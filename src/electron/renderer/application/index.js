/* eslint-disable camelcase */
const { ipcRenderer } = require('electron')
const { EventEmitter } = require('events')

const isDevelopment = process.env.NODE_ENV === 'development'
const Server = require('../../../networking/server')
const Settings = require('./settings')
const Patcher = require('./patcher')
const Dispatch = require('./dispatch')
const ModalSystem = require('./modals')
const PluginInfoModalManager = require('../ui/plugin-info-modal-manager')
const registerCoreCommands = require('./core-commands')
const Tooltip = require('./components/tooltip')
const ToastService = require('../../../ui/services/ToastService')
const TooltipManager = require('../../../ui/managers/TooltipManager')
const NetworkEventHandler = require('../../../managers/network/NetworkEventHandler')
const ConsoleManager = require('../../../ui/managers/ConsoleManager')
const GameLauncher = require('../../../managers/game/GameLauncher')
const PluginUIManager = require('../../../ui/managers/PluginUIManager')
const IPCManager = require('../../../managers/ipc/IPCManager')
const AutoCompleteManager = require('../../../ui/managers/AutoCompleteManager')
const VersionChecker = require('../../../services/update/VersionChecker')
const WindowActionManager = require('../../../managers/window/WindowActionManager')
const ModalActionManager = require('../../../ui/managers/ModalActionManager')
const ServerHostChecker = require('../../../services/network/ServerHostChecker')
const CommandRegistry = require('../../../managers/command/CommandRegistry')

/**
 * Message status icons (using FontAwesome).
 * @type {Object}
 * @constant
 */
const messageIcons = Object.freeze({
  success: 'fa-check-circle',
  error: 'fa-times-circle',
  wait: 'fa-spinner fa-pulse',
  celebrate: 'fa-trophy',
  warn: 'fa-exclamation-triangle',
  notify: 'fa-info-circle',
  speech: 'fa-comment-alt',
  logger: 'fa-file-alt',
  action: 'fa-bolt',
  welcome: 'fa-heart'
})



