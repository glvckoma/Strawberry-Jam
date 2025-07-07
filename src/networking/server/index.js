const Client = require('../client')
const net = require('net')

module.exports = class Server {
  /**
   * Constructor.
   * @constructor
   */
  constructor (application) {
    /**
     * The application that instantiated this server.
     * @type {Application}
     * @public
     */
    this.application = application

    /**
     * The server instance.
     * @type {?net.Server}
     * @public
     */
    this.server = null

    /**
     * The client that has connected to the server.
     * @type {Set<Client>}
     * @public
     */
    this.clients = new Set()
    
    /**
     * The actual port the server is listening on.
     * @type {?number}
     * @public
     */
    this.actualPort = null

    /**
     * Fallback ports to try if the primary port is busy.
     * @type {number[]}
     * @private
     */
    this._fallbackPorts = [443, 444, 445, 8443, 9443]
    
    // Ensure proper default settings
    this._ensureDefaultSettings()
  }
  
  /**
   * Ensure default settings for networking are present
   * @private
   */
  _ensureDefaultSettings() {
    // Skip if settings unavailable
    if (!this.application || !this.application.settings) {
      return;
    }

    try {
      // Define default networking settings
      const defaultSettings = {
        smartfoxServer: 'lb-iss04-classic-prod.animaljam.com',
        secureConnection: true,
        autoReconnect: true
      };

      // Check and apply defaults for each setting
      for (const [key, defaultValue] of Object.entries(defaultSettings)) {
        try {
          // Get current value
          const currentValue = this.application.settings.get(key);
          
          // If value is missing or invalid, set default
          if (key === 'smartfoxServer') {
            if (!currentValue || typeof currentValue !== 'string' || !currentValue.includes('animaljam')) {
              this.application.settings.update(key, defaultValue);
            }
          } else if (typeof defaultValue === 'boolean' && typeof currentValue !== 'boolean') {
            // Handle boolean settings
            this.application.settings.update(key, defaultValue);
          }
        } catch (settingError) {
          // If getting setting fails, set the default
          this.application.settings.update(key, defaultValue);
        }
      }
    } catch (error) {
      // Don't log - just fail silently
    }
  }

  /**
   * Handles new incoming connections.
   * @param {net.Socket} connection
   * @private
   */
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

  /**
   * Create socket and begin listening for new connections.
   * Auto-detects available port starting with 443.
   * @returns {Promise<void>}
   * @public
   */
  async serve () {
    if (this.server) throw new Error('The server has already been instantiated.')

    let lastError = null

    for (const port of this._fallbackPorts) {
      try {
        this.server = net.createServer(this._onConnection.bind(this))

        await new Promise((resolve, reject) => {
          this.server.once('listening', () => {
            this.actualPort = port
            this.application.consoleMessage({
              message: `Server listening on port ${port}`,
              type: 'notify'
            })
            resolve()
          })
          this.server.once('error', reject)

          this.server.listen(port, '127.0.0.1')
        })

        // Success! Break out of loop
        break

      } catch (error) {
        lastError = error
        if (error.code === 'EADDRINUSE') {
          this.application.consoleMessage({
            message: `Port ${port} is busy, trying next port...`,
            type: 'warn'
          })
          this.server = null // Reset for next attempt
          continue
        } else {
          // Re-throw non-port-busy errors immediately
          throw error
        }
      }
    }

    if (!this.server) {
      const errorMessage = `Could not find an available port after trying ports: ${this._fallbackPorts.join(', ')}`
      this.application.consoleMessage({
        message: errorMessage,
        type: 'error'
      })
      throw new Error(errorMessage + (lastError ? `. Last error: ${lastError.message}` : ''))
    }

    this.server.on('error', (error) => {
      this.application.consoleMessage({
        message: `Server encountered an error: ${error.message}`,
        type: 'error'
      })
    })
  }
}
