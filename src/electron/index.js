const { app, BrowserWindow, globalShortcut, shell, ipcMain, protocol, net, dialog, session } = require('electron');
const path = require('path');
const fs = require('fs'); // Changed to import standard fs module
const fsPromises = fs.promises; // Alias for promises API
const crypto = require('crypto');
const { fork, spawn } = require('child_process');
const { autoUpdater } = require('electron-updater');
const Store = require('electron-store');
const os = require('os');
const processManager = require('../utils/ProcessManager');
const setupIpcHandlers = require('./ipcHandlers');
// const keytar = require('keytar'); // Will be required in constructor

// Suppress Electron security warnings
process.env.ELECTRON_DISABLE_SECURITY_WARNINGS = 'true';

// Keytar service name for Leak Checker API Key
let KEYTAR_SERVICE_LEAK_CHECK_API_KEY;
const KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY = 'leak_checker_api_key';
const MIGRATION_FLAG_LEAK_CHECK_API_KEY_V1 = 'leakCheckApiKeyMigratedToKeytar_v1';

const Patcher = require('./renderer/application/patcher');
const { getDataPath, getAssetsPath } = require('../Constants');
const logManager = require('../utils/LogManager');

const isDevelopment = process.env.NODE_ENV === 'development'

// Helper: Only log in development
function devLog(...args) {}
function devWarn(...args) {}
const USER_DATA_PATH = app.getPath('userData');
const STATE_FILE_PATH = path.join(USER_DATA_PATH, 'jam_state.json');

