"use strict";

const fs = require('fs').promises;
const path = require('path');
const os = require('os');
const { app } = require('electron');

// Dynamic axios loading to handle both CommonJS and ES module environments
let axios;
try {
    // Try CommonJS require first
    axios = require('axios');
} catch (error) {
    console.error('Failed to load axios via CommonJS require:', error.message);
    // We'll handle this later when making requests
}

// Helper function for delay
const wait = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// --- Constants ---
const leakCheckApiUrl = 'https://leakcheck.io/api/v2/query';
const defaultRateLimitDelay = 400; // Milliseconds

// --- File Names (Using Original Names for Compatibility) ---
const ACCOUNTS_TO_TRY_FILE = 'accounts-to-try.txt'; // Original name
const PROCESSED_FILE = 'dont-log-usernames.txt'; // Original name for processed list
const FOUND_GENERAL_FILE = 'accounts.txt'; // Original name for general finds
const FOUND_AJC_FILE = 'ajc_confirmed_accounts.txt'; // Original name for AJC finds
const LOGGED_USERNAMES_FILE = 'logged_usernames.txt'; // Input file (remains the same)

/**
 * Processes logged usernames against the LeakCheck API.
 *
 * @param {object} options - Configuration options.
 * @param {BrowserWindow.webContents} options.webContents - The webContents of the main window to send IPC messages.
 * @param {function} options.log - The logging function (e.g., Jam's main process log).
 * @param {Store} options.store - The electron-store instance for settings (API key, output dir).
 * @param {string} options.appDataPath - The application data path.
 * @param {number} [options.limit=Infinity] - Maximum number of usernames to process in this run.
 * @param {number} [options.startIndex=0] - The index in the input file to start processing from.
 * @param {function} options.updateStateCallback - Async function to report state updates (e.g., { status: 'running', lastProcessedIndex: 123 }).
 * @param {function} [options.checkPauseStatus=() => false] - Function to check if pause is requested.
 * @param {function} [options.checkStopStatus=() => false] - Function to check if stop is requested.
 */
