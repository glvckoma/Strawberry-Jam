// Core account testing loop, authentication calls, and related logic.
"use strict";

import { testerState } from './tester-state.js';
// Import necessary UI functions
import { renderTesterAccountList, updateTesterSummary, setTesterMessage, updateTesterButtons } from './tester-ui.js';
// Assuming 'globals' is accessible globally or passed in during initialization.

// Conditional logging helper - relies on testerState
function debugLog(...args) {
    if (testerState.debugLoggingEnabled) {
        console.log('[DEBUG][TesterLogic]', ...args);
    }
}

// --- Error Message Helper ---
function getFriendlyErrorMessage(error, username = '') {
    const userPart = username ? ` for ${username}` : '';
    let message = `An unexpected error occurred${userPart}.`; // Default message

    if (error) {
        debugLog(`[getFriendlyErrorMessage] Raw error:`, error); // Log the raw error for debugging
        const raw = (error && error.message) ? error.message : '';
        switch (raw) {
            case 'WRONG_CREDENTIALS':
            case 'LOGIN_ERROR': // Treat LOGIN_ERROR similarly
                message = `Invalid username or password${userPart}.`;
                break;
            case 'BANNED':
                message = `Account ${username} is banned.`;
                break;
            case 'SUSPENDED':
                message = `Account ${username} is suspended.`;
                break;
            case 'OTP_NEEDED':
                message = `Account ${username} requires OTP verification.`;
                break;
            case 'FORBIDDEN':
                message = `Access Forbidden (403)${userPart}. IP might be blocked.`;
                break;
            case 'RATE_LIMITED':
                message = `Rate Limited (503)${userPart}. Please wait before retrying.`;
                break;
            // Add more specific mappings as needed
            case 'Failed to fetch':
            case 'NetworkError when attempting to fetch resource.': // Common browser network error
                message = `Network error occurred${userPart}. Check your connection or try again later.`;
                break;
            default:
                // Refine common generic error patterns
                if (/Invalid response code: (\d+|undefined)/i.test(raw)) {
                    message = `The server returned an unexpected response. Please try again later.`;
                } else if (/timeout/i.test(raw)) {
                    message = `The request timed out${userPart}. Please check your connection and try again.`;
                } else if (/fetch/i.test(raw) || /network/i.test(raw)) {
                    message = `A network error occurred${userPart}. Please check your connection.`;
                } else if (testerState.debugLoggingEnabled && raw) {
                    message = `An unexpected error occurred${userPart}: ${raw}`;
                } else {
                    message = `A server or network error occurred${userPart}. Please try again later.`;
                }
                break;
        }
    }
    debugLog(`[getFriendlyErrorMessage] Friendly message: "${message}"`);
    return message;
}
// --- End Error Message Helper ---


