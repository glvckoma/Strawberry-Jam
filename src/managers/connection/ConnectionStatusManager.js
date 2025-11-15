const ServerStatusChecker = require('../../services/ServerStatusChecker')

class ConnectionStatusManager {
  constructor(application, ipcRenderer) {
    this.application = application
    this.ipcRenderer = ipcRenderer
    this.serverStatus = {
      isOnline: null,
      lastChecked: 0,
      responseTime: 0,
      server: null,
      accessStatus: 'unknown',
      statusCode: null,
      isChecking: false
    }
  }

  updateConnectionStatus(connected, serverOnline = null) {
    const statusElement = document.getElementById('connection-status')
    if (!statusElement) return
    
    if (serverOnline !== null) {
      this.serverStatus.isOnline = serverOnline
      this.serverStatus.isChecking = false
    }
    
    if (connected) {
      statusElement.querySelector('span:first-child').classList.remove('bg-error-red', 'bg-highlight-yellow', 'bg-tertiary-bg')
      statusElement.querySelector('span:first-child').classList.add('bg-highlight-green')
      statusElement.querySelector('span:last-child').textContent = 'Connected'
      statusElement.querySelector('span:first-child').classList.remove('pulse-animation', 'pulse-yellow', 'pulse-loading')
      statusElement.querySelector('span:first-child').classList.add('pulse-green')
      statusElement.classList.remove('text-gray-400', 'text-highlight-yellow', 'text-error-red')
      statusElement.classList.add('text-highlight-green')
      
      if (this.serverStatus.server) {
        const tooltipText = `Connected to ${this.serverStatus.server} (Response time: ${this.serverStatus.responseTime}ms)`
        statusElement.setAttribute('title', tooltipText)
      }
    } else if (this.serverStatus.isChecking) {
      statusElement.querySelector('span:first-child').classList.remove('bg-error-red', 'bg-highlight-green', 'bg-highlight-yellow')
      statusElement.querySelector('span:first-child').classList.add('bg-tertiary-bg')
      statusElement.querySelector('span:last-child').textContent = 'Checking...'
      statusElement.querySelector('span:first-child').classList.remove('pulse-green', 'pulse-animation')
      statusElement.querySelector('span:first-child').classList.add('pulse-loading')
      statusElement.classList.remove('text-highlight-green', 'text-highlight-yellow', 'text-error-red')
      statusElement.classList.add('text-gray-400')
      
      statusElement.setAttribute('title', 'Checking Animal Jam server status...')
    } else {
      const dotElement = statusElement.querySelector('span:first-child')
      dotElement.classList.remove('bg-highlight-green', 'bg-error-red', 'bg-highlight-yellow', 'bg-tertiary-bg')
      dotElement.classList.remove('pulse-green', 'pulse-animation', 'pulse-loading', 'pulse-yellow')
      statusElement.classList.remove('text-highlight-green', 'text-gray-400', 'text-highlight-yellow', 'text-error-red')
      
      if (this.serverStatus.accessStatus === 'disabled_by_setting') {
        statusElement.querySelector('span:last-child').textContent = 'Disabled in Settings'
        statusElement.classList.add('text-gray-400')
        dotElement.classList.add('bg-tertiary-bg')
        statusElement.setAttribute('title', 'Server status check is disabled in settings.')
      } else if (this.serverStatus.isOnline === true) {
        if (this.serverStatus.accessStatus === 'blocked') {
          statusElement.querySelector('span:last-child').textContent = 'AJ Servers: IP Blocked'
          statusElement.classList.add('text-highlight-yellow')
          dotElement.classList.add('bg-highlight-yellow')
          dotElement.classList.add('pulse-yellow')
          
          statusElement.setAttribute('title', `${this.serverStatus.details || 'Your IP appears to be blocked from accessing the servers'}`)
        }
        else if (this.serverStatus.accessStatus === 'rate_limited') {
          statusElement.querySelector('span:last-child').textContent = 'AJ Servers: Rate Limited'
          statusElement.classList.add('text-highlight-yellow')
          dotElement.classList.add('bg-highlight-yellow')
          dotElement.classList.add('pulse-yellow')
          
          statusElement.setAttribute('title', `${this.serverStatus.details || 'Server is rate limiting requests'}`)
        }
        else if (this.serverStatus.accessStatus === 'auth_error') {
          statusElement.querySelector('span:last-child').textContent = 'AJ Servers: Auth Issues'
          statusElement.classList.add('text-highlight-yellow')
          dotElement.classList.add('bg-highlight-yellow')
          dotElement.classList.add('pulse-yellow')
          
          statusElement.setAttribute('title', `${this.serverStatus.details || 'Authentication service issues'}`)
        }
        else if (this.serverStatus.accessStatus === 'unusual') {
          statusElement.querySelector('span:last-child').textContent = 'AJ Servers: Unusual Status'
          statusElement.classList.add('text-highlight-yellow')
          dotElement.classList.add('bg-highlight-yellow')
          dotElement.classList.add('pulse-yellow')
          
          statusElement.setAttribute('title', `${this.serverStatus.details || 'Server responding with unusual status'}`)
        }
        else {
          statusElement.querySelector('span:last-child').textContent = 'AJ Servers are online!'
          statusElement.classList.add('text-highlight-green')
          dotElement.classList.add('bg-highlight-green')
          dotElement.classList.add('pulse-green')
          
          if (this.serverStatus.details) {
            statusElement.setAttribute('title', `${this.serverStatus.details} (Response time: ${this.serverStatus.responseTime}ms)`)
          } else if (this.serverStatus.server) {
            const tooltipText = `Server ${this.serverStatus.server} is online (Response time: ${this.serverStatus.responseTime}ms)`
            statusElement.setAttribute('title', tooltipText)
          }
        }
      } else if (this.serverStatus.isOnline === false) {
        if (this.serverStatus.accessStatus === 'server_error') {
          statusElement.querySelector('span:last-child').textContent = 'AJ Servers: Error'
        } else if (this.serverStatus.accessStatus === 'network_error') {
          statusElement.querySelector('span:last-child').textContent = 'Cannot Connect to AJ Servers'
        } else {
          statusElement.querySelector('span:last-child').textContent = 'AJ Servers are offline :('
        }
        
        statusElement.classList.add('text-error-red')
        dotElement.classList.add('bg-error-red')
        dotElement.classList.add('pulse-animation')
        
        const lastCheckedTime = new Date(this.serverStatus.lastChecked).toLocaleTimeString()
        const tooltipText = `${this.serverStatus.details || 'Unable to connect to Animal Jam servers'}. Last checked: ${lastCheckedTime}`
        statusElement.setAttribute('title', tooltipText)
      } else {
        statusElement.querySelector('span:last-child').textContent = 'Status Unknown'
        statusElement.classList.add('text-gray-400')
        dotElement.classList.add('bg-tertiary-bg')
        dotElement.classList.add('pulse-animation')
        
        statusElement.setAttribute('title', 'Server status unknown. Type !servers to check status.')
      }
    }
  }

