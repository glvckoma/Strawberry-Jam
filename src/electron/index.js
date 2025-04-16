const { app, BrowserWindow, globalShortcut, shell, ipcMain, protocol, net, dialog, session } = require('electron') // Added session
const path = require('path')
const fs = require('fs').promises; // Added for state management
const crypto = require('crypto'); // Added for unique IDs
const { fork, spawn } = require('child_process') // Added spawn
const { autoUpdater } = require('electron-updater')
const Store = require('electron-store'); // Added for leak checker
const { startLeakCheck } = require('./leakChecker'); // Added for leak checker
const Patcher = require('./renderer/application/patcher'); // Import the Patcher class
const { getDataPath } = require('../Constants'); // Import getDataPath

const isDevelopment = process.env.NODE_ENV === 'development'

// Helper: Only log in development
function devLog(...args) {
  if (isDevelopment) console.log(...args);
}
function devWarn(...args) {
  if (isDevelopment) console.warn(...args);
}
const USER_DATA_PATH = app.getPath('userData');
const STATE_FILE_PATH = path.join(USER_DATA_PATH, 'jam_state.json');
const defaultDataDir = path.resolve('data'); // Default project data dir (Added from leakChecker.js)
const LOGGED_USERNAMES_FILE = 'logged_usernames.txt'; // Input file (Added from leakChecker.js)

// Default structure for the state file
const DEFAULT_APP_STATE = {
  leakCheck: {
    inputFilePath: null,
    lastProcessedIndex: -1,
    status: "idle" // idle, running, paused, completed, error
  },
  accountTester: {
    currentFile: null,
    scrollIndex: 0,
    filterQuery: "",
    fileStates: {} // e.g., { "data/accounts.txt": { "user:pass": "status", ... } }
  }
};

/**
 * Default window options.
 * @type {Object}
 * @constant
 */
const defaultWindowOptions = {
  title: 'Jam',
  backgroundColor: '#16171f',
  resizable: true,
  useContentSize: true,
  width: 840,
  height: 645,
  frame: false,
  webPreferences: {
    webSecurity: false,
    nativeWindowOpen: true,
    contextIsolation: false,
    enableRemoteModule: true,
    nodeIntegration: true,
    preload: path.resolve(__dirname, 'preload.js')
  },
  icon: path.join('assets', 'icon.png')
}

// Register the 'app://' protocol scheme early, before the app is ready.
// This allows the protocol to be used immediately when the window loads.
protocol.registerSchemesAsPrivileged([
  { scheme: 'app', privileges: { standard: true, secure: true, supportFetchAPI: true } }
]);

// --- Standalone Cache Clear Logic (for startup) ---
// This function is no longer needed as the logic was removed from startup
// async function clearAppCacheOnStartup() { ... }
// --- End Standalone Cache Clear Logic ---


class Electron {
  /**
   * Constructor.
   * @constructor
   */
  constructor () {
    this._window = null
    this._apiProcess = null
    this._store = new Store(); // Instantiate Store
    this._patcher = new Patcher(null); // Instantiate Patcher (pass null for application)
    this._isLeakCheckRunning = false; // Added for leak check state
    this._isLeakCheckPaused = false; // Flag for pause state
    this._isLeakCheckStopped = false; // Flag for stop state
    this._isQuitting = false; // Flag to prevent multiple quit handler runs
    this._isClearingCacheAndQuitting = false; // Flag for cache clear on quit
    this._setupIPC()
  }

