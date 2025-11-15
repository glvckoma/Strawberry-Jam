const { BrowserWindow } = require('electron');

const isDevelopment = process.env.NODE_ENV === 'development';

class WindowManager {
  constructor(electronInstance) {
    this.electronInstance = electronInstance;
    this.showingExitConfirmation = false;
    this.processingExitConfirmation = false;
  }

  handleWindowClose() {
    const shouldPrompt = this.electronInstance._store.get('ui.promptOnExit', true);

    if (shouldPrompt && this.electronInstance._window && !this.electronInstance._window.isDestroyed()) {
      if (this.showingExitConfirmation) {
        return;
      }

      this.showingExitConfirmation = true;
      this.electronInstance._window.webContents.send('show-exit-confirmation');

      setTimeout(() => {
        this.showingExitConfirmation = false;
      }, 10000);
    } else {
      this.electronInstance._window.close();
    }
  }

  handleExitConfirmationResponse({ confirmed, dontAskAgain }) {
    if (this.processingExitConfirmation) {
      return;
    }

    this.processingExitConfirmation = true;
    this.showingExitConfirmation = false;

    if (dontAskAgain) {
      this.electronInstance._store.set('ui.promptOnExit', false);
    }

    if (confirmed) {
      this.electronInstance._window.close();
    }

    setTimeout(() => {
      this.processingExitConfirmation = false;
    }, 500);
  }

  minimizeWindow() {
    if (this.electronInstance._window) {
      this.electronInstance._window.minimize();
      if (this.electronInstance._handleAppMinimized) {
        this.electronInstance._handleAppMinimized();
      }
    }
  }

  toggleFullscreen() {
    if (!this.electronInstance._window) return;

    if (!this.electronInstance._window.isFullScreen()) {
      const bounds = this.electronInstance._window.getBounds();
      this.electronInstance._savedWindowState = {
        bounds,
        isMaximized: this.electronInstance._window.isMaximized()
      };
    }

    this.electronInstance._window.setFullScreen(!this.electronInstance._window.isFullScreen());

    this.electronInstance._window.webContents.send('fullscreen-changed', this.electronInstance._window.isFullScreen());
  }

  toggleMaximize() {
    if (!this.electronInstance._window) return;

    if (this.electronInstance._window.isMaximized()) {
      this.electronInstance._window.unmaximize();
    } else {
      if (!this.electronInstance._savedWindowState) {
        this.electronInstance._savedWindowState = {
          bounds: this.electronInstance._window.getBounds(),
          isMaximized: false
        };
      }

      this.electronInstance._window.maximize();
    }

    this.electronInstance._window.webContents.send('maximize-changed', this.electronInstance._window.isMaximized());
  }
}

module.exports = WindowManager;

