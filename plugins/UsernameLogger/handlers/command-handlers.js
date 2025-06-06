/**
 * @file command-handlers.js - Command handlers for Username Logger
 * @author glvckoma
 */

const path = require('path');
const { getFilePaths } = require('../utils/path-utils');

/**
 * Class for handling user commands
 */
class CommandHandlers {
  /**
   * Creates a new command handlers instance
   * @param {Object} options - Handler options
   * @param {Object} options.application - The application object for logging
   * @param {Object} options.configModel - The config model for configuration
   * @param {Object} options.stateModel - The state model for state management
   * @param {Object} options.fileService - The file service for file operations
   * @param {Object} options.apiService - The API service for API operations
   * @param {Object} options.leakCheckService - The leak check service for leak checking
   * @param {string} options.dataPath - The application data path
   */
  constructor({ application, configModel, stateModel, fileService, apiService, leakCheckService, dataPath }) {
    this.application = application;
    this.configModel = configModel;
    this.stateModel = stateModel;
    this.fileService = fileService;
    this.apiService = apiService;
    this.leakCheckService = leakCheckService;
    this.dataPath = dataPath;
    
    // Bind methods to ensure 'this' context is correct
    this.handleLogCommand = this.handleLogCommand.bind(this);
    this.handleSettingsCommand = this.handleSettingsCommand.bind(this);
    this.handleLeakCheckCommand = this.handleLeakCheckCommand.bind(this);
    this.handleLeakCheckStopCommand = this.handleLeakCheckStopCommand.bind(this);
    this.handleTrimProcessedCommand = this.handleTrimProcessedCommand.bind(this);
    this.handleSetApiKeyCommand = this.handleSetApiKeyCommand.bind(this);
    this.handleUserCountCommand = this.handleUserCountCommand.bind(this);
    // this.handleTestApiKeyCommand = this.handleTestApiKeyCommand.bind(this); // Removed
    // Removed handleSetIndexCommand binding
  }

  /**
   * Detect whether we're in development mode - more reliable than process.env.NODE_ENV
   * @returns {boolean} true if in development mode
   * @private
   */
  _isDevMode() {
    try {
      // In packaged apps, app.asar will be in the path
      return !window.location.href.includes('app.asar');
    } catch (e) {
      return false;
    }
  }

  /**
   * Toggles username logging on/off.
   * @param {Object} params - Command parameters.
   * @param {string[]} params.parameters - Command arguments.
   */
  async handleLogCommand({ parameters }) { // Made async
    const mainAppSettings = this.application.settings || { get: () => undefined, set: async () => {} };
    let currentLoggingStatus = await mainAppSettings.get('leakCheck.enableLogging');
    // Default to true if undefined, to match typical expectation if setting is new
    if (typeof currentLoggingStatus === 'undefined') currentLoggingStatus = true;

    const newValue = !currentLoggingStatus;
    
    try {
      await mainAppSettings.set('leakCheck.enableLogging', newValue);
      this.application.consoleMessage({
        type: newValue ? 'success' : 'notify',
        message: `[Username Logger] Logging ${newValue ? 'enabled' : 'disabled'}.`
      });
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error updating logging status: ${error.message}`
      });
    }
  }

  /**
   * Configures which types of usernames to collect.
   * @param {Object} params - Command parameters.
   * @param {string[]} params.parameters - Command arguments.
   */
  async handleSettingsCommand({ parameters }) { // Made async
    if (parameters.length === 0) {
      // Display current settings
      const config = await this.configModel.getConfig(); // Now async
      const mainAppSettings = this.application.settings || { get: () => undefined }; // Graceful fallback
      const customOutputDir = mainAppSettings.get('leakCheckOutputDir');
      const paths = getFilePaths(this.dataPath, customOutputDir);
      const effectiveOutputDir = customOutputDir && customOutputDir.trim() !== '' ? customOutputDir : path.dirname(paths.potentialAccountsPath);

      const apiKey = await this.apiService.getApiKey();
      const apiKeyStatus = apiKey && apiKey.trim() !== '' ? 'Set' : 'Not Set';

      this.application.consoleMessage({
        type: 'logger',
        message: `[Username Logger] Current Settings (now managed via main UI):`
      });
      this.application.consoleMessage({ type: 'logger', message: `- Logging: ${config.isLoggingEnabled ? 'Enabled' : 'Disabled'}` });
      this.application.consoleMessage({ type: 'logger', message: `- Collect Nearby Players: ${config.collectNearbyPlayers ? 'Yes' : 'No'}` });
      this.application.consoleMessage({ type: 'logger', message: `- Collect Buddies: ${config.collectBuddies ? 'Yes' : 'No'}` });
      this.application.consoleMessage({ type: 'logger', message: `- Auto Leak Check: ${config.autoLeakCheck ? 'Enabled' : 'Disabled'}` });
      this.application.consoleMessage({ type: 'logger', message: `- Auto Leak Check Threshold: ${config.autoLeakCheckThreshold} usernames` });
      this.application.consoleMessage({ type: 'logger', message: `- Input/Processed Files Directory: ${path.dirname(paths.collectedUsernamesPath)}` });
      this.application.consoleMessage({ type: 'logger', message: `- Leak Check Output Directory: ${effectiveOutputDir}` });
      this.application.consoleMessage({ type: 'logger', message: `- LeakCheck API Key: ${apiKeyStatus}` });
      
      this.application.consoleMessage({
        type: 'logger',
        message: `\n[Username Logger] Settings are now primarily managed via the main application's settings UI.`
      });
      
