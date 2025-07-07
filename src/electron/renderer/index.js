const Application = require('./application')
const { ipcRenderer } = require('electron')
const ServerStatusChecker = require('../../services/ServerStatusChecker')
const logManager = require('../../utils/LogManagerPreload')

const application = new Application()

// Track session start time
let sessionStartTime = null;

// Track server status
let serverStatus = {
  isOnline: null, // null = unknown, true = online, false = offline
  lastChecked: 0,
  responseTime: 0,
  server: null,
  accessStatus: 'unknown',
  statusCode: null,
  isChecking: false // New flag to track when a check is in progress
};

/**
 * Updates the connection status indicator in the UI.
 * @param {boolean} connected - Whether the client is connected
 * @param {boolean} [serverOnline] - Whether the AJ servers are online (optional)
 */
const updateConnectionStatus = (connected, serverOnline = null) => {
  // Get footer-based status element
  const statusElement = document.getElementById('connection-status')
  if (!statusElement) return
  
  // If server status is provided, update the global state
  if (serverOnline !== null) {
    serverStatus.isOnline = serverOnline;
    serverStatus.isChecking = false; // Check completed
  }
  
  // Update status for footer indicator
  if (connected) {
    // Connected state
    statusElement.querySelector('span:first-child').classList.remove('bg-error-red', 'bg-highlight-yellow', 'bg-tertiary-bg')
    statusElement.querySelector('span:first-child').classList.add('bg-highlight-green')
    statusElement.querySelector('span:last-child').textContent = 'Connected'
    statusElement.querySelector('span:first-child').classList.remove('pulse-animation', 'pulse-yellow', 'pulse-loading')
    statusElement.querySelector('span:first-child').classList.add('pulse-green')
    statusElement.classList.remove('text-gray-400', 'text-highlight-yellow', 'text-error-red')
    statusElement.classList.add('text-highlight-green')
    
    // Add tooltip with server info
    if (serverStatus.server) {
      const tooltipText = `Connected to ${serverStatus.server} (Response time: ${serverStatus.responseTime}ms)`;
      statusElement.setAttribute('title', tooltipText);
    }
  } else if (serverStatus.isChecking) {
    // Checking state (new)
    statusElement.querySelector('span:first-child').classList.remove('bg-error-red', 'bg-highlight-green', 'bg-highlight-yellow')
    statusElement.querySelector('span:first-child').classList.add('bg-tertiary-bg')
    statusElement.querySelector('span:last-child').textContent = 'Checking...'
    statusElement.querySelector('span:first-child').classList.remove('pulse-green', 'pulse-animation')
    statusElement.querySelector('span:first-child').classList.add('pulse-loading')
    statusElement.classList.remove('text-highlight-green', 'text-highlight-yellow', 'text-error-red')
    statusElement.classList.add('text-gray-400')
    
    // Add tooltip
    statusElement.setAttribute('title', 'Checking Animal Jam server status...');
  } else {
    // Disconnected state with server status
    
    // First remove all classes to ensure clean state
    const dotElement = statusElement.querySelector('span:first-child');
    dotElement.classList.remove('bg-highlight-green', 'bg-error-red', 'bg-highlight-yellow', 'bg-tertiary-bg');
    dotElement.classList.remove('pulse-green', 'pulse-animation', 'pulse-loading', 'pulse-yellow');
    statusElement.classList.remove('text-highlight-green', 'text-gray-400', 'text-highlight-yellow', 'text-error-red');
    
    // Show server status when not connected if we know it
    if (serverStatus.accessStatus === 'disabled_by_setting') {
      // Handle the specific case where the check is disabled by user settings
      statusElement.querySelector('span:last-child').textContent = 'Disabled in Settings';
      statusElement.classList.add('text-gray-400');
      dotElement.classList.add('bg-tertiary-bg');
      statusElement.setAttribute('title', 'Server status check is disabled in settings.');
    } else if (serverStatus.isOnline === true) {
      // Determine specific status based on accessStatus
      if (serverStatus.accessStatus === 'blocked') {
        // IP blocked
        statusElement.querySelector('span:last-child').textContent = 'AJ Servers: IP Blocked';
        statusElement.classList.add('text-highlight-yellow');
        dotElement.classList.add('bg-highlight-yellow');
        dotElement.classList.add('pulse-yellow');
        
        // Add tooltip
        statusElement.setAttribute('title', `${serverStatus.details || 'Your IP appears to be blocked from accessing the servers'}`);
      }
      else if (serverStatus.accessStatus === 'rate_limited') {
        // Rate limited
        statusElement.querySelector('span:last-child').textContent = 'AJ Servers: Rate Limited';
        statusElement.classList.add('text-highlight-yellow');
        dotElement.classList.add('bg-highlight-yellow');
        dotElement.classList.add('pulse-yellow');
        
        // Add tooltip
        statusElement.setAttribute('title', `${serverStatus.details || 'Server is rate limiting requests'}`);
      }
      else if (serverStatus.accessStatus === 'auth_error') {
        // Authentication service having issues
        statusElement.querySelector('span:last-child').textContent = 'AJ Servers: Auth Issues';
        statusElement.classList.add('text-highlight-yellow');
        dotElement.classList.add('bg-highlight-yellow');
        dotElement.classList.add('pulse-yellow');
        
        // Add tooltip
        statusElement.setAttribute('title', `${serverStatus.details || 'Authentication service issues'}`);
      }
      else if (serverStatus.accessStatus === 'unusual') {
        // Unusual response
        statusElement.querySelector('span:last-child').textContent = 'AJ Servers: Unusual Status';
        statusElement.classList.add('text-highlight-yellow');
        dotElement.classList.add('bg-highlight-yellow');
        dotElement.classList.add('pulse-yellow');
        
        // Add tooltip
        statusElement.setAttribute('title', `${serverStatus.details || 'Server responding with unusual status'}`);
      }
      else {
        // Servers online but not connected (normal case)
        statusElement.querySelector('span:last-child').textContent = 'AJ Servers are online!';
        statusElement.classList.add('text-highlight-green');
        dotElement.classList.add('bg-highlight-green');
        dotElement.classList.add('pulse-green');
        
        // Add tooltip with server info
        if (serverStatus.details) {
          statusElement.setAttribute('title', `${serverStatus.details} (Response time: ${serverStatus.responseTime}ms)`);
        } else if (serverStatus.server) {
          const tooltipText = `Server ${serverStatus.server} is online (Response time: ${serverStatus.responseTime}ms)`;
          statusElement.setAttribute('title', tooltipText);
        }
      }
    } else if (serverStatus.isOnline === false) {
      // Determine specific offline message based on accessStatus
      if (serverStatus.accessStatus === 'server_error') {
        statusElement.querySelector('span:last-child').textContent = 'AJ Servers: Error';
      } else if (serverStatus.accessStatus === 'network_error') {
        statusElement.querySelector('span:last-child').textContent = 'Cannot Connect to AJ Servers';
      } else {
        statusElement.querySelector('span:last-child').textContent = 'AJ Servers are offline :(';
      }
      
      statusElement.classList.add('text-error-red');
      dotElement.classList.add('bg-error-red');
      dotElement.classList.add('pulse-animation');
      
      // Add tooltip with details
      const lastCheckedTime = new Date(serverStatus.lastChecked).toLocaleTimeString();
      const tooltipText = `${serverStatus.details || 'Unable to connect to Animal Jam servers'}. Last checked: ${lastCheckedTime}`;
      statusElement.setAttribute('title', tooltipText);
    } else {
      // Unknown status
      statusElement.querySelector('span:last-child').textContent = 'Status Unknown';
      statusElement.classList.add('text-gray-400');
      dotElement.classList.add('bg-tertiary-bg');
      dotElement.classList.add('pulse-animation');
      
      // Add tooltip suggesting to use servers command
      statusElement.setAttribute('title', 'Server status unknown. Type !servers to check status.');
    }
  }
}

