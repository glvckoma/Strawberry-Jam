const { autoUpdater } = require('electron-updater');
const logManager = require('../../utils/LogManager');

class AutoUpdateService {
  constructor(app, store, window, manualCheckInProgressRef) {
    this.app = app;
    this.store = store;
    this.window = window;
    this.manualCheckInProgressRef = manualCheckInProgressRef;
    this.checkIntervalId = null;
  }

  get manualCheckInProgress() {
    return this.manualCheckInProgressRef.value;
  }

  set manualCheckInProgress(value) {
    this.manualCheckInProgressRef.value = value;
  }

  recordCheckStatus(status, extra) {
    const now = new Date().toISOString();
    try {
      this.store.set('updates.lastAutoCheckAt', now);
      this.store.set('updates.lastAutoCheckStatus', status);
      if (extra && typeof extra === 'object') {
        this.store.set('updates.lastAutoCheckMeta', extra);
      }
    } catch (e) {
    }
  }

  initialize() {
    if (!this.app.isPackaged) {
      try {
        logManager.info('Skipping auto-updater initialization in development mode', 'auto-update');
      } catch (e) {
      }
      return;
    }

    const enableAutoUpdates = this.store.get('updates.enableAutoUpdates', true);
    this.store.set('updates.enableAutoUpdates', enableAutoUpdates);

    autoUpdater.autoDownload = enableAutoUpdates;
    autoUpdater.allowDowngrade = false;
    autoUpdater.allowPrerelease = false;

    autoUpdater.on('checking-for-update', () => {
      try {
        logManager.info('Checking for update', 'auto-update');
      } catch (e) {
      }
      this.recordCheckStatus('checking');
      if (this.manualCheckInProgress && this.window && this.window.webContents && !this.window.isDestroyed()) {
        this.window.webContents.send('manual-update-check-status', { status: 'checking', message: 'Checking for updates...' });
      }
    });

    autoUpdater.on('update-not-available', () => {
      try {
        logManager.info('No update available', 'auto-update');
      } catch (e) {
      }
      this.recordCheckStatus('no-update');
      if (this.manualCheckInProgress && this.window && this.window.webContents && !this.window.isDestroyed()) {
        this.window.webContents.send('manual-update-check-status', { status: 'no-update', message: 'No new updates available.' });
        this.manualCheckInProgress = false;
      }
    });

    autoUpdater.on('error', (err) => {
      const message = err && err.message ? err.message : String(err);
      try {
        logManager.error(`Auto-updater error: ${message}`, 'auto-update');
      } catch (e) {
      }
      this.recordCheckStatus('error', { message });
      if (this.manualCheckInProgress && this.window && this.window.webContents && !this.window.isDestroyed()) {
        this.window.webContents.send('manual-update-check-status', { status: 'error', message: `Error checking for updates: ${message}` });
        this.manualCheckInProgress = false;
      }
    });

    autoUpdater.on('update-available', (info) => {
      const version = info && info.version ? info.version : null;
      try {
        logManager.info(`Update available ${version || ''}`.trim(), 'auto-update');
      } catch (e) {
      }
      this.recordCheckStatus('available', { version });
      const messageText = autoUpdater.autoDownload
        ? 'A new update is available. Downloading now...'
        : 'A new update is available. Click "Update Now" to download.';
      if (this.manualCheckInProgress && this.window && this.window.webContents && !this.window.isDestroyed()) {
        this.window.webContents.send('manual-update-check-status', { status: 'available', message: messageText, version });
      }
    });

    autoUpdater.on('download-progress', (progressObj) => {
      if (this.manualCheckInProgress && this.window && this.window.webContents && !this.window.isDestroyed()) {
        this.window.webContents.send('manual-update-check-status', {
          status: 'downloading',
          message: `Downloading update... ${progressObj.percent.toFixed(1)}%`,
          version: progressObj.percent
        });
      }
    });

    autoUpdater.on('update-downloaded', (info) => {
      const version = info && info.version ? info.version : null;
      try {
        logManager.info(`Update downloaded ${version || ''}`.trim(), 'auto-update');
      } catch (e) {
      }
      this.recordCheckStatus('downloaded', { version });
      if (this.manualCheckInProgress && this.window && this.window.webContents && !this.window.isDestroyed()) {
        this.window.webContents.send('manual-update-check-status', { status: 'downloaded', message: 'Update downloaded. Click "Restart Now" to install.' });
        this.manualCheckInProgress = false;
      }
    });

    if (enableAutoUpdates) {
      const checkInterval = 1000 * 60 * 5;
      setTimeout(() => {
        autoUpdater.checkForUpdatesAndNotify().catch(err => {
          const message = err && err.message ? err.message : String(err);
          try {
            logManager.error(`Initial auto-update check failed: ${message}`, 'auto-update');
          } catch (e) {
          }
          this.recordCheckStatus('error', { message, phase: 'initial' });
        });
      }, 5000);

      this.checkIntervalId = setInterval(() => {
        autoUpdater.checkForUpdatesAndNotify().catch(err => {
          const message = err && err.message ? err.message : String(err);
          try {
            logManager.error(`Scheduled auto-update check failed: ${message}`, 'auto-update');
          } catch (e) {
          }
          this.recordCheckStatus('error', { message, phase: 'scheduled' });
        });
      }, checkInterval);
    }
  }

  getDiagnosticsSnapshot() {
    const snapshot = {
      appVersion: this.app ? this.app.getVersion() : null,
      enableAutoUpdates: this.store.get('updates.enableAutoUpdates', true),
      lastAutoCheckAt: this.store.get('updates.lastAutoCheckAt', null),
      lastAutoCheckStatus: this.store.get('updates.lastAutoCheckStatus', null),
      lastAutoCheckMeta: this.store.get('updates.lastAutoCheckMeta', null),
      autoDownload: autoUpdater.autoDownload,
      allowPrerelease: autoUpdater.allowPrerelease,
      allowDowngrade: autoUpdater.allowDowngrade,
      updateConfigPath: autoUpdater.updateConfigPath || null
    };
    return snapshot;
  }

  dispose() {
    if (this.checkIntervalId) {
      clearInterval(this.checkIntervalId);
      this.checkIntervalId = null;
    }
  }
}

module.exports = AutoUpdateService;