      return;
    }
    
    // Parameters are now mostly informational or for actions not covered by simple value setting.
    const commandAction = parameters[0].toLowerCase();
    // const value = parameters[1]?.toLowerCase(); // Value might not be used for all actions

    if (commandAction === 'reset') {
      // This reset should ideally trigger a reset of the main application's settings
      // for LeakCheck, which is a more complex operation involving IPC.
      // For now, it will only reset the plugin's internal state (like leakCheckLastProcessedIndex).
      this.configModel.setLeakCheckIndex(-1); // Reset index
      await this.configModel.saveConfig(); // Save the reset index
      
      this.application.consoleMessage({
        type: 'success',
        message: `[Username Logger] Plugin state (leak check index) reset. Other settings are managed in the main UI.`
      });
      this.application.consoleMessage({
        type: 'notify',
        message: `[Username Logger] To reset API key, Auto Check, Threshold, etc., please use the main application's settings UI.`
      });
    } else {
      this.application.consoleMessage({
        type: 'warn',
        message: `[Username Logger] Modifying settings via command line is deprecated. Please use the main application's settings UI.`
      });
      this.application.consoleMessage({
        type: 'logger',
        message: `To view current settings, type !userlogsettings (with no parameters).`
      });
    }
  }

  /**
   * Handles the leak check command.
   * @param {Object} params - Command parameters.
   * @param {string[]} params.parameters - Command arguments.
   */
  async handleLeakCheckCommand({ parameters }) {
    try {
      // Always resume from the last processed index by default
      let limit = Infinity;
      let startIndex = this.configModel.getLeakCheckIndex() + 1;
      
      const isDevMode = this._isDevMode();
      
      // Debug log the current saved index
      if (isDevMode) {
        this.application.consoleMessage({
          type: 'logger',
          message: `[Username Logger] Current saved index is ${this.configModel.getLeakCheckIndex()}, will start from ${startIndex}`
        });
      }
      
      if (parameters.length > 0) {
        // Only parameter accepted is a number for the limit
        const param = parameters[0].toLowerCase();
        
        if (param === 'all') {
          // Process all remaining usernames (already the default with Infinity)
          if (isDevMode) {
            this.application.consoleMessage({
              type: 'notify',
              message: `[Username Logger] Processing all remaining usernames from index ${startIndex}.`
            });
          } else {
            this.application.consoleMessage({
              type: 'notify',
              message: `[Username Logger] Processing all remaining usernames.`
            });
          }
        } else {
          // Try to parse as a number (limit)
          const num = parseInt(param, 10);
          if (isNaN(num) || num <= 0) {
            this.application.consoleMessage({
              type: 'error',
              message: `[Username Logger] Invalid parameter. Use a positive number or 'all'.`
            });
            return;
          }
          
          limit = num;
          if (isDevMode) {
            this.application.consoleMessage({
              type: 'notify',
              message: `[Username Logger] Processing up to ${limit} usernames from index ${startIndex}.`
            });
          } else {
            this.application.consoleMessage({
              type: 'notify',
              message: `[Username Logger] Processing up to ${limit} usernames.`
            });
          }
        }
      } else {
        // No parameters - default is to process all remaining
        if (isDevMode) {
          this.application.consoleMessage({
            type: 'notify',
            message: `[Username Logger] Processing all remaining usernames from index ${startIndex}.`
          });
        } else {
          this.application.consoleMessage({
            type: 'notify',
            message: `[Username Logger] Processing all remaining usernames.`
          });
        }
      }
      
      // Run the leak check with the determined parameters
      this.leakCheckService.runLeakCheck({ limit, startIndex });
    } catch (error) {
      // Silent error handling to avoid breaking the app
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error starting leak check: ${error.message}`
      });
    }
  }

  /**
   * Handles the leak check stop command.
   */
  handleLeakCheckStopCommand() {
    try {
      this.leakCheckService.stopLeakCheck();
    } catch (error) {
      // Silent error handling
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error stopping leak check: ${error.message}`
      });
    }
  }

  /**
   * Trims already processed usernames from the collected_usernames.txt file
   * and resets the index to -1 (next check will start at 0).
   */
  async handleTrimProcessedCommand() {
    try {
      const { collectedUsernamesPath } = getFilePaths(this.dataPath);
      const processedIndex = this.configModel.getLeakCheckIndex();
      const isDevMode = this._isDevMode();
      
      // Check if leak check is running
      if (this.stateModel.getLeakCheckState().isRunning) {
        this.application.consoleMessage({
          type: 'warn',
          message: `[Username Logger] Cannot trim usernames while leak check is running. Stop the check first.`
        });
        return;
      }
      
      // Show processing message
      this.application.consoleMessage({
        type: 'notify',
        message: `[Username Logger] Processing usernames for trimming... This might take a moment for large files.`
      });
      
      // Configure options for large files
      const trimOptions = {
        chunkSize: 5000,
        safeMode: true
      };
      
      if (isDevMode) {
        this.application.consoleMessage({
          type: 'logger',
          message: `[Username Logger] Using optimized chunked processing for large files.`
        });
      }
      
      // Trim processed usernames with enhanced options
      const result = await this.fileService.trimProcessedUsernames(
        collectedUsernamesPath, 
        processedIndex,
        trimOptions
      );
      
      if (result) {
        // Reset the index
        this.configModel.setLeakCheckIndex(-1);
        
        // Save the config to persist the index change
        const saveSuccess = await this.configModel.saveConfig();
        
        if (!saveSuccess) {
          this.application.consoleMessage({
            type: 'error',
            message: `[Username Logger] Warning: Index was reset but failed to save config. Changes may not persist.`
          });
        }
        
        if (isDevMode) {
          this.application.consoleMessage({
            type: 'success',
            message: `[Username Logger] Index reset to -1. Next leak check will start from index 0.`
          });
        } else {
          this.application.consoleMessage({
            type: 'success',
            message: `[Username Logger] Processed usernames trimmed. Next check will start from the beginning.`
          });
        }
      } else {
        this.application.consoleMessage({
          type: 'error',
          message: `[Username Logger] Failed to trim processed usernames. Check logs for details.`
        });
      }
    } catch (error) {
      // More detailed error handling
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error trimming processed usernames: ${error.message}`
      });
      
      // Log stack trace in development mode
      const isDevMode = this._isDevMode();
      if (isDevMode) {
        this.application.consoleMessage({
          type: 'error',
          message: `[Username Logger] Error stack trace: ${error.stack}`
        });
      }
    }
  }

  /**
   * Handles the set API key command.
   * @param {Object} params - Command parameters.
   * @param {string[]} params.parameters - Command arguments.
   */
  async handleSetApiKeyCommand({ parameters }) {
    try {
      if (parameters.length === 0) {
        this.application.consoleMessage({
          type: 'warn',
          message: '[Username Logger] Please specify an API key. Usage: !setapikey YOUR_API_KEY'
        });
        
        // Show guidance on how to get an API key
        this.application.consoleMessage({
          type: 'logger',
          message: '[Username Logger] You need a LeakCheck.io API key to check usernames against leak databases.'
        });
        
        return;
      }
      
      // Use the first parameter as the API key
      const apiKey = parameters[0];
      
      // Basic validation - just ensure it's a non-empty string
      if (typeof apiKey !== 'string' || apiKey.trim() === '') {
        this.application.consoleMessage({
          type: 'error',
          message: `[Username Logger] Invalid API key format. API key cannot be empty.`
        });
        return;
      }
      
      // Log what we're setting (partially masked)
      if (apiKey.length > 8) {
        const masked = apiKey.substring(0, 4) + '...' + apiKey.substring(apiKey.length - 4);
        this.application.consoleMessage({
          type: 'logger',
          message: `[Username Logger] Setting API key: ${masked}`
        });
      }
      
      // Try to set it in the application settings
      const saveResult = await this.apiService.setApiKey(apiKey);
      
      if (saveResult) {
        this.application.consoleMessage({
          type: 'success',
          message: `[Username Logger] LeakCheck API key saved successfully. You can now use !leakcheck to check usernames.`
        });
      } else {
        this.application.consoleMessage({
          type: 'error',
          message: `[Username Logger] Failed to save API key. Please try again or check application logs.`
        });
      }
    } catch (error) {
      // Silent error handling
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error setting API key: ${error.message}`
      });
    }
  }

  // Removed handleTestApiKeyCommand method

  // Removed handleSetIndexCommand method

  /**
   * Fetches username count data.
   * @returns {Promise<Object|null>} An object with counts or null on error.
   */
  async getUserCountData() {
    try {
      const mainAppSettings = this.application.settings || { get: () => undefined };
      const customOutputDir = mainAppSettings.get('leakCheckOutputDir');
      const { collectedUsernamesPath, processedUsernamesPath, foundAccountsPath, ajcAccountsPath, potentialAccountsPath, workingAccountsPath } = getFilePaths(this.dataPath, customOutputDir);

      const counts = {};
      const collectedUsernames = await this.fileService.readUsernamesFromLog(collectedUsernamesPath);
      counts.collected = collectedUsernames.length;
      const processedUsernames = await this.fileService.readLinesFromFile(processedUsernamesPath);
      counts.processed = processedUsernames.length;
      const foundGeneral = await this.fileService.readLinesFromFile(foundAccountsPath);
      counts.foundGeneral = foundGeneral.length;
      const foundAjc = await this.fileService.readLinesFromFile(ajcAccountsPath);
      counts.foundAjc = foundAjc.length;
      const potentialInvalid = await this.fileService.readLinesFromFile(potentialAccountsPath);
      counts.potentialInvalid = potentialInvalid.length;
      const working = await this.fileService.readLinesFromFile(workingAccountsPath);
      counts.working = working.length;
      counts.totalUnique = new Set([...collectedUsernames, ...processedUsernames]).size;
      counts.currentIndex = this.configModel.getLeakCheckIndex();
      
      return counts;
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error fetching user count data: ${error.message}`
      });
      if (this._isDevMode()) {
        this.application.consoleMessage({
          type: 'error',
          message: `[Username Logger] getUserCountData stack trace: ${error.stack}`
        });
      }
      return null;
    }
  }

  /**
   * Displays counts of usernames in various log files
   */
  async handleUserCountCommand() {
    this.application.consoleMessage({
      type: 'notify',
      message: `[Username Logger] Counting usernames in files...`
    });
    
    const countsData = await this.getUserCountData();
    
    if (countsData) {
      const countsSummary = `Collected: ${countsData.collected}, Processed: ${countsData.processed}, Total Unique: ${countsData.totalUnique}, Found (Gen/AJC): ${countsData.foundGeneral}/${countsData.foundAjc}, Working: ${countsData.working}, Potential (Invalid): ${countsData.potentialInvalid}, Index: ${countsData.currentIndex}`;
      this.application.consoleMessage({
        type: 'success',
        message: `[Username Logger] Counts: ${countsSummary}`
      });
    } else {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Could not retrieve username counts.`
      });
    }
  }

  /**
   * Registers all command handlers with the dispatch system
   * @param {Object} dispatch - The dispatch system
   */
  registerHandlers(dispatch) {
    try {
      // dispatch.onCommand({ // !userlog command removed as this is now a UI setting
      //   name: 'userlog',
      //   description: 'Toggles username logging on/off.',
      //   callback: this.handleLogCommand
      // });
      
      dispatch.onCommand({
        name: 'leakcheck',
        description: 'Run a leak check on collected usernames. Usage: !leakcheck [all|number]',
        callback: this.handleLeakCheckCommand
      });

      dispatch.onCommand({
        name: 'leakcheckstop',
        description: 'Stop a running leak check.',
        callback: this.handleLeakCheckStopCommand
      });
      
      // dispatch.onCommand({ // !setapikey command removed as this is now a UI setting
      //   name: 'setapikey',
      //   description: 'Sets the LeakCheck API key. Usage: !setapikey YOUR_API_KEY',
      //    callback: this.handleSetApiKeyCommand
      //  });
 
       // Removed testapikey command registration
 
       // Removed setindex command registration
      
    } catch (error) {
      // Silent error handling
      console.error('[Username Logger] Error registering command handlers:', error);
    }
  }
}

module.exports = CommandHandlers;
