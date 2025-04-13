 const { app, BrowserWindow, globalShortcut, shell, ipcMain, protocol, net, dialog } = require('electron') // Added dialog
const path = require('path')
const fs = require('fs').promises; // Added for state management
const { fork } = require('child_process')
const { autoUpdater } = require('electron-updater')
const Store = require('electron-store'); // Added for leak checker
const { startLeakCheck } = require('./leakChecker'); // Added for leak checker
// Removed incorrect logger import

const isDevelopment = process.env.NODE_ENV === 'development'
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

class Electron {
  /**
   * Constructor.
   * @constructor
   */
  constructor () {
    this._window = null
    this._apiProcess = null
    this._store = new Store(); // Instantiate Store
    this._isLeakCheckRunning = false; // Added for leak check state
    this._isLeakCheckPaused = false; // Flag for pause state
    this._isLeakCheckStopped = false; // Flag for stop state
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
    ipcMain.on('application-relaunch', () => {
      setTimeout(() => {
        app.relaunch()
        app.exit()
      }, 5000)
    })

    ipcMain.on('open-url', (_, url) => shell.openExternal(url))

    // --- Settings IPC Handlers ---
    ipcMain.handle('get-setting', (event, key) => {
      console.log(`[IPC] Handling 'get-setting' for key: ${key}`);
      try {
        const value = this._store.get(key);
        console.log(`[Store] Value retrieved for '${key}':`, value); // Log retrieved value
        return value;
      } catch (error) {
        console.error(`[Store] Error getting setting '${key}':`, error);
        return undefined; // Or throw an error? Returning undefined might be safer.
      }
    });

    ipcMain.handle('set-setting', (event, key, value) => {
      console.log(`[IPC] Handling 'set-setting' for key: ${key} with value:`, value); // Log value being set
      try {
        this._store.set(key, value);
        console.log(`[Store] Successfully set '${key}'.`); // Log success
        return { success: true };
      } catch (error) {
        console.error(`[Store] Error setting setting '${key}':`, error);
        return { success: false, error: error.message };
      }
    });

    ipcMain.handle('select-output-directory', async (event) => {
      console.log(`[IPC] Handling 'select-output-directory'`);
      if (!this._window) {
        console.error('[Dialog] Cannot show dialog, main window not available.');
        return { canceled: true, error: 'Main window not available' };
      }
      try {
        const result = await dialog.showOpenDialog(this._window, {
          properties: ['openDirectory', 'createDirectory'],
          title: 'Select Leak Check Output Directory'
        });

        if (result.canceled || !result.filePaths || result.filePaths.length === 0) {
          console.log('[Dialog] Directory selection canceled.');
          return { canceled: true };
        } else {
          const selectedPath = result.filePaths[0];
          console.log(`[Dialog] Directory selected: ${selectedPath}`);
          return { canceled: false, path: selectedPath };
        }
      } catch (error) {
        console.error('[Dialog] Error showing open dialog:', error);
        return { canceled: true, error: error.message };
      }
    });
    // --- End Settings IPC Handlers ---


    // --- Leak Checker IPC ---
    // Note: isLeakCheckRunning is now a class property this._isLeakCheckRunning

    // Use handle for async operations like reading/writing state
    ipcMain.handle('leak-check-start', async (event, options = {}) => { // Handles Start and Resume
      console.log('[IPC] Handling leak-check-start/resume request.');
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
        console.log('[IPC] Received leak-check-pause signal.');
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
        console.log('[IPC] Received leak-check-stop signal.');
        this._isLeakCheckStopped = true; // Set stop flag
        this._isLeakCheckPaused = false; // Ensure pause is cleared if stopping from paused state
        // The running startLeakCheck loop will detect this via checkStopStatus()
        // It should then perform cleanup and call updateStateCallback({ status: 'stopped', ... })
        // DO NOT clear _isLeakCheckRunning or update state here. Let the callback handle it.
        console.log('[IPC Stop] Stop flag set. Waiting for checker process to acknowledge.');
        return { success: true, message: 'Stop signal sent. Process will stop shortly.' };
    }).bind(this));