/**
 * Checks the Animal Jam server status and updates the UI.
 * @returns {Promise<boolean>} Whether the server is online
 */
const checkServerStatus = async () => {
  try {
    // Update UI to show we're checking
    serverStatus.isChecking = true;
    updateConnectionStatus(false);
    
    // Get server host from settings if available
    const serverHost = application.settings ? 
      application.settings.get('smartfoxServer') : 
      'lb-iss04-classic-prod.animaljam.com';
    
    // Check server status
    const result = await ServerStatusChecker.checkServerStatus(serverHost);
    
    // Update global state
    serverStatus = {
      isOnline: result.isOnline,
      lastChecked: Date.now(),
      responseTime: result.responseTime,
      server: result.server || serverHost,
      accessStatus: result.accessStatus || 'unknown',
      statusCode: result.statusCode,
      details: result.details || '',
      isChecking: false
    };
    
    // Always update UI to reflect new server status
    // We pass the current connection state as null to preserve it
    const isConnected = application.server && 
                        application.server.clients && 
                        application.server.clients.size > 0;
    
    updateConnectionStatus(isConnected, result.isOnline);
    
    // Log the result if console is available
    if (application && application.consoleMessage) {
      // Format server name to be more user-friendly
      let displayServer = result.server || serverHost;
      if (displayServer.includes('.internal')) {
        // Convert internal server name format to external
        displayServer = displayServer.replace(/\.internal$/, '');
        displayServer = 'lb-' + displayServer.replace(/\.(prod|stage)/, '-$1') + '.animaljam.com';
      }
      
      // Create appropriate message based on status
      let message = '';
      let messageType = '';
      
      if (result.isOnline) {
        if (result.accessStatus === 'ok') {
          message = `AJ Servers are online! ${displayServer} (${result.responseTime}ms)`;
          if (result.details) {
            message += ` - ${result.details}`;
          }
          messageType = 'success';
        } else if (result.accessStatus === 'blocked') {
          message = `AJ Servers are online but your IP appears to be blocked. ${displayServer} (${result.responseTime}ms)`;
          if (result.details) {
            message += ` - ${result.details}`;
          }
          messageType = 'warn';
        } else if (result.accessStatus === 'rate_limited') {
          message = `AJ Servers are online but rate limiting requests. ${displayServer} (${result.responseTime}ms)`;
          if (result.details) {
            message += ` - ${result.details}`;
          }
          messageType = 'warn';
        } else if (result.accessStatus === 'auth_error') {
          message = `AJ Servers are online but authentication service has issues. ${displayServer}`;
          if (result.details) {
            message += ` - ${result.details}`;
          }
          messageType = 'warn';
        } else if (result.accessStatus === 'unusual') {
          message = `AJ Servers are responding with unusual status. ${displayServer} (${result.responseTime}ms)`;
          if (result.details) {
            message += ` - ${result.details}`;
          }
          messageType = 'notify';
        } else {
          // Fallback for any other online status
          message = `AJ Servers are online. ${displayServer} (${result.responseTime}ms)`;
          if (result.details) {
            message += ` - ${result.details}`;
          }
          messageType = 'success';
        }
      } else {
        if (result.accessStatus === 'server_error') {
          message = `AJ Servers are experiencing errors. ${displayServer}`;
        } else if (result.accessStatus === 'network_error') {
          message = `Cannot connect to AJ Servers. ${displayServer}`;
        } else {
          message = `AJ Servers appear to be offline. ${displayServer}`;
        }
        
        if (result.details) {
          message += ` - ${result.details}`;
        }
        messageType = 'error';
      }
      
      application.consoleMessage({
        message,
        type: messageType
      });
    }
    
    return result.isOnline;
  } catch (error) {
    console.error('Error checking server status:', error);
    
    // Update to unknown state
    serverStatus.isOnline = null;
    serverStatus.lastChecked = Date.now();
    serverStatus.isChecking = false;
    serverStatus.accessStatus = 'network_error';
    serverStatus.details = `Error checking server status: ${error.message}`;
    
    // Log the error if console is available
    if (application && application.consoleMessage) {
      application.consoleMessage({
        message: `Error checking server status: ${error.message}`,
        type: 'error'
      });
    }
    
    return false;
  }
}

