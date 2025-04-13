// IPC communication handlers specific to the Account Tester
"use strict";

import { testerState } from './tester-state.js';
import { debugLog, processCurrentAccount } from './tester-logic.js'; // Import necessary logic
// Import ALL necessary UI functions
import {
    renderTesterAccountList,
    updateTesterButtons,
    updateTesterSummary,
    setTesterMessage,
    updateSavePathDisplay,
    updateDelayInputs,
    updateToggleStates
} from './tester-ui.js';

// Helper function to load and apply saved state for a file
async function loadAndApplySavedState(filePath) {
    debugLog('[IPC] Loading tester state via get-app-state.');
    try {
        const appState = await window.ipc.invoke('get-app-state');
        const currentTesterState = appState?.accountTester || {};
        const fileState = currentTesterState.fileStates?.[filePath];
        const savedScrollIndex = currentTesterState.scrollIndex?.[filePath] || 0;

        if (fileState) {
            debugLog('[IPC] Applying saved state for file:', filePath);
            let appliedCount = 0;
            testerState.accounts.forEach(acc => {
                const accountKey = `${acc.username}:${acc.password}`;
                if (fileState[accountKey]) {
                    acc.status = fileState[accountKey];
                    appliedCount++;
                } else {
                    acc.status = 'pending';
                }
            });
            debugLog(`[IPC] Applied saved status to ${appliedCount} accounts.`);
        } else {
            debugLog('[IPC] No saved state found for this file, defaulting all to pending.');
            testerState.accounts.forEach(acc => acc.status = 'pending');
        }

        debugLog(`[IPC] Scroll position to restore: ${savedScrollIndex}`);
        return true;
    } catch (err) {
        console.error('[IPC] Error loading tester state:', err);
        setTesterMessage('Error loading saved state.');
        testerState.accounts.forEach(acc => acc.status = 'pending');
        return false;
    }
}

