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
   * @returns {Promise<void>}
   * @public
   */
  async serve () {
    if (this.server) throw new Error('The server has already been instantiated.')

    this.server = net.createServer(this._onConnection.bind(this))

    await new Promise((resolve, reject) => {
      this.server.once('listening', resolve)
      this.server.once('error', reject)

      this.server.listen(443, '127.0.0.1')
    })

    this.server.on('error', (error) => {
      this.application.consoleMessage({
        message: `Server encountered an error: ${error.message}`,
        type: 'error'
      })
    })
  }
}
