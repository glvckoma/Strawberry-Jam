const logManager = require('../../utils/LogManager');

class AppNotificationService {
  constructor(window, pluginWindows, backgroundPlugins) {
    this.window = window;
    this.pluginWindows = pluginWindows;
    this.backgroundPlugins = backgroundPlugins;
  }

  notifyStrawberryJamClose(apiProcess) {
    apiProcess.on('message', (message) => {
      if (message && message.type === 'aj-classic-closing') {
        logManager.log('[AJ Classic Close] Received notification from API process that AJ Classic is closing, closing all plugins', 'main', logManager.logLevels.INFO);
        
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
          
          this.pluginWindows.clear();
          this.backgroundPlugins.clear();
          
          if (this.window && !this.window.isDestroyed()) {
            this.window.webContents.send('plugins-closed-by-aj-classic');
          }
        }
      }
    });
  }
}

module.exports = AppNotificationService;

