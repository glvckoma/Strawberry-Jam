const Module = require('module');
const originalRequire = Module.prototype.require;
const originalResolveFilename = Module._resolveFilename;

const fs = require('fs');
const fsPromisesValue = fs.promises || (() => {
  const { promisify } = require('util');
  const promises = {};
  const fsMethods = ['access', 'appendFile', 'chmod', 'chown', 'copyFile', 'lchmod', 'lchown', 'link', 'lstat', 'mkdir', 'mkdtemp', 'open', 'readdir', 'readFile', 'readlink', 'realpath', 'rename', 'rm', 'rmdir', 'stat', 'symlink', 'truncate', 'unlink', 'utimes', 'writeFile'];
  fsMethods.forEach(method => {
    if (typeof fs[method] === 'function') {
      promises[method] = promisify(fs[method]);
    }
  });
  return promises;
})();

Module._cache['fs/promises'] = {
  id: 'fs/promises',
  exports: fsPromisesValue,
  loaded: true,
  children: [],
  parent: null,
  filename: 'fs/promises',
  paths: []
};

Module._resolveFilename = function(request, parent, isMain, options) {
  if (request === 'fs/promises') {
    return 'fs/promises';
  }
  return originalResolveFilename.call(this, request, parent, isMain, options);
};

Module.prototype.require = function(id) {
  if (id === 'fs/promises') {
    return fsPromisesValue;
  }
  return originalRequire.apply(this, arguments);
};

const { app, BrowserWindow, shell, ipcMain, protocol, net, dialog, session } = require('electron');
const path = require('path');
const fsPromises = fsPromisesValue;
const crypto = require('crypto');
const { fork, spawn } = require('child_process');
const Store = require('electron-store');
const os = require('os');
const chokidar = require('chokidar');
const processManager = require('../utils/ProcessManager');
const setupIpcHandlers = require('./ipcHandlers');
const PlatformPaths = require('../PlatformPaths');


// Suppress Electron security warnings
process.env.ELECTRON_DISABLE_SECURITY_WARNINGS = 'true';

// Keytar service name for Leak Checker API Key
let KEYTAR_SERVICE_LEAK_CHECK_API_KEY;
const KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY = 'leak_checker_api_key';
const MIGRATION_FLAG_LEAK_CHECK_API_KEY_V1 = 'leakCheckApiKeyMigratedToKeytar_v1';

const Patcher = require('./renderer/application/patcher');
const { getDataPath, getAssetsPath, TCP_SERVER_PORTS, API_SERVER_PORTS } = require('../Constants');
const logManager = require('../utils/LogManager');
const AutoUpdateService = require('../services/update/AutoUpdateService');
const AppStateService = require('../services/state/AppStateService');
const WindowCreationService = require('../services/window/WindowCreationService');
const AppNotificationService = require('../services/notification/AppNotificationService');
const GlobalShortcutManager = require('../managers/shortcut/GlobalShortcutManager');
const CacheService = require('../services/cache/CacheService');

const isDevelopment = process.env.NODE_ENV === 'development'

// Helper: Only log in development
function devLog(...args) {}
function devWarn(...args) {}
const USER_DATA_PATH = app.getPath('userData');

const STRAWBERRY_JAM_CLASSIC_BASE_PATH = PlatformPaths.getStrawberryJamClassicBasePath();