  async checkServerStatus() {
    try {
      this.serverStatus.isChecking = true
      this.updateConnectionStatus(false)
      
      const serverHost = this.application.settings ? 
        this.application.settings.get('smartfoxServer') : 
        'lb-iss02-classic-prod.animaljam.com'
      
      const result = await ServerStatusChecker.checkServerStatus(serverHost)
      
      this.serverStatus = {
        isOnline: result.isOnline,
        lastChecked: Date.now(),
        responseTime: result.responseTime,
        server: result.server || serverHost,
        accessStatus: result.accessStatus || 'unknown',
        statusCode: result.statusCode,
        details: result.details || '',
        isChecking: false
      }
      
      const isConnected = this.application.server && 
                          this.application.server.clients && 
                          this.application.server.clients.size > 0
      
      this.updateConnectionStatus(isConnected, result.isOnline)
      
      if (this.application && this.application.consoleMessage) {
        let displayServer = result.server || serverHost
        if (displayServer.includes('.internal')) {
          displayServer = displayServer.replace(/\.internal$/, '')
          displayServer = 'lb-' + displayServer.replace(/\.(prod|stage)/, '-$1') + '.animaljam.com'
        }
        
        let message = ''
        let messageType = ''
        
        if (result.isOnline) {
          if (result.accessStatus === 'ok') {
            message = `AJ Servers are online! ${displayServer} (${result.responseTime}ms)`
            if (result.details) {
              message += ` - ${result.details}`
            }
            messageType = 'success'
          } else if (result.accessStatus === 'blocked') {
            message = `AJ Servers are online but your IP appears to be blocked. ${displayServer} (${result.responseTime}ms)`
            if (result.details) {
              message += ` - ${result.details}`
            }
            messageType = 'warn'
          } else if (result.accessStatus === 'rate_limited') {
            message = `AJ Servers are online but rate limiting requests. ${displayServer} (${result.responseTime}ms)`
            if (result.details) {
              message += ` - ${result.details}`
            }
            messageType = 'warn'
          } else if (result.accessStatus === 'auth_error') {
            message = `AJ Servers are online but authentication service has issues. ${displayServer}`
            if (result.details) {
              message += ` - ${result.details}`
            }
            messageType = 'warn'
          } else if (result.accessStatus === 'unusual') {
            message = `AJ Servers are responding with unusual status. ${displayServer} (${result.responseTime}ms)`
            if (result.details) {
              message += ` - ${result.details}`
            }
            messageType = 'notify'
          } else {
            message = `AJ Servers are online. ${displayServer} (${result.responseTime}ms)`
            if (result.details) {
              message += ` - ${result.details}`
            }
            messageType = 'success'
          }
        } else {
          if (result.accessStatus === 'server_error') {
            message = `AJ Servers are experiencing errors. ${displayServer}`
          } else if (result.accessStatus === 'network_error') {
            message = `Cannot connect to AJ Servers. ${displayServer}`
          } else {
            message = `AJ Servers appear to be offline. ${displayServer}`
          }
          
          if (result.details) {
            message += ` - ${result.details}`
          }
          messageType = 'error'
        }
        
        this.application.consoleMessage({
          message,
          type: messageType
        })
      }
      
      return result.isOnline
    } catch (error) {
      console.error('Error checking server status:', error)
      
      this.serverStatus.isOnline = null
      this.serverStatus.lastChecked = Date.now()
      this.serverStatus.isChecking = false
      this.serverStatus.accessStatus = 'network_error'
      this.serverStatus.details = `Error checking server status: ${error.message}`
      
      if (this.application && this.application.consoleMessage) {
        this.application.consoleMessage({
          message: `Error checking server status: ${error.message}`,
          type: 'error'
        })
      }
      
      return false
    }
  }

