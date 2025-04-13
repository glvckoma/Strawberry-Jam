#!/usr/bin/env node
/**
 * Standalone CLI script to process logged usernames against LeakCheck API.
 *
 * Interactive prompt before starting. Listens for 's' keypress to stop cleanly.
 * Reads API key from --api-key argument > AppData config > settings.json fallback.
 * Uses file paths relative to CWD or specified via arguments.
 *
 * Usage:
 * node process_logs.js [options]
 *
 * Options:
 *   -k, --api-key            LeakCheck API Key (overrides automatic detection) [string]
 *   -i, --input-file         Path to collected usernames file      [string] [default: "data/collected_usernames.txt"]
 *   -p, --processed-file     Path to processed usernames file      [string] [default: "data/processed_usernames.txt"]
 *   -o, --output-dir         Directory for output files            [string] [default: "data"]
 *   -l, --limit              Max number of new usernames to check  [number] [default: Infinity]
 *   -d, --delay              Delay between API calls (ms)          [number] [default: 400]
 *       --no-overwrite-input Prevent overwriting the input file after processing [boolean] [default: false]
 *       --non-interactive    Skip interactive prompt and run directly [boolean] [default: false]
 *   -h, --help               Show help                             [boolean]
 *
 * Example:
 * node process_logs.js # Interactive mode
 * node process_logs.js --non-interactive -l 1000 # Run directly
 * node process_logs.js -k YOUR_API_KEY --input-file my_list.txt --output-dir results/ --non-interactive
 */

const fs = require('fs').promises;
const path = require('path');
const os = require('os');
const axios = require('axios');
const yargs = require('yargs/yargs');
const { hideBin } = require('yargs/helpers');
// REMOVED: const inquirer = require('inquirer'); // Removed CommonJS require
const readline = require('readline');


// --- Constants ---
const LEAKCHECK_API_URL = 'https://leakcheck.io/api/v2/query';
const APP_DATA_PATH = path.join(os.homedir(), 'AppData', 'Roaming', 'jam', 'config.json'); // Correct path for AppData config
const SETTINGS_PATH_ROOT = path.resolve('settings.json'); // Root settings as last fallback

// --- Global State for Stop Handling ---
let shouldStop = false;

// --- Argument Parsing ---
const argv = yargs(hideBin(process.argv))
    .usage('Usage: $0 [options]') // Add usage string
    .option('k', { alias: 'api-key', type: 'string', description: 'LeakCheck API Key (overrides automatic detection)' })
    .option('i', { alias: 'input-file', type: 'string', description: 'Path to collected usernames file', default: path.join('data', 'collected_usernames.txt') })
    .option('p', { alias: 'processed-file', type: 'string', description: 'Path to processed usernames file', default: path.join('data', 'processed_usernames.txt') })
    .option('o', { alias: 'output-dir', type: 'string', description: 'Directory for output files', default: 'data' })
    .option('l', { alias: 'limit', type: 'number', description: 'Max number of new usernames to check', default: Infinity })
    .option('d', { alias: 'delay', type: 'number', description: 'Delay between API calls (ms)', default: 400 })
    .option('no-overwrite-input', { type: 'boolean', description: 'Prevent overwriting the input file after processing', default: false })
    .option('non-interactive', { type: 'boolean', description: 'Skip interactive prompt and run directly', default: false })
    .help()
    .alias('h', 'help')
    .epilogue('Reads API key from --api-key > AppData config > settings.json fallback.') // Add epilogue
    .argv;

// --- Configuration ---
const loggedUsernamesPath = path.resolve(argv.inputFile);
const dontLogUsernamesPath = path.resolve(argv.processedFile);
const outputDirPath = path.resolve(argv.outputDir);
const accountsToTryPath = path.join(outputDirPath, 'potential_accounts.txt');
const foundAccountsPath = path.join(outputDirPath, 'found_accounts.txt');
const ajcConfirmedPath = path.join(outputDirPath, 'ajc_accounts.txt');
const rateLimitDelay = argv.delay;
const processLimit = argv.limit;
const preventOverwrite = argv.noOverwriteInput;
// --- End Configuration ---

