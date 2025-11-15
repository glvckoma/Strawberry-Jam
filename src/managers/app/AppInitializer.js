class AppInitializer {
  constructor(application, ipcRenderer) {
    this.application = application
    this.ipcRenderer = ipcRenderer
  }

  async initializeApp(dependencies) {
    const {
      sessionStartTimeRef,
      setupWindowControls,
      setupConnectionMonitoring,
      registerAppCommands,
      checkServerStatus,
      connectionStatusManager
    } = dependencies

    let totalUptime = await this.ipcRenderer.invoke('get-total-uptime')
    const sessionStartTime = new Date()
    sessionStartTimeRef.current = sessionStartTime

    window.addEventListener('beforeunload', () => {
      const now = new Date()
      const sessionDuration = Math.round((now - sessionStartTimeRef.current) / 1000)
      this.ipcRenderer.send('update-total-uptime', totalUptime + sessionDuration)
    })
    
    setupWindowControls()

    try {
      await this.application.instantiate()
      
      this.application.attachNetworkingEvents()
      
      setupConnectionMonitoring()
      
      registerAppCommands(this.application)
      
      if (this.application && typeof this.application.refreshAutoComplete === 'function') {
        this.application.refreshAutoComplete()
      }

      setTimeout(async () => {
        if (this.application && this.application.settings && this.application.settings._isLoaded) {
          const performCheck = this.application.settings.get('ui.performServerCheckOnLaunch', true)
          if (performCheck) {
            await checkServerStatus()
          } else {
            if (connectionStatusManager) {
              connectionStatusManager.setCheckingState(false)
              connectionStatusManager.setAccessStatus('disabled_by_setting')
              const serverStatus = connectionStatusManager.getServerStatus()
              serverStatus.isOnline = null
              serverStatus.lastChecked = Date.now()
              connectionStatusManager.updateConnectionStatus(false, null)
            }
          }
        } else {
          if (this.application && this.application.consoleMessage) {
            this.application.consoleMessage({
              message: '[Startup] Settings not loaded, proceeding with server status check by default.',
              type: 'warn'
            })
          } else {
            console.warn('[Startup] Settings not loaded, proceeding with server status check by default.')
          }
          await checkServerStatus()
        }
      }, 2000)
    } catch (error) {
      this.application.consoleMessage({
        message: `Error during initialization: ${error.message}`,
        type: 'error'
      })
      
      console.error('Initialization error details:', error)
    }
  }
}

module.exports = AppInitializer

