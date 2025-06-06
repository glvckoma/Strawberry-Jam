/**
 * Strawberry Jam - Plugin Template
 * 
 * This is a template for creating new plugins with standardized
 * UI components and functionality.
 */

// Plugin class
class PluginTemplate {
  constructor() {
    this.initialized = false;
    
    // Initialize the plugin when document is ready
    this.init();
  }

  /**
   * Initialize the plugin
   */
  init() {
    if (this.initialized) return;
    
    // Set up event listeners
    this.setupEventListeners();
    
    console.log('[Plugin Template] Initialized');
    this.initialized = true;
  }

  /**
   * Set up event listeners for the plugin's UI elements
   */
  setupEventListeners() {
    // Example of setting up a button click event
    const actionButton = document.querySelector('button:last-child');
    if (actionButton) {
      actionButton.addEventListener('click', () => {
        this.handleAction();
      });
    }
  }

  /**
   * Handle primary action button click
   */
  handleAction() {
    console.log('[Plugin Template] Action button clicked');
    
    // Example of showing a notification
    this.showNotification('Action performed successfully!');
  }

  /**
   * Show a notification message
   * @param {string} message - The message to display
   * @param {string} type - The type of notification (success, error, warning)
   */
  showNotification(message, type = 'success') {
    // This is just a placeholder - implement your own notification system
    // or use the main application's notification system if available
    console.log(`[Plugin Template] ${type.toUpperCase()}: ${message}`);
    
    // Example: Show an alert (you would typically use something nicer)
    alert(message);
  }
}

// Initialize the plugin
window.pluginTemplate = new PluginTemplate(); 