// Returns the final status string, or a special string ('otp', 'rate-limited', etc.) if testing should pause
async function testAccount(account, index) {
    debugLog(`testAccount called for index ${index}: ${account.username}`);
    // Ensure account exists and is pending or was interrupted during testing
    if (!account || (account.status !== 'pending' && account.status !== 'testing')) {
        debugLog(`testAccount skipped for index ${index}: Status is ${account?.status}`);
        return account?.status || 'error'; // Return current status if not pending/testing
    }

    account.status = 'testing';
    renderTesterAccountList(); // Update UI to show 'testing' status
    updateTesterSummary(); // Update summary counts
    let finalStatus = 'error'; // Default to error

    try {
        debugLog(`Calling globals.authenticateWithPassword for ${account.username}`);
        // Store original df value
        const originalDf = globals.df;
        // Generate new UUID for this login attempt
        const randomDf = window.ipc.uuidv4();
        debugLog(`Using randomized device fingerprint: ${randomDf}`);
        
        try {
            // Temporarily replace df with random UUID
            globals.df = randomDf;
            // Use the existing global authentication function
            await globals.authenticateWithPassword(account.username, account.password);
            debugLog(`Authentication success for ${account.username}`);
        } finally {
            // Always restore original df value
            globals.df = originalDf;
            debugLog('Restored original device fingerprint');
        }
        account.status = 'works';
        finalStatus = 'works';
        debugLog(`Sending tester-save-works IPC for ${account.username}`);
        // Ensure 'window.ipc' is accessible here
        window.ipc.send('tester-save-works', `${account.username}:${account.password}`);
    } catch (err) {
        // Log the raw error message first
        debugLog(`Raw authentication error for ${account.username}:`, err);
        debugLog(`Processing mapped error for ${account.username}:`, err.name, err.message);
        // Track if a known error message has been shown
        let knownErrorShown = false;
        // Check if the error is due to an abort/timeout first
        if (err.name === 'Aborted' || err.name === 'TimedOut') {
            debugLog(`Test for ${account.username} aborted/timed out. Status remains 'testing'.`);
            // Signal that the test was interrupted, but don't change the account's visible status.
            finalStatus = 'interrupted'; // Use a specific internal status for loop control.
        } else {
            // Map other error messages to statuses
            switch (err.message) {
                case 'WRONG_CREDENTIALS':
                    debugLog(`Result for ${account.username}: WRONG_CREDENTIALS`);
                    account.status = 'invalid';
                    finalStatus = 'invalid';
                    setTesterMessage(getFriendlyErrorMessage(err, account.username), null, { priority: 'known' });
                    knownErrorShown = true;
                    break;
                case 'BANNED':
                    debugLog(`Result for ${account.username}: BANNED`);
                    account.status = 'banned';
                    finalStatus = 'banned';
                    setTesterMessage(getFriendlyErrorMessage(err, account.username), null, { priority: 'known' });
                    knownErrorShown = true;
                    break;
                case 'SUSPENDED':
                    debugLog(`Result for ${account.username}: SUSPENDED`);
                    account.status = 'suspended';
                    finalStatus = 'suspended';
                    setTesterMessage(getFriendlyErrorMessage(err, account.username), null, { priority: 'known' });
                    knownErrorShown = true;
                    break;
                case 'OTP_NEEDED':
                    debugLog(`Result for ${account.username}: OTP_NEEDED`);
                    account.status = 'otp';
                    finalStatus = 'otp'; // Signal loop to pause
                    setTesterMessage(getFriendlyErrorMessage(err, account.username), null, { priority: 'known' });
                    knownErrorShown = true;
                    break;
                case 'FORBIDDEN': // Handle 403 Forbidden
                    debugLog(`Result for ${account.username}: FORBIDDEN (403)`);
                    account.status = 'pending'; // Keep status as pending to allow retry
                    finalStatus = 'forbidden'; // Signal loop to pause
                    setTesterMessage(getFriendlyErrorMessage(err, account.username) + ' Click Continue to retry.', null, { priority: 'known' });
                    knownErrorShown = false;
                    break;
                case 'RATE_LIMITED': // Handle 503 Rate Limit
                    debugLog(`Result for ${account.username}: RATE_LIMITED (503)`);
                    account.status = 'pending'; // Keep status as pending to allow retry
                    finalStatus = 'rate-limited'; // Signal loop to pause and retry same account
                    // Always show the rate limit message, even if a known error was already shown
                    setTesterMessage(getFriendlyErrorMessage(err, account.username) + ` Auto-retry in ${testerState.retryDelay / 1000}s or click Continue.`, null, { priority: 'known' });
                    knownErrorShown = true;
                    break;
                case 'LOGIN_ERROR': // Handle LOGIN_ERROR (typically 401 - bad credentials) as 'invalid' and continue
                    debugLog(`Result for ${account.username}: LOGIN_ERROR (Invalid)`);
                    account.status = 'invalid';
                    finalStatus = 'invalid';
                    setTesterMessage(getFriendlyErrorMessage(err, account.username), null, { priority: 'known' });
                    knownErrorShown = true;
                    break;
                case 'ERROR':
                default:
                    debugLog(`Result for ${account.username}: Generic Error (${err.message || 'Unknown'})`);
                    account.status = 'pending'; // Keep status as pending to allow retry
                    finalStatus = 'generic-error'; // Signal loop to pause
                    // If this is a rate limit error, always show the message (should be caught above, but double-check)
                    if (err && (err.message === 'RATE_LIMITED' || /rate.?limit|503/i.test(err.message))) {
                        setTesterMessage(getFriendlyErrorMessage(err, account.username) + ` Auto-retry in ${testerState.retryDelay / 1000}s or click Continue.`, null, { priority: 'known' });
                        debugLog('Rate limit detected in generic error; overwriting message.');
                    } else if (!knownErrorShown) {
                        setTesterMessage(getFriendlyErrorMessage(err, account.username) + ' Click Continue to retry.', 5000, { priority: 'generic' });
                        console.error(`[TesterLogic] Generic error testing ${account.username}:`, err);
                    } else {
                        debugLog('Known error message already shown; skipping generic error message overwrite.');
                    }
                    break;
            }
        }
    } finally {
        debugLog(`testAccount finally block for index ${index}. Final status determined: ${finalStatus}`);
        // Ensure UI is updated even if errors occur during saving
        // Update UI unless interrupted (status will be updated on next render anyway)
        if (finalStatus !== 'interrupted') {
            renderTesterAccountList(); // Call UI function
        }
        updateTesterSummary(); // Call UI function

        // --- State Saving ---
        // Save the status unless the test was interrupted (aborted/timed out)
        if (finalStatus !== 'interrupted' && testerState.lastFilePath && account) {
            try {
                debugLog(`Saving state for account index ${index} (${account.username}) with status ${account.status}`);

                // Get current state first to merge updates
                // Ensure 'window.ipc' is accessible here
                const currentState = await window.ipc.invoke('get-app-state');
                const accountKey = `${account.username}:${account.password}`;

                // Ensure nested structure exists
                const currentAccountTesterState = currentState.accountTester || {};
                const currentFileStates = currentAccountTesterState.fileStates || {};
                const currentSpecificFileState = currentFileStates[testerState.lastFilePath] || {};

                // Create the new state object by merging
                const newState = {
                    ...currentState,
                    accountTester: {
                        ...currentAccountTesterState,
                        fileStates: {
                            ...currentFileStates,
                            [testerState.lastFilePath]: {
                                ...currentSpecificFileState,
                                [accountKey]: account.status // Update/add the specific account's status
                            }
                        }
                        // Keep existing scrollIndex and filterQuery (handled separately)
                    }
                };

                // Send the updated state back to the main process
                await window.ipc.invoke('set-app-state', newState);
                debugLog(`State saved successfully for index ${index}.`);
            } catch (err) {
                console.error(`[TesterLogic] Error saving tester state for index ${index}:`, err);
            }
        } else {
            debugLog(`Skipping state save for index ${index} (status: ${finalStatus}, path: ${testerState.lastFilePath}, account exists: ${!!account})`);
        }
        // --- End State Saving ---
    }
    // Return status for loop control ('works', 'invalid', 'otp', 'forbidden', 'rate-limited', 'error', 'interrupted', 'generic-error')
    return finalStatus;
}