  /**
   * Sets up IPC event handlers.
   * @private
   */
  _setupIPC () {
    ipcMain.on('open-directory', (event, filePath) => shell.openExternal(`file://${filePath}`))
    ipcMain.on('window-close', () => this._window.close())
    ipcMain.on('window-minimize', () => this._window.minimize())
    ipcMain.on('open-settings', (_, url) => shell.openExternal(url))
    // Removed application-relaunch handler

    ipcMain.on('open-url', (_, url) => shell.openExternal(url))

    // --- App Version IPC Handler ---
    ipcMain.handle('get-app-version', () => {
      devLog('[IPC] Handling get-app-version');
      return app.getVersion();
    });

    // --- Settings IPC Handlers ---
    ipcMain.handle('get-setting', (event, key) => {
      devLog(`[IPC] Handling 'get-setting' for key: ${key}`);
      try {
        const value = this._store.get(key);
        devLog(`[Store] Value retrieved for '${key}':`, value); // Log retrieved value
        return value;
      } catch (error) {
        if (isDevelopment) console.error(`[Store] Error getting setting '${key}':`, error);
        return undefined; // Or throw an error? Returning undefined might be safer.
      }
    });

    ipcMain.handle('set-setting', (event, key, value) => {
      devLog(`[IPC] Handling 'set-setting' for key: ${key} with value:`, value); // Log value being set
      try {
        // Removed special handling for autoClearCacheOnUpdate
        this._store.set(key, value);
        devLog(`[Store] Successfully set '${key}'.`); // Log success
        return { success: true };
      } catch (error) {
        if (isDevelopment) console.error(`[Store] Error setting setting '${key}':`, error);
        return { success: false, error: error.message };
      }
    });

    ipcMain.handle('select-output-directory', async (event) => {
      devLog(`[IPC] Handling 'select-output-directory'`);
      if (!this._window) {
        if (isDevelopment) console.error('[Dialog] Cannot show dialog, main window not available.');
        return { canceled: true, error: 'Main window not available' };
      }
      try {
        const result = await dialog.showOpenDialog(this._window, {
          properties: ['openDirectory', 'createDirectory'],
          title: 'Select Leak Check Output Directory'
        });

        if (result.canceled || !result.filePaths || result.filePaths.length === 0) {
          devLog('[Dialog] Directory selection canceled.');
          return { canceled: true };
        } else {
          const selectedPath = result.filePaths[0];
          devLog(`[Dialog] Directory selected: ${selectedPath}`);
          return { canceled: false, path: selectedPath };
        }
      } catch (error) {
        if (isDevelopment) console.error('[Dialog] Error showing open dialog:', error);
        return { canceled: true, error: error.message };
      }
    });
    // --- End Settings IPC Handlers ---


    // --- IPC Handler for saving working accounts ---
    ipcMain.on('tester-save-works', async (event, accountLine) => {
      const worksFilePath = path.join(getDataPath(app), 'working_accounts.txt'); // Pass app object
      devLog(`[IPC tester-save-works] Appending to: ${worksFilePath}`);
      try {
        // Ensure directory exists (though _onReady should handle this for packaged)
        await fs.mkdir(path.dirname(worksFilePath), { recursive: true });
        // Append the line
        await fs.appendFile(worksFilePath, accountLine + '\n', 'utf-8');
        devLog(`[IPC tester-save-works] Successfully appended: ${accountLine}`);
      } catch (error) {
        console.error(`[IPC tester-save-works] Error appending to ${worksFilePath}:`, error);
        // Optionally send an error back to the renderer?
      }
    });
    // --- End IPC Handler for saving working accounts ---


    // --- Leak Checker IPC ---
    // Note: isLeakCheckRunning is now a class property this._isLeakCheckRunning

    // Use handle for async operations like reading/writing state
    ipcMain.handle('leak-check-start', async (event, options = {}) => { // Handles Start and Resume
      devLog('[IPC] Handling leak-check-start/resume request.');
      // Call the refactored method
      return this._initiateOrResumeLeakCheck(options);
    });

    // IPC handler for Pause signal
    ipcMain.handle('leak-check-pause', async () => {
        // Use class property
        if (!this._isLeakCheckRunning) {
            return { success: false, message: 'Leak check is not running.' };
        }
        if (this._isLeakCheckPaused) {
             return { success: true, message: 'Leak check is already paused.' };
        }
        devLog('[IPC] Received leak-check-pause signal.');
        this._isLeakCheckPaused = true;
        // The running startLeakCheck loop will detect this via checkPauseStatus()
        // It should then call updateStateCallback({ status: 'paused', ... }) in the control method
        return { success: true, message: 'Pause signal sent.' };
    });

    // IPC handler for Stop signal
    ipcMain.handle('leak-check-stop', (async () => {
        // Use class property
        if (!this._isLeakCheckRunning && !this._isLeakCheckPaused) { // Can stop if paused too
             return { success: false, message: 'Leak check is not running or paused.' };
        }
        devLog('[IPC] Received leak-check-stop signal.');
        this._isLeakCheckStopped = true; // Set stop flag
        this._isLeakCheckPaused = false; // Ensure pause is cleared if stopping from paused state
        // The running startLeakCheck loop will detect this via checkStopStatus()
        // It should then perform cleanup and call updateStateCallback({ status: 'stopped', ... })
        // DO NOT clear _isLeakCheckRunning or update state here. Let the callback handle it.
        devLog('[IPC Stop] Stop flag set. Waiting for checker process to acknowledge.');
        return { success: true, message: 'Stop signal sent. Process will stop shortly.' };
    }).bind(this));

    // IPC handler to verify the actual runtime status
    ipcMain.handle('verify-leak-check-status', async () => {
        devLog('[IPC] Handling verify-leak-check-status request.');
        // Return the current runtime flag state
        return { isRunning: this._isLeakCheckRunning };
    });

    // --- End Leak Checker IPC ---


    // --- App State IPC Handlers --- (Helper methods added below)
    // Note: Direct IPC handlers are kept for potential direct use,
    // but internal calls now use helper methods for consistency.
    ipcMain.handle('get-app-state', (async () => {
        devLog(`[IPC] Handling direct 'get-app-state' request.`);
        return this.getAppState(); // Use helper
    }).bind(this)); // Bind to the Electron class instance

    ipcMain.handle('set-app-state', (async (event, newState) => {
        devLog(`[IPC] Handling direct 'set-app-state' request.`);
        return this.setAppState(newState); // Use helper
    }).bind(this)); // Bind to the Electron class instance
    // --- End App State IPC Handlers ---


    // --- Plugin State IPC Bridge ---
    ipcMain.handle('dispatch-get-state', async (event, key) => { // Make handler async
      devLog(`[IPC Main] Received ASYNC 'dispatch-get-state' request from plugin for key: ${key}`);
      if (!this._window || !this._window.webContents || this._window.webContents.isDestroyed()) {
        if (isDevelopment) console.error(`[IPC Main] Cannot get state for key '${key}': Main window not available.`);
        return null; // Return null if main window isn't ready
      }

      const replyChannel = `get-state-reply-${crypto.randomUUID()}`;
      devLog(`[IPC Main] Generated reply channel: ${replyChannel}`);

      return new Promise((resolve, reject) => {
        const timeout = setTimeout(() => {
          ipcMain.removeListener(replyChannel, listener); // Clean up listener on timeout
          if (isDevelopment) console.error(`[IPC Main] Timeout waiting for reply on ${replyChannel} for key ${key}`);
          reject(new Error(`Timeout waiting for state response for key: ${key}`));
        }, 2000); // 2 second timeout

        const listener = (event, value) => {
          clearTimeout(timeout);
          devLog(`[IPC Main] Received reply on ${replyChannel} for key ${key}:`, value);
          resolve(value);
        };

        ipcMain.once(replyChannel, listener);

        // Send async request to main renderer
        devLog(`[IPC Main] Sending async request 'main-renderer-get-state-async' to main window for key: ${key}`);
        this._window.webContents.send('main-renderer-get-state-async', { key, replyChannel });
      });
    });
    // --- End Plugin State IPC Bridge ---


    // --- Account Tester IPC Handlers ---
    // Use a closure to capture 'this'
    const self = this;
    ipcMain.handle('tester-cleanup-processed', async (event, filePath) => {
      devLog(`[IPC] Handling 'tester-cleanup-processed' for file: ${filePath}`);
      if (!filePath) {
        return { success: false, error: 'File path is required.' };
      }

      try {
        // 1. Get current state
        const appState = await self.getAppState();
        const fileState = appState?.accountTester?.fileStates?.[filePath];

        if (!fileState) {
          devLog(`[Cleanup] No state found for file ${filePath}. Nothing to clean.`);
          return { success: true, removedCount: 0, message: 'No state found for this file.' };
        }

        // 2. Read the account file content
        let fileContent;
        try {
          fileContent = await fs.readFile(filePath, 'utf-8');
        } catch (readError) {
          if (readError.code === 'ENOENT') {
            if (isDevelopment) console.error(`[Cleanup] Account file not found: ${filePath}`);
            return { success: false, error: `Account file not found: ${filePath}` };
          }
          throw readError; // Re-throw other read errors
        }

        const lines = fileContent.split(/\r?\n/);
        let originalCount = 0;
        const linesToKeep = [];

        // 3. Filter lines based on state
        for (const line of lines) {
          const trimmedLine = line.trim();
          if (!trimmedLine) continue; // Skip empty lines

          originalCount++;
          const accountKey = trimmedLine; // Assuming line is "user:pass" which is the key in state
          const status = fileState[accountKey];

          // Keep lines that are pending, testing, or not found in state
          if (!status || status === 'pending' || status === 'testing') {
            linesToKeep.push(line); // Keep the original line ending
          } else {
             devLog(`[Cleanup] Removing tested account: ${accountKey} (Status: ${status})`);
          }
        }

        const removedCount = originalCount - linesToKeep.length;
        devLog(`[Cleanup] Original lines: ${originalCount}, Lines to keep: ${linesToKeep.length}, Removed: ${removedCount}`);

        // 4. Write the filtered content back to the file
        await fs.writeFile(filePath, linesToKeep.join('\n'), 'utf-8'); // Use '\n' for consistency
        devLog(`[Cleanup] Successfully wrote cleaned file: ${filePath}`);

        // 5. Optionally: Clean up the state for this file?
        // Decided against modifying state here. Reloading the list will effectively refresh the state view.
        // If we wanted to clean state:
        // delete appState.accountTester.fileStates[filePath];
        // await this.setAppState(appState);

        return { success: true, removedCount: removedCount };

      } catch (error) {
        if (isDevelopment) console.error(`[Cleanup] Error processing file ${filePath}:`, error);
        return { success: false, error: error.message || 'An unknown error occurred during cleanup.' };
      }
    });

    // --- REMOVED 'tester-select-save-path' handler ---

    // --- New Handlers for Specific File Loads (using handle/invoke) ---
    // Modified to use getDataPath()
    const createLoadFileHandler = (channelName, baseFilename) => {
      ipcMain.handle(channelName, async (event) => {
        const dataDir = getDataPath(app); // Pass app object
        const fullPath = path.join(dataDir, baseFilename); // Construct full path
        devLog(`[IPC ${channelName}] Handling request. Resolved path: ${fullPath}`);

        // --- ADDED LOGGING for working_accounts.txt ---
        if (baseFilename === 'working_accounts.txt') {
          console.log(`[Account Tester] Loading 'working_accounts.txt' from: ${fullPath}`);
        }
        // --- END ADDED LOGGING ---

        try {
          devLog(`[IPC ${channelName}] Attempting to read file: ${fullPath}`);
          const fileContent = await fs.readFile(fullPath, 'utf-8');
          devLog(`[IPC ${channelName}] Successfully read file: ${fullPath}`);
          const lines = fileContent.split(/\r?\n/);
          const accounts = lines
            .map(line => line.trim())
            .filter(line => line && line.includes(':'))
            .map(line => {
              const [username, ...passwordParts] = line.split(':');
              const password = passwordParts.join(':');
              return { username, password, status: 'pending' };
            });

          devLog(`[IPC ${channelName}] Successfully parsed ${accounts.length} accounts from ${fullPath}`);
          this._store.set('testerLastPath', fullPath);
          devLog(`[Store] Updated testerLastPath to: ${fullPath}`);

          devLog(`[IPC ${channelName}] Returning success response.`);
          return { // Return the result directly
            success: true,
            accounts: accounts,
            filePath: fullPath
          };
        } catch (error) {
          if (isDevelopment) console.error(`[IPC ${channelName}] Error processing file ${fullPath}:`, error);
          let errorMessage = `Error loading file: ${error.message}`;
          if (error.code === 'ENOENT') {
            errorMessage = `File not found: ${path.basename(fullPath)}`;
          }
          devLog(`[IPC ${channelName}] Returning error response.`);
          return { // Return the error result directly
            success: false,
            error: errorMessage,
            filePath: fullPath
          };
          // No need for inner try/catch for sending response
        }
      });
    };

    // Use base filenames now
    createLoadFileHandler('tester-load-all-accounts', 'accounts.txt');
    createLoadFileHandler('tester-load-confirmed-accounts', 'ajc_confirmed_accounts.txt');
    createLoadFileHandler('tester-load-works-accounts', 'working_accounts.txt');
    // --- End New Handlers ---

    // --- End Account Tester IPC Handlers ---

    // --- Renderer Ready Listener (for Auto-Resume) ---
    ipcMain.once('renderer-ready', (async () => {
    devLog('[IPC] Received renderer-ready signal.');
    try {
      devLog('[Startup] Checking for Leak Check auto-resume...');
      const appState = await this.getAppState();
      if (appState.leakCheck && (appState.leakCheck.status === 'running' || appState.leakCheck.status === 'paused')) {
        devLog(`[Startup] Found Leak Check state: ${appState.leakCheck.status}. Auto-resume disabled.`);
        // No need for setTimeout now, as renderer is confirmed ready
        // --- AUTO-RESUME DISABLED ---
        // this._initiateOrResumeLeakCheck()
        //   .then(result => {
        //     if (result.success) {
        //       devLog('[Startup] Leak Check auto-resume initiated successfully.');
        //     } else {
        //       if (isDevelopment) console.error(`[Startup] Leak Check auto-resume failed: ${result.message}`);
        //     }
        //   })
        //   .catch(err => {
        //     if (isDevelopment) console.error(`[Startup] Error during Leak Check auto-resume initiation: ${err.message}`);
        //   });
        // --- END AUTO-RESUME DISABLED ---
      } else {
        devLog('[Startup] No Leak Check auto-resume needed (State: ' + (appState.leakCheck?.status || 'idle') + ').');
      }
    } catch (error) {
      if (isDevelopment) console.error(`[Startup] Error during Leak Check auto-resume check: ${error.message}`);
    }
    }).bind(this));
    // --- End Renderer Ready Listener ---

    // --- Danger Zone IPC Handlers ---
    ipcMain.handle('danger-zone:clear-cache', async () => {
      devLog('[IPC] Handling danger-zone:clear-cache');
      // 1. Confirm other instances are closed (using dialog)
      const continueClear = await this._confirmNoOtherInstances('clear the cache');
      if (!continueClear) {
        return { success: false, message: 'Cache clearing cancelled by user.' };
      }

      // 2. Clear Electron session data, get BOTH cache paths, spawn helper for BOTH
      try {
        devLog('[Clear Cache] Clearing Electron session cache...');
        await session.defaultSession.clearCache();
        devLog('[Clear Cache] Clearing Electron session storage data (cookies, localstorage)...');
        await session.defaultSession.clearStorageData({ storages: ['cookies', 'localstorage'] }); // Specify storages
        devLog('[Clear Cache] Electron session data cleared.');

        // Get both cache paths
        const cachePaths = this._getCachePaths(); // Use the refactored method
        if (!cachePaths || cachePaths.length === 0) {
           devLog('[Clear Cache] Could not determine cache paths. Skipping helper script.');
           // Still quit after clearing session data
        } else {
          const helperScriptPath = path.join(__dirname, 'clear-cache-helper.js');
          devLog(`[Clear Cache] Spawning helper script: ${helperScriptPath} with paths:`, cachePaths);

           // Resolve helper path correctly for packaged vs dev
           let resolvedHelperPath;
           if (app.isPackaged) {
             resolvedHelperPath = path.join(process.resourcesPath, 'clear-cache-helper.js');
           } else {
             resolvedHelperPath = helperScriptPath; // Use path relative to __dirname in dev
           }
           devLog(`[Clear Cache] Resolved helper path: ${resolvedHelperPath}`);

           try {
               await fs.access(resolvedHelperPath); // Verify helper exists

               // Spawn the helper script detached with both paths
               const child = spawn('node', [resolvedHelperPath, ...cachePaths], { // Spawn node explicitly
                 detached: true,
                 stdio: 'ignore' // Ignore stdio to allow parent to exit
               });
               child.on('error', (err) => { console.error('[Clear Cache] Failed to spawn helper script:', err); });
               child.unref(); // Allow the parent process to exit independently
               devLog('[Clear Cache] Helper script spawned.');
           } catch (accessError) {
                console.error(`[Clear Cache] Helper script not found at: ${resolvedHelperPath}`, accessError);
                // Proceed to quit even if helper fails to spawn
           }
        }

        devLog('[Clear Cache] Quitting application.');
        app.quit(); // Quit the main application immediately
        return { success: true, message: 'Internal cache cleared. External cache clearing scheduled. Application will close.' };

      } catch (error) {
        console.error('[Clear Cache] Error clearing cache, spawning helper, or quitting:', error);
        dialog.showMessageBoxSync(this._window, {
          type: 'error',
          title: 'Clear Cache Error',
          message: `Failed to initiate cache clearing: ${error.message}`,
          buttons: ['OK']
        });
        return { success: false, error: error.message };
      }

      // Set the flag and quit. The actual work happens in 'will-quit'.
      this._isClearingCacheAndQuitting = true;
      devLog('[Clear Cache] Flag set. Quitting application to trigger will-quit handler.');
      app.quit();
      // Return success, although the real work hasn't happened yet.
      // The window will close before the handler finishes.
      return { success: true, message: 'Cache clearing initiated. Application will close.' };

    });

    ipcMain.handle('danger-zone:uninstall', async () => {
      devLog('[IPC] Handling danger-zone:uninstall');
      // 1. Confirm other instances are closed (using dialog)
      const continueUninstall = await this._confirmNoOtherInstances('uninstall Strawberry Jam');
      if (!continueUninstall) {
        return { success: false, message: 'Uninstall cancelled by user.' };
      }

      // 2. Locate and execute uninstaller
      try {
        const uninstallerPath = this._getUninstallerPath();
        if (!uninstallerPath) {
          throw new Error('Uninstaller path could not be determined for this OS.');
        }

        await fs.access(uninstallerPath); // Check if it exists
        devLog(`[Uninstall] Found uninstaller at: ${uninstallerPath}`);

        // Spawn detached process
        spawn(uninstallerPath, [], {
          detached: true,
          stdio: 'ignore' // Prevent parent from waiting
        }).unref(); // Allow parent to exit independently

        devLog('[Uninstall] Uninstaller process spawned. Quitting application.');

        // 3. Quit Strawberry Jam immediately
        app.quit();
        return { success: true }; // Note: We don't know if uninstall *actually* succeeded

      } catch (error) {
        console.error('[Uninstall] Error:', error);
        const errorMsg = error.code === 'ENOENT' ? 'Uninstaller executable not found.' : error.message;
        dialog.showMessageBoxSync(this._window, { // Use sync dialog before quitting
          type: 'error',
          title: 'Uninstall Error',
          message: `Failed to start uninstaller: ${errorMsg}`,
          buttons: ['OK']
        });
        // Don't quit on error
        return { success: false, error: errorMsg };
      }
    });
    // --- End Danger Zone IPC Handlers ---

  }