function setupTesterIPCListeners() {
    debugLog("Setting up Tester IPC listeners.");

    // --- State Loading & Updates ---
    window.ipc.on("tester-accounts-loaded", async (event, data) => {
        console.log('[AUTOLOAD] Received tester-accounts-loaded:', data ? `success=${data.success}, accounts=${data.accounts?.length}` : 'null');
        debugLog('[IPC] Received tester-accounts-loaded:', data);
        if (data && data.success) {
            console.log(`[AUTOLOAD] Successfully loaded ${data.accounts?.length || 0} accounts from ${data.filePath}`);
            testerState.accounts = data.accounts || [];
            testerState.currentIndex = testerState.accounts.length > 0 ? 0 : -1;
            testerState.lastFilePath = data.filePath;
            setTesterMessage(''); // Clear message initially

            // Load state *after* loading accounts from file
            console.log('[AUTOLOAD] Loading and applying saved state for manual load');
            await loadAndApplySavedState(testerState.lastFilePath);

            // Defer the UI updates slightly to allow layout calculation
            console.log('[AUTOLOAD] Deferring UI updates for manual load');
            setTimeout(() => {
                console.log('[AUTOLOAD] Executing deferred UI updates for manual load');
                // First render to get elements in DOM
                renderTesterAccountList(true); // Call UI function
                
                // Then use requestAnimationFrame for a second render after layout
                requestAnimationFrame(() => {
                    console.log('[AUTOLOAD] First animation frame for manual load - waiting for layout');
                    requestAnimationFrame(() => {
                        console.log('[AUTOLOAD] Second animation frame for manual load - rendering with layout');
                        // Final render with correct measurements
                        renderTesterAccountList(true);
                        updateTesterButtons(); // Call UI function
                        updateTesterSummary(); // Call UI function
                        console.log('[AUTOLOAD] UI updates complete for manual load');
                    });
                });
                
                debugLog(`[IPC] Deferred initial render complete for ${data.filePath}.`);
            }, 0); // 0ms timeout defers execution until after current stack clears

            debugLog(`[IPC] Loaded ${testerState.accounts.length} accounts from ${data.filePath}. State applied.`);

        } else {
            console.error(`[IPC] Error loading accounts file: ${data?.error || 'Unknown error'}`);
            window.alert(`Error loading accounts file: ${data?.error || 'Unknown error'}`); // Keep alert for user feedback
        }
    });
    // REMOVED loginSucceeded listener - Moved to tester-bridge.js


    // Listeners for shortcut triggers
    window.ipc.on('tester-trigger-works', () => {
        debugLog('[IPC] Received tester-trigger-works.');
        processCurrentAccount('works'); // Call logic function
    });

    window.ipc.on('tester-trigger-does-not-work', () => {
        debugLog('[IPC] Received tester-trigger-does-not-work.');
        processCurrentAccount('invalid'); // Call logic function
    });

    // Listener for save path selection/result
    window.ipc.on('tester-save-path-result', (event, data) => {
        debugLog('[IPC] Received tester-save-path-result:', data);
        if (data.success && data.filePath) {
            testerState.saveFilePath = data.filePath; // Update state
            // UI update will happen in initTesterUI or manually if needed later
            debugLog('Sending tester-set-save-path IPC.');
            window.ipc.send('tester-set-save-path', data.filePath);
        } else if (data.error) {
            console.error('[IPC] Error selecting save file:', data.error);
            setTesterMessage(`Error selecting save file: ${data.error}`); // Call UI function for error message
        } else {
            debugLog('[IPC] Save path selection canceled or no path returned.');
            testerState.saveFilePath = null; // Update state
            // UI update will happen in initTesterUI or manually if needed later
            debugLog('Sending tester-set-save-path IPC with null.');
            window.ipc.send('tester-set-save-path', null);
        }
    });

    // Listener for last path result (for initial loading)
    window.ipc.on("tester-last-path-result", (event, lastPath) => {
        console.log('[AUTOLOAD] Received tester-last-path-result:', lastPath);
        debugLog('[IPC] Received tester-last-path-result:', lastPath);
        if (lastPath) {
            testerState.lastFilePath = lastPath; // Update state
            console.log(`[AUTOLOAD] Last path found: ${lastPath}. Requesting auto-load.`);
            debugLog(`Received last used path: ${lastPath}. Requesting auto-load.`);
            console.log('[AUTOLOAD] Sending tester-load-specific-file IPC.');
            window.ipc.send('tester-load-specific-file', lastPath);
        } else {
            console.log('[AUTOLOAD] No last path found. Auto-load sequence terminated.');
        }
    });

    // Listener for the result of the auto-load attempt
    window.ipc.on('tester-specific-file-loaded', async (event, data) => {
        console.log('[AUTOLOAD] Received tester-specific-file-loaded:', data ? `success=${data.success}, accounts=${data.accounts?.length}` : 'null');
        debugLog('[IPC] Received tester-specific-file-loaded:', data);
        if (data && data.success) {
            console.log(`[AUTOLOAD] Successfully loaded ${data.accounts?.length || 0} accounts from ${data.filePath}`);
            testerState.accounts = data.accounts || []; // Update state
            testerState.currentIndex = testerState.accounts.length > 0 ? 0 : -1; // Update state
            testerState.lastFilePath = data.filePath; // Update state
            
            // Load and apply saved state before UI updates
            console.log('[AUTOLOAD] Loading and applying saved state');
            await loadAndApplySavedState(data.filePath);
            
            // Defer the UI updates slightly to allow layout calculation
            console.log('[AUTOLOAD] Deferring UI updates');
            setTimeout(() => {
                console.log('[AUTOLOAD] Executing deferred UI updates');
                // First render to get elements in DOM
                renderTesterAccountList(true); // Call UI function
                
                // Then use requestAnimationFrame for a second render after layout
                requestAnimationFrame(() => {
                    console.log('[AUTOLOAD] First animation frame - waiting for layout');
                    requestAnimationFrame(() => {
                        console.log('[AUTOLOAD] Second animation frame - rendering with layout');
                        // Final render with correct measurements
                        renderTesterAccountList(true);
                        updateTesterButtons(); // Call UI function
                        updateTesterSummary(); // Call UI function
                        setTesterMessage(`Auto-loaded ${testerState.accounts.length} accounts from ${data.filePath.split(/[\\/]/).pop()}.`); // Call UI function
                        console.log('[AUTOLOAD] UI updates complete');
                    });
                });
                
                debugLog(`[IPC] Deferred initial render complete for auto-loaded file ${data.filePath}`);
            }, 0); // 0ms timeout defers execution until after current stack clears

            debugLog(`Auto-loaded ${testerState.accounts.length} accounts from ${data.filePath}`);
        } else {
            console.error(`[IPC] Error auto-loading file ${data.filePath}: ${data.error}`);
            setTesterMessage(`Error auto-loading last file: ${data.error}`); // Call UI function
        }
    });

    // Listener for loaded delays
    window.ipc.on('tester-delays-loaded', (event, delays) => {
        debugLog('[IPC] Received tester-delays-loaded:', delays);
        let stateChanged = false;
        if (typeof delays.interTestDelay === 'number' && delays.interTestDelay >= 0) {
            testerState.interTestDelay = delays.interTestDelay; // Update state
            stateChanged = true;
            debugLog(`[IPC] Applied interTestDelay from main: ${testerState.interTestDelay}`);
        } else {
            debugLog(`[IPC] Invalid or missing interTestDelay received from main: ${delays.interTestDelay}`);
        }
        if (typeof delays.retryDelay === 'number' && delays.retryDelay >= 0) {
            testerState.retryDelay = delays.retryDelay; // Update state
            stateChanged = true;
            debugLog(`[IPC] Applied retryDelay from main: ${testerState.retryDelay}`);
        } else {
            debugLog(`[IPC] Invalid or missing retryDelay received from main: ${delays.retryDelay}`);
        }

        // Always log the final values being set
        debugLog(`[IPC] Final delay values after load: interTestDelay=${testerState.interTestDelay}, retryDelay=${testerState.retryDelay}`);

        // Defer UI updates to ensure DOM elements are accessible
        setTimeout(() => {
            debugLog(`[IPC] Calling updateDelayInputs after delay load. UI should show: interTestDelay=${testerState.interTestDelay}, retryDelay=${testerState.retryDelay}`);
            updateDelayInputs();
        }, 100); // Small delay to ensure DOM is ready
    });

    // Listener for loaded debug mode state
    window.ipc.on('tester-debug-mode-loaded', (event, isEnabled) => {
        debugLog(`[IPC] Received tester-debug-mode-loaded: ${isEnabled}`);
        testerState.debugLoggingEnabled = !!isEnabled; // Update state
        
        // Defer UI updates to ensure DOM elements are accessible
        setTimeout(() => {
            debugLog('[IPC] Deferred updateToggleStates call after tester-debug-mode-loaded');
            updateToggleStates();
            
            // Dispatch event for GameScreen (assuming document is accessible)
            document.dispatchEvent(new CustomEvent('tester-debug-state-changed', {
                detail: { isEnabled: testerState.debugLoggingEnabled }
            }));
        }, 100); // Small delay to ensure DOM is ready
    });

    // Listener for loaded actual login mode state
    window.ipc.on('tester-actual-login-mode-loaded', (event, isEnabled) => {
        debugLog(`[IPC] Received tester-actual-login-mode-loaded: ${isEnabled}`);
        testerState.actualLoginEnabled = !!isEnabled; // Update state
        
        // Defer UI updates to ensure DOM elements are accessible
        setTimeout(() => {
            debugLog('[IPC] Deferred updateToggleStates and updateTesterButtons call after tester-actual-login-mode-loaded');
            updateToggleStates();
            updateTesterButtons(); // Keep this one as it affects button logic immediately
        }, 100); // Small delay to ensure DOM is ready
    });

    // Listener for loaded disable devtools mode state
    window.ipc.on('tester-disable-devtools-mode-loaded', (event, isEnabled) => {
        debugLog(`[IPC] Received tester-disable-devtools-mode-loaded: ${isEnabled}`);
        testerState.disableDevToolsEnabled = !!isEnabled; // Update state
        
        // Defer UI updates to ensure DOM elements are accessible
        setTimeout(() => {
            debugLog('[IPC] Deferred updateToggleStates call after tester-disable-devtools-mode-loaded');
            updateToggleStates();
        }, 100); // Small delay to ensure DOM is ready
    });

    // Listener for reload result
    window.ipc.on('tester-reload-list-result', async (event, data) => {
        console.log('[AUTOLOAD] Received tester-reload-list-result:', data ? `success=${data.success}, accounts=${data.accounts?.length}` : 'null');
        debugLog('[IPC] Received tester-reload-list-result:', data);
        // Update button state via UI function
        updateTesterButtons();
        if (data && data.success) {
            console.log(`[AUTOLOAD] Successfully reloaded ${data.accounts?.length || 0} accounts from ${data.filePath}`);
            testerState.accounts = data.accounts || []; // Update state
            testerState.currentIndex = testerState.accounts.length > 0 ? 0 : -1; // Update state
            
            // Load and apply saved state before UI updates
            console.log('[AUTOLOAD] Loading and applying saved state for reload');
            await loadAndApplySavedState(data.filePath);
            
            // Defer the UI updates slightly to allow layout calculation
            console.log('[AUTOLOAD] Deferring UI updates for reload');
            setTimeout(() => {
                console.log('[AUTOLOAD] Executing deferred UI updates for reload');
                // First render to get elements in DOM
                renderTesterAccountList(true); // Call UI function
                
                // Then use requestAnimationFrame for a second render after layout
                requestAnimationFrame(() => {
                    console.log('[AUTOLOAD] First animation frame for reload - waiting for layout');
                    requestAnimationFrame(() => {
                        console.log('[AUTOLOAD] Second animation frame for reload - rendering with layout');
                        // Final render with correct measurements
                        renderTesterAccountList(true);
                        updateTesterButtons(); // Call UI function
                        updateTesterSummary(); // Call UI function
                        setTesterMessage(`Reloaded ${testerState.accounts.length} accounts from ${data.filePath.split(/[\\/]/).pop()}.`); // Call UI function
                        console.log('[AUTOLOAD] UI updates complete for reload');
                    });
                });
                
                debugLog(`[IPC] Deferred initial render complete for reloaded file ${data.filePath}`);
            }, 0); // 0ms timeout defers execution until after current stack clears

            debugLog(`Reloaded ${testerState.accounts.length} accounts from ${data.filePath}`);
        } else {
            console.error(`[IPC] Error reloading file ${data.filePath}: ${data.error}`);
            setTesterMessage(`Error reloading list: ${data.error}`); // Call UI function
        }
    });

    // Listener for auto-load result (This seems redundant with tester-specific-file-loaded, maybe consolidate?)
    window.ipc.on('tester-auto-load-result', async (event, data) => {
        console.log('[AUTOLOAD] Received tester-auto-load-result:', data ? `success=${data.success}, accounts=${data.accounts?.length}` : 'null');
        debugLog('[IPC] Received tester-auto-load-result:', data);
        if (data && data.success) {
            console.log(`[AUTOLOAD] Successfully loaded ${data.accounts?.length || 0} accounts from ${data.filePath}`);
            testerState.accounts = data.accounts || []; // Update state
            testerState.currentIndex = testerState.accounts.length > 0 ? 0 : -1; // Update state
            testerState.lastFilePath = data.filePath; // Update state
            
            // Load and apply saved state before UI updates
            console.log('[AUTOLOAD] Loading and applying saved state');
            await loadAndApplySavedState(data.filePath);
            
            // Defer the UI updates slightly to allow layout calculation
            console.log('[AUTOLOAD] Deferring UI updates');
            setTimeout(() => {
                console.log('[AUTOLOAD] Executing deferred UI updates');
                // First render to get elements in DOM
                renderTesterAccountList(true); // Call UI function
                
                // Then use requestAnimationFrame for a second render after layout
                requestAnimationFrame(() => {
                    console.log('[AUTOLOAD] First animation frame - waiting for layout');
                    requestAnimationFrame(() => {
                        console.log('[AUTOLOAD] Second animation frame - rendering with layout');
                        // Final render with correct measurements
                        renderTesterAccountList(true);
                        updateTesterButtons(); // Call UI function
                        updateTesterSummary(); // Call UI function
                        setTesterMessage(`Auto-loaded ${testerState.accounts.length} accounts from ${data.filePath.split(/[\\/]/).pop()}.`); // Call UI function
                        console.log('[AUTOLOAD] UI updates complete');
                    });
                });
                
                debugLog(`[IPC] Deferred initial render complete for auto-loaded file ${data.filePath}`);
            }, 0); // 0ms timeout defers execution until after current stack clears

            debugLog(`Auto-loaded ${testerState.accounts.length} accounts from ${data.filePath}`);
        } else {
            console.error(`[IPC] Error auto-loading file ${data.filePath}: ${data.error}`);
            setTesterMessage(`Error auto-loading last file: ${data.error}`); // Call UI function
        }
    });

    debugLog("Tester IPC Listeners Initialized.");
    
    // Add listener for the main process ready signal
    window.ipc.on("tester-main-ready", (event, isReady) => {
        if (isReady) {
            console.log('[AUTOLOAD] Received tester-main-ready signal.');
            isMainProcessReady = true;
            // If initializeTesterState was already called, initiate the auto-load path now
            if (initializeTesterStateCalled) {
                initiateAutoLoadPath();
            }
        }
    });
}

