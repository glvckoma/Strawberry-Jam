const { ipcRenderer } = require('electron');

/**
 * LogManager client for renderer processes
 * Provides access to the main process LogManager through IPC
 */
class LogManagerClient {
  constructor() {
    this.logLevels = {
      DEBUG: 0,
      INFO: 1,
      WARN: 2,
      ERROR: 3
    };
    this.context = 'renderer';
  }

  /**
   * Set the context for all logs from this client
   * @param {String} context Context identifier
   */
  setContext(context) {
    if (typeof context === 'string' && context.trim() !== '') {
      this.context = context;
    }
  }

  /**
   * Log a message at the specified level
   * @param {String} message Log message
   * @param {Number} level Log level
   */
  log(message, level = this.logLevels.INFO) {
    return ipcRenderer.invoke('log-manager-log', message, this.context, level);
  }

  /**
   * Log a debug message
   * @param {String} message Log message
   */
  debug(message) {
    return this.log(message, this.logLevels.DEBUG);
  }

  /**
   * Log an info message
   * @param {String} message Log message
   */
  info(message) {
    return this.log(message, this.logLevels.INFO);
  }

  /**
   * Log a warning message
   * @param {String} message Log message
   */
  warn(message) {
    return this.log(message, this.logLevels.WARN);
  }

  /**
   * Log an error message
   * @param {String} message Log message
   */
  error(message) {
    return this.log(message, this.logLevels.ERROR);
  }

  /**
   * Get logs with optional filtering
   * @param {Object} options Filter options
   * @returns {Promise<Array>} Filtered logs
   */
  getLogs(options = {}) {
    return ipcRenderer.invoke('log-manager-get-logs', options);
  }
  
  /**
   * Get DevTools logs with optional filtering
   * @param {Object} options Filter options
   * @returns {Promise<Array>} Filtered DevTools logs
   */
  getDevToolsLogs(options = {}) {
    return ipcRenderer.invoke('log-manager-get-devtools-logs', options);
  }
  
  /**
   * Get system information
   * @returns {Promise<Object>} System information
   */
  getSystemInfo() {
    return ipcRenderer.invoke('log-manager-get-system-info');
  }

  /**
   * Export logs to a file
   * @param {Object} options Export options
   * @returns {Promise<String>} Path to exported log file
   */
  exportLogs(options = {}) {
    return ipcRenderer.invoke('log-manager-export', options);
  }
  
  /**
   * Get all logs combined (standard, devtools) for comprehensive reporting
   * @param {Object} options Options for filtering
   * @param {Number} options.maxResults Maximum number of logs to include
   * @returns {Promise<Object>} Combined logs and system info
   */
  async getAllLogs(options = {}) {
    try {
      // Get system info
      const systemInfo = await this.getSystemInfo();
      
      // Get standard logs
      const logs = await this.getLogs({
        maxResults: options.maxResults || 200
      });
      
      // Get devtools logs
      const devToolsLogs = await this.getDevToolsLogs({
        maxResults: options.maxResults || 100
      });
      
      return {
        systemInfo,
        logs,
        devToolsLogs
      };
    } catch (error) {
      console.error('Error getting all logs:', error);
      return {
        systemInfo: {},
        logs: [],
        devToolsLogs: []
      };
    }
  }
}

// Create and export singleton instance
const logManager = new LogManagerClient();
module.exports = logManager; 