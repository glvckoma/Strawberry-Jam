const { autoUpdater } = require('electron-updater');

class AutoUpdateService {
  constructor(app, store, window, manualCheckInProgressRef) {
    this.app = app;
    this.store = store;
    this.window = window;
    this.manualCheckInProgressRef = manualCheckInProgressRef;
  }

  get manualCheckInProgress() {
    return this.manualCheckInProgressRef.value;
  }

  set manualCheckInProgress(value) {
    this.manualCheckInProgressRef.value = value;
  }

  initialize() {
    if (!this.app.isPackaged) {
      console.log('[AutoUpdater] Skipping auto-updater initialization in development mode.');
      return;
    }
    
    const enableAutoUpdates = this.store.get('updates.enableAutoUpdates', true);
    autoUpdater.autoDownload = enableAutoUpdates;
    autoUpdater.allowDowngrade = false;
    autoUpdater.allowPrerelease = false;

    autoUpdater.on('checking-for-update', () => {
      console.log('[AutoUpdater] Checking for update...');
      if (this.manualCheckInProgress && this.window && this.window.webContents && !this.window.isDestroyed()) {
        this.window.webContents.send('manual-update-check-status', { status: 'checking', message: 'Checking for updates...' });
      }
    });

    autoUpdater.on('update-not-available', (info) => {
      console.log('[AutoUpdater] Update not available.');
      if (this.manualCheckInProgress && this.window && this.window.webContents && !this.window.isDestroyed()) {
        this.window.webContents.send('manual-update-check-status', { status: 'no-update', message: 'No new updates available.' });
        this.manualCheckInProgress = false;
      }
    });

    autoUpdater.on('error', (err) => {
      console.error('[AutoUpdater] Error:', err.message);
      if (this.manualCheckInProgress && this.window && this.window.webContents && !this.window.isDestroyed()) {
        this.window.webContents.send('manual-update-check-status', { status: 'error', message: `Error checking for updates: ${err.message}` });
        this.manualCheckInProgress = false;
      }
    });

    autoUpdater.on('update-available', (info) => {
      console.log(`[AutoUpdater] Update available: ${info.version}`);
      const messageText = autoUpdater.autoDownload
        ? 'A new update is available. Downloading now...'
        : 'A new update is available. Click "Update Now" to download.';
      if (this.manualCheckInProgress && this.window && this.window.webContents && !this.window.isDestroyed()) {
        this.window.webContents.send('manual-update-check-status', { status: 'available', message: messageText, version: info.version });
      }
    });

    autoUpdater.on('update-downloaded', (info) => {
      console.log(`[AutoUpdater] Update downloaded: ${info.version}`);
      if (this.manualCheckInProgress && this.window && this.window.webContents && !this.window.isDestroyed()) {
        this.window.webContents.send('manual-update-check-status', { status: 'downloaded', message: 'Update downloaded. Click "Restart Now" to install.' });
        this.manualCheckInProgress = false;
      }
    });

    if (enableAutoUpdates) {
      const checkInterval = 1000 * 60 * 5;
      setTimeout(() => {
        autoUpdater.checkForUpdatesAndNotify().catch(err => {
          console.error('[AutoUpdater] Initial check failed:', err.message);
        });
      }, 5000);
      
      setInterval(() => {
        autoUpdater.checkForUpdatesAndNotify().catch(err => {
          console.error('[AutoUpdater] Scheduled check failed:', err.message);
        });
      }, checkInterval);
    }
  }
}

module.exports = AutoUpdateService;