const STRAWBERRY_JAM_CLASSIC_BASE_PATH = process.platform === 'win32'
  ? path.join(os.homedir(), 'AppData', 'Local', 'Programs', 'strawberry-jam-classic')
  : process.platform === 'darwin'
    ? path.join('/', 'Applications', 'Strawberry Jam Classic.app', 'Contents')
    : undefined;

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
  },
  game: {
    type: 'object',
    properties: {
      // Removed selectedSwfFile since we use file replacement strategy
    },
    additionalProperties: true
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
  }
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

    // Handler registration moved to _onReady for later initialization.
    // global.console.log('[IPC Main CONSTRUCTOR Setup] DIAGNOSTIC: "get-main-log-path" handler registration REMOVED from constructor start.');

    this._migrateLeakCheckApiKeyToKeytar().catch(err => {
      console.error('[Migration] Error during leak check API key migration:', err);
    });

    this._patcher = null;
    this._isQuitting = false;
    this._isClearingCacheAndQuitting = false;
    this._savedWindowState = null;
    setupIpcHandlers(this); // Call the new IPC setup function
    this.pluginWindows = new Map();
    this._backgroundPlugins = new Set();
    this._setupFileOpeningIPC(); // Add this line
    this.manualCheckInProgress = false; // Flag for manual update checks

    ipcMain.on('broadcast-to-plugins', (event, channel, ...args) => {
      this.pluginWindows.forEach((window) => {
        if (window && !window.isDestroyed()) {
          window.webContents.send(channel, ...args);
        }
      });
    });
  }

  async _migrateLeakCheckApiKeyToKeytar() {
    if (this._store.get(MIGRATION_FLAG_LEAK_CHECK_API_KEY_V1)) {
      return;
    }

    const oldApiKey = this._store.get('leakCheck.apiKey');

    if (oldApiKey && typeof oldApiKey === 'string' && oldApiKey.trim() !== '') {
      try {
        await this.keytar.setPassword(KEYTAR_SERVICE_LEAK_CHECK_API_KEY, KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY, oldApiKey);
        this._store.set('leakCheck.apiKey', '');
        this._store.set(MIGRATION_FLAG_LEAK_CHECK_API_KEY_V1, true);
      } catch (err) {
        if (isDevelopment) console.error(`[Migration LeakCheck][Keytar] Stack: ${err.stack}`);
      }
    } else {
      this._store.set(MIGRATION_FLAG_LEAK_CHECK_API_KEY_V1, true);
    }
  }

  _handleOpenPluginWindow(event, { url, name, pluginPath }) {
    
    const existingWindow = this.pluginWindows.get(name);
    if (existingWindow && !existingWindow.isDestroyed()) {
      
      if (existingWindow.isMinimized()) {
        existingWindow.restore();
      }
      
      existingWindow.focus();
      
      if (this._window && this._window.webContents && !this._window.isDestroyed()) {
        this._window.webContents.send('plugin-window-focused', name);
      }
      
      return;
    }
    
    const isDev = process.env.NODE_ENV === 'development';

    const configPath = path.join(pluginPath, 'plugin.json');
    let runInBackground = false;
    
    try {
      if (fs.existsSync(configPath)) {
        const pluginConfig = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        runInBackground = pluginConfig.runInBackground === true;
        
        if (runInBackground) {
          this._backgroundPlugins.add(name);
        }
      }
    } catch (err) {
    }

    const pluginWindow = new BrowserWindow({
      ...defaultWindowOptions,
      title: name,
      width: 800,
      height: 600,
      frame: false,
      icon: path.join(getAssetsPath(app), 'images', 'icon.png'), // Set the icon for plugin windows
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
      if (!this._isQuitting) {
        if (this._window && !this._window.isDestroyed() && this._window.webContents && !this._window.webContents.isDestroyed()) {
          this._window.webContents.send('plugin-window-closed', name);
        }
      }
      this.pluginWindows.delete(name);
      this._backgroundPlugins.delete(name);
    });

    pluginWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription) => {
    });
  } 

  async getAppState() {
    try {
      await fsPromises.access(STATE_FILE_PATH);
      const data = await fsPromises.readFile(STATE_FILE_PATH, 'utf-8');
      const currentState = JSON.parse(data);
      const mergedState = {
        ...DEFAULT_APP_STATE,
        ...currentState,
        leakCheck: { ...DEFAULT_APP_STATE.leakCheck, ...(currentState.leakCheck || {}) }
      };
      return mergedState;
    } catch (error) {
      if (error.code === 'ENOENT') {
        return JSON.parse(JSON.stringify(DEFAULT_APP_STATE));
      }
      return JSON.parse(JSON.stringify(DEFAULT_APP_STATE));
    }
  }

  async setAppState(newState) {
     try {
       await fsPromises.mkdir(USER_DATA_PATH, { recursive: true });
       await fsPromises.writeFile(STATE_FILE_PATH, JSON.stringify(newState, null, 2), 'utf-8');
       return { success: true };
     } catch (error) {
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
    }

    return cachePaths;
  }
  async _clearAppCache() {
    const cachePaths = this._getCachePaths();

    let errors = [];
    for (const cachePath of cachePaths) {
      try {
        await fsPromises.rm(cachePath, { recursive: true, force: true });
      } catch (error) {
        if (error.code === 'ENOENT') {
        } else {
          console.error(`[Cache Clear Method] Failed to delete ${cachePath}:`, error);
          errors.push(`Failed to delete ${path.basename(cachePath)}: ${error.message}`);
        }
      }
    }

    if (errors.length > 0) {
      console.error('[Cache Clear Method] Finished with errors:', errors.join('; '));
    } else {
    }
  }

  _getUninstallerPath() {
    if (process.platform === 'win32') {
      const localAppData = app.getPath('localAppData');
      return path.join(localAppData, 'Programs', 'strawberry-jam', 'Uninstall strawberry-jam.exe');
    } else if (process.platform === 'darwin') {
      return null;
    } else {
        return null;
      }
    }
  
  
    create () {
      const consoleLimit = this._store.get('logs.consoleLimit', 1000);
      const networkLimit = this._store.get('logs.networkLimit', 1000);
  
      logManager.initialize({
        appDataPath: app.getPath('userData'),
        maxMemoryLogs: consoleLimit
      });
  
      const originalConsole = {
        log: console.log,
        error: console.error,
        warn: console.warn
      };
  
      console.log = (message) => logManager.log(message, 'main', logManager.logLevels.INFO);
      console.error = (message) => logManager.log(message, 'main', logManager.logLevels.ERROR);
      console.warn = (message) => logManager.log(message, 'main', logManager.logLevels.WARN);
  
      app.whenReady().then(async () => {
        // Try to clear any problematic cache state early to prevent hangs
      try {
        await session.defaultSession.clearCache().catch(err => {
        });
      } catch (error) {
      }

      protocol.handle('app', (request) => {
        const url = request.url.slice('app://'.length);
        const assetsPath = getAssetsPath(app);
        let filePath;
      
        if (url.startsWith('assets/')) {
          filePath = path.join(assetsPath, url.substring('assets/'.length));
        } else {
          filePath = path.normalize(`${__dirname}/../../${url}`);
        }
      
        return net.fetch(`file://${filePath}`);
      });

      // Call _onReady which will now also register the IPC handler
      this._onReady()
      
      if (this._window) {
        this._window.on('enter-full-screen', () => {
          this._window.webContents.send('fullscreen-changed', true)
        })
        
        this._window.on('leave-full-screen', () => {
          this._window.webContents.send('fullscreen-changed', false)
          
          if (this._savedWindowState) {
            this._window.setBounds(this._savedWindowState.bounds)
            
            if (this._savedWindowState.isMaximized) {
              this._window.maximize()
            }
          }
        })
        
        this._window.on('maximize', () => {
          this._window.webContents.send('maximize-changed', true)
        })
        
        this._window.on('unmaximize', () => {
          this._window.webContents.send('maximize-changed', false)
        })
        
        this._window.on('minimize', () => {
          this._handleAppMinimized();
        })
        
        this._window.on('restore', () => {
          this._handleAppRestored();
        })
        
        this._window.on('focus', () => {
          this._handleAppRestored();
        })
      }
    })

    app.on('window-all-closed', () => {
      if (process.platform !== 'darwin') app.quit()
    })


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
    if (!app.isPackaged) {
      console.log('[AutoUpdater] Skipping auto-updater initialization in development mode.');
      return;
    }
    
    const enableAutoUpdates = this._store.get('updates.enableAutoUpdates', true);
    autoUpdater.autoDownload = enableAutoUpdates;
    autoUpdater.allowDowngrade = false;
    autoUpdater.allowPrerelease = false;

    autoUpdater.on('checking-for-update', () => {
      console.log('[AutoUpdater] Checking for update...');
      if (this.manualCheckInProgress && this._window && this._window.webContents && !this._window.isDestroyed()) {
        this._window.webContents.send('manual-update-check-status', { status: 'checking', message: 'Checking for updates...' });
      }
    });

    autoUpdater.on('update-not-available', (info) => {
      console.log('[AutoUpdater] Update not available.');
      if (this.manualCheckInProgress && this._window && this._window.webContents && !this._window.isDestroyed()) {
        this._window.webContents.send('manual-update-check-status', { status: 'no-update', message: 'No new updates available.' });
        this.manualCheckInProgress = false;
      }
    });

    autoUpdater.on('error', (err) => {
      console.error('[AutoUpdater] Error:', err.message);
      if (this.manualCheckInProgress && this._window && this._window.webContents && !this._window.isDestroyed()) {
        this._window.webContents.send('manual-update-check-status', { status: 'error', message: `Error checking for updates: ${err.message}` });
        this.manualCheckInProgress = false;
      }
    });

    autoUpdater.on('update-available', (info) => {
      console.log(`[AutoUpdater] Update available: ${info.version}`);
      const messageText = autoUpdater.autoDownload
        ? 'A new update is available. Downloading now...'
        : 'A new update is available. Click "Update Now" to download.';
      if (this.manualCheckInProgress && this._window && this._window.webContents && !this._window.isDestroyed()) {
        this._window.webContents.send('manual-update-check-status', { status: 'available', message: messageText, version: info.version });
      }
    });

    autoUpdater.on('update-downloaded', (info) => {
      console.log(`[AutoUpdater] Update downloaded: ${info.version}`);
      if (this.manualCheckInProgress && this._window && this._window.webContents && !this._window.isDestroyed()) {
        this._window.webContents.send('manual-update-check-status', { status: 'downloaded', message: 'Update downloaded. Click "Restart Now" to install.' });
        this.manualCheckInProgress = false;
      }
    });

    if (enableAutoUpdates) {
      const checkInterval = 1000 * 60 * 5; // 5 minutes
      setTimeout(() => {
        autoUpdater.checkForUpdatesAndNotify().catch(err => {
          console.error('[AutoUpdater] Initial check failed:', err.message);
        });
      }, 5000); // Initial check after 5 seconds
      
      setInterval(() => {
        autoUpdater.checkForUpdatesAndNotify().catch(err => {
          console.error('[AutoUpdater] Scheduled check failed:', err.message);
        });
      }, checkInterval);
    }
  }

  messageWindow (type, message = {}) {
    if (this._window && this._window.webContents) {
      this._window.webContents.send(type, message)
    }
  }

  async _onReady () {
    // --- REGISTER IPC HANDLER HERE using ipcMain.on and event.sender.send ---
    ipcMain.on('request-main-log-path', (event) => { // Listening for the request
      const pathToSend = (logManager && logManager.logPath) ? logManager.logPath : "dummy/path/from/_onReady/sender_send_handler";
      if (event.sender && !event.sender.isDestroyed()) {
        event.sender.send('response-main-log-path', pathToSend); // Sending reply on new channel
      } else {
      }
    });
    // --- END IPC HANDLER REGISTRATION ---

    this._patcher = new Patcher(null, getAssetsPath(app));
    const windowOptions = {
      ...defaultWindowOptions,
      icon: path.join(getAssetsPath(app), 'images', 'icon.png')
    };
    
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
    
    // Note: loadFile is already promise-based, no fsPromises needed here.
    await this._window.loadFile(path.join(__dirname, 'renderer', 'index.html'))

    const assetsPath = getAssetsPath(app)
    
    this._window.webContents.send('set-data-path', dataPath)
    this._window.webContents.send('set-assets-path', assetsPath)
    this._window.webContents.send('set-user-data-path', USER_DATA_PATH)
    
    this._window.webContents.setWindowOpenHandler((details) => this._createWindow(details))

    this._window.on('closed', () => {
      const mainWindowId = this._window ? this._window.id : -1; // Should be null here, but good for clarity

      let closedCount = 0;
      BrowserWindow.getAllWindows().forEach(win => {
        // Check if it's not the main window (which is already closing/closed)
        // and ensure it's not already destroyed.
        if (win && typeof win.id === 'number' && win.id !== mainWindowId && !win.isDestroyed()) {
          try {
            win.destroy(); // More forceful than close()
            closedCount++;
          } catch (e) {
            console.error(`[Main Window Closed] Error destroying plugin window ${win.getTitle()}:`, e);
          }
        }
      });

      if (this.pluginWindows) {
        this.pluginWindows.clear();
      }
      if (this._backgroundPlugins) {
        this._backgroundPlugins.clear();
      }
      
      this._window = null;
    });

    try {
      const dataPath = getDataPath(app);
      await fsPromises.mkdir(dataPath, { recursive: true });
    } catch (error) {
      dialog.showErrorBox('Startup Error', `Failed to create base data directory. Some features might not work correctly.\n\nError: ${error.message}`);
    }    if (app.isPackaged) {
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

        // Create all files in parallel for better performance
        const fileCreationPromises = filesToEnsure.map(async (filename) => {
          const filePath = path.join(dataPath, filename);
          try {
            await fsPromises.access(filePath);
          } catch (accessError) {
            if (accessError.code === 'ENOENT') {
              await fsPromises.writeFile(filePath, '', 'utf-8');
            } else {
            }
          }
        });

        // Wait for all file operations to complete, but with a timeout
        await Promise.all(fileCreationPromises).catch((error) => {
        });
      } catch (error) {
        dialog.showErrorBox('Startup Error', `Failed to create necessary data files in ${dataPath}. Some features might not work correctly.\n\nError: ${error.message}`);
      }    }
    
    // Fork API process with timeout and error handling
    try {
      this._apiProcess = fork(path.join(__dirname, '..', 'api', 'index.js'), [], {
        silent: false // Allow child process to log to console
      });
      processManager.add(this._apiProcess);

      // Set up API process event handlers
      this._apiProcess.on('error', (error) => {
      });

      this._apiProcess.on('exit', (code, signal) => {
        if (code !== 0) {
        }
      });

      // Listen for messages from API process
      this._apiProcess.on('message', (message) => {
        if (message && message.type === 'aj-classic-closing') {
          logManager.log('[AJ Classic Close] Received notification from API process that AJ Classic is closing, closing all plugins', 'main', logManager.logLevels.INFO);
          
          // Close all plugin windows
          if (this.pluginWindows) {
            this.pluginWindows.forEach((window, name) => {
              if (window && !window.isDestroyed()) {
                try {
                  logManager.log(`[AJ Classic Close] Closing plugin window: ${name}`, 'main', logManager.logLevels.INFO);
                  window.close();
                } catch (error) {
                  logManager.error(`[AJ Classic Close] Error closing plugin window ${name}: ${error.message}`);
                }
              }
            });
            
            // Clear the plugin windows map
            this.pluginWindows.clear();
            this._backgroundPlugins.clear();
            
            // Notify the main window that plugins were closed
            if (this._window && !this._window.isDestroyed()) {
              this._window.webContents.send('plugins-closed-by-aj-classic');
            }
          }
        }
      });

      // Give API process a moment to start, but don't block the main startup
      setTimeout(() => {
        if (this._apiProcess && !this._apiProcess.killed) {
        }
      }, 1000);
      
    } catch (error) {
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


    this._initAutoUpdater();

    // Apply SWF on launch if enabled
    try {
      const autoReapply = this._store.get('game.autoReapplySwfOnLaunch');
      if (autoReapply) {
        const selectedFile = this._store.get('game.selectedSwfFile');
        if (selectedFile) {
          logManager.log(`[Auto Reapply] Auto-reapplying SWF file: ${selectedFile}`, 'main', logManager.logLevels.INFO);
          const FilesController = require('../api/controllers/FilesController');
          FilesController.replaceSwfFile(selectedFile);
        }
      }
    } catch (error) {
      console.error('Error applying SWF on launch:', error);
    }
  }

  _handleAppMinimized() {
    this.pluginWindows.forEach((window, name) => {
      if (!window.isDestroyed()) {
        try {
          window.webContents.send('app-minimized');
          window.webContents.executeJavaScript('window.jam.isAppMinimized = true;');
          
          if (this._backgroundPlugins.has(name)) {
            this._enableBackgroundProcessing(window, name);
          }
        } catch (err) {
        }
      }
    });
    
    this._window.webContents.send('app-minimized');
  }
  
  _enableBackgroundProcessing(window, name) {
    
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
                }
              }
            }, 1000);
            
          }
        })();
      `).catch(err => {
      });
    } catch (err) {
    }
  }

  _handleAppRestored() {
    this.pluginWindows.forEach((window, name) => {
      if (!window.isDestroyed()) {
        try {
          window.webContents.send('app-restored');
          window.webContents.executeJavaScript('window.jam.isAppMinimized = false;');
          
          window.webContents.executeJavaScript(`
            window.dispatchEvent(new CustomEvent('jam-foreground', {
              detail: { timestamp: Date.now() }
            }));
          `).catch(err => {
          });
        } catch (err) {
        }
      }
    });
    
    this._window.webContents.send('app-restored');
  }

  _setupFileOpeningIPC() {
    ipcMain.on('open-file-in-editor', (event, relativePath) => {
      // The event sender is a plugin window. We can find its path.
      const pluginWindow = BrowserWindow.fromWebContents(event.sender);
      if (!pluginWindow) return;

      const pluginName = pluginWindow.getTitle();
      const allWindows = this.pluginWindows;
      let pluginPath;

      for (const [name, window] of allWindows.entries()) {
        if (window === pluginWindow) {
          // We need to get the original path from when it was opened.
          // This requires a slight modification to how we store plugin data or window info.
          // For now, let's assume a way to get the base path.
          // A simple way is to find the plugin by its name in the main app's dispatch.
          // This is a bit of a workaround. A better way would be to store the path with the window.
          const mainAppWebContents = this._window.webContents;
          mainAppWebContents.send('get-plugin-path', pluginName);
          
          ipcMain.once('plugin-path-response', (e, pPath) => {
            if (pPath) {
              const fullPath = path.join(pPath, relativePath);
              shell.openPath(fullPath).catch(err => {
                console.error(`[Electron] Failed to open file: ${fullPath}`, err);
              });
            }
          });
          return;
        }
      }
    });
  }
}

module.exports = Electron
