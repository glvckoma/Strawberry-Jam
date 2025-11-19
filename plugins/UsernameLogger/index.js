/**
 * @file index.js - Entry point for Username Logger plugin
 * @author Glockoma
 */

const path = require('path');

// Import modules
const ConfigModel = require('./models/config-model');
const StateModel = require('./models/state-model');
const FileService = require('./services/file-service');
const ApiService = require('./services/api-service');
const LeakCheckService = require('./services/leak-check-service');
const MigrationService = require('./services/migration-service');
const MessageHandlers = require('./handlers/message-handlers');
const CommandHandlers = require('./handlers/command-handlers');
const BatchLogger = require('./utils/batch-logger');
const { getFilePaths } = require('./utils/path-utils');

/**
 * UsernameLogger plugin for collecting and analyzing usernames
 */
class UsernameLogger {
  /**
   * Creates a new UsernameLogger instance
   * @param {Object} options - Plugin options
   * @param {Object} options.application - The application object
   * @param {Object} options.dispatch - The dispatch object
   * @param {string} options.dataPath - The application data path
   */
  constructor({ application, dispatch, dataPath }) {
    this.application = application;
    this.dispatch = dispatch;
    this.dataPath = dataPath; // Keep the original dataPath for migration purposes.

    // Establish the dedicated storage path for the plugin.
    const appRoamingPath = path.resolve(this.dataPath, '..');
    this.pluginStoragePath = path.join(appRoamingPath, 'UsernameLogger');

    // The main config file now resides in our dedicated folder.
    this.configFilePath = path.join(this.pluginStoragePath, 'config.json');
    this.isLoggingCurrentlyEnabled = null;

    // Initialize components, now using the new centralized path.
    this._initializeComponents();

    // Initialize plugin.
    this._initialize();
  }
  
  /**
   * Initializes all components and services
   * @private
   */
  _initializeComponents() {
    // Create models
    this.configModel = new ConfigModel({
      application: this.application,
      configFilePath: this.configFilePath
    });
    
    this.stateModel = new StateModel({
      application: this.application
    });
    
    // Create services, passing the new pluginStoragePath to them.
    this.fileService = new FileService({
      application: this.application
    });

    this.apiService = new ApiService({
      application: this.application
    });

    this.batchLogger = new BatchLogger({
      application: this.application,
      pluginStoragePath: this.pluginStoragePath,
      fileService: this.fileService
    });

    this.leakCheckService = new LeakCheckService({
      application: this.application,
      fileService: this.fileService,
      apiService: this.apiService,
      configModel: this.configModel,
      stateModel: this.stateModel,
      pluginStoragePath: this.pluginStoragePath
    });

    this.migrationService = new MigrationService({
      application: this.application,
      fileService: this.fileService,
      configModel: this.configModel,
      // Pass both old and new paths for migration purposes.
      originalDataPath: this.dataPath, // Now correctly passed
      pluginStoragePath: this.pluginStoragePath
    });
    
    // Create handlers, passing the new pluginStoragePath.
    this.messageHandlers = new MessageHandlers({
      application: this.application,
      configModel: this.configModel,
      stateModel: this.stateModel,
      fileService: this.fileService,
      batchLogger: this.batchLogger,
      pluginStoragePath: this.pluginStoragePath
    });

    this.commandHandlers = new CommandHandlers({
      application: this.application,
      configModel: this.configModel,
      stateModel: this.stateModel,
      fileService: this.fileService,
      apiService: this.apiService,
      leakCheckService: this.leakCheckService,
      pluginStoragePath: this.pluginStoragePath
    });
    
    // Set up auto leak check callback
    this.messageHandlers.setAutoLeakCheckCallback(() => {
      this.leakCheckService.runLeakCheck();
    });
  }
  