 // --- Helper methods for State Management ---
  async getAppState() {
    console.log(`[State Helper] Reading app state from ${STATE_FILE_PATH}`);
    try {
      await fs.access(STATE_FILE_PATH);
      const data = await fs.readFile(STATE_FILE_PATH, 'utf-8');
      const currentState = JSON.parse(data);
      // Deep merge with default state to ensure all nested keys exist
      const mergedState = {
        ...DEFAULT_APP_STATE,
        ...currentState,
        leakCheck: { ...DEFAULT_APP_STATE.leakCheck, ...(currentState.leakCheck || {}) },
        accountTester: { ...DEFAULT_APP_STATE.accountTester, ...(currentState.accountTester || {}), fileStates: { ...DEFAULT_APP_STATE.accountTester.fileStates, ...(currentState.accountTester?.fileStates || {}) } }
      };
      console.log('[State Helper] Successfully read and merged state file.');
      return mergedState;
    } catch (error) {
      if (error.code === 'ENOENT') {
        console.log('[State Helper] State file not found, returning default state.');
        // Optionally write the default state here if needed on first read
        // await this.setAppState(DEFAULT_APP_STATE); // Be careful about recursion if setAppState calls getAppState
        return JSON.parse(JSON.stringify(DEFAULT_APP_STATE)); // Return a deep copy
      }
      console.error('[State Helper] Error reading state file:', error);
      // In case of other errors, return default state to prevent crashes
      return JSON.parse(JSON.stringify(DEFAULT_APP_STATE)); // Return a deep copy
    }
  }

