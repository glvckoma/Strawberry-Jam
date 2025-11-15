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