    // IPC handler to verify the actual runtime status
    ipcMain.handle('verify-leak-check-status', async () => {
        console.log('[IPC] Handling verify-leak-check-status request.');
        // Return the current runtime flag state
        return { isRunning: this._isLeakCheckRunning };
    });

    // --- End Leak Checker IPC ---


    // --- App State IPC Handlers --- (Helper methods added below)
    // Note: Direct IPC handlers are kept for potential direct use,
    // but internal calls now use helper methods for consistency.
    ipcMain.handle('get-app-state', (async () => {
        console.log(`[IPC] Handling direct 'get-app-state' request.`);
        return this.getAppState(); // Use helper
    }).bind(this)); // Bind to the Electron class instance

    ipcMain.handle('set-app-state', (async (event, newState) => {
        console.log(`[IPC] Handling direct 'set-app-state' request.`);
        return this.setAppState(newState); // Use helper
    }).bind(this)); // Bind to the Electron class instance
    // --- End App State IPC Handlers ---

    // --- Account Tester IPC Handlers ---
    // Use a closure to capture 'this'
    const self = this;
    ipcMain.handle('tester-cleanup-processed', async (event, filePath) => {
      console.log(`[IPC] Handling 'tester-cleanup-processed' for file: ${filePath}`);
      if (!filePath) {
        return { success: false, error: 'File path is required.' };
      }

      try {
        // 1. Get current state
        const appState = await self.getAppState();
        const fileState = appState?.accountTester?.fileStates?.[filePath];

        if (!fileState) {
          console.log(`[Cleanup] No state found for file ${filePath}. Nothing to clean.`);
          return { success: true, removedCount: 0, message: 'No state found for this file.' };
        }

        // 2. Read the account file content
        let fileContent;
        try {
          fileContent = await fs.readFile(filePath, 'utf-8');
        } catch (readError) {
          if (readError.code === 'ENOENT') {
            console.error(`[Cleanup] Account file not found: ${filePath}`);
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
             console.log(`[Cleanup] Removing tested account: ${accountKey} (Status: ${status})`);
          }
        }

        const removedCount = originalCount - linesToKeep.length;
        console.log(`[Cleanup] Original lines: ${originalCount}, Lines to keep: ${linesToKeep.length}, Removed: ${removedCount}`);

        // 4. Write the filtered content back to the file
        await fs.writeFile(filePath, linesToKeep.join('\n'), 'utf-8'); // Use '\n' for consistency
        console.log(`[Cleanup] Successfully wrote cleaned file: ${filePath}`);

        // 5. Optionally: Clean up the state for this file?
        // Decided against modifying state here. Reloading the list will effectively refresh the state view.
        // If we wanted to clean state:
        // delete appState.accountTester.fileStates[filePath];
        // await this.setAppState(appState);

        return { success: true, removedCount: removedCount };

      } catch (error) {
        console.error(`[Cleanup] Error processing file ${filePath}:`, error);
        return { success: false, error: error.message || 'An unknown error occurred during cleanup.' };
      }
    });

