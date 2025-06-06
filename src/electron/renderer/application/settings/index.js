const { ipcRenderer } = require('electron')
const { debounce } = require('lodash')

// Default values for critical settings
const DEFAULT_SETTINGS = {
  smartfoxServer: 'lb-iss04-classic-prod.animaljam.com',
  secureConnection: true,
  leakCheckApiKey: '',
  leakCheckOutputDir: '',
  autoReconnect: true,
  preventAutoLogin: false,
  // Old flat keys:
  // hideGamePlugins: false,
  // performServerCheckOnLaunch: true // New setting

  // New keys matching electron-store structure for UI settings
  'ui.hideGamePlugins': false,
  'ui.performServerCheckOnLaunch': true,

  // UsernameLogger and LeakCheck specific settings
  'leakCheck.enableLogging': true,
  'leakCheck.autoLeakCheck': false,
  'leakCheck.autoLeakCheckThreshold': 100,
  'usernameLogger.collectNearbyPlayers': true,
  'usernameLogger.collectBuddies': true
}

// Development mode check (safer than process.env which may be undefined in packaged app)
const isDevelopment = typeof process !== 'undefined' &&
                      process.env &&
                      process.env.NODE_ENV === 'development';

module.exports = class Settings {
  constructor () {
    // Pre-initialize settings with defaults
    this.settings = {...DEFAULT_SETTINGS}
    this._isLoaded = false
    this._saveSettingsDebounced = debounce(this._saveSettings.bind(this), 500, { maxWait: 2000 })
  }

  /**
   * Loads settings from electron store via IPC
   * @returns {Promise<void>}
   * @public
   */
  async load () {
    // Removed initial "Loading settings..." log
    try {
      // Initialize with defaults first to ensure we have valid values
      this.settings = {...DEFAULT_SETTINGS}

      const settingsToLoad = [
        { key: 'smartfoxServer', defaultValue: DEFAULT_SETTINGS.smartfoxServer },
        { key: 'secureConnection', defaultValue: DEFAULT_SETTINGS.secureConnection },
        { key: 'leakCheckApiKey', defaultValue: DEFAULT_SETTINGS.leakCheckApiKey },
        { key: 'leakCheckOutputDir', defaultValue: DEFAULT_SETTINGS.leakCheckOutputDir },
        { key: 'autoReconnect', defaultValue: DEFAULT_SETTINGS.autoReconnect },
        { key: 'preventAutoLogin', defaultValue: DEFAULT_SETTINGS.preventAutoLogin },
        { key: 'ui.hideGamePlugins', defaultValue: DEFAULT_SETTINGS['ui.hideGamePlugins'] },
        { key: 'ui.performServerCheckOnLaunch', defaultValue: DEFAULT_SETTINGS['ui.performServerCheckOnLaunch'] },
        // Added UsernameLogger and LeakCheck settings
        { key: 'leakCheck.enableLogging', defaultValue: DEFAULT_SETTINGS['leakCheck.enableLogging'] },
        { key: 'leakCheck.autoLeakCheck', defaultValue: DEFAULT_SETTINGS['leakCheck.autoLeakCheck'] },
        { key: 'leakCheck.autoLeakCheckThreshold', defaultValue: DEFAULT_SETTINGS['leakCheck.autoLeakCheckThreshold'] },
        { key: 'usernameLogger.collectNearbyPlayers', defaultValue: DEFAULT_SETTINGS['usernameLogger.collectNearbyPlayers'] },
        { key: 'usernameLogger.collectBuddies', defaultValue: DEFAULT_SETTINGS['usernameLogger.collectBuddies'] }
      ]

      for (const {key, defaultValue} of settingsToLoad) {
        try {
          const result = await ipcRenderer.invoke('get-setting', key)

          // Only update if we got a valid value (not undefined or null)
          // 'result' directly holds the value from electron-store
          if (result !== undefined && result !== null) {
            this.settings[key] = result; // Assign result directly

            // Special handling for boolean settings (convert strings if needed)
            if (typeof defaultValue === 'boolean' && typeof result !== 'boolean') { // Check type of result itself
              if (result === 'true') this.settings[key] = true;
              else if (result === 'false') this.settings[key] = false;
              else this.settings[key] = Boolean(result); // Fallback conversion
            }
          }
          // If result is undefined/null, this.settings[key] retains its default value from DEFAULT_SETTINGS
        } catch (settingError) {
          // Silently continue with default on individual setting error
          if (isDevelopment) {
            // Keep error log for debugging individual setting load failures
            console.error(`[Settings] Error loading ${key}, using default:`, settingError)
          }
        }
        // Removed individual "Loaded [key]:" logs
      }

      // Loading is complete
      this._isLoaded = true

      // Save loaded settings back to ensure consistency
      // This will write any missing settings with defaults
      this._saveSettingsDebounced()
    } catch (error) {
      // Only log in development
      if (isDevelopment) {
        console.error('[Settings] Fatal error loading settings:', error)
      }
      // Initialize with defaults on error
      this.settings = {...DEFAULT_SETTINGS}
      this._isLoaded = true // Still mark as loaded so app can function
    }
  }

  /**
   * Returns the value if the given key is found.
   * @param key
   * @param defaultValue
   * @returns {any}
   * @public
   */
  get (key, defaultValue = false) {
    if (!this._isLoaded) {
      throw new Error('Settings have not been loaded yet. Call `load()` first.')
    }
    return this.settings[key] !== undefined ? this.settings[key] : defaultValue
  }

  /**
   * Gets all settings.
   * @returns
   */
  getAll () {
    if (!this._isLoaded) {
      throw new Error('Settings have not been loaded yet. Call `load()` first.')
    }
    return this.settings
  }

  /**
   * Saves all settings
   */
  setAll (settings) {
    if (!this._isLoaded) {
      throw new Error('Settings have not been loaded yet. Call `load()` first.')
    }

    this.settings = settings
    this._saveSettingsDebounced()
  }

  /**
   * Updates the settings file.
   * @param key
   * @param value
   * @returns {Promise<void>}
   * @public
   */
  async update (key, value) {
    if (!this._isLoaded) throw new Error('Settings have not been loaded yet. Call `load()` first.')

    this.settings[key] = value
    this._saveSettingsDebounced()
  }

  /**
   * Immediately saves the settings to electron store via IPC.
   * @private
   */
  async _saveSettings () {
    try {
      // Save each setting individually to avoid race conditions
      for (const [key, value] of Object.entries(this.settings)) {
        await ipcRenderer.invoke('set-setting', key, value)
      }

      if (isDevelopment) {
        // Keep this log for debugging saves
        console.log('[Settings] Saved settings successfully')
      }
    } catch (error) {
      if (isDevelopment) {
        console.error('[Settings] Failed saving settings:', error)
      }
    }
  }
}