// Set initial connection status to checking
document.addEventListener('DOMContentLoaded', () => {
  serverStatus.isChecking = true;
  updateConnectionStatus(false);

  // Copy Packet Logs functionality
  const copyPacketLogsButton = document.getElementById('copyPacketLogsButton');
  const messageLog = document.getElementById('message-log');

  if (copyPacketLogsButton && messageLog) {
    copyPacketLogsButton.addEventListener('click', async () => {
      const originalButtonText = copyPacketLogsButton.innerHTML;
      const originalButtonClasses = copyPacketLogsButton.className;

      try {
        let logsToCopy = [];
        const logEntries = messageLog.querySelectorAll('div');

        logEntries.forEach(entry => {
          const isIncoming = entry.querySelector('.fa-arrow-down');
          const isOutgoing = entry.querySelector('.fa-arrow-up');
          const logText = entry.textContent.trim();

          if (logText) {
            if (isIncoming) {
              logsToCopy.push(`In: ${logText}`);
            } else if (isOutgoing) {
              logsToCopy.push(`Out: ${logText}`);
            } else {
              logsToCopy.push(logText);
            }
          }
        });

        if (logsToCopy.length > 0) {
          await navigator.clipboard.writeText(logsToCopy.join('\n'));
          copyPacketLogsButton.innerHTML = '<i class="fas fa-check mr-1"></i>Copied!';
          copyPacketLogsButton.className = 'bg-highlight-green text-white px-2 py-1 rounded text-xs transition min-w-[40px] ml-2';
        } else {
          copyPacketLogsButton.innerHTML = '<i class="fas fa-exclamation-triangle mr-1"></i>No Logs';
          copyPacketLogsButton.className = 'bg-error-red text-white px-2 py-1 rounded text-xs transition min-w-[40px] ml-2';
        }
      } catch (err) {
        console.error('Failed to copy logs:', err);
        copyPacketLogsButton.innerHTML = '<i class="fas fa-times mr-1"></i>Error';
        copyPacketLogsButton.className = 'bg-error-red text-white px-2 py-1 rounded text-xs transition min-w-[40px] ml-2';
      } finally {
        setTimeout(() => {
          copyPacketLogsButton.innerHTML = originalButtonText;
          copyPacketLogsButton.className = originalButtonClasses;
        }, 2000);
      }
    });
  }
})

