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
const PluginInfoModalManager = require('../ui/plugin-info-modal-manager')
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

// Global Toast Function
function showGlobalToast (message, type = 'success', duration = 7000) { // Increased default duration further
  const colors = {
    success: 'bg-highlight-green text-white',
    error: 'bg-error-red text-white',
    warning: 'bg-highlight-yellow text-black', // Changed warning to have black text for better contrast
    notify: 'bg-custom-blue text-white',
    checking: 'bg-gray-600 text-white', // For 'checking' status
    available: 'bg-blue-500 text-white', // For 'available' status
    downloaded: 'bg-purple-500 text-white' // For 'downloaded' status
  }
  const toastId = `global-toast-${Date.now()}`;
  const toast = $(`
    <div id="${toastId}" class="fixed bottom-32 right-4 px-4 py-3 rounded-lg shadow-xl z-[99999] text-sm font-medium ${colors[type] || colors.notify}" style="opacity: 0; transform: translateY(20px);">
      ${message}
    </div>
  `);
  $('body').append(toast);

  // Animate in
  toast.animate({ opacity: 1, transform: 'translateY(0)' }, 300);

  setTimeout(() => {
    toast.animate({ opacity: 0, transform: 'translateY(20px)' }, 300, function () { $(this).remove() });
  }, duration);
}


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

    /**
     * Whether the game client is currently running.
     * @type {boolean}
     * @private
     */
    this._isGameRunning = false;

    this._setupPluginIPC(); // Moved from instantiate to ensure handlers are ready early
    this._setupStatusIndicatorIPC(); // Add call to setup new listeners
    this._setupGameProcessIPC(); // Add game process IPC listener
    // this._setupAppUpdateIPC(); // Call is already commented out, ensuring it remains so.
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
        }

        ipcRenderer.on('plugin-remote-message', async (event, msg) => { // Make handler async
          let processedMsg = msg;
          
          // Check if dispatch is ready and message needs processing
          if (this.dispatch && typeof msg === 'string' && msg.includes('{room}')) {
            try {
              const currentRoom = await this.dispatch.getState('room'); // Await the async call
              if (currentRoom) {
                processedMsg = msg.replaceAll('{room}', currentRoom);
              } else {
              }
            } catch (error) {
            }
          }
          
          // Send the (potentially processed) message
          if (this.dispatch && typeof this.dispatch.sendRemoteMessage === 'function') {
            this.dispatch.sendRemoteMessage(processedMsg).catch(err => {
              this.consoleMessage({ type: 'error', message: `Error sending remote message from plugin: ${err.message}` });
            });
          } else {
            this.consoleMessage({ type: 'error', message: 'Cannot send remote message: Dispatch not ready.' });
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
              event.returnValue = value; // Set return value for sendSync
            } catch (error) {
              event.returnValue = null; // Return null on error
            }
          } else {
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
              value = null; // Ensure value is null on error
            }
          } else {
            value = null; // Ensure value is null if dispatch isn't ready
          }
          // Send the value back on the unique reply channel
          ipcRenderer.send(replyChannel, value);
        });

      } catch (e) {
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
          this._updatePluginStatusIndicator(pluginName, true);
        });

        ipcRenderer.on('plugin-window-closed', (event, pluginName) => {
          this._updatePluginStatusIndicator(pluginName, false);
        });
        
        ipcRenderer.on('plugin-window-focused', (event, pluginName) => {
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
      }
    }
  }

  /**
   * Sets up IPC listeners for game process events.
   * @private
   */
  _setupGameProcessIPC() {
    if (typeof require === "function") {
      try {
        const { ipcRenderer } = require('electron');

        ipcRenderer.on('game-process-exit', () => {
          this._handleGameProcessExit();
        });

      } catch (e) {
      }
    }
  }

  /**
   * Handles when the game process exits.
   * @private
   */
  _handleGameProcessExit() {
    this._isGameRunning = false;
    
    // Re-enable the play button
    if (this.$playButton) {
      this.$playButton.classList.remove('opacity-100');
      this.$playButton.onclick = () => jam.application.openAnimalJam();
      // Remove the game running tooltip
      this._removeGameRunningTooltip();
    }

    this.consoleMessage({
      message: 'Strawberry Jam Classic has closed.',
      type: 'info'
    });
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
    // Ensure pluginList is available
    if (!this.$pluginList || this.$pluginList.length === 0) {
        return;
    }
    
    const $listItem = this.$pluginList.find(`li[data-plugin-name="${pluginName}"]`);
    if ($listItem.length === 0) {
        // It's possible the list hasn't fully rendered yet, or the plugin isn't listed.
        // We could potentially retry or queue the update, but for now, just log.
        return;
    }

    const $indicator = $listItem.find('.plugin-status-indicator');
    if ($indicator.length === 0) {
        return;
    }

    // Only update UI plugins
    const pluginType = $listItem.data('plugin-type');
    if (pluginType === 'ui') {
        if (isOpen) {
            $indicator.removeClass('bg-red-500 bg-yellow-500').addClass('bg-green-500');
        } else {
            $indicator.removeClass('bg-green-500 bg-yellow-500').addClass('bg-red-500');
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
    // const onModalClosed = () => {
    //   this.reloadLogLimitSettings(); // This call is likely redundant and contributing to the loop.
    //   this.removeListener('modal:closed:settings', onModalClosed);
    // };
    // this.once('modal:closed:settings', onModalClosed);
    // The settings are now flushed upon save, so log limits should be up-to-date.
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

      if (promptOnExit === false) {
        // If promptOnExit is false, tell the main process to close directly
        ipcRenderer.send('direct-close-window'); // We'll need to handle this in the main process
      } else {
        // Otherwise, show the exit confirmation modal
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
            scrollbar-color: #16171f #121212;
          }
          .ui-autocomplete::-webkit-scrollbar {
            width: 8px;
          }
          .ui-autocomplete::-webkit-scrollbar-track {
            background: #121212;
          }
          .ui-autocomplete::-webkit-scrollbar-thumb {
            background: #16171f;
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

    const commandSource = Array.from(this.dispatch.commands.values()).map(command => ({
      value: command.name,
      description: command.description
    }));
    
    this.$input.autocomplete({
      source: commandSource,
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
        
        // Use smooth rotation animation instead of icon switching
        if (isHidden) {
          $detailsButton.html('<i class="fas fa-chevron-down mr-1 smooth-chevron"></i> Details')
          $detailsButton.find('i').css('transform', 'rotate(0deg)')
        } else {
          $detailsButton.html('<i class="fas fa-chevron-down mr-1 smooth-chevron"></i> Hide')
          $detailsButton.find('i').css('transform', 'rotate(180deg)')
        }
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
      
    } catch (error) {
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

    // Check if game is already running
    if (this._isGameRunning) {
      this.consoleMessage({
        message: 'Strawberry Jam Classic is already running!',
        type: 'warning'
      });
      return;
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
        message: 'Starting Strawberry Jam Classic...', 
        type: 'wait',
        details: { messageId: startMessageId } // Pass ID
      });
      
      await this.patcher.killProcessAndPatch(); // Await the patching process
      
      launchSuccessful = true; // Assume success if killProcessAndPatch completes without error
      this._isGameRunning = true; // Mark game as running
      
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
          message: 'Successfully launched Strawberry Jam Classic!',
          type: 'success'
        });
      }
      
      // Handle button state based on game running status
      if (this.$playButton) {
        if (this._isGameRunning) {
          // Keep button disabled but make it fully opaque and allow hover for tooltip
          this.$playButton.classList.remove('opacity-50', 'pointer-events-none');
          this.$playButton.classList.add('opacity-100');
          this.$playButton.onclick = () => jam.application.openAnimalJam(); // Will show warning message
          // Add tooltip indicating game is running
          this._addGameRunningTooltip();
        } else {
          // Re-enable button normally if launch failed
          this.$playButton.classList.remove('opacity-50', 'pointer-events-none');
          this.$playButton.onclick = () => jam.application.openAnimalJam();
          // Remove the game running tooltip
          this._removeGameRunningTooltip();
        }
      }
    }
  }

  /**
   * Opens AJ Classic external installation
   * @returns {Promise<void>}
   * @public
   */
  async openAJClassic () {
    const ajClassicButton = document.getElementById('ajClassicButton');
    if (!ajClassicButton) {
      console.error("AJ Classic button element not found!");
      return;
    }

    // Disable button and apply styles
    ajClassicButton.classList.add('opacity-50', 'pointer-events-none');
    ajClassicButton.onclick = () => false;
    
    const startMessageId = `start-aj-classic-${Date.now()}`;

    try {
      // Log starting message
      this.consoleMessage({ 
        message: 'Launching AJ Classic...', 
        type: 'wait',
        details: { messageId: startMessageId }
      });
      
      // Send IPC message to launch AJ Classic
      ipcRenderer.send('launch-aj-classic');
      
      // Success message after short delay
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Remove starting message
      const startingMessageElement = document.querySelector(`[data-message-id='${startMessageId}']`);
      if (startingMessageElement) {
        $(startingMessageElement).remove();
      }
      
      // Log success message
      this.consoleMessage({
        message: 'AJ Classic launched successfully!',
        type: 'success'
      });
      
    } catch (error) {
      this.consoleMessage({
        message: `Error launching AJ Classic: ${error.message}`,
        type: 'error'
      });
    } finally {
      // Re-enable button
      if (ajClassicButton) {
        ajClassicButton.classList.remove('opacity-50', 'pointer-events-none');
        ajClassicButton.onclick = () => jam.application.openAJClassic();
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
      this.pluginInfoModalManager.show(name);
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
    return $plugin; 
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
    await this.pathPromise;

    // Now that paths are available, instantiate the Patcher
    this.patcher = new Patcher(this, this.assetsPath);
    
    // Initialize Dispatch with the data path and the bound consoleMessage function
    this.dispatch = new Dispatch(
      this,
      this.dataPath,
      this.consoleMessage.bind(this) // Pass bound function
    );

    this.pluginInfoModalManager = new PluginInfoModalManager(this.dispatch);

    ipcRenderer.on('get-plugin-path', (event, pluginName) => {
      const plugin = this.dispatch.plugins.get(pluginName);
      if (plugin) {
        ipcRenderer.send('plugin-path-response', plugin.filepath);
      } else {
        ipcRenderer.send('plugin-path-response', null);
      }
    });
    
    // Register core commands
    registerCoreCommands(this.dispatch, this);
    
    // Refresh autocomplete to include core commands
    this.refreshAutoComplete();
    
    // Load settings (log only in dev mode)
    await this.settings.load();
    if (isDevelopment) {
    }
    
    // Load log limit settings from user settings
    await this._loadLogLimitSettings();
    
    // Initialize tooltip system
    Tooltip.init(this);
    
    // Remove title attributes from elements that will have tooltips
    this._removeTitleAttributes();
    
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

    // Check for version updates and show modal if needed
    await this._checkVersionAndShowUpdatesModal();

    // Signal to main process that renderer is ready (for auto-resume logic)
    ipcRenderer.send('renderer-ready');

    // Set up handlers for the minimize and close buttons
    const minimizeButton = document.getElementById('minimizeButton');
    const mainCloseButton = document.getElementById('mainCloseButton');
    
    if (minimizeButton) {
      minimizeButton.addEventListener('click', () => {
        this.minimize();
      });
    } else {
    }

    if (mainCloseButton) {
      mainCloseButton.addEventListener('click', () => {
        this.close();
      });
    } else {
    }
    
    // Apply tooltips to all UI elements after a short delay to ensure DOM is ready
    setTimeout(() => {
      this._applyTooltips();
    }, 500);
    
    // Listen for exit confirmation request from main process
    ipcRenderer.on('show-exit-confirmation', () => {
      this.modals.show('confirmExitModal');
    });

    // Listen for notification that plugins were closed by AJ Classic closing
    ipcRenderer.on('plugins-closed-by-aj-classic', () => {
      this.consoleMessage({
        message: 'All plugins have been closed because Strawberry Jam Classic was closed.',
        type: 'notify'
      });
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
   * Adds a tooltip to the play button indicating the game is running.
   * @private
   */
  _addGameRunningTooltip() {
    if (this.$playButton) {
      this.addTooltip(this.$playButton, 'Strawberry Jam is already running', {
        theme: 'error',
        position: 'top'
      });
    }
  }

  /**
   * Removes the game running tooltip from the play button.
   * @private
   */
  _removeGameRunningTooltip() {
    if (this.$playButton) {
      Tooltip.remove(this.$playButton);
    }
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
    
    // Navigation chevron button
    const toggleNavButton = document.getElementById('toggleNavSection');
    if (toggleNavButton) {
      this.addTooltip(toggleNavButton, 'Toggle Navigation List');
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
    $('#toggleNavSection').removeAttr('title');
    
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

  /**
   * Checks for version updates and shows the updates modal if needed.
   * @returns {Promise<void>}
   * @private
   */
  async _checkVersionAndShowUpdatesModal() {
    try {
      // Get user's last seen version
      const lastSeenVersion = await ipcRenderer.invoke('get-setting', 'lastSeenVersion');
      
      // Load updates data
      const path = require('path');
      const dataPath = path.join(__dirname, '../../../data/updates-data.json');
      const rawData = await ipcRenderer.invoke('read-file', dataPath);
      const updatesData = JSON.parse(rawData);
      
      // Find the latest version in updates data
      const latestVersion = Object.keys(updatesData).find(v => updatesData[v].isLatest);
      
      // Check if we should show updates modal
      const shouldShow = latestVersion && 
                        latestVersion !== lastSeenVersion && 
                        this._isNewerVersion(latestVersion, lastSeenVersion || '0.0.0');
      
      if (shouldShow) {
        // Small delay to ensure UI is fully loaded
        setTimeout(() => {
          this.modals.show('updatesModal', '#modalContainer', { 
            version: latestVersion 
          });
        }, 1000);
      }
    } catch (error) {
      console.error('Error checking for version updates:', error);
      // Fail silently - don't interrupt app startup
    }
  }

  /**
   * Compares two version strings to determine if first is newer than second.
   * @param {string} version1 - Version to compare (e.g., "3.3.2")
   * @param {string} version2 - Version to compare against (e.g., "3.3.1")
   * @returns {boolean} True if version1 is newer than version2
   * @private
   */
  _isNewerVersion(version1, version2) {
    const v1Parts = version1.split('.').map(Number);
    const v2Parts = version2.split('.').map(Number);
    
    for (let i = 0; i < Math.max(v1Parts.length, v2Parts.length); i++) {
      const v1Part = v1Parts[i] || 0;
      const v2Part = v2Parts[i] || 0;
      
      if (v1Part > v2Part) return true;
      if (v1Part < v2Part) return false;
    }
    
    return false;
  }

  /**
   * Opens the Updates modal manually.
   * @public
   */
  async openUpdatesModal(version = null) {
    // If no version specified, get the latest version from updates data
    if (!version) {
      try {
        const path = require('path');
        const dataPath = path.join(__dirname, '../../../data/updates-data.json');
        const rawData = await ipcRenderer.invoke('read-file', dataPath);
        const updatesData = JSON.parse(rawData);
        const dataKeys = Object.keys(updatesData);
        const latestVersion = dataKeys.find(v => updatesData[v].isLatest);
        const fallbackVersion = dataKeys[0];
        version = latestVersion || fallbackVersion;
      } catch (error) {
        console.error('Failed to load version for manual open:', error);
        // Fallback to a known version if all else fails
        version = '3.4.0';
      }
    }
    
    this.modals.show('updatesModal', '#modalContainer', { 
      version: version 
    });
  }
}
