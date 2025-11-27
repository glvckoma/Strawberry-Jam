const path = require('path')
const { PluginManager: PM } = require('live-plugin-manager')
const logManager = require('../../../../utils/LogManagerPreload');
logManager.info('DIAGNOSTIC_DISPATCH_LOG_TEST from dispatch/index.js top level'); // Diagnostic

// Define isDevelopment for environment checks
const isDevelopment = process.env.NODE_ENV === 'development';

// Helper: Only log in development
function devLog(...args) {
  if (isDevelopment) console.log(...args);
}
const fs = require('fs').promises
const Ajv = new (require('ajv'))({ useDefaults: true })
const { ConnectionMessageTypes, PluginTypes, getDataPath } = require('../../../../Constants') // Import getDataPath
const StateManager = require('../../../../managers/state/StateManager')
const PluginManager = require('../../../../managers/plugin/PluginManager')
const MessageDispatcher = require('../../../../managers/message/MessageDispatcher')

/**
 * The path to the plugins folder.
 * @constant
 */
const BASE_PATH = process.platform === 'win32'
  ? path.resolve('plugins/')
  : process.platform === 'darwin'
    ? path.join(__dirname, '..', '..', '..', '..', '..', '..', '..', 'plugins/')
    : undefined

/**
 * The default Configuration schema.
 * @type {Object}
 * @private
 */
const ConfigurationSchema = {
  type: 'object',
  properties: {
    name: { type: 'string' },
    main: { type: 'string', default: 'index.js' },
    description: { type: 'string', default: '' },
    author: { type: 'string', default: 'Sxip' },
    type: { type: 'string', default: 'game' },
    dependencies: { type: 'object', default: {} }
  },
  required: [
    'name',
    'main',
    'description',
    'author',
    'type',
    'dependencies'
  ]
}