const initializeApp = async () => {
  // Start session timer
  let totalUptime = await ipcRenderer.invoke('get-total-uptime');
  sessionStartTime = new Date();

  window.addEventListener('beforeunload', () => {
    const now = new Date();
    const sessionDuration = Math.round((now - sessionStartTime) / 1000);
    ipcRenderer.send('update-total-uptime', totalUptime + sessionDuration);
  });
  
  // Removed the initial "Starting Strawberry Jam..." message from here.
  // It's now logged within application.instantiate()

  // No need for startup delay - our messages are stored with IDs for later removal
  
  // Setup window control buttons
  setupWindowControls();

  try {
    await application.instantiate()
    
    application.attachNetworkingEvents()
    
    // Setup connection status monitoring
    setupConnectionMonitoring()
    
    // Register app-specific commands
    registerAppCommands(application)
    
    // Refresh autocomplete after core commands are registered
    if (application && typeof application.refreshAutoComplete === 'function') {
      application.refreshAutoComplete();
    }

    // Check server status on startup
    setTimeout(async () => {
      if (application && application.settings && application.settings._isLoaded) {
        const performCheck = application.settings.get('ui.performServerCheckOnLaunch', true);
        if (performCheck) {
          await checkServerStatus();
        } else {
          // Update internal state to reflect that the check was skipped
          serverStatus.isOnline = null; // Explicitly set to unknown
          serverStatus.isChecking = false; // No check is in progress
          serverStatus.lastChecked = Date.now();
          serverStatus.accessStatus = 'disabled_by_setting'; // Custom status for clarity
          // Update UI assuming not connected to game server at this early stage
          updateConnectionStatus(false, null);
        }
      } else {
        // Fallback: if settings somehow aren't loaded, perform the check
        if (application && application.consoleMessage) {
            application.consoleMessage({
              message: '[Startup] Settings not loaded, proceeding with server status check by default.',
              type: 'warn'
            });
        } else {
            console.warn('[Startup] Settings not loaded, proceeding with server status check by default.');
        }
        await checkServerStatus();
      }
    }, 2000); // Delay to allow UI to initialize
  } catch (error) {
    application.consoleMessage({
      message: `Error during initialization: ${error.message}`,
      type: 'error'
    })
    
    console.error('Initialization error details:', error)
  }
}

