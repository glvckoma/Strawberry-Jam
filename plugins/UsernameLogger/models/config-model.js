/**
 * @file config-model.js - Configuration model for Username Logger plugin
 * @author glvckoma
 */

const fs = require('fs').promises; // Use promises API
const path = require('path');
const { DEFAULT_CONFIG } = require('../constants/constants');

/**
 * Manages plugin configuration including loading, saving, and access
 */
class ConfigModel {
  /**
   * Creates a new configuration model
   * @param {Object} options - Configuration options
   * @param {Object} options.application - The application object for logging
   * @param {string} options.configFilePath - Path to the config file
   */
  constructor({ application, configFilePath }) {
    this.application = application;
    this.configFilePath = configFilePath;
    // this.config is no longer used to store migrated settings.
    // DEFAULT_CONFIG is now empty.
    this.config = { ...DEFAULT_CONFIG };
    this.leakCheckLastProcessedIndex = -1;
  }

  /**
   * Loads only the leakCheckLastProcessedIndex from the plugin's specific config file.
   * Other settings are now fetched from the main application settings.
   * @returns {Promise<boolean>} True if index was loaded successfully or file not found (defaults to -1).
   */
  async loadConfig() {
    try {
      const configData = await fs.readFile(this.configFilePath, 'utf8');
      const savedState = JSON.parse(configData);
      this.leakCheckLastProcessedIndex = savedState.leakCheckLastProcessedIndex ?? -1;
      
      if (process.env.NODE_ENV === 'development') {
        this.application.consoleMessage({
          type: 'logger',
          message: `[Username Logger] Loaded plugin state from ${this.configFilePath}. Index: ${this.leakCheckLastProcessedIndex}`
        });
      }
      return true;
    } catch (error) {
      if (error.code === 'ENOENT') {
        if (process.env.NODE_ENV === 'development') {
          this.application.consoleMessage({
            type: 'warn',
            message: `[Username Logger] Plugin state file not found (${this.configFilePath}). Index defaults to -1.`
          });
        }
      } else {
        if (process.env.NODE_ENV === 'development') {
          this.application.consoleMessage({
            type: 'error',
            message: `[Username Logger] Error loading plugin state: ${error.message}`
          });
        }
      }
      this.leakCheckLastProcessedIndex = -1; // Default on any error
      return false; // Indicate defaults were used or loading failed
    }
  }
  
  /**
   * Saves only the leakCheckLastProcessedIndex to the plugin's specific config file.
   * @returns {Promise<boolean>} True if saved successfully.
   */
  async saveConfig() {
    try {
      const stateToSave = {
        leakCheckLastProcessedIndex: this.leakCheckLastProcessedIndex
      };

      const configDir = path.dirname(this.configFilePath);
      await fs.mkdir(configDir, { recursive: true });
      await fs.writeFile(this.configFilePath, JSON.stringify(stateToSave, null, 2));
      
      if (process.env.NODE_ENV === 'development') {
        this.application.consoleMessage({
          type: 'logger',
          message: `[Username Logger] Saved plugin state (index: ${this.leakCheckLastProcessedIndex}) to ${this.configFilePath}`
        });
      }
      return true;
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error saving plugin state: ${error.message}`
      });
      return false;
    }
  }

  /**
   * This method is deprecated for settings migrated to the main application.
   * It might be used for future purely internal plugin flags not exposed in UI.
   * @param {string} key - The configuration key to update
   * @param {any} value - The new value
   * @returns {boolean} True if the update was valid (only for non-migrated keys)
   */
  updateConfig(key, value) {
    // This method should now only handle settings NOT managed by the main UI.
    // For now, assuming all relevant settings are migrated or handled by main app.
    if (this.config.hasOwnProperty(key)) { // Check against the (now likely empty) this.config
      this.config[key] = value;
      if (process.env.NODE_ENV === 'development') {
        this.application.consoleMessage({
          type: 'warn',
          message: `[Username Logger] updateConfig called for internal key '${key}'. Ensure this is not a migrated setting.`
        });
      }
      return true;
    }
    if (process.env.NODE_ENV === 'development') {
      this.application.consoleMessage({
        type: 'warn',
        message: `[Username Logger] updateConfig called for unknown or migrated key '${key}'. This operation will have no effect on migrated settings.`
      });
    }
    return false;
  }

  /**
   * Gets the combined configuration, fetching relevant values from the main application settings.
   * @returns {Promise<Object>} The combined configuration object.
   */
  async getConfig() {
    const mainSettings = this.application.settings || { get: () => undefined };
    
    // Default values should ideally come from the main application's settings definitions
    // For example, if main app defines 'leakCheck.enableLogging' with a default of true.
    const isLoggingEnabled = await mainSettings.get('leakCheck.enableLogging') ?? false;
    const collectNearbyPlayers = await mainSettings.get('usernameLogger.collectNearbyPlayers') ?? true; // Assuming new key in main settings
    const collectBuddies = await mainSettings.get('usernameLogger.collectBuddies') ?? true; // Assuming new key in main settings
    const autoLeakCheck = await mainSettings.get('leakCheck.autoLeakCheck') ?? false;
    const autoLeakCheckThreshold = await mainSettings.get('leakCheck.autoLeakCheckThreshold') ?? 100;
    // API key is handled by ApiService, not directly part of this config object for security.
    
    return {
      isLoggingEnabled,
      collectNearbyPlayers,
      collectBuddies,
      autoLeakCheck,
      autoLeakCheckThreshold,
      // Any purely internal plugin settings from this.config could be merged here if needed
      ...this.config
    };
  }

  /**
   * Gets the current leak check index
   * @returns {number} The current leak check index
   */
  getLeakCheckIndex() {
    return this.leakCheckLastProcessedIndex;
  }

  /**
   * Sets the last processed leak check index
   * @param {number} index - The index to set
   */
  setLeakCheckIndex(index) {
    if (typeof index === 'number' && !isNaN(index)) {
      this.leakCheckLastProcessedIndex = index;
      return true;
    }
    return false;
  }

  /**
   * Resets configuration to defaults
   * @param {boolean} preserveApiKey - Whether to preserve the API key
   */
  resetConfig(preserveApiKey = true) {
    const apiKey = preserveApiKey ? this.config.leakCheckApiKey : undefined;
    this.config = { ...DEFAULT_CONFIG };
    if (preserveApiKey && apiKey) {
      this.config.leakCheckApiKey = apiKey;
    }
  }
}

module.exports = ConfigModel;