// Extracted loop logic
async function runTestLoop() {
    debugLog(`runTestLoop starting/resuming. Initial state: pausedState=${testerState.pausedState}, currentIndex=${testerState.currentIndex}, isTesting=${testerState.isTesting}, shouldStop=${testerState.shouldStop}`);

    // Clear paused state as we are running now (will be set again if needed)
    const resumingFromPause = testerState.pausedState !== 'none';
    if (resumingFromPause) debugLog('Resuming from pause state:', testerState.pausedState);
    testerState.pausedState = 'none';
    setTesterMessage(''); // Clear any previous messages via UI function

    // Update button state *immediately* after clearing pause state if resuming
    // or when starting fresh
    updateTesterButtons(); // Call UI function


    // Determine start index
    let startIndex = 0;
    let initialRetry = false; // Flag for rate-limit retry

    // Determine start index based on pause state
    if (['ratelimit', 'forbidden', 'generic-error'].includes(testerState.pausedState) && testerState.currentIndex >= 0) {
        // Resuming from rate limit, forbidden, or generic error: retry the *same* index
        startIndex = testerState.currentIndex;
        if (testerState.pausedState === 'ratelimit') {
            initialRetry = true; // Only set retry flag for rate limit
        }
        debugLog(`Resuming loop to retry index ${startIndex} after ${testerState.pausedState} pause.`);
    } else if (testerState.pausedState === 'otp' && testerState.currentIndex >= 0) {
        // Resuming from OTP: move to the *next* index
        startIndex = testerState.currentIndex + 1;
        debugLog(`Resuming loop from index ${startIndex} after OTP pause.`);
    } else if (testerState.currentIndex >= 0) {
        // Starting fresh, continuing after success/error, or resuming after a stop *during* a test
        if (!testerState.isTesting && testerState.currentIndex < testerState.accounts.length - 1) {
            startIndex = testerState.currentIndex + 1;
            debugLog(`Continuing loop from index ${startIndex} (after completed/stopped test).`);
        } else if (!testerState.isTesting && testerState.currentIndex >= testerState.accounts.length - 1) {
            startIndex = 0;
            debugLog(`Loop previously completed or stopped after last item. Resetting start index to 0.`);
        } else {
            startIndex = testerState.currentIndex;
            debugLog(`Starting/Resuming loop from index ${startIndex} (fresh start or after interruption).`);
        }
    } else {
        startIndex = 0;
        debugLog(`Starting loop from beginning (index 0).`);
    }

    // Ensure startIndex is within bounds if accounts exist
    if (testerState.accounts.length > 0 && startIndex >= testerState.accounts.length) {
        startIndex = 0;
        debugLog(`Start index was out of bounds, resetting to 0.`);
    } else if (testerState.accounts.length === 0) {
        startIndex = -1;
        debugLog(`No accounts loaded, setting start index to -1.`);
    }

    debugLog(`Determined loop start index: ${startIndex}`);
    // Ensure loop doesn't run if startIndex is invalid (-1)
    for (let i = startIndex; i >= 0 && i < testerState.accounts.length; /* i increment handled below */) {
        debugLog(`Loop iteration: index=${i}`);
        // Check for STOP request (graceful stop after current)
        if (testerState.shouldStop) {
            debugLog('Stop requested, breaking loop.');
            break;
        }

        const account = testerState.accounts[i];
        testerState.currentIndex = i; // Update current index

        // --- Auto-scroll ---
        renderTesterAccountList(true); // Call UI function to scroll
        // --- End Auto-scroll ---


        // Handle Retry Logic for Rate Limit
        let currentRetryAttempt = testerState.retryAttempts.get(i) || 0;
        let shouldTestAccount = account.status === 'pending'; // Assume test if pending

        if (initialRetry) {
            initialRetry = false; // Consume the initial retry flag
            currentRetryAttempt++;
            testerState.retryAttempts.set(i, currentRetryAttempt);
            shouldTestAccount = true; // Force test on initial retry

            if (currentRetryAttempt > testerState.MAX_RETRY_ATTEMPTS) {
                debugLog(`Account ${account.username} (index ${i}) exceeded max retry attempts (${testerState.MAX_RETRY_ATTEMPTS}) for rate limit.`);
                account.status = 'error'; // Mark as error after max retries
                setTesterMessage(`Account ${account.username} failed after ${testerState.MAX_RETRY_ATTEMPTS} rate limit retries.`); // Call UI function
                testerState.retryAttempts.delete(i); // Clean up attempt count for this index
                renderTesterAccountList(); // Call UI function
                updateTesterSummary(); // Call UI function
                i++; // Move to the next account
                continue; // Skip testing this account further
            } else {
                setTesterMessage(`Retrying account ${account.username} (attempt ${currentRetryAttempt}/${testerState.MAX_RETRY_ATTEMPTS}) after ${testerState.retryDelay / 1000}s delay...`, null); // Call UI function
                debugLog(`Delaying ${testerState.retryDelay}ms before retrying index ${i} (attempt ${currentRetryAttempt}).`);
                await new Promise(resolve => setTimeout(resolve, testerState.retryDelay));
                // Check for STOP request *during* the delay
                if (testerState.shouldStop) {
                    debugLog('Stop requested during retry delay.');
                    break;
                }
                setTesterMessage(`Retrying account ${account.username} (attempt ${currentRetryAttempt}/${testerState.MAX_RETRY_ATTEMPTS})...`, null); // Call UI function
            }
        } else if (account.status === 'pending') {
            debugLog(`Resetting retry attempts for index ${i} (normal pending test).`);
            // If it's a normal pending test (not a retry), reset attempt count for this index
            testerState.retryAttempts.delete(i);
        }


        if (shouldTestAccount) {
            renderTesterAccountList(); // Update selection visually before test via UI function
            const resultStatus = await testAccount(account, i); // Pass index

            debugLog(`testAccount result for index ${i}: ${resultStatus}`);
            // Handle pausing based on result
            if (resultStatus === 'otp') {
                testerState.pausedState = 'otp';
                debugLog(`Pausing loop due to OTP for index ${i}.`);
                testerState.retryAttempts.delete(i); // Reset retries if OTP occurs
                await waitForOtpModalClose(); // This still needs access to the DOM/modal
                debugLog('OTP modal closed, loop will continue from next account on "Continue" click.');
                updateTesterButtons(); // Update button to "Continue" via UI function
                return; // Exit the loop function, wait for user
            } else if (resultStatus === 'rate-limited') {
                testerState.pausedState = 'ratelimit';
                debugLog(`Pausing loop due to Rate Limit for index ${i}.`);
                // Retry attempts handled at the start of the next loop iteration for this index
                updateTesterButtons(); // Update button to "Continue" via UI function
                return; // Exit the loop function, wait for user
            } else if (resultStatus === 'forbidden') {
                testerState.pausedState = 'forbidden';
                debugLog(`Pausing loop due to Forbidden (403) for index ${i}.`);
                testerState.retryAttempts.delete(i); // Reset retries if forbidden occurs
                updateTesterButtons(); // Update button to "Continue" via UI function
                return; // Exit the loop function, wait for user
            } else if (resultStatus === 'generic-error') {
                testerState.pausedState = 'generic-error';
                debugLog(`Pausing loop due to Generic Error for index ${i}.`);
                testerState.retryAttempts.delete(i); // Reset retries if generic error occurs
                updateTesterButtons(); // Update button to "Continue" via UI function
                return; // Exit the loop function, wait for user
            } else if (resultStatus === 'interrupted') { // Handle the 'interrupted' status
                debugLog(`Test for index ${i} was interrupted (aborted/timed out). Loop will check stop/cancel flags.`);
                // Do not increment i here. The loop's main stop/cancel checks at the top will handle termination.
            } else {
                debugLog(`Account ${i} processed with status ${resultStatus}. Resetting retries.`);
                // Account processed successfully or failed with non-retryable error
                testerState.retryAttempts.delete(i); // Reset retry count for this index
                // Increment index ONLY if the loop didn't pause/exit AND wasn't interrupted
                if (resultStatus !== 'interrupted') {
                    i++;
                }
            }


            // Delay before next account only if loop is continuing (not paused, stopped, or interrupted)
            if (i < testerState.accounts.length && !testerState.shouldStop && testerState.pausedState === 'none') {
                debugLog(`Delaying ${testerState.interTestDelay}ms before next account (index ${i}).`);
                await new Promise(resolve => setTimeout(resolve, testerState.interTestDelay));
                // Check for STOP request *during* the delay
                if (testerState.shouldStop) {
                    debugLog('Stop requested during inter-test delay.');
                    break;
                }
            }
        } else {
            debugLog(`Skipping test for index ${i} (status: ${account.status}), moving to next.`);
            // If account is not pending (and not an initial retry), reset its retry count and move to the next one
            testerState.retryAttempts.delete(i);
            renderTesterAccountList(); // Update selection visually via UI function
            i++; // Move to the next index
        }
    }

    // Loop finished (either completed or stopped)
    debugLog(`Test loop finished. Final state: isTesting=${testerState.isTesting}, shouldStop=${testerState.shouldStop}, pausedState=${testerState.pausedState}`);
    testerState.isTesting = false;
    testerState.shouldStop = false; // Reset stop flag
    testerState.pausedState = 'none'; // Reset pause state
    // Ensure 'globals' is accessible here
    if (globals.currentAbortController) {
        globals.currentAbortController = null; // Clear the abort controller
    }
    updateTesterButtons(); // Reset button states via UI function
    updateTesterSummary(); // Update summary via UI function
    setTesterMessage(''); // Clear message via UI function
}

// Helper to wait for OTP modal to close - This still needs DOM access
// It might need to live in tester-ui.js or be passed the modal layer element.
async function waitForOtpModalClose() {
    debugLog('waitForOtpModalClose called.');
    // TODO: This needs access to the main document's modal layer.
    // This function likely needs to be moved or adapted.
    const modalLayer = document.getElementById("modal-layer"); // This won't work directly here
    if (!modalLayer || !modalLayer.querySelector("otp-modal")) {
        debugLog('OTP modal not found, returning immediately.');
        return;
    }
    debugLog('OTP modal found, setting up MutationObserver.');
    return new Promise(resolve => {
        const observer = new MutationObserver((mutationsList, observer) => {
            debugLog('MutationObserver triggered for OTP modal.');
            if (!modalLayer.querySelector("otp-modal")) {
                observer.disconnect();
                resolve();
            }
        });
        observer.observe(modalLayer, { childList: true });
    });
}

// Processes the currently selected account, marking it with a given status
// This might be better placed in tester-ui.js as it directly triggers UI updates and IPC based on user action (shortcuts)
async function processCurrentAccount(status) {
    debugLog(`processCurrentAccount called with status: ${status}, currentIndex: ${testerState.currentIndex}`);
    // Allow processing even if paused, but not if actively testing an account right now
    if ((testerState.isTesting && testerState.pausedState === 'none') || testerState.currentIndex === -1) {
        debugLog('processCurrentAccount ignored: Tester running or no selection.');
        return;
    }

    const account = testerState.accounts[testerState.currentIndex];
    if (!account || account.status === status) {
        debugLog(`processCurrentAccount no change needed for index ${testerState.currentIndex}. Current status: ${account?.status}`);
        return; // No change needed
    }

    debugLog(`Updating status for index ${testerState.currentIndex} (${account.username}) to ${status}.`);
    account.status = status;

    // Save based on status
    const accountString = `${account.username}:${account.password}`;
    if (status === 'works') {
        // For 'works' status, we need to verify with a randomized UUID login attempt
        debugLog(`Verifying 'works' status with randomized UUID login for ${account.username}`);
        
        // Store original df value
        const originalDf = globals.df;
        // Generate new UUID for this verification
        const randomDf = window.ipc.uuidv4();
        debugLog(`Using randomized device fingerprint for verification: ${randomDf}`);
        
        try {
            // Temporarily replace df with random UUID
            globals.df = randomDf;
            // Verify the account works
            await globals.authenticateWithPassword(account.username, account.password);
            debugLog(`Verification successful for ${account.username}`);
            // Send save IPC after successful verification
            window.ipc.send('tester-save-works', accountString);
        } catch (err) {
            debugLog(`Verification failed for ${account.username}:`, err);
            // If verification fails, set status back to pending
            account.status = 'pending';
            // Use helper function for message
            setTesterMessage(getFriendlyErrorMessage(err, account.username));
        } finally {
            // Always restore original df value
            globals.df = originalDf;
            debugLog('Restored original device fingerprint after verification');
        }
    }

    renderTesterAccountList(); // Call UI function
    updateTesterSummary(); // Call UI function

    // Optionally move to the next account *only if not paused*
    if (testerState.pausedState === 'none' && testerState.currentIndex < testerState.accounts.length - 1) {
        debugLog(`Moving to next account index: ${testerState.currentIndex + 1}`);
        testerState.currentIndex++;
        renderTesterAccountList(); // Update selection visually via UI function
    }
    updateTesterButtons(); // Update button states via UI function
}