/**
 * Setup window control buttons (minimize, fullscreen, close).
 */
const setupWindowControls = () => {
  // Minimize button
  const minimizeButton = document.getElementById('minimizeButton');
  if (minimizeButton) {
    minimizeButton.addEventListener('click', () => {
      application.minimize();
    });
  }
  
  // Fullscreen button
  const fullscreenButton = document.getElementById('fullscreenButton');
  if (fullscreenButton) {
    fullscreenButton.addEventListener('click', () => {
      application.toggleMaximize();
    });
    
    // Use more appropriate maximize/restore icons
    const icon = fullscreenButton.querySelector('i');
    if (icon) {
      icon.classList.remove('fa-expand');
      icon.classList.remove('fas');
      icon.classList.add('fa-regular');
      icon.classList.add('fa-window-maximize');
    }
    
    // Update button icon based on maximize state
    ipcRenderer.on('maximize-changed', (event, isMaximized) => {
      const icon = fullscreenButton.querySelector('i');
      if (icon) {
        if (isMaximized) {
          icon.classList.remove('fa-window-maximize');
          icon.classList.add('fa-window-restore');
        } else {
          icon.classList.remove('fa-window-restore');
          icon.classList.add('fa-window-maximize');
        }
      }
    });
  }
  
  // Close button
  const closeButton = document.getElementById('mainCloseButton');
  if (closeButton) {
    closeButton.addEventListener('click', () => {
      application.close();
    });
  }

  // Clear console button
  const clearConsoleButton = document.getElementById('clearConsoleButton');
  if (clearConsoleButton) {
    clearConsoleButton.addEventListener('click', () => {
      clearConsole();
    });
  }
  
  // Clear packet log button
  const clearPacketLogButton = document.getElementById('clearPacketLogButton');
  if (clearPacketLogButton) {
    clearPacketLogButton.addEventListener('click', () => {
      clearPacketLog();
    });
  }
};

/**
 * Clears the console logs.
 */
const clearConsole = () => {
  // Find and clear the message containers
  const $mainLogContainer = $('#messages');
  const $packetLogContainer = $('#packetMessages');
  
  // Clear both message containers
  if ($mainLogContainer.length) {
    $mainLogContainer.empty();
  }
  
  if ($packetLogContainer.length) {
    $packetLogContainer.empty();
  }
  
  // Reset message counters (if application is available)
  if (application) {
    application._packetLogCount = 0;
    application._appMessageCount = 0;
    
    // Display confirmation
    application.consoleMessage({
      type: 'notify',
      message: 'Console logs cleared'
    });
  }
};

/**
 * Clears the packet logs.
 */
const clearPacketLog = () => {
  // Clear the message log
  const $messageLog = $('#message-log');
  if ($messageLog.length) {
    $messageLog.empty();
  }
  
  // Reset counters
  $('#incomingCount, #outgoingCount, #totalCount').text('0');
  
  // Display confirmation
  if (application) {
    application.consoleMessage({
      type: 'notify',
      message: 'Packet logs cleared'
    });
  }
};