  async setAppState(newState) {
     console.log(`[State Helper] Writing app state to ${STATE_FILE_PATH}`);
     try {
       await fs.mkdir(USER_DATA_PATH, { recursive: true });
       await fs.writeFile(STATE_FILE_PATH, JSON.stringify(newState, null, 2), 'utf-8');
       console.log('[State Helper] Successfully wrote state file.');
       return { success: true };
     } catch (error) {
       console.error('[State Helper] Error writing state file:', error);
       return { success: false, error: error.message };
     }
   }

  // --- Helper method to confirm no other instances ---
  async _confirmNoOtherInstances(actionDescription) {
    const gotTheLock = app.requestSingleInstanceLock();
    if (gotTheLock) {
      // We are the only instance, release the lock immediately
      app.releaseSingleInstanceLock();
      return true; // Proceed
    } else {
      // Another instance is running
      const choice = await dialog.showMessageBox(this._window, {
        type: 'warning',
        title: 'Multiple Instances Detected',
        message: `It looks like another Strawberry Jam window is open.\n\nPlease close all other Strawberry Jam windows before attempting to ${actionDescription}.`,
        buttons: ['Cancel', 'I have closed other windows'],
        defaultId: 0, // Default to Cancel
        cancelId: 0
      });
      return choice.response === 1; // Return true only if user clicks "I have closed..."
    }
  }

  // --- Helper method to GET Cache Paths (Returns both paths again) ---
  _getCachePaths() {
    devLog('[Cache Paths] Getting cache paths...');
    const roamingPath = app.getPath('appData');
    const cachePaths = [];

    if (process.platform === 'win32') {
      cachePaths.push(path.join(roamingPath, 'AJ Classic'));
      cachePaths.push(path.join(roamingPath, 'strawberry-jam'));
    } else if (process.platform === 'darwin') { // macOS
      const libraryPath = app.getPath('home') + '/Library/Application Support'; // Use explicit path for consistency
      cachePaths.push(path.join(libraryPath, 'AJ Classic'));
      cachePaths.push(path.join(libraryPath, 'strawberry-jam')); // Assuming same name on macOS
    } else {
      console.warn('[Cache Paths] Unsupported platform for cache clearing:', process.platform);
      // Return empty array or handle differently if needed
    }

    devLog('[Cache Paths] Identified cache paths:', cachePaths);
    return cachePaths;
  }

