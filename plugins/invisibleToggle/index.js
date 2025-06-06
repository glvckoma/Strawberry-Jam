// InvisibleToggle Plugin for Jam
// Toggle invisibility using the AJC mod command.
// WARNING: This is a "mod" command and may violate Animal Jam's Terms of Service. Use at your own risk.
//
// Usage: Type !invis in the Jam console or call window.toggleInvis() in the browser console to toggle invisibility ON/OFF.

module.exports = function ({ dispatch, application }) { // Added application to parameters for consistency, though not used by this specific plugin
  class InvisibleToggle {
    constructor() { // dispatch is now available from the outer function's scope
      this.dispatch = dispatch; // Use dispatch from the outer scope
      this.isInvisible = false;

      // Attach the toggle function to the window for user access
      window.toggleInvis = this.toggleInvis.bind(this);

      // Register a chat/console command: !invis
      if (this.dispatch && typeof this.dispatch.onCommand === 'function') {
        this.dispatch.onCommand({
          name: 'invis',
          description: 'Toggle invisibility ON/OFF (InvisibleToggle plugin). Usage: !invis',
          callback: () => this.toggleInvis()
        });
      } else {
        if (application && application.consoleMessage) {
           application.consoleMessage({ type: 'error', message: 'InvisibleToggle: Dispatch or onCommand not available.' });
        } else {
           console.error('InvisibleToggle: Dispatch or onCommand not available.');
        }
      }
    }

    toggleInvis() {
      if (!this.dispatch) {
        if (application && application.consoleMessage) {
          application.consoleMessage({ type: 'error', message: 'InvisibleToggle: dispatch object not found. Plugin cannot function.'});
        } else {
          console.error('InvisibleToggle: dispatch object not found. Plugin cannot function.');
        }
        return;
      }

      if (!this.isInvisible) {
        // Invisibility ON: %xt%fi%-1%
        this.dispatch.sendConnectionMessage('%xt%fi%-1%');
        this.isInvisible = true;
        // console.info('InvisibleToggle: Invisibility ON (sent %xt%fi%-1%)'); // Original dev log
        console.log('[Invisible Toggle] Invisibility ON. Please re-enter the room for changes to take full effect.');
      } else {
        // Invisibility OFF: %xt%fi%-1%0%
        this.dispatch.sendConnectionMessage('%xt%fi%-1%0%');
        this.isInvisible = false;
        // console.info('InvisibleToggle: Invisibility OFF (sent %xt%fi%-1%0%)'); // Original dev log
        console.log('[Invisible Toggle] Invisibility OFF. Please re-enter the room for changes to take full effect.');
      }
    }
  }

  // Instantiate the plugin
  return new InvisibleToggle();
};
