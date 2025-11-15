const { shell } = require('electron');

class WindowCreationService {
  constructor(defaultWindowOptions) {
    this.defaultWindowOptions = defaultWindowOptions;
  }

  createWindow({ url, frameName }) {
    if (frameName === 'external') {
      shell.openExternal(url);
      return { action: 'deny' };
    }

    return {
      action: 'allow',
      overrideBrowserWindowOptions: {
        ...this.defaultWindowOptions,
        autoHideMenuBar: true,
        frame: true,
        webPreferences: {
          ...this.defaultWindowOptions.webPreferences
        }
      }
    };
  }
}

module.exports = WindowCreationService;