// Helper function for delay
const wait = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// --- Function to get API Key ---
async function getApiKey(providedKey) {
    // 1. Check CLI argument
    if (providedKey) {
        console.log('Using API Key provided via --api-key argument.');
        return providedKey;
    }

    // 2. Check AppData config.json
    console.log(`Attempting to read API Key from AppData: ${APP_DATA_PATH}...`);
    try {
        const appDataConfigRaw = await fs.readFile(APP_DATA_PATH, 'utf8');
        const appDataConfig = JSON.parse(appDataConfigRaw);
        if (appDataConfig.leakCheckApiKey) {
            console.log('API Key successfully read from AppData config.json.');
            return appDataConfig.leakCheckApiKey;
        }
        console.log('API Key not found in AppData config.json.');
    } catch (error) {
        if (error.code === 'ENOENT') {
            console.log('AppData config.json not found.');
        } else {
            console.warn(`Warning: Could not read or parse AppData config.json: ${error.message}`);
        }
    }

    // 3. Fallback to root settings.json
    console.log(`Attempting to read API Key from root settings.json: ${SETTINGS_PATH_ROOT}...`);
     try {
        const settingsData = await fs.readFile(SETTINGS_PATH_ROOT, 'utf8');
        const settings = JSON.parse(settingsData);
        if (settings.leakCheckApiKey) {
            console.log('API Key successfully read from root settings.json (fallback).');
            return settings.leakCheckApiKey;
        }
        console.log('API Key not found in root settings.json.');
    } catch (error) {
         if (error.code === 'ENOENT') {
            console.log('Root settings.json not found.');
        } else {
            console.warn(`Warning: Could not read or parse root settings.json: ${error.message}`);
        }
    }

    // 4. If not found anywhere
    return null; // Return null instead of exiting, handle in main logic
}

// --- Setup Stop Listener ---
function setupStopListener() {
    console.log("\nPress 's' then Enter to stop cleanly...");
    readline.emitKeypressEvents(process.stdin);
    if (process.stdin.isTTY) {
        process.stdin.setRawMode(true);
    }
    process.stdin.on('keypress', (str, key) => {
        if (key.ctrl && key.name === 'c') {
            console.log('\nCtrl+C detected. Stopping...');
            shouldStop = true;
            // Give writeBatches a moment to run in the loop check
            setTimeout(() => process.exit(1), 500);
        } else if (str === 's') {
            console.log('\nStop key pressed. Finishing current check and stopping...');
            shouldStop = true;
        }
    });
}

function cleanupStopListener() {
     if (process.stdin.isTTY) {
        process.stdin.setRawMode(false);
    }
    process.stdin.pause(); // Stop listening
    process.stdin.removeAllListeners('keypress');
}