    // --- New Handlers for Specific File Loads (using handle/invoke) ---
    const createLoadFileHandler = (channelName, relativeFilePath) => {
      ipcMain.handle(channelName, async (event) => { // Changed to ipcMain.handle
        // No sender needed for handle, result is returned
        const fullPath = path.resolve(relativeFilePath);
        console.log(`[IPC ${channelName}] Handling request. Resolved path: ${fullPath}`);

        try {
          console.log(`[IPC ${channelName}] Attempting to read file: ${fullPath}`);
          const fileContent = await fs.readFile(fullPath, 'utf-8');
          console.log(`[IPC ${channelName}] Successfully read file: ${fullPath}`);
          const lines = fileContent.split(/\r?\n/);
          const accounts = lines
            .map(line => line.trim())
            .filter(line => line && line.includes(':'))
            .map(line => {
              const [username, ...passwordParts] = line.split(':');
              const password = passwordParts.join(':');
              return { username, password, status: 'pending' };
            });

          console.log(`[IPC ${channelName}] Successfully parsed ${accounts.length} accounts from ${fullPath}`);
          this._store.set('testerLastPath', fullPath);
          console.log(`[Store] Updated testerLastPath to: ${fullPath}`);

          console.log(`[IPC ${channelName}] Returning success response.`);
          return { // Return the result directly
            success: true,
            accounts: accounts,
            filePath: fullPath
          };
        } catch (error) {
          console.error(`[IPC ${channelName}] Error processing file ${fullPath}:`, error);
          let errorMessage = `Error loading file: ${error.message}`;
          if (error.code === 'ENOENT') {
            errorMessage = `File not found: ${path.basename(fullPath)}`;
          }
          console.log(`[IPC ${channelName}] Returning error response.`);
          return { // Return the error result directly
            success: false,
            error: errorMessage,
            filePath: fullPath
          };
          // No need for inner try/catch for sending response
        }
      });
    };

    createLoadFileHandler('tester-load-all-accounts', 'data/accounts.txt');
    createLoadFileHandler('tester-load-confirmed-accounts', 'data/ajc_confirmed_accounts.txt');
    createLoadFileHandler('tester-load-works-accounts', 'data/working_accounts.txt');
    // --- End New Handlers ---

    // --- End Account Tester IPC Handlers ---

    // --- Renderer Ready Listener (for Auto-Resume) ---
    ipcMain.once('renderer-ready', (async () => {
      console.log('[IPC] Received renderer-ready signal.');
      try {
        console.log('[Startup] Checking for Leak Check auto-resume...');
        const appState = await this.getAppState();
        if (appState.leakCheck && (appState.leakCheck.status === 'running' || appState.leakCheck.status === 'paused')) {
          console.log(`[Startup] Found Leak Check state: ${appState.leakCheck.status}. Auto-resume disabled.`);
          // No need for setTimeout now, as renderer is confirmed ready
          // --- AUTO-RESUME DISABLED ---
          // this._initiateOrResumeLeakCheck()
          //   .then(result => {
          //     if (result.success) {
          //       console.log('[Startup] Leak Check auto-resume initiated successfully.');
          //     } else {
          //       console.error(`[Startup] Leak Check auto-resume failed: ${result.message}`);
          //     }
          //   })
          //   .catch(err => {
          //     console.error(`[Startup] Error during Leak Check auto-resume initiation: ${err.message}`);
          //   });
          // --- END AUTO-RESUME DISABLED ---
        } else {
          console.log('[Startup] No Leak Check auto-resume needed (State: ' + (appState.leakCheck?.status || 'idle') + ').');
        }
      } catch (error) {
        console.error(`[Startup] Error during Leak Check auto-resume check: ${error.message}`);
      }
    }).bind(this));
    // --- End Renderer Ready Listener ---

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

    app.whenReady().then(() => {
      // Register the actual handler logic once the app is ready, BEFORE creating the window
      protocol.handle('app', (request) => {
        const url = request.url.slice('app://'.length)
        let filePath

        if (app.isPackaged) {
          filePath = path.join(process.resourcesPath, url)
        } else {
          filePath = path.normalize(`${__dirname}/../../${url}`)
        }
        console.log(`[Protocol Handler] Serving request for ${request.url} from ${filePath}`); // Added logging
        return net.fetch(`file://${filePath}`)
      })

      // Now proceed with creating the window and other ready tasks
      this._onReady()
    })

    app.on('window-all-closed', () => {
      if (process.platform !== 'darwin') app.quit()
    })

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