/**
 * Setup monitoring for connection status changes.
 */
const setupConnectionMonitoring = () => {
  // Check for connection changes periodically
  setInterval(() => {
    const isConnected = application.server && 
                        application.server.clients && 
                        application.server.clients.size > 0
    if (application.dispatch) {
      application.dispatch.setState('connected', isConnected);
    }
    updateConnectionStatus(isConnected)
    updateTimestamp()
    checkEmptyPluginList()
  }, 1000) // Check every second

  // Listen for connection change events from the application
  if (application) {
    application.on('connection:change', (isConnected) => {
      // Broadcast this change to all plugin windows
      if (typeof require === 'function') {
        try {
          const { ipcRenderer } = require('electron');
          ipcRenderer.send('broadcast-to-plugins', 'connection-status-changed', isConnected);
        } catch (e) {
          console.error('[Renderer] Could not broadcast connection status change to plugins.', e);
        }
      }
    });
  }
  
  // Listen for client connect events
  if (application.server) {
    const originalOnConnection = application.server._onConnection
    application.server._onConnection = async function(connection) {
      await originalOnConnection.call(this, connection)
      updateConnectionStatus(true)
      application.consoleMessage({
        message: 'Connected to Animal Jam servers.',
        type: 'success'
      })
    }
  }
}

/**
 * Update the timestamp display in the footer to show session time and game time.
 */
