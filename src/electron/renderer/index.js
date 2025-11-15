const Application = require('./application')
const { ipcRenderer } = require('electron')
const logManager = require('../../utils/LogManagerPreload')
const ConnectionStatusManager = require('../../managers/connection/ConnectionStatusManager')
const WindowControlsManager = require('../../ui/managers/WindowControlsManager')
const AppInitializer = require('../../managers/app/AppInitializer')
const CommandRegistrar = require('../../managers/command/CommandRegistrar')
const TabManager = require('../../ui/managers/TabManager')
const TimestampUpdater = require('../../ui/managers/TimestampUpdater')
const PluginListChecker = require('../../ui/managers/PluginListChecker')

const application = new Application()

const connectionStatusManager = new ConnectionStatusManager(application, ipcRenderer)
const windowControlsManager = new WindowControlsManager(application, ipcRenderer)
const appInitializer = new AppInitializer(application, ipcRenderer)
const commandRegistrar = new CommandRegistrar(ipcRenderer)
const tabManager = new TabManager(application)
const timestampUpdater = new TimestampUpdater(ipcRenderer)
const pluginListChecker = new PluginListChecker()


document.addEventListener('DOMContentLoaded', () => {
  connectionStatusManager.setCheckingState(true)
  connectionStatusManager.updateConnectionStatus(false)

  // Copy Packet Logs functionality
  const copyPacketLogsButton = document.getElementById('copyPacketLogsButton');
  const messageLog = document.getElementById('message-log');

  if (copyPacketLogsButton && messageLog) {
    copyPacketLogsButton.addEventListener('click', async () => {
      const originalButtonText = copyPacketLogsButton.innerHTML;
      const originalButtonClasses = copyPacketLogsButton.className;

      try {
        let logsToCopy = [];
        // Only consider top-level packet entries (direct children)
        const allEntries = messageLog.querySelectorAll(':scope > div');

        // Only include entries that are currently visible (not filtered out)
        const logEntries = Array.from(allEntries).filter(entry => {
          const style = window.getComputedStyle(entry);
          const isHidden = style.display === 'none' || style.visibility === 'hidden' || entry.classList.contains('hidden');
          return !isHidden;
        });

        logEntries.forEach(entry => {
          const isIncoming = entry.querySelector('.fa-arrow-down');
          const isOutgoing = entry.querySelector('.fa-arrow-up');
          // Packet text is inside the second child div (message container)
          const messageContainer = entry.querySelector(':scope > div:nth-child(2)');
          const logText = (messageContainer ? messageContainer.textContent : entry.textContent).trim();

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

const sessionStartTimeRef = { current: null }

const initializeApp = async () => {
  await appInitializer.initializeApp({
    sessionStartTimeRef,
    setupWindowControls: () => windowControlsManager.setupWindowControls(),
    setupConnectionMonitoring: () => connectionStatusManager.setupConnectionMonitoring(
      () => timestampUpdater.updateTimestamp(sessionStartTimeRef.current),
      () => pluginListChecker.checkEmptyPluginList()
    ),
    registerAppCommands: (app) => commandRegistrar.registerAppCommands(app, () => connectionStatusManager.checkServerStatus()),
    checkServerStatus: () => connectionStatusManager.checkServerStatus(),
    connectionStatusManager
  })
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
      versionDisplayElement.textContent = `v${version}`;
    } else {
      console.error('Could not find element with ID appVersionDisplay');
    }
  } catch (error) {
    console.error('Error fetching app version:', error);
    const versionDisplayElement = document.getElementById('appVersionDisplay');
    if (versionDisplayElement) {
      versionDisplayElement.textContent = 'v?.?.?';
    }
  }
};
displayAppVersion();
// --- End Fetch and Display App Version ---

window.jam = {
  application,
  dispatch: application.dispatch,
  settings: application.settings,
  server: application.server,
  ipcRenderer
}

window.openTab = (tabId) => {
  tabManager.openTab(tabId)
}
