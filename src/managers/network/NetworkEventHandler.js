const { ConnectionMessageTypes } = require('../../Constants')

module.exports = class NetworkEventHandler {
  constructor(application, dispatch) {
    this.application = application
    this.dispatch = dispatch
    this._callback = null
    this._isAttached = false
  }

  attach() {
    if (this._isAttached && this._callback) {
      this.detach()
    }

    this._callback = ({ message, type }) => {
      try {
        if (!message || typeof message.toMessage !== 'function') {
          return
        }

        const messageText = message.toMessage()
        if (!messageText) {
          return
        }

        if (typeof require === "function") {
          try {
            const { ipcRenderer } = require('electron')
            
            ipcRenderer.send('packet-event', {
              raw: messageText,
              direction: type === 'aj' ? 'in' : 'out',
              timestamp: Date.now()
            })
          } catch (e) {
          }
        }
        
        if (type === 'aj' && messageText.includes('%xt%l%-1%')) {
          this.application.consoleMessage({
            type: 'success',
            message: 'Successfully logged in!'
          })
        }
        
        this.application.consoleMessage({
          type: 'speech',
          isPacket: true,
          isIncoming: type === 'aj',
          message: messageText
        })
      } catch (error) {
      }
    }

    this.dispatch.onMessage({
      type: ConnectionMessageTypes.any,
      callback: this._callback
    })

    this._isAttached = true
  }

  detach() {
    if (this._isAttached && this._callback) {
      this.dispatch.offMessage({
        type: ConnectionMessageTypes.any,
        message: ConnectionMessageTypes.any,
        callback: this._callback
      })
      this._isAttached = false
      this._callback = null
    }
  }
}