// --- Core Processing Function ---
async function runLeakCheckProcess(apiKey, config) {
    const {
        loggedUsernamesPath,
        dontLogUsernamesPath,
        outputDirPath,
        accountsToTryPath,
        foundAccountsPath,
        ajcConfirmedPath,
        rateLimitDelay,
        processLimit,
        preventOverwrite
    } = config;

    shouldStop = false; // Reset stop flag
    setupStopListener(); // Start listening for stop key

    // --- Ensure Output Directory Exists ---
    try {
        await fs.mkdir(outputDirPath, { recursive: true });
    } catch (error) {
        console.error(`Error creating output directory ${outputDirPath}: ${error.message}`);
        cleanupStopListener();
        process.exit(1);
    }

    // --- Read Already Checked Usernames ---
    let alreadyCheckedUsernames = new Set();
    try {
        const dontLogData = await fs.readFile(dontLogUsernamesPath, 'utf8');
        dontLogData.split(/\r?\n/).forEach(u => { if (u.trim()) alreadyCheckedUsernames.add(u.trim().toLowerCase()); });
        console.log(`Loaded ${alreadyCheckedUsernames.size} usernames from processed list (${path.basename(dontLogUsernamesPath)}).`);
    } catch (error) {
        if (error.code !== 'ENOENT') console.warn(`Warning: Could not read ${dontLogUsernamesPath}: ${error.message}`);
        else console.log(`Processed file (${path.basename(dontLogUsernamesPath)}) not found, starting fresh.`);
    }
     try {
        const accountsToTryData = await fs.readFile(accountsToTryPath, 'utf8');
        let addedFromPotential = 0;
        accountsToTryData.split(/\r?\n/).forEach(u => {
             if (u.trim() && alreadyCheckedUsernames.add(u.trim().toLowerCase())) {
                 addedFromPotential++;
             }
        });
        if (addedFromPotential > 0) {
            console.log(`Loaded ${addedFromPotential} additional usernames from potential list (${path.basename(accountsToTryPath)}). Total ignored: ${alreadyCheckedUsernames.size}`);
        }
    } catch (error) {
        if (error.code !== 'ENOENT') console.warn(`Warning: Could not read ${accountsToTryPath}: ${error.message}`);
    }

    // --- Read Logged Usernames and Filter ---
    let usernamesToProcess = [];
    let originalLogSize = 0;
    try {
        const loggedData = await fs.readFile(loggedUsernamesPath, 'utf8');
        const uniqueUsernamesInLog = new Set();
        loggedData.split(/\r?\n/).forEach(line => {
            let match = line.match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z - (.+)$/);
            let username = null;
            if (match && match[1]) {
               username = match[1].trim();
            } else if (line.trim() && !line.trim().startsWith('---')) {
               username = line.trim();
            }
            if (username) {
                uniqueUsernamesInLog.add(username);
            }
        });
        originalLogSize = uniqueUsernamesInLog.size;
        usernamesToProcess = [...uniqueUsernamesInLog].filter(u => !alreadyCheckedUsernames.has(u.toLowerCase()));
        console.log(`Found ${originalLogSize} unique usernames in log, ${usernamesToProcess.length} need checking.`);
    } catch (error) {
        if (error.code === 'ENOENT') {
            console.error(`Error: Input file ${loggedUsernamesPath} not found.`);
        } else {
            console.error(`Error reading ${loggedUsernamesPath}: ${error.message}`);
        }
        cleanupStopListener();
        process.exit(1);
    }

    // --- Apply Limit and Check ---
    const limitedUsernames = usernamesToProcess.slice(0, processLimit);
    if (limitedUsernames.length === 0) {
         console.log('\nNo new usernames to process.');
         cleanupStopListener();
         process.exit(0);
    }

    console.log(`\nProcessing ${limitedUsernames.length} usernames...`);
    let processedCount = 0;
    let foundCount = 0;
    let notFoundCount = 0;
    let invalidCharCount = 0;
    let errorCount = 0;

    // Batches for writing
    const BATCH_SIZE = 100;
    let processedBatch = [];
    let foundGeneralBatch = [];
    let foundAjcBatch = [];
    let potentialBatch = [];

    // Helper function to write batches
    const writeBatches = async (force = false) => {
        const shouldWrite = force ||
                           processedBatch.length >= BATCH_SIZE ||
                           foundGeneralBatch.length >= BATCH_SIZE ||
                           foundAjcBatch.length >= BATCH_SIZE ||
                           potentialBatch.length >= BATCH_SIZE;
        if (!shouldWrite) return;

        if (force || processedCount % (BATCH_SIZE * 2) === 0) {
             console.log(`  -> Writing batches (Processed: ${processedBatch.length}, FoundGen: ${foundGeneralBatch.length}, FoundAJC: ${foundAjcBatch.length}, Potential: ${potentialBatch.length})`);
        }
        try {
            const writePromises = [];
            if (processedBatch.length > 0) writePromises.push(fs.appendFile(dontLogUsernamesPath, processedBatch.join('\n') + '\n'));
            if (foundGeneralBatch.length > 0) writePromises.push(fs.appendFile(foundAccountsPath, foundGeneralBatch.join('\n') + '\n'));
            if (foundAjcBatch.length > 0) writePromises.push(fs.appendFile(ajcConfirmedPath, foundAjcBatch.join('\n') + '\n'));
            if (potentialBatch.length > 0) {
                writePromises.push(fs.appendFile(accountsToTryPath, potentialBatch.join('\n') + '\n'));
                writePromises.push(fs.appendFile(dontLogUsernamesPath, potentialBatch.join('\n') + '\n'));
            }
            await Promise.all(writePromises);
            processedBatch = []; foundGeneralBatch = []; foundAjcBatch = []; potentialBatch = [];
        } catch (writeError) {
           console.error(`\n  -> Batch File Write Error: ${writeError.message}`);
        }
    };

    // --- Main Loop ---
    try {
        for (const username of limitedUsernames) {
            if (shouldStop) {
                console.log('\nStop requested. Breaking loop...');
                break;
            }

            processedCount++;
            if (processedCount % 50 === 0 || processedCount === 1 || processedCount === limitedUsernames.length) {
                process.stdout.write(`Progress: ${processedCount}/${limitedUsernames.length} (${Math.round((processedCount/limitedUsernames.length)*100)}%) \r`);
            }

            try {
                await wait(rateLimitDelay);
                const response = await axios.get(`${LEAKCHECK_API_URL}/${encodeURIComponent(username)}`, {
                    params: { type: 'username' }, headers: { 'X-API-Key': apiKey }, validateStatus: (status) => status < 500
                });
                let addedToProcessed = false;
                if (response.status === 200 && response.data?.success && response.data?.found > 0) {
                    foundCount++; addedToProcessed = true;
                    let passwordsFoundGeneral = 0, passwordsFoundAjc = 0;
                    if (Array.isArray(response.data.result)) {
                        for (const breach of response.data.result) {
                            if (breach.password) {
                                const accountEntry = `${username}:${breach.password}`;
                                const isAjcSource = (breach.source && breach.source.name === "AnimalJam.com");
                                if (isAjcSource) { foundAjcBatch.push(accountEntry); passwordsFoundAjc++; }
                                else { foundGeneralBatch.push(accountEntry); passwordsFoundGeneral++; }
                            }
                        }
                    }
                    if (passwordsFoundAjc > 0 || passwordsFoundGeneral > 0) {
                        process.stdout.clearLine(0); process.stdout.cursorTo(0);
                        console.log(`[FOUND] ${username} - Saved ${passwordsFoundAjc} AJC / ${passwordsFoundGeneral} General passwords.`);
                    }
                } else if (response.status === 200 && response.data?.success && response.data?.found === 0) {
                    notFoundCount++; addedToProcessed = true;
                } else if (response.status === 400 && response.data?.error === 'Invalid characters in query') {
                    invalidCharCount++; addedToProcessed = false;
                    process.stdout.clearLine(0); process.stdout.cursorTo(0);
                    console.warn(`[INVALID CHARS] ${username} - Saving for manual check.`);
                    potentialBatch.push(username);
                } else {
                    errorCount++; addedToProcessed = false;
                    process.stdout.clearLine(0); process.stdout.cursorTo(0);
                    console.error(`[API ERROR] ${username}: Status ${response.status} - ${JSON.stringify(response.data)}`);
                }
                if (addedToProcessed) processedBatch.push(username);
                await writeBatches();
            } catch (requestError) {
                errorCount++; process.stdout.clearLine(0); process.stdout.cursorTo(0);
                let errorMessage = requestError.message;
                if (requestError.response) errorMessage = `Status ${requestError.response.status} - ${JSON.stringify(requestError.response.data)}`;
                else if (requestError.request) errorMessage = 'No response received from API server.';
                console.error(`[REQUEST ERROR] ${username}: ${errorMessage}`);
            }
        } // End loop
    } finally {
        process.stdout.write("\n");
        console.log('Writing final batches before exit...');
        await writeBatches(true);
        cleanupStopListener();
    }


    console.log(`\n--- Processing Summary ---`);
    console.log(`Checked:      ${processedCount}`);
    console.log(`Found:        ${foundCount}`);
    console.log(`Not Found:    ${notFoundCount}`);
    console.log(`Invalid Chars:${invalidCharCount}`);
    console.log(`Errors:       ${errorCount}`);
    console.log(`--------------------------`);


    // --- Overwrite log file with unprocessed usernames (Optional) ---
    if (!preventOverwrite) {
        console.log('\nAttempting to update input file (if needed)...');
        try {
            const finalProcessedData = await fs.readFile(dontLogUsernamesPath, 'utf8');
            const finalProcessedSet = new Set();
            finalProcessedData.split(/\r?\n/).forEach(u => { if (u.trim()) finalProcessedSet.add(u.trim().toLowerCase()); });

            const originalLogData = await fs.readFile(loggedUsernamesPath, 'utf8');
            const originalUsernames = new Set();
             originalLogData.split(/\r?\n/).forEach(line => {
                let match = line.match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z - (.+)$/);
                let username = null;
                if (match && match[1]) username = match[1].trim();
                else if (line.trim() && !line.trim().startsWith('---')) username = line.trim();
                if (username) originalUsernames.add(username);
            });

            const unprocessedUsernames = [...originalUsernames].filter(u => !finalProcessedSet.has(u.toLowerCase()));

            if (unprocessedUsernames.length < originalUsernames.size) {
                console.log(`Overwriting ${loggedUsernamesPath} with ${unprocessedUsernames.length} unprocessed usernames...`);
                 const newLogContentLines = [];
                 originalLogData.split(/\r?\n/).forEach(line => {
                    let match = line.match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z - (.+)$/);
                    let username = null;
                    if (match && match[1]) username = match[1].trim();
                    else if (line.trim() && !line.trim().startsWith('---')) username = line.trim();
                    if (username && unprocessedUsernames.includes(username)) newLogContentLines.push(line);
                    else if (!username && line.trim() === '') { /* Keep empty lines? */ }
                 });
                const newLogContent = newLogContentLines.join('\n');
                await fs.writeFile(loggedUsernamesPath, newLogContent, 'utf8');
                console.log(`Successfully updated ${loggedUsernamesPath}.`);
            } else {
                 console.log(`${loggedUsernamesPath} remains unchanged (no usernames processed or removed).`);
            }
        } catch (error) {
            console.error(`\nError updating ${loggedUsernamesPath} after processing: ${error.message}`);
        }
    } else {
        console.log(`\nSkipping overwrite of input file (${loggedUsernamesPath}) due to --no-overwrite-input flag.`);
    }
    console.log('\nProcessing finished.');
}