module.exports = class Dispatch {
  /**
   * Constructor.
   * @param {Application} application
   * @param {string} dataPath - The data path from the main process
   * @param {Function} boundConsoleMessage - The consoleMessage function bound to the application instance
   * @constructor
   */
  constructor (application, dataPath, boundConsoleMessage) {
    this._application = application

    /**
     * The data path for plugins to use.
     * @type {string}
     * @public
     */
    this.dataPath = dataPath;

    /**
     * The bound consoleMessage function from the Application instance.
     * @type {Function}
     * @private
     */
    this._consoleMessage = boundConsoleMessage;

    /**
     * Stores all of the plugins.
     * @type {Map<string, any>}
     * @public
     */
    this.plugins = new Map()

    /**
     * Dependency manager plugin manager.
     * @type {PluginManager}
     * @public
     */
    this.dependencyManager = new PM(process.platform === 'darwin'
      ? { pluginsPath: path.join(__dirname, '..', '..', '..', '..', '..', '..', '..', 'plugin_packages') }
      : {}
    )

    /**
     * Stores all of the commands
     * @type {Map<string, object>}
     * @public
     */
    this.commands = new Map()

    /**
     * Intervals set.
     * @type {Set<Interval>}
     * @public
     */
    this.intervals = new Set()

    /**
     * State object.
     * @type {Object}
     * @public
     */
    this.state = {}

    /**
     * Stores the message hooks.
     * @type {Object}
     * @public
     */
    this.hooks = {
      connection: new Map(),
      aj: new Map(),
      any: new Map()
    }

    /**
     * Message dispatcher instance.
     * @type {MessageDispatcher}
     * @public
     */
    this.messageDispatcher = new MessageDispatcher(this.hooks, this._consoleMessage, this)

    /**
     * State manager instance.
     * @type {StateManager}
     * @public
     */
    this.stateManager = new StateManager(this.state, (hook) => this.onMessage(hook))

    /**
     * Plugin manager instance.
     * @type {PluginManager}
     * @public
     */
    this.pluginManager = new PluginManager({
      plugins: this.plugins,
      application: this._application,
      dependencyManager: this.dependencyManager,
      dataPath: this.dataPath,
      consoleMessage: this._consoleMessage,
      BASE_PATH: BASE_PATH,
      clearAllCallback: () => this.clearAll(),
      initializeDefaultStateHandlersCallback: () => this._initializeDefaultStateHandlers(),
      shouldHideGamePluginsCallback: () => this._shouldHideGamePlugins(),
      refreshPluginVisibilityCallback: () => this.refreshPluginVisibility()
    })

  }

  /**
   * Initializes the default message handlers for basic room and player state.
   * @private
   */
  _initializeDefaultStateHandlers() {
    this.stateManager.initializeDefaultStateHandlers()
  }

  get connected () {
    return this._application.server.clients.size > 0
  }

  get settings () {
    return this._application.settings
  }

  /**
   * Reads files recursively from a directory.
   * @param {string} directory
   * @returns {string[]}
   * @static
   */
  static async readdirRecursive (directory) {
    return PluginManager.readdirRecursive(directory)
  }

  /**
   * Opens the plugin window.
   * @param name
   * @public
   */
  open (name) {
    const plugin = this.plugins.get(name)

    if (plugin) {
      const { filepath, configuration: { main } } = plugin
      const url = `file://${path.join(filepath, main)}`

      // Request main process to create a new window
      if (typeof require === "function") {
        try {
          const { ipcRenderer } = require('electron');
          ipcRenderer.send('open-plugin-window', {
            url,
            name,
            pluginPath: filepath
          });
        } catch (e) {
          console.error("Failed to request plugin window:", e);
          // Fallback to basic window.open
          const popup = window.open(url);
          if (popup) {
            popup.jam = {
              application: this._application,
              dispatch: this
            };
          }
        }
      }
    } else {
      this._consoleMessage({
        type: 'error',
        message: `Plugin "${name}" not found.`
      })
    }
  }

  /**
   * Installs plugin dependencies..
   * @param {object} configuration
   * @public
   */
  async installDependencies (configuration) {
    return this.pluginManager.installDependencies(configuration)
  }

  /**
   * Requires a plugin dependency.
   * @param {string} name
   */
  require (name) {
    return this.pluginManager.require(name)
  }

  /**
   * Helper function to wait for the jquery preload to finish.
   * @param {Window} window
   * @param {Function} callback
   * @public
   */
  waitForJQuery (window, callback) {
    return this.pluginManager.waitForJQuery(window, callback)
  }

  /**
   * Loads all of the plugins.
   * @returns {Promise<void>}
   * @public
   */
  async load (filter = file => path.basename(file) === 'plugin.json') {
    return this.pluginManager.load(filter)
  }

  /**
   * Dispatches all of the message hooks.
   * @returns {Promise<void>}
   * @public
   */
  async all ({ client, type, message }) {
    return this.messageDispatcher.all({ client, type, message })
  }

  /**
   * Sends multiple messages.
   * @param messages
   * @public
   */
  async sendMultipleMessages ({ type, messages = [] } = {}) {
    return this.messageDispatcher.sendMultipleMessages({ type, messages })
  }

  /**
   * Stores and validates the plugin configuration.
   * @param filepath
   * @param configuration
   * @private
   */
  async _storeAndValidate (filepath, configuration) {
    // This function is being replaced by _validateAndPrepareConfig and _processAndRenderPlugin
    // We keep it temporarily for reference if needed, but it won't be called directly by load anymore.
    // TODO: Remove this function after confirming new logic works.
    const validate = Ajv.compile(ConfigurationSchema)

    if (!validate(configuration)) {
      this._consoleMessage({
        type: 'error',
        message: `Failed validating the configuration for the plugin ${filepath}. ${validate.errors[0].message}.`
      })
      return
    }

    // Check if the plugin name already exists
    if (this.plugins.has(configuration.name)) {
      this._consoleMessage({
        type: 'error',
        message: `Plugin with the name ${configuration.name} already exists.`
      })
      return
    }

    try {
      await this.installDependencies(configuration)

      switch (configuration.type) {
        case PluginTypes.game: {
          const PluginInstance = require(path.join(filepath, configuration.main))
          const plugin = new PluginInstance({
            application: this._application,
            dispatch: this,
            dataPath: this.dataPath // Pass dataPath to game plugin constructors
          })

          this.plugins.set(configuration.name, {
            configuration,
            filepath,
            plugin
          })
          break
        }

        case PluginTypes.ui:
          this.plugins.set(configuration.name, { configuration, filepath })
          break

        default:
          throw new Error(`Unsupported plugin type: ${configuration.type}`)
      }

      this._application.renderPluginItems(configuration)
    } catch (error) {
      this._consoleMessage({
        type: 'error',
        message: `Error processing the plugin ${filepath}: ${error.message}`
      })
    }
  }

  /**
   * Refreshes a plugin
   * @param {string} The plugin name
   * @returns {Promise<void>}
   */
  async refresh () {
    return this.pluginManager.refresh()
  }

  /**
   * Promise timeout helper.
   * @param ms
   * @returns {Promise<void>}
   * @public
   */
  wait (ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  /**
   * Displays a server admin message.
   * @param {string} text
   * @public
   */
  serverMessage (text) {
    return this.sendConnectionMessage(`%xt%ua%${text}%0%`)
  }

  /**
   * Helper method for random.
   * @param {number} min
   * @param {number} max
   * @public
   */
  random (min, max) {
    return ~~(Math.random() * (max - min + 1)) + min
  }

  /**
   * Sets a state.
   * @param {string} key
   * @param {any} value
   * @returns {this}
   * @public
   */
  setState (key, value) {
    return this.stateManager.setState(key, value)
  }

  /**
   * Gets a state synchronously (when possible)
   * @param {string} key
   * @returns {any}
   * @public
   */
  getStateSync (key) {
    return this.stateManager.getStateSync(key)
  }

  /**
   * Fetches the state.
   * @param key
   * @param defaultValue
   * @returns {any}
   * @public
   */
  getState (key, defaultValue = null) {
    return this.stateManager.getState(key, defaultValue)
  }

  /**
   * Updates a state.
   * @param {string} key
   * @param {any} value
   * @returns {this}
   * @public
   */
  updateState (key, value) {
    return this.stateManager.updateState(key, value)
  }

  /**
   * Sends a connection message.
   * @param message
   * @returns {Promise<number>}
   * @public
   */
  sendConnectionMessage (message) {
    const promises = [...this._application.server.clients].map(client => client.sendConnectionMessage(message))
    return Promise.all(promises)
  }

  /**
   * Gets a list of all connected clients with their metadata.
   * @returns {Array<Object>} Array of client objects with {clientId, username, userId, connected}
   * @public
   */
  getConnectedClients () {
    if (!this._application.server || !this._application.server.clients) {
      return []
    }

    return [...this._application.server.clients].map(client => ({
      clientId: client.clientId,
      username: client.username || null,
      userId: client.userId || null,
      connected: client.connected || false
    }))
  }

  /**
   * Sends a remote message.
   * @param {string} message - The message to send
   * @param {Object} options - Optional filtering options
   * @param {string} options.targetUsername - Filter by username (sends only to clients with this username)
   * @param {string} options.targetClientId - Filter by client ID (sends only to client with this ID)
   * @returns {Promise<number>}
   * @public
   */
  sendRemoteMessage (message, options = {}) {
    if (this._application.server.clients.size === 0) {
      console.warn('[Dispatch] No server clients connected to send remote message.');
      return Promise.resolve([]); // Return an empty resolved promise if no clients
    }

    // Filter clients based on options
    let targetClients = [...this._application.server.clients];
    
    if (options.targetUsername) {
      targetClients = targetClients.filter(client => 
        client.username === options.targetUsername
      );
    } else if (options.targetClientId) {
      targetClients = targetClients.filter(client => 
        client.clientId === options.targetClientId
      );
    }

    if (targetClients.length === 0) {
      console.warn('[Dispatch] No matching clients found for the specified filter.');
      return Promise.resolve([]);
    }

    const promises = targetClients.map(client => {
      try {
        return client.sendRemoteMessage(message);
      } catch (e) {
        console.error(`[Dispatch] Error in client.sendRemoteMessage for client ${client.clientId}:`, e);
        return Promise.reject(e); // Propagate error for Promise.all
      }
    });
    return Promise.all(promises);
  }

  /**
   * Sets an interval.
   * @param {*} fn
   * @param {*} delay
   * @param  {...any} args
   * @returns
   * @public
   */
  setInterval (fn, delay, ...args) {
    const interval = setInterval(fn, delay, ...args)
    this.intervals.add(interval)
    return interval
  }

  /**
   * Clears an interval.
   * @param {} interval
   * @public
   */
  clearInterval (interval) {
    clearInterval(interval)
    this.intervals.clear(interval)
  }

  /**
   * Hooks a command.
   * @param command
   * @public
   */
  onCommand ({ name, description = '', callback } = {}) {
    if (typeof name !== 'string' || typeof callback !== 'function') return

    if (this.commands.has(name)) return
    this.commands.set(name, { name, description, callback })
  }

  /**
   * Off command, removes the command.
   * @param command
   * @public
   */
  offCommand ({ name, callback } = {}) {
    if (!this.commands.has(name)) return

    const commandCallbacks = this.commands.get(name)

    const index = commandCallbacks.indexOf(callback)
    if (index !== -1) commandCallbacks.splice(index, 1)
  }

  /**
   * Hooks a message by the type.
   * @param options
   * @public
   */
  onMessage ({ type, message, callback } = {}) {
    return this.messageDispatcher.onMessage({ type, message, callback })
  }

  /**
   * Unhooks a message.
   * @param options
   * @public
   */
  offMessage ({ type, message, callback } = {}) {
    return this.messageDispatcher.offMessage({ type, message, callback })
  }

  clearAll () {
    this.plugins.clear()
    this.commands.clear()

    const { connection, aj, any } = this.hooks

    connection.clear()
    aj.clear()
    any.clear()
  }



  /**
   * Notifies all loaded plugins that have an onSettingsUpdated method.
   * This should be called after settings have been saved.
   * @public
   */
  async notifyPluginsOfSettingsUpdate() {
    devLog('[Dispatch] Attempting to flush settings before notifying plugins...');
    try {
      if (this._application && this._application.settings && typeof this._application.settings.flush === 'function') {
        await this._application.settings.flush();
        devLog('[Dispatch] Settings flushed successfully.');
      } else {
        devLog('[Dispatch] Could not flush settings: application or settings object or flush method not available.');
      }
    } catch (flushError) {
      devError('[Dispatch] Error flushing settings:', flushError);
      this._consoleMessage({
        type: 'error',
        message: `[Dispatch] Error flushing settings before update: ${flushError.message}`
      });
      // Decide if we should proceed or not. For now, let's proceed but log the error.
    }

    devLog('[Dispatch] Notifying plugins of settings update...');
    for (const [name, pluginData] of this.plugins) {
      // pluginData.plugin holds the instance for game plugins
      // UI plugins don't have an instance stored directly in this.plugins in the current structure
      // This notification is primarily for game plugins that might react to settings changes.
      // UI plugins typically re-fetch settings when they are opened or interacted with.
      const pluginInstance = pluginData.plugin;
      if (pluginInstance && typeof pluginInstance.onSettingsUpdated === 'function') {
        try {
          devLog(`[Dispatch] Calling onSettingsUpdated for plugin: ${name}`);
          await pluginInstance.onSettingsUpdated();
        } catch (error) {
          this._consoleMessage({
            type: 'error',
            message: `Error calling onSettingsUpdated for plugin ${name}: ${error.message}`
          });
          devError(`[Dispatch] Error in onSettingsUpdated for ${name}:`, error);
        }
      }
    }

    // Refresh plugin visibility after notifying plugins
    await this.refreshPluginVisibility();
  }

  /**
   * Helper method to check if game plugins should be hidden based on user settings
   * @returns {Promise<boolean>} - Whether game plugins should be hidden
   * @private
   */
  async _shouldHideGamePlugins() {
    // Bypassing application settings cache for this specific check to ensure freshness
    if (typeof require === "function") {
      try {
        const { ipcRenderer } = require('electron');
        const ipcSettingValue = await ipcRenderer.invoke('get-setting', 'ui.hideGamePlugins');
        return ipcSettingValue === true;
      } catch (e) {
        // It's good practice to log the error in development for debugging
        if (process.env.NODE_ENV === 'development') {
          console.error('[_shouldHideGamePlugins] Error getting ui.hideGamePlugins from store via IPC:', e);
        }
        return false; // Default to showing all plugins on IPC error
      }
    } else {
      // This case should ideally not happen in a proper Electron renderer context
      if (process.env.NODE_ENV === 'development') {
        console.error('[_shouldHideGamePlugins] require is not a function. Not in Electron renderer context?');
      }
      return false; // Default if IPC is not available
    }
  }

  /**
   * Refreshes plugin visibility based on current settings
   * @public
   */
  async refreshPluginVisibility() {
    try {
      const hideGamePlugins = await this._shouldHideGamePlugins();
      if (hideGamePlugins) {
        // Hide game plugins from UI but keep them loaded and functional
        this._application.$pluginList.find('[data-plugin-type="game"]').hide();
      } else {
        // Show all plugins
        this._application.$pluginList.find('[data-plugin-type="game"]').show();
      }
    } catch (error) {
      this._consoleMessage({
        type: 'error',
        message: `Error refreshing plugin visibility: ${error.message}`
      });
    }
  }
}
