const { ConnectionMessageTypes } = require('../../Constants')

module.exports = class MessageDispatcher {
  constructor(hooks, consoleMessage, dispatch) {
    this.hooks = hooks
    this._consoleMessage = consoleMessage
    this._dispatch = dispatch
  }

  async all({ client, type, message }) {
    const ajHooks = type === ConnectionMessageTypes.aj ? this.hooks.aj.get(message.type) || [] : []
    const connectionHooks = type === ConnectionMessageTypes.connection ? this.hooks.connection.get(message.type) || [] : []
    const anyHooks = this.hooks.any.get(ConnectionMessageTypes.any) || []

    const hooks = [...ajHooks, ...connectionHooks, ...anyHooks]

    if (hooks.length > 0) {} else {
    }

    const promises = hooks.map(async (hook, index) => {
      try {
        if (message.type === 'rj' || message.type === 'login') {
        }
        await hook({ client, type, dispatch: this._dispatch, message })
      } catch (error) {
        this._consoleMessage({
          type: 'error',
          message: `Failed hooking packet ${message.type}. ${error.message}`
        })
      }
    })

    await Promise.all(promises)
  }

  async sendMultipleMessages({ type, messages = [] } = {}) {
    if (messages.length === 0) {
      return Promise.resolve()
    }

    const sendFunction = type === ConnectionMessageTypes.aj
      ? this._dispatch.sendRemoteMessage.bind(this._dispatch)
      : this._dispatch.sendConnectionMessage.bind(this._dispatch)

    try {
      await Promise.all(messages.map(sendFunction))
    } catch (error) {
      this._consoleMessage({
        type: 'error',
        message: `Error sending messages: ${error.message}`
      })
    }
  }

  onMessage({ type, message, callback } = {}) {
    const registrationMap = {
      [ConnectionMessageTypes.aj]: this._registerAjHook.bind(this),
      [ConnectionMessageTypes.connection]: this._registerConnectionHook.bind(this),
      [ConnectionMessageTypes.any]: this._registerAnyHook.bind(this)
    }

    const registerHook = registrationMap[type]
    if (registerHook) {
      registerHook({ type, message, callback })
    }
  }

  offMessage({ type, message, callback } = {}) {
    const hooksMap = {
      [ConnectionMessageTypes.aj]: this.hooks.aj,
      [ConnectionMessageTypes.connection]: this.hooks.connection,
      [ConnectionMessageTypes.any]: this.hooks.any
    }

    const specificHooksMap = hooksMap[type]

    if (specificHooksMap) {
      const hookList = specificHooksMap.get(message)
      if (hookList) {
        const index = hookList.indexOf(callback)
        if (index !== -1) {
          hookList.splice(index, 1)
        }
        if (hookList.length === 0) {
          specificHooksMap.delete(message)
        }
      }
    }
  }

  _registerHook(type, { message, callback }) {
    if (!this.hooks[type]) {
      return this._consoleMessage({
        type: 'error',
        message: `Invalid hook type: ${type}`
      })
    }

    const hooksMap = this.hooks[type]
    if (hooksMap.has(message)) {
      hooksMap.get(message).push(callback)
    } else {
      hooksMap.set(message, [callback])
    }
    if (type === 'aj') {}
  }

  _registerConnectionHook(hook) {
    this._registerHook('connection', hook)
  }

  _registerAjHook(hook) {
    this._registerHook('aj', hook)
  }

  _registerAnyHook(hook) {
    this._registerHook('any', { message: ConnectionMessageTypes.any, callback: hook.callback })
  }
}

