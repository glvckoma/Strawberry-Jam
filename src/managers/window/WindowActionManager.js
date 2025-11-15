const { ipcRenderer } = require('electron')

/**
 * WindowActionManager - Manages window actions (open, minimize, close, fullscreen, etc.)
 * 
 * @module WindowActionManager
 */
class WindowActionManager {
  /**
   * Opens a URL or directory
   * @param {string} url - URL or path to open
   * @public
   */
  open(url) {
    ipcRenderer.send('open-url', url)
  }

  /**
   * Opens a plugin directory
   * @param {string} name - Plugin name
   * @param {Object} dispatch - Dispatch instance for plugin access
   * @public
   */
  directory(name, dispatch) {
    const plugin = dispatch.plugins.get(name)

    if (plugin) {
      const { filepath } = plugin
      ipcRenderer.send('open-directory', filepath)
    }
  }

  /**
   * Minimizes the application window
   * @public
   */
  minimize() {
    ipcRenderer.send('window-minimize')
  }

  /**
   * Closes the application window
   * @param {Object} modals - Modal system instance for exit confirmation
   * @returns {Promise<void>}
   * @public
   */
  async close(modals) {
    try {
      const promptOnExit = await ipcRenderer.invoke('get-setting', 'ui.promptOnExit')

      if (promptOnExit === false) {
        ipcRenderer.send('direct-close-window')
      } else {
        modals.show('confirmExitModal')
      }
    } catch (error) {
      console.error('[Renderer Application.close] Error in close method:', error)
      ipcRenderer.send('window-close')
    }
  }

  /**
   * Toggles fullscreen mode
   * @public
   */
  toggleFullscreen() {
    ipcRenderer.send('window-toggle-fullscreen')
  }

  /**
   * Toggles maximize/restore window
   * @public
   */
  toggleMaximize() {
    ipcRenderer.send('window-toggle-maximize')
  }

  /**
   * Relaunches the application
   * @public
   */
  relaunch() {
    ipcRenderer.send('application-relaunch')
  }
}

module.exports = WindowActionManager