  // --- Helper method for Cache Clearing (Now only used for auto-update potentially - needs review) ---
  async _clearAppCache() {
    // This method might still be used by the auto-update logic in will-quit.
    // It currently clears BOTH paths using fs.rm.
    // If used for auto-update, it should probably also use the session API + helper script pattern.
    // For now, leaving it as is, but marking for review.
    // TODO: Review if this method is still needed and update its logic if necessary.
    devLog('[Cache Clear Method - REVIEW NEEDED] Starting cache clearing process...');
    const roamingPath = app.getPath('appData');
    const cachePaths = [];
     if (process.platform === 'win32') {
      cachePaths.push(path.join(roamingPath, 'AJ Classic'));
      cachePaths.push(path.join(roamingPath, 'strawberry-jam'));
    } else if (process.platform === 'darwin') { // macOS
      const libraryPath = app.getPath('home') + '/Library/Application Support';
      cachePaths.push(path.join(libraryPath, 'AJ Classic'));
      cachePaths.push(path.join(libraryPath, 'strawberry-jam')); // Assuming same name on macOS
    } else {
       console.warn('[Cache Clear Method] Unsupported platform:', process.platform);
       return;
    }

    let errors = [];
    for (const cachePath of cachePaths) {
      try {
        devLog(`[Cache Clear Method] Attempting to delete: ${cachePath}`);
        await fs.rm(cachePath, { recursive: true, force: true });
        devLog(`[Cache Clear Method] Successfully deleted: ${cachePath}`);
      } catch (error) {
        if (error.code === 'ENOENT') {
          devLog(`[Cache Clear Method] Path not found, skipping: ${cachePath}`);
        } else {
          console.error(`[Cache Clear Method] Failed to delete ${cachePath}:`, error);
          errors.push(`Failed to delete ${path.basename(cachePath)}: ${error.message}`);
        }
      }
    }

    if (errors.length > 0) {
      // Decide how to handle errors here - maybe log to a file?
      console.error('[Cache Clear Method] Finished with errors:', errors.join('; '));
      // Avoid throwing an error if called from will-quit to not block shutdown
    } else {
       devLog('[Cache Clear Method] Cache clearing process completed.');
    }
  }

  // --- Helper method to get Uninstaller Path ---
  _getUninstallerPath() { // This can remain an instance method
    if (process.platform === 'win32') {
      // Standard location for NSIS installers installed for the current user
      const localAppData = app.getPath('home') + '\\AppData\\Local';
      return path.join(localAppData, 'Programs', 'strawberry-jam', 'Uninstall strawberry-jam.exe');
    } else if (process.platform === 'darwin') {
      // macOS apps are typically self-contained bundles. Uninstallation is usually drag-to-trash.
      // There isn't a standard separate uninstaller executable.
      // We might need to guide the user or skip this step on macOS.
      console.warn('[Uninstall] Standard uninstaller executable not applicable on macOS.');
      // For now, return null to indicate it's not found/applicable
      return null;
      // Alternative: Could try to delete the .app bundle from /Applications? Risky.
      // return '/Applications/Strawberry Jam.app'; // Example, needs verification
    } else {
      console.warn('[Uninstall] Unsupported platform for uninstaller:', process.platform);
      return null;
    }
  }

 // --- Leak Check Control Method ---
  /**
   * Initiates or resumes the leak check process based on current state.
   * Can be called by IPC handlers or on application startup.
   * @param {object} options - Options, typically from IPC { limit }.
   * @returns {Promise<object>} - Promise resolving to { success: boolean, message: string }.
   * @private
   */
  async _initiateOrResumeLeakCheck(options = {}) {
    console.log('[LeakCheck Control] Initiating or resuming leak check...');

    // Use class property for running state
    if (this._isLeakCheckRunning) {
      // If trying to resume a paused check, allow it
      if (this._isLeakCheckPaused) {
         console.log('[LeakCheck Control] Resuming paused check...');
         this._isLeakCheckPaused = false; // Clear pause flag before starting
         // Proceed to start logic, which will pick up from saved state.
      } else {
        console.warn('[LeakCheck Control] Attempted to start while already running.');
        return { success: false, message: 'Leak check is already in progress.' };
      }
    }

    // Reset flags for a new run (or resume)
    this._isLeakCheckPaused = false;
    this._isLeakCheckStopped = false;
    this._isLeakCheckRunning = true; // Set running flag

    if (!this._window || !this._window.webContents || this._window.webContents.isDestroyed()) {
      console.error('[LeakCheck Control] Cannot start check, main window/webContents not available.');
      this._isLeakCheckRunning = false; // Reset running flag
      return { success: false, message: 'Main window not available.' };
    }

    try {
      // 1. Get current application state
      const currentAppState = await this.getAppState();
      let leakCheckState = currentAppState.leakCheck || DEFAULT_APP_STATE.leakCheck;

      // If status is completed/error/stopped, reset index for a fresh start
      if (['completed', 'error', 'stopped'].includes(leakCheckState.status)) {
          console.log(`[LeakCheck Control] Status is ${leakCheckState.status}, resetting index for a new run.`);
          leakCheckState.lastProcessedIndex = -1;
      }

      // 2. Determine start index
      const startIndex = leakCheckState.lastProcessedIndex + 1;
      // Use input path from state if available, otherwise default
      const inputFilePath = leakCheckState.inputFilePath || path.join(defaultDataDir, LOGGED_USERNAMES_FILE);

      // Update state immediately to 'running'
      leakCheckState.status = 'running';
      // Ensure inputFilePath is stored if it wasn't already
      leakCheckState.inputFilePath = inputFilePath;
      currentAppState.leakCheck = leakCheckState;
      await this.setAppState(currentAppState);


      // 3. Define logger
      const leakCheckLogger = (level, message) => {
        const prefix = `[LeakCheck/${level.toUpperCase()}]`;
        if (level === 'error' || level === 'warn') console.error(prefix, message);
        else console.log(prefix, message);
      };

      // 4. Define updateStateCallback
      const updateStateCallback = async (newStateUpdate) => {
        try {
          const currentState = await this.getAppState();
          // Only update if the process is still considered running by the main process flag
          // Use this._isLeakCheckRunning which is managed by this class
          if (this._isLeakCheckRunning) {
              currentState.leakCheck = { ...currentState.leakCheck, ...newStateUpdate };
              await this.setAppState(currentState);
              console.log(`[State Callback] Updated state: Status=${newStateUpdate.status}, Index=${newStateUpdate.lastProcessedIndex}`);

              // Send progress update to renderer
              if (this._window && this._window.webContents && !this._window.webContents.isDestroyed()) {
                  this._window.webContents.send('leak-check-progress', newStateUpdate);
                  console.log(`[State Callback] Sent leak-check-progress event to renderer: Status=${newStateUpdate.status}`);
              }

              // If the callback reports completion/error/stop, clear the running flag
              if (['completed', 'error', 'stopped'].includes(newStateUpdate.status)) {
                  this._isLeakCheckRunning = false;
                  this._isLeakCheckPaused = false; // Ensure pause is cleared on final state
                  this._isLeakCheckStopped = false; // Ensure stop is cleared on final state
              }
          } else {
               console.log(`[State Callback] Ignored state update (${newStateUpdate.status}) because process is not marked as running.`);
          }
        } catch (error) {
          console.error('[State Callback] Error updating state:', error);
        }
      };

      // 5. Define functions to check pause/stop status
      const checkPauseStatus = () => this._isLeakCheckPaused;
      const checkStopStatus = () => this._isLeakCheckStopped;


      // 6. Start the leak check process (async)
      console.log(`[LeakCheck Control] Calling startLeakCheck with startIndex: ${startIndex}`);
      startLeakCheck({
        webContents: this._window.webContents,
        log: leakCheckLogger,
        store: this._store,
        limit: options.limit, // Pass limit if provided (e.g., for manual start)
        startIndex: startIndex,
        updateStateCallback: updateStateCallback,
        checkPauseStatus: checkPauseStatus,
        checkStopStatus: checkStopStatus
      }).catch(async (err) => {
          // Catch unhandled errors from startLeakCheck promise itself
          console.error(`[LeakCheck Control] Unhandled error during startLeakCheck execution: ${err.message}`);
          this._isLeakCheckRunning = false; // Ensure flag is cleared on error
          this._isLeakCheckPaused = false;
          this._isLeakCheckStopped = false;
          await updateStateCallback({ status: 'error', lastProcessedIndex: leakCheckState.lastProcessedIndex }); // Update state to error
          // Optionally send an IPC message back if needed
          if (this._window && this._window.webContents && !this._window.webContents.isDestroyed()) {
              this._window.webContents.send('leak-check-result', { success: false, message: `Internal error: ${err.message}` });
          }
      });

      // Return success immediately since the process is now running async
      return { success: true, message: 'Leak check process initiated or resumed.' };

    } catch (error) {
      console.error(`[LeakCheck Control] Error setting up leak check: ${error.message}`);
      this._isLeakCheckRunning = false; // Ensure flag is cleared
      this._isLeakCheckPaused = false;
      this._isLeakCheckStopped = false;
      // Attempt to update state to error
      try { await this.setAppState({ ...await this.getAppState(), leakCheck: { status: 'error', lastProcessedIndex: -1 } }); } catch (e) {}
      return { success: false, message: `Error starting leak check: ${error.message}` };
    }
  }
 // --- End Leak Check Control Method ---


