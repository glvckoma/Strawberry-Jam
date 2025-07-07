const { ipcMain, shell, dialog, session, app, BrowserWindow } = require('electron');
const path = require('path');
const fs = require('fs');
const fsPromises = fs.promises;
const crypto = require('crypto');
const { spawn } = require('child_process');
const processManager = require('../utils/ProcessManager');
const logManager = require('../utils/LogManager');
const os = require('os');
const { autoUpdater } = require('electron-updater');
const { getDataPath } = require('../Constants');

const isDevelopment = process.env.NODE_ENV === 'development';

const STRAWBERRY_JAM_CLASSIC_BASE_PATH = process.platform === 'win32'
  ? path.join(os.homedir(), 'AppData', 'Local', 'Programs', 'strawberry-jam-classic')
  : process.platform === 'darwin'
    ? path.join('/', 'Applications', 'Strawberry Jam Classic.app', 'Contents')
    : undefined;

let KEYTAR_SERVICE_LEAK_CHECK_API_KEY;
const KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY = 'leak_checker_api_key';

// Cache for game time to revert to in case of data corruption
let lastKnownGoodGameTime = 0;

function setupIpcHandlers(electronInstance) {
  KEYTAR_SERVICE_LEAK_CHECK_API_KEY = `${app.getName()}-leak-check-api-key`;

  ipcMain.handle('read-json-file', async (event, filePath, defaultValue) => {
    const dataDir = getDataPath(app);
    const fullPath = path.join(dataDir, filePath);
    try {
      await fsPromises.access(fullPath);
      const fileContent = await fsPromises.readFile(fullPath, 'utf-8');
      return JSON.parse(fileContent);
    } catch (error) {
      return defaultValue;
    }
  });

  ipcMain.handle('write-json-file', async (event, filePath, data) => {
    const dataDir = getDataPath(app);
    const fullPath = path.join(dataDir, filePath);
    try {
      await fsPromises.writeFile(fullPath, JSON.stringify(data, null, 2), 'utf-8');
      return true;
    } catch (error) {
      console.error(`[IPC] Error writing JSON file '${fullPath}':`, error);
      return false;
    }
  });

  ipcMain.on('show-toast', (event, { message, type }) => {
    const senderWindow = BrowserWindow.fromWebContents(event.sender);
    if (senderWindow && !senderWindow.isDestroyed()) {
      // This assumes the main window is the one that can show toasts.
      // A more robust system might target a specific window or use a global manager.
      electronInstance._window.webContents.send('show-toast-from-main', { message, type });
    }
  });

  ipcMain.on('open-directory', (event, filePath) => {
    if (!filePath) {
      return;
    }
    shell.openPath(filePath).catch(err => {
       if (event && event.sender && !event.sender.isDestroyed()) {
          event.sender.send('directory-open-error', { path: filePath, error: err.message });
       }
    });
  });

  ipcMain.on('window-close', () => {
    const shouldPrompt = electronInstance._store.get('ui.promptOnExit', true);
    
    if (shouldPrompt && electronInstance._window && !electronInstance._window.isDestroyed()) {
      electronInstance._window.webContents.send('show-exit-confirmation');
    } else {
      electronInstance._window.close();
    }
  });
  
  ipcMain.on('exit-confirmation-response', (event, { confirmed, dontAskAgain }) => {
    
    if (dontAskAgain) {
      electronInstance._store.set('ui.promptOnExit', false);
    }
    
    if (confirmed) {
      electronInstance._window.close();
    }
  });

  ipcMain.on('window-minimize', () => {
    if (electronInstance._window) {
      electronInstance._window.minimize();
      electronInstance._handleAppMinimized();
    }
  });
  
  ipcMain.on('window-toggle-fullscreen', () => {
    if (!electronInstance._window) return;
    
    if (!electronInstance._window.isFullScreen()) {
      const bounds = electronInstance._window.getBounds();
      electronInstance._savedWindowState = {
        bounds,
        isMaximized: electronInstance._window.isMaximized()
      };
    }
    
    electronInstance._window.setFullScreen(!electronInstance._window.isFullScreen());
    
    electronInstance._window.webContents.send('fullscreen-changed', electronInstance._window.isFullScreen());
  });

  ipcMain.on('window-toggle-maximize', () => {
    if (!electronInstance._window) return;
    
    if (electronInstance._window.isMaximized()) {
      electronInstance._window.unmaximize();
    } else {
      if (!electronInstance._savedWindowState) {
        electronInstance._savedWindowState = {
          bounds: electronInstance._window.getBounds(),
          isMaximized: false
        };
      }
      
      electronInstance._window.maximize();
    }
    
    electronInstance._window.webContents.send('maximize-changed', electronInstance._window.isMaximized());
  });

  ipcMain.handle('get-modal-html', async (event, modalName) => {
    const modalPath = path.join(__dirname, `renderer/application/modals/${modalName}.html`);
    try {
      return await fs.promises.readFile(modalPath, 'utf-8');
    } catch (error) {
      console.error(`Failed to read modal HTML for ${modalName}:`, error);
      return null;
    }
  });

  ipcMain.on('open-settings', (_, url) => shell.openExternal(url));

  ipcMain.on('open-url', (_, url) => shell.openExternal(url));

  ipcMain.on('plugin-window-minimize', (event) => {
    const senderWindow = BrowserWindow.fromWebContents(event.sender);
    if (senderWindow && !senderWindow.isDestroyed()) {
      senderWindow.minimize();
    } else {
    }
  });

  ipcMain.handle('get-app-version', () => {
    return app.getVersion();
  });

  ipcMain.handle('get-setting', async (event, key) => {
    try {
      if (key === 'plugins.usernameLogger.apiKey') {
        const apiKey = await electronInstance.keytar.getPassword(KEYTAR_SERVICE_LEAK_CHECK_API_KEY, KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY);
        return apiKey || '';
      }
      const valueFromStore = electronInstance._store.get(key);
      return valueFromStore;
    } catch (error) {
      if (isDevelopment) {
      }
      return key === 'plugins.usernameLogger.apiKey' ? '' : undefined;
    }
  });

  ipcMain.handle('set-setting', async (event, key, value) => {
    try {
      if (key === 'plugins.usernameLogger.apiKey') {
        if (typeof value === 'string' && value.trim() !== '') {
          await electronInstance.keytar.setPassword(KEYTAR_SERVICE_LEAK_CHECK_API_KEY, KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY, value);
        } else {
          await electronInstance.keytar.deletePassword(KEYTAR_SERVICE_LEAK_CHECK_API_KEY, KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY);
        }
        return { success: true };
      }
      electronInstance._store.set(key, value);
      
      return { success: true };
    } catch (error) {
      if (isDevelopment) {
      }
      return { success: false, error: error.message };
    }
  });

  // IPC handler for getting SWF files information
  ipcMain.handle('get-swf-files', async (event) => {
    try {
      const FilesController = require('../api/controllers/FilesController');
      return FilesController.getSwfFileInfo();
    } catch (error) {
      console.error('Error getting SWF files information:', error);
      return [];
    }
  });

  // IPC handler for replacing SWF files
  ipcMain.handle('replace-swf-file', async (event, selectedFile) => {
    try {
      const FilesController = require('../api/controllers/FilesController');
      return await FilesController.replaceSwfFile(selectedFile);
    } catch (error) {
      console.error('Error replacing SWF file:', error);
      return { success: false, error: error.message };
    }
  });

  // IPC handler for reapplying SWF files
  ipcMain.handle('reapply-swf-file', async (event, selectedFile) => {
    try {
      const FilesController = require('../api/controllers/FilesController');
      // Re-use the same logic as replacing the SWF file
      return await FilesController.replaceSwfFile(selectedFile);
    } catch (error) {
      console.error('Error reapplying SWF file:', error);
      return { success: false, error: error.message };
    }
  });


  // IPC handler for getting active SWF info
  ipcMain.handle('get-active-swf-info', async (event) => {
    try {
      const FilesController = require('../api/controllers/FilesController');
      return FilesController.getActiveSwfInfo();
    } catch (error) {
      console.error('Error getting active SWF info:', error);
      return { active: null, hasBackup: false, error: error.message };
    }
  });

  ipcMain.handle('select-output-directory', async (event) => {
    if (!electronInstance._window) {
      if (isDevelopment) console.error('[Dialog] Cannot show dialog, main window not available.');
      return { canceled: true, error: 'Main window not available' };
    }
    try {
      const result = await dialog.showOpenDialog(electronInstance._window, {
        properties: ['openDirectory', 'createDirectory'],
        title: 'Select Leak Check Output Directory'
      });

      if (result.canceled || !result.filePaths || result.filePaths.length === 0) {
        return { canceled: true };
      } else {
        const selectedPath = result.filePaths[0];
        return { canceled: false, path: selectedPath };
      }
    } catch (error) {
      if (isDevelopment) console.error('[Dialog] Error showing open dialog:', error);
      return { canceled: true, error: error.message };
    }
  });

  ipcMain.handle('save-text-file', async (event, options) => {
    
    if (!electronInstance._window) {
      return { success: false, canceled: true };
    }
    
    try {
      const result = await dialog.showSaveDialog(electronInstance._window, {
        title: 'Save Report',
        defaultPath: options.suggestedFilename,
        filters: [
          { name: 'Text Files', extensions: ['txt'] },
          { name: 'All Files', extensions: ['*'] }
        ]
      });
      
      if (result.canceled || !result.filePath) {
        return { success: false, canceled: true };
      }
      
      await fsPromises.writeFile(result.filePath, options.content, 'utf-8');
      
      return { success: true, filePath: result.filePath };
    } catch (error) {
      return { success: false, error: error.message };
    }
  });

  ipcMain.on('app-restart', () => {
    app.relaunch();
    app.exit(0);
  });

  ipcMain.handle('get-app-state', (async () => {
      return electronInstance.getAppState();
  }).bind(electronInstance));

  ipcMain.handle('set-app-state', (async (event, newState) => {
      return electronInstance.setAppState(newState);
  }).bind(electronInstance));

  ipcMain.handle('dispatch-get-state', async (event, key) => {
    if (electronInstance._isQuitting) {
      if (isDevelopment) console.warn(`[IPC Main] Denying 'dispatch-get-state' for key '${key}' because app is quitting.`);
      return Promise.reject(new Error('Application is shutting down. Cannot get state.'));
    }

    if (!electronInstance._window || !electronInstance._window.webContents || electronInstance._window.webContents.isDestroyed()) {
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

      if (electronInstance._window && electronInstance._window.webContents && !electronInstance._window.webContents.isDestroyed()) {
        electronInstance._window.webContents.send('main-renderer-get-state-async', { key, replyChannel });
      } else {
        clearTimeout(timeout);
        ipcMain.removeListener(replyChannel, listener);
        if (isDevelopment) console.error(`[IPC Main] Main window webContents destroyed before sending 'main-renderer-get-state-async' for key '${key}'.`);
        reject(new Error('Main window became unavailable before state request could be sent.'));
      }
    });
  });

  ipcMain.once('renderer-ready', (async () => {
  }).bind(electronInstance));

  ipcMain.handle('danger-zone:clear-cache', async () => {
    const continueClear = await electronInstance._confirmNoOtherInstances('clear the cache');
    if (!continueClear) {
      return { success: false, message: 'Cache clearing cancelled by user.' };
    }

    try {
      await session.defaultSession.clearCache();
      await session.defaultSession.clearStorageData({ storages: ['cookies', 'localstorage'] });

      const cachePaths = electronInstance._getCachePaths();
      if (!cachePaths || cachePaths.length === 0) {
      } else {
        const helperScriptPath = path.join(__dirname, 'clear-cache-helper.js');

         let resolvedHelperPath;
         if (app.isPackaged) {
           resolvedHelperPath = path.join(process.resourcesPath, 'clear-cache-helper.js');
         } else {
           resolvedHelperPath = helperScriptPath;
         }

         try {
             await fsPromises.access(resolvedHelperPath);

             const child = spawn('node', [resolvedHelperPath, ...cachePaths], {
               detached: true,
               stdio: 'ignore'
             });
             processManager.add(child);
             child.on('error', (err) => { });
             child.unref();
         } catch (accessError) {
         }
      }

      app.quit();
      return { success: true, message: 'Internal cache cleared. External cache clearing scheduled. Application will close.' };

    } catch (error) {
      dialog.showMessageBoxSync(electronInstance._window, {
        type: 'error',
        title: 'Clear Cache Error',
        message: `Failed to initiate cache clearing: ${error.message}`,
        buttons: ['OK']
      });
      return { success: false, error: error.message };
    }

    electronInstance._isClearingCacheAndQuitting = true;
    app.quit();
    return { success: true, message: 'Cache clearing initiated. Application will close.' };

  });

  ipcMain.handle('danger-zone:uninstall', async () => {
    const continueUninstall = await electronInstance._confirmNoOtherInstances('uninstall Strawberry Jam');
    if (!continueUninstall) {
      return { success: false, message: 'Uninstall cancelled by user.' };
    }

    try {
      const uninstallerPath = electronInstance._getUninstallerPath();
      if (!uninstallerPath) {
        throw new Error('Uninstaller path could not be determined for this OS.');
      }

      await fsPromises.access(uninstallerPath);

      const child = spawn(uninstallerPath, [], {
        detached: true,
        stdio: 'ignore'
      });
      processManager.add(child);
      child.unref();


      app.quit();
      return { success: true };

    } catch (error) {
      const errorMsg = error.code === 'ENOENT' ? 'Uninstaller executable not found.' : error.message;
      dialog.showMessageBoxSync(electronInstance._window, {
        type: 'error',
        title: 'Uninstall Error',
        message: `Failed to start uninstaller: ${errorMsg}`,
        buttons: ['OK']
      });
      return { success: false, error: errorMsg };
    }
  });

  ipcMain.handle('get-open-plugin-windows', (event) => {
    const openPluginNames = [];
    if (electronInstance.pluginWindows) {
      for (const [pluginName, window] of electronInstance.pluginWindows.entries()) {
        if (window && !window.isDestroyed()) {
          openPluginNames.push(pluginName);
        }
      }
    }
    return openPluginNames;
  });

  ipcMain.handle('close-plugin-windows', (event, pluginNames) => {
    const closedWindows = [];
    if (electronInstance.pluginWindows && Array.isArray(pluginNames)) {
      for (const pluginName of pluginNames) {
        const window = electronInstance.pluginWindows.get(pluginName);
        if (window && !window.isDestroyed()) {
          try {
            window.close();
            closedWindows.push(pluginName);
          } catch (error) {
            console.warn(`[IPC] Failed to close plugin window ${pluginName}:`, error);
          }
        }
      }
    }
    return closedWindows;
  });

  ipcMain.on('open-plugin-window', electronInstance._handleOpenPluginWindow.bind(electronInstance));

  ipcMain.handle('get-os-info', async () => {
    return {
      platform: process.platform,
      release: os.release(),
      arch: process.arch
    };
  });

  ipcMain.handle('get-server-port', async () => {
    // Get the server port from the application instance
    if (electronInstance && electronInstance.application && electronInstance.application.server) {
      return electronInstance.application.server.actualPort || 443;
    }
    return 443; // Default fallback
  });

  ipcMain.handle('get-api-port', async () => {
    // Get the API server port from the forked process
    try {
      // Try to get the port from the API process if it's running
      if (electronInstance && electronInstance._apiProcess && !electronInstance._apiProcess.killed) {
        // Since the API server runs in a separate process, we need to communicate with it
        // For now, we'll check if common ports are available by trying to connect
        const net = require('net');
        const ports = [8080, 8081, 8082, 9080, 3000];
        
        for (const port of ports) {
          try {
            // Try to connect to the port to see if our API server is running there
            await new Promise((resolve, reject) => {
              const socket = new net.Socket();
              socket.setTimeout(100); // Very short timeout
              
              socket.on('connect', () => {
                socket.destroy();
                resolve(port);
              });
              
              socket.on('timeout', () => {
                socket.destroy();
                reject(new Error('timeout'));
              });
              
              socket.on('error', () => {
                socket.destroy();
                reject(new Error('connection failed'));
              });
              
              socket.connect(port, '127.0.0.1');
            });
            
            // If we get here, the port is responding
            return port;
          } catch (err) {
            // Port not responding, try next
            continue;
          }
        }
      }
    } catch (error) {
      // Fall through to default
    }
    
    return 8080; // Default fallback
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
      }
      return [];
    }
  });

  ipcMain.handle('get-cache-size', async () => {
    const cachePaths = electronInstance._getCachePaths();
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
          sizes.directories[path.basename(cachePath)] = 0;
        }
      }

      return sizes;
    } catch (error) {
      return { total: 0, directories: {} };
    }
  });

  ipcMain.on('direct-close-window', () => {
    if (electronInstance._window && !electronInstance._window.isDestroyed()) {
      electronInstance._window.close();
    }
  });

  ipcMain.on('winapp-generate-report', (event, reportData) => {
    if (reportData && reportData.logs) {
      logManager.addGameClientLogs(reportData.logs);
    } else {
    }
  });

  ipcMain.handle('get-username-logger-counts', async (event) => {
    try {
      const pluginWindowEntry = Array.from(electronInstance.pluginWindows.entries()).find(([name, win]) => name === 'Username Logger');
      
      if (!pluginWindowEntry) {
        return null;
      }
      const pluginWindow = pluginWindowEntry[1];

      if (!pluginWindow || pluginWindow.isDestroyed() || !pluginWindow.webContents || pluginWindow.webContents.isDestroyed()) {
        return null;
      }

      const isFunctionAvailable = await pluginWindow.webContents.executeJavaScript('typeof window.getUsernameLoggerCounts === "function"');
      if (!isFunctionAvailable) {
        return null;
      }
      
      const counts = await pluginWindow.webContents.executeJavaScript('window.getUsernameLoggerCounts();');
      return counts;
    } catch (error) {
      return null;
    }
  });

  ipcMain.on('plugin-settings-updated', (event) => {
    if (electronInstance._window && electronInstance._window.webContents && !electronInstance._window.webContents.isDestroyed()) {
      electronInstance._window.webContents.send('broadcast-plugin-settings-updated');
    }
  });

  ipcMain.on('check-for-updates', () => {
    electronInstance.manualCheckInProgress = true;
    autoUpdater.checkForUpdates().catch(err => {
      if (electronInstance._window && electronInstance._window.webContents && !electronInstance._window.isDestroyed()) {
        electronInstance._window.webContents.send('manual-update-check-status', { status: 'error', message: `Manual update check failed: ${err.message}` });
      }
      electronInstance.manualCheckInProgress = false;
    });
  });

  ipcMain.on('download-update', () => {
    autoUpdater.downloadUpdate().catch(err => {
      if (electronInstance._window && electronInstance._window.webContents && !electronInstance._window.isDestroyed()) {
        electronInstance._window.webContents.send('manual-update-check-status', { status: 'error', message: `Update download failed: ${err.message}` });
      }
    });
  });

  let gameTimeInterval;
  let gameStartTime;

  ipcMain.on('launch-game-client', () => {
    const exePath = process.platform === 'win32'
      ? path.join(STRAWBERRY_JAM_CLASSIC_BASE_PATH, 'AJ Classic.exe')
      : process.platform === 'darwin'
        ? path.join(STRAWBER_JAM_CLASSIC_BASE_PATH, 'MacOS', 'AJ Classic')
        : undefined;

    if (!exePath || !fs.existsSync(exePath)) {
      logManager.error(`[Process] Game client executable not found at: ${exePath}`);
      dialog.showErrorBox('Launch Error', `Could not find the game client executable. Please ensure it is installed correctly at:\n${exePath}`);
      return;
    }

    const dataPath = getDataPath(app);
    const spawnEnv = {
      ...process.env,
      STRAWBERRY_JAM_DATA_PATH: dataPath
    };

    try {
      const gameProcess = spawn(exePath, [], {
        detached: false,
        stdio: 'ignore',
        env: spawnEnv
      });

      processManager.add(gameProcess);
      gameStartTime = Date.now();
      
      gameProcess.on('close', async (code) => {
        logManager.log(`Game client process exited with code: ${code}`, 'main', logManager.logLevels.INFO);
        const endTime = Date.now();
        const durationInSeconds = Math.round((endTime - gameStartTime) / 1000);

        const dataDir = getDataPath(app);
        const gameTimeFilePath = path.join(dataDir, 'gametime.json');
        let gameTimeData = { totalGameTime: 0, totalUptime: 0 };

        try {
          await fsPromises.access(gameTimeFilePath);
          const fileContent = await fsPromises.readFile(gameTimeFilePath, 'utf-8');
          gameTimeData = JSON.parse(fileContent);
          // Sanity check for game time
          if (gameTimeData.totalGameTime > Date.now() / 1000) {
            logManager.warn(`[Process] Detected abnormally high game time (${gameTimeData.totalGameTime}), reverting to last known value: ${lastKnownGoodGameTime}.`);
            gameTimeData.totalGameTime = lastKnownGoodGameTime;
          } else {
            // Update the cache with the valid time from the file
            lastKnownGoodGameTime = gameTimeData.totalGameTime;
          }
        } catch (error) {
          // File doesn't exist, use defaults
        }

        gameTimeData.totalGameTime += durationInSeconds;

        try {
          await fsPromises.writeFile(gameTimeFilePath, JSON.stringify(gameTimeData, null, 2), 'utf-8');
        } catch (error) {
          logManager.error(`[Process] Failed to write total game time: ${error.message}`);
        }
        gameStartTime = null;
      });

      gameProcess.on('error', (err) => {
        logManager.error(`[Process] Error with game client process: ${err.message}`);
        gameStartTime = null;
      });
    } catch (error) {
      logManager.error(`[Process] Failed to spawn game client process: ${error.message}`);
      dialog.showErrorBox('Launch Error', `Failed to start the game client process:\n${error.message}`);
    }
  });

  // Launch AJ Classic external installation
  ipcMain.on('launch-aj-classic', () => {
    // Cross-platform path resolution for AJ Classic
    const getAJClassicPath = () => {
      if (process.platform === 'win32') {
        return path.join(os.homedir(), 'AppData', 'Local', 'Programs', 'aj-classic', 'AJ Classic.exe');
      } else if (process.platform === 'darwin') {
        return path.join('/', 'Applications', 'AJ Classic.app', 'Contents', 'MacOS', 'AJ Classic');
      } else {
        // Linux/other platforms - common installation paths
        const possiblePaths = [
          path.join(os.homedir(), '.local', 'share', 'aj-classic', 'AJ Classic'),
          path.join('/opt', 'aj-classic', 'AJ Classic'),
          path.join('/usr', 'local', 'bin', 'aj-classic')
        ];
        return possiblePaths.find(p => fs.existsSync(p)) || possiblePaths[0];
      }
    };

    const exePath = getAJClassicPath();

    if (!fs.existsSync(exePath)) {
      logManager.error(`[Process] AJ Classic executable not found at: ${exePath}`);
      dialog.showErrorBox('AJ Classic Launch Error', 
        `Could not find AJ Classic installation.\n\nLooked for:\n${exePath}\n\nPlease ensure AJ Classic is installed correctly.`);
      return;
    }

    try {
      const classicProcess = spawn(exePath, [], {
        detached: true,
        stdio: 'ignore'
      });

      processManager.add(classicProcess);
      classicProcess.unref(); // Allow parent to exit independently
      
      logManager.log(`AJ Classic launched from: ${exePath}`, 'main', logManager.logLevels.INFO);

      classicProcess.on('error', (err) => {
        logManager.error(`[Process] Error launching AJ Classic: ${err.message}`);
        dialog.showErrorBox('AJ Classic Launch Error', `Failed to start AJ Classic:\n${err.message}`);
      });
    } catch (error) {
      logManager.error(`[Process] Failed to spawn AJ Classic process: ${error.message}`);
      dialog.showErrorBox('AJ Classic Launch Error', `Failed to start AJ Classic:\n${error.message}`);
    }
  });

  // Global IPC handlers that don't depend on electronInstance directly
  ipcMain.on('packet-event', (event, packetData) => {
    const windows = BrowserWindow.getAllWindows();
    windows.forEach(win => {
      try {
        if (win && win.webContents && !win.webContents.isDestroyed()) {
          win.webContents.send('packet-event', packetData);
        }
      } catch (e) {
      }
    });
  });

  ipcMain.on('plugin-remote-message', (event, msg) => {
    const mainWindow = BrowserWindow.getAllWindows().find(win =>
      win.webContents && !win.webContents.isDestroyed() && win.webContents.getURL().includes('renderer/index.html')
    );
    if (mainWindow && mainWindow.webContents) {
      mainWindow.webContents.send('plugin-remote-message', msg);
    } else {
    }
  });

  ipcMain.on('send-connection-message', (event, msg) => {
    const mainWindow = BrowserWindow.getAllWindows().find(win =>
      win.webContents.getURL().includes('renderer/index.html')
    );
    if (mainWindow && mainWindow.webContents) {
      mainWindow.webContents.send('plugin-connection-message', msg);
    }
  });

  ipcMain.on('console-message', (event, { type, msg }) => {
  });

  ipcMain.on('dispatch-get-state-sync', (event, key) => {
    const mainWindow = BrowserWindow.getAllWindows().find(win =>
      win.webContents.getURL().includes('renderer/index.html')
    );

    if (!mainWindow || !mainWindow.webContents) {
      event.returnValue = null;
      return;
    }

    if (key === 'room') {
      if (global.cachedRoomState !== undefined) {
        event.returnValue = global.cachedRoomState;
      } else {
        event.returnValue = null;
      }
    } else {
      event.returnValue = null;
    }
  });

  ipcMain.on('update-room-state', (event, roomState) => {
    global.cachedRoomState = roomState;
  });

  ipcMain.handle('get-total-game-time', async () => {
    const dataDir = getDataPath(app);
    const gameTimeFilePath = path.join(dataDir, 'gametime.json');
    let totalGameTime = 0;
    try {
      await fsPromises.access(gameTimeFilePath);
      const fileContent = await fsPromises.readFile(gameTimeFilePath, 'utf-8');
      const data = JSON.parse(fileContent);
      totalGameTime = data.totalGameTime || 0;

      // Sanity check for game time. If it's a future timestamp, revert to the last known good value.
      if (totalGameTime > Date.now() / 1000) {
        logManager.warn(`[IPC] Detected abnormally high game time (${totalGameTime}), reverting to last known value: ${lastKnownGoodGameTime}.`);
        totalGameTime = lastKnownGoodGameTime;
      } else {
        // It's a valid time, so update our cache
        lastKnownGoodGameTime = totalGameTime;
      }
    } catch (error) {
      // file does not exist
    }

    if (gameStartTime) {
      const now = Date.now();
      const sessionDuration = Math.round((now - gameStartTime) / 1000);
      totalGameTime += sessionDuration;
    }
    
    return totalGameTime;
  });

  ipcMain.handle('get-total-uptime', async () => {
    const dataDir = getDataPath(app);
    const gameTimeFilePath = path.join(dataDir, 'gametime.json');
    try {
      await fsPromises.access(gameTimeFilePath);
      const fileContent = await fsPromises.readFile(gameTimeFilePath, 'utf-8');
      const data = JSON.parse(fileContent);
      return data.totalUptime || 0;
    } catch (error) {
      return 0;
    }
  });

  ipcMain.on('update-total-uptime', async (event, uptime) => {
    const dataDir = getDataPath(app);
    const gameTimeFilePath = path.join(dataDir, 'gametime.json');
    let gameTimeData = { totalGameTime: 0, totalUptime: 0 };

    try {
      await fsPromises.access(gameTimeFilePath);
      const fileContent = await fsPromises.readFile(gameTimeFilePath, 'utf-8');
      gameTimeData = JSON.parse(fileContent);
    } catch (error) {
      // File doesn't exist, use defaults
    }

    gameTimeData.totalUptime = uptime;

    try {
      await fsPromises.writeFile(gameTimeFilePath, JSON.stringify(gameTimeData, null, 2), 'utf-8');
    } catch (error) {
      logManager.error(`[Process] Failed to write total uptime: ${error.message}`);
    }
  });

  ipcMain.handle('reset-game-time', async () => {
    const dataDir = getDataPath(app);
    const gameTimeFilePath = path.join(dataDir, 'gametime.json');
    const initialData = { totalGameTime: 0, totalUptime: 0 };

    try {
      await fsPromises.writeFile(gameTimeFilePath, JSON.stringify(initialData, null, 2), 'utf-8');
      lastKnownGoodGameTime = 0; // Reset the in-memory cache as well
      return { success: true };
    } catch (error) {
      logManager.error(`[IPC] Failed to reset game time file: ${error.message}`);
      return { success: false, error: error.message };
    }
  });
}

module.exports = setupIpcHandlers;
