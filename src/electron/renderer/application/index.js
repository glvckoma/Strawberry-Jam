/* eslint-disable camelcase */
const { ipcRenderer } = require('electron')
const { EventEmitter } = require('events')

// Helper: Only log in development
function devLog(...args) {
  if (process.env.NODE_ENV === 'development') console.log(...args);
}
function devError(...args) {
  if (process.env.NODE_ENV === 'development') console.error(...args);
}
const Server = require('../../../networking/server')
const Settings = require('./settings')
const Patcher = require('./patcher')
const Dispatch = require('./dispatch')
const HttpClient = require('../../../services/HttpClient')
const ModalSystem = require('./modals')

/**
 * Message status icons.
 * @type {Object}
 * @constant
 */
const messageStatus = Object.freeze({
  success: {
    icon: 'success.png'
  },
  logger: {
    icon: 'logger.png'
  },
  action: {
    icon: 'action.png'
  },
  wait: {
    icon: 'wait.png'
  },
  celebrate: {
    icon: 'celebrate.png'
  },
  warn: {
    icon: 'warn.png'
  },
  notify: {
    icon: 'notify.png'
  },
  speech: {
    icon: 'speech.png'
  },
  error: {
    icon: 'error.png'
  }
})

module.exports = class Application extends EventEmitter {
  /**
   * Constructor.
   * @constructor
   */
  constructor () {
    super()

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

    /**
     * The reference to the dispatch.
     * @type {Dispatch}
     * @public
     */
    this.dispatch = new Dispatch(this)

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
    this._maxLogEntries = 600;

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
  }

  /**
   * Checks if the Animal Jam server host has changed.
   * @returns {Promise<void>}
   * @privte
   */
  async _checkForHostChanges () {
    try {
      const data = await HttpClient.fetchFlashvars()
      let { smartfoxServer } = data

      smartfoxServer = smartfoxServer.replace(/\.(stage|prod)\.animaljam\.internal$/, '-$1.animaljam.com')
      smartfoxServer = `lb-${smartfoxServer}`

      if (smartfoxServer !== this.settings.get('smartfoxServer')) {
        this.settings.update('smartfoxServer', smartfoxServer)

        this.consoleMessage({
          message: 'Server host has changed. Changes are now being applied.',
          type: 'notify'
        })
      }
    } catch (error) {
      this.consoleMessage({ type: 'error', message: `Error loading settings: ${error.message}` })
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
        devLog("[Main Renderer] Setting up plugin IPC listeners...");

        ipcRenderer.on('plugin-remote-message', (event, msg) => {
          devLog("[Main Renderer] Received plugin-remote-message:", msg);
          if (this.dispatch && typeof this.dispatch.sendRemoteMessage === 'function') {
            this.dispatch.sendRemoteMessage(msg).catch(err => {
              this.consoleMessage({ type: 'error', message: `Error sending remote message from plugin: ${err.message}` });
            });
          } else {
            this.consoleMessage({ type: 'error', message: 'Cannot send remote message: Dispatch not ready.' });
          }
        });

        ipcRenderer.on('plugin-connection-message', (event, msg) => {
          devLog("[Main Renderer] Received plugin-connection-message:", msg);
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
          devLog(`[Main Renderer] Received dispatch-get-state-sync request for key: ${key}`);
          if (this.dispatch && typeof this.dispatch.getState === 'function') {
            try {
              const value = this.dispatch.getState(key);
              devLog(`[Main Renderer] Returning sync state value for ${key}:`, value);
              event.returnValue = value; // Set return value for sendSync
            } catch (error) {
              this.consoleMessage({ type: 'error', message: `Error getting sync state for key '${key}': ${error.message}` });
              devError(`[Main Renderer] Error getting sync state for key '${key}':`, error);
              event.returnValue = null; // Return null on error
            }
          } else {
            this.consoleMessage({ type: 'error', message: `Cannot get sync state for key '${key}': Dispatch not ready.` });
            devError(`[Main Renderer] Cannot get sync state for key '${key}': Dispatch not ready.`);
            event.returnValue = null; // Return null if dispatch isn't ready
          }
        });

        // Listener for asynchronous state requests from the main process
        ipcRenderer.on('main-renderer-get-state-async', (event, { key, replyChannel }) => {
          devLog(`[Main Renderer] Received ASYNC request from main process for key: ${key} (Reply Channel: ${replyChannel})`);
          let value = null;
          // Check if dispatch and getState are available
          if (this.dispatch && typeof this.dispatch.getState === 'function') {
            try {
              value = this.dispatch.getState(key);
              devLog(`[Main Renderer] Got state value for ${key}:`, value);
            } catch (error) {
              this.consoleMessage({ type: 'error', message: `Error getting ASYNC state for key '${key}' in renderer: ${error.message}` });
              devError(`[Main Renderer] Error getting ASYNC state for key '${key}':`, error);
              value = null; // Ensure value is null on error
            }
          } else {
            this.consoleMessage({ type: 'error', message: `Cannot get ASYNC state for key '${key}': Dispatch not ready.` });
            devError(`[Main Renderer] Cannot get ASYNC state for key '${key}': Dispatch not ready.`);
            value = null; // Ensure value is null if dispatch isn't ready
          }
          // Send the value back on the unique reply channel
          devLog(`[Main Renderer] Sending reply for ${key} on channel ${replyChannel}:`, value);
          ipcRenderer.send(replyChannel, value);
        });


        devLog("[Main Renderer] Plugin IPC listeners setup complete.");
      } catch (e) {
        devError("[Main Renderer] Error setting up plugin IPC listeners:", e);
      }
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
    this.modals.show('settings', '#modalContainer')
  }

  /**
   * Opens plugins hub.
   */
  openPluginHub () {
    this.modals.show('pluginLibraryModal', '#modalContainer')
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
  close () {
    ipcRenderer.send('window-close')
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
            ipcRenderer.send('packet-event', {
              raw: message.toMessage(),
              direction: type === 'aj' ? 'in' : 'out',
              timestamp: Date.now()
            });
          } catch (e) {
            // Ignore if not available
          }
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
            scrollbar-color: #3A3D4D #1C1E26;
          }
          .ui-autocomplete::-webkit-scrollbar {
            width: 8px;
          }
          .ui-autocomplete::-webkit-scrollbar-track {
            background: #1C1E26;
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
  consoleMessage ({ message, type = 'success', withStatus = true, time = true, isPacket = false, isIncoming = false, details = null } = {}) {
    const baseTypeClasses = {
      success: 'bg-highlight-green/10 border-l-4 border-highlight-green text-highlight-green',
      error: 'bg-error-red/10 border-l-4 border-error-red text-error-red',
      wait: 'bg-tertiary-bg/30 border-l-4 border-tertiary-bg text-gray-300',
      celebrate: 'bg-purple-500/10 border-l-4 border-purple-500 text-purple-400',
      warn: 'bg-highlight-yellow/10 border-l-4 border-highlight-yellow text-highlight-yellow',
      notify: 'bg-blue-500/10 border-l-4 border-blue-500 text-blue-400',
      speech: 'bg-primary-bg/10 border-l-4 border-primary-bg text-text-primary',
      logger: 'bg-gray-700/30 border-l-4 border-gray-600 text-gray-300',
      action: 'bg-teal-500/10 border-l-4 border-teal-500 text-teal-400'
    }

    const packetTypeClasses = {
      incoming: 'bg-tertiary-bg/20 border-l-4 border-highlight-green text-text-primary',
      outgoing: 'bg-highlight-green/5 border-l-4 border-highlight-yellow text-text-primary'
    }

    const createElement = (tag, classes = '', content = '') => {
      return $('<' + tag + '>').addClass(classes).html(content)
    }

    const getTime = () => {
      const now = new Date()
      const hour = String(now.getHours()).padStart(2, '0')
      const minute = String(now.getMinutes()).padStart(2, '0')
      const second = String(now.getSeconds()).padStart(2, '0')
      return `${hour}:${minute}:${second}`
    }

    const status = (type, message) => {
      const statusInfo = messageStatus[type]
      if (!statusInfo) throw new Error('Invalid Status Type.')
      return `
        <div class="flex items-center space-x-2">
          <img src="app://assets/icons/${statusInfo.icon}" class="w-4 h-4 opacity-90" />
          <span class="font-medium">${message || ''}</span>
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

    $messageContainer.css({
      overflow: 'hidden',
      'text-overflow': 'ellipsis',
      'white-space': 'normal',
      'word-break': 'break-word'
    })

    $container.append($messageContainer)

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
      if (this._packetLogCount > this._maxLogEntries) {
        this._cleanOldLogs($targetContainer, true);
      }
    } else {
      // Increment app message count and check if cleaning is needed
      this._appMessageCount++;
      if (this._appMessageCount > this._maxLogEntries) {
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
    const entriesToRemove = Math.floor(this._maxLogEntries * this._cleanPercentage);
    const $entries = $logContainer.children('div'); // Assuming logs are direct div children
    const currentTotal = $entries.length;

    if (currentTotal <= this._maxLogEntries) {
      return; // No need to clean yet
    }

    const numberToRemove = Math.min(entriesToRemove, currentTotal - (this._maxLogEntries * (1 - this._cleanPercentage))); // Ensure we don't remove too many
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

    // Add a notification message about the cleaning
    this.consoleMessage({
        message: `Cleaned ${numberToRemove} oldest log entries to maintain performance.`,
        type: 'notify',
        isPacket: false // Ensure this notification goes to the app messages log
    });

    devLog(`Cleaned ${numberToRemove} old log entries from ${isPacketLog ? 'packet log' : 'app messages'}. New count: ${newCount}`);
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

    try {
      this.consoleMessage({ message: 'Patching and launching Animal Jam Classic...', type: 'wait' });
      await this.patcher.killProcessAndPatch(); // Await the patching process
      this.consoleMessage({ message: 'Animal Jam Classic launched.', type: 'success' });
    } catch (error) {
      this.consoleMessage({
        message: `Error patching/launching Animal Jam Classic: ${error.message}`,
        type: 'error'
      });
    } finally {
      // Re-enable button and remove styles regardless of success/failure
      if (this.$playButton) {
        this.$playButton.classList.remove('opacity-50', 'pointer-events-none');
        // Restore original onclick behavior
        this.$playButton.onclick = () => jam.application.openAnimalJam();
      }
    }
  }

  /**
   * Renders a plugin item
   * @param {Object} plugin
   * @returns {JQuery<HTMLElement>}
   */
  renderPluginItems ({ name, type, description, author = 'Sxip' } = {}) {
    const getIconClass = () => {
      switch (type) {
        case 'ui': return 'fa-desktop'
        case 'game': return 'fa-gamepad'
      }
    }

    const getIconColorClass = () => {
      switch (type) {
        case 'ui': return 'text-highlight-green bg-highlight-green/10'
        case 'game': return 'text-highlight-yellow bg-highlight-yellow/10'
      }
    }

    const onClickEvent = type === 'ui' ? () => jam.application.dispatch.open(name) : null

    const $listItem = $('<li>', { class: type === 'ui' ? 'group' : '' })
    const $container = $('<div>', {
      class: `flex items-center px-3 py-3.5 ${type === 'ui' ? 'hover:bg-tertiary-bg cursor-pointer' : ''} rounded-md transition-colors`,
      click: onClickEvent
    })

    const $iconContainer = $('<div>', {
      class: `w-8 h-8 flex items-center justify-center ${getIconColorClass()} rounded mr-3 flex-shrink-0`
    }).append($('<i>', { class: `fas ${getIconClass()} text-base` }))

    const $contentContainer = $('<div>', { class: 'flex-1 min-w-0' })
    const $titleRow = $('<div>', { class: 'flex items-center' })

    $titleRow.append($('<span>', {
      class: 'text-sidebar-text font-medium whitespace-normal break-words text-[15px]', // Removed truncate, added wrapping
      text: name
    }))

    const $metaRow = $('<div>', {
      class: 'flex items-center text-[11px] text-gray-400 mt-1'
    })

    $metaRow.append($('<span>', {
      class: 'flex items-center',
      html: `<i class="fas fa-user mr-1 opacity-70"></i>${author}`
    }))

    $metaRow.append($('<span>', {
      class: 'mx-1.5 opacity-50',
      html: '•'
    }))

    $metaRow.append($('<span>', {
      class: 'opacity-70',
      text: type.charAt(0).toUpperCase() + type.slice(1)
    }))

    const $description = $('<p>', {
      class: 'text-xs text-gray-400 whitespace-normal break-words mt-1.5', // Removed truncate, added wrapping
      text: description || `${type.charAt(0).toUpperCase() + type.slice(1)} plugin for Animal Jam`
    })

    $contentContainer.append($titleRow, $metaRow, $description)
    $container.append($iconContainer, $contentContainer)
    $listItem.append($container)

    if (type === 'ui') this.$pluginList.prepend($listItem)
    else this.$pluginList.append($listItem)

    return $listItem
  }

  /**
   * Instantiates the application.
   * @returns {Promise<void>}
   * @public
   */
  async instantiate () {
    await Promise.all([
      this.settings.load(),
      this.dispatch.load()
    ])

    /**
     * Simple check for the host changes for animal jam classic.
     */
    const secureConnection = this.settings.get('secureConnection')
    if (secureConnection) await this._checkForHostChanges()

    await this.server.serve()
    // this._setupPluginIPC(); // Call moved to constructor
    this.emit('ready')

    // Signal to main process that renderer is ready (for auto-resume logic)
    devLog('[Renderer] Application instantiated, sending renderer-ready signal.');
    ipcRenderer.send('renderer-ready');
  }
}