async function startLeakCheck(options) {
    const {
        webContents,
        log,
        store,
        appDataPath,
        limit = Infinity,
        startIndex = 0,
        updateStateCallback = async () => {}, // No-op default
        checkPauseStatus = () => false, // Default to not paused
        checkStopStatus = () => false   // Default to not stopped
    } = options;

    const sendResult = (success, message, summary = null) => {
        // Ensure webContents is checked before sending final result
        if (webContents && !webContents.isDestroyed()) {
            webContents.send('leak-check-result', { success, message, summary });
        }
    };

    // Ensure axios is available
    if (!axios) {
        try {
            // Try to load axios dynamically if it wasn't loaded at the top level
            axios = require('axios');
            log('info', '[LeakCheck] Successfully loaded axios dynamically');
        } catch (error) {
            log('error', `[LeakCheck] Failed to load axios: ${error.message}`);
            await updateStateCallback({ status: 'error', lastProcessedIndex: startIndex - 1 });
            sendResult(false, 'Failed to load axios HTTP client. Check installation.');
            return;
        }
    }

    log('info', '[LeakCheck] Starting leak check process...');
    // sendStatus('Starting...'); // Replaced with log

    // --- Determine Output Directory ---
    let outputDir = appDataPath; // <-- Default to appDataPath first
    try {
      const customOutputDir = store.get('leakCheckOutputDir');
      if (customOutputDir && typeof customOutputDir === 'string') {
        // Basic validation: check if it's an absolute path (more robust checks could be added)
        if (path.isAbsolute(customOutputDir)) {
          outputDir = customOutputDir;
          log('info', `[LeakCheck] Using custom output directory: ${outputDir}`);
        } else {
          log('warn', `[LeakCheck] Custom output directory '${customOutputDir}' is not absolute. Using default.`);
        }
      } else {
        log('info', '[LeakCheck] No custom output directory set. Using default.');
      }
      // Ensure the chosen directory exists (create if not) - important for custom paths
      await fs.mkdir(outputDir, { recursive: true });
    } catch (error) {
      log('error', `[LeakCheck] Error determining/creating output directory: ${error.message}. Using default.`);
      outputDir = appDataPath; // <-- Fallback to appDataPath on error
      try {
        await fs.mkdir(outputDir, { recursive: true }); // Try creating default just in case
      } catch (mkdirError) {
        log('error', `[LeakCheck] Failed to create default output directory: ${mkdirError.message}`);
        sendResult(false, 'Failed to create output directory.');
        return; // Cannot proceed without a writable directory
      }
    }
    log('info', `[LeakCheck] Output directory set to: ${outputDir}`); // Replaced sendStatus

    // --- Define Full Output File Paths ---
    const accountsToTryPath = path.join(outputDir, ACCOUNTS_TO_TRY_FILE);
    const dontLogUsernamesPath = path.join(outputDir, PROCESSED_FILE); // This is the processed list
    const foundAccountsPath = path.join(outputDir, FOUND_GENERAL_FILE);
    const ajcConfirmedPath = path.join(outputDir, FOUND_AJC_FILE);
    // Use appDataPath for the input file (logged usernames from UsernameLogger)
    const loggedUsernamesPath = path.join(appDataPath, 'UsernameLogger', LOGGED_USERNAMES_FILE);

    // --- Read API Key ---
    let apiKey;
    log('debug', '[LeakCheck] Store instance received:', store);
    try {
        apiKey = store.get('leakCheckApiKey');
        log('info', `[LeakCheck] API Key retrieved from store: ${apiKey ? '****** (found)' : '(not found)'}`);
        if (!apiKey) {
            log('error', '[LeakCheck] Error: LeakCheck API Key not found or is empty in settings.');
            await updateStateCallback({ status: 'error', lastProcessedIndex: startIndex - 1 }); // Report error state
            sendResult(false, 'LeakCheck API Key not found in settings.');
            return;
        }
        log('info', '[LeakCheck] API Key found.');
        // sendStatus('API Key found.'); // Replaced with log
    } catch (error) {
        log('error', `[LeakCheck] Error reading API Key from store: ${error.message}`);
        sendResult(false, 'Error reading API Key from settings.');
        return;
    }

    // --- Read Logged Usernames (Input) ---
    let allUsernamesInLog = [];
    try {
        const loggedData = await fs.readFile(loggedUsernamesPath, 'utf8');
        const uniqueUsernamesInLog = new Set();
        loggedData.split(/\r?\n/).forEach(line => {
            // Try matching timestamp format first
            let match = line.match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z - (.+)$/);
            let username = null;
            if (match && match[1]) {
               username = match[1].trim();
            // Otherwise, assume the line is the username if not empty/separator
            } else if (line.trim() && !line.trim().startsWith('---')) {
               username = line.trim();
            }
            // Add to set if a username was extracted
            if (username) {
                uniqueUsernamesInLog.add(username);
            }
        });
        allUsernamesInLog = [...uniqueUsernamesInLog]; // Convert set to array
        log('info', `[LeakCheck] Found ${allUsernamesInLog.length} unique usernames in log file.`);
    } catch (error) {
        if (error.code === 'ENOENT') {
            log('error', `[LeakCheck] Error: Input file ${path.basename(loggedUsernamesPath)} not found.`);
            await updateStateCallback({ status: 'error', lastProcessedIndex: startIndex - 1 });
            sendResult(false, `${path.basename(loggedUsernamesPath)} not found. Log some usernames first.`);
        } else {
            log('error', `[LeakCheck] Error reading ${path.basename(loggedUsernamesPath)}: ${error.message}`);
            await updateStateCallback({ status: 'error', lastProcessedIndex: startIndex - 1 });
            sendResult(false, `Error reading ${path.basename(loggedUsernamesPath)}.`);
        }
        return;
    }

    // --- Determine Usernames to Process in This Run ---
    const usernamesToCheckThisRun = allUsernamesInLog.slice(startIndex);
    const limitedUsernamesToCheck = usernamesToCheckThisRun.slice(0, limit);

    if (limitedUsernamesToCheck.length === 0) {
         log('info', '[LeakCheck] No new usernames to process from the starting index.');
         await updateStateCallback({ status: 'completed', lastProcessedIndex: allUsernamesInLog.length - 1 }); // Mark as completed up to the end
         sendResult(true, 'No new usernames to process.');
         return;
    }

    log('info', `[LeakCheck] Starting check from index ${startIndex}. Processing up to ${limitedUsernamesToCheck.length} usernames (limit: ${limit})...`);
    // sendStatus(`Processing ${limitedUsernamesToCheck.length} usernames (starting from index ${startIndex})...`); // Replaced with log

    // --- Read Already Checked Usernames (for duplicate output prevention) ---
    // Read these closer to the loop to ensure they are fresh if the process runs long
    let alreadyCheckedUsernames = new Set();
    try {
        const dontLogData = await fs.readFile(dontLogUsernamesPath, 'utf8');
        dontLogData.split(/\r?\n/).forEach(u => { if (u.trim()) alreadyCheckedUsernames.add(u.trim().toLowerCase()); });
        log('info', `[LeakCheck] Loaded ${alreadyCheckedUsernames.size} usernames from processed list (for output filtering).`);
    } catch (error) {
        if (error.code !== 'ENOENT') log('warn', `[LeakCheck] Warning: Could not read ${path.basename(dontLogUsernamesPath)} for output filtering: ${error.message}`);
    }
    // Note: We might also want to read accountsToTryPath here if we want to avoid adding duplicates there too.

    // --- Processing Loop ---
    let processedInThisRun = 0;
    let foundCount = 0;
    let notFoundCount = 0;
    let errorCount = 0;
    let invalidCharCount = 0;
    let currentOverallIndex = startIndex - 1; // Tracks the index in the *original* allUsernamesInLog array

    for (const username of limitedUsernamesToCheck) {
        currentOverallIndex++; // Increment index for the current username being processed
        processedInThisRun++;

        // --- Check for Pause/Stop Signals ---
        if (checkStopStatus()) {
            log('info', '[LeakCheck] Stop signal detected. Aborting loop.');
            await updateStateCallback({ status: 'stopped', lastProcessedIndex: currentOverallIndex - 1 }); // Save index before stopping
            sendResult(true, 'Leak check stopped by user.');
            return; // Exit the function
        }
        if (checkPauseStatus()) {
            log('info', '[LeakCheck] Pause signal detected. Pausing loop.');
            await updateStateCallback({ status: 'paused', lastProcessedIndex: currentOverallIndex - 1 }); // Save index before pausing
            sendResult(true, 'Leak check paused.');
            // Exit the function. The main process needs to handle resuming by calling startLeakCheck again.
            return;
        }
        // ---

        const progressDetails = {
            current: processedInThisRun,
            totalInRun: limitedUsernamesToCheck.length,
            overallIndex: currentOverallIndex,
            username: username
        };
        // Remove sendStatus call for detailed progress string
        // sendStatus(`Checking ${processedInThisRun}/${limitedUsernamesToCheck.length} (Index ${currentOverallIndex}): ${username}`, progressDetails);
        log('debug', `[LeakCheck] [${processedInThisRun}/${limitedUsernamesToCheck.length} | Index ${currentOverallIndex}] Checking: ${username}`);

        // Skip if already in the processed list (read earlier)
        if (alreadyCheckedUsernames.has(username.toLowerCase())) {
            log('info', `[LeakCheck]   -> Skipping ${username} (already processed according to ${path.basename(dontLogUsernamesPath)}).`);
            // Still need to update state index if skipping
            await updateStateCallback({ status: 'running', lastProcessedIndex: currentOverallIndex });
            continue;
        }


        try {
            await wait(defaultRateLimitDelay); // Apply rate limit delay
            const response = await axios.get(`${leakCheckApiUrl}/${encodeURIComponent(username)}`, {
                params: { type: 'username' },
                headers: { 'X-API-Key': apiKey },
                validateStatus: (status) => status < 500 // Handle 4xx as non-errors, 5xx as errors
            });

            let addedToProcessedList = false;

            if (response.status === 200 && response.data?.success && response.data?.found > 0) {
                foundCount++;
                addedToProcessedList = true; // Mark for adding to processed list
                log('info', `[LeakCheck]   -> Found ${response.data.found} results for: ${username}`);
                let passwordsFoundGeneral = 0;
                let passwordsFoundAjc = 0;
                if (Array.isArray(response.data.result)) {
                    for (const breach of response.data.result) {
                        if (breach.password) {
                            const accountEntry = `${username}:${breach.password}\n`;
                            let targetPath = foundAccountsPath;
                            let isAjcSource = false;
                            // Check if source exists and name is AnimalJam.com
                            if (breach.source && typeof breach.source === 'object' && breach.source.name === "AnimalJam.com") {
                                targetPath = ajcConfirmedPath;
                                isAjcSource = true;
                            } else if (typeof breach.source === 'string' && breach.source === "AnimalJam.com") {
                                // Handle case where source might just be a string (less likely based on API docs but safe)
                                targetPath = ajcConfirmedPath;
                                isAjcSource = true;
                            }
                            // Avoid adding duplicates to output files
                            // Note: Reading the entire output file each time is inefficient.
                            // A better approach might be to keep Sets of usernames already added to output files in memory.
                            // For now, we skip this check for simplicity, relying on the processed list check.
                            try {
                                await fs.appendFile(targetPath, accountEntry);
                                if (isAjcSource) passwordsFoundAjc++; else passwordsFoundGeneral++;
                            } catch (writeError) {
                                log('error', `[LeakCheck]   -> File Write Error (${path.basename(targetPath)}): ${writeError.message}`);
                            }
                        }
                    }
                }
                // Log saving details
                if (passwordsFoundAjc > 0 || passwordsFoundGeneral > 0) {
                    let logMessage = "    -> Saved ";
                    if (passwordsFoundAjc > 0) logMessage += `${passwordsFoundAjc} password(s) to ${path.basename(ajcConfirmedPath)}`;
                    if (passwordsFoundAjc > 0 && passwordsFoundGeneral > 0) logMessage += " and ";
                    if (passwordsFoundGeneral > 0) logMessage += `${passwordsFoundGeneral} password(s) to ${path.basename(foundAccountsPath)}`;
                    log('info', logMessage + ".");
                } else {
                    log('info', `[LeakCheck]   -> No passwords found in results for ${username}, but breach exists.`);
                }

            } else if (response.status === 200 && response.data?.success && response.data?.found === 0) {
                notFoundCount++;
                addedToProcessedList = true; // Mark for adding to processed list
                log('info', `[LeakCheck]   -> Not Found: ${username}`);

            } else if (response.status === 400 && response.data?.error === 'Invalid characters in query') {
                 invalidCharCount++;
                 addedToProcessedList = false; // Do not add invalid char usernames to processed list automatically
                 log('warn', `[LeakCheck]   -> Invalid Characters for API: ${username}. Saving for manual check.`);
                 // Avoid adding duplicates to accountsToTryPath
                 if (!alreadyCheckedUsernames.has(username.toLowerCase())) {
                     try {
                         await fs.appendFile(accountsToTryPath, `${username}\n`);
                         alreadyCheckedUsernames.add(username.toLowerCase()); // Add here to prevent re-adding in same run
                     } catch (writeError) {
                         log('error', `[LeakCheck]   -> File Write Error (${path.basename(accountsToTryPath)}): ${writeError.message}`);
                     }
                 }

            } else {
                errorCount++;
                addedToProcessedList = false; // Do not add to processed list on unexpected API response
                log('error', `[LeakCheck]   -> Unexpected API Response for ${username}: Status ${response.status} - ${JSON.stringify(response.data)}`);
            }

            // Add to processed list only if API call was successful (found or not found)
            // and not already in the set (to avoid duplicates if run multiple times without clearing state)
            if (addedToProcessedList && !alreadyCheckedUsernames.has(username.toLowerCase())) {
                try {
                    await fs.appendFile(dontLogUsernamesPath, `${username}\n`);
                    alreadyCheckedUsernames.add(username.toLowerCase()); // Add to set to prevent re-processing in same run
                    // Update state only after successfully adding to processed list
                    await updateStateCallback({ status: 'running', lastProcessedIndex: currentOverallIndex });
                } catch (writeError) {
                   log('error', `[LeakCheck]   -> File Write Error (${path.basename(dontLogUsernamesPath)}): ${writeError.message}`);
                   // Don't update state if writing to processed list fails
                }
            } else if (!addedToProcessedList) {
                // If not added to processed list (error, invalid chars), don't advance the state index
                log('warn', `[LeakCheck]   -> Did not advance state index for ${username} due to error or invalid characters.`);
            } else {
                 // If already processed, still advance the state index
                 await updateStateCallback({ status: 'running', lastProcessedIndex: currentOverallIndex });
            }

        } catch (requestError) {
            errorCount++;
            // Don't advance state index on request error
            let errorMessage = requestError.message;
            if (requestError.response) { // Error response from server (e.g., 5xx)
                errorMessage = `Status ${requestError.response.status} - ${JSON.stringify(requestError.response.data)}`;
            } else if (requestError.request) { // No response received
                errorMessage = 'No response received from API server.';
            } // Otherwise, use the basic error message
            log('error', `[LeakCheck]   -> Request Error for ${username}: ${errorMessage}`);
        }
    } // End of loop

    const summary = {
        processed: processedInThisRun, // Report count for this specific run
        found: foundCount,
        notFound: notFoundCount,
        invalidChar: invalidCharCount,
        errors: errorCount,
        startIndex: startIndex,
        lastIndexProcessed: currentOverallIndex // Report the actual last index processed
    };
    log('info', `[LeakCheck] Processing run complete. Summary: ${JSON.stringify(summary)}`);

    // Determine final status based on whether we processed everything intended for this run
    const expectedEndIndex = startIndex + limitedUsernamesToCheck.length - 1;
    // Determine final status - consider it completed only if we processed everything *and* there were no errors preventing state updates
    let finalStatus = 'stopped'; // Default to stopped if loop exited early
    if (currentOverallIndex >= expectedEndIndex) {
        finalStatus = 'completed';
    }

    let finalIndexToSave = currentOverallIndex;

    // --- Automatic Cleanup on Completion ---
    if (finalStatus === 'completed') {
        log('info', '[LeakCheck] Process completed successfully. Resetting index and clearing input file.');
        finalIndexToSave = -1; // Reset index for the state update
        try {
            // Clear the input file (logged_usernames.txt)
            await fs.writeFile(loggedUsernamesPath, '', 'utf8');
            log('info', `[LeakCheck] Successfully cleared input file: ${path.basename(loggedUsernamesPath)}`);
        } catch (clearError) {
            log('error', `[LeakCheck] Failed to clear input file ${path.basename(loggedUsernamesPath)} after completion: ${clearError.message}`);
            // Proceed with updating state, but log the error.
            // Don't change finalStatus back to error just because cleanup failed.
        }
    }
    // --- End Automatic Cleanup ---

    // Update state with the final status and potentially reset index
    await updateStateCallback({ status: finalStatus, lastProcessedIndex: finalIndexToSave });
    sendResult(true, `Leak check run complete. Status: ${finalStatus}`, summary);

    // Note: Manual cleanup logic removed in favor of automatic cleanup on completion.
}

module.exports = { startLeakCheck };