  /**
   * Creates the main window and sets up event handlers.
   * @returns {this}
   * @public
   */
  create () {
    // Protocol scheme registration is done earlier (before class definition)

    app.whenReady().then(async () => { // Make the callback async
      // --- REMOVED Check for AJ Classic Cache Clear Flag on Startup ---


      // Register the actual handler logic once the app is ready, BEFORE creating the window
      protocol.handle('app', (request) => {
        const url = request.url.slice('app://'.length)
        let filePath

        if (app.isPackaged) {
          filePath = path.join(process.resourcesPath, url)
        } else {
          filePath = path.normalize(`${__dirname}/../../${url}`)
        }
    devLog(`[Protocol Handler] Serving request for ${request.url} from ${filePath}`); // Added logging
    return net.fetch(`file://${filePath}`)
      })

      // Now proceed with creating the window and other ready tasks
      this._onReady()
    })

    app.on('window-all-closed', () => {
      // Original logic: Quit if not on macOS when all windows are closed.
      // ASAR restoration is handled in 'will-quit'.
      if (process.platform !== 'darwin') app.quit()
    })

    // Add the will-quit handler
    app.on('will-quit', async (event) => {
      console.log('[App Quit] Entering will-quit handler.'); // LOGGING ADDED
      // Only run the restore logic once
      if (this._isQuitting) {
        console.log('[App Quit] will-quit handler already running, skipping subsequent calls.');
        return; // Skip if already quitting
      }
      this._isQuitting = true; // Set the flag

      // Prevent immediate quitting
      event.preventDefault();
      console.log('[App Quit] Default quit prevented.'); // LOGGING ADDED
      try {
        console.log('[App Quit] Entering main try block.'); // LOGGING ADDED
        // --- Manual Cache Clear Logic (Moved Here) ---
        if (this._isClearingCacheAndQuitting) {
          console.log('[App Quit] Manual cache clearing requested.'); // LOGGING CHANGED
          try {
            console.log('[App Quit] Clearing Electron session cache...'); // LOGGING CHANGED & Restored
            await session.defaultSession.clearCache(); // Restored
            console.log('[App Quit] Session cache cleared.'); // LOGGING ADDED
            console.log('[App Quit] Clearing Electron session storage data...'); // LOGGING CHANGED & Restored
            await session.defaultSession.clearStorageData({ storages: ['cookies', 'localstorage'] }); // Restored
            console.log('[App Quit] Session storage data cleared.'); // LOGGING ADDED
            // Removed SKIPPED log

            const cachePaths = this._getCachePaths();
            if (cachePaths && cachePaths.length > 0) {
              let resolvedHelperPath;
              if (app.isPackaged) {
                resolvedHelperPath = path.join(process.resourcesPath, 'clear-cache-helper.js');
              } else {
                resolvedHelperPath = path.join(__dirname, 'clear-cache-helper.js');
              }
              devLog(`[App Quit] Resolved helper path: ${resolvedHelperPath}`);

              try {
                await fs.access(resolvedHelperPath); // Verify helper exists
                const appExePath = app.getPath('exe');
                const helperArgs = [
                  resolvedHelperPath,
                  ...cachePaths,
                  '--relaunch-after-clear', // Add flag
                  appExePath // Pass executable path
                ];
                console.log(`[App Quit] Spawning helper script detached: node ${helperArgs.join(' ')}`); // LOGGING CHANGED

                // Spawn detached, don't wait for it. It will handle relaunch.
                const child = spawn('node', helperArgs, {
                  detached: true,
                  stdio: 'ignore'
                });
                child.on('error', (err) => { console.error('[App Quit] Failed to spawn helper script:', err); });
                child.unref(); // Allow parent (this process) to exit independently
                console.log('[App Quit] Helper script spawned detached.'); // LOGGING CHANGED

              } catch (helperError) {
                console.error(`[App Quit] Failed to find or spawn helper script (${resolvedHelperPath}):`, helperError);
                // Log the error but continue with shutdown/restore
              }
            } else {
              devLog('[App Quit] Could not determine cache paths. Skipping helper script.');
            }
          } catch (clearError) {
            console.error('[App Quit] Error during manual cache clearing:', clearError);
            // Log error but continue with shutdown/restore
          }
        }
        // --- End Manual Cache Clear Logic ---

        // Call the restore method on our patcher instance AFTER cache clearing
        console.log('[App Quit] Restoring original ASAR...'); // LOGGING CHANGED
        await this._patcher.restoreOriginalAsar(); // Restored this line
        console.log('[App Quit] ASAR restoration finished.'); // LOGGING CHANGED

        // --- General Cleanup ---
        console.log('[App Quit] Performing general cleanup...'); // LOGGING CHANGED
        // Signal Leak Checker to stop if running
        if (this._isLeakCheckRunning) {
          devLog('[App Quit] Signaling running Leak Checker to stop...');
          this._isLeakCheckStopped = true;
          this._isLeakCheckPaused = false; // Ensure pause is cleared
          // Note: We don't await checker stop here to avoid blocking quit indefinitely
        }

        // Terminate the forked API process
        if (this._apiProcess && !this._apiProcess.killed) { // Restored this block
          console.log('[App Quit] Terminating API process...'); // LOGGING CHANGED
          this._apiProcess.kill();
          console.log('[App Quit] API process terminated.'); // LOGGING CHANGED
        }
        // Removed SKIPPED log for API termination
        console.log('[App Quit] General cleanup finished.'); // LOGGING CHANGED
        // --- End General Cleanup ---

        console.log('[App Quit] Main try block finished.'); // LOGGING ADDED
      } catch (error) {
        console.error('[App Quit] Error during will-quit handler execution:', error);
      } finally {
        console.log('[App Quit] Entering finally block. Forcing exit with app.exit(0).'); // LOGGING CHANGED
        // Force exit as allowing default quit process to resume seems unreliable
        app.exit(0); // ADDED FORCE EXIT
      } // End finally
    }); // End app.on('will-quit', ...)


    return this
  }