// --- Main Execution Logic ---
async function main() {
    // Dynamically import inquirer
    const inquirer = (await import('inquirer')).default;

    const apiKey = await getApiKey(argv.apiKey); // Pass CLI key if provided
    if (!apiKey && !argv.nonInteractive) { // Check if API key is missing and we are in interactive mode
        console.error('\nError: LeakCheck API Key could not be found.');
        console.error('Please provide the API key using the --api-key argument,');
        console.error(`or ensure it exists in "${APP_DATA_PATH}" (preferred),`);
        console.error(`or ensure it exists in "${SETTINGS_PATH_ROOT}".`);
        process.exit(1);
    } else if (!apiKey && argv.nonInteractive) {
         console.error('\nError: LeakCheck API Key could not be found and non-interactive mode is enabled.');
         process.exit(1);
    }


    const config = {
        loggedUsernamesPath,
        dontLogUsernamesPath,
        outputDirPath,
        accountsToTryPath,
        foundAccountsPath,
        ajcConfirmedPath,
        rateLimitDelay,
        processLimit,
        preventOverwrite
    };

    if (argv.nonInteractive) {
        console.log('Non-interactive mode enabled. Starting process directly.');
        await runLeakCheckProcess(apiKey, config);
    } else {
        console.log('\n--- Configuration ---');
        // Determine API key source for display
        let apiKeySource = 'Not Found';
        if (argv.apiKey) {
            apiKeySource = 'CLI Argument';
        } else {
            try {
                 const appDataConfigRaw = await fs.readFile(APP_DATA_PATH, 'utf8');
                 const appDataConfig = JSON.parse(appDataConfigRaw);
                 if (appDataConfig.leakCheckApiKey) apiKeySource = 'AppData';
            } catch { /* Ignore error */ }
            if (apiKeySource === 'Not Found') {
                 try {
                    const settingsData = await fs.readFile(SETTINGS_PATH_ROOT, 'utf8');
                    const settings = JSON.parse(settingsData);
                    if (settings.leakCheckApiKey) apiKeySource = 'settings.json (Fallback)';
                 } catch { /* Ignore error */ }
            }
        }

        console.log(`API Key Source:     ${apiKeySource}`);
        console.log(`Input File:         ${loggedUsernamesPath}`);
        console.log(`Processed File:     ${dontLogUsernamesPath}`);
        console.log(`Output Directory:   ${outputDirPath}`);
        console.log(`Processing limit:   ${processLimit === Infinity ? 'All' : processLimit}`);
        console.log(`API Delay:          ${rateLimitDelay}ms`);
        console.log(`Overwrite Input:    ${!preventOverwrite}`);
        console.log('---------------------');

        const answers = await inquirer.prompt([
            {
                type: 'confirm',
                name: 'proceed',
                message: 'Proceed with the leak check using these settings?',
                default: true,
            },
        ]);

        if (answers.proceed) {
            await runLeakCheckProcess(apiKey, config);
        } else {
            console.log('Operation cancelled by user.');
            process.exit(0);
        }
    }
}

// --- Run the main function ---
main().catch(error => {
    console.error("\nAn unexpected error occurred:", error);
    cleanupStopListener(); // Attempt cleanup on error
    process.exit(1);
});
