const { app, BrowserWindow, globalShortcut, shell, ipcMain, protocol, net, dialog, session } = require('electron');
const path = require('path');
const fs = require('fs'); // Changed to import standard fs module
const fsPromises = fs.promises; // Alias for promises API
const crypto = require('crypto');
const { fork, spawn } = require('child_process');
const { autoUpdater } = require('electron-updater');
const Store = require('electron-store');
const os = require('os');
// const keytar = require('keytar'); // Will be required in constructor

// Suppress Electron security warnings
process.env.ELECTRON_DISABLE_SECURITY_WARNINGS = 'true';

// Keytar service name for Leak Checker API Key
let KEYTAR_SERVICE_LEAK_CHECK_API_KEY;
const KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY = 'leak_checker_api_key';
const MIGRATION_FLAG_LEAK_CHECK_API_KEY_V1 = 'leakCheckApiKeyMigratedToKeytar_v1';

const Patcher = require('./renderer/application/patcher');
const { getDataPath } = require('../Constants');
const logManager = require('../utils/LogManager');

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
const defaultDataDir = path.resolve('data');
const LOGGED_USERNAMES_FILE = 'logged_usernames.txt';

const schema = {
  network: {
    type: 'object',
    properties: {
      smartfoxServer: {
        type: 'string',
        default: 'lb-iss04-classic-prod.animaljam.com'
      },
      secureConnection: {
        type: 'boolean',
        default: true
      }
    },
    default: {}
  },
  ui: {
    type: 'object',
    properties: {
      promptOnExit: {
        type: 'boolean',
        default: true
      },
      hideGamePlugins: {
        type: 'boolean',
        default: false
      },
      performServerCheckOnLaunch: {
        type: 'boolean',
        default: true
      }
    },
    default: {}
  },
  logs: {
    type: 'object',
    properties: {
      consoleLimit: {
        type: 'number',
        default: 1000
      },
      networkLimit: {
        type: 'number',
        default: 1000
      }
    },
    default: {}
  },
  plugins: {
    type: 'object',
    properties: {
      usernameLogger: {
        type: 'object',
        properties: {
          apiKey: { type: 'string', default: '' },
          outputDir: { type: 'string', default: '' },
          autoCheck: {
            type: 'object',
            properties: {
              enabled: { type: 'boolean', default: false },
              threshold: { type: 'number', default: 100 }
            },
            default: {}
          },
          collection: {
            type: 'object',
            properties: {
              enabled: { type: 'boolean', default: true },
              collectNearby: { type: 'boolean', default: true },
              collectBuddies: { type: 'boolean', default: true }
            },
            default: {}
          }
        },
        default: {}
      }
    },
    default: {}
  },
  updates: {
    type: 'object',
    properties: {
      enableAutoUpdates: {
        type: 'boolean',
        default: true
      }
    },
    default: {}
  }
};

const DEFAULT_APP_STATE = {
  leakCheck: {
    inputFilePath: null,
    lastProcessedIndex: -1,
    status: "idle"
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
    preload: path.resolve(__dirname, 'preload.js'),
    additionalArguments: ['--disable-electron-security-warnings']
  },
  icon: path.join('assets', 'images', 'icon.png')
}

protocol.registerSchemesAsPrivileged([
  { scheme: 'app', privileges: { standard: true, secure: true, supportFetchAPI: true } }
]);

class Electron {
  constructor () {
    this._window = null
    this._apiProcess = null
    this._store = new Store({ schema });
    this.keytar = require('keytar'); // Initialize keytar as an instance property

    const appNameForKeytar = app.getName();
    KEYTAR_SERVICE_LEAK_CHECK_API_KEY = `${appNameForKeytar}-leak-check-api-key`;
    console.log(`[Keytar Init] app.getName() resolved to: "${appNameForKeytar}"`);
    console.log(`[Keytar Init] KEYTAR_SERVICE_LEAK_CHECK_API_KEY set to: "${KEYTAR_SERVICE_LEAK_CHECK_API_KEY}"`);

    // Handler registration moved to _onReady for later initialization.
    // global.console.log('[IPC Main CONSTRUCTOR Setup] DIAGNOSTIC: "get-main-log-path" handler registration REMOVED from constructor start.');

    console.log(`[ElectronStore Init] Value of 'ui.promptOnExit' after store initialization: ${this._store.get('ui.promptOnExit')}`);
    
    this._migrateLeakCheckApiKeyToKeytar().catch(err => {
      console.error('[Migration] Error during leak check API key migration:', err);
    });

    this._patcher = new Patcher(null);
    this._isQuitting = false;
    this._isClearingCacheAndQuitting = false;
    this._savedWindowState = null;
    this._setupIPC() // Original call to setup other IPC handlers
    this.pluginWindows = new Map();
    this._backgroundPlugins = new Set();
    this.manualCheckInProgress = false; // Flag for manual update checks
  }

