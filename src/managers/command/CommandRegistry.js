/**
 * CommandRegistry - Registers console commands
 * 
 * @module CommandRegistry
 */
class CommandRegistry {
  constructor(application) {
    this.application = application
  }

  /**
   * Register a console command
   * @param {string} name - Command name
   * @param {Function} callback - Command callback
   * @param {string} [description] - Command description
   * @returns {boolean} - Success
   * @public
   */
  register(name, callback, description = '') {
    if (!this.application.dispatch || !this.application.dispatch.onCommand) {
      console.error('Cannot register command: dispatch not initialized')
      return false
    }
    
    try {
      this.application.dispatch.onCommand({
        name,
        description: description || `${name} command`,
        callback
      })
      
      this.application.refreshAutoComplete()
      
      return true
    } catch (error) {
      console.error(`Failed to register command ${name}:`, error)
      return false
    }
  }
}

module.exports = CommandRegistry