  /**
   * Initializes the plugin
   * @private
   */
  async _initialize() {
    try {
      // First, ensure the dedicated plugin directory exists.
      await this.fileService.ensureDirectoryExists(this.pluginStoragePath);

      // Load plugin-specific configuration from the new centralized location.
      await this.configModel.loadConfig();

      // Run data migration if needed, AFTER loading config, so the status flag is available.
      await this.migrationService.runMigration();

      // Load ignore list (this can stay as is if it doesn't depend on old paths)
      await this.migrationService.loadIgnoreList(this.stateModel);
      
      // Register command handlers, which should always be active
      this.commandHandlers.registerHandlers(this.dispatch);
      
      // Perform initial configuration based on saved settings
      await this.onSettingsUpdated();
      
      // Refresh autocomplete to include our commands
      if (this.application && typeof this.application.refreshAutoComplete === 'function') {
        this.application.refreshAutoComplete();
      }

      // Expose a function on the window object for the main process to call
      if (typeof window !== 'undefined') {
        window.getUsernameLoggerCounts = async () => {
          if (this.commandHandlers && typeof this.commandHandlers.getUserCountData === 'function') {
            return this.commandHandlers.getUserCountData();
          }
          this.application.consoleMessage({type: 'error', message: '[Username Logger] getUserCountData function not available on commandHandlers.'});
          return null;
        };
        if (process.env.NODE_ENV === 'development') {
          this.application.consoleMessage({type: 'logger', message: '[Username Logger] Exposed getUsernameLoggerCounts on window object.'});
        }
      } else {
        this.application.consoleMessage({type: 'warn', message: '[Username Logger] Window object not available, cannot expose getUsernameLoggerCounts.'});
      }

    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Initialization error: ${error.message}`
      });
    }
  }
  
  /**
   * Fetches the latest settings and reconfigures the plugin's message handlers.
   * This method is called by the dispatch system when settings are updated.
   * @public
   */
  async onSettingsUpdated() {
    try {
      // Get the latest UI settings from the main application settings store
      const currentEnableLogging = await this.application.settings.get('plugins.usernameLogger.collection.enabled', true);
      const currentCollectNearby = await this.application.settings.get('plugins.usernameLogger.collection.collectNearby', true);
      const currentCollectBuddies = await this.application.settings.get('plugins.usernameLogger.collection.collectBuddies', true);
      
      // For other features, not part of this specific logging request but needed for handler config
      const autoCheckEnabled = await this.application.settings.get('plugins.usernameLogger.autoCheck.enabled');
      const autoCheckThreshold = await this.application.settings.get('plugins.usernameLogger.autoCheck.threshold');

      const isInitialState = this.isLoggingCurrentlyEnabled === null;
      const stateChanged = !isInitialState && this.isLoggingCurrentlyEnabled !== currentEnableLogging;
      if (stateChanged) {
        const ignoredCount = this.stateModel.getIgnoredUsernamesCount();
        const message = currentEnableLogging
          ? `Username Logging is enabled${ignoredCount > 0 ? ` - ${ignoredCount} existing usernames will be ignored.` : '.'}`
          : 'Username Logging is disabled.';
        this.application.consoleMessage({
          type: currentEnableLogging ? 'success' : 'warn',
          message
        });
      }

      this.isLoggingCurrentlyEnabled = currentEnableLogging;
      // this.wasCollectingNearby and this.wasCollectingBuddies are no longer used for logging here.

      // Always unregister handlers first to ensure a clean state
      this.messageHandlers.unregisterHandlers(this.dispatch);

      // Conditionally register message handlers based on the new settings
      if (currentEnableLogging) {
        // Pass the latest settings to the message handler instance, including enableLogging
        this.messageHandlers.updateSettings({
          enableLogging: currentEnableLogging, // Add this
          collectNearby: currentCollectNearby,
          collectBuddies: currentCollectBuddies,
          autoCheckEnabled,
          autoCheckThreshold
        });
        // Register the handlers to start listening to game messages
        this.messageHandlers.registerHandlers(this.dispatch);
      }
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error during re-configuration: ${error.message}`
      });
    }
  }
  
  /**
   * Cleans up resources when plugin is unloaded
   */
  unload() {
    // Flush any pending log batches
    this.batchLogger.forceFlush();
    
    // If a leak check is running, try to stop it
    if (this.stateModel.getLeakCheckState().isRunning) {
      this.leakCheckService.stopLeakCheck();
    }
  }
}

module.exports = UsernameLogger;
