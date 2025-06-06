/* eslint-disable camelcase */
const { ipcRenderer } = require('electron')
const { EventEmitter } = require('events')

// Define isDevelopment for environment checks
const isDevelopment = process.env.NODE_ENV === 'development';

// Helper: Only log in development
function devLog(...args) {
  if (isDevelopment) console.log(...args);
}
function devError(...args) {
  if (isDevelopment) console.error(...args);
}
function devWarn(...args) {
  if (isDevelopment) console.warn(...args);
}
const Server = require('../../../networking/server')
const Settings = require('./settings')
const Patcher = require('./patcher')
const Dispatch = require('./dispatch')
const HttpClient = require('../../../services/HttpClient')
const ModalSystem = require('./modals')
const registerCoreCommands = require('./core-commands')
const Tooltip = require('./components/tooltip') // Import our tooltip component

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

    /**
     * Promise that resolves when the data path is received from the main process.
     * @type {Promise<void>}
     * @private
     */
    this.dataPathPromise = new Promise((resolve) => {
      ipcRenderer.once('set-data-path', (event, receivedPath) => {
        devLog(`[Renderer] Received data path: ${receivedPath}`);
        this.dataPath = receivedPath;
        resolve(); // Resolve the promise once path is received
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
    this.patcher = new Patcher(this)

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
        const [command, ...parameters] = message.split(' ')

        const cmd = this.dispatch.commands.get(command)
        if (cmd) {
          cmd.callback({ parameters })
        }

        this.$input.val('')
      }
    })

    /**
     * Maximum number of log entries to keep before cleaning.
     * @type {number}
     * @private
     */
    this._maxLogEntries = 1000; // Default to 1000 instead of 600

    /**
     * Maximum number of console log entries to keep before cleaning.
     * @type {number}
     * @private
     */
    this._consoleLogLimit = 1000;

    /**
     * Maximum number of network log entries to keep before cleaning.
     * @type {number}
     * @private
     */
    this._networkLogLimit = 1000;

    /**
     * Percentage of logs to remove when cleaning.
     * @type {number}
     * @private
     */
    this._cleanPercentage = 0.4; // Remove 40%

    /**
     * Current count of packet log entries.
     * @type {number}
     * @private
     */
    this._packetLogCount = 0;

    /**
     * Current count of application message entries.
     * @type {number}
     * @private
     */
    this._appMessageCount = 0;

    /**
     * The reference to the play button element.
     * @type {HTMLElement | null}
     * @private
     */
    this.$playButton = document.getElementById('playButton'); // Use vanilla JS as jQuery might not be ready

    this._setupPluginIPC(); // Moved from instantiate to ensure handlers are ready early
    this._setupStatusIndicatorIPC(); // Add call to setup new listeners
  }

  /**
   * Checks if the Animal Jam server host has changed.
   * @returns {Promise<void>}
   * @private
   */
  async _checkForHostChanges () {
    const DEFAULT_SERVER = 'lb-iss04-classic-prod.animaljam.com';
    
    try {
      // Get flashvars data from AJ
      const data = await HttpClient.fetchFlashvars();
      
      // Handle missing data
      if (!data || !data.smartfoxServer) {
        // Ensure we have a server value
        const currentServer = this.settings.get('smartfoxServer');
        if (!currentServer || typeof currentServer !== 'string' || !currentServer.includes('animaljam')) {
          this.settings.update('smartfoxServer', DEFAULT_SERVER);
        }
        return;
      }
      
      let { smartfoxServer } = data;
      
      // Process the server address if it's valid
      if (typeof smartfoxServer === 'string') {
        smartfoxServer = smartfoxServer.replace(/\.(stage|prod)\.animaljam\.internal$/, '-$1.animaljam.com');
        smartfoxServer = `lb-${smartfoxServer}`;
        
        // Only proceed if we got a valid server
        if (smartfoxServer && smartfoxServer.includes('animaljam')) {
          try {
            const currentServer = this.settings.get('smartfoxServer');
            
            if (smartfoxServer !== currentServer) {
              // Update the server setting
              this.settings.update('smartfoxServer', smartfoxServer);
              
              // Notify the user
              this.consoleMessage({
                message: 'Server host has changed. Changes are now being applied.',
                type: 'notify'
              });
            }
          } catch (settingsError) {
            // Silently handle settings error and set directly if needed
            if (this.settings && this.settings.settings) {
              this.settings.settings.smartfoxServer = smartfoxServer;
            }
          }
        }
      }
    } catch (error) {
      // Only show error to user, don't log to console
      this.consoleMessage({ 
        type: 'warn', 
        message: 'Could not check for server updates. Using saved server settings.'
      });
      
      // Ensure we have a valid server value regardless of errors
      try {
        const currentServer = this.settings.get('smartfoxServer');
        if (!currentServer || typeof currentServer !== 'string' || !currentServer.includes('animaljam')) {
          this.settings.update('smartfoxServer', DEFAULT_SERVER);
        }
      } catch (err) {
        // Last resort - try to set directly
        if (this.settings && this.settings.settings) {
          this.settings.settings.smartfoxServer = DEFAULT_SERVER;
        }
      }
    }
  }

  /**
   * Sets up IPC listeners for messages forwarded from plugin windows.
   * @private
   */
  _setupPluginIPC () {
    if (typeof require === "function") {
      try {
        const { ipcRenderer } = require('electron');
        // room-tracking.js is no longer used here as per reversion plan

        // Initialize room state with dispatch if window.jam.roomState exists
        if (window.jam && window.jam.roomState && this.dispatch) {
          // Set the dispatch on the roomState instance
          window.jam.roomState.dispatch = this.dispatch;
          console.log("[Application] Successfully initialized window.jam.roomState with dispatch");
        }

        ipcRenderer.on('plugin-remote-message', async (event, msg) => { // Make handler async
          console.log('[AppIndex IPC] Received plugin-remote-message in renderer:', msg);
          let processedMsg = msg;
          
          // Check if dispatch is ready and message needs processing
          if (this.dispatch && typeof msg === 'string' && msg.includes('{room}')) {
            console.log('[AppIndex IPC] Message contains {room}, attempting to replace.');
            try {
              const currentRoom = await this.dispatch.getState('room'); // Await the async call
              if (currentRoom) {
                processedMsg = msg.replaceAll('{room}', currentRoom);
                console.log('[AppIndex IPC] Replaced {room}. ProcessedMsg:', processedMsg);
              } else {
                devWarn('[Application._setupPluginIPC] {room} placeholder found, but current room is null or undefined after await. Message will be sent with placeholder unreplaced.');
              }
            } catch (error) {
              devError('[Application._setupPluginIPC] Error awaiting room state for {room} replacement:', error);
              devWarn('[Application._setupPluginIPC] Message will be sent with {room} placeholder unreplaced due to error.');
            }
          }
          
          console.log(`[AppIndex IPC] this.dispatch is: ${typeof this.dispatch}`);
          if (this.dispatch) {
            console.log(`[AppIndex IPC] this.dispatch.sendRemoteMessage is: ${typeof this.dispatch.sendRemoteMessage}`);
          }

          // Send the (potentially processed) message
          if (this.dispatch && typeof this.dispatch.sendRemoteMessage === 'function') {
            console.log('[AppIndex IPC] Calling this.dispatch.sendRemoteMessage with:', processedMsg);
            this.dispatch.sendRemoteMessage(processedMsg).catch(err => {
              this.consoleMessage({ type: 'error', message: `Error sending remote message from plugin: ${err.message}` });
              console.error('[AppIndex IPC] Error in this.dispatch.sendRemoteMessage:', err);
            });
          } else {
            this.consoleMessage({ type: 'error', message: 'Cannot send remote message: Dispatch not ready.' });
            console.error('[AppIndex IPC] Dispatch not ready or sendRemoteMessage is not a function.');
          }
        });

        ipcRenderer.on('plugin-connection-message', (event, msg) => {
          if (this.dispatch && typeof this.dispatch.sendConnectionMessage === 'function') {
            this.dispatch.sendConnectionMessage(msg).catch(err => {
              this.consoleMessage({ type: 'error', message: `Error sending connection message from plugin: ${err.message}` });
            });
          } else {
            this.consoleMessage({ type: 'error', message: 'Cannot send connection message: Dispatch not ready.' });
          }
        });

        // Listener for UI plugins requesting state synchronously
        ipcRenderer.on('dispatch-get-state-sync', (event, key) => {
          if (this.dispatch && typeof this.dispatch.getState === 'function') {
            try {
              const value = this.dispatch.getState(key);
              devLog(`[ROOMLOGIC_DEBUG] Application 'dispatch-get-state-sync' handler: For key '${key}', returning value:`, value);
              event.returnValue = value; // Set return value for sendSync
            } catch (error) {
              devError(`[Main Renderer] Error getting sync state for key '${key}':`, error);
              event.returnValue = null; // Return null on error
            }
          } else {
            devError(`[Main Renderer] Cannot get sync state for key '${key}': Dispatch not ready.`);
            event.returnValue = null; // Return null if dispatch isn't ready
          }
        });

        // Listener for asynchronous state requests from the main process
        ipcRenderer.on('main-renderer-get-state-async', (event, { key, replyChannel }) => {
          let value = null;
          // Check if dispatch and getState are available
          if (this.dispatch && typeof this.dispatch.getState === 'function') {
            try {
              value = this.dispatch.getState(key);
            } catch (error) {
              devError(`[Main Renderer] Error getting ASYNC state for key '${key}':`, error);
              value = null; // Ensure value is null on error
            }
          } else {
            devError(`[Main Renderer] Cannot get ASYNC state for key '${key}': Dispatch not ready.`);
            value = null; // Ensure value is null if dispatch isn't ready
          }
          // Send the value back on the unique reply channel
          ipcRenderer.send(replyChannel, value);
        });

      } catch (e) {
        devError("[Main Renderer] Error setting up plugin IPC listeners:", e);
      }
    }
  }

  /**
   * Sets up IPC listeners for plugin window status updates.
   * @private
   */
  _setupStatusIndicatorIPC() {
    if (typeof require === "function") {
      try {
        const { ipcRenderer } = require('electron');

        ipcRenderer.on('plugin-window-opened', (event, pluginName) => {
          devLog(`[Renderer IPC] Received plugin-window-opened for: ${pluginName}`);
          this._updatePluginStatusIndicator(pluginName, true);
        });

        ipcRenderer.on('plugin-window-closed', (event, pluginName) => {
          devLog(`[Renderer IPC] Received plugin-window-closed for: ${pluginName}`);
          this._updatePluginStatusIndicator(pluginName, false);
        });
        
        ipcRenderer.on('plugin-window-focused', (event, pluginName) => {
          devLog(`[Renderer IPC] Received plugin-window-focused for: ${pluginName}`);
          // Blink the indicator to provide visual feedback that the window was focused
          const $listItem = this.$pluginList.find(`li[data-plugin-name="${pluginName}"]`);
          const $indicator = $listItem.find('.plugin-status-indicator');
          if ($indicator.length > 0) {
            // Quick blink animation
            $indicator.addClass('plugin-focus-blink');
            setTimeout(() => {
              $indicator.removeClass('plugin-focus-blink');
            }, 1000);
          }
        });

      } catch (e) {
        devError("[Renderer IPC] Error setting up status indicator listeners:", e);
      }
    }
  }

  /**
   * Updates the status indicator for a specific plugin.
   * @param {string} pluginName - The name of the plugin.
   * @param {boolean} isOpen - Whether the plugin window is open.
   * @private
   */
  _updatePluginStatusIndicator(pluginName, isOpen) {
    // Ensure pluginList is available
    if (!this.$pluginList || this.$pluginList.length === 0) {
        devError(`[Status Update] Cannot update indicator for ${pluginName}: $pluginList not found.`);
        return;
    }
    
    const $listItem = this.$pluginList.find(`li[data-plugin-name="${pluginName}"]`);
    if ($listItem.length === 0) {
        // It's possible the list hasn't fully rendered yet, or the plugin isn't listed.
        // We could potentially retry or queue the update, but for now, just log.
        devWarn(`[Status Update] List item for plugin "${pluginName}" not found.`);
        return;
    }

    const $indicator = $listItem.find('.plugin-status-indicator');
    if ($indicator.length === 0) {
        devError(`[Status Update] Status indicator for plugin "${pluginName}" not found within list item.`);
        return;
    }

    // Only update UI plugins
    const pluginType = $listItem.data('plugin-type');
    if (pluginType === 'ui') {
        if (isOpen) {
            $indicator.removeClass('bg-red-500 bg-yellow-500').addClass('bg-green-500');
            devLog(`[Status Update] Set indicator for ${pluginName} to GREEN`);
        } else {
            $indicator.removeClass('bg-green-500 bg-yellow-500').addClass('bg-red-500');
            devLog(`[Status Update] Set indicator for ${pluginName} to RED`);
        }
    } else {
         // Keep game plugins yellow
         $indicator.removeClass('bg-red-500 bg-green-500').addClass('bg-yellow-500');
         // devLog(`[Status Update] Ignored status update for non-UI plugin ${pluginName}`);
    }
  }

  open (url) {
    ipcRenderer.send('open-url', url)
  }

  /**
   * Opens the plugin directory.
   * @param name
   * @public
   */
  directory (name) {
    const plugin = this.dispatch.plugins.get(name)

    if (plugin) {
      const { filepath } = plugin
      ipcRenderer.send('open-directory', filepath)
    }
  }

  /**
   * Opens the settings modal.
   * @returns {void}
   * @public
   */
  openSettings () {
    this.modals.show('settings')
    
    // Set up a one-time event listener for settings modal close
    // to reload log limits in case they changed
    const onModalClosed = () => {
      this.reloadLogLimitSettings();
      this.removeListener('modal:closed:settings', onModalClosed);
    };
    
    this.once('modal:closed:settings', onModalClosed);
  }

  /**
   * Opens the Plugin Hub modal.
   * @public
   */
  openPluginHub () {
    this.modals.show('pluginHub', '#modalContainer')
  }

  /**
   * Opens the Links modal.
   * @public
   */
  openLinksModal () {
    this.modals.show('links', '#modalContainer')
  }

  /**
   * Minimizes the application.
   * @public
   */
  minimize () {
    ipcRenderer.send('window-minimize')
  }

  /**
   * Closes the application.
   * @public
   */
  async close () { // Make the method async
    try {
      // Get the 'promptOnExit' setting from the main process
      const promptOnExit = await ipcRenderer.invoke('get-setting', 'ui.promptOnExit');
      // console.log(`[Renderer Application.close] Value of 'ui.promptOnExit' from main: ${promptOnExit}`);

      if (promptOnExit === false) {
        // If promptOnExit is false, tell the main process to close directly
        console.log('[Renderer Application.close] promptOnExit is false, sending direct-close-window to main.');
        ipcRenderer.send('direct-close-window'); // We'll need to handle this in the main process
      } else {
        // Otherwise, show the exit confirmation modal
        // console.log('[Renderer Application.close] promptOnExit is true or undefined, showing confirmExitModal.');
        this.modals.show('confirmExitModal');
      }
    } catch (error) {
      console.error('[Renderer Application.close] Error in close method:', error);
      // Fallback: if there's an error getting the setting, or showing the modal,
      // attempt to close via the main process's default window-close logic.
      ipcRenderer.send('window-close');
    }
  }

  /**
   * Toggles fullscreen mode.
   * @public
   */
  toggleFullscreen () {
    ipcRenderer.send('window-toggle-fullscreen')
  }

  /**
   * Toggles maximize/restore window.
   * @public
   */
  toggleMaximize () {
    ipcRenderer.send('window-toggle-maximize')
  }

  /**
   * Relaunches the application.
   * @public
   */
  relaunch () {
    ipcRenderer.send('application-relaunch')
  }

  /**
   * Attaches networking events.
   * @public
   */
  attachNetworkingEvents () {
    this.dispatch.onMessage({
      type: '*',
      callback: ({ message, type }) => {
        // Broadcast packet event to main process for UI plugins
        if (typeof require === "function") {
          try {
            const { ipcRenderer } = require('electron');
            // const roomUtils = require('../../../utils/room-tracking'); // Reversion: room-tracking.js no longer populates dispatch.state here
            
            // Parse raw message for room state updates
            const rawMessage = message.toMessage();
            devLog(`[ROOMLOGIC_DEBUG] Application.attachNetworkingEvents: Received packet. Type: ${type}, Raw: ${rawMessage}. Dispatching to Dispatch.all...`);
            
            // Try to update room state if this is an incoming packet
            // Room state (basic room ID and player data) is now set directly by Dispatch.js
            // based on 'rj' and 'login' packets, aligning with @jam-master's logic.
            // The room-tracking.js utility is no longer used by Application.js to populate dispatch.state.
            
            ipcRenderer.send('packet-event', {
              raw: rawMessage,
              direction: type === 'aj' ? 'in' : 'out',
              timestamp: Date.now()
            });
          } catch (e) {
            // Ignore if not available
          }
        }
        
        // Detect login success (%xt%l%-1%) and show friendly message
        if (type === 'aj' && message.toMessage().includes('%xt%l%-1%')) {
          this.consoleMessage({
            type: 'success',
            message: 'Successfully logged in!'
          });
        }
        
        this.consoleMessage({
          type: 'speech',
          isPacket: true,
          isIncoming: type === 'aj',
          message: message.toMessage()
        })
      }
    })
  }

  /**
   * Handles input autocomplete activation.
   * @type {void}
   * @public
   */
  activateAutoComplete () {
    if (!$('#autocomplete-styles').length) {
      $('head').append(`
        <style id="autocomplete-styles">
          .ui-autocomplete {
            max-height: 280px;
            overflow-y: auto;
            overflow-x: hidden;
            padding: 8px;
            backdrop-filter: blur(8px);
            scrollbar-width: thin;
            scrollbar-color: #3A3D4D #121212;
          }
          .ui-autocomplete::-webkit-scrollbar {
            width: 8px;
          }
          .ui-autocomplete::-webkit-scrollbar-track {
            background: #121212;
          }
          .ui-autocomplete::-webkit-scrollbar-thumb {
            background: #3A3D4D;
            border-radius: 8px;
          }
          .ui-autocomplete::-webkit-scrollbar-thumb:hover {
            background: #5A5F6D;
          }
          .autocomplete-item {
            padding: 6px !important;
            border-radius: 6px;
            margin-bottom: 4px;
            border: 1px solid transparent;
            transition: all 0.15s ease;
          }
          .autocomplete-item {
            padding: 6px !important;
            border-radius: 6px;
            margin-bottom: 4px;
            border: 1px solid transparent;
            transition: all 0.15s ease;
          }
          .autocomplete-item.ui-state-focus {
            border: 1px solid rgba(52, 211, 153, 0.5) !important;
            background: rgba(52, 211, 153, 0.1) !important;
            margin: 0 0 4px 0 !important;
          }
          .autocomplete-item-content {
            display: flex;
            flex-direction: column;
            gap: 2px;
          }
          .autocomplete-item-name {
            font-size: 14px;
            font-weight: 500;
            color: var(--text-primary, #e2e8f0);
            display: flex;
            align-items: center;
            gap: 6px;
          }
          .autocomplete-item-description {
            font-size: 12px;
            opacity: 0.7;
            color: var(--text-secondary, #a0aec0);
            margin-left: 16px;
          }
          .autocomplete-shortcut {
            margin-top: 4px;
            font-size: 10px;
            color: rgba(160, 174, 192, 0.6);
            display: flex;
            justify-content: flex-end;
          }
          .autocomplete-shortcut kbd {
            background: rgba(45, 55, 72, 0.6);
            border-radius: 3px;
            padding: 1px 4px;
            margin: 0 2px;
            border: 1px solid rgba(160, 174, 192, 0.2);
            font-family: monospace;
          }
        </style>
      `)
    }

    this.$input.autocomplete({
      source: Array.from(this.dispatch.commands.values()).map(command => ({
        value: command.name,
        description: command.description
      })),
      position: { my: 'left top', at: 'left bottom', collision: 'flip' },
      classes: {
        'ui-autocomplete': 'bg-secondary-bg/95 border border-sidebar-border rounded-lg shadow-lg z-50'
      },
      delay: 50,
      minLength: 0,
      create: function () {
        $(this).data('ui-autocomplete')._resizeMenu = function () {
          this.menu.element.css({ width: this.element.outerWidth() + 'px' })
        }
      },
      select: function (event, ui) {
        this.value = ui.item.value
        return false
      },
      focus: function (event, ui) {
        $('.autocomplete-item').removeClass('scale-[1.01]')
        $(event.target).closest('.autocomplete-item').addClass('scale-[1.01]')
        return false
      },
      open: function () {
        const $menu = $(this).autocomplete('widget')
        $menu.css('opacity', 0)
          .animate({ opacity: 1 }, 150)
      },
      close: function () {
        const $menu = $(this).autocomplete('widget')
        $menu.animate({ opacity: 0 }, 100)
      }
    }).autocomplete('instance')._renderMenu = function (ul, items) {
      const that = this

      items.forEach(item => {
        that._renderItemData(ul, item)
      })
    }

    this.$input.autocomplete('instance')._renderItem = function (ul, item) {
      return $('<li>')
        .addClass('autocomplete-item ui-menu-item')
        .attr('data-value', item.value)
        .append(`
        <div class="autocomplete-item-content">
          <span class="autocomplete-item-name">
            <i class="fas fa-terminal text-xs opacity-70"></i>
            ${item.value}
          </span>
          <span class="autocomplete-item-description">${item.description}</span>
          <div class="autocomplete-shortcut">
            Press <kbd>Tab</kbd> to complete, <kbd>Enter</kbd> to execute
          </div>
        </div>
      `)
        .appendTo(ul)
    }
  }

  /**
   * Refreshes the autocomplete source.
   * @public
   */
  refreshAutoComplete () {
    this.activateAutoComplete()
  }

  /**
   * Displays a new console message.
   * @param message
   * @public
   */
  consoleMessage ({ message, type = 'success', withStatus = true, time = true, isPacket = false, isIncoming = false, details = null, style = '' } = {}) {
    const baseTypeClasses = {
      success: 'bg-highlight-green/10 border-l-4 border-highlight-green text-highlight-green',
      error: 'bg-error-red/10 border-l-4 border-error-red text-error-red',
      wait: 'bg-tertiary-bg/30 border-l-4 border-tertiary-bg text-gray-300',
      celebrate: 'bg-purple-500/10 border-l-4 border-purple-500 text-purple-400',
      warn: 'bg-highlight-yellow/10 border-l-4 border-highlight-yellow text-highlight-yellow',
      notify: 'bg-blue-500/10 border-l-4 border-blue-500 text-blue-400',
      welcome: 'bg-red-600/10 border-l-4 border-red-500 text-white',
      speech: 'bg-primary-bg/10 border-l-4 border-primary-bg text-text-primary',
      logger: 'bg-gray-700/30 border-l-4 border-gray-600 text-gray-300',
      action: 'bg-teal-500/10 border-l-4 border-teal-500 text-teal-400'
    }

    const packetTypeClasses = {
      incoming: 'bg-tertiary-bg/20 border-l-4 border-highlight-green text-text-primary',
      outgoing: 'bg-highlight-green/5 border-l-4 border-highlight-yellow text-text-primary'
    }

    const createElement = (tag, classes = '', content = '') => {
      return $('<' + tag + '>').addClass(classes + ' message-animate-in').html(content)
    }

    const getTime = () => {
      const now = new Date()
      const hour = String(now.getHours()).padStart(2, '0')
      const minute = String(now.getMinutes()).padStart(2, '0')
      const second = String(now.getSeconds()).padStart(2, '0')
      return `${hour}:${minute}:${second}`
    }

    const status = (type, message) => {
      const icon = messageIcons[type]
      if (!icon) throw new Error('Invalid Status Type.')
      return `
        <div class="flex items-center space-x-2 w-full">
          <div class="flex">
            <i class="fas ${icon} mr-2"></i>
          </div>
          <span>${message || ''}</span>
        </div>
      `
    }

    const $container = createElement(
      'div',
      'flex items-start p-3 rounded-md mb-2 shadow-sm max-w-full w-full transition-colors duration-150 hover:bg-opacity-20'
    )

    if (isPacket) {
      $container.addClass(packetTypeClasses[isIncoming ? 'incoming' : 'outgoing'])
    } else {
      $container.addClass(baseTypeClasses[type] || 'bg-tertiary-bg/10 border-l-4 border-tertiary-bg text-text-primary')
    }

    if (isPacket) {
      const iconClass = isIncoming ? 'fa-arrow-down text-highlight-green' : 'fa-arrow-up text-highlight-yellow'
      const $iconContainer = createElement('div', 'flex items-center mr-3 text-base', `<i class="fas ${iconClass}"></i>`)
      $container.append($iconContainer)
    } else if (time) {
      const $timeContainer = createElement('div', 'text-xs text-gray-500 mr-3 whitespace-nowrap font-mono', getTime())
      $container.append($timeContainer)
    }

    const $messageContainer = createElement(
      'div',
      isPacket
        ? 'text-xs flex-1 break-all leading-relaxed'
        : 'flex-1 text-xs flex items-center space-x-2 leading-relaxed'
    )

    if (withStatus && !isPacket) {
      $messageContainer.html(status(type, message))
    } else {
      $messageContainer.text(message)
      if (isPacket) {
        $messageContainer.addClass('font-mono')
      }
    }

    // Apply custom styling if provided
    if (style) {
      $messageContainer.attr('style', style);
    }

    $messageContainer.css({
      overflow: 'hidden',
      'text-overflow': 'ellipsis',
      'white-space': 'normal',
      'word-break': 'break-word'
    })

    $container.append($messageContainer)
    
    // Add data-message-id if provided in details
    if (details && details.messageId) {
      $container.attr('data-message-id', details.messageId);
    }

    if (isPacket && details) {
      const $actionsContainer = createElement('div', 'flex ml-2 items-center')

      const $detailsButton = createElement(
        'button',
        'text-xs text-gray-400 hover:text-text-primary transition-colors px-2 py-1 rounded hover:bg-tertiary-bg/20',
        '<i class="fas fa-code mr-1"></i> Details'
      )

      const $copyButton = createElement(
        'button',
        'text-xs text-gray-400 hover:text-text-primary transition-colors ml-1 px-2 py-1 rounded hover:bg-tertiary-bg/20',
        '<i class="fas fa-copy mr-1"></i> Copy'
      )

      $copyButton.on('click', (e) => {
        e.stopPropagation()
        navigator.clipboard.writeText(message)

        const originalHtml = $copyButton.html()
        $copyButton.html('<i class="fas fa-check mr-1"></i> Copied!')
        $copyButton.addClass('text-highlight-green')

        setTimeout(() => {
          $copyButton.html(originalHtml)
          $copyButton.removeClass('text-highlight-green')
        }, 1500)
      })

      $actionsContainer.append($detailsButton, $copyButton)
      $container.append($actionsContainer)

      const $detailsContainer = createElement(
        'div',
        'bg-tertiary-bg/50 rounded-md p-3 mt-2 hidden w-full',
        `<pre class="text-xs text-text-primary overflow-auto max-h-[300px] font-mono">${JSON.stringify(details, null, 2)}</pre>`
      )

      $detailsButton.on('click', (e) => {
        e.stopPropagation()
        $detailsContainer.toggleClass('hidden')
        const isHidden = $detailsContainer.hasClass('hidden')
        $detailsButton.html(
          isHidden
            ? '<i class="fas fa-code mr-1"></i> Details'
            : '<i class="fas fa-chevron-up mr-1"></i> Hide'
        )
      })

      $container.after($detailsContainer)

      $container.css('cursor', 'pointer')
      $container.on('click', function (e) {
        if (!$(e.target).closest('button').length) {
          $detailsButton.click()
        }
      })
    }

    // Determine the target container based on message type
    const $targetContainer = isPacket ? $('#message-log') : $('#messages');
    
    // Update counters for packet logs
    if (isPacket) {
      const $totalCount = $('#totalCount');
      const $incomingCount = $('#incomingCount');
      const $outgoingCount = $('#outgoingCount');

      const totalCount = parseInt($totalCount.text() || '0', 10) + 1;
      $totalCount.text(totalCount);

      if (isIncoming) {
        const incomingCount = parseInt($incomingCount.text() || '0', 10) + 1;
        $incomingCount.text(incomingCount);
      } else {
        const outgoingCount = parseInt($outgoingCount.text() || '0', 10) + 1;
        $outgoingCount.text(outgoingCount);
      }
      
      // Increment packet log count and check if cleaning is needed
      this._packetLogCount++;
      // Use network log limit instead of general max log entries
      if (this._packetLogCount > this._networkLogLimit) {
        this._cleanOldLogs($targetContainer, true);
      }
    } else {
      // Increment app message count and check if cleaning is needed
      this._appMessageCount++;
      // Use console log limit instead of general max log entries
      if (this._appMessageCount > this._consoleLogLimit) {
        this._cleanOldLogs($targetContainer, false);
      }
    }

    // Append the container to the appropriate target
    $targetContainer.append($container);

    // Auto-scroll logic
    const isAtBottom = $targetContainer.scrollTop() + $targetContainer.innerHeight() >= $targetContainer[0].scrollHeight - 30;
    if (isAtBottom) {
      $targetContainer.scrollTop($targetContainer[0].scrollHeight);
    }


    if (window.applyFilter) window.applyFilter()
  } // End of consoleMessage method

  /**
   * Cleans old log entries from the specified container.
   * @param {JQuery<HTMLElement>} $logContainer - The jQuery object for the log container.
   * @param {boolean} isPacketLog - Whether the container is for packet logs.
   * @private
   */
  _cleanOldLogs($logContainer, isPacketLog) {
    // Use the appropriate log limit based on log type
    const maxEntries = isPacketLog ? this._networkLogLimit : this._consoleLogLimit;
    
    const entriesToRemove = Math.floor(maxEntries * this._cleanPercentage);
    const $entries = $logContainer.children('div'); // Assuming logs are direct div children
    const currentTotal = $entries.length;

    if (currentTotal <= maxEntries) {
      return; // No need to clean yet
    }

    const numberToRemove = Math.min(entriesToRemove, currentTotal - (maxEntries * (1 - this._cleanPercentage))); // Ensure we don't remove too many
    const logsToRemove = $entries.slice(0, numberToRemove);

    let removedIncoming = 0;
    let removedOutgoing = 0;

    if (isPacketLog) {
      // Count incoming/outgoing packets being removed
      logsToRemove.each(function() {
        if ($(this).hasClass('bg-tertiary-bg/20')) { // Incoming class check
          removedIncoming++;
        } else if ($(this).hasClass('bg-highlight-green/5')) { // Outgoing class check
          removedOutgoing++;
        }
      });
    }

    logsToRemove.remove();

    const newCount = $logContainer.children('div').length;

    // Update counters and internal state
    if (isPacketLog) {
      this._packetLogCount = newCount;

      const $totalCount = $('#totalCount');
      const $incomingCount = $('#incomingCount');
      const $outgoingCount = $('#outgoingCount');

      const currentTotalCount = parseInt($totalCount.text() || '0', 10);
      const currentIncomingCount = parseInt($incomingCount.text() || '0', 10);
      const currentOutgoingCount = parseInt($outgoingCount.text() || '0', 10);

      $totalCount.text(Math.max(0, currentTotalCount - numberToRemove));
      $incomingCount.text(Math.max(0, currentIncomingCount - removedIncoming));
      $outgoingCount.text(Math.max(0, currentOutgoingCount - removedOutgoing));

    } else {
      this._appMessageCount = newCount;
    }

    // Developer log about the cleaning (kept)
    devLog(`Cleaned ${numberToRemove} old log entries from ${isPacketLog ? 'packet log' : 'app messages'}. New count: ${newCount}`);
  }

  /**
   * Loads log limit settings from user settings.
   * @private
   * @returns {Promise<void>}
   */
  async _loadLogLimitSettings() {
    try {
      // Get log limit settings with fallbacks
      let consoleLogLimit, networkLogLimit;
      
      try {
        // Direct IPC call to bypass the Settings class inconsistency
        consoleLogLimit = await ipcRenderer.invoke('get-setting', 'logs.consoleLimit');
        networkLogLimit = await ipcRenderer.invoke('get-setting', 'logs.networkLimit');
      } catch (error) {
        console.error('Error with direct IPC call:', error);
        // Fallback to settings class
        consoleLogLimit = this.settings.get('logs.consoleLimit');
        networkLogLimit = this.settings.get('logs.networkLimit');
      }

      // Debug the raw values
      
      // Apply settings with bounds checking - ensure numeric parsing
      this._consoleLogLimit = consoleLogLimit !== undefined && consoleLogLimit !== null 
        ? Math.max(100, Math.min(10000, parseInt(consoleLogLimit) || 1000))
        : 1000;
      
      this._networkLogLimit = networkLogLimit !== undefined && networkLogLimit !== null
        ? Math.max(100, Math.min(10000, parseInt(networkLogLimit) || 1000))
        : 1000;
      
      // For backward compatibility
      this._maxLogEntries = Math.max(this._consoleLogLimit, this._networkLogLimit);
      
      devLog(`Log limits set - Console: ${this._consoleLogLimit}, Network: ${this._networkLogLimit}`);
    } catch (error) {
      devError('Error loading log limit settings:', error);
      // Use defaults if there's an error
      this._consoleLogLimit = 1000;
      this._networkLogLimit = 1000;
      this._maxLogEntries = 1000;
    }
  }

  /**
   * Clears all console log messages for a fresh start.
   * Used primarily after initial startup messages are shown.
   * @private
   */
  _clearConsoleMessages() {
    const $messages = $('#messages');
    $messages.empty();
    this._appMessageCount = 0;
  }
  
  /**
   * Removes all messages with a specific ID.
   * @param {string} messageId - The ID of the message(s) to remove.
   * @private
   */
  _removeMessageById(messageId) {
    if (!messageId) return;
    
    // Use querySelectorAll to get ALL elements with this ID
    const messageElements = document.querySelectorAll(`[data-message-id='${messageId}']`);
    
    if (messageElements && messageElements.length > 0) {
      // Log how many elements we're removing for debugging
      devLog(`[Renderer] Removing ${messageElements.length} messages with ID: ${messageId}`);
      
      // Remove each matching element
      messageElements.forEach(element => {
        $(element).fadeOut(200, function() {
          $(this).remove();
        });
      });
    }
  }

  /**
   * Opens Animal Jam Classic, disabling the button during patching.
   * @returns {Promise<void>}
   * @public
   */
  async openAnimalJam () {
    if (!this.$playButton) {
      console.error("Play button element not found!");
      this.$playButton = document.getElementById('playButton'); // Try to get it again
      if (!this.$playButton) return; // Still not found, exit
    }

    // Disable button and apply styles
    this.$playButton.classList.add('opacity-50', 'pointer-events-none');
    this.$playButton.onclick = () => false; // Prevent further clicks via onclick
    
    // Unique ID for the status message
    const startMessageId = `start-aj-${Date.now()}`;
    let launchSuccessful = false;

    try {
      // Log starting message with a unique ID
      this.consoleMessage({ 
        message: 'Starting Animal Jam Classic...', 
        type: 'wait',
        details: { messageId: startMessageId } // Pass ID
      });
      
      await this.patcher.killProcessAndPatch(); // Await the patching process
      
      launchSuccessful = true; // Assume success if killProcessAndPatch completes without error
      
    } catch (error) {
      this.consoleMessage({
        message: `Error launching Animal Jam Classic: ${error.message}`,
        type: 'error'
      });
    } finally {
      // Remove the "Starting..." message ONLY if launch was successful
      if (launchSuccessful) {
        const startingMessageElement = document.querySelector(`[data-message-id='${startMessageId}']`);
        if (startingMessageElement) {
          // Add a short delay before removing the starting message
          await new Promise(resolve => setTimeout(resolve, 1000)); // 1 second delay
          $(startingMessageElement).remove(); // Use jQuery remove for potential effects
        }
        // Log success message HERE, after removing the starting message
        this.consoleMessage({
          message: 'Successfully launched Animal Jam Classic!',
          type: 'success'
        });
      }
      
      // Re-enable button and remove styles regardless of success/failure
      if (this.$playButton) {
        this.$playButton.classList.remove('opacity-50', 'pointer-events-none');
        // Restore original onclick behavior
        this.$playButton.onclick = () => jam.application.openAnimalJam();
      }
    }
  }

  /**
   * Renders the plugin items within the list.
   * @param {object} plugin - The plugin details
   * @param {string} plugin.name - The name of the plugin.
   * @param {string} plugin.type - The type of the plugin ('game' or 'ui').
   * @param {string} plugin.description - The description of the plugin.
   * @param {string} [plugin.author='Sxip'] - The author of the plugin.
   * @public
   */
  renderPluginItems ({ name, type, description, author = 'Sxip' } = {}) {
    // Determine status indicator color based on plugin type
    // TODO: Enhance this later to check live activity status for UI plugins if possible
    let statusColorClass = 'bg-red-500'; // Default to inactive/red
    if (type === 'game') {
      statusColorClass = 'bg-yellow-500'; // Game plugins are yellow
    }
    // Future enhancement: Check if type === 'ui' and if its window is open/active -> bg-green-500

    // Generate the new simplified list item HTML (WITHOUT onclick attribute on the info icon)
    const $plugin = $(`
      <li class="flex items-center justify-between text-sidebar-text hover:bg-tertiary-bg px-3 py-2 rounded-md transition-all group plugin-list-item" data-plugin-name="${name}" data-plugin-type="${type}">
        <div class="flex items-center flex-grow min-w-0"> <!-- Added flex-grow and min-w-0 for truncation -->
          <span class="inline-block w-2 h-2 ${statusColorClass} rounded-full mr-2 flex-shrink-0 plugin-status-indicator"></span>
          <span class="font-medium text-sm truncate mr-2">${name}</span> <!-- Added truncate -->
        </div>
        <a href="#" 
           class="plugin-info-button text-gray-400 hover:text-theme-primary transition-colors opacity-0 group-hover:opacity-100 ml-auto pl-2 flex-shrink-0" 
           aria-label="Plugin Info">
          <i class="fas fa-info-circle"></i>
        </a>
      </li>
    `);

    // Attach click handler for the info button programmatically
    $plugin.find('.plugin-info-button').on('click', (e) => {
      e.preventDefault(); // Prevent default anchor action
      e.stopPropagation(); // Prevent triggering potential parent click handlers (for UI plugins)
      // Call _showPluginInfo with the original, unescaped data
      this._showPluginInfo(name, type, description, author);
    });

    // Add click handler to the entire list item if it's a UI plugin
    if (type === 'ui') {
      $plugin.addClass('cursor-pointer'); // Add pointer cursor for UI plugins
      $plugin.on('click', (e) => {
        // Check if the click target is NOT the info button or its icon
        if (!$(e.target).closest('.plugin-info-button').length) {
          this.dispatch.open(name);
        }
      });
    }

    // Return the created element instead of appending directly
    // Appending will be handled after sorting
    return $plugin; 
    // this.$pluginList.append($plugin);
    // this._updateEmptyPluginMessage(); // This will be called after appending all items
  }

  /**
   * Shows the plugin info modal.
   * @param {string} name - Plugin name
   * @param {string} type - Plugin type
   * @param {string} description - Plugin description
   * @param {string} author - Plugin author
   * @private
   */
  _showPluginInfo(name, type, description, author) {
    // Get plugin commands and other metadata if available
    const pluginMetadata = this.dispatch.plugins.get(name);
    let commands = [];
    let version = '';
    let filepath = '';
    let tags = [];
    
    if (pluginMetadata) {
      if (pluginMetadata.configuration) {
        version = pluginMetadata.configuration.version || '';
        commands = pluginMetadata.configuration.commands || [];
        tags = pluginMetadata.configuration.tags || [];
      }
      filepath = pluginMetadata.filepath || '';
    }
    
    // Create modal container
    const $modal = $('<div>', {
      class: 'fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-70 backdrop-blur-sm',
      id: 'pluginInfoModal'
    });
    
    // Create the modal content with kid-friendly styling - removed white border
    const $content = $('<div>', {
      class: 'bg-primary-bg rounded-xl shadow-2xl max-w-lg w-full mx-4 overflow-hidden transform transition-all duration-200 scale-100 hover:scale-[1.01]'
    });
    
    // Modal header with fun styling
    const $header = $('<div>', {
      class: 'px-6 py-4 bg-gradient-to-r from-highlight-blue/20 to-highlight-blue/5 border-b border-highlight-blue/50 flex items-center justify-between'
    });
    
    // Title with bouncy animation on hover - Now uses the actual name
    const $title = $('<h3>', {
      class: 'text-lg font-bold text-highlight-blue flex items-center transition-transform duration-200',
      // Use the actual name passed as argument
      html: `<i class="fas ${type === 'ui' ? 'fa-window-restore' : 'fa-code'} mr-2 transform transition-all duration-300"></i> ${name}` 
    });
    
    // Add bounce effect on hover
    $title.hover(
      function() {
        $(this).find('i').addClass('animate-bounce');
      },
      function() {
        $(this).find('i').removeClass('animate-bounce');
      }
    );
    
    // Close button with pulse effect
    const $closeButton = $('<button>', {
      class: 'text-gray-400 hover:text-highlight-red transition-colors duration-200 transform hover:scale-110 rounded-full p-1 hover:bg-highlight-red/10',
      'aria-label': 'Close'
    }).append(
      $('<i>', { class: 'fas fa-times' })
    ).on('click', () => {
      // Fade out animation
      $modal.css({
        'opacity': '0',
        'transform': 'scale(0.95)',
        'transition': 'opacity 0.2s ease-in-out, transform 0.2s ease-in-out'
      });
      
      setTimeout(() => $modal.remove(), 200);
    });
    
    $header.append($title, $closeButton);
    
    // Modal body with colorful sections for kids
    const $body = $('<div>', {
      class: 'px-6 py-5 max-h-[65vh] overflow-y-auto custom-scrollbar'
    });
    
    // Version and tags display if available
    if (version || (tags && tags.length > 0)) {
      const $versionTagsContainer = $('<div>', {
        class: 'flex flex-wrap items-center gap-2 mb-4'
      });
      
      if (version) {
        $versionTagsContainer.append(
          $('<span>', {
            class: 'px-2 py-1 text-xs font-semibold rounded-full bg-tertiary-bg text-text-secondary',
            text: `v${version}`
          })
        );
      }
      
      if (tags && tags.length > 0) {
        tags.forEach(tag => {
          let tagColorClass = '';
          switch(tag.toLowerCase()) {
            case 'beta':
              tagColorClass = 'bg-highlight-yellow/20 text-highlight-yellow';
              break;
            case 'new':
              tagColorClass = 'bg-highlight-green/20 text-highlight-green';
              break;
            case 'networking':
              tagColorClass = 'bg-highlight-blue/20 text-highlight-blue';
              break;
            case 'account':
              tagColorClass = 'bg-highlight-purple/20 text-highlight-purple';
              break;
            default:
              tagColorClass = 'bg-gray-600/20 text-gray-400';
          }
          
          $versionTagsContainer.append(
            $('<span>', {
              class: `px-2 py-1 text-xs font-semibold rounded-full ${tagColorClass}`,
              text: tag
            })
          );
        });
      }
      
      $body.append($versionTagsContainer);
    }
    
    // What is this plugin? - with hover effects
    const $whatIsSection = $('<div>', {
      class: 'mb-5 bg-highlight-green/10 p-4 rounded-lg border border-highlight-green/30 transform transition-all duration-200 hover:border-highlight-green/60 hover:bg-highlight-green/15 hover:shadow-md'
    });
    
    $whatIsSection.append(
      $('<h4>', {
        class: 'text-highlight-green text-base font-bold mb-2 flex items-center',
        html: '<i class="fas fa-puzzle-piece mr-2"></i> What is this plugin?'
      }),
      $('<p>', {
        class: 'text-text-primary text-sm leading-relaxed',
        text: description || `A ${type} plugin for Animal Jam`
      })
    );
    
    $body.append($whatIsSection);
    
    // Who made it? - with hover effects
    const $whoMadeSection = $('<div>', {
      class: 'mb-5 bg-highlight-yellow/10 p-4 rounded-lg border border-highlight-yellow/30 transform transition-all duration-200 hover:border-highlight-yellow/60 hover:bg-highlight-yellow/15 hover:shadow-md'
    });
    
    $whoMadeSection.append(
      $('<h4>', {
        class: 'text-highlight-yellow text-base font-bold mb-2 flex items-center',
        html: '<i class="fas fa-user-edit mr-2"></i> Who made it?'
      }),
      $('<p>', {
        class: 'text-text-primary text-sm leading-relaxed flex items-center',
        html: `<i class="fas fa-user mr-2"></i> ${author}${version ? ` <span class="ml-2 text-gray-400">(v${version})</span>` : ''}`
      })
    );
    
    $body.append($whoMadeSection);
    
    // How do I use it? - detailed instructions based on plugin type
    const $howToSection = $('<div>', {
      class: 'mb-5 bg-highlight-blue/10 p-4 rounded-lg border border-highlight-blue/30 transform transition-all duration-200 hover:border-highlight-blue/60 hover:bg-highlight-blue/15 hover:shadow-md'
    });
    
    $howToSection.append(
      $('<h4>', {
        class: 'text-highlight-blue text-base font-bold mb-2 flex items-center',
        html: '<i class="fas fa-lightbulb mr-2"></i> How do I use it?'
      })
    );
    
    // Customize the instructions based on plugin name
    let howToUseHtml = '';
    
    if (type === 'ui') {
      // Basic instructions for UI plugins
      howToUseHtml = `
        <p class="text-text-primary text-sm leading-relaxed mb-3">
          Click on the plugin in the sidebar to open it! <i class="fas fa-mouse-pointer text-xs"></i>
        </p>
      `;
      
      // Add specific instructions based on plugin name
      if (name.toLowerCase().includes('packet') && name.toLowerCase().includes('spam')) {
        howToUseHtml += `
          <div class="space-y-3 mt-3">
            <div class="bg-secondary-bg/30 p-3 rounded-lg">
              <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
                <i class="fas fa-bolt mr-2"></i> What is Packet Spammer?
              </p>
              <p class="text-text-primary text-sm leading-relaxed">
                Think of packets as little messages your game sends to and from Animal Jam's servers.
                This tool lets you send these messages repeatedly to do certain actions in the game.
              </p>
            </div>
            
            <div class="bg-secondary-bg/30 p-3 rounded-lg">
              <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
                <i class="fas fa-gamepad mr-2"></i> Using the buttons:
              </p>
              <ul class="text-text-primary text-sm space-y-2 list-disc pl-5">
                <li>
                  <span class="text-highlight-blue font-medium">Packet Type:</span> 
                  Choose whether to send the packet to the game (client) or to Animal Jam's servers
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Packet Content:</span>
                  Type or paste the packet message you want to send
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Delay (ms):</span>
                  How long to wait between sending each packet (in milliseconds)
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Count:</span>
                  How many packets to send (leave empty to send continuously)
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Start button:</span>
                  Begin sending the packets
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Stop button:</span>
                  Stop sending packets
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Save/Load buttons:</span>
                  Save your favorite packet setups to use them again later
                </li>
              </ul>
            </div>
            
            <div class="bg-highlight-yellow/10 p-3 rounded-lg">
              <p class="text-highlight-yellow text-sm font-medium flex items-center mb-1">
                <i class="fas fa-exclamation-triangle mr-2"></i> Friendly reminder:
              </p>
              <p class="text-text-primary text-sm leading-relaxed">
                Be careful with this tool! Sending too many packets too quickly can cause lag or get you disconnected.
              </p>
            </div>
          </div>
        `;
      } else if (name.toLowerCase().includes('login')) {
        howToUseHtml += `
          <div class="space-y-3 mt-3">
            <div class="bg-secondary-bg/30 p-3 rounded-lg">
              <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
                <i class="fas fa-key mr-2"></i> What does this plugin do?
              </p>
              <p class="text-text-primary text-sm leading-relaxed">
                This plugin lets you see and change the information sent between your game and Animal Jam's servers when you log in.
              </p>
            </div>
            
            <div class="bg-secondary-bg/30 p-3 rounded-lg">
              <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
                <i class="fas fa-gamepad mr-2"></i> Using the features:
              </p>
              <ul class="text-text-primary text-sm space-y-2 list-disc pl-5">
                <li>
                  <span class="text-highlight-blue font-medium">View Login Packet:</span> 
                  See all the information that gets sent when you log in
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Edit Fields:</span>
                  Change values in the editor (for advanced users)
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Packet Editor:</span>
                  The large text box shows the login information in a format called JSON
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Save/Load:</span>
                  Save your changes for later or load previously saved settings
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Apply Changes:</span>
                  Use your modifications the next time you log in
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Reset:</span>
                  Go back to the original settings if something goes wrong
                </li>
              </ul>
            </div>
            
            <div class="bg-highlight-yellow/10 p-3 rounded-lg">
              <p class="text-highlight-yellow text-sm font-medium flex items-center mb-1">
                <i class="fas fa-exclamation-triangle mr-2"></i> Friendly reminder:
              </p>
              <p class="text-text-primary text-sm leading-relaxed">
                This is an advanced tool. If you're not sure what you're doing, just look but don't change anything!
              </p>
            </div>
          </div>
        `;
      } else if (name.toLowerCase().includes('advertis')) {
        howToUseHtml += `
          <div class="space-y-3 mt-3">
            <div class="bg-secondary-bg/30 p-3 rounded-lg">
              <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
                <i class="fas fa-bullhorn mr-2"></i> What does this plugin do?
              </p>
              <p class="text-text-primary text-sm leading-relaxed">
                This plugin helps you automatically send messages in the game at regular intervals - perfect for advertising your den, items for trade, or just saying hello!
              </p>
            </div>
            
            <div class="bg-secondary-bg/30 p-3 rounded-lg">
              <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
                <i class="fas fa-gamepad mr-2"></i> Step-by-step guide:
              </p>
              <ol class="text-text-primary text-sm space-y-2 list-decimal pl-5">
                <li>
                  <span class="text-highlight-blue font-medium">Add messages:</span> 
                  Click the "Add Message" button and type your message in the box
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Set interval:</span>
                  Enter how many seconds to wait between messages (60 seconds is a good start)
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Choose order:</span>
                  Pick "Sequential" to send messages in order or "Random" to mix them up
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Start advertising:</span>
                  Click the "Start" button to begin sending your messages
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Stop anytime:</span>
                  Click "Stop" when you want to pause the messages
                </li>
              </ol>
            </div>
            
            <div class="bg-secondary-bg/30 p-3 rounded-lg">
              <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
                <i class="fas fa-save mr-2"></i> Save your setup:
              </p>
              <p class="text-text-primary text-sm leading-relaxed">
                Once you've created the perfect set of messages:
              </p>
              <ul class="text-text-primary text-sm space-y-1 list-disc pl-5">
                <li>Click "Save" to save your configuration</li>
                <li>Use "Load" to bring back your saved messages later</li>
              </ul>
            </div>
            
            <div class="bg-highlight-yellow/10 p-3 rounded-lg">
              <p class="text-highlight-yellow text-sm font-medium flex items-center mb-1">
                <i class="fas fa-exclamation-triangle mr-2"></i> Friendly reminder:
              </p>
              <p class="text-text-primary text-sm leading-relaxed">
                Don't set the interval too short or spam the same message - that could get you in trouble!
              </p>
            </div>
          </div>
        `;
      } else if (name.toLowerCase().includes('logger')) {
        howToUseHtml += `
          <div class="space-y-3 mt-3">
            <div class="bg-secondary-bg/30 p-3 rounded-lg">
              <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
                <i class="fas fa-users mr-2"></i> What does this plugin do?
              </p>
              <p class="text-text-primary text-sm leading-relaxed">
                This plugin automatically collects usernames of jammers you see in the game and saves them in a file.
              </p>
            </div>
            
            <div class="bg-secondary-bg/30 p-3 rounded-lg">
              <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
                <i class="fas fa-gamepad mr-2"></i> How to use it:
              </p>
              <ul class="text-text-primary text-sm space-y-2 list-disc pl-5">
                <li>
                  <span class="text-highlight-blue font-medium">Turn on/off:</span> 
                  Type <span class="font-mono bg-tertiary-bg px-1 rounded">userlog on</span> or <span class="font-mono bg-tertiary-bg px-1 rounded">userlog off</span> in the command line
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Check status:</span>
                  Type <span class="font-mono bg-tertiary-bg px-1 rounded">userlog status</span> to see if it's running
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Find saved usernames:</span>
                  Username logs are saved in your data folder
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Change settings:</span>
                  Type <span class="font-mono bg-tertiary-bg px-1 rounded">userlogsettings</span> to customize how it works
                </li>
              </ul>
            </div>
            
            <div class="bg-highlight-yellow/10 p-3 rounded-lg">
              <p class="text-highlight-yellow text-sm font-medium flex items-center mb-1">
                <i class="fas fa-exclamation-triangle mr-2"></i> Friendly reminder:
              </p>
              <p class="text-text-primary text-sm leading-relaxed">
                Be respectful of other jammers' privacy and only use collected usernames for positive purposes!
              </p>
            </div>
          </div>
        `;
      } else {
        howToUseHtml += `
          <div class="space-y-3 mt-3">
            <div class="bg-secondary-bg/30 p-3 rounded-lg">
              <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
                <i class="fas fa-gamepad mr-2"></i> Step-by-step guide:
              </p>
              <ol class="text-text-primary text-sm space-y-2 list-decimal pl-5">
                <li>
                  <span class="text-highlight-blue font-medium">Open the plugin:</span> 
                  Click on this plugin in the sidebar
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Explore the options:</span>
                  Look through all the buttons and controls
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Try things out:</span>
                  Don't be afraid to experiment with different settings
                </li>
                <li>
                  <span class="text-highlight-blue font-medium">Have fun:</span>
                  See how this plugin enhances your Animal Jam experience!
                </li>
              </ol>
            </div>
            
            <div class="bg-secondary-bg/30 p-3 rounded-lg">
              <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
                <i class="fas fa-lightbulb mr-2"></i> Common actions:
              </p>
              <p class="text-text-primary text-sm leading-relaxed">
                <span class="inline-block bg-tertiary-bg text-highlight-blue px-2 py-1 rounded-md mb-1">
                  <i class="fas fa-mouse-pointer mr-1"></i> Button clicks
                </span> 
                Most plugins have buttons you can click to activate features
              </p>
              <p class="text-text-primary text-sm leading-relaxed">
                <span class="inline-block bg-tertiary-bg text-highlight-blue px-2 py-1 rounded-md mb-1">
                  <i class="fas fa-cog mr-1"></i> Settings
                </span>
                Look for settings or gear icons to customize how things work
              </p>
            </div>
            
            <div class="bg-highlight-yellow/10 p-3 rounded-lg">
              <p class="text-highlight-yellow text-sm font-medium flex items-center mb-1">
                <i class="fas fa-exclamation-triangle mr-2"></i> Need help?
              </p>
              <p class="text-text-primary text-sm leading-relaxed">
                If you're not sure how to use this plugin, ask in our Discord server!
              </p>
            </div>
          </div>
        `;
      }
    } else {
      // Game plugin instructions
      howToUseHtml = `
        <div class="space-y-3">
          <p class="text-text-primary text-sm leading-relaxed">
            Game plugins run automatically when you play Animal Jam! You can use commands to control them.
          </p>
          
          <div class="bg-secondary-bg/30 p-3 rounded-lg">
            <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
              <i class="fas fa-gamepad mr-2"></i> How to use this plugin:
            </p>
            <ol class="text-text-primary text-sm space-y-2 list-decimal pl-5">
              <li>
                <span class="text-highlight-blue font-medium">It's already working!</span> 
                Game plugins like this one run in the background while you play
              </li>
              <li>
                <span class="text-highlight-blue font-medium">Use commands:</span>
                Type commands in the command box at the bottom of this window
              </li>
              <li>
                <span class="text-highlight-blue font-medium">Check the commands:</span>
                Look at the "Commands you can use" section below
              </li>
            </ol>
          </div>
          
          <div class="bg-highlight-yellow/10 p-3 rounded-lg">
            <p class="text-highlight-yellow text-sm font-medium flex items-center mb-1">
              <i class="fas fa-exclamation-triangle mr-2"></i> Need help?
            </p>
            <p class="text-text-primary text-sm leading-relaxed">
              If you're not sure how to use this plugin, ask in our Discord server!
            </p>
          </div>
        </div>
      `;
    }
    
    $howToSection.append(howToUseHtml);
    $body.append($howToSection);
    
    // Special handling for InvisibleToggle plugin
    if (name === 'InvisibleToggle') {
      // Add commands section for InvisibleToggle
      const $invisibleCommandsSection = $('<div>', {
        class: 'mb-5 bg-highlight-purple/10 p-4 rounded-lg border border-highlight-purple/30 transform transition-all duration-200 hover:border-highlight-purple/60 hover:bg-highlight-purple/15 hover:shadow-md'
      });
      
      $invisibleCommandsSection.append(
        $('<h4>', {
          class: 'text-highlight-purple text-base font-bold mb-3 flex items-center',
          html: '<i class="fas fa-terminal mr-2"></i> Commands you can use:'
        })
      );
      
      const $commandsList = $('<ul>', {
        class: 'space-y-3'
      });
      
      const $cmdItem = $('<li>', {
        class: 'text-text-primary text-sm bg-secondary-bg/50 p-3 rounded-lg border border-sidebar-border/30 transform transition-all duration-200 hover:border-highlight-purple/30 hover:bg-secondary-bg'
      });
      
      const $cmdName = $('<div>', {
        class: 'font-mono bg-highlight-purple/20 px-2 py-1 rounded text-highlight-purple inline-block mb-1.5',
        text: 'invis'
      });
      
      const $cmdDesc = $('<div>', {
        class: 'text-text-primary leading-relaxed',
        text: 'Toggle invisibility ON/OFF. Use this command to hide your character from other players.'
      });
      
      $cmdItem.append($cmdName, $cmdDesc);
      $commandsList.append($cmdItem);
      
      // How to access advanced section
      const $advancedSection = $('<div>', {
        class: 'mt-3 bg-secondary-bg/30 p-3 rounded-lg'
      });
      
      $advancedSection.append(
        $('<p>', {
          class: 'text-text-primary text-sm font-medium mb-2 flex items-center',
          html: '<i class="fas fa-info-circle mr-2"></i> How to use this command:'
        }),
        $('<p>', {
          class: 'text-text-primary text-sm leading-relaxed',
          html: `Type <span class="font-mono bg-tertiary-bg px-1 rounded text-highlight-purple">!invis</span> in the command box at the bottom of Jam to toggle invisibility on or off.`
        })
      );
      
      $commandsList.append($advancedSection);
      $invisibleCommandsSection.append($commandsList);
      $body.append($invisibleCommandsSection);
    }
    
    // Display commands if available with interactive styling
    if (commands && commands.length > 0) {
      const $commandsSection = $('<div>', {
        class: 'mb-5 bg-highlight-purple/10 p-4 rounded-lg border border-highlight-purple/30 transform transition-all duration-200 hover:border-highlight-purple/60 hover:bg-highlight-purple/15 hover:shadow-md'
      });
      
      $commandsSection.append(
        $('<h4>', {
          class: 'text-highlight-purple text-base font-bold mb-3 flex items-center',
          html: '<i class="fas fa-terminal mr-2"></i> Commands you can use:'
        })
      );
      
      const $commandsList = $('<ul>', {
        class: 'space-y-3'
      });
      
      commands.forEach(cmd => {
        const $cmdItem = $('<li>', {
          class: 'text-text-primary text-sm bg-secondary-bg/50 p-3 rounded-lg border border-sidebar-border/30 transform transition-all duration-200 hover:border-highlight-purple/30 hover:bg-secondary-bg'
        });
        
        const $cmdName = $('<div>', {
          class: 'font-mono bg-highlight-purple/20 px-2 py-1 rounded text-highlight-purple inline-block mb-1.5',
          text: cmd.name
        });
        
        const $cmdDesc = $('<div>', {
          class: 'text-text-primary leading-relaxed',
          text: cmd.description || ''
        });
        
        $cmdItem.append($cmdName, $cmdDesc);
        $commandsList.append($cmdItem);
      });
      
      $commandsSection.append($commandsList);
      $body.append($commandsSection);
    }
    
    // Add a fun footer with bouncy button
    const $footer = $('<div>', {
      class: 'px-6 py-4 bg-gradient-to-r from-tertiary-bg to-tertiary-bg/70 border-t border-sidebar-border/50 flex justify-end items-center'
    });
    
    // Add directory button if available
    if (filepath) {
      const $dirButton = $('<button>', {
        class: 'mr-auto bg-tertiary-bg hover:bg-tertiary-bg/80 text-text-secondary hover:text-text-primary px-3 py-1.5 rounded-lg transition-colors text-xs flex items-center',
        html: '<i class="fas fa-folder mr-1.5"></i> Open folder'
      }).on('click', () => {
        this.directory(name);
      });
      
      $footer.append($dirButton);
    }
    
    // Got it button with bounce effect
    const $gotItButton = $('<button>', {
      class: 'bg-highlight-blue hover:bg-highlight-blue/90 text-white px-5 py-2 rounded-lg transition-all duration-200 text-sm font-medium shadow-md hover:shadow-lg transform hover:-translate-y-0.5 active:translate-y-0 active:shadow-sm',
      text: 'Got it!'
    }).on('click', () => {
      // Fade out animation
      $modal.css({
        'opacity': '0',
        'transform': 'scale(0.95)',
        'transition': 'opacity 0.2s ease-in-out, transform 0.2s ease-in-out'
      });
      
      setTimeout(() => $modal.remove(), 200);
    });
    
    $footer.append($gotItButton);
    
    // Assemble and add to DOM
    $content.append($header, $body, $footer);
    $modal.append($content);
    $('body').append($modal);
    
    // Fade in animation
    $modal.css({
      'opacity': '0',
      'transform': 'scale(0.95)'
    });
    
    setTimeout(() => {
      $modal.css({
        'opacity': '1',
        'transform': 'scale(1)',
        'transition': 'opacity 0.3s ease-out, transform 0.3s ease-out'
      });
    }, 10);
  }

  /**
   * Updates the empty plugin message visibility
   * @private
   */
  _updateEmptyPluginMessage() {
    const $emptyPluginMessage = $('#emptyPluginMessage')
    if ($emptyPluginMessage.length > 0) {
      const hasPlugins = this.$pluginList.children().not(function() {
        return this.nodeType === 3 || $(this).text().trim() === ''
      }).length > 0
      
      $emptyPluginMessage.toggleClass('hidden', hasPlugins)
    }
  }

  /**
   * Instantiates the application.
   * @returns {Promise<void>}
   * @public
   */
  async instantiate () {
    // Wait for the data path to be received from the main process
    devLog('[Renderer] Waiting for data path from main process...');
    await this.dataPathPromise;
    devLog(`[Renderer] Data path received: ${this.dataPath}`);
    
    // Initialize Dispatch with the data path and the bound consoleMessage function
    this.dispatch = new Dispatch(
      this,
      this.dataPath,
      this.consoleMessage.bind(this) // Pass bound function
    );
    devLog('[Renderer] Dispatch initialized with data path');
    
    // Register core commands
    registerCoreCommands(this.dispatch, this);
    devLog('[Renderer] Core commands registered');
    
    // Load settings (log only in dev mode)
    await this.settings.load();
    if (isDevelopment) {
      devLog('[Settings] Settings loaded successfully');
    }
    
    // Load log limit settings from user settings
    await this._loadLogLimitSettings();
    if (isDevelopment) {
      devLog('[Settings] Log limit settings loaded');
    }
    
    // Initialize tooltip system
    devLog('[Renderer] Initializing tooltip system...');
    Tooltip.init(this);
    
    // Remove title attributes from elements that will have tooltips
    this._removeTitleAttributes();
    
    devLog('[Renderer] Tooltip system initialized');
    
    // Initial startup message with timestamp-based unique ID
    const startupMessageId = `startup-message-${Date.now()}`;
    this.consoleMessage({
      message: 'Starting Strawberry Jam...',
      type: 'wait',
      details: { messageId: startupMessageId }
    });
    
    // Display the loading plugins message with timestamp-based unique ID
    const loadingPluginsMessageId = `loading-plugins-message-${Date.now()}`;
    this.consoleMessage({
      message: 'Loading plugins...',
      type: 'wait',
      details: { messageId: loadingPluginsMessageId }
    });
    
    // Load plugins with concise messaging
    await this.dispatch.load();
    
    // Log plugin counts in a simpler format
    const pluginCount = this.dispatch.plugins ? this.dispatch.plugins.size : 0;
    this.consoleMessage({
      message: `Successfully loaded ${pluginCount} plugins.`,
      type: 'success'
    });

    // Host change check - only log in development mode
    const secureConnection = this.settings.get('secureConnection')
    if (secureConnection) {
      if (isDevelopment) {
        devLog('[Host] Checking for server host changes...');
      }
      await this._checkForHostChanges()
    }

    // Start the server
    await this.server.serve();
    
    // Remove the initial startup messages
    this._removeMessageById(startupMessageId);
    this._removeMessageById(loadingPluginsMessageId);
    
    // Also remove the initial message set in renderer/index.js if it exists
    if (this.initialStartupMessageId) {
      this._removeMessageById(this.initialStartupMessageId);
      this.initialStartupMessageId = null;
    }
    
    // Show welcome messages
    this.consoleMessage({
      message: 'Server started!',
      type: 'success'
    });
    
    this.consoleMessage({
      message: 'Thanks for choosing strawberry jam, type commands here to use plugins.',
      type: 'welcome'
    });
    
    // this._setupPluginIPC(); // Call moved to constructor
    this.emit('ready')

    // Signal to main process that renderer is ready (for auto-resume logic)
    devLog('[Renderer] Application instantiated, sending renderer-ready signal.');
    ipcRenderer.send('renderer-ready');

    // Set up handlers for the minimize and close buttons
    const minimizeButton = document.getElementById('minimizeButton');
    const mainCloseButton = document.getElementById('mainCloseButton');
    
    if (minimizeButton) {
      minimizeButton.addEventListener('click', () => {
        devLog('[Renderer] Minimize button clicked.');
        this.minimize();
      });
      devLog('[Renderer] Minimize button handler set up.');
    } else {
      devWarn('[Renderer] Minimize button element (#minimizeButton) not found!');
    }

    if (mainCloseButton) {
      mainCloseButton.addEventListener('click', () => {
        devLog('[Renderer] Close button clicked.');
        this.close();
      });
      devLog('[Renderer] Close button handler set up.');
    } else {
      devWarn('[Renderer] Close button element (#mainCloseButton) not found!');
    }
    
    // Apply tooltips to all UI elements after a short delay to ensure DOM is ready
    setTimeout(() => {
      this._applyTooltips();
      devLog('[Renderer] Tooltips applied to UI elements');
    }, 500);
    
    // Listen for exit confirmation request from main process
    ipcRenderer.on('show-exit-confirmation', () => {
      devLog('[Renderer] Received show-exit-confirmation request.');
      this.modals.show('confirmExitModal');
    });

    // Initialize modal close button styles
    this._initializeModalCloseButtonStyles();
    
    // Set up a MutationObserver to detect DOM changes and reapply tooltips
    this._setupTooltipObserver();
  }
  
  /**
   * Sets up a MutationObserver to detect when new elements are added to the DOM
   * and reapply tooltips as needed.
   * @private
   */
  _setupTooltipObserver() {
    // Create a MutationObserver to watch for significant DOM changes
    const observer = new MutationObserver((mutations) => {
      let shouldReapplyTooltips = false;
      
      // Check if any mutations are significant enough to warrant reapplying tooltips
      for (const mutation of mutations) {
        if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
          // If substantive elements were added, reapply tooltips
          for (const node of mutation.addedNodes) {
            if (node.nodeType === 1 && (
                node.id === 'clearConsoleButton' || 
                node.id === 'clearPacketLogButton' ||
                node.id === 'settingsButton' ||
                node.id === 'pluginsButton' ||
                node.querySelector('.modal-close-button-std') ||
                node.classList.contains('tab-content')
              )) {
              shouldReapplyTooltips = true;
              break;
            }
          }
        }
        
        if (shouldReapplyTooltips) break;
      }
      
      // If significant changes were detected, reapply tooltips
      if (shouldReapplyTooltips) {
        devLog('[Renderer] Detected DOM changes, reapplying tooltips...');
        setTimeout(() => this._applyTooltips(), 100);
      }
    });
    
    // Start observing the document with specified configuration
    observer.observe(document.body, { 
      childList: true,
      subtree: true,
      attributes: false,
      characterData: false
    });
    
    devLog('[Renderer] Tooltip observer initialized');
  }

  /**
   * Initializes the hover styles for standardized modal close buttons.
   * @private
   */
  _initializeModalCloseButtonStyles() {
    // Ensure this runs after the DOM is ready and relevant modals might be shown.
    // Using $(document).on for dynamically added elements is robust.
    $(document).on('mouseenter', '.modal-close-button-std', function () {
      $(this).css({
        'color': 'var(--theme-primary)', // Make sure --theme-primary is defined in your CSS
        'background-color': 'rgba(232, 61, 82, 0.1)',
        'transform': 'scale(1.1)'
      });
    });

    $(document).on('mouseleave', '.modal-close-button-std', function () {
      // Resetting to empty string will allow CSS to take over.
      // If these properties were inline before, this won't revert to original inline,
      // but to stylesheet-defined styles for the element/classes.
      $(this).css({
        'color': '',
        'background-color': '',
        'transform': ''
      });
    });
    devLog('[Renderer] Modal close button hover styles initialized.');
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
    return Tooltip.create(element, content, options);
  }

  /**
   * Apply tooltips to UI elements
   * Called after the DOM is fully loaded to ensure all elements exist
   * @private
   */
  _applyTooltips() {
    // Refresh plugins button
    const refreshPluginsButton = document.getElementById('refreshPluginsSection');
    if (refreshPluginsButton) {
      this.addTooltip(refreshPluginsButton, 'Refresh Plugins');
    }
    
    // Toggle plugins visibility button
    const togglePluginsButton = document.getElementById('togglePluginsSection');
    if (togglePluginsButton) {
      this.addTooltip(togglePluginsButton, 'Toggle Plugins List');
    }
    
    // Info icons
    $('.plugin-info-button').each((index, element) => {
      this.addTooltip(element, 'More Info');
    });
    
    // Clear buttons (icon-only)
    const clearConsoleButton = document.getElementById('clearConsoleButton');
    if (clearConsoleButton) {
      this.addTooltip(clearConsoleButton, 'Clear Console Messages');
    }
    
    const clearPacketLogButton = document.getElementById('clearPacketLogButton');
    if (clearPacketLogButton) {
      this.addTooltip(clearPacketLogButton, 'Clear Network Messages');
    }
  }

  /**
   * Removes title attributes from elements that will have tooltips
   * @private
   */
  _removeTitleAttributes() {
    // Remove title attributes from icon-only buttons that need custom tooltips
    $('#clearConsoleButton').removeAttr('title');
    $('#clearPacketLogButton').removeAttr('title');
    $('#refreshPluginsSection').removeAttr('title');
    $('#togglePluginsSection').removeAttr('title');
    
    // Remove title from info buttons
    $('.plugin-info-button').removeAttr('title');

    // Still remove title attributes from window controls and play button
    // even though we don't apply custom tooltips to them
    $('#minimizeButton').removeAttr('title');
    $('#fullscreenButton').removeAttr('title');
    $('#mainCloseButton').removeAttr('title');
    $('#playButton').removeAttr('title');
  }

  /**
   * Reloads log limit settings after they've been changed.
   * This should be called after settings are updated in the settings modal.
   * @public
   */
  reloadLogLimitSettings() {
    this._loadLogLimitSettings();
    devLog('Log limit settings reloaded from settings.');
  }

  /**
   * Register a console command
   * @param {string} name - Command name
   * @param {Function} callback - Command callback
   * @param {string} [description] - Command description
   * @returns {boolean} - Success
   */
  registerConsoleCommand(name, callback, description = '') {
    if (!this.dispatch || !this.dispatch.onCommand) {
      console.error('Cannot register command: dispatch not initialized');
      return false;
    }
    
    try {
      this.dispatch.onCommand({
        name,
        description: description || `${name} command`,
        callback
      });
      return true;
    } catch (error) {
      console.error(`Failed to register command ${name}:`, error);
      return false;
    }
  }

  /**
   * Opens the Report Problem modal.
   * @public
   */
  openReportProblemModal () {
    this.modals.show('reportProblem')
  }
}
