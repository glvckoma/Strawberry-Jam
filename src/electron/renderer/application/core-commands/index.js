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
  console.log('[Core Commands] Registering core commands...');
  
  // Clear command - clears the console logs
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
  
  console.log('[Core Commands] Successfully registered core commands:', Array.from(dispatch.commands.keys()));
}

module.exports = registerCoreCommands; 