  _setupIPC () {
    // Original _setupIPC content starts here, the 'get-main-log-path' handler is now in the constructor
    ipcMain.on('open-directory', (event, filePath) => {
      if (!filePath) {
        console.error('[IPC open-directory] Received request with no filePath.');
        return;
      }
      console.log(`[IPC open-directory] Attempting to open path: ${filePath}`);
      shell.openPath(filePath).catch(err => {
         console.error(`[IPC open-directory] Error opening path '${filePath}':`, err);
         if (event && event.sender && !event.sender.isDestroyed()) {
            event.sender.send('directory-open-error', { path: filePath, error: err.message });
         }
      });
    })

    ipcMain.on('window-close', () => {
      console.log(`[window-close] Value of 'ui.promptOnExit' from store before 'shouldPrompt' check: ${this._store.get('ui.promptOnExit', true)}`);
      const shouldPrompt = this._store.get('ui.promptOnExit', true);
      
      if (shouldPrompt && this._window && !this._window.isDestroyed()) {
        devLog('[IPC window-close] Showing exit confirmation modal');
        this._window.webContents.send('show-exit-confirmation');
      } else {
        devLog('[IPC window-close] Closing window directly (no prompt)');
        this._window.close();
      }
    })
    
    ipcMain.on('exit-confirmation-response', (event, { confirmed, dontAskAgain }) => {
      devLog(`[IPC exit-confirmation-response] Received: confirmed=${confirmed}, dontAskAgain=${dontAskAgain}`);
      
      if (dontAskAgain) {
        devLog('[IPC exit-confirmation-response] Setting promptOnExit to false');
        this._store.set('ui.promptOnExit', false);
        console.log(`[exit-confirmation-response] Value of 'ui.promptOnExit' after set: ${this._store.get('ui.promptOnExit')}`);
      }
      
      if (confirmed) {
        devLog('[IPC exit-confirmation-response] Confirmed exit, closing window');
        this._window.close();
      }
    })

    ipcMain.on('window-minimize', () => {
      if (this._window) {
        this._window.minimize();
        this._handleAppMinimized();
      }
    })
    
    ipcMain.on('window-toggle-fullscreen', () => {
      if (!this._window) return
      
      if (!this._window.isFullScreen()) {
        const bounds = this._window.getBounds()
        this._savedWindowState = {
          bounds,
          isMaximized: this._window.isMaximized()
        }
        devLog('[IPC window-toggle-fullscreen] Saving window state before fullscreen:', this._savedWindowState)
      }
      
      this._window.setFullScreen(!this._window.isFullScreen())
      
      this._window.webContents.send('fullscreen-changed', this._window.isFullScreen())
    })

    ipcMain.on('window-toggle-maximize', () => {
      if (!this._window) return
      
      if (this._window.isMaximized()) {
        this._window.unmaximize()
        devLog('[IPC window-toggle-maximize] Window unmaximized')
      } else {
        if (!this._savedWindowState) {
          this._savedWindowState = {
            bounds: this._window.getBounds(),
            isMaximized: false
          }
          devLog('[IPC window-toggle-maximize] Saving window state before maximize:', this._savedWindowState)
        }
        
        this._window.maximize()
        devLog('[IPC window-toggle-maximize] Window maximized')
      }
      
      this._window.webContents.send('maximize-changed', this._window.isMaximized())
    })

    ipcMain.on('open-settings', (_, url) => shell.openExternal(url))

    ipcMain.on('open-url', (_, url) => shell.openExternal(url))

    ipcMain.on('plugin-window-minimize', (event) => {
      const senderWindow = BrowserWindow.fromWebContents(event.sender)
      if (senderWindow && !senderWindow.isDestroyed()) {
        devLog(`[IPC plugin-window-minimize] Minimizing window: ${senderWindow.getTitle()}`);
        senderWindow.minimize()
      } else {
        devWarn('[IPC plugin-window-minimize] Sender window not found or already destroyed.');
      }
    })

    ipcMain.handle('get-app-version', () => {
      devLog('[IPC] Handling get-app-version');
      return app.getVersion();
    });

    ipcMain.handle('get-setting', async (event, key) => {
      try {
        if (key === 'plugins.usernameLogger.apiKey') {
          devLog('[IPC get-setting] Attempting to get plugins.usernameLogger.apiKey from Keytar.');
          const apiKey = await this.keytar.getPassword(KEYTAR_SERVICE_LEAK_CHECK_API_KEY, KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY);
          return apiKey || '';
        }
        const valueFromStore = this._store.get(key);
        return valueFromStore;
      } catch (error) {
        if (isDevelopment) {
           console.error(`[Store/Keytar GET] Error getting setting '${key}': ${error.message}`);
           console.error(`[Store/Keytar GET] Stack: ${error.stack}`);
        }
        // Ensure consistent return for the specific key on error, otherwise undefined
        return key === 'plugins.usernameLogger.apiKey' ? '' : undefined;
      }
    });

    ipcMain.handle('set-setting', async (event, key, value) => {
      try {
        if (key === 'plugins.usernameLogger.apiKey') {
          devLog('[IPC set-setting] Attempting to set plugins.usernameLogger.apiKey in Keytar.');
          if (typeof value === 'string' && value.trim() !== '') {
            await this.keytar.setPassword(KEYTAR_SERVICE_LEAK_CHECK_API_KEY, KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY, value);
          } else {
            await this.keytar.deletePassword(KEYTAR_SERVICE_LEAK_CHECK_API_KEY, KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY);
          }
          return { success: true };
        }
        this._store.set(key, value);
        return { success: true };
      } catch (error) {
        if (isDevelopment) {
           console.error(`[Store/Keytar SET] Error setting setting '${key}' with value '${value}': ${error.message}`);
           console.error(`[Store/Keytar SET] Stack: ${error.stack}`);
        }
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

    ipcMain.handle('save-text-file', async (event, options) => {
      devLog(`[IPC save-text-file] Handling request to save text file: ${options.suggestedFilename}`);
      
      if (!this._window) {
        devLog('[IPC save-text-file] Cannot show dialog, main window not available');
        return { success: false, canceled: true };
      }
      
      try {
        const result = await dialog.showSaveDialog(this._window, {
          title: 'Save Report',
          defaultPath: options.suggestedFilename,
          filters: [
            { name: 'Text Files', extensions: ['txt'] },
            { name: 'All Files', extensions: ['*'] }
          ]
        });
        
        if (result.canceled || !result.filePath) {
          devLog('[IPC save-text-file] Save dialog was canceled');
          return { success: false, canceled: true };
        }
        
        devLog(`[IPC save-text-file] Writing content to file: ${result.filePath}`);
        await fsPromises.writeFile(result.filePath, options.content, 'utf-8');
        
        devLog('[IPC save-text-file] File saved successfully');
        return { success: true, filePath: result.filePath };
      } catch (error) {
        console.error('[IPC save-text-file] Error saving file:', error);
        return { success: false, error: error.message };
      }
    });

    ipcMain.on('app-restart', () => {
      console.log('[IPC] Received app-restart signal.');
      app.relaunch();
      app.exit(0);
    });


    // --- Leak Checker IPC (REMOVED) ---


    // --- App State IPC Handlers ---
    ipcMain.handle('get-app-state', (async () => {
        devLog(`[IPC] Handling direct 'get-app-state' request.`);
        return this.getAppState();
    }).bind(this));

    ipcMain.handle('set-app-state', (async (event, newState) => {
        devLog(`[IPC] Handling direct 'set-app-state' request.`);
        return this.setAppState(newState);
    }).bind(this));


    // --- Plugin State IPC Bridge ---
    ipcMain.handle('dispatch-get-state', async (event, key) => {
      if (this._isQuitting) {
        if (isDevelopment) console.warn(`[IPC Main] Denying 'dispatch-get-state' for key '${key}' because app is quitting.`);
        return Promise.reject(new Error('Application is shutting down. Cannot get state.'));
      }

      if (!this._window || !this._window.webContents || this._window.webContents.isDestroyed()) {
        if (isDevelopment) console.error(`[IPC Main] Cannot get state for key '${key}': Main window not available.`);
        return Promise.reject(new Error('Main window not available to get state.'));
      }

      const replyChannel = `get-state-reply-${crypto.randomUUID()}`;

      return new Promise((resolve, reject) => {
        const timeout = setTimeout(() => {
          ipcMain.removeListener(replyChannel, listener);
          if (isDevelopment) console.error(`[IPC Main] Timeout waiting for reply on ${replyChannel} for key ${key}`);
          reject(new Error(`Timeout waiting for state response for key: ${key}`));
        }, 2000);

        const listener = (event, value) => {
          clearTimeout(timeout);
          resolve(value);
        };

        ipcMain.once(replyChannel, listener);

        if (this._window && this._window.webContents && !this._window.webContents.isDestroyed()) {
          this._window.webContents.send('main-renderer-get-state-async', { key, replyChannel });
        } else {
          clearTimeout(timeout);
          ipcMain.removeListener(replyChannel, listener);
          if (isDevelopment) console.error(`[IPC Main] Main window webContents destroyed before sending 'main-renderer-get-state-async' for key '${key}'.`);
          reject(new Error('Main window became unavailable before state request could be sent.'));
        }
      });
    });

    // --- Renderer Ready Listener (for Auto-Resume) ---
    ipcMain.once('renderer-ready', (async () => {
      devLog('[IPC] Received renderer-ready signal.');
    }).bind(this));

    // --- Danger Zone IPC Handlers ---
    ipcMain.handle('danger-zone:clear-cache', async () => {
      devLog('[IPC] Handling danger-zone:clear-cache');
      const continueClear = await this._confirmNoOtherInstances('clear the cache');
      if (!continueClear) {
        return { success: false, message: 'Cache clearing cancelled by user.' };
      }

      try {
        devLog('[Clear Cache] Clearing Electron session cache...');
        await session.defaultSession.clearCache();
        devLog('[Clear Cache] Clearing Electron session storage data (cookies, localstorage)...');
        await session.defaultSession.clearStorageData({ storages: ['cookies', 'localstorage'] });
        devLog('[Clear Cache] Electron session data cleared.');

        const cachePaths = this._getCachePaths();
        if (!cachePaths || cachePaths.length === 0) {
           devLog('[Clear Cache] Could not determine cache paths. Skipping helper script.');
        } else {
          const helperScriptPath = path.join(__dirname, 'clear-cache-helper.js');
          devLog(`[Clear Cache] Spawning helper script: ${helperScriptPath} with paths:`, cachePaths);

           let resolvedHelperPath;
           if (app.isPackaged) {
             resolvedHelperPath = path.join(process.resourcesPath, 'clear-cache-helper.js');
           } else {
             resolvedHelperPath = helperScriptPath;
           }
           devLog(`[Clear Cache] Resolved helper path: ${resolvedHelperPath}`);

           try {
               await fsPromises.access(resolvedHelperPath);

               const child = spawn('node', [resolvedHelperPath, ...cachePaths], {
                 detached: true,
                 stdio: 'ignore'
               });
               child.on('error', (err) => { console.error('[Clear Cache] Failed to spawn helper script:', err); });
               child.unref();
               devLog('[Clear Cache] Helper script spawned.');
           } catch (accessError) {
                console.error(`[Clear Cache] Helper script not found at: ${resolvedHelperPath}`, accessError);
           }
        }

        devLog('[Clear Cache] Quitting application.');
        app.quit();
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

      this._isClearingCacheAndQuitting = true;
      devLog('[Clear Cache] Flag set. Quitting application to trigger will-quit handler.');
      app.quit();
      return { success: true, message: 'Cache clearing initiated. Application will close.' };

    });

    ipcMain.handle('danger-zone:uninstall', async () => {
      devLog('[IPC] Handling danger-zone:uninstall');
      const continueUninstall = await this._confirmNoOtherInstances('uninstall Strawberry Jam');
      if (!continueUninstall) {
        return { success: false, message: 'Uninstall cancelled by user.' };
      }

      try {
        const uninstallerPath = this._getUninstallerPath();
        if (!uninstallerPath) {
          throw new Error('Uninstaller path could not be determined for this OS.');
        }

        await fsPromises.access(uninstallerPath);
        devLog(`[Uninstall] Found uninstaller at: ${uninstallerPath}`);

        spawn(uninstallerPath, [], {
          detached: true,
          stdio: 'ignore'
        }).unref();

        devLog('[Uninstall] Uninstaller process spawned. Quitting application.');

        app.quit();
        return { success: true };

      } catch (error) {
        console.error('[Uninstall] Error:', error);
        const errorMsg = error.code === 'ENOENT' ? 'Uninstaller executable not found.' : error.message;
        dialog.showMessageBoxSync(this._window, {
          type: 'error',
          title: 'Uninstall Error',
          message: `Failed to start uninstaller: ${errorMsg}`,
          buttons: ['OK']
        });
        return { success: false, error: errorMsg };
      }
    });

    ipcMain.on('open-plugin-window', this._handleOpenPluginWindow.bind(this));

    ipcMain.handle('get-os-info', async () => {
      return {
        platform: process.platform,
        release: os.release(),
        arch: process.arch
      };
    });

    ipcMain.handle('get-enabled-plugins', async () => {
      try {
        const plugins = [];
        const pluginsPath = path.join(app.getPath('userData'), 'plugins');
        
        if (fs.existsSync(pluginsPath)) {
          const pluginDirs = fs.readdirSync(pluginsPath, { withFileTypes: true })
            .filter(dirent => dirent.isDirectory())
            .map(dirent => dirent.name);
          
          for (const dir of pluginDirs) {
            const configPath = path.join(pluginsPath, dir, 'plugin.json');
            
            if (fs.existsSync(configPath)) {
              try {
                const configData = JSON.parse(fs.readFileSync(configPath, 'utf8'));
                
                if (configData.enabled !== false) {
                  plugins.push({
                    name: configData.name || dir,
                    version: configData.version || 'unknown',
                    author: configData.author || 'unknown'
                  });
                }
              } catch (err) {
                try {
                  logManager.error(`Error reading plugin config for ${dir}: ${err.message}`);
                } catch (logErr) {
                  console.error(`Error reading plugin config for ${dir}: ${err.message}`);
                }
              }
            }
          }
        }
        
        return plugins;
      } catch (error) {
        try {
          logManager.error('Error getting enabled plugins:', error.message);
        } catch (logErr) {
          console.error('Error getting enabled plugins:', error.message);
        }
        return [];
      }
    });

    ipcMain.handle('get-cache-size', async () => {
      devLog('[IPC] Handling get-cache-size');
      const cachePaths = this._getCachePaths();
      const sizes = { total: 0, directories: {} };

      try {
        const calculateDirSize = async (dirPath) => {
          let size = 0;
          
          try {
            await fsPromises.access(dirPath);
          } catch (error) {
            return 0;
          }

          const files = await fsPromises.readdir(dirPath, { withFileTypes: true });
          
          for (const file of files) {
            const filePath = path.join(dirPath, file.name);
            
            if (file.isDirectory()) {
              size += await calculateDirSize(filePath);
            } else {
              try {
                const stats = await fsPromises.stat(filePath);
                size += stats.size;
              } catch (error) {
                devLog(`[Cache Size] Error getting size for ${filePath}: ${error.message}`);
              }
            }
          }
          
          return size;
        };

        for (const cachePath of cachePaths) {
          try {
            const dirName = path.basename(cachePath);
            const size = await calculateDirSize(cachePath);
            sizes.directories[dirName] = size;
            sizes.total += size;
          } catch (error) {
            devLog(`[Cache Size] Error calculating size for ${cachePath}: ${error.message}`);
            sizes.directories[path.basename(cachePath)] = 0;
          }
        }

        devLog(`[Cache Size] Total size: ${sizes.total} bytes`);
        return sizes;
      } catch (error) {
        console.error('[Cache Size] Error calculating cache sizes:', error);
        return { total: 0, directories: {} };
      }
    });

    ipcMain.on('direct-close-window', () => {
      devLog('[IPC direct-close-window] Received request to close window directly.');
      if (this._window && !this._window.isDestroyed()) {
        this._window.close();
      }
    });

    // Handler for logs from winapp.asar (game client)
    ipcMain.on('winapp-generate-report', (event, reportData) => {
      if (reportData && reportData.logs) {
        logManager.addGameClientLogs(reportData.logs);
        devLog(`[IPC Main] Received ${reportData.logs.length} logs from winapp.asar.`);
        // Optionally, send a confirmation back if LoginScreen.js were to use invoke
        // event.reply('winapp-report-received', { status: 'success' });
      } else {
        devWarn('[IPC Main] Received winapp-generate-report without log data.');
      }
    });

    ipcMain.handle('get-username-logger-counts', async (event) => {
      devLog('[IPC Main] Handling "get-username-logger-counts" request from settings UI.');
      try {
        const pluginWindowEntry = Array.from(this.pluginWindows.entries()).find(([name, win]) => name === 'Username Logger');
        
        if (!pluginWindowEntry) {
          console.warn('[IPC Main] Username Logger plugin instance not found in pluginWindows map. It might not be loaded or opened yet.');
          // Return a default/empty state or null, as rejecting might still cause unhandled promise issues higher up if not caught.
          return null;
        }
        const pluginWindow = pluginWindowEntry[1];

        if (!pluginWindow || pluginWindow.isDestroyed() || !pluginWindow.webContents || pluginWindow.webContents.isDestroyed()) {
          console.warn('[IPC Main] Username Logger plugin window or its webContents are not available (destroyed or not ready).');
          return null;
        }

        // Ensure the function is available on the plugin's window object
        const isFunctionAvailable = await pluginWindow.webContents.executeJavaScript('typeof window.getUsernameLoggerCounts === "function"');
        if (!isFunctionAvailable) {
          console.warn('[IPC Main] "window.getUsernameLoggerCounts" function not found on Username Logger plugin window. The plugin might not be fully initialized.');
          return null;
        }
        
        devLog('[IPC Main] Executing "window.getUsernameLoggerCounts()" on plugin window.');
        const counts = await pluginWindow.webContents.executeJavaScript('window.getUsernameLoggerCounts();');
        devLog('[IPC Main] Received counts from plugin via executeJavaScript:', counts);
        return counts;
      } catch (error) {
        console.error('[IPC Main] Error in "get-username-logger-counts" handler:', error);
        // Return null or a default error object instead of rejecting, to prevent unhandled rejections if the caller doesn't catch.
        return null;
      }
    });

    // The 'get-main-log-path' handler was moved to the constructor.
    // The diagnostic global.console.log that was here is also effectively moved.

    ipcMain.on('plugin-settings-updated', (event) => {
      devLog('[IPC] Received plugin-settings-updated signal. Broadcasting to renderer.');
      if (this._window && this._window.webContents && !this._window.webContents.isDestroyed()) {
        this._window.webContents.send('broadcast-plugin-settings-updated');
      }
    });

    ipcMain.on('check-for-updates', () => {
      console.log('[IPC] Received check-for-updates signal for manual check.');
      this.manualCheckInProgress = true; // Set flag
      autoUpdater.checkForUpdates().catch(err => {
        console.error('[Updater] Error during manual update check (IPC):', err.message);
        if (this._window && this._window.webContents && !this._window.isDestroyed()) {
          // Send error status back to renderer via the new manual-update-check-status channel
          this._window.webContents.send('manual-update-check-status', { status: 'error', message: `Manual update check failed: ${err.message}` });
        }
        this.manualCheckInProgress = false; // Reset flag on error
      });
    });
  }

  async _migrateLeakCheckApiKeyToKeytar() {
    if (this._store.get(MIGRATION_FLAG_LEAK_CHECK_API_KEY_V1)) {
      devLog('[Migration LeakCheck] API key migration already performed. Skipping.');
      return;
    }

    devLog('[Migration LeakCheck] Starting Leak Check API key migration to Keytar...');
    const oldApiKey = this._store.get('leakCheck.apiKey');

    if (oldApiKey && typeof oldApiKey === 'string' && oldApiKey.trim() !== '') {
      try {
        await this.keytar.setPassword(KEYTAR_SERVICE_LEAK_CHECK_API_KEY, KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY, oldApiKey);
        devLog('[Migration LeakCheck][Keytar] Successfully migrated API key.');
        this._store.set('leakCheck.apiKey', '');
        devLog('[Migration LeakCheck] Plaintext API key removed from store.');
        this._store.set(MIGRATION_FLAG_LEAK_CHECK_API_KEY_V1, true);
        devLog('[Migration LeakCheck] API key migration completed and flag set.');
      } catch (err) {
        console.error(`[Migration LeakCheck][Keytar] Error migrating API key: ${err.message}`);
        if (isDevelopment) console.error(`[Migration LeakCheck][Keytar] Stack: ${err.stack}`);
      }
    } else {
      devLog('[Migration LeakCheck] No old API key found in store to migrate or key was empty.');
      this._store.set(MIGRATION_FLAG_LEAK_CHECK_API_KEY_V1, true);
    }
  }

  _handleOpenPluginWindow(event, { url, name, pluginPath }) {
    devLog(`[IPC Main Handler] Handling request to open plugin window for ${name}`);
    
    const existingWindow = this.pluginWindows.get(name);
    if (existingWindow && !existingWindow.isDestroyed()) {
      devLog(`[IPC Main Handler] Plugin window for ${name} already exists, focusing it`);
      
      if (existingWindow.isMinimized()) {
        existingWindow.restore();
      }
      
      existingWindow.focus();
      
      if (this._window && this._window.webContents && !this._window.isDestroyed()) {
        this._window.webContents.send('plugin-window-focused', name);
      }
      
      return; 
    }
    
    devLog(`[IPC Main Handler] Creating new plugin window for ${name}`);

    const isDev = process.env.NODE_ENV === 'development';

    const configPath = path.join(pluginPath, 'plugin.json');
    let runInBackground = false;
    
    try {
      if (fs.existsSync(configPath)) {
        const pluginConfig = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        runInBackground = pluginConfig.runInBackground === true;
        
        if (runInBackground) {
          this._backgroundPlugins.add(name);
          devLog(`[IPC Main Handler] Plugin ${name} will run in background`);
        }
      }
    } catch (err) {
      devWarn(`[IPC Main Handler] Error checking if plugin should run in background: ${err.message}`);
    }

    const pluginWindow = new BrowserWindow({
      ...defaultWindowOptions,
      title: name,
      width: 800,
      height: 600,
      frame: false,
      webPreferences: {
        ...defaultWindowOptions.webPreferences,
        devTools: true, 
        nodeIntegration: true,
        contextIsolation: false,
        backgroundThrottling: !runInBackground 
      }
    });

    pluginWindow.webContents.on('console-message', (event, level, message) => {
      if (message.includes('%cElectron Security Warning') || 
          message.startsWith('Electron Security Warning')) {
        event.preventDefault();
        return;
      }
      
      if (message.includes('InvisibleToggle:') || 
          message.includes('InvisibleToggle loaded.')) {
        event.preventDefault();
        return;
      }
    });

    pluginWindow.loadURL(url);

    pluginWindow.webContents.on('did-finish-load', () => {
      devLog(`[IPC Main Handler] Plugin window ${name} loaded`);
      pluginWindow.focus(); 

      pluginWindow.webContents.executeJavaScript(`
        (function() {
          if (!window.jQuery) {
            var jQueryScript = document.createElement('script');
            jQueryScript.src = "https://code.jquery.com/jquery-3.6.0.min.js";
            jQueryScript.onload = function() {
              if (process.env.NODE_ENV === 'development') console.log("[Plugin Window] jQuery injected:", typeof window.$);
              
              if (typeof window.$.ui === 'undefined') { 
                var jQueryUIScript = document.createElement('script');
                jQueryUIScript.src = "https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js";
                jQueryUIScript.onload = function() {
                  if (process.env.NODE_ENV === 'development') console.log("[Plugin Window] jQuery UI injected.");
                };
                document.head.appendChild(jQueryUIScript);
              }
            };
            document.head.appendChild(jQueryScript);
          }
        })();
      `).then(() => {
          pluginWindow.webContents.executeJavaScript(`
            try {
              const { ipcRenderer } = require('electron');
              
              window.jam = window.jam || {};

              const dispatchObj = {
                sendRemoteMessage: function(msg) {
                  ipcRenderer.send('send-remote-message', msg);
                },
                sendConnectionMessage: function(msg) {
                  ipcRenderer.send('send-connection-message', msg);
                },
                getState: function(key) {
                  return ipcRenderer.invoke('dispatch-get-state', key);
                },
                getStateSync: function(key) {
                  return ipcRenderer.sendSync('dispatch-get-state-sync', key);
                },
                runInBackground: ${runInBackground}
              };

              const applicationObj = {
                consoleMessage: function(type, msg) {
                  if (process.env.NODE_ENV === 'development') console.log("[Plugin App Console] " + type + ": " + msg); 
                  ipcRenderer.send('console-message', { type, msg });
                }
              };

              window.jam.dispatch = dispatchObj;
              window.jam.application = applicationObj;

              window.jam.isAppMinimized = false;

              window.dispatchEvent(new CustomEvent('jam-ready'));
            } catch (err) {
              if (process.env.NODE_ENV === 'development') console.error("[Plugin Window] Error setting up window.jam:", err);
            }
          `);
      });
    });

    this.pluginWindows.set(name, pluginWindow);
    if (this._window && this._window.webContents && !this._window.isDestroyed()) {
      this._window.webContents.send('plugin-window-opened', name);
    }

    pluginWindow.on('closed', () => {
      devLog(`[IPC Main Handler] Plugin window ${name} closed`);
      if (!this._isQuitting) {
        if (this._window && !this._window.isDestroyed() && this._window.webContents && !this._window.webContents.isDestroyed()) {
          this._window.webContents.send('plugin-window-closed', name);
        }
      }
      this.pluginWindows.delete(name); 
      this._backgroundPlugins.delete(name); 
    });

    pluginWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription) => {
      if (isDevelopment) console.error(`[IPC Main Handler] Plugin window ${name} failed to load:`, errorDescription);
    });
  } 

  async getAppState() {
    console.log(`[State Helper] Reading app state from ${STATE_FILE_PATH}`);
    try {
      await fsPromises.access(STATE_FILE_PATH);
      const data = await fsPromises.readFile(STATE_FILE_PATH, 'utf-8');
      const currentState = JSON.parse(data);
      const mergedState = {
        ...DEFAULT_APP_STATE,
        ...currentState,
        leakCheck: { ...DEFAULT_APP_STATE.leakCheck, ...(currentState.leakCheck || {}) }
      };
      console.log('[State Helper] Successfully read and merged state file.');
      return mergedState;
    } catch (error) {
      if (error.code === 'ENOENT') {
        console.log('[State Helper] State file not found, returning default state.');
        return JSON.parse(JSON.stringify(DEFAULT_APP_STATE)); 
      }
      console.error('[State Helper] Error reading state file:', error);
      return JSON.parse(JSON.stringify(DEFAULT_APP_STATE)); 
    }
  }

  async setAppState(newState) {
     console.log(`[State Helper] Writing app state to ${STATE_FILE_PATH}`);
     try {
       await fsPromises.mkdir(USER_DATA_PATH, { recursive: true });
       await fsPromises.writeFile(STATE_FILE_PATH, JSON.stringify(newState, null, 2), 'utf-8');
       console.log('[State Helper] Successfully wrote state file.');
       return { success: true };
     } catch (error) {
       console.error('[State Helper] Error writing state file:', error);
       return { success: false, error: error.message };
     }
   }

  async _confirmNoOtherInstances(actionDescription) {
    const gotTheLock = app.requestSingleInstanceLock();
    if (gotTheLock) {
      app.releaseSingleInstanceLock();
      return true; 
    } else {
      const choice = await dialog.showMessageBox(this._window, {
        type: 'warning',
        title: 'Multiple Instances Detected',
        message: `It looks like another Strawberry Jam window is open.\n\nPlease close all other Strawberry Jam windows before attempting to ${actionDescription}.`,
        buttons: ['Cancel', 'I have closed other windows'],
        defaultId: 0, 
        cancelId: 0
      });
      return choice.response === 1; 
    }
  }
  _getCachePaths() {
    devLog('[Cache Paths] Getting specific cache paths...');
    const cachePaths = [];

    if (process.platform === 'win32') {
      // Clear the full Strawberry Jam app data directory
      const appDataPath = app.getPath('appData');
      cachePaths.push(path.join(appDataPath, 'strawberry-jam'));
      
      // Clear the AJ Classic directory
      cachePaths.push(path.join(appDataPath, 'AJ Classic'));
      
    } else if (process.platform === 'darwin') {
      // macOS paths
      const homeDir = app.getPath('home');
      const libraryPath = path.join(homeDir, 'Library', 'Application Support');
      cachePaths.push(path.join(libraryPath, 'strawberry-jam'));
      cachePaths.push(path.join(libraryPath, 'AJ Classic'));
      
    } else {
      console.warn('[Cache Paths] Unsupported platform for cache clearing:', process.platform);
    }

    devLog('[Cache Paths] Identified specific cache paths:', cachePaths);
    return cachePaths;
  }
  async _clearAppCache() {
    devLog('[Cache Clear Method] Starting cache clearing process...');
    const cachePaths = this._getCachePaths();

    let errors = [];
    for (const cachePath of cachePaths) {
      try {
        devLog(`[Cache Clear Method] Attempting to delete: ${cachePath}`);
        await fsPromises.rm(cachePath, { recursive: true, force: true });
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
      console.error('[Cache Clear Method] Finished with errors:', errors.join('; '));
    } else {
       devLog('[Cache Clear Method] Cache clearing process completed.');
    }
  }

  _getUninstallerPath() { 
    if (process.platform === 'win32') {
      const localAppData = app.getPath('home') + '\\AppData\\Local';
      return path.join(localAppData, 'Programs', 'strawberry-jam', 'Uninstall strawberry-jam.exe');
    } else if (process.platform === 'darwin') {
      console.warn('[Uninstall] Standard uninstaller executable not applicable on macOS.');
      return null;
    } else {
      console.warn('[Uninstall] Unsupported platform for uninstaller:', process.platform);
      return null;
    }
  }


  create () {
    const consoleLimit = this._store.get('logs.consoleLimit', 1000);
    const networkLimit = this._store.get('logs.networkLimit', 1000);

    logManager.initialize({
      appDataPath: app.getPath('userData'),
      consoleLimit: consoleLimit,
      networkLimit: networkLimit
    });

    const originalConsole = {
      log: console.log,
      error: console.error,
      warn: console.warn
    };

    console.log = (message) => logManager.log(message, 'main', logManager.logLevels.INFO);
    console.error = (message) => logManager.log(message, 'main', logManager.logLevels.ERROR);
    console.warn = (message) => logManager.log(message, 'main', logManager.logLevels.WARN);    console.log('Application starting');

    app.whenReady().then(async () => { 
      console.log('[Startup] Electron app ready, beginning startup sequence...');
      
      // Try to clear any problematic cache state early to prevent hangs
      try {
        devLog('[Startup] Attempting to clear potentially problematic cache...');
        await session.defaultSession.clearCache().catch(err => {
          devLog('[Startup] Cache clear failed (this is often normal):', err.message);
        });
      } catch (error) {
        devLog('[Startup] Cache operations not available yet, continuing...');
      }

      protocol.handle('app', (request) => {
        const url = request.url.slice('app://'.length)
        let filePath

        if (app.isPackaged) {
          filePath = path.join(process.resourcesPath, url)
        } else {
          filePath = path.normalize(`${__dirname}/../../${url}`)
        }
    devLog(`[Protocol Handler] Serving request for ${request.url} from ${filePath}`); 
    return net.fetch(`file://${filePath}`)
      })

      // Call _onReady which will now also register the IPC handler
      this._onReady()
      
      if (this._window) {
        this._window.on('enter-full-screen', () => {
          devLog('[Window Event] Entered fullscreen mode')
          this._window.webContents.send('fullscreen-changed', true)
        })
        
        this._window.on('leave-full-screen', () => {
          devLog('[Window Event] Left fullscreen mode')
          this._window.webContents.send('fullscreen-changed', false)
          
          if (this._savedWindowState) {
            devLog('[Window Event] Restoring window state:', this._savedWindowState)
            
            this._window.setBounds(this._savedWindowState.bounds)
            
            if (this._savedWindowState.isMaximized) {
              this._window.maximize()
            }
          }
        })
        
        this._window.on('maximize', () => {
          devLog('[Window Event] Window maximized')
          this._window.webContents.send('maximize-changed', true)
        })
        
        this._window.on('unmaximize', () => {
          devLog('[Window Event] Window unmaximized')
          this._window.webContents.send('maximize-changed', false)
        })
        
        this._window.on('minimize', () => {
          devLog('[Window Event] Window minimized')
          this._handleAppMinimized();
        })
        
        this._window.on('restore', () => {
          devLog('[Window Event] Window restored')
          this._handleAppRestored();
        })
        
        this._window.on('focus', () => {
          devLog('[Window Event] Window focused')
          this._handleAppRestored();
        })
      }
    })

    app.on('window-all-closed', () => {
      if (process.platform !== 'darwin') app.quit()
    })

    app.on('will-quit', async (event) => {
      console.log('[App Quit START] Entering will-quit handler.');
      if (this._isQuitting) {
        console.log('[App Quit] will-quit handler already running, skipping subsequent calls.');
        return;
      }
      this._isQuitting = true;

      event.preventDefault();
      console.log('[App Quit] Default quit prevented. Starting graceful shutdown.');

      try {
        console.log('[App Quit] Entering main cleanup try block.');
        if (this._isClearingCacheAndQuitting) {
          console.log('[App Quit] Manual cache clearing requested.');
          try {
            console.log('[App Quit] Clearing Electron session cache...');
            await session.defaultSession.clearCache();
            console.log('[App Quit] Session cache cleared.');
            console.log('[App Quit] Clearing Electron session storage data...');
            await session.defaultSession.clearStorageData({ storages: ['cookies', 'localstorage'] });
            console.log('[App Quit] Session storage data cleared.');

            const cachePaths = this._getCachePaths();
            if (cachePaths && cachePaths.length > 0) {
              let resolvedHelperPath;
              if (app.isPackaged) {
                resolvedHelperPath = path.join(process.resourcesPath, 'clear-cache-helper.js');
              } else {
                resolvedHelperPath = path.join(__dirname, 'clear-cache-helper.js');
              }
              devLog(`[App Quit] Resolved helper path for cache clearing: ${resolvedHelperPath}`);
              try {
                await fsPromises.access(resolvedHelperPath);
                const appExePath = app.getPath('exe');
                const helperArgs = [resolvedHelperPath, ...cachePaths, '--relaunch-after-clear', appExePath];
                console.log(`[App Quit] Spawning cache clear helper script detached: node ${helperArgs.join(' ')}`);
                const child = spawn('node', helperArgs, { detached: true, stdio: 'ignore' });
                child.on('error', (err) => { console.error('[App Quit] Failed to spawn cache clear helper script:', err); });
                child.unref();
                console.log('[App Quit] Cache clear helper script spawned detached.');
              } catch (helperError) {
                console.error(`[App Quit] Failed to find or spawn cache clear helper script (${resolvedHelperPath}):`, helperError);
              }
            } else {
              devLog('[App Quit] Could not determine cache paths for manual clear. Skipping helper script.');
            }
          } catch (clearError) {
            console.error('[App Quit] Error during manual cache clearing:', clearError);
          }
        }

        console.log('[App Quit] Performing other general cleanup...');

        if (this._apiProcess && !this._apiProcess.killed) {
          console.log('[App Quit API] Attempting to terminate API process...');
          this._apiProcess.kill(); // Default SIGTERM
          // Add a small delay or check for exit event if issues persist
          console.log('[App Quit API] API process kill signal sent.');
        } else if (this._apiProcess && this._apiProcess.killed) {
          console.log('[App Quit API] API process already reported as killed.');
        } else {
          console.log('[App Quit API] API process not found or not active.');
        }
        console.log('[App Quit] General cleanup finished.');

        console.log('[App Quit] Main cleanup try block finished.');
        console.log('[App Quit END] All cleanup initiated, calling app.quit() to proceed with termination.');
        app.quit();
      } catch (error) {
        console.error('[App Quit ERROR] Error during will-quit handler execution:', error);
        console.log('[App Quit ERROR] Error occurred, forcing exit with app.exit(1).');
        app.exit(1);
      }
    });


    return this
  }

  _registerShortcut (key, callback) {
    globalShortcut.register(key, callback)
  }

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

  _initAutoUpdater () {
    autoUpdater.setFeedURL({
      provider: 'github',
      owner: 'glvckoma',
      repo: 'Strawberry-Jam'
    });
    const enableAutoUpdates = this._store.get('updates.enableAutoUpdates', true);

    autoUpdater.autoDownload = enableAutoUpdates; // Set based on setting
    autoUpdater.allowDowngrade = true
    autoUpdater.allowPrerelease = false

    if (enableAutoUpdates) {
      console.log('[Updater] Automatic updates enabled. Scheduling checks.');
      const checkInterval = 1000 * 60 * 5;
      setTimeout(() => {
        autoUpdater.checkForUpdates().catch(err => {
          console.error('[Updater] Error during scheduled update check (setTimeout):', err.message);
          // Optionally send an IPC message to renderer about this specific error
          if (this._window && this._window.webContents && !this._window.isDestroyed()) {
            this._window.webContents.send('app-update-status', { status: 'error', message: `Scheduled update check failed: ${err.message}` });
          }
        });
      }, 5000);
      setInterval(() => {
        autoUpdater.checkForUpdates().catch(err => {
          console.error('[Updater] Error during scheduled update check (setInterval):', err.message);
          if (this._window && this._window.webContents && !this._window.isDestroyed()) {
            this._window.webContents.send('app-update-status', { status: 'error', message: `Scheduled update check failed: ${err.message}` });
          }
        });
      }, checkInterval);
    } else {
      console.log('[Updater] Automatic updates disabled by setting.');
    }

    autoUpdater.on('checking-for-update', () => {
      console.log('[Updater] Checking for update...');
      if (this.manualCheckInProgress && this._window && this._window.webContents && !this._window.isDestroyed()) {
        this._window.webContents.send('manual-update-check-status', { status: 'checking', message: 'Checking for updates...' });
      }
      // Global toast via 'app-update-status' removed
    })

    autoUpdater.on('update-not-available', (info) => {
      console.log('[Updater] Update not available.', info);
      if (this.manualCheckInProgress && this._window && this._window.webContents && !this._window.isDestroyed()) {
        this._window.webContents.send('manual-update-check-status', { status: 'no-update', message: 'No new updates available.' });
        this.manualCheckInProgress = false; // Reset flag
      }
      // Global toast via 'app-update-status' removed
    })

    autoUpdater.on('error', (err) => {
      console.error('[Updater] Error in auto-updater.', err);
      if (this.manualCheckInProgress && this._window && this._window.webContents && !this._window.isDestroyed()) {
        this._window.webContents.send('manual-update-check-status', { status: 'error', message: `Error checking for updates: ${err.message}` });
        this.manualCheckInProgress = false; // Reset flag
      }
      // Global toast via 'app-update-status' removed
    })

    autoUpdater.on('update-available', (info) => {
      console.log('[Updater] Update available.', info);
      const messageText = autoUpdater.autoDownload
        ? 'A new update is available. Downloading now...' // This will only happen if enableAutoUpdates is true
        : 'A new update is available. Click "Update Now" to download.'; // For manual checks or if autoDownload is off
      if (this.manualCheckInProgress && this._window && this._window.webContents && !this._window.isDestroyed()) {
        this._window.webContents.send('manual-update-check-status', { status: 'available', message: messageText, version: info.version });
        // Do not reset manualCheckInProgress here, wait for download or error
      }
      // Global toast via 'app-update-status' removed
    })

    autoUpdater.on('update-downloaded', (info) => {
      console.log('[Updater] Update downloaded.', info);
      if (this.manualCheckInProgress && this._window && this._window.webContents && !this._window.isDestroyed()) {
        this._window.webContents.send('manual-update-check-status', { status: 'downloaded', message: 'Update downloaded. Click "Restart Now" to install.' });
        this.manualCheckInProgress = false; // Reset flag
      }
      // Global toast via 'app-update-status' removed
    })
  }

  messageWindow (type, message = {}) {
    if (this._window && this._window.webContents) {
      this._window.webContents.send(type, message)
    }
  }

  async _onReady () {
    // --- REGISTER IPC HANDLER HERE using ipcMain.on and event.sender.send ---
    ipcMain.on('request-main-log-path', (event) => { // Listening for the request
      global.console.log('[IPC Main _onReady] DIAGNOSTIC: "request-main-log-path" (ipcMain.on) handler invoked.');
      const pathToSend = (logManager && logManager.logPath) ? logManager.logPath : "dummy/path/from/_onReady/sender_send_handler";
      global.console.log(`[IPC Main _onReady] DIAGNOSTIC: (ipcMain.on) Sending "response-main-log-path" with path: ${pathToSend}`);
      if (event.sender && !event.sender.isDestroyed()) {
        event.sender.send('response-main-log-path', pathToSend); // Sending reply on new channel
      } else {
        global.console.error('[IPC Main _onReady] DIAGNOSTIC: event.sender is not available or destroyed for "request-main-log-path".');
      }
    });
    global.console.log('[IPC Main _onReady Setup] DIAGNOSTIC: Attempted to register "request-main-log-path" (ipcMain.on) handler within _onReady.');
    // --- END IPC HANDLER REGISTRATION ---

    const windowOptions = { ...defaultWindowOptions };
    
    this._window = new BrowserWindow(windowOptions);
    
    const { screen } = require('electron');
    const primaryDisplay = screen.getPrimaryDisplay();
    const { width, height } = primaryDisplay.workAreaSize;
    
    const newWidth = Math.floor(width * 0.57);  
    const newHeight = Math.floor(height * 0.8);
    
    const x = Math.floor((width - newWidth) / 2);
    const y = Math.floor((height - newHeight) / 2);
    
    this._window.setBounds({
      x,
      y,
      width: newWidth,
      height: newHeight
    });
    
    this._window.webContents.on('console-message', (event, level, message) => {
      if (message.includes('%cElectron Security Warning') || 
          message.startsWith('Electron Security Warning')) {
        event.preventDefault();
        return;
      }
      
      if (message.includes('InvisibleToggle:') || 
          message.includes('InvisibleToggle loaded.')) {
        event.preventDefault();
        return;
      }
    });
    
    const dataPath = getDataPath(app);
    devLog(`[Main] Calculated data path: ${dataPath}`);
    
    // Note: loadFile is already promise-based, no fsPromises needed here.
    await this._window.loadFile(path.join(__dirname, 'renderer', 'index.html'))
    
    this._window.webContents.send('set-data-path', dataPath);
    devLog(`[Main] Sent data path to renderer: ${dataPath}`);
    
    this._window.webContents.setWindowOpenHandler((details) => this._createWindow(details))

    this._window.on('closed', () => {
      devLog('[Main Window Closed START] Main window has been closed. Processing related cleanup.');
      const mainWindowId = this._window ? this._window.id : -1; // Should be null here, but good for clarity

      devLog('[Main Window Closed] Attempting to close/destroy all other plugin windows...');
      let closedCount = 0;
      BrowserWindow.getAllWindows().forEach(win => {
        // Check if it's not the main window (which is already closing/closed)
        // and ensure it's not already destroyed.
        if (win && typeof win.id === 'number' && win.id !== mainWindowId && !win.isDestroyed()) {
          devLog(`[Main Window Closed] Destroying plugin window: ${win.getTitle()} (ID: ${win.id})`);
          try {
            win.destroy(); // More forceful than close()
            closedCount++;
          } catch (e) {
            console.error(`[Main Window Closed] Error destroying plugin window ${win.getTitle()}:`, e);
          }
        }
      });
      devLog(`[Main Window Closed] Finished attempting to destroy plugin windows. Count: ${closedCount}`);

      if (this.pluginWindows) {
        devLog(`[Main Window Closed] Clearing pluginWindows map (size before: ${this.pluginWindows.size})`);
        this.pluginWindows.clear();
        devLog(`[Main Window Closed] pluginWindows map cleared (size after: ${this.pluginWindows.size})`);
      }
      if (this._backgroundPlugins) {
        devLog(`[Main Window Closed] Clearing _backgroundPlugins set (size before: ${this._backgroundPlugins.size})`);
        this._backgroundPlugins.clear();
        devLog(`[Main Window Closed] _backgroundPlugins set cleared (size after: ${this._backgroundPlugins.size})`);
      }
      
      this._window = null;
      devLog('[Main Window Closed END] Main window reference nulled and cleanup finished.');
    });

    try {
      const dataPath = getDataPath(app); 
      await fsPromises.mkdir(dataPath, { recursive: true });
      devLog(`[Startup] Ensured data directory exists: ${dataPath}`);
    } catch (error) {
      console.error(`[Startup] Error ensuring base data directory:`, error);
      dialog.showErrorBox('Startup Error', `Failed to create base data directory. Some features might not work correctly.\n\nError: ${error.message}`);
    }    if (app.isPackaged) {
      devLog('[Startup] Packaged app detected. Ensuring specific data files exist...');
      const dataPath = getDataPath(app); 
      const filesToEnsure = [
        'working_accounts.txt',
        'collected_usernames.txt',
        'processed_usernames.txt',
        'potential_accounts.txt',
        'found_accounts.txt',
        'ajc_accounts.txt'
      ];

      try {
        await fsPromises.mkdir(dataPath, { recursive: true });
        devLog(`[Startup] Ensured data directory exists: ${dataPath}`);

        // Create all files in parallel for better performance
        const fileCreationPromises = filesToEnsure.map(async (filename) => {
          const filePath = path.join(dataPath, filename);
          try {
            await fsPromises.access(filePath); 
            devLog(`[Startup] File already exists: ${filePath}`);
          } catch (accessError) {
            if (accessError.code === 'ENOENT') {
              devLog(`[Startup] Creating empty file: ${filePath}`);
              await fsPromises.writeFile(filePath, '', 'utf-8');
            } else {
              console.warn(`[Startup] Warning: Could not access ${filePath}:`, accessError.message);
            }
          }
        });

        // Wait for all file operations to complete, but with a timeout
        await Promise.all(fileCreationPromises).catch((error) => {
          console.warn('[Startup] Some file operations failed, but continuing startup:', error.message);
        });
      } catch (error) {
        console.error(`[Startup] Error ensuring data directory/files at ${dataPath}:`, error);
        dialog.showErrorBox('Startup Error', `Failed to create necessary data files in ${dataPath}. Some features might not work correctly.\n\nError: ${error.message}`);
      }    }
    
    // Fork API process with timeout and error handling
    console.log('[Startup] Starting API server process...');
    try {
      this._apiProcess = fork(path.join(__dirname, '..', 'api', 'index.js'), [], {
        silent: false // Allow child process to log to console
      });

      // Set up API process event handlers
      this._apiProcess.on('error', (error) => {
        console.error('[API Process] Failed to start or crashed:', error.message);
      });

      this._apiProcess.on('exit', (code, signal) => {
        if (code !== 0) {
          console.warn(`[API Process] Exited with code ${code} and signal ${signal}`);
        }
      });

      // Give API process a moment to start, but don't block the main startup
      setTimeout(() => {
        if (this._apiProcess && !this._apiProcess.killed) {
          console.log('[Startup] API server process appears to be running successfully');
        }
      }, 1000);
      
    } catch (error) {
      console.error('[Startup] Failed to fork API process:', error.message);
      // Continue startup even if API process fails - most functionality doesn't depend on it
    }

    if (isDevelopment) {
      this._registerShortcut('F11', () => {
        const focusedWindow = BrowserWindow.getFocusedWindow();
        if (focusedWindow && focusedWindow.webContents) {
          focusedWindow.webContents.toggleDevTools();
        }
      })
    }


    // Always initialize the auto-updater to set feed URL and listeners.
    // _initAutoUpdater internally respects 'updates.enableAutoUpdates' for scheduling automatic checks.
    console.log('[Updater] Initializing auto-updater system (setting feed URL and listeners)...');
    this._initAutoUpdater();

    // Then, if performServerCheckOnLaunch is true, trigger an initial check.
    const performServerCheckOnLaunch = this._store.get('ui.performServerCheckOnLaunch', true);
    if (performServerCheckOnLaunch) {
      console.log('[Updater] Performing initial update check on launch (ui.performServerCheckOnLaunch is true).');
      autoUpdater.checkForUpdates().catch(err => {
        console.error('[Updater] Error during initial launch update check:', err.message);
        // No global toast here. Console log is sufficient for background checks.
      });
    } else {
      console.log('[Updater] Skipping initial update check on launch (ui.performServerCheckOnLaunch is false).');
    }
  }

  _handleAppMinimized() {
    devLog('[Window Event] Main window minimized, updating plugin windows');
    
    this.pluginWindows.forEach((window, name) => {
      if (!window.isDestroyed()) {
        try {
          window.webContents.executeJavaScript('window.jam.isAppMinimized = true;');
          
          if (this._backgroundPlugins.has(name)) {
            this._enableBackgroundProcessing(window, name);
          }
        } catch (err) {
          devWarn(`[Window Event] Error updating minimized state for plugin ${name}: ${err.message}`);
        }
      }
    });
    
    this._window.webContents.send('app-minimized');
  }
  
  _enableBackgroundProcessing(window, name) {
    devLog(`[Background Processing] Enabling background processing for plugin: ${name}`);
    
    try {
      if (window.webContents && !window.webContents.isDestroyed()) {
        window.webContents.backgroundThrottling = false;
      }
      
      window.webContents.executeJavaScript(`
        (function() {
          if (!window._backgroundKeepAliveInterval) {
            window._backgroundKeepAliveInterval = setInterval(() => {
              if (typeof window.jam !== 'undefined' && window.jam.dispatch && window.jam.dispatch.runInBackground) {
                window.dispatchEvent(new CustomEvent('jam-background-tick', { 
                  detail: { timestamp: Date.now() } 
                }));
                
                if (Date.now() % 10000 < 1000) {
                  console.log('[Background Processing] Plugin ${name} is running in background mode');
                }
              }
            }, 1000);
            
            console.log('[Background Processing] Background keep-alive enabled for plugin ${name}');
          }
        })();
      `).catch(err => {
        devWarn(`[Background Processing] Error setting up background processing for ${name}: ${err.message}`);
      });
    } catch (err) {
      devWarn(`[Background Processing] Failed to enable background processing for ${name}: ${err.message}`);
    }
  }

  _handleAppRestored() {
    devLog('[Window Event] Main window restored, updating plugin windows');
    
    this.pluginWindows.forEach((window, name) => {
      if (!window.isDestroyed()) {
        try {
          window.webContents.executeJavaScript('window.jam.isAppMinimized = false;');
          
          window.webContents.executeJavaScript(`
            window.dispatchEvent(new CustomEvent('jam-foreground', { 
              detail: { timestamp: Date.now() } 
            }));
          `).catch(err => {
            devWarn(`[Window Event] Error dispatching foreground event for plugin ${name}: ${err.message}`);
          });
        } catch (err) {
          devWarn(`[Window Event] Error updating restored state for plugin ${name}: ${err.message}`);
        }
      }
    });
    
    this._window.webContents.send('app-restored');
  }
}

// This was the old location of the _setupIPC() internal 'get-main-log-path' handler.
// It's now registered directly in _onReady.

ipcMain.on('packet-event', (event, packetData) => {
  const windows = BrowserWindow.getAllWindows();
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

ipcMain.on('plugin-remote-message', (event, msg) => { // Changed channel name here
  console.log(`[IPC Main] Received plugin-remote-message: ${msg}`); // Changed devLog to console.log for visibility and added msg content
  const mainWindow = BrowserWindow.getAllWindows().find(win =>
    win.webContents && !win.webContents.isDestroyed() && win.webContents.getURL().includes('renderer/index.html')
  );
  if (mainWindow && mainWindow.webContents) {
    console.log(`[IPC Main] Forwarding plugin-remote-message to main window: ${mainWindow.getTitle()}`);
    mainWindow.webContents.send('plugin-remote-message', msg); // Forwarding channel remains the same
  } else {
    console.error('[IPC Main] Could not find main window to forward plugin-remote-message.');
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

ipcMain.on('dispatch-get-state-sync', (event, key) => {
  const mainWindow = BrowserWindow.getAllWindows().find(win =>
    win.webContents.getURL().includes('renderer/index.html')
  );

  if (!mainWindow || !mainWindow.webContents) {
    devLog(`[IPC Main] Cannot handle dispatch-get-state-sync: Main window not found`); 
    event.returnValue = null;
    return;
  }

  if (key === 'room') {
    if (global.cachedRoomState !== undefined) {
      event.returnValue = global.cachedRoomState;
    } else {
      devLog(`[IPC Main] No cached room state available, returning null`); 
      event.returnValue = null;
    }
  } else {
    devLog(`[IPC Main] Cannot get state synchronously for key: ${key}`); 
    event.returnValue = null;
  }
});

ipcMain.on('update-room-state', (event, roomState) => {
  devLog(`[IPC Main] Updating cached room state: ${roomState}`); 
  global.cachedRoomState = roomState;
});

module.exports = Electron