  setupConnectionMonitoring(updateTimestamp, checkEmptyPluginList) {
    setInterval(() => {
      const isConnected = this.application.server && 
                          this.application.server.clients && 
                          this.application.server.clients.size > 0
      if (this.application.dispatch) {
        this.application.dispatch.setState('connected', isConnected)
      }
      this.updateConnectionStatus(isConnected)
      if (updateTimestamp) updateTimestamp()
      if (checkEmptyPluginList) checkEmptyPluginList()
    }, 1000)

    if (this.application) {
      this.application.on('connection:change', (isConnected) => {
        if (typeof require === 'function') {
          try {
            const { ipcRenderer } = require('electron')
            ipcRenderer.send('broadcast-to-plugins', 'connection-status-changed', isConnected)
          } catch (e) {
            console.error('[Renderer] Could not broadcast connection status change to plugins.', e)
          }
        }
      })
    }
    
    if (this.application.server) {
      const originalOnConnection = this.application.server._onConnection
      const self = this
      this.application.server._onConnection = async function(connection) {
        await originalOnConnection.call(this, connection)
        self.updateConnectionStatus(true)
        self.application.consoleMessage({
          message: 'Connected to Animal Jam servers.',
          type: 'success'
        })
      }
    }
  }

  setCheckingState(isChecking) {
    this.serverStatus.isChecking = isChecking
  }

  setAccessStatus(accessStatus) {
    this.serverStatus.accessStatus = accessStatus
  }

  getServerStatus() {
    return this.serverStatus
  }
}

module.exports = ConnectionStatusManager

