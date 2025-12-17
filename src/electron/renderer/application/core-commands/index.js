function registerCoreCommands(dispatch, application) {
  dispatch.onCommand({
    name: 'clear',
    description: 'Clears the console logs',
    callback: () => {
      const $mainLogContainer = $('#messages');
      const $packetLogContainer = $('#packetMessages');
      
      if ($mainLogContainer.length) {
        $mainLogContainer.empty();
      }
      
      if ($packetLogContainer.length) {
        $packetLogContainer.empty();
      }
      
      application._packetLogCount = 0;
      application._appMessageCount = 0;
      
      application.consoleMessage({
        type: 'notify',
        message: 'Console logs cleared'
      });
    }
  });

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