// Flag to track if the main process is ready
let isMainProcessReady = false;
// Flag to track if initializeTesterState has been called
let initializeTesterStateCalled = false;

// Function to request initial states
function initializeTesterState() {
    console.log('[AUTOLOAD] *** INITIALIZATION START ***');
    debugLog('[IPC] Requesting initial states from main process.');
    
    // Add a small delay before sending state requests to ensure UI is ready
    setTimeout(() => {
        debugLog('[IPC] Sending state requests after initialization delay');
        
        // Send all state requests
        window.ipc.send("tester-get-save-path");
        window.ipc.send("tester-get-delays");
        window.ipc.send("tester-get-debug-mode");
        window.ipc.send("tester-get-actual-login-mode");
        window.ipc.send("tester-get-disable-devtools-mode");
        
        // Initiate auto-load directly
        console.log('[AUTOLOAD] Initiating auto-load path directly.');
        window.ipc.send("tester-get-last-path");
        
        console.log('[AUTOLOAD] *** INITIALIZATION COMPLETE ***');
    }, 500); // Delay to ensure UI is fully initialized
}

// Export the initialization functions
export { setupTesterIPCListeners, initializeTesterState };

// Register the real implementations with the bridge
if (window.registerSetupTesterIPCListeners) {
    window.registerSetupTesterIPCListeners(setupTesterIPCListeners);
    // Also expose the initialization function globally for the final init script
    window.initializeTesterState = initializeTesterState;
} else {
    console.error('[TesterIPC] Bridge function registerSetupTesterIPCListeners not found!');
}
