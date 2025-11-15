const { globalShortcut, BrowserWindow } = require('electron');

class GlobalShortcutManager {
  constructor() {
    this.registeredShortcuts = new Set();
  }

  register(key, callback) {
    try {
      globalShortcut.register(key, callback);
      this.registeredShortcuts.add(key);
    } catch (error) {
      console.error(`[GlobalShortcut] Failed to register shortcut ${key}:`, error);
    }
  }

  unregister(key) {
    try {
      globalShortcut.unregister(key);
      this.registeredShortcuts.delete(key);
    } catch (error) {
      console.error(`[GlobalShortcut] Failed to unregister shortcut ${key}:`, error);
    }
  }

  unregisterAll() {
    try {
      globalShortcut.unregisterAll();
      this.registeredShortcuts.clear();
    } catch (error) {
      console.error('[GlobalShortcut] Failed to unregister all shortcuts:', error);
    }
  }

  registerDevToolsShortcut() {
    this.register('F11', () => {
      const focusedWindow = BrowserWindow.getFocusedWindow();
      if (focusedWindow && focusedWindow.webContents) {
        focusedWindow.webContents.toggleDevTools();
      }
    });
  }
}

module.exports = GlobalShortcutManager;