    // Redundant protocol handler removed from here. The correct one is in create().
    this._apiProcess = fork(path.join(__dirname, '..', 'api', 'index.js'))
    this._registerShortcut('F11', () => this._window.webContents.openDevTools())

    // Enable auto-updater for production builds
    if (!isDevelopment) {
      this._initAutoUpdater()
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

// Handle plugin window creation
ipcMain.on('open-plugin-window', (event, { url, name, pluginPath }) => {
  console.log(`[IPC Main] Creating plugin window for ${name}`);
  
  const pluginWindow = new BrowserWindow({
    ...defaultWindowOptions,
    title: name,
    width: 800,
    height: 600,
    frame: false, // Make plugin window frameless
    webPreferences: {
      ...defaultWindowOptions.webPreferences,
      devTools: true,
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  // Load the plugin URL
  pluginWindow.loadURL(url);
  
  // Open DevTools by default for debugging
  if (process.env.NODE_ENV === 'development') {
    pluginWindow.webContents.openDevTools();
  }

  // When window is ready, inject the jam object
  pluginWindow.webContents.on('did-finish-load', () => {
    console.log(`[IPC Main] Plugin window ${name} loaded`);
    
    // Inject window.jam object
    pluginWindow.webContents.executeJavaScript(`
      try {
        const { ipcRenderer } = require('electron');
        console.log("[Plugin Window] Setting up window.jam...");
        
        // Ensure window.jam exists (created by preload)
        window.jam = window.jam || {};

        // Define dispatch object
        const dispatchObj = {
          sendRemoteMessage: function(msg) {
            console.log("[Plugin Window] Sending remote message via IPC:", msg);
            ipcRenderer.send('send-remote-message', msg);
          },
          sendConnectionMessage: function(msg) {
            console.log("[Plugin Window] Sending connection message via IPC:", msg);
            ipcRenderer.send('send-connection-message', msg);
          }
        };

        // Define application object
        const applicationObj = {
          consoleMessage: function(type, msg) {
            // Escape inner backticks and dollar signs for the outer template literal
            console.log(\`[Plugin App Console] \\\${type}: \\\${msg}\`); 
            ipcRenderer.send('console-message', { type, msg });
          }
        };

        // Assign to window.jam
        window.jam.dispatch = dispatchObj;
        window.jam.application = applicationObj;

        // console.log("[Plugin Window] window.jam properties setup complete."); // Removed log

        // Dispatch a custom event to signal readiness
        window.dispatchEvent(new CustomEvent('jam-ready'));
        // console.log("[Plugin Window] Dispatched jam-ready event."); // Removed log
      } catch (err) {
        console.error("[Plugin Window] Error setting up window.jam:", err);
      }
    `);
  });

  // Handle window errors
  pluginWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription) => {
    console.error(`[IPC Main] Plugin window ${name} failed to load:`, errorDescription);
  });
});

// Add handlers for plugin window IPC messages
ipcMain.on('send-remote-message', (event, msg) => {
  console.log("[IPC Main] Received send-remote-message:", msg);
  const mainWindow = BrowserWindow.getAllWindows().find(win => 
    win.webContents.getURL().includes('renderer/index.html')
  );
  if (mainWindow && mainWindow.webContents) {
    mainWindow.webContents.send('plugin-remote-message', msg);
  }
});

ipcMain.on('send-connection-message', (event, msg) => {
  console.log("[IPC Main] Received send-connection-message:", msg);
  const mainWindow = BrowserWindow.getAllWindows().find(win => 
    win.webContents.getURL().includes('renderer/index.html')
  );
  if (mainWindow && mainWindow.webContents) {
    mainWindow.webContents.send('plugin-connection-message', msg);
  }
});

ipcMain.on('console-message', (event, { type, msg }) => {
  console.log(`[Plugin Console] ${type}: ${msg}`);
});

module.exports = Electron
