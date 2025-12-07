class CommandRegistrar {
  constructor(ipcRenderer) {
    this.ipcRenderer = ipcRenderer
  }

  registerAppCommands(app, checkServerStatus) {
    if (app.dispatch && typeof app.dispatch.onCommand === 'function') {
      app.dispatch.onCommand({
        name: 'servers',
        callback: async (commandData) => {
          const args = commandData.parameters || (Array.isArray(commandData) ? commandData : [])
          app.consoleMessage({
            type: 'notify',
            message: 'Checking Animal Jam server status...'
          })
          
          const isOnline = await checkServerStatus()
          return true
        },
        description: 'Check if Animal Jam servers are online and display status information'
      })

      app.dispatch.onCommand({
        name: 'end',
        callback: async (commandData) => {
          try {
            app.consoleMessage({
              type: 'notify',
              message: 'Ending AJ Classic processes...'
            })

            const result = await this.ipcRenderer.invoke('end-aj-classic-processes')
            
            if (result.success) {
              app.consoleMessage({
                type: 'success',
                message: `Successfully ended ${result.processCount} AJ Classic processes`
              })
            } else {
              app.consoleMessage({
                type: 'error',
                message: `Failed to end processes: ${result.error}`
              })
            }
          } catch (error) {
            app.consoleMessage({
              type: 'error',
              message: `Error ending processes: ${error.message}`
            })
          }
          return true
        },
        description: 'Ends all AJ Classic.exe processes'
      })

      app.dispatch.onCommand({
        name: 'terminate',
        callback: async (commandData) => {
          try {
            app.consoleMessage({
              type: 'wait',
              message: 'Checking ports 443 and 8080...'
            })

            const PortChecker = require('../../utils/PortChecker')
            const port443Busy = await PortChecker.isPortBusy(443)
            const port8080Busy = await PortChecker.isPortBusy(8080)

            if (!port443Busy && !port8080Busy) {
              app.consoleMessage({
                type: 'notify',
                message: 'Ports 443 and 8080 are not in use. No action needed.'
              })
              return true
            }

            const portsToTerminate = []
            if (port443Busy) {
              portsToTerminate.push(443)
              const processInfo = await PortChecker.findProcessUsingPort(443)
              if (processInfo) {
                app.consoleMessage({
                  type: 'warn',
                  message: `Port 443 is busy: Process ${processInfo.processName || 'Unknown'} (PID: ${processInfo.pid})`
                })
              } else {
                app.consoleMessage({
                  type: 'warn',
                  message: 'Port 443 is busy: Unable to identify process'
                })
              }
            }

            if (port8080Busy) {
              portsToTerminate.push(8080)
              const processInfo = await PortChecker.findProcessUsingPort(8080)
              if (processInfo) {
                app.consoleMessage({
                  type: 'warn',
                  message: `Port 8080 is busy: Process ${processInfo.processName || 'Unknown'} (PID: ${processInfo.pid})`
                })
              } else {
                app.consoleMessage({
                  type: 'warn',
                  message: 'Port 8080 is busy: Unable to identify process'
                })
              }
            }

            for (const port of portsToTerminate) {
              try {
                const result = await this.ipcRenderer.invoke('terminate-port', port)
                if (result.success) {
                  app.consoleMessage({
                    type: 'success',
                    message: result.message
                  })
                } else {
                  app.consoleMessage({
                    type: 'error',
                    message: result.message
                  })
                }
              } catch (error) {
                app.consoleMessage({
                  type: 'error',
                  message: `Failed to terminate port ${port}: ${error.message}`
                })
              }
            }

            app.consoleMessage({
              type: 'notify',
              message: 'Terminate command completed. Please restart the application if needed.'
            })
            return true
          } catch (error) {
            app.consoleMessage({
              type: 'error',
              message: `Error in terminate command: ${error.message}`
            })
            return false
          }
        },
        description: 'Terminates processes using ports 443 or 8080'
      })
    } else if (typeof app.registerConsoleCommand === 'function') {
      app.registerConsoleCommand(
        'servers',
        async (args) => {
          app.consoleMessage({
            type: 'notify',
            message: 'Checking Animal Jam server status...'
          })
          
          const isOnline = await checkServerStatus()
          return true
        },
        'Check if Animal Jam servers are online and display status information'
      )
    }
  }
}

module.exports = CommandRegistrar

