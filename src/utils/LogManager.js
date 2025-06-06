const fs = require('fs');
const path = require('path');
const { app, ipcMain, BrowserWindow } = require('electron');
const os = require('os');
const isDevelopment = process.env.NODE_ENV === 'development';

/**
 * Central log management system for Strawberry Jam
 * Handles log collection, storage, and reporting across processes
 */
class LogManager {
  constructor() {
    // Save references to original console methods before they get overridden
    this.originalConsole = {
      log: console.log,
      error: console.error,
      warn: console.warn
    };
    
    this.logStreams = {
      main: [],
      renderer: [],
      console: [],
      network: [],
      system: [],
      default: []
    };
    this.logLimits = {
      main: 1000,
      renderer: 1000,
      console: 1000,
      network: 1000,
      system: 100,
      default: 1000
    };
    this.initialized = false;
    this.logPath = '';
    this.sessionLogPath = ''; // Will not be used to create files automatically
    this.devToolsLogs = [];
    this.gameClientLogs = []; // For logs from winapp.asar
    this.maxGameClientLogs = 500; // Max game client logs to keep in memory
    this.systemInfo = {};
    this.logLevels = {
      DEBUG: 0,
      INFO: 1,
      WARN: 2,
      ERROR: 3
    };
  }

  /**
   * Initialize the log manager
   * @param {Object} options Configuration options
   * @param {String} options.appDataPath Path to app data
   * @param {Number} [options.consoleLimit=1000] Maximum console logs to keep in memory
   * @param {Number} [options.networkLimit=1000] Maximum network logs to keep in memory
   */
  initialize(options = {}) {
    if (this.initialized) return;

    const appDataPath = options.appDataPath || (app ? app.getPath('userData') : path.join(__dirname, '../../logs'));
    this.logPath = path.join(appDataPath, 'logs');
    
    if (!fs.existsSync(this.logPath)) {
      fs.mkdirSync(this.logPath, { recursive: true });
    }

    this.autoCleanupOldLogs();
    
    // this.sessionLogPath remains empty; automatic session file creation is disabled.
    
    this.logLimits.console = options.consoleLimit || this.logLimits.console;
    this.logLimits.network = options.networkLimit || this.logLimits.network;
    
    if (ipcMain) {
      this.setupIpcHandlers();
    }
    
    this.collectSystemInfo();
    
    this.initialized = true;
    this.log('LogManager initialized', 'system', this.logLevels.INFO);
    
    this.log(`System: ${os.platform()} ${os.release()} ${os.arch()}`, 'system', this.logLevels.INFO);
    this.log(`Memory: ${Math.round(os.totalmem() / (1024 * 1024 * 1024))} GB`, 'system', this.logLevels.INFO);
    this.log(`CPUs: ${os.cpus().length} cores`, 'system', this.logLevels.INFO);
    
    if (app) {
      this.setupDevToolsListener();
    }
  }

  debug(message, context = 'unknown') {
    this.log(message, context, this.logLevels.DEBUG);
  }

  info(message, context = 'unknown') {
    this.log(message, context, this.logLevels.INFO);
  }

  warn(message, context = 'unknown') {
    this.log(message, context, this.logLevels.WARN);
  }

  error(message, context = 'unknown') {
    this.log(message, context, this.logLevels.ERROR);
  }
  
  /**
   * Collect system information for diagnostics
   * @private
   */
  collectSystemInfo() {
    try {
      this.systemInfo = {
        platform: os.platform(),
        release: os.release(),
        arch: os.arch(),
        cpus: os.cpus().length,
        totalMemory: Math.round(os.totalmem() / (1024 * 1024 * 1024)),
        freeMemory: Math.round(os.freemem() / (1024 * 1024 * 1024)),
        uptime: os.uptime(),
        appVersion: app ? app.getVersion() : 'unknown'
      };
    } catch (error) {
      this.originalConsole.error('Error collecting system info:', error);
    }
  }
  