const schema = {
  network: {
    type: 'object',
    properties: {
      smartfoxServer: {
        type: 'string',
        default: 'lb-iss02-classic-prod.animaljam.com'
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
      },
      consoleDrawerHeight: {
        type: 'number',
        default: 200
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
      },
      sidebar: {
        type: 'object',
        properties: {
          customIcons: { type: 'object', default: {} },
          hiddenPlugins: {
            type: 'array',
            items: { type: 'string' },
            default: []
          },
          sortMode: {
            type: 'string',
            enum: ['type', 'alphabetical', 'custom'],
            default: 'type'
          },
          customOrder: {
            type: 'array',
            items: { type: 'string' },
            default: []
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
    nodeIntegrationInSubFrames: true,
    webviewTag: true,
    plugins: true,
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
    this._apiPort = null
    this._store = new Store({ schema });
    try {
      this.keytar = require('keytar');
    } catch (e) {
      logManager.warn('[Electron] keytar not available, credential storage will use fallback');
      this.keytar = {
        getPassword: async () => null,
        setPassword: async () => {},
        deletePassword: async () => {}
      };
    }
    this._swfFileWatcher = null;

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
    this._backgroundIntervals = new Map();
    this._cachedJQuery = null;
    this._cachedJQueryUI = null;
    this._setupFileOpeningIPC();
    this._setupCleanupHandlers();
    this.manualCheckInProgressRef = { value: false };
    this.autoUpdateService = new AutoUpdateService(app, this._store, this._window, this.manualCheckInProgressRef);
    this.appStateService = new AppStateService(app, DEFAULT_APP_STATE);
    this.windowCreationService = new WindowCreationService(defaultWindowOptions);
    this.appNotificationService = new AppNotificationService(this._window, this.pluginWindows, this._backgroundPlugins);
    this.globalShortcutManager = new GlobalShortcutManager();
    this.cacheService = new CacheService();

    ipcMain.on('broadcast-to-plugins', (event, channel, ...args) => {
      this.pluginWindows.forEach((window) => {
        if (window && !window.isDestroyed()) {
          window.webContents.send(channel, ...args);
        }
      });
    });
  }

  _loadJQueryCache() {
    if (this._cachedJQuery) return
    try {
      this._cachedJQuery = fs.readFileSync(path.join(__dirname, '..', '..', 'node_modules', 'jquery', 'dist', 'jquery.min.js'), 'utf8')
    } catch (e) {
      this._cachedJQuery = null
    }
    try {
      this._cachedJQueryUI = fs.readFileSync(path.join(__dirname, '..', '..', 'assets', 'scripts', 'jquery-ui.js'), 'utf8')
    } catch (e) {
      this._cachedJQueryUI = null
    }
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

      this._loadJQueryCache()
      const jqInjection = this._cachedJQuery
        ? `if (!window.jQuery) { ${this._cachedJQuery}\n }`
        : ''
      const jqUIInjection = this._cachedJQueryUI
        ? `if (window.jQuery && !window.jQuery.ui) { ${this._cachedJQueryUI}\n }`
        : ''
      pluginWindow.webContents.executeJavaScript(jqInjection).then(() => {
        return pluginWindow.webContents.executeJavaScript(jqUIInjection)
      }).then(() => {
          pluginWindow.webContents.executeJavaScript(`
            try {
              const { ipcRenderer } = require('electron');
              
              window.jam = window.jam || {};

              const dispatchObj = {
                sendRemoteMessage: function(msg, options) {
                  ipcRenderer.send('send-remote-message', { message: msg, options: options || {} });
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
                getConnectedClients: function() {
                  return ipcRenderer.invoke('dispatch-get-connected-clients');
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

      if (this._backgroundIntervals.has(name)) {
        this._backgroundIntervals.delete(name);
      }

      try {
        if (pluginWindow.webContents && !pluginWindow.webContents.isDestroyed()) {
          pluginWindow.webContents.executeJavaScript(`
            if (window._backgroundKeepAliveInterval) {
              clearInterval(window._backgroundKeepAliveInterval);
              window._backgroundKeepAliveInterval = null;
            }
          `).catch(() => {});
        }
      } catch (err) {
      }

      this.pluginWindows.delete(name);
      this._backgroundPlugins.delete(name);
    });

    pluginWindow.webContents.on('did-fail-load', (event, errorCode, errorDescription) => {
    });
  }

  _handleOpenGameWindow() {
    if (this._gameWindow && !this._gameWindow.isDestroyed()) {
      if (this._gameWindow.isMinimized()) this._gameWindow.restore()
      this._gameWindow.focus()
      return
    }

    const gameWindow = new BrowserWindow({
      ...defaultWindowOptions,
      title: 'Game Client',
      width: 1024,
      height: 768,
      frame: false,
      icon: path.join(getAssetsPath(app), 'images', 'icon.png'),
      webPreferences: {
        ...defaultWindowOptions.webPreferences,
        nodeIntegration: true,
        contextIsolation: false
      }
    })

    const clientPath = path.join(app.getAppPath(), 'assets', 'client', 'gui', 'index.html')
    gameWindow.loadFile(clientPath)

    this._gameWindow = gameWindow

    gameWindow.webContents.on('dom-ready', () => {
      const config = require(path.join(app.getAppPath(), 'assets', 'client', 'config.js'))
      const username = this._store.get('login.username', '')
      const rememberMe = this._store.get('login.rememberMe', false)
      const df = require('crypto').randomUUID()

      gameWindow.webContents.send('postSystemData', {
        version: app.getVersion(),
        platform: os.platform(),
        platformRelease: os.release(),
        language: this._store.get('login.language') || 'en',
        affiliateCode: this._store.get('login.affiliateCode') || ''
      })

      gameWindow.webContents.send('loginInfoLoaded', {
        username,
        rememberMe,
        authToken: null,
        refreshToken: null,
        config,
        df,
        rcToken: ''
      })
    })

    gameWindow.on('closed', () => {
      this._gameWindow = null
    })
  }

  async getAppState() {
    return await this.appStateService.getAppState();
  }

  async setAppState(newState) {
    return await this.appStateService.setAppState(newState);
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
    return this.cacheService.getCachePaths();
  }

  async _clearAppCache() {
    return await this.cacheService.clearAppCache();
  }

  _getUninstallerPath() {
    return this.cacheService.getUninstallerPath();
  }
  
  
    create () {
      const consoleLimit = this._store.get('logs.consoleLimit', 1000);
      const networkLimit = this._store.get('logs.networkLimit', 1000);
  
    logManager.initialize({
      appDataPath: app.getPath('userData'),
      maxMemoryLogs: networkLimit
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

  _registerShortcut(key, callback) {
    this.globalShortcutManager.register(key, callback);
  }

  _createWindow({ url, frameName }) {
    return this.windowCreationService.createWindow({ url, frameName });
  }


  messageWindow (type, message = {}) {
    if (this._window && this._window.webContents) {
      this._window.webContents.send(type, message)
    }
  }

  _setupZoomHandling(win) {
    const MIN_ZOOM = -3;
    const MAX_ZOOM = 3;

    win.webContents.on('before-input-event', (event, input) => {
      if (!input.control || input.type !== 'keyDown') return;

      if (input.key === '0') {
        win.webContents.setZoomLevel(0);
        event.preventDefault();
      } else if (input.key === '=' || input.key === '+') {
        const current = win.webContents.getZoomLevel();
        if (current < MAX_ZOOM) {
          win.webContents.setZoomLevel(Math.min(current + 0.5, MAX_ZOOM));
        }
        event.preventDefault();
      } else if (input.key === '-') {
        const current = win.webContents.getZoomLevel();
        if (current > MIN_ZOOM) {
          win.webContents.setZoomLevel(Math.max(current - 0.5, MIN_ZOOM));
        }
        event.preventDefault();
      }
    });
  }

  async _onReady () {
    ipcMain.on('request-main-log-path', (event) => {
      const pathToSend = (logManager && logManager.logPath) ? logManager.logPath : "dummy/path/from/_onReady/sender_send_handler";
      if (event.sender && !event.sender.isDestroyed()) {
        event.sender.send('response-main-log-path', pathToSend);
      }
    });

    this._patcher = new Patcher(null, getAssetsPath(app));
    const windowOptions = {
      ...defaultWindowOptions,
      icon: path.join(getAssetsPath(app), 'images', 'icon.png')
    };
    
    this._window = new BrowserWindow(windowOptions);
    this.autoUpdateService.window = this._window;

    const { screen } = require('electron');
    const savedBounds = this._store.get('windowBounds');
    let bounds = null;

    if (savedBounds && savedBounds.width > 200 && savedBounds.height > 200) {
      const displays = screen.getAllDisplays();
      const visible = displays.some(d => {
        const b = d.bounds;
        return savedBounds.x >= b.x - 50 && savedBounds.y >= b.y - 50 &&
               savedBounds.x < b.x + b.width && savedBounds.y < b.y + b.height;
      });
      if (visible) bounds = savedBounds;
    }

    if (!bounds) {
      const { width, height } = screen.getPrimaryDisplay().workAreaSize;
      const w = Math.floor(width * 0.57);
      const h = Math.floor(height * 0.8);
      bounds = { x: Math.floor((width - w) / 2), y: Math.floor((height - h) / 2), width: w, height: h };
    }

    this._window.setBounds(bounds);
    
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
    
    this._setupZoomHandling(this._window);

    const dataPath = getDataPath(app);

    await this._window.loadFile(path.join(__dirname, 'renderer', 'index.html'))

    const assetsPath = getAssetsPath(app)
    
    const FilesController = require('../api/controllers/FilesController');
    FilesController.initialize(app);
    
    this._window.webContents.send('set-data-path', dataPath)
    this._window.webContents.send('set-assets-path', assetsPath)
    this._window.webContents.send('set-user-data-path', USER_DATA_PATH)
    
    this._window.webContents.setWindowOpenHandler((details) => this._createWindow(details))

    this._window.on('close', () => {
      try {
        if (this._window && !this._window.isDestroyed()) {
          this._store.set('windowBounds', this._window.getBounds());
        }
      } catch (_) {}
    });

    this._window.on('closed', () => {
      const mainWindowId = this._window ? this._window.id : -1;

      let closedCount = 0;
      BrowserWindow.getAllWindows().forEach(win => {
        if (win && typeof win.id === 'number' && win.id !== mainWindowId && !win.isDestroyed()) {
          try {
            win.destroy();
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

      if (this._swfFileWatcher) {
        try {
          this._swfFileWatcher.close();
          this._swfFileWatcher = null;
        } catch (error) {
          console.error('[SWF Watcher] Error closing file watcher:', error);
        }
      }
      
      this._window = null;
    });

    try {
      const dataPath = getDataPath(app);
      await fsPromises.mkdir(dataPath, { recursive: true });
    } catch (error) {
      if (isDevelopment) {
        console.error(`[Electron] Error creating data directory: ${error.message}`);
      }
    }
    
    // Fork API process with timeout and error handling
    try {
      const assetsPath = getAssetsPath(app);
      this._apiProcess = fork(path.join(__dirname, '..', 'api', 'index.js'), [], {
        silent: false, // Allow child process to log to console
        env: {
          ...process.env,
          STRAWBERRY_JAM_ASSETS_PATH: assetsPath
        }
      });
      processManager.add(this._apiProcess);

      // Set up API process event handlers
      this._apiProcess.on('error', (error) => {
      });

      this._apiProcess.on('message', (message) => {
        if (message && message.type === 'api-port' && message.port) {
          this._apiPort = message.port
        }
      });

      this._apiProcess.on('exit', (code, signal) => {
        if (code !== 0 && this._window && !this._window.isDestroyed()) {
          this._window.webContents.send('port-error', {
            server: 'api',
            message: 'The API server failed to start because port 7681 is busy. Close other applications using this port or use the /terminate command, then restart.'
          })
        }
      });

      this.appNotificationService.window = this._window;
      this.appNotificationService.notifyStrawberryJamClose(this._apiProcess);

      // Give API process a moment to start, but don't block the main startup
      setTimeout(() => {
        if (this._apiProcess && !this._apiProcess.killed) {
        }
      }, 1000);
      
    } catch (error) {
      // Continue startup even if API process fails - most functionality doesn't depend on it
    }

    if (isDevelopment) {
      this.globalShortcutManager.registerDevToolsShortcut();
    }


    await Promise.all([
      Promise.resolve(this.autoUpdateService.initialize()).catch(() => {}),
      this._autoReapplySwfIfNeeded().catch(e => console.error('Error applying SWF on launch:', e)),
      this._setupSwfFileWatcher().catch(() => {})
    ]);
  }

  async _autoReapplySwfIfNeeded() {
    const selectedFile = this._store.get('game.selectedSwfFile')
    if (!selectedFile) return

    const FilesController = require('../api/controllers/FilesController')
    const sourceFilePath = path.join(FilesController.optionsDir, selectedFile)

    const sourceExists = await fsPromises.access(sourceFilePath).then(() => true).catch(() => false)
    if (!sourceExists) return

    const stats = await fsPromises.stat(sourceFilePath)
    const currentModifiedTime = stats.mtime.getTime()
    const lastModifiedKey = `game.swfLastModified.${selectedFile}`
    const lastModifiedTime = this._store.get(lastModifiedKey)

    if (!lastModifiedTime || currentModifiedTime > lastModifiedTime) {
      logManager.log(`[Auto Reapply] Detected modification to ${selectedFile}, reapplying...`, 'main', logManager.logLevels.INFO)
      const result = await FilesController.replaceSwfFile(selectedFile)
      if (result.success) {
        this._store.set(lastModifiedKey, currentModifiedTime)
        if (this._window && this._window.webContents && !this._window.isDestroyed()) {
          this._window.webContents.send('swf-auto-reapplied')
        }
      }
    }
  }

  async _setupSwfFileWatcher() {
    try {
      const FilesController = require('../api/controllers/FilesController');
      const optionsDir = FilesController.optionsDir;

      if (!optionsDir) return;
      const dirExists = await fsPromises.access(optionsDir).then(() => true).catch(() => false);
      if (!dirExists) return;

      if (this._swfFileWatcher) {
        this._swfFileWatcher.close();
      }

      this._swfFileWatcher = chokidar.watch(path.join(optionsDir, '*.swf'), {
        ignored: /(^|[\/\\])\../,
        persistent: true,
        ignoreInitial: true,
        usePolling: true,
        interval: 1000,
        awaitWriteFinish: {
          stabilityThreshold: 2000,
          pollInterval: 500
        }
      });

      this._swfFileWatcher.on('change', async (filePath) => {
        try {
          const filename = path.basename(filePath);
          const stats = await fsPromises.stat(filePath);
          const currentModifiedTime = stats.mtime.getTime();
          const lastModifiedKey = `game.swfLastModified.${filename}`;
          const lastModifiedTime = this._store.get(lastModifiedKey);

          if (lastModifiedTime && currentModifiedTime <= lastModifiedTime) {
            return;
          }

          const selectedFile = this._store.get('game.selectedSwfFile');
          if (selectedFile === filename) {
            logManager.log(`[SWF Watcher] Detected modification to ${filename}, reapplying...`, 'main', logManager.logLevels.INFO);
            
            const result = await FilesController.replaceSwfFile(filename);
            if (result.success) {
              this._store.set(lastModifiedKey, currentModifiedTime);
              
              if (this._window && this._window.webContents && !this._window.isDestroyed()) {
                this._window.webContents.send('swf-auto-reapplied');
              }
            } else {
              console.error(`[SWF Watcher] Failed to reapply ${filename}:`, result.error);
            }
          }
        } catch (error) {
          console.error('[SWF Watcher] Error handling file change:', error);
        }
      });

      this._swfFileWatcher.on('error', (error) => {
        console.error('[SWF Watcher] Watcher error:', error);
      });

      logManager.log('[SWF Watcher] File watcher initialized', 'main', logManager.logLevels.INFO);
    } catch (error) {
      console.error('[SWF Watcher] Failed to setup file watcher:', error);
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
    if (this._backgroundIntervals.has(name)) return

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
              }
            }, 5000);
          }
          return window._backgroundKeepAliveInterval;
        })();
      `).then((intervalId) => {
        if (intervalId) {
          this._backgroundIntervals.set(name, intervalId);
        }
      }).catch(() => {});
    } catch (err) {
    }
  }

  _handleAppRestored() {
    this.pluginWindows.forEach((window, name) => {
      if (!window.isDestroyed()) {
        try {
          window.webContents.send('app-restored');
          window.webContents.executeJavaScript('window.jam.isAppMinimized = false;');

          if (this._backgroundIntervals.has(name)) {
            window.webContents.executeJavaScript(`
              if (window._backgroundKeepAliveInterval) {
                clearInterval(window._backgroundKeepAliveInterval);
                window._backgroundKeepAliveInterval = null;
              }
            `).catch(() => {});
            this._backgroundIntervals.delete(name);
          }

          window.webContents.executeJavaScript(`
            window.dispatchEvent(new CustomEvent('jam-foreground', {
              detail: { timestamp: Date.now() }
            }));
          `).catch(() => {});
        } catch (err) {
        }
      }
    });

    this._window.webContents.send('app-restored');
  }

  _setupFileOpeningIPC() {
    ipcMain.on('open-file-in-editor', (event, relativePath) => {
      const pluginWindow = BrowserWindow.fromWebContents(event.sender);
      if (!pluginWindow) return;

      const pluginName = pluginWindow.getTitle();
      const allWindows = this.pluginWindows;
      let pluginPath;

      for (const [name, window] of allWindows.entries()) {
        if (window === pluginWindow) {
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

  _setupCleanupHandlers() {
    const performCleanup = async (signal) => {
      if (this._isQuitting) {
        return;
      }
      this._isQuitting = true;

      if (signal) {
        logManager.log(`[Electron] ${signal} received, starting cleanup`, 'main');
      } else {
        logManager.log('[Electron] will-quit event triggered, starting cleanup', 'main');
      }

      const cleanupPromises = [];

      if (this._window && !this._window.isDestroyed() && this._window.webContents) {
        cleanupPromises.push(
          new Promise((resolve) => {
            this._window.webContents.send('app-cleanup-request');
            setTimeout(resolve, 500);
          })
        );
      }

      for (const [name, window] of this.pluginWindows.entries()) {
        if (window && !window.isDestroyed() && window.webContents) {
          try {
            window.webContents.executeJavaScript(`
              if (window._backgroundKeepAliveInterval) {
                clearInterval(window._backgroundKeepAliveInterval);
                window._backgroundKeepAliveInterval = null;
              }
            `).catch(() => {});
          } catch (err) {
          }
        }
      }

      this._backgroundIntervals.clear();

      if (this._swfFileWatcher) {
        try {
          this._swfFileWatcher.close();
          this._swfFileWatcher = null;
        } catch (error) {
          logManager.error(`[Electron] Error closing SWF watcher: ${error.message}`);
        }
      }

      await Promise.all(cleanupPromises);

      await processManager.killAll(null);

      if (signal) {
        process.exit(0);
      }
    };

    app.on('will-quit', async (event) => {
      await performCleanup(null);
    });

    const handleSignal = (signal) => {
      if (this._isQuitting) {
        return;
      }
      logManager.log(`[Electron] Received ${signal}, initiating cleanup...`, 'main');
      performCleanup(signal).catch((err) => {
        logManager.error(`[Electron] Error during ${signal} cleanup: ${err.message}`);
        process.exit(1);
      });
    };

    process.on('SIGINT', () => {
      handleSignal('SIGINT');
    });

    process.on('SIGTERM', () => {
      handleSignal('SIGTERM');
    });
    
    process.on('exit', (code) => {
      if (!this._isQuitting) {
        logManager.log(`[Electron] Process exiting with code ${code}, performing emergency cleanup`, 'main');
        processManager._emergencyCleanup();
      }
    });

    ipcMain.on('application-cleanup-complete', () => {
      logManager.log('[Electron] Application cleanup completed', 'main');
    });
  }
}

module.exports = Electron
