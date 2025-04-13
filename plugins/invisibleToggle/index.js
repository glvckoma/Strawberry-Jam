// InvisibleToggle Plugin for Jam
// Toggle invisibility using the AJC mod command.
// WARNING: This is a "mod" command and may violate Animal Jam's Terms of Service. Use at your own risk.
//
// Usage: Type !invis in the Jam console or call window.toggleInvis() in the browser console to toggle invisibility ON/OFF.

class InvisibleToggle {
  constructor({ dispatch }) {
    this.dispatch = dispatch;
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
      console.info('InvisibleToggle: Registered !invis command. Type !invis in the Jam console to toggle invisibility.');
    }
    console.info('InvisibleToggle loaded. Use !invis in the Jam console or window.toggleInvis() in the browser console to toggle invisibility.');
  }

  toggleInvis() {
    if (!this.dispatch) {
      console.error('InvisibleToggle: dispatch object not found. Plugin cannot function.');
      return;
    }

    if (!this.isInvisible) {
      // Invisibility ON: %xt%fi%-1%
      this.dispatch.sendConnectionMessage('%xt%fi%-1%');
      this.isInvisible = true;
      console.info('InvisibleToggle: Invisibility ON (sent %xt%fi%-1%)');
    } else {
      // Invisibility OFF: %xt%fi%-1%0%
      this.dispatch.sendConnectionMessage('%xt%fi%-1%0%');
      this.isInvisible = false;
      console.info('InvisibleToggle: Invisibility OFF (sent %xt%fi%-1%0%)');
    }
  }
}

module.exports = InvisibleToggle;