  /**
   * Set up devtools message logging
   * @private
   */
  setupDevToolsListener() {
    try {
      app.on('browser-window-created', (_, window) => {
        this.attachDevToolsListenerToWindow(window);
      });
      
      BrowserWindow.getAllWindows().forEach(window => {
        this.attachDevToolsListenerToWindow(window);
      });
    } catch (error) {
      this.originalConsole.error('Error setting up devtools listeners:', error);
    }
  }
  
  /**
   * Checks a window's WebContents and sends the main log path if identified as winapp.
   * @param {Electron.WebContents} webContents The WebContents to check.
   * @param {Electron.BrowserWindow} windowInstance The parent BrowserWindow instance.
   * @returns {string} A string context for logging.
   * @private
   */
  _checkAndSendLogPath(webContents, windowInstance) {
    if (!webContents || webContents.isDestroyed()) return 'destroyed-webContents';

    let windowTitleContext = 'unknown-context';
    let identifiedAsWinApp = false;

    try {
      const rawWindowTitle = windowInstance ? (windowInstance.getTitle() || 'unknown-title') : 'unknown-window-instance';
      const currentUrl = webContents.getURL();
      this.originalConsole.log(`[LogManager Check] Checking window: Title='${rawWindowTitle}', URL='${currentUrl}'`);

      if (currentUrl.includes('winapp.asar')) {
        windowTitleContext = 'winapp-url';
        identifiedAsWinApp = true;
        this.originalConsole.log(`[LogManager Check] Identified '${windowTitleContext}' by URL: ${currentUrl}`);
      } else if (rawWindowTitle.toLowerCase().includes('animal jam') || rawWindowTitle.toLowerCase().includes('aj classic')) {
        windowTitleContext = 'winapp-title';
        identifiedAsWinApp = true;
        this.originalConsole.log(`[LogManager Check] Identified '${windowTitleContext}' by title: ${rawWindowTitle}`);
      } else if (rawWindowTitle.includes('index.html') && !rawWindowTitle.includes('/plugins/')) {
        windowTitleContext = 'main-client-ui';
      } else if (rawWindowTitle.includes('/plugins/')) {
        const pluginMatch = rawWindowTitle.match(/\/plugins\/([^\/]+)/);
        windowTitleContext = pluginMatch && pluginMatch[1] ? `plugin-${pluginMatch[1]}` : `plugin-unknown`;
      } else {
        windowTitleContext = rawWindowTitle.replace(/[^a-zA-Z0-9_-]/g, '_').substring(0, 50) || 'other-window';
      }

      if (identifiedAsWinApp) {
        this.originalConsole.log(`[LogManager Check] Sending log path to ${windowTitleContext} window: ${this.logPath}`);
        webContents.send('set-main-log-path', this.logPath);
      }
    } catch (e) {
      this.originalConsole.error(`[LogManager Check] Error identifying or sending log path: ${e.message}`);
    }
    return windowTitleContext;
  }

  /**
   * Attach devtools message listeners to a window
   * @param {BrowserWindow} window The window to attach to
   * @private
   */
  attachDevToolsListenerToWindow(window) {
    if (!window || !window.webContents) return;
    
    const initialContext = this._checkAndSendLogPath(window.webContents, window);
    this.originalConsole.log(`[LogManager Attach] Initial check for window (Context: ${initialContext}), attaching console logger.`);

    const didNavigateListener = (event, url) => {
      this.originalConsole.log(`[LogManager Attach] Window (Context: ${initialContext}) navigated to URL: ${url}`);
      this._checkAndSendLogPath(window.webContents, window);
    };
    window.webContents.on('did-navigate', didNavigateListener);

    const webContentsDestroyedListener = () => {
        if (window && window.webContents && !window.webContents.isDestroyed()) {
            window.webContents.removeListener('did-navigate', didNavigateListener);
        }
        if (window && window.webContents && !window.webContents.isDestroyed()) {
             window.webContents.removeListener('destroyed', webContentsDestroyedListener);
        }
        this.originalConsole.log(`[LogManager Attach] WebContents for window (Initial Context: ${initialContext}) destroyed. Cleaned up 'did-navigate' listener.`);
    };
    window.webContents.on('destroyed', webContentsDestroyedListener);
      
    window.webContents.on('console-message', (_, level, message, line, sourceId) => {
        const logLevel = Math.min(Math.max(level, 0), 3);
        
        let sourceName = `${initialContext}-devtools`; 
        try {
          if (sourceId) {
            const sourceUrl = new URL(sourceId);
            const fileName = path.basename(sourceUrl.pathname);
            if (fileName && fileName.length > 0 && fileName.length < 100) {
              sourceName = `${initialContext}-${fileName}`;
            } else if (initialContext) {
               sourceName = `${initialContext}-general`;
            }
          } else if (initialContext) {
            sourceName = `${initialContext}-console`;
          }
        } catch (e) {
          // Keep default sourceName
        }
        
        this.log(message, sourceName, logLevel);
        
        this.devToolsLogs.push({
          timestamp: new Date().toISOString(),
          window: initialContext,
          level: logLevel,
          levelName: this.getLevelName(logLevel),
          message,
          source: sourceId,
          line
        });
        
        if (this.devToolsLogs.length > this.maxMemoryLogs) {
          this.devToolsLogs = this.devToolsLogs.slice(-Math.floor(this.maxMemoryLogs * 0.8));
        }
      });
    }
  