  /**
   * Registers a global shortcut.
   * @param {string} key - The shortcut key.
   * @param {Function} callback - The callback function.
   * @private
   */
  _registerShortcut (key, callback) {
    globalShortcut.register(key, callback)
  }

  /**
   * Creates a new browser window based on the frame name.
   * @param {Object} options - Options for creating the window.
   * @param {string} options.url - The URL to open.
   * @param {string} options.frameName - The name of the frame.
   * @private
   */
  _createWindow ({ url, frameName }) {
    if (frameName === 'external') {
      shell.openExternal(url)
      return { action: 'deny' }
    }

    return {
      action: 'allow',
      overrideBrowserWindowOptions: {
        ...defaultWindowOptions,
        autoHideMenuBar: true,
        frame: true,
        webPreferences: {
          ...defaultWindowOptions.webPreferences
        }
      }
    }
  }

  /**
   * Initializes the auto-updater and sets up update checks.
   * @private
   */
  _initAutoUpdater () {
    autoUpdater.autoDownload = true; // Automatically download updates when available
    autoUpdater.allowDowngrade = false
    autoUpdater.allowPrerelease = false

    const checkInterval = 1000 * 60 * 5 // 5 minutes
    autoUpdater.checkForUpdates()
    setInterval(() => autoUpdater.checkForUpdates(), checkInterval)

    autoUpdater.on('update-available', () => {
      this.messageWindow('message', {
        type: 'notify',
        message: 'A new update is available. Downloading now...'
      })
    })

    autoUpdater.on('update-downloaded', () => {
      this.messageWindow('message', {
        type: 'celebrate',
        message: 'Update Downloaded. It will be installed on restart.'
      })
    })
  }

  /**
   * Sends a message to the main window process.
   * @param {string} type - The message type.
   * @param {Object} [message={}] - The message payload.
   * @public
   */
  messageWindow (type, message = {}) {
    if (this._window && this._window.webContents) {
      this._window.webContents.send(type, message)
    }
  }

  /**
   * Handles the ready event, creates the main window, spawns the API process,
   * and checks if Leak Check needs to be auto-resumed.
   * @private
   */
  async _onReady () { // Make async
    this._window = new BrowserWindow(defaultWindowOptions)
    // Wait for the window to finish loading before trying to resume
    await this._window.loadFile(path.join(__dirname, 'renderer', 'index.html'))
    this._window.webContents.setWindowOpenHandler((details) => this._createWindow(details))

    // --- Ensure Data Directory Exists (Both Dev and Packaged) ---
    try {
      const dataPath = getDataPath(app); // Pass app object
      await fs.mkdir(dataPath, { recursive: true });
      devLog(`[Startup] Ensured data directory exists: ${dataPath}`);
    } catch (error) {
      console.error(`[Startup] Error ensuring base data directory:`, error);
      // Show error but continue, maybe some features won't work
      dialog.showErrorBox('Startup Error', `Failed to create base data directory. Some features might not work correctly.\n\nError: ${error.message}`);
    }
    // --- End Ensure Data Directory ---

    // --- Create Specific Data Files on Packaged Startup ---
    if (app.isPackaged) {
      devLog('[Startup] Packaged app detected. Ensuring specific data files exist...');
      const dataPath = getDataPath(app); // Pass app object
      // Updated list of files to ensure existence
      const filesToEnsure = [
        'working_accounts.txt',
        'collected_usernames.txt',
        'processed_usernames.txt',
        'potential_accounts.txt',
        'found_accounts.txt',
        'ajc_accounts.txt'
      ];

      try {
        await fs.mkdir(dataPath, { recursive: true });
        devLog(`[Startup] Ensured data directory exists: ${dataPath}`);

        for (const filename of filesToEnsure) {
          const filePath = path.join(dataPath, filename);
          try {
            await fs.access(filePath); // Check if file exists
            devLog(`[Startup] File already exists: ${filePath}`);
          } catch (accessError) {
            // File doesn't exist, create it empty
            if (accessError.code === 'ENOENT') {
              devLog(`[Startup] Creating empty file: ${filePath}`);
              await fs.writeFile(filePath, '', 'utf-8');
            } else {
              throw accessError; // Re-throw other access errors
            }
          }
        }
      } catch (error) {
        console.error(`[Startup] Error ensuring data directory/files at ${dataPath}:`, error);
        // Optionally show a dialog to the user? For now, just log the error.
        dialog.showErrorBox('Startup Error', `Failed to create necessary data files in ${dataPath}. Some features might not work correctly.\n\nError: ${error.message}`);
      }
    }
    // --- End Data Directory Creation ---

    // Redundant protocol handler removed from here. The correct one is in create().
    this._apiProcess = fork(path.join(__dirname, '..', 'api', 'index.js'))

    // Register F11 shortcut for devtools ONLY in development
    if (isDevelopment) {
      // Modified F11 to toggle dev tools for the currently focused window
      this._registerShortcut('F11', () => {
        const focusedWindow = BrowserWindow.getFocusedWindow();
        if (focusedWindow && focusedWindow.webContents) {
          focusedWindow.webContents.toggleDevTools();
        }
      })
    }

    // Enable auto-updater ONLY for production builds
    if (app.isPackaged) { // Use app.isPackaged for a more reliable check
      console.log('[Updater] Production mode detected. Initializing auto-updater.');
      this._initAutoUpdater();
    } else {
      console.log('[Updater] Development mode detected. Auto-updater disabled.');
      // Add placeholder dev-app-update.yml to prevent errors in dev
      const devUpdateConfigPath = path.join(app.getAppPath(), 'dev-app-update.yml');
      fs.access(devUpdateConfigPath).catch(() => {
        fs.writeFile(devUpdateConfigPath, 'provider: github').catch(err => {
          console.error('[Updater] Failed to write dev-app-update.yml:', err);
        });
      });
    }

    // --- Auto-resume Leak Check (Moved to 'renderer-ready' listener) ---
  }
}


// Broadcast packet events to all renderer windows (main and plugin windows)
ipcMain.on('packet-event', (event, packetData) => {
  const windows = BrowserWindow.getAllWindows();
  // console.log(`[IPC Main] Received packet-event. Broadcasting to ${windows.length} window(s).`); // Removed log
  windows.forEach(win => {
    try {
      if (win && win.webContents && !win.webContents.isDestroyed()) {
        win.webContents.send('packet-event', packetData);
      }
    } catch (e) {
      console.error(`[IPC Main] Error sending packet-event to window: ${e.message}`);
    }
  });
});

/**
 * Handle plugin window creation.
 * - In development: plugin windows never open devtools automatically.
 * - In production: plugin windows cannot open devtools at all.
 */
ipcMain.on('open-plugin-window', (event, { url, name, pluginPath }) => {
    devLog(`[IPC Main] Creating plugin window for ${name}`);

    const isDev = process.env.NODE_ENV === 'development';

  const pluginWindow = new BrowserWindow({
    ...defaultWindowOptions,
    title: name,
    width: 800,
    height: 600,
    frame: false,
    webPreferences: {
      ...defaultWindowOptions.webPreferences,
      devTools: true, // Allow devtools in any environment
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  // Load the plugin URL
  pluginWindow.loadURL(url);

  // When window is ready, inject the jam object and jQuery, and open dev tools
    pluginWindow.webContents.on('did-finish-load', () => {
      devLog(`[IPC Main] Plugin window ${name} loaded`);

      // Dev tools do not open automatically for plugin windows.

      // Inject jQuery from CDN
      pluginWindow.webContents.executeJavaScript(`
        (function() {
          if (!window.jQuery) {
            var script = document.createElement('script');
            script.src = "https://code.jquery.com/jquery-3.6.0.min.js";
            script.onload = function() {
              if (process.env.NODE_ENV === 'development') console.log("[Plugin Window] jQuery injected:", typeof window.$);
            };
            document.head.appendChild(script);
          }
        })();
      `).then(() => {
        // Inject window.jam object after jQuery injection
        pluginWindow.webContents.executeJavaScript(`
          try {
            const { ipcRenderer } = require('electron');
            if (process.env.NODE_ENV === 'development') console.log("[Plugin Window] Setting up window.jam...");
            
            // Ensure window.jam exists (created by preload)
            window.jam = window.jam || {};

            // Define dispatch object
            const dispatchObj = {
              sendRemoteMessage: function(msg) {
                if (process.env.NODE_ENV === 'development') console.log("[Plugin Window] Sending remote message via IPC:", msg);
                ipcRenderer.send('send-remote-message', msg);
              },
              sendConnectionMessage: function(msg) {
                if (process.env.NODE_ENV === 'development') console.log("[Plugin Window] Sending connection message via IPC:", msg);
                ipcRenderer.send('send-connection-message', msg);
              },
              // Add getState method using invoke
              getState: function(key) {
                if (process.env.NODE_ENV === 'development') console.log("[Plugin Window] Requesting state via IPC invoke for key:", key);
                // This returns a Promise! Plugin code needs to handle this (e.g., await).
                return ipcRenderer.invoke('dispatch-get-state', key);
              },
              // Add getStateSync method using sendSync
              getStateSync: function(key) {
                if (process.env.NODE_ENV === 'development') console.log("[Plugin Window] Requesting state via IPC sendSync for key:", key);
                // This returns the value directly.
                return ipcRenderer.sendSync('dispatch-get-state-sync', key);
              }
            };

            // Define application object
            const applicationObj = {
              consoleMessage: function(type, msg) {
                // Use string concatenation to avoid nested template literals
                if (process.env.NODE_ENV === 'development') console.log("[Plugin App Console] " + type + ": " + msg); 
                ipcRenderer.send('console-message', { type, msg });
              }
            };

            // Assign to window.jam
            window.jam.dispatch = dispatchObj;
            window.jam.application = applicationObj;

            // Dispatch a custom event to signal readiness
            window.dispatchEvent(new CustomEvent('jam-ready'));
          } catch (err) {
            if (process.env.NODE_ENV === 'development') console.error("[Plugin Window] Error setting up window.jam:", err);
          }
        `);
      });
    });

  // Handle window errors
  pluginWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription) => {
    if (isDevelopment) console.error(`[IPC Main] Plugin window ${name} failed to load:`, errorDescription);
  });
});

// Add handlers for plugin window IPC messages
ipcMain.on('send-remote-message', (event, msg) => {
  devLog("[IPC Main] Received send-remote-message:", msg);
  const mainWindow = BrowserWindow.getAllWindows().find(win => 
    win.webContents.getURL().includes('renderer/index.html')
  );
  if (mainWindow && mainWindow.webContents) {
    mainWindow.webContents.send('plugin-remote-message', msg);
  }
});

ipcMain.on('send-connection-message', (event, msg) => {
  devLog("[IPC Main] Received send-connection-message:", msg);
  const mainWindow = BrowserWindow.getAllWindows().find(win => 
    win.webContents.getURL().includes('renderer/index.html')
  );
  if (mainWindow && mainWindow.webContents) {
    mainWindow.webContents.send('plugin-connection-message', msg);
  }
});

ipcMain.on('console-message', (event, { type, msg }) => {
  devLog(`[Plugin Console] ${type}: ${msg}`);
});

module.exports = Electron