module.exports = class Application extends EventEmitter {
  /**
   * Constructor.
   * @constructor
   */
  constructor () {
    super()

    /**
     * The data path received from the main process.
     * @type {string|null}
     * @public
     */
    this.dataPath = null;
    this.assetsPath = null;

    /**
     * Promise that resolves when the data path is received from the main process.
     * @type {Promise<void>}
     * @private
     */
    this.pathPromise = new Promise((resolve) => {
      ipcRenderer.once('set-data-path', (event, receivedPath) => {
        this.dataPath = receivedPath;
      });
      ipcRenderer.once('set-assets-path', (event, receivedPath) => {
        this.assetsPath = receivedPath;
        resolve();
      });
    });

    /**
     * The reference to the server connection.
     * @type {Server}
     * @public
     */
    this.server = new Server(this)

    /**
     * The reference to the settings manager.
     * @type {Settings}
     * @public
     */
    this.settings = new Settings()

    /**
     * The reference to the patcher manager.
     * @type {Patcher}
     * @public
     */
    this.patcher = null

    // Dispatch will be initialized in instantiate() after dataPath is received
    /**
     * The reference to the dispatch.
     * @type {Dispatch}
     * @public
     */
    this.dispatch = null;

    /**
     * Stores the modal system.
     * @type {ModalSystem}
     * @public
     */
    this.modals = new ModalSystem(this)
    this.modals.initialize()

    /**
     * The reference to the plugin info modal manager.
     * @type {PluginInfoModalManager}
     * @public
     */
    this.pluginInfoModalManager = null

    /**
     * The reference to the tooltip manager.
     * @type {TooltipManager}
     * @public
     */
    this.tooltipManager = null

    /**
     * The reference to the network event handler.
     * @type {NetworkEventHandler}
     * @public
     */
    this.networkEventHandler = null

    /**
     * The reference to the console manager.
     * @type {ConsoleManager}
     * @public
     */
    this.consoleManager = null

    /**
     * The reference to the game launcher.
     * @type {GameLauncher}
     * @public
     */
    this.gameLauncher = null

    /**
     * The reference to the plugin UI manager.
     * @type {PluginUIManager}
     * @public
     */
    this.pluginUIManager = null

    /**
     * The reference to the IPC manager.
     * @type {IPCManager}
     * @public
     */
    this.ipcManager = null

    /**
     * The reference to the autocomplete manager.
     * @type {AutoCompleteManager}
     * @public
     */
    this.autoCompleteManager = null

    /**
     * The reference to the version checker.
     * @type {VersionChecker}
     * @public
     */
    this.versionChecker = null

    /**
     * The reference to the window action manager.
     * @type {WindowActionManager}
     * @public
     */
    this.windowActionManager = null

    /**
     * The reference to the modal action manager.
     * @type {ModalActionManager}
     * @public
     */
    this.modalActionManager = null

    /**
     * The reference to the server host checker.
     * @type {ServerHostChecker}
     * @public
     */
    this.serverHostChecker = null

    /**
     * The reference to the command registry.
     * @type {CommandRegistry}
     * @public
     */
    this.commandRegistry = null

    /**
     * The reference to the application input.
     * @type {JQuery<HTMLElement>}
     * @private
     */
    this.$input = $('#input')

    /**
     * The reference to the plugin list.
     * @type {JQuery<HTMLElement>}
     * @private
     */
    this.$pluginList = $('#pluginList')

    /**
     * Handles the input events.
     * @type {void}
     * @private
     */
    this.$input.on('keydown', (event) => {
      if (event.key === 'Enter') {
        const message = this.$input.val().trim()
        if (!message) return;
        
        const [command, ...parameters] = message.split(' ')

        if (this.dispatch && this.dispatch.commands) {
          const cmd = this.dispatch.commands.get(command)
          if (cmd) {
            try {
              cmd.callback({ parameters })
            } catch (error) {
              this.consoleMessage({
                type: 'error',
                message: `Error executing command '${command}': ${error.message}`
              });
            }
          } else {
            this.consoleMessage({
              type: 'error',
              message: `Unknown command: '${command}'. Type 'help' for available commands.`
            });
          }
        } else {
          this.consoleMessage({
            type: 'error',
            message: 'Command system not initialized yet.'
          });
        }

        this.$input.val('')
      } else if (event.key === 'Tab') {
        event.preventDefault();
        if (this.autoCompleteManager) {
          this.autoCompleteManager.handleTabCompletion();
        }
      }
    })

    /**
     * The reference to the play button element.
     * @type {HTMLElement | null}
     * @private
     */
    this.$playButton = document.getElementById('playButton')

    /**
     * Whether the game client is currently running.
     * @type {boolean}
     * @private
     */
    this._isGameRunning = false

    this.windowActionManager = new WindowActionManager()
    this.modalActionManager = new ModalActionManager(this)

    this.ipcManager = new IPCManager(this)
    this.ipcManager.setupPluginIPC()
    this.ipcManager.setupStatusIndicatorIPC()
    this.ipcManager.setupGameProcessIPC()
  }

  /**
   * Checks if the Animal Jam server host has changed.
   * @returns {Promise<void>}
   * @private
   */
  async _checkForHostChanges () {
    if (this.serverHostChecker) {
      await this.serverHostChecker.check()
    }
  }

  // /**
  //  * Sets up IPC listeners for application update status. (REMOVED - Global toasts for updates are disabled)
  //  * @private
  //  */
  // _setupAppUpdateIPC() {
  //   if (typeof require === "function") {
  //     try {
  //       const { ipcRenderer } = require('electron');
  //       ipcRenderer.on('app-update-status', (event, { status, message, version }) => {
  //         devLog(`[Renderer IPC] Received app-update-status: ${status}, Message: ${message}, Version: ${version}`);
  //         let toastType = 'notify';
  //         let toastMessage = message;
  //         let duration = 7000; // Default duration from previous adjustment
  //
  //         switch (status) {
  //           case 'checking':
  //             toastType = 'checking'; // Use a specific type for styling if needed, or 'notify'
  //             break;
  //           case 'no-update':
  //             toastType = 'success';
  //             break;
  //           case 'available':
  //             toastType = 'available';
  //             toastMessage = version ? `${message} (v${version})` : message;
  //             duration = 5000; // Keep available message longer (reverted from 7000 for this specific case if desired)
  //             break;
  //           case 'downloaded':
  //             toastType = 'downloaded'; // Or 'celebrate' from settings.js
  //             duration = 7000; // Keep downloaded message longer
  //             break;
  //           case 'error':
  //             toastType = 'error';
  //             duration = 5000; // Reverted from 7000 for this specific case if desired
  //             break;
  //           default:
  //             toastType = 'notify';
  //         }
  //         showGlobalToast(toastMessage, toastType, duration);
  //       });
  //     } catch (e) {
  //       devError("[Renderer IPC] Error setting up app update status listeners:", e);
  //     }
  //   }
  // }

  /**
   * Updates the status indicator for a specific plugin.
   * @param {string} pluginName - The name of the plugin.
   * @param {boolean} isOpen - Whether the plugin window is open.
   * @private
   */
  _updatePluginStatusIndicator(pluginName, isOpen) {
    if (this.pluginUIManager) {
      this.pluginUIManager.updatePluginStatusIndicator(pluginName, isOpen)
    }
  }

  open (url) {
    this.windowActionManager.open(url)
  }

  /**
   * Opens the plugin directory.
   * @param name
   * @public
   */
  directory (name) {
    this.windowActionManager.directory(name, this.dispatch)
  }

  /**
   * Opens the settings modal.
   * @returns {void}
   * @public
   */
  openSettings () {
    this.modalActionManager.openSettings()
  }

  /**
   * Opens the Plugin Hub modal.
   * @public
   */
  openPluginHub () {
    this.modalActionManager.openPluginHub()
  }

  /**
   * Opens the Links modal.
   * @public
   */
  openLinksModal () {
    this.modalActionManager.openLinksModal()
  }

  /**
   * Minimizes the application.
   * @public
   */
  minimize () {
    this.windowActionManager.minimize()
  }

  /**
   * Closes the application.
   * @public
   */
  async close () {
    await this.windowActionManager.close(this.modals)
  }

  /**
   * Toggles fullscreen mode.
   * @public
   */
  toggleFullscreen () {
    this.windowActionManager.toggleFullscreen()
  }

  /**
   * Toggles maximize/restore window.
   * @public
   */
  toggleMaximize () {
    this.windowActionManager.toggleMaximize()
  }

  /**
   * Relaunches the application.
   * @public
   */
  relaunch () {
    this.windowActionManager.relaunch()
  }

  /**
   * Attaches networking events.
   * @public
   */
  attachNetworkingEvents () {
    if (this.networkEventHandler) {
      this.networkEventHandler.attach()
    }
  }

  /**
   * Handles input autocomplete activation.
   * @type {void}
   * @public
   */
  activateAutoComplete () {
    if (this.autoCompleteManager) {
      this.autoCompleteManager.activate()
    }
  }

  /**
   * Refreshes the autocomplete source.
   * @public
   */
  refreshAutoComplete () {
    if (this.autoCompleteManager) {
      this.autoCompleteManager.refresh()
    }
  }

  /**
   * Displays a new console message.
   * @param message
   * @public
   */
  consoleMessage (params = {}) {
    if (this.consoleManager) {
      this.consoleManager.message(params)
    }
  }

  /**
   * Updates an existing console message by its data-message-id.
   * @param {string} messageId - The identifier used when the message was created
   * @param {Object} params - Update parameters
   * @param {string} params.message - New message text
   * @param {string} [params.type='success'] - New message type
   * @returns {boolean} True if updated, false if not found
   * @public
   */
  updateConsoleMessage(messageId, params = {}) {
    if (this.consoleManager) {
      return this.consoleManager.updateMessage(messageId, params)
    }
    return false
  }

  /**
   * Loads log limit settings from user settings.
   * @private
   * @returns {Promise<void>}
   */
  async _loadLogLimitSettings() {
    if (this.consoleManager) {
      await this.consoleManager.loadLogLimitSettings()
    }
  }

  /**
   * Removes all messages with a specific ID.
   * @param {string} messageId - The ID of the message(s) to remove
   * @private
   */
  _removeMessageById(messageId) {
    if (this.consoleManager) {
      this.consoleManager.removeMessageById(messageId)
    }
  }

  /**
   * Opens Animal Jam Classic
   * @returns {Promise<void>}
   * @public
   */
  async openAnimalJam () {
    if (this.gameLauncher) {
      await this.gameLauncher.openAnimalJam()
    }
  }

  /**
   * Opens AJ Classic external installation
   * @returns {Promise<void>}
   * @public
   */
  async openAJClassic () {
    if (this.gameLauncher) {
      await this.gameLauncher.openAJClassic()
    }
  }

  /**
   * Renders the plugin items within the list.
   * @param {object} plugin - The plugin details
   * @param {string} plugin.name - The name of the plugin
   * @param {string} plugin.type - The type of the plugin ('game' or 'ui')
   * @param {string} plugin.description - The description of the plugin
   * @param {string} [plugin.author='Sxip'] - The author of the plugin
   * @returns {JQuery<HTMLElement>} - The plugin list item
   * @public
   */
  renderPluginItems (params = {}) {
    if (this.pluginUIManager) {
      return this.pluginUIManager.renderItems(params)
    }
    return $()
  }

  /**
   * Updates the empty plugin message visibility
   * @private
   */
  _updateEmptyPluginMessage() {
    if (this.pluginUIManager) {
      this.pluginUIManager.updateEmptyPluginMessage()
    }
  }

  /**
   * Instantiates the application.
   * @returns {Promise<void>}
   * @public
   */
  async instantiate () {
    await this.pathPromise

    this.patcher = new Patcher(this, this.assetsPath)
    
    this.consoleManager = new ConsoleManager(this, messageIcons)
    this.dispatch = new Dispatch(
      this,
      this.dataPath,
      this.consoleMessage.bind(this)
    )

    this.gameLauncher = new GameLauncher(this)
    this.pluginUIManager = new PluginUIManager(this)
    this.autoCompleteManager = new AutoCompleteManager(this)
    this.versionChecker = new VersionChecker(this)
    this.serverHostChecker = new ServerHostChecker(this)
    this.commandRegistry = new CommandRegistry(this)

    this.pluginInfoModalManager = new PluginInfoModalManager(this.dispatch)

    ipcRenderer.on('get-plugin-path', (event, pluginName) => {
      const plugin = this.dispatch.plugins.get(pluginName)
      ipcRenderer.send('plugin-path-response', plugin ? plugin.filepath : null)
    })
    
    registerCoreCommands(this.dispatch, this)
    
    await this.settings.load()
    await this._loadLogLimitSettings()
    
    this.tooltipManager = new TooltipManager(this)
    this.tooltipManager.initialize()
    
    this.networkEventHandler = new NetworkEventHandler(this, this.dispatch)
    
    const startupMessageId = `startup-message-${Date.now()}`
    this.consoleMessage({
      message: 'Starting Strawberry Jam...',
      type: 'wait',
      details: { messageId: startupMessageId }
    })
    
    const loadingPluginsMessageId = `loading-plugins-message-${Date.now()}`
    this.consoleMessage({
      message: 'Loading plugins...',
      type: 'wait',
      details: { messageId: loadingPluginsMessageId }
    })
    
    await this.dispatch.load()
    
    const pluginCount = this.dispatch.plugins ? this.dispatch.plugins.size : 0
    this.consoleMessage({
      message: `Successfully loaded ${pluginCount} plugins.`,
      type: 'success'
    })

    this.refreshAutoComplete()

    const secureConnection = this.settings.get('secureConnection')
    if (secureConnection) {
      await this._checkForHostChanges()
    }

    const PortChecker = require('../../../utils/PortChecker')
    const port443Busy = await PortChecker.isPortBusy(443)
    const port8080Busy = await PortChecker.isPortBusy(8080)

    const busyPorts = []
    const portDetails = []
    
    if (port443Busy) {
      const processInfo = await PortChecker.findProcessUsingPort(443)
      if (processInfo && processInfo.processName && processInfo.processName.toLowerCase() !== 'electron.exe') {
        busyPorts.push('443')
        portDetails.push(`Port 443: ${processInfo.processName} (PID: ${processInfo.pid})`)
      }
    }
    
    if (port8080Busy) {
      const processInfo = await PortChecker.findProcessUsingPort(8080)
      if (processInfo && processInfo.processName && processInfo.processName.toLowerCase() !== 'electron.exe') {
        busyPorts.push('8080')
        portDetails.push(`Port 8080: ${processInfo.processName} (PID: ${processInfo.pid})`)
      }
    }

    if (busyPorts.length > 0) {
      const message = `Port${busyPorts.length > 1 ? 's' : ''} ${busyPorts.join(' and ')} ${busyPorts.length > 1 ? 'are' : 'is'} already in use. ${portDetails.join(' ')} Use the "terminate" command to close processes using these ports, then restart the application.`
      this.consoleMessage({
        type: 'warn',
        message: message
      })
    }

    await this.server.serve()
    
    this._removeMessageById(startupMessageId)
    this._removeMessageById(loadingPluginsMessageId)
    
    if (this.initialStartupMessageId) {
      this._removeMessageById(this.initialStartupMessageId)
      this.initialStartupMessageId = null
    }
    
    this.consoleMessage({
      message: `Server started on port ${this.server.actualPort}!`,
      type: 'success'
    })
    
    this.consoleMessage({
      message: 'Enjoy 33.33% off BerryBreach purchases using code "HOLIDAYS2025" until 12/31/2025.',
      type: 'welcome'
    })
    
    this.emit('ready')

    await this._checkVersionAndShowUpdatesModal()
    ipcRenderer.send('renderer-ready')

    // Set up handlers for the minimize and close buttons
    const minimizeButton = document.getElementById('minimizeButton');
    const mainCloseButton = document.getElementById('mainCloseButton');
    
    if (minimizeButton) {
      minimizeButton.addEventListener('click', () => this.minimize())
    }

    if (mainCloseButton) {
      mainCloseButton.addEventListener('click', () => this.close())
    }
    
    setTimeout(() => {
      if (this.tooltipManager) {
        this.tooltipManager.applyTooltips()
      }
    }, 500)
    
    ipcRenderer.on('show-exit-confirmation', () => {
      this.modals.show('confirmExitModal')
    })

    ipcRenderer.on('plugins-closed-by-aj-classic', () => {
    })

    this.modalActionManager.initializeModalCloseButtonStyles()
  }
  
  /**
   * Create a tooltip for an element.
   * This is a convenience method for creating tooltips with common options.
   * 
   * @param {HTMLElement|jQuery} element - Target element to attach tooltip to
   * @param {string} content - Tooltip content/text
   * @param {Object} options - Tooltip options
   * @returns {HTMLElement} - The element with attached tooltip
   * @public
   */
  addTooltip(element, content, options = {}) {
    if (this.tooltipManager) {
      return this.tooltipManager.addTooltip(element, content, options)
    }
    return Tooltip.create(element, content, options)
  }

  /**
   * Adds a tooltip to the play button indicating the game is running.
   * @private
   */
  _addGameRunningTooltip() {
    if (this.tooltipManager && this.$playButton) {
      this.tooltipManager.addGameRunningTooltip(this.$playButton)
    }
  }

  _removeGameRunningTooltip() {
    if (this.tooltipManager) {
      this.tooltipManager.removeGameRunningTooltip()
    }
  }

  /**
   * Reloads log limit settings after they've been changed.
   * @public
   */
  reloadLogLimitSettings() {
    if (this.consoleManager) {
      this.consoleManager.loadLogLimitSettings()
    }
  }

  /**
   * Register a console command
   * @param {string} name - Command name
   * @param {Function} callback - Command callback
   * @param {string} [description] - Command description
   * @returns {boolean} - Success
   * @public
   */
  registerConsoleCommand(name, callback, description = '') {
    if (this.commandRegistry) {
      return this.commandRegistry.register(name, callback, description)
    }
    return false
  }

  /**
   * Opens the Report Problem modal.
   * @public
   */
  openReportProblemModal () {
    this.modalActionManager.openReportProblemModal()
  }

  /**
   * Checks for version updates and shows the updates modal if needed.
   * @returns {Promise<void>}
   * @private
   */
  async _checkVersionAndShowUpdatesModal() {
    if (this.versionChecker) {
      await this.versionChecker.checkAndShow()
    }
  }

  /**
   * Opens the Updates modal manually.
   * @param {string} [version=null] - Version to show, or null to use latest
   * @returns {Promise<void>}
   * @public
   */
  async openUpdatesModal(version = null) {
    if (this.versionChecker) {
      await this.versionChecker.openUpdatesModal(version)
    }
  }
}
