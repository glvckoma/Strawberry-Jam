const Client = require('../client')
const net = require('net')
const { TCP_SERVER_PORTS } = require('../../Constants')

module.exports = class Server {
  constructor (application) {
    this.application = application
    this.server = null
    this.clients = new Set()
    this.actualPort = null
    this._port = TCP_SERVER_PORTS[0]
    this._ensureDefaultSettings()
  }

  _ensureDefaultSettings() {
    if (!this.application || !this.application.settings) {
      return
    }

    try {
      const defaultSettings = {
        smartfoxServer: 'lb-iss02-classic-prod.animaljam.com',
        secureConnection: true,
        autoReconnect: true
      }

      for (const [key, defaultValue] of Object.entries(defaultSettings)) {
        try {
          const currentValue = this.application.settings.get(key)

          if (key === 'smartfoxServer') {
            if (!currentValue || typeof currentValue !== 'string' || !currentValue.includes('animaljam')) {
              this.application.settings.update(key, defaultValue)
            }
          } else if (typeof defaultValue === 'boolean' && typeof currentValue !== 'boolean') {
            this.application.settings.update(key, defaultValue)
          }
        } catch (settingError) {
          this.application.settings.update(key, defaultValue)
        }
      }
    } catch (error) {
    }
  }

  async _onConnection (connection) {
    try {
      const client = new Client(connection, this)
      await client.connect()

      this.clients.add(client)
    } catch (error) {
      this.application.consoleMessage({
        message: `Unexpected error occurred while trying to connect to the Animal Jam servers. ${error.message}`,
        type: 'error'
      })
    }
  }

  async disconnectAllClients() {
    const disconnectPromises = []

    for (const client of this.clients) {
      if (client && typeof client.disconnect === 'function') {
        disconnectPromises.push(
          Promise.resolve(client.disconnect(true)).catch(err => {
            if (this.application && this.application.consoleMessage) {
              this.application.consoleMessage({
                message: `Error disconnecting client during session cleanup: ${err.message}`,
                type: 'warn'
              })
            }
          })
        )
      }
    }

    await Promise.all(disconnectPromises)
    this.clients.clear()
  }

  async serve () {
    if (this.server) throw new Error('The server has already been instantiated.')

    for (const port of TCP_SERVER_PORTS) {
      const attemptServer = net.createServer(this._onConnection.bind(this))

      const result = await new Promise((resolve) => {
        attemptServer.once('listening', () => {
          this.actualPort = port
          this._port = port
          this.server = attemptServer
          if (this.application && this.application.consoleMessage) {
            this.application.consoleMessage({
              message: `Server listening on port ${port}`,
              type: 'notify'
            })
          }
          resolve(true)
        })
        attemptServer.once('error', (error) => {
          attemptServer.close()
          resolve(false)
        })
        attemptServer.listen(port, '127.0.0.1')
      })

      if (result) {
        this.server.on('error', (error) => {
          this.application.consoleMessage({
            message: `Server encountered an error: ${error.message}`,
            type: 'error'
          })
        })
        return
      }
    }

    throw new Error(`All ports (${TCP_SERVER_PORTS.join(', ')}) are unavailable. Use the /terminate command, then restart.`)
  }

  async close() {
    if (!this.server) {
      return
    }

    const disconnectPromises = []
    
    for (const client of this.clients) {
      if (client && typeof client.disconnect === 'function') {
        disconnectPromises.push(
          Promise.resolve(client.disconnect(true)).catch(err => {
            if (this.application && this.application.consoleMessage) {
              this.application.consoleMessage({
                message: `Error disconnecting client: ${err.message}`,
                type: 'warn'
              })
            }
          })
        )
      }
    }

    await Promise.all(disconnectPromises)
    this.clients.clear()

    return new Promise((resolve) => {
      if (this.server) {
        this.server.close(() => {
          this.server = null
          this.actualPort = null
          resolve()
        })
      } else {
        resolve()
      }
    })
  }
}