  /**
   * Set up IPC handlers for renderer process communication
   * @private
   */
  setupIpcHandlers() {
    ipcMain.handle('log-manager-log', (event, message, context, level) => {
      let windowContext = context;
      try {
        if (event.sender) {
          const window = BrowserWindow.fromWebContents(event.sender);
          if (window) {
            const title = window.getTitle() || 'unknown';
            if (!context.includes('plugin-') && !context.includes('main')) {
              windowContext = context === 'renderer' 
                ? (title.includes('index.html') ? 'main' : `${title}-${context}`)
                : context;
            }
          }
        }
      } catch (e) { /* Do nothing on error */ }
      
      this.log(message, windowContext, level);
    });
    
    ipcMain.handle('log-manager-get-logs', (event, options = {}) => {
      return this.getLogs(options);
    });
    
    ipcMain.handle('log-manager-export', (event, options = {}) => {
      return this.exportLogs(options);
    });
    
    ipcMain.handle('log-manager-get-devtools-logs', (event, options = {}) => {
      return this.getDevToolsLogs(options);
    });
    
    ipcMain.handle('log-manager-get-system-info', () => {
      return this.systemInfo;
    });
  }
 
  /**
   * Add logs received from the game client (winapp.asar)
   * @param {Array<Object>} logsArray Array of log entries from the game client
   */
  addGameClientLogs(logsArray) {
    if (!this.initialized) {
      this.originalConsole.warn('LogManager not initialized, cannot add game client logs.');
      return;
    }
    if (!Array.isArray(logsArray)) {
      this.originalConsole.error('addGameClientLogs expects an array.');
      return;
    }

    const processedLogs = logsArray.map(log => {
      return {
        timestamp: log.timestamp || new Date().toISOString(),
        levelName: log.levelName || this.getLevelName(log.level || this.logLevels.INFO),
        level: log.level || this.logLevels.INFO,
        context: log.context || 'game-client',
        message: log.message || ''
      };
    });

    this.gameClientLogs.push(...processedLogs);

    if (this.gameClientLogs.length > this.maxGameClientLogs) {
      this.gameClientLogs = this.gameClientLogs.slice(-Math.floor(this.maxGameClientLogs * 0.8));
    }
    this.originalConsole.log(`[LogManager] Added ${processedLogs.length} logs from game client. Total: ${this.gameClientLogs.length}`);
  }
  
  /**
   * Add a log entry
   * @param {String} message Log message
   * @param {String} context Log context (main, renderer, plugin name, etc)
   * @param {Number} level Log level (0=DEBUG, 1=INFO, 2=WARN, 3=ERROR)
   */
  log(message, context = 'unknown', level = 1) {
    if (!this.initialized) {
      this.originalConsole.warn('LogManager not initialized');
      return;
    }
    
    const timestamp = new Date().toISOString();
    const entry = {
      timestamp,
      message: typeof message === 'object' ? JSON.stringify(message) : String(message),
      context,
      level,
      levelName: this.getLevelName(level)
    };

    const streamName = this.logStreams[context] ? context : 'default';
    const stream = this.logStreams[streamName];
    const limit = this.logLimits[streamName] || 1000;
    
    stream.push(entry);
    
    if (stream.length > limit) {
      this.logStreams[streamName] = stream.slice(-Math.floor(limit * 0.8));
    }
    
    this.appendToLogFile(entry);
    
    const shouldLog = isDevelopment || level >= (isDevelopment ? 0 : 2);
    if (shouldLog) {
      const consoleMethod = level >= 3 ? 'error' : level === 2 ? 'warn' : 'log';
      this.originalConsole[consoleMethod](`[${entry.levelName}] [${context}] ${message}`);
    }
  }
  
