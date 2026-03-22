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
        description: 'Ends all AJ Classic processes'
      })

      app.dispatch.onCommand({
        name: 'terminate',
        callback: async (commandData) => {
          try {
            const { TCP_SERVER_PORTS, API_SERVER_PORTS } = require('../../Constants')
            const PortChecker = require('../../utils/PortChecker')
            const args = commandData.parameters || (Array.isArray(commandData) ? commandData : [])
            const isConfirm = args.length > 0 && args[0].toLowerCase() === 'confirm'
            const allPorts = [...TCP_SERVER_PORTS, ...API_SERVER_PORTS]

            app.consoleMessage({
              type: 'wait',
              message: `Checking ports ${allPorts.join(', ')}...`
            })

            const busyPorts = []
            for (const port of allPorts) {
              const busy = await PortChecker.isPortBusy(port)
              if (busy) {
                const processInfo = await PortChecker.findProcessUsingPort(port)
                busyPorts.push({ port, processInfo })
              }
            }

            if (busyPorts.length === 0) {
              app.consoleMessage({
                type: 'notify',
                message: 'No processes found on any Strawberry Jam ports. No action needed.'
              })
              return true
            }

            for (const { port, processInfo } of busyPorts) {
              const name = processInfo ? (processInfo.processName || 'Unknown') : 'Unable to identify'
              const pid = processInfo ? ` (PID: ${processInfo.pid})` : ''
              app.consoleMessage({
                type: 'warn',
                message: `Port ${port} is busy: ${name}${pid}`
              })
            }

            if (!isConfirm) {
              app.consoleMessage({
                type: 'notify',
                message: `Found ${busyPorts.length} busy port(s). Run /terminate confirm to kill these processes.`
              })
              return true
            }

            for (const { port } of busyPorts) {
              try {
                const result = await this.ipcRenderer.invoke('terminate-port', port)
                app.consoleMessage({
                  type: result.success ? 'success' : 'error',
                  message: result.message
                })
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
        description: 'Scans Strawberry Jam ports for conflicts. Use /terminate confirm to kill blocking processes.'
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

