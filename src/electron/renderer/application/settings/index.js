const { ipcRenderer } = require('electron')

function debounce(fn, wait, options = {}) {
  let timeout = null
  let maxTimeout = null
  let lastArgs = null
  const maxWait = options.maxWait || 0

  function invoke() {
    clearTimeout(timeout)
    clearTimeout(maxTimeout)
    timeout = null
    maxTimeout = null
    const args = lastArgs
    lastArgs = null
    fn.apply(null, args)
  }

  function debounced(...args) {
    lastArgs = args
    clearTimeout(timeout)
    timeout = setTimeout(invoke, wait)
    if (maxWait && !maxTimeout) {
      maxTimeout = setTimeout(invoke, maxWait)
    }
  }

  debounced.cancel = () => {
    clearTimeout(timeout)
    clearTimeout(maxTimeout)
    timeout = null
    maxTimeout = null
    lastArgs = null
  }

  return debounced
}

// Default values for critical settings
const DEFAULT_SETTINGS = {
  smartfoxServer: 'lb-iss02-classic-prod.animaljam.com',
  secureConnection: true,
  leakCheckApiKey: '',
  leakCheckOutputDir: '',
  autoReconnect: true,
  preventAutoLogin: false,

  // Network settings
  'network.smartfoxServer': 'lb-iss02-classic-prod.animaljam.com',
  'network.secureConnection': true,

  // New keys matching electron-store structure for UI settings
  'ui.hideGamePlugins': false,
  'ui.performServerCheckOnLaunch': true,
  'ui.allowMultipleInstances': false,

  // Update settings
  'updates.enableAutoUpdates': true,

  // Game client settings
  'game.selectedSwfFile': 'ajclient.swf',
  'game.autoReapplySwf': false,

  // Plugin settings
  'plugins.refreshBehavior': 'ask',

  // UsernameLogger and LeakCheck specific settings
  'leakCheck.enableLogging': true,
  'leakCheck.autoLeakCheck': false,
  'leakCheck.autoLeakCheckThreshold': 100,
  'usernameLogger.collectNearbyPlayers': true,
  'usernameLogger.collectBuddies': true,
  'plugins.usernameLogger.apiKey': '',
  'plugins.usernameLogger.outputDir': '',
  'plugins.usernameLogger.autoCheck.enabled': false,
  'plugins.usernameLogger.autoCheck.threshold': 0,
  'plugins.usernameLogger.collection.enabled': true,
  'plugins.usernameLogger.collection.collectNearby': true,
  'plugins.usernameLogger.collection.collectBuddies': true,
  'plugins.usernameLogger.maxPasswordsPerAccount': 0,

  // Log limiting settings
  'logs.consoleLimit': 500,
  'logs.networkLimit': 500,

  // Custom theme color settings
  'ui.customThemeColor': null,
  'ui.customThemeEnabled': false,
  'ui.customThemeName': null,
  'ui.customThemeFruit': null,

  // Tutorial settings
  'ui.tutorialCompleted': false,
  'ui.showTutorialOnFirstLaunch': true,
  'ui.applyColorToFruitIcon': true,

  'logs.packetFilters': [],
  'logs.packetFontSize': 12,
  'logs.incomingColor': '#10b981',
  'logs.outgoingColor': '#eab308',

  'plugins.defaultDisplayMode': 'inline',

  'ui.militaryTime': false
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
        { key: 'network.smartfoxServer', defaultValue: DEFAULT_SETTINGS['network.smartfoxServer'] },
        { key: 'network.secureConnection', defaultValue: DEFAULT_SETTINGS['network.secureConnection'] },
        { key: 'ui.hideGamePlugins', defaultValue: DEFAULT_SETTINGS['ui.hideGamePlugins'] },
        { key: 'ui.performServerCheckOnLaunch', defaultValue: DEFAULT_SETTINGS['ui.performServerCheckOnLaunch'] },
        { key: 'ui.allowMultipleInstances', defaultValue: DEFAULT_SETTINGS['ui.allowMultipleInstances'] },
        { key: 'updates.enableAutoUpdates', defaultValue: DEFAULT_SETTINGS['updates.enableAutoUpdates'] },
        // Game client settings
        { key: 'game.selectedSwfFile', defaultValue: DEFAULT_SETTINGS['game.selectedSwfFile'] },
        { key: 'game.autoReapplySwf', defaultValue: DEFAULT_SETTINGS['game.autoReapplySwf'] },
        // Plugin settings
        { key: 'plugins.refreshBehavior', defaultValue: DEFAULT_SETTINGS['plugins.refreshBehavior'] },
        // Added UsernameLogger and LeakCheck settings
        { key: 'leakCheck.enableLogging', defaultValue: DEFAULT_SETTINGS['leakCheck.enableLogging'] },
        { key: 'leakCheck.autoLeakCheck', defaultValue: DEFAULT_SETTINGS['leakCheck.autoLeakCheck'] },
        { key: 'leakCheck.autoLeakCheckThreshold', defaultValue: DEFAULT_SETTINGS['leakCheck.autoLeakCheckThreshold'] },
        { key: 'usernameLogger.collectNearbyPlayers', defaultValue: DEFAULT_SETTINGS['usernameLogger.collectNearbyPlayers'] },
        { key: 'usernameLogger.collectBuddies', defaultValue: DEFAULT_SETTINGS['usernameLogger.collectBuddies'] },
        { key: 'plugins.usernameLogger.apiKey', defaultValue: DEFAULT_SETTINGS['plugins.usernameLogger.apiKey'] },
        { key: 'plugins.usernameLogger.outputDir', defaultValue: DEFAULT_SETTINGS['plugins.usernameLogger.outputDir'] },
        { key: 'plugins.usernameLogger.autoCheck.enabled', defaultValue: DEFAULT_SETTINGS['plugins.usernameLogger.autoCheck.enabled'] },
        { key: 'plugins.usernameLogger.autoCheck.threshold', defaultValue: DEFAULT_SETTINGS['plugins.usernameLogger.autoCheck.threshold'] },
        { key: 'plugins.usernameLogger.collection.enabled', defaultValue: DEFAULT_SETTINGS['plugins.usernameLogger.collection.enabled'] },
        { key: 'plugins.usernameLogger.collection.collectNearby', defaultValue: DEFAULT_SETTINGS['plugins.usernameLogger.collection.collectNearby'] },
        { key: 'plugins.usernameLogger.collection.collectBuddies', defaultValue: DEFAULT_SETTINGS['plugins.usernameLogger.collection.collectBuddies'] },
        { key: 'plugins.usernameLogger.maxPasswordsPerAccount', defaultValue: DEFAULT_SETTINGS['plugins.usernameLogger.maxPasswordsPerAccount'] },
        // Log limiting settings
        { key: 'logs.consoleLimit', defaultValue: DEFAULT_SETTINGS['logs.consoleLimit'] },
        { key: 'logs.networkLimit', defaultValue: DEFAULT_SETTINGS['logs.networkLimit'] },
        { key: 'ui.customThemeColor', defaultValue: DEFAULT_SETTINGS['ui.customThemeColor'] },
        { key: 'ui.customThemeEnabled', defaultValue: DEFAULT_SETTINGS['ui.customThemeEnabled'] },
        { key: 'ui.customThemeName', defaultValue: DEFAULT_SETTINGS['ui.customThemeName'] },
        { key: 'ui.customThemeFruit', defaultValue: DEFAULT_SETTINGS['ui.customThemeFruit'] },
        { key: 'ui.tutorialCompleted', defaultValue: DEFAULT_SETTINGS['ui.tutorialCompleted'] },
        { key: 'ui.showTutorialOnFirstLaunch', defaultValue: DEFAULT_SETTINGS['ui.showTutorialOnFirstLaunch'] },
        { key: 'ui.applyColorToFruitIcon', defaultValue: DEFAULT_SETTINGS['ui.applyColorToFruitIcon'] },
        { key: 'logs.packetFilters', defaultValue: DEFAULT_SETTINGS['logs.packetFilters'] },
        { key: 'logs.packetFontSize', defaultValue: DEFAULT_SETTINGS['logs.packetFontSize'] },
        { key: 'logs.incomingColor', defaultValue: DEFAULT_SETTINGS['logs.incomingColor'] },
        { key: 'logs.outgoingColor', defaultValue: DEFAULT_SETTINGS['logs.outgoingColor'] },
        { key: 'plugins.defaultDisplayMode', defaultValue: DEFAULT_SETTINGS['plugins.defaultDisplayMode'] }
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

  /**
   * Flushes any pending debounced save operations to the main process.
   * This ensures that the latest settings are persisted immediately.
   * @public
   * @returns {Promise<void>}
   */
  async flush () {
    if (!this._isLoaded) {
      // It might be too early to throw an error here if flush is called during early init
      // For now, let's log if in development and simply return.
      if (isDevelopment) {
        console.warn('[Settings] flush() called before settings loaded. Aborting flush.');
      }
      return;
    }

    // Cancel any scheduled debounced save
    if (this._saveSettingsDebounced && typeof this._saveSettingsDebounced.cancel === 'function') {
      this._saveSettingsDebounced.cancel()
    }

    // Immediately save the current settings
    await this._saveSettings()

    if (isDevelopment) {
      console.log('[Settings] Settings flushed successfully.')
    }
  }
}