  /**
   * Append log entry to session log file
   * @private
   * @param {Object} entry Log entry
   */
  appendToLogFile(entry) {
    if (this.sessionLogPath && typeof this.sessionLogPath === 'string' && this.sessionLogPath.trim() !== '') {
      try {
        const logLine = `[${entry.timestamp}] [${entry.levelName}] [${entry.context}] ${entry.message}\n`;
        fs.appendFileSync(this.sessionLogPath, logLine);
      } catch (error) {
        this.originalConsole.error('Error writing to log file:', error);
      }
    } else {
      // this.originalConsole.log('[LogManager] Skipping appendToLogFile: sessionLogPath not set.');
    }
  }
  
  /**
   * Get log level name from numeric value
   * @private
   * @param {Number} level Numeric log level
   * @returns {String} Level name
   */
  getLevelName(level) {
    const names = Object.entries(this.logLevels)
      .find(([name, value]) => value === level);
      
    return names ? names[0] : 'UNKNOWN';
  }
  
  /**
   * Get logs with optional filtering
   * @param {Object} options Filter options
   * @param {String} options.context Filter by context
   * @param {Number} options.minLevel Minimum log level
   * @param {Number} options.maxResults Maximum results to return
   * @returns {Array} Filtered logs
   */
  getLogs(options = {}) {
    let allLogs = Object.values(this.logStreams).flat();
    allLogs.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));

    let filtered = allLogs;
    
    if (options.context) {
      filtered = filtered.filter(log => log.context === options.context);
    }
    
    if (options.minLevel !== undefined) {
      filtered = filtered.filter(log => log.level >= options.minLevel);
    }
    
    if (options.maxResults) {
      filtered = filtered.slice(-options.maxResults);
    }
    
    return filtered;
  }
  
  /**
   * Get devtools logs with optional filtering
   * @param {Object} options Filter options
   * @param {String} options.window Filter by window
   * @param {Number} options.minLevel Minimum log level
   * @param {Number} options.maxResults Maximum results to return
   * @returns {Array} Filtered devtools logs
   */
  getDevToolsLogs(options = {}) {
    let filtered = [...this.devToolsLogs];
    
    if (options.window) {
      filtered = filtered.filter(log => log.window === options.window);
    }
    
    if (options.minLevel !== undefined) {
      filtered = filtered.filter(log => log.level >= options.minLevel);
    }
    
    if (options.maxResults) {
      filtered = filtered.slice(-options.maxResults);
    }
    
    return filtered;
  }
  
  /**
   * Export logs to a file
   * @param {Object} options Export options
   * @param {String} options.outputPath Custom output path (optional)
   * @param {Boolean} options.includeMemoryLogs Include in-memory logs
   * @param {Boolean} options.includeDevToolsLogs Include devtools logs
   * @param {String} options.format Export format (text, json)
   * @returns {String} Path to exported log file
   */
  exportLogs(options = {}) {
    try {
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const outputPath = options.outputPath || path.join(this.logPath, `export-${timestamp}.txt`);
      const format = options.format || 'text';
      
      const includeDevToolsLogs = options.includeDevToolsLogs !== false;
      
      let content = '';
      
      if (format === 'json') {
        const allLogs = Object.values(this.logStreams).flat().sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
        const exportData = {
          systemInfo: this.systemInfo,
          logs: allLogs,
          devToolsLogs: includeDevToolsLogs ? this.devToolsLogs : [],
          gameClientLogs: this.gameClientLogs || []
        };
        content = JSON.stringify(exportData, null, 2);
      } else {
        content = '## System Information\n';
        Object.entries(this.systemInfo).forEach(([key, value]) => {
          content += `${key}: ${value}\n`;
        });
        content += '\n\n';
        
        if (this.sessionLogPath && fs.existsSync(this.sessionLogPath)) { // Check if sessionLogPath is valid
          content += '## Session Logs (Main Process - if enabled)\n';
          content += fs.readFileSync(this.sessionLogPath, 'utf8');
          content += '\n\n';
        }
        
        if (options.includeMemoryLogs) {
          content += '## Memory Logs (All Streams)\n';
          const allLogs = Object.values(this.logStreams).flat().sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
          allLogs.forEach(entry => {
            content += `[${entry.timestamp}] [${entry.levelName}] [${entry.context}] ${entry.message}\n`;
          });
          content += '\n\n';
        }
        
        if (includeDevToolsLogs && this.devToolsLogs.length > 0) {
          content += '## DevTools Logs (All Renderers)\n';
          this.devToolsLogs.forEach(entry => {
            content += `[${entry.timestamp}] [${entry.levelName}] [${entry.window}] ${entry.message} (${path.basename(entry.source || '')}:${entry.line || '?'})\n`;
          });
          content += '\n\n';
        }

        if (this.gameClientLogs && this.gameClientLogs.length > 0) {
          content += '## Game Client Logs (winapp.asar - from memory)\n';
          this.gameClientLogs.forEach(entry => {
            content += `[${entry.timestamp}] [${entry.levelName}] [${entry.context || 'game-client'}] ${entry.message}\n`;
          });
          content += '\n\n';
        }
      }
      
      fs.writeFileSync(outputPath, content);
      
      return outputPath;
    } catch (error) {
      this.originalConsole.error('Error exporting logs:', error);
      throw error;
    }
  }
 
  /**
   * Automatically cleans up old log files to prevent excessive disk usage.
   * Keeps a specified number of the most recent session and export logs.
   * @private
   */
  autoCleanupOldLogs() {
    const MAX_SESSION_LOGS = 20; // For main process session logs, if they were enabled
    const MAX_EXPORT_FILES = 20;

    try {
      this.originalConsole.log('[LogManager] Performing auto-cleanup of old log files...');
      const files = fs.readdirSync(this.logPath);

      // Cleanup for main process session logs (if any exist from past versions or if re-enabled)
      const sessionLogs = files
        .filter(file => file.startsWith('session-') && file.endsWith('.log'))
        .map(file => ({ name: file, time: fs.statSync(path.join(this.logPath, file)).mtime.getTime() }))
        .sort((a, b) => a.time - b.time); 

      const exportFiles = files
        .filter(file => file.startsWith('export-') && file.endsWith('.txt'))
        .map(file => ({ name: file, time: fs.statSync(path.join(this.logPath, file)).mtime.getTime() }))
        .sort((a, b) => a.time - b.time);

      const deleteOldFiles = (fileList, maxFiles, type) => {
        if (fileList.length > maxFiles) {
          const filesToDelete = fileList.slice(0, fileList.length - maxFiles);
          this.originalConsole.log(`[LogManager] Deleting ${filesToDelete.length} old ${type} log(s)...`);
          filesToDelete.forEach(file => {
            try {
              fs.unlinkSync(path.join(this.logPath, file.name));
              this.originalConsole.log(`[LogManager] Deleted old log: ${file.name}`);
            } catch (e) {
              this.originalConsole.error(`[LogManager] Error deleting old log ${file.name}:`, e);
            }
          });
        }
      };

      deleteOldFiles(sessionLogs, MAX_SESSION_LOGS, 'main-session'); // Clarified type
      deleteOldFiles(exportFiles, MAX_EXPORT_FILES, 'export');
      // Note: winapp-session-*.log files are managed by LoginScreen.js's rotation logic

      this.originalConsole.log('[LogManager] Auto-cleanup finished.');

    } catch (error) {
      this.originalConsole.error('[LogManager] Error during auto-cleanup of old log files:', error);
    }
  }
}

// Export singleton instance
const logManager = new LogManager();
module.exports = logManager;