const updateTimestamp = async () => {
  const timestampDisplay = document.getElementById('timestamp-display');
  if (timestampDisplay && sessionStartTime) {
    const now = new Date();
    const sessionDuration = now - sessionStartTime;
    
    const totalUptime = await ipcRenderer.invoke('get-total-uptime');
    const combinedUptime = totalUptime * 1000 + sessionDuration;

    const hours = Math.floor(combinedUptime / (1000 * 60 * 60));
    const minutes = Math.floor((combinedUptime % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((combinedUptime % (1000 * 60)) / 1000);

    const formattedUptime = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;

    try {
      const totalGameTime = await ipcRenderer.invoke('get-total-game-time');
      const gameTimeHours = Math.floor(totalGameTime / 3600);
      const gameTimeMinutes = Math.floor((totalGameTime % 3600) / 60);
      const formattedGameTime = `${gameTimeHours}h ${gameTimeMinutes}m`;

      timestampDisplay.textContent = `Uptime: ${formattedUptime} | Game Time: ${formattedGameTime}`;
    } catch (error) {
      // Fallback if game time is not available
      timestampDisplay.textContent = `Uptime: ${formattedUptime}`;
    }
  }
};

/**
 * Check if the plugin list is empty and toggle the empty state message.
 */
const checkEmptyPluginList = () => {
  const pluginList = document.getElementById('pluginList')
  const emptyPluginMessage = document.getElementById('emptyPluginMessage')
  
  if (pluginList && emptyPluginMessage) {
    // Get plugin items while ignoring empty text nodes
    const hasPlugins = Array.from(pluginList.children)
      .some(child => child.nodeType !== 3 && child.textContent.trim() !== '')
    
    emptyPluginMessage.classList.toggle('hidden', hasPlugins)
  }
}

const setupIpcEvents = () => {
  ipcRenderer
    .on('message', (sender, args) => application.consoleMessage({ ...args }))
}

const setupAppEvents = () => {
  application
    .on('ready', () => application.activateAutoComplete())
    .on('refresh:plugins', () => {
      application.refreshAutoComplete()
      application.attachNetworkingEvents()
      
      // Handle refresh animation completion
      setTimeout(() => {
        const pluginsSectionContent = document.getElementById("pluginsSectionContent");
        const pluginList = document.getElementById("pluginList");
        const refreshIcon = document.querySelector("#refreshPluginsSection i");
        
        if (pluginsSectionContent && pluginList && refreshIcon) {
          // Stop refresh animations
          pluginsSectionContent.classList.remove("plugins-refreshing", "refresh-shimmer");
          refreshIcon.classList.remove("refresh-spinning");
          
          // Re-enable the refresh button
          const refreshButton = document.getElementById("refreshPluginsSection");
          if (refreshButton) {
            refreshButton.disabled = false;
          }
          
          // Animate new plugins in with staggered effect
          const newPlugins = pluginList.querySelectorAll("li");
          newPlugins.forEach((plugin, index) => {
            plugin.classList.add("refreshing-fade-in");
            plugin.style.animationDelay = `${index * 75}ms`;
            
            // Clean up animation classes after animation completes
            setTimeout(() => {
              plugin.classList.remove("refreshing-fade-in");
              plugin.style.animationDelay = "";
            }, 500 + (index * 75));
          });
        }
      }, 100); // Small delay to ensure plugins are rendered
    })
}

// Set context for renderer logs
logManager.setContext('renderer-main');

// Store original console methods
const originalConsole = {
  log: console.log,
  error: console.error,
  warn: console.warn
};

// Override console methods with LogManager
console.log = (message) => {
  const formattedMessage = typeof message === 'object'
    ? JSON.stringify(message)
    : message

  // Send to application console UI
  application.consoleMessage({
    type: 'logger',
    message: formattedMessage
  })
  
  // Also log to LogManager
  logManager.info(formattedMessage);
}

console.error = (message) => {
  const formattedMessage = typeof message === 'object'
    ? JSON.stringify(message)
    : message

  // Send to application console UI
  application.consoleMessage({
    type: 'error',
    message: formattedMessage
  })
  
  // Also log to LogManager
  logManager.error(formattedMessage);
}

console.warn = (message) => {
  const formattedMessage = typeof message === 'object'
    ? JSON.stringify(message)
    : message

  // Send to application console UI
  application.consoleMessage({
    type: 'warn',
    message: formattedMessage
  })
  
  // Also log to LogManager
  logManager.warn(formattedMessage);
}

initializeApp()
setupIpcEvents()
setupAppEvents()

// --- Fetch and Display App Version ---
const displayAppVersion = async () => {
  try {
    const version = await ipcRenderer.invoke('get-app-version');
    const versionDisplayElement = document.getElementById('appVersionDisplay');
    if (versionDisplayElement) {
      // Prepend "Strawberry Jam v" to the version number
      versionDisplayElement.textContent = `Strawberry Jam v${version}`;
    } else {
      console.error('Could not find element with ID appVersionDisplay');
    }
  } catch (error) {
    console.error('Error fetching app version:', error);
    // Optionally display an error or default text
    const versionDisplayElement = document.getElementById('appVersionDisplay');
    if (versionDisplayElement) {
      versionDisplayElement.textContent = 'Strawberry Jam v?.?.?'; // Default/error text
    }
  }
};
displayAppVersion(); // Call the function to display the version on load
// --- End Fetch and Display App Version ---

window.jam = {
  application,
  dispatch: application.dispatch,
  settings: application.settings,
  server: application.server,
  ipcRenderer
}

function openTab(tabId) {
  if (tabId === 'packet-logging') {
    $('#commandContainer').fadeOut(150, function() {
      $('#searchContainer').fadeIn(150);
      setTimeout(applyFilter, 0);
    });
  } else {
    $('#searchContainer').fadeOut(150, function() {
      $('#commandContainer').fadeIn(150);
    });
  }

  // Get the current active tab content
  const $currentActive = $('.tab-content.active');
  const $newActive = $(`#${tabId}`);
  
  // Don't animate if it's already active
  if ($currentActive.attr('id') === $newActive.attr('id')) {
    return;
  }
  
  // Update tab buttons immediately
  $('.tab-button').removeClass('active');
  const $activeTab = $(`.tab-button[data-tab="${tabId}"]`).addClass('active');
  
  // Reset all indicators, then style the active one with theme color
  $('.active-indicator').css({
    'transform': 'scaleX(0)',
    'background-color': '',
    'box-shadow': '',
    'transition': 'transform 0.3s ease-out, background-color 0.3s ease, box-shadow 0.3s ease'
  });
  
  // Get current theme color and apply to the active tab indicator
  const themeColor = $('body').css('--theme-primary') || '#e83d52';
  $activeTab.find('.active-indicator').css({
    'transform': 'scaleX(1)',
    'background-color': themeColor,
    'box-shadow': `0 0 6px 0 ${themeColor}`,
    'transition': 'transform 0.3s ease-out, background-color 0.3s ease, box-shadow 0.3s ease'
  });
  
  // Animate tab content transition
  $currentActive.css({
    'opacity': '1',
    'transform': 'translateY(0)',
    'transition': 'opacity 0.25s ease-out, transform 0.25s ease-out'
  });
  
  setTimeout(() => {
    $currentActive.css({
      'opacity': '0',
      'transform': 'translateY(10px)'
    });
    
    // Hide current content after fade out and prep new content for fade in
    setTimeout(() => {
      $currentActive.removeClass('active').addClass('hidden');
      
      // Show and fade in new content
      $newActive.removeClass('hidden').addClass('active').css({
        'opacity': '0',
        'transform': 'translateY(-10px)',
        'transition': 'opacity 0.25s ease-out, transform 0.25s ease-out'
      });
      
      // Start animation after a tiny delay to ensure CSS is applied
      setTimeout(() => {
        $newActive.css({
          'opacity': '1',
          'transform': 'translateY(0)'
        });
        
        // Reapply tooltips after tab change to ensure they work properly
        if (application && typeof application._applyTooltips === 'function') {
          setTimeout(() => application._applyTooltips(), 300);
        }
      }, 10);
    }, 200);
  }, 10);
}

/**
 * Register application-specific commands.
 * @param {Application} app - The application instance
 */
const registerAppCommands = (app) => {
  // ... existing commands ...
  
  // Add server status check command
  if (app.dispatch && typeof app.dispatch.onCommand === 'function') {
    app.dispatch.onCommand({
      name: 'servers',
      callback: async (commandData) => { // Assuming callback receives an object like { parameters: args }
        const args = commandData.parameters || (Array.isArray(commandData) ? commandData : []);
        app.consoleMessage({
          type: 'notify',
          message: 'Checking Animal Jam server status...'
        });
        
        const isOnline = await checkServerStatus();
        return true; // Command handled
      },
      description: 'Check if Animal Jam servers are online and display status information'
      // Add other properties like 'permission' if your onCommand handler supports them
    });

    // Add end command to kill AJ Classic processes
    app.dispatch.onCommand({
      name: 'end',
      callback: async (commandData) => {
        try {
          app.consoleMessage({
            type: 'notify',
            message: 'Ending AJ Classic processes...'
          });

          // Send IPC message to main process to handle process termination
          const { ipcRenderer } = require('electron');
          const result = await ipcRenderer.invoke('end-aj-classic-processes');
          
          if (result.success) {
            app.consoleMessage({
              type: 'success',
              message: `Successfully ended ${result.processCount} AJ Classic processes`
            });
          } else {
            app.consoleMessage({
              type: 'error',
              message: `Failed to end processes: ${result.error}`
            });
          }
        } catch (error) {
          app.consoleMessage({
            type: 'error',
            message: `Error ending processes: ${error.message}`
          });
        }
        return true; // Command handled
      },
      description: 'Ends all AJ Classic.exe processes'
    });
  } else if (typeof app.registerConsoleCommand === 'function') {
    // Fallback to old method if app.dispatch.onCommand is not found (for safety, though we expect it)
    app.registerConsoleCommand(
      'servers',
      async (args) => {
        app.consoleMessage({
          type: 'notify',
          message: 'Checking Animal Jam server status...'
        });
        
        const isOnline = await checkServerStatus();
        return true; // Command handled
      },
      'Check if Animal Jam servers are online and display status information'
    );
  }
}
