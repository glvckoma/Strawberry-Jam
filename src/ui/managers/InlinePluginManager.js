const path = require('path')

class InlinePluginManager {
  constructor(application) {
    this.application = application
    this._currentPlugin = null
    this._$listSection = null
    this._$pluginHeader = null
    this._$container = null
    this._$iframe = null
    this._$nameSpan = null
  }

  initialize() {
    this._$listSection = $('#pluginsSectionContent')
    this._$pluginHeader = $('#plugins > .flex.items-center.justify-between')
    this._$container = $('#inlinePluginContainer')
    this._$iframe = $('#inlinePluginFrame')
    this._$nameSpan = $('#inlinePluginName')

    $('#inlinePluginBackBtn').on('click', () => this.close())
    $('#inlinePluginPopoutBtn').on('click', () => this.popout())
  }

  open(pluginName) {
    const plugin = this.application.dispatch.plugins.get(pluginName)
    if (!plugin) return

    const { filepath, configuration: { main } } = plugin
    const url = `file://${path.join(filepath, main)}`

    this._currentPlugin = pluginName
    this._$nameSpan.text(pluginName)
    this._$listSection.addClass('hidden')
    this._$pluginHeader.addClass('hidden')
    this._$container.removeClass('hidden')
    this._$iframe.attr('src', url)

    this._$iframe.off('load').on('load', () => {
      this._injectJamBridge()
      if (window._pendingSpammerPacket && pluginName === 'Packet Spammer') {
        const packet = window._pendingSpammerPacket
        window._pendingSpammerPacket = null
        setTimeout(() => {
          try {
            const iframeWin = this._$iframe[0].contentWindow
            if (iframeWin && iframeWin.spammer && iframeWin.spammer.input) {
              iframeWin.spammer.input.value = packet
            } else if (iframeWin && iframeWin.document) {
              const input = iframeWin.document.getElementById('inputTxt')
              if (input) input.value = packet
            }
          } catch (e) {}
        }, 100)
      }
    })

    this.application.pluginUIManager.updatePluginStatusIndicator(pluginName, true)
  }

  close() {
    if (this._currentPlugin) {
      this.application.pluginUIManager.updatePluginStatusIndicator(this._currentPlugin, false)
    }
    this._$iframe.attr('src', 'about:blank')
    this._$container.addClass('hidden')
    this._$listSection.removeClass('hidden')
    this._$pluginHeader.removeClass('hidden')
    this._currentPlugin = null
  }

  popout() {
    if (!this._currentPlugin) return
    const name = this._currentPlugin
    this.close()
    this.application.dispatch.open(name)
  }

  _injectJamBridge() {
    try {
      const iframeWin = this._$iframe[0].contentWindow
      if (!iframeWin) return

      if (!iframeWin.jQuery) {
        iframeWin.jQuery = iframeWin.$ = require('jquery')
      }

      const dispatch = this.application.dispatch
      const app = this.application
      iframeWin.jam = {
        isEmbedded: true,
        ipcRenderer: require('electron').ipcRenderer,
        dispatch: {
          sendRemoteMessage: (msg, options) => dispatch.sendRemoteMessage(msg, options),
          sendConnectionMessage: (msg, options) => dispatch.sendConnectionMessage(msg, options),
          sendMultipleMessages: ({ type, messages = [] } = {}) => {
            const sendFn = type === 'aj'
              ? (msg) => dispatch.sendRemoteMessage(msg)
              : (msg) => dispatch.sendConnectionMessage(msg)
            for (const msg of messages) {
              sendFn(msg)
            }
          },
          getState: (key) => dispatch.getState(key),
          getStateSync: (key) => dispatch.getStateSync(key),
          getConnectedClients: () => dispatch.getConnectedClients(),
          runInBackground: false
        },
        onPacket: iframeWin.jam && iframeWin.jam.onPacket ? iframeWin.jam.onPacket : null,
        showToast: (message, type) => app.consoleMessage({ type: type || 'notify', message }),
        application: {
          consoleMessage: (type, msg) => app.consoleMessage({ type, message: msg })
        }
      }

      const embeddedLink = iframeWin.document.createElement('link')
      embeddedLink.rel = 'stylesheet'
      embeddedLink.href = 'app://assets/styles/plugin-embedded.css'
      iframeWin.document.head.appendChild(embeddedLink)

      iframeWin.close = () => {}

      iframeWin.dispatchEvent(new CustomEvent('jam-ready'))
    } catch (err) {
      console.error('Failed to inject jam bridge:', err)
    }
  }
}

module.exports = InlinePluginManager
