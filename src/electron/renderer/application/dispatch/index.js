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

    // No longer exposing getDataPath function directly
    // this.getDataPath = getDataPath;

    // Default state handlers will be initialized at the end of the load() method.
  }

  /**
   * Initializes the default message handlers for basic room and player state.
   * @private
   */
  _initializeDefaultStateHandlers() {
    devLog('[ROOMLOGIC_DEBUG] Dispatch._initializeDefaultStateHandlers: Starting to set up default handlers.');
    this.onMessage({
      type: ConnectionMessageTypes.aj,
      message: 'rj', // Room Join packet
      callback: ({ message }) => {
        // Based on XtMessage.parse() and logs, message.value for "%xt%rj%world%status%name%instance%..." is:
        // message.value[0] = "" (empty string from leading '%')
        // message.value[1] = "xt"
        // message.value[2] = "rj" (command)
        // message.value[3] = worldId (e.g., "8795")
        // message.value[4] = status ("1" for success)
        // message.value[5] = textualRoomName (e.g., "balloosh.room_main#94")
        // message.value[6] = numericalInstanceId (e.g., "3695" - needed for pubMsg)

        devLog(`[ROOMLOGIC_DEBUG] Dispatch 'rj' handler: Raw message.value:`, message.value);

        if (message.value && message.value.length > 6 && message.value[4] === '1') { // Status '1' is at index 4
          const textualRoomId = message.value[5];         // e.g., "balloosh.room_main#94"
          const numericalInstanceRoomId = message.value[6]; // e.g., "3695"

          devLog(`[ROOMLOGIC_DEBUG] Dispatch 'rj' handler: Extracted textualRoomId: ${textualRoomId}, numericalInstanceRoomId: ${numericalInstanceRoomId}`);
          
          if (textualRoomId) {
            this.setState('room', textualRoomId);
            if (isDevelopment) {
              devLog(`[Dispatch] State 'room' (textual) set by 'rj' packet: ${textualRoomId}`);
            }
          } else {
            devLog(`[ROOMLOGIC_DEBUG] Dispatch 'rj' handler: textualRoomId is undefined or empty.`);
          }

          if (numericalInstanceRoomId && !isNaN(parseInt(numericalInstanceRoomId))) {
            this.setState('internalRoomId', numericalInstanceRoomId); // For sending XT packets
            if (isDevelopment) {
              devLog(`[Dispatch] State 'internalRoomId' (numeric for pubMsg) set by 'rj' packet: ${numericalInstanceRoomId}`);
            }
          } else {
            devLog(`[ROOMLOGIC_DEBUG] Dispatch 'rj' handler: numericalInstanceRoomId ('${numericalInstanceRoomId}') is undefined, empty, or not a number.`);
            // Fallback: if the textualRoomId itself is purely numerical (e.g. for some specific rooms). Unlikely for typical AJ rooms.
            if (textualRoomId && !isNaN(parseInt(textualRoomId))) {
                this.setState('internalRoomId', textualRoomId);
                if (isDevelopment) console.warn(`[Dispatch] Fallback: Using textualRoomId '${textualRoomId}' as internalRoomId because numericalInstanceRoomId was invalid.`);
            } else {
                this.setState('internalRoomId', null);
                if (isDevelopment) console.warn(`[Dispatch] No valid numerical room ID found in 'rj' packet. 'internalRoomId' set to null.`);
            }
          }
        } else {
          devLog(`[ROOMLOGIC_DEBUG] Dispatch 'rj' handler: Packet did not match expected structure or status for room ID extraction. Status (at index 4) was: ${message.value && message.value.length > 4 ? message.value[4] : 'N/A'}`);
          this.setState('room', null);
          this.setState('internalRoomId', null);
        }
      }
    });
    devLog('[ROOMLOGIC_DEBUG] Dispatch._initializeDefaultStateHandlers: "rj" handler setup complete.');

    this.onMessage({
      type: ConnectionMessageTypes.aj,
      message: 'login', // Login packet
      callback: ({ message }) => {
        devLog(`[ROOMLOGIC_DEBUG] Dispatch 'login' handler: Raw message.value:`, message.value);
        // Attempt to extract player data based on @jam-master's structure
        if (message.value && message.value.b && message.value.b.o && message.value.b.o.params) {
          const playerData = message.value.b.o.params;
          devLog(`[ROOMLOGIC_DEBUG] Dispatch 'login' handler: Extracted playerData:`, playerData);
          this.setState('player', playerData);
          // Optional: Log player data if in development
          if (isDevelopment) {
            devLog('[Dispatch] Player data set by "login" packet.');
          }
        } else {
          devLog(`[ROOMLOGIC_DEBUG] Dispatch 'login' handler: Packet did not match expected structure for player data extraction.`);
        }
      }
    });
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
    const result = []

    const read = async (dir) => {
      const entries = await fs.readdir(dir, { withFileTypes: true })

      const promises = entries.map(async (entry) => {
        const filepath = path.join(dir, entry.name)

        if (entry.isDirectory()) {
          await read(filepath)
        } else {
          result.push(filepath)
        }
      })

      await Promise.all(promises)
    }

    await read(directory)
    return result
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
    const { dependencies } = configuration

    if (!dependencies || Object.keys(dependencies).length === 0) {
      return
    }

    const installPromises = Object.entries(dependencies).map(
      ([module, version]) => this.dependencyManager.install(module, version)
    )

    await Promise.all(installPromises)
  }

  /**
   * Requires a plugin dependency.
   * @param {string} name
   */
  require (name) {
    return this.dependencyManager.require(name)
  }

  /**
   * Helper function to wait for the jquery preload to finish.
   * @param {Window} window
   * @param {Function} callback
   * @public
   */
  waitForJQuery (window, callback) {
    return new Promise((resolve, reject) => {
      const checkInterval = 100
      const maxRetries = 100
      let retries = 0

      const intervalId = setInterval(() => {
        if (typeof window.$ !== 'undefined') {
          clearInterval(intervalId)
          try {
            callback()
            resolve()
          } catch (error) {
            reject(error)
          }
        } else if (retries >= maxRetries) {
          clearInterval(intervalId)
          reject(new Error('jQuery was not found within the expected time.'))
        } else {
          retries++
        }
      }, checkInterval)
    })
  }

  /**
   * Loads all of the plugins.
   * @returns {Promise<void>}
   * @public
   */
  async load (filter = file => path.basename(file) === 'plugin.json') {
    devLog('[Dispatch] Starting plugin load sequence...');
    this.clearAll()
    this._application.$pluginList.empty(); // Clear existing plugin list items

    // Ensure BASE_PATH is defined
      if (!BASE_PATH) {
      this._consoleMessage({ type: 'error', message: 'Plugin base path (BASE_PATH) could not be determined. Cannot load plugins.' });
      this._application._updateEmptyPluginMessage(); // Update empty message status
      return;
    }

    devLog(`[Dispatch] Plugin base directory: ${BASE_PATH}`);

    try {
      // Check if BASE_PATH exists, no need to create it as it should be part of the app structure
      try {
        await fs.access(BASE_PATH);
        devLog(`[Dispatch] Plugin directory accessible: ${BASE_PATH}`);
      } catch (accessError) {
        // If BASE_PATH doesn't exist, it's a critical issue with the app deployment/structure.
        this._consoleMessage({ type: 'error', message: `Plugins directory not found at ${BASE_PATH}. Cannot load plugins.` });
        this._application._updateEmptyPluginMessage();
        return;
      }

      const files = await Dispatch.readdirRecursive(BASE_PATH); // Use BASE_PATH
      devLog(`[Dispatch] Found ${files.length} files/folders in plugin directory.`);

      const configFiles = files.filter(filter);
      devLog(`[Dispatch] Found ${configFiles.length} plugin configuration files (plugin.json).`);

      if (configFiles.length === 0) {
        this._consoleMessage({ type: 'notify', message: 'No plugins found in the plugins directory.' });
      this._application._updateEmptyPluginMessage(); 
        return;
      }

      const pluginPromises = configFiles.map(async configFile => {
        try {
          devLog(`[Dispatch] Reading plugin config: ${configFile}`);
          const configuration = JSON.parse(await fs.readFile(configFile, 'utf8'));
          const filepath = path.dirname(configFile);
          // Pass the raw configuration for validation and preparation
          return this._validateAndPrepareConfig(filepath, configuration.default || configuration);
        } catch (error) {
          this._consoleMessage({ type: 'error', message: `Error reading or parsing plugin config ${path.basename(configFile)}: ${error.message}` });
          return null;
        }
      });

      let loadedPluginConfigs = (await Promise.all(pluginPromises)).filter(r => r !== null);
      devLog(`[Dispatch] Successfully validated and prepared ${loadedPluginConfigs.length} plugin configurations.`);
              
      // Filter plugins based on ui.hideGamePlugins setting
      const hideGamePlugins = await this._shouldHideGamePlugins();
      if (hideGamePlugins) {
        devLog('[Dispatch] Filtering out game-specific plugins as ui.hideGamePlugins is true.');
        loadedPluginConfigs = loadedPluginConfigs.filter(p => p.configuration.type !== 'game');
      }
      devLog(`[Dispatch] ${loadedPluginConfigs.length} plugins remaining after filtering.`);

      // Sort plugins: UI plugins first, then game plugins, then alphabetically
      loadedPluginConfigs.sort((a, b) => {
        const typeA = a.configuration.type;
        const typeB = b.configuration.type;
        const nameA = a.configuration.name || '';
        const nameB = b.configuration.name || '';

        let priorityA = 2; // Default for 'other' types
        if (typeA === 'ui') priorityA = 0;       // HARDCODED 'ui'
        else if (typeA === 'game') priorityA = 1; // HARDCODED 'game'

        let priorityB = 2; // Default for 'other' types
        if (typeB === 'ui') priorityB = 0;       // HARDCODED 'ui'
        else if (typeB === 'game') priorityB = 1; // HARDCODED 'game'
        
        if (priorityA !== priorityB) {
          return priorityA - priorityB; // Lower priority number comes first
        }
        
        // If priorities are the same, sort by name
        return nameA.localeCompare(nameB);
      });

      for (const configData of loadedPluginConfigs) {
        // _processAndRenderPlugin expects an object with configuration and filepath properties
        await this._processAndRenderPlugin(configData); 
        }

    } catch (error) {
      // Catch errors from readdirRecursive or other unexpected issues
      this._consoleMessage({ type: 'error', message: `Error loading plugins: ${error.message}` });
      devError('[Dispatch] Detailed error loading plugins:', error);
    } finally {
      this._application._updateEmptyPluginMessage(); // Call this after all processing
      devLog('[Dispatch] Plugin load sequence finished.');
      this._application.refreshAutoComplete();
      // Ensure default state handlers are re-initialized after all plugins load and clearAll has run
      devLog('[ROOMLOGIC_DEBUG] Re-initializing default state handlers after plugin load.');
      this._initializeDefaultStateHandlers();
    }
  }

  /**
   * Dispatches all of the message hooks.
   * @returns {Promise<void>}
   * @public
   */
  async all ({ client, type, message }) {
    // ROOMLOGIC_DEBUG: Log incoming message details to Dispatch.all
    devLog(`[ROOMLOGIC_DEBUG] Dispatch.all: Received. ConnectionType: ${type}, MessageType: ${message.type}, RawValue:`, message.value);

    const ajHooks = type === ConnectionMessageTypes.aj ? this.hooks.aj.get(message.type) || [] : [];
    const connectionHooks = type === ConnectionMessageTypes.connection ? this.hooks.connection.get(message.type) || [] : [];
    const anyHooks = this.hooks.any.get(ConnectionMessageTypes.any) || [];

    const hooks = [...ajHooks, ...connectionHooks, ...anyHooks];

    if (hooks.length > 0) {
      devLog(`[ROOMLOGIC_DEBUG] Dispatch.all: Found ${hooks.length} hooks for MessageType: ${message.type}. AJ: ${ajHooks.length}, Conn: ${connectionHooks.length}, Any: ${anyHooks.length}`);
    } else {
      // devLog(`[ROOMLOGIC_DEBUG] Dispatch.all: No hooks found for MessageType: ${message.type}.`);
    }

    const promises = hooks.map(async (hook, index) => {
      try {
        // ROOMLOGIC_DEBUG: Log which hook is about to be called
        // To avoid excessive logging for every packet, we can be selective or add more detail if a specific packet is problematic
        if (message.type === 'rj' || message.type === 'login') { // Example: Log details for rj or login
            devLog(`[ROOMLOGIC_DEBUG] Dispatch.all: Invoking hook #${index + 1} for MessageType: ${message.type}. Hook function:`, hook.toString().substring(0, 100) + "...");
        }
        await hook({ client, type, dispatch: this, message });
      } catch (error) {
        this._consoleMessage({
          type: 'error',
          message: `Failed hooking packet ${message.type}. ${error.message}`
        });
        devLog(`[ROOMLOGIC_DEBUG] Dispatch.all: Error in hook for MessageType: ${message.type}. Error:`, error);
      }
    });

    await Promise.all(promises);
  }

  /**
   * Sends multiple messages.
   * @param messages
   * @public
   */
  async sendMultipleMessages ({ type, messages = [] } = {}) {
    if (messages.length === 0) {
      return Promise.resolve()
    }

    const sendFunction = type === ConnectionMessageTypes.aj
      ? this.sendRemoteMessage.bind(this)
      : this.sendConnectionMessage.bind(this)

    try {
      await Promise.all(messages.map(sendFunction))
    } catch (error) {
      this._consoleMessage({
        type: 'error',
        message: `Error sending messages: ${error.message}`
      })
    }
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
    const { $pluginList, consoleMessage } = this._application

    $pluginList.empty()

    const pluginPaths = [...this.plugins.values()].map(({ filepath, configuration: { main } }) => ({
      jsPath: path.resolve(filepath, main),
      jsonPath: path.resolve(filepath, 'plugin.json')
    }))

    for (const { jsPath, jsonPath } of pluginPaths) {
      const jsCacheKey = require.resolve(jsPath)
      const jsonCacheKey = require.resolve(jsonPath)
      if (require.cache[jsCacheKey]) delete require.cache[jsCacheKey]
      if (require.cache[jsonCacheKey]) delete require.cache[jsonCacheKey]
    }

    this.clearAll()
    await this.load()

    this._application.emit('refresh:plugins')
    this._consoleMessage({
      type: 'success',
      message: `Successfully refreshed ${this.plugins.size} plugins.`
    })
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
    // Don't update if value hasn't changed
    if (this.state[key] === value) {
      if (key === 'room') {
        devLog(`[ROOMLOGIC_DEBUG] Dispatch setState: Attempted to set 'room' to '${value}', but it's already the current value.`);
      }
      return this;
    }
    
    this.state[key] = value;
    if (key === 'room') {
      devLog(`[ROOMLOGIC_DEBUG] Dispatch setState: 'room' has been set to '${value}'. Current this.state.room: ${this.state.room}`);
    }
    
    // IPC call for 'room' key removed as per reversion plan to align with @jam-master
    return this;
  }

  /**
   * Gets a state synchronously (when possible)
   * @param {string} key
   * @returns {any}
   * @public
   */
  getStateSync (key) {
    // For local state access, just return from memory
    if (this.state[key] !== undefined) {
      return this.state[key]
    }
    
    // For IPC-based access (when running in renderer), handle specially
    if (typeof require === 'function') {
      try {
        const { ipcRenderer } = require('electron')
        // This is a synchronous IPC call - will block until response received
        const value = ipcRenderer.sendSync('dispatch-get-state-sync', key)
        if (value !== undefined) {
          // Cache the value locally
          this.state[key] = value
          return value
        }
      } catch (e) {
        console.error(`[Dispatch] Error in getStateSync for key ${key}:`, e)
      }
    }
    
    // Default case - state not found
    return null
  }

  /**
   * Fetches the state.
   * @param key
   * @param defaultValue
   * @returns {any}
   * @public
   */
  getState (key, defaultValue = null) {
    const value = this.state[key] !== undefined ? this.state[key] : defaultValue;
    if (key === 'room') {
      devLog(`[ROOMLOGIC_DEBUG] Dispatch getState: Requesting 'room'. Current this.state.room: ${this.state.key}. Returning: ${value}`);
    } else if (key === 'player') {
      devLog(`[ROOMLOGIC_DEBUG] Dispatch getState: Requesting 'player'. Returning:`, value);
    }
    return value;
  }

  /**
   * Updates a state.
   * @param {string} key
   * @param {any} value
   * @returns {this}
   * @public
   */
  updateState (key, value) {
    if (this.state[key]) this.state[key] = value
    else throw new Error('Invalid state key.')
    return this
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
   * Sends a remote message.
   * @param message
   * @returns {Promise<number>}
   * @public
   */
  sendRemoteMessage (message) {
    devLog(`[Dispatch] sendRemoteMessage called with:`, message);
    devLog(`[Dispatch] Current server clients count: ${this._application.server.clients.size}`);
    
    if (this._application.server.clients.size === 0) {
      console.warn('[Dispatch] No server clients connected to send remote message.');
      return Promise.resolve([]); // Return an empty resolved promise if no clients
    }

    const promises = [...this._application.server.clients].map(client => {
      try {
        devLog(`[Dispatch] Attempting to send to client:`, client.id); // Assuming client has an id
        return client.sendRemoteMessage(message);
      } catch (e) {
        console.error(`[Dispatch] Error in client.sendRemoteMessage for client ${client.id}:`, e);
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
    const registrationMap = {
      [ConnectionMessageTypes.aj]: this._registerAjHook.bind(this),
      [ConnectionMessageTypes.connection]: this._registerConnectionHook.bind(this),
      [ConnectionMessageTypes.any]: this._registerAnyHook.bind(this)
    }

    const registerHook = registrationMap[type]
    if (registerHook) {
      registerHook({ type, message, callback })
    }
  }

  /**
   * Unhooks a message.
   * @param options
   * @public
   */
  offMessage ({ type, message, callback } = {}) { // Added 'message' parameter
    const hooksMap = {
      [ConnectionMessageTypes.aj]: this.hooks.aj,
      [ConnectionMessageTypes.connection]: this.hooks.connection,
      [ConnectionMessageTypes.any]: this.hooks.any
    }

    const specificHooksMap = hooksMap[type]; // e.g., this.hooks.aj

    if (specificHooksMap) {
      // Use the 'message' parameter to get the correct list of callbacks
      const hookList = specificHooksMap.get(message);
      if (hookList) {
        const index = hookList.indexOf(callback);
        if (index !== -1) {
          hookList.splice(index, 1);
          if (isDevelopment) {
            devLog(`[Dispatch] Successfully removed hook for type='${type}', message='${message}'. Remaining: ${hookList.length}`);
          }
          // If the list becomes empty, optionally delete the key from the map
          if (hookList.length === 0) {
            specificHooksMap.delete(message);
            if (isDevelopment) {
              devLog(`[Dispatch] Hook list for type='${type}', message='${message}' is now empty. Key deleted.`);
            }
          }
        } else {
          if (isDevelopment) {
            devLog(`[Dispatch] Callback not found for type='${type}', message='${message}'. No action taken.`);
          }
        }
      } else {
        if (isDevelopment) {
          devLog(`[Dispatch] No hook list found for type='${type}', message='${message}'. No action taken.`);
        }
      }
    } else {
      if (isDevelopment) {
        devLog(`[Dispatch] Invalid hook type '${type}' for offMessage. No action taken.`);
      }
    }
  }

  /**
 * Registers a message hook for the specified type.
 * @param {string} type - The type of hook to register.
 * @param {object} hook - The hook object containing message and callback.
 * @private
 */
  _registerHook (type, { message, callback }) {
    // type is 'aj', message is the specific XT command string like 'rj' or 'login'
    devLog(`[ROOMLOGIC_DEBUG] Dispatch._registerHook: type='${type}', message='${message}'. Callback:`, callback.toString().substring(0,100)+"...");
    if (!this.hooks[type]) {
      devLog(`[ROOMLOGIC_DEBUG] Dispatch._registerHook: Invalid hook type array: ${type}`);
      return this._consoleMessage({
        type: 'error',
        message: `Invalid hook type: ${type}`
      });
    }

    const hooksMap = this.hooks[type]; // e.g., this.hooks.aj
    if (hooksMap.has(message)) {
      hooksMap.get(message).push(callback);
      devLog(`[ROOMLOGIC_DEBUG] Dispatch._registerHook: Added callback to existing hook for type='${type}', message='${message}'. New count: ${hooksMap.get(message).length}`);
    } else {
      hooksMap.set(message, [callback]);
      devLog(`[ROOMLOGIC_DEBUG] Dispatch._registerHook: Set new hook for type='${type}', message='${message}'. Count: 1`);
    }
    // For debugging, let's see the state of this.hooks.aj after registration
    if (type === 'aj') {
        devLog(`[ROOMLOGIC_DEBUG] Dispatch._registerHook: Current state of this.hooks.aj:`, this.hooks.aj);
    }
  }

  /**
 * Registers a local message hook.
 * @param {object} hook - The hook object.
 * @private
 */
  _registerConnectionHook (hook) {
    this._registerHook('connection', hook)
  }

  /**
 * Registers a remote message hook.
 * @param {object} hook - The hook object.
 * @private
 */
  _registerAjHook (hook) {
    devLog(`[ROOMLOGIC_DEBUG] Dispatch._registerAjHook: Registering AJ hook for message type: ${hook.message}`);
    this._registerHook('aj', hook);
  }

  /**
 * Registers any message hook.
 * @param {object} hook - The hook object.
 * @private
 */
  _registerAnyHook (hook) {
    this._registerHook('any', { message: ConnectionMessageTypes.any, callback: hook.callback })
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
   * Validates configuration and installs dependencies. Does not instantiate or render.
   * @param {string} filepath - Directory path of the plugin
   * @param {object} configuration - Raw configuration from plugin.json
   * @returns {Promise<object|null>} - Object containing validated config and filepath, or null on error
   * @private
   */
  async _validateAndPrepareConfig(filepath, configuration) {
    const validate = Ajv.compile(ConfigurationSchema);
    if (!validate(configuration)) {
      this._consoleMessage({
        type: 'error',
        message: `Failed validating configuration for plugin in ${filepath}. ${validate.errors[0].message}.`
      });
      return null;
    }

    // Check for duplicate name before proceeding (although checked again later)
    if (this.plugins.has(configuration.name)) {
       this._consoleMessage({
         type: 'warn',
         message: `Duplicate plugin name found during validation: ${configuration.name}`
       });
    }

    try {
      // Ensure dependencies are installed before returning the config object
      await this.installDependencies(configuration);
      // Return an object that includes both filepath and the (now defaulted by AJV) configuration
      return { filepath, configuration }; 
    } catch (error) {
      this._consoleMessage({
        type: 'error',
        message: `Error installing dependencies for plugin in ${filepath}: ${error.message}`
      });
      return null;
    }
  }

  /**
   * Processes a single validated plugin config: instantiates/stores plugin and renders UI item.
   * @param {object} configData - Object containing { filepath, configuration }
   * @returns {Promise<void>}
   * @private
   */
  async _processAndRenderPlugin(configData) {
    const { filepath, configuration } = configData;

    // Final duplicate check before storing
    if (this.plugins.has(configuration.name)) {
      this._consoleMessage({
        type: 'error',
        message: `Plugin with the name ${configuration.name} already exists. Skipping.`
      });
      return;
    }

    try {
      let pluginInstance = null;
      if (configuration.type === 'game') {
        const PluginClass = require(path.join(filepath, configuration.main));
        pluginInstance = new PluginClass({
          application: this._application,
          dispatch: this,
          dataPath: this.dataPath
        });
      }

      // Store plugin data (instance is null for UI plugins here)
      this.plugins.set(configuration.name, {
        configuration,
        filepath,
        plugin: pluginInstance // Store instance for game plugins
      });

      // Render the item using Application method - this now returns the element
      const $pluginElement = this._application.renderPluginItems(configuration); 

      // Append the rendered element to the list
      this._application.$pluginList.append($pluginElement);

    } catch (error) {
      this._consoleMessage({
        type: 'error',
        message: `Error processing/rendering plugin ${configuration.name}: ${error.message}`
      });
    }
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
}
