const HttpClient = require('../../services/HttpClient')

/**
 * ServerHostChecker - Checks for Animal Jam server host changes
 * 
 * @module ServerHostChecker
 */
class ServerHostChecker {
  constructor(application) {
    this.application = application
  }

  /**
   * Checks if the Animal Jam server host has changed
   * @returns {Promise<void>}
   * @public
   */
  async check() {
    const DEFAULT_SERVER = 'lb-iss02-classic-prod.animaljam.com'
    
    try {
      const data = await HttpClient.fetchFlashvars()
      
      if (!data || !data.smartfoxServer) {
        const currentServer = this.application.settings.get('smartfoxServer')
        if (!currentServer || typeof currentServer !== 'string' || !currentServer.includes('animaljam')) {
          this.application.settings.update('smartfoxServer', DEFAULT_SERVER)
        }
        return
      }
      
      let { smartfoxServer } = data
      
      if (typeof smartfoxServer === 'string') {
        smartfoxServer = smartfoxServer.replace(/\.(stage|prod)\.animaljam\.internal$/, '-$1.animaljam.com')
        smartfoxServer = `lb-${smartfoxServer}`
        
        if (smartfoxServer && smartfoxServer.includes('animaljam')) {
          try {
            const currentServer = this.application.settings.get('smartfoxServer')
            
            if (smartfoxServer !== currentServer) {
              this.application.settings.update('smartfoxServer', smartfoxServer)
              
              this.application.consoleMessage({
                message: 'Server host has changed. Changes are now being applied.',
                type: 'notify'
              })
            }
          } catch (settingsError) {
            if (this.application.settings && this.application.settings.settings) {
              this.application.settings.settings.smartfoxServer = smartfoxServer
            }
          }
        }
      }
    } catch (error) {
      try {
        const currentServer = this.application.settings.get('smartfoxServer')
        if (!currentServer || typeof currentServer !== 'string' || !currentServer.includes('animaljam')) {
          this.application.settings.update('smartfoxServer', DEFAULT_SERVER)
        }
      } catch (err) {
        if (this.application.settings && this.application.settings.settings) {
          this.application.settings.settings.smartfoxServer = DEFAULT_SERVER
        }
      }
    }
  }
}

module.exports = ServerHostChecker

