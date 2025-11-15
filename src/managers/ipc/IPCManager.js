const { ipcRenderer } = require('electron')

/**
 * IPCManager - Manages IPC handlers for plugin communication and game process events
 * 
 * @module IPCManager
 */
class IPCManager {
  constructor(application) {
    this.application = application
  }

  /**
   * Sets up IPC listeners for messages forwarded from plugin windows
   * @public
   */
  setupPluginIPC() {
    if (typeof require === "function") {
      try {
        if (window.jam && window.jam.roomState && this.application.dispatch) {
          window.jam.roomState.dispatch = this.application.dispatch
        }

        ipcRenderer.on('plugin-remote-message', async (event, msg) => {
          let processedMsg = msg
          
          if (this.application.dispatch && typeof msg === 'string' && msg.includes('{room}')) {
            try {
              const currentRoom = await this.application.dispatch.getState('room')
              if (currentRoom) {
                processedMsg = msg.replaceAll('{room}', currentRoom)
              }
            } catch (error) {
            }
          }
          
          if (this.application.dispatch && typeof this.application.dispatch.sendRemoteMessage === 'function') {
            this.application.dispatch.sendRemoteMessage(processedMsg).catch(err => {
              this.application.consoleMessage({ type: 'error', message: `Error sending remote message from plugin: ${err.message}` })
            })
          } else {
            this.application.consoleMessage({ type: 'error', message: 'Cannot send remote message: Dispatch not ready.' })
          }
        })

        ipcRenderer.on('plugin-connection-message', (event, msg) => {
          if (this.application.dispatch && typeof this.application.dispatch.sendConnectionMessage === 'function') {
            this.application.dispatch.sendConnectionMessage(msg).catch(err => {
              this.application.consoleMessage({ type: 'error', message: `Error sending connection message from plugin: ${err.message}` })
            })
          } else {
            this.application.consoleMessage({ type: 'error', message: 'Cannot send connection message: Dispatch not ready.' })
          }
        })

        ipcRenderer.on('dispatch-get-state-sync', (event, key) => {
          if (this.application.dispatch && typeof this.application.dispatch.getState === 'function') {
            try {
              const value = this.application.dispatch.getState(key)
              event.returnValue = value
            } catch (error) {
              event.returnValue = null
            }
          } else {
            event.returnValue = null
          }
        })

        ipcRenderer.on('main-renderer-get-state-async', (event, { key, replyChannel }) => {
          let value = null
          if (this.application.dispatch && typeof this.application.dispatch.getState === 'function') {
            try {
              value = this.application.dispatch.getState(key)
            } catch (error) {
              value = null
            }
          } else {
            value = null
          }
          ipcRenderer.send(replyChannel, value)
        })

      } catch (e) {
      }
    }
  }

  /**
   * Sets up IPC listeners for plugin window status updates
   * @public
   */
  setupStatusIndicatorIPC() {
    if (typeof require === "function") {
      try {
        ipcRenderer.on('plugin-window-opened', (event, pluginName) => {
          this.application.pluginUIManager.updatePluginStatusIndicator(pluginName, true)
        })

        ipcRenderer.on('plugin-window-closed', (event, pluginName) => {
          this.application.pluginUIManager.updatePluginStatusIndicator(pluginName, false)
        })
        
        ipcRenderer.on('plugin-window-focused', (event, pluginName) => {
          const $listItem = this.application.$pluginList.find(`li[data-plugin-name="${pluginName}"]`)
          const $indicator = $listItem.find('.plugin-status-indicator')
          if ($indicator.length > 0) {
            $indicator.addClass('plugin-focus-blink')
            setTimeout(() => {
              $indicator.removeClass('plugin-focus-blink')
            }, 1000)
          }
        })

      } catch (e) {
      }
    }
  }

  /**
   * Sets up IPC listeners for game process events
   * @public
   */
  setupGameProcessIPC() {
    if (typeof require === "function") {
      try {
        ipcRenderer.on('game-process-exit', () => {
          this.application.gameLauncher.handleGameProcessExit()
        })

      } catch (e) {
      }
    }
  }
}

module.exports = IPCManager

