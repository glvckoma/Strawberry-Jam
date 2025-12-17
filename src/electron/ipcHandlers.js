const { ipcMain, shell, dialog, session, app, BrowserWindow } = require('electron');
const path = require('path');
const fs = require('fs');
const fsPromises = fs.promises;
const crypto = require('crypto');
const { spawn } = require('child_process');
const { autoUpdater } = require('electron-updater');
const processManager = require('../utils/ProcessManager');
const logManager = require('../utils/LogManager');
const PriceCheckerScraper = require('../services/PriceCheckerScraper');
const SettingsService = require('../services/settings/SettingsService');
const FileIOHandler = require('../services/file/FileIOHandler');
const WindowManager = require('../managers/window/WindowManager');
const GameTimeTracker = require('../services/game/GameTimeTracker');
const GameProcessManager = require('../managers/game/GameProcessManager');
const AccountManager = require('../services/account/AccountManager');
const SystemInfoService = require('../services/system/SystemInfoService');
const { getUsernameLoggerPath } = require('../Constants');

const isDevelopment = process.env.NODE_ENV === 'development';

function setupIpcHandlers(electronInstance) {
  const KEYTAR_SERVICE_LEAK_CHECK_API_KEY = `${app.getName()}-leak-check-api-key`;
  const settingsService = new SettingsService(electronInstance._store, electronInstance.keytar, KEYTAR_SERVICE_LEAK_CHECK_API_KEY);

  const gameStartTimeRef = { value: null };
  const isGameTimeBeingTrackedRef = { value: false };
  const lastKnownGoodGameTimeRef = { value: 0 };

  const fileIOHandler = new FileIOHandler(app, electronInstance._window);
  const windowManager = new WindowManager(electronInstance);
  const gameTimeTracker = new GameTimeTracker(app, gameStartTimeRef, lastKnownGoodGameTimeRef);
  const gameProcessManager = new GameProcessManager(electronInstance, gameTimeTracker, gameStartTimeRef, isGameTimeBeingTrackedRef);
  const accountManager = new AccountManager(electronInstance._store);
  const systemInfoService = new SystemInfoService();

  ipcMain.handle('read-json-file', async (event, filePath, defaultValue) => {
    return await fileIOHandler.readJsonFile(filePath, defaultValue);
  });

  ipcMain.handle('write-json-file', async (event, filePath, data) => {
    return await fileIOHandler.writeJsonFile(filePath, data);
  });

  ipcMain.handle('read-file', async (event, filePath) => {
    return await fileIOHandler.readFile(filePath);
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
    windowManager.handleWindowClose();
  });

  ipcMain.on('exit-confirmation-response', (event, response) => {
    windowManager.handleExitConfirmationResponse(response);
  });

  ipcMain.on('window-minimize', () => {
    windowManager.minimizeWindow();
  });

  ipcMain.on('window-toggle-fullscreen', () => {
    windowManager.toggleFullscreen();
  });

  ipcMain.on('window-toggle-maximize', () => {
    windowManager.toggleMaximize();
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

  ipcMain.handle('get-username-logger-path', () => {
    return getUsernameLoggerPath(app);
  });

  ipcMain.handle('get-setting', async (event, key) => {
    return await settingsService.getSetting(key);
  });

  ipcMain.handle('set-setting', async (event, key, value) => {
    const result = await settingsService.setSetting(key, value);
    return result;
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
      const result = await FilesController.replaceSwfFile(selectedFile);
      
      if (result.success) {
        const fs = require('fs');
        const path = require('path');
        const sourceFilePath = path.join(FilesController.optionsDir, selectedFile);
        
        if (fs.existsSync(sourceFilePath)) {
          const stats = fs.statSync(sourceFilePath);
          const currentModifiedTime = stats.mtime.getTime();
          const lastModifiedKey = `game.swfLastModified.${selectedFile}`;
          electronInstance._store.set(lastModifiedKey, currentModifiedTime);
        }
      }
      
      return result;
    } catch (error) {
      console.error('Error replacing SWF file:', error);
      return { success: false, error: error.message };
    }
  });

  // IPC handler for reapplying SWF files
  ipcMain.handle('reapply-swf-file', async (event, selectedFile) => {
    try {
      const FilesController = require('../api/controllers/FilesController');
      const result = await FilesController.replaceSwfFile(selectedFile);
      
      if (result.success) {
        const fs = require('fs');
        const path = require('path');
        const sourceFilePath = path.join(FilesController.optionsDir, selectedFile);
        
        if (fs.existsSync(sourceFilePath)) {
          const stats = fs.statSync(sourceFilePath);
          const currentModifiedTime = stats.mtime.getTime();
          const lastModifiedKey = `game.swfLastModified.${selectedFile}`;
          electronInstance._store.set(lastModifiedKey, currentModifiedTime);
        }
      }
      
      return result;
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
    return await fileIOHandler.saveTextFile(options);
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
        console.warn('[Clear Cache] No cache paths found to clear');
      } else {
        const possiblePaths = [];
        
        if (app.isPackaged) {
          possiblePaths.push(path.join(process.resourcesPath, 'clear-cache-helper.js'));
          possiblePaths.push(path.join(__dirname, 'clear-cache-helper.js'));
        } else {
          possiblePaths.push(path.join(__dirname, 'clear-cache-helper.js'));
          const altPath = path.resolve(__dirname, 'clear-cache-helper.js');
          if (altPath !== possiblePaths[0]) {
            possiblePaths.push(altPath);
          }
        }

        let resolvedHelperPath = null;
        for (const testPath of possiblePaths) {
          try {
            await fsPromises.access(testPath);
            resolvedHelperPath = testPath;
            break;
          } catch (err) {
            continue;
          }
        }

        if (!resolvedHelperPath) {
          const errorMessage = `Helper script not found in any of these locations:\n${possiblePaths.map(p => `  - ${p}`).join('\n')}\n\n__dirname: ${__dirname}\nisPackaged: ${app.isPackaged}`;
          console.error(`[Clear Cache] ${errorMessage}`);
          dialog.showMessageBoxSync(electronInstance._window, {
            type: 'error',
            title: 'Clear Cache Error',
            message: `Cannot clear external cache.\n\n${errorMessage}`,
            buttons: ['OK']
          });
        } else {
          try {
            const nodeExecutable = process.execPath;
            const scriptArgs = [resolvedHelperPath, ...cachePaths];

            const child = spawn(nodeExecutable, scriptArgs, {
              detached: true,
              stdio: ['ignore', 'ignore', 'ignore'],
              windowsHide: true
            });
            
            child.on('error', (err) => {
              console.error('[Clear Cache] Failed to spawn helper script:', err);
            });

            child.unref();
          } catch (spawnError) {
            console.error('[Clear Cache] Error spawning helper script:', spawnError);
            dialog.showMessageBoxSync(electronInstance._window, {
              type: 'error',
              title: 'Clear Cache Error',
              message: `Failed to start cache clearing process.\n\nError: ${spawnError.message}`,
              buttons: ['OK']
            });
          }
        }
      }

      electronInstance._isClearingCacheAndQuitting = true;
      app.quit();
      return { success: true, message: 'Internal cache cleared. External cache clearing scheduled. Application will close.' };

    } catch (error) {
      console.error('[Clear Cache] Error during cache clearing:', error);
      dialog.showMessageBoxSync(electronInstance._window, {
        type: 'error',
        title: 'Clear Cache Error',
        message: `Failed to initiate cache clearing: ${error.message}`,
        buttons: ['OK']
      });
      return { success: false, error: error.message };
    }
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
    return systemInfoService.getOsInfo();
  });

  ipcMain.handle('get-server-port', async () => {
    // Get the server port from the application instance
    if (electronInstance && electronInstance.application && electronInstance.application.server) {
      return electronInstance.application.server.actualPort || 443;
    }
    return 443; // Default fallback
  });

  ipcMain.handle('get-api-port', async () => {
    if (electronInstance && electronInstance._apiPort) {
      return electronInstance._apiPort
    }

    if (electronInstance && electronInstance._apiProcess && !electronInstance._apiProcess.killed) {
      for (let attempt = 0; attempt < 3; attempt++) {
        await new Promise(resolve => setTimeout(resolve, 200))
        
        if (electronInstance._apiPort) {
          return electronInstance._apiPort
        }
      }

      const http = require('http')
      const ports = [8080, 8081, 8082, 9080, 3000]
      
      for (const port of ports) {
        try {
          const result = await new Promise((resolve, reject) => {
            const req = http.get(`http://127.0.0.1:${port}/api/health`, { timeout: 500 }, (res) => {
              let data = ''
              res.on('data', chunk => { data += chunk })
              res.on('end', () => {
                try {
                  const json = JSON.parse(data)
                  if (json && json.service === 'strawberry-jam-api') {
                    resolve(port)
                  } else {
                    reject(new Error('Not Strawberry Jam API'))
                  }
                } catch {
                  reject(new Error('Invalid response'))
                }
              })
            })
            
            req.on('timeout', () => {
              req.destroy()
              reject(new Error('timeout'))
            })
            
            req.on('error', reject)
          })
          
          if (result) {
            if (electronInstance) {
              electronInstance._apiPort = result
            }
            return result
          }
        } catch (err) {
          continue
        }
      }
    }
    
    return 8080
  });

  ipcMain.handle('terminate-port', async (event, port) => {
    const { exec } = require('child_process')
    const { promisify } = require('util')
    const execAsync = promisify(exec)
    const platform = process.platform
    
    try {
      if (platform === 'win32') {
        const { stdout } = await execAsync(`netstat -ano | findstr :${port}`)
        const lines = stdout.trim().split('\n').filter(line => line.trim())
        
        for (const line of lines) {
          const parts = line.trim().split(/\s+/)
          const pid = parts[parts.length - 1]
          
          if (pid && !isNaN(pid)) {
            try {
              await execAsync(`taskkill /PID ${pid} /F`)
              return { success: true, message: `Terminated process ${pid} using port ${port}` }
            } catch (killError) {
              return { success: false, message: `Failed to terminate process ${pid}: ${killError.message}` }
            }
          }
        }
        
        return { success: false, message: `No process found using port ${port}` }
      } else if (platform === 'darwin' || platform === 'linux') {
        const { stdout } = await execAsync(`lsof -ti:${port}`)
        const pids = stdout.trim().split('\n').filter(pid => pid.trim())
        
        if (pids.length === 0) {
          return { success: false, message: `No process found using port ${port}` }
        }
        
        for (const pid of pids) {
          try {
            await execAsync(`kill -9 ${pid}`)
          } catch (killError) {
            return { success: false, message: `Failed to terminate process ${pid}: ${killError.message}` }
          }
        }
        
        return { success: true, message: `Terminated ${pids.length} process(es) using port ${port}` }
      }
      
      return { success: false, message: 'Unsupported platform' }
    } catch (error) {
      return { success: false, message: `Error checking port ${port}: ${error.message}` }
    }
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

  ipcMain.handle('get-user-plugins-path', () => {
    const userPluginsPath = path.join(app.getPath('userData'), 'plugins');
    if (!fs.existsSync(userPluginsPath)) {
      fs.mkdirSync(userPluginsPath, { recursive: true });
    }
    return userPluginsPath;
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
      const message = err && err.message ? err.message : String(err);
      if (electronInstance._window && electronInstance._window.webContents && !electronInstance._window.isDestroyed()) {
        electronInstance._window.webContents.send('manual-update-check-status', { status: 'error', message: `Manual update check failed: ${message}` });
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

  ipcMain.on('launch-game-client', () => {
    gameProcessManager.launchGameClient();
  });

  ipcMain.on('launch-aj-classic', () => {
    gameProcessManager.launchAJClassic();
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

  ipcMain.on('send-remote-message', (event, data) => {
    const mainWindow = BrowserWindow.getAllWindows().find(win =>
      win.webContents && !win.webContents.isDestroyed() && win.webContents.getURL().includes('renderer/index.html')
    );
    if (mainWindow && mainWindow.webContents) {
      // Support both old format (string) and new format (object with message and options)
      if (typeof data === 'string') {
        mainWindow.webContents.send('plugin-remote-message', data);
      } else if (data && data.message) {
        mainWindow.webContents.send('plugin-remote-message-with-options', data);
      }
    }
  });

  ipcMain.handle('dispatch-get-connected-clients', async () => {
    const mainWindow = BrowserWindow.getAllWindows().find(win =>
      win.webContents && !win.webContents.isDestroyed() && win.webContents.getURL().includes('renderer/index.html')
    );
    if (mainWindow && mainWindow.webContents) {
      try {
        const result = await mainWindow.webContents.executeJavaScript(`
          (window.jam && window.jam.application && window.jam.application.dispatch && 
           typeof window.jam.application.dispatch.getConnectedClients === 'function')
            ? window.jam.application.dispatch.getConnectedClients()
            : []
        `);
        // Ensure result is an array
        return Array.isArray(result) ? result : [];
      } catch (error) {
        console.error('[IPC] Error getting connected clients:', error);
        return [];
      }
    }
    return [];
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
    return await gameTimeTracker.getTotalGameTime();
  });

  ipcMain.handle('get-total-uptime', async () => {
    return await gameTimeTracker.getTotalUptime();
  });

  ipcMain.on('update-total-uptime', async (event, uptime) => {
    await gameTimeTracker.updateTotalUptime(uptime);
  });

  ipcMain.handle('reset-game-time', async () => {
    return await gameTimeTracker.resetGameTime();
  });

  ipcMain.handle('get-saved-accounts', async () => {
    return await accountManager.getSavedAccounts();
  });

  ipcMain.handle('save-account', async (event, accountData) => {
    return await accountManager.saveAccount(accountData);
  });

  ipcMain.handle('delete-account', async (event, username) => {
    return await accountManager.deleteAccount(username);
  });

  ipcMain.handle('delete-all-accounts', async () => {
    return await accountManager.deleteAllAccounts();
  });

  ipcMain.handle('toggle-pin-account', async (event, username) => {
    return await accountManager.togglePinAccount(username);
  });

  ipcMain.handle('import-accounts', async (event, accounts) => {
    return await accountManager.importAccounts(accounts);
  });

  // End AJ Classic processes handler
  ipcMain.handle('search-wiki', async (event, searchTerm) => {
    try {
      const results = await PriceCheckerScraper.searchForItems(searchTerm);
      return results;
    } catch (error) {
      console.error('[IPC] Error in search-wiki:', error);
      throw error; // Rethrow to send error back to renderer
    }
  });

  ipcMain.handle('get-page-details', async (event, pageUrl) => {
    try {
      const details = await PriceCheckerScraper.getItemDetails(pageUrl);
      return details;
    } catch (error) {
      console.error('[IPC] Error in get-page-details:', error);
      throw error;
    }
  });

  ipcMain.handle('end-aj-classic-processes', async () => {
    return await gameProcessManager.endAJClassicProcesses();
  });
}

module.exports = setupIpcHandlers;
