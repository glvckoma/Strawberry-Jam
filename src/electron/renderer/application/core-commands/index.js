/**
 * Core commands for the application.
 * These are basic commands that are available in the console.
 */

/**
 * Register core commands with the dispatch system.
 * @param {import('../dispatch')} dispatch - The dispatch instance.
 * @param {import('../')} application - The application instance.
 */
function registerCoreCommands(dispatch, application) {
  
  dispatch.onCommand({
    name: 'clear',
    description: 'Clears the console logs',
    callback: () => {
      // Find and clear the message containers
      const $mainLogContainer = $('#messages');
      const $packetLogContainer = $('#packetMessages');
      
      // Clear both message containers
      if ($mainLogContainer.length) {
        $mainLogContainer.empty();
      }
      
      if ($packetLogContainer.length) {
        $packetLogContainer.empty();
      }
      
      // Reset message counters
      application._packetLogCount = 0;
      application._appMessageCount = 0;
      
      // Display confirmation
      application.consoleMessage({
        type: 'notify',
        message: 'Console logs cleared'
      });
    }
  });

  // Help command - shows available commands
  dispatch.onCommand({
    name: 'help',
    description: 'Shows available commands',
    callback: () => {
      const commands = Array.from(dispatch.commands.values());
      
      if (commands.length === 0) {
        application.consoleMessage({
          type: 'notify',
          message: 'No commands available'
        });
        return;
      }
      
      // Group commands by type (core, game plugins, etc.)
      const coreCommands = commands.filter(cmd => 
        ['clear', 'help', 'servers', 'end', 'terminate'].includes(cmd.name)
      );
      
      const gameCommands = commands.filter(cmd => 
        !['clear', 'help', 'servers', 'end'].includes(cmd.name)
      );
      
      application.consoleMessage({
        type: 'notify',
        message: 'Available commands:'
      });
      
      if (coreCommands.length > 0) {
        application.consoleMessage({
          type: 'notify',
          message: `Core commands: ${coreCommands.map(cmd => cmd.name).join(', ')}`
        });
      }
      
      if (gameCommands.length > 0) {
        application.consoleMessage({
          type: 'notify',
          message: `Game commands: ${gameCommands.map(cmd => cmd.name).join(', ')}`
        });
      }
      
      application.consoleMessage({
        type: 'notify',
        message: 'Use Tab to autocomplete commands, Enter to execute'
      });
    }
  });
}

module.exports = registerCoreCommands; 