// Export the functions to be used by other modules (mainly tester-ui.js)
export {
    debugLog,
    testAccount,
    runTestLoop,
    waitForOtpModalClose, // Note: This function needs DOM access adaptation
    processCurrentAccount, // Note: This function might be better in tester-ui.js
    updateTesterAccountStatus // Export the new function
};

// --- New Status Update Function ---
async function updateTesterAccountStatus(index, status, error = null) {
    debugLog(`updateTesterAccountStatus called for index ${index}, status ${status}, error:`, error);

    if (index < 0 || index >= testerState.accounts.length) {
        console.error(`[TesterLogic] Invalid index (${index}) passed to updateTesterAccountStatus.`);
        return;
    }

    const account = testerState.accounts[index];
    if (!account) {
        console.error(`[TesterLogic] Account not found at index ${index} for updateTesterAccountStatus.`);
        return;
    }

    // Update status
    account.status = status;

    // Update UI
    renderTesterAccountList();
    updateTesterSummary();

    // Show error message if provided
    if (error) {
        setTesterMessage(getFriendlyErrorMessage(error, account.username), null, { priority: 'known' });
    }

    // Save state
    if (testerState.lastFilePath) {
        try {
            debugLog(`Saving state via updateTesterAccountStatus for account index ${index} (${account.username}) with status ${account.status}`);
            const currentState = await window.ipc.invoke('get-app-state');
            const accountKey = `${account.username}:${account.password}`;
            const currentAccountTesterState = currentState.accountTester || {};
            const currentFileStates = currentAccountTesterState.fileStates || {};
            const currentSpecificFileState = currentFileStates[testerState.lastFilePath] || {};

            const newState = {
                ...currentState,
                accountTester: {
                    ...currentAccountTesterState,
                    fileStates: {
                        ...currentFileStates,
                        [testerState.lastFilePath]: {
                            ...currentSpecificFileState,
                            [accountKey]: account.status
                        }
                    }
                }
            };
            await window.ipc.invoke('set-app-state', newState);
            debugLog(`State saved successfully via updateTesterAccountStatus for index ${index}.`);
        } catch (err) {
            console.error(`[TesterLogic] Error saving tester state via updateTesterAccountStatus for index ${index}:`, err);
        }
    } else {
        debugLog(`Skipping state save via updateTesterAccountStatus for index ${index} (no lastFilePath)`);
    }
}

// Register with the bridge
if (window.registerUpdateTesterAccountStatus) {
    window.registerUpdateTesterAccountStatus(updateTesterAccountStatus);
    debugLog('[TesterLogic] Registered updateTesterAccountStatus with bridge.');
} else {
    console.error('[TesterLogic] Bridge function registerUpdateTesterAccountStatus not found!');
}
