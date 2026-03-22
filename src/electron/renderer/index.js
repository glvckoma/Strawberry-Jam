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

  const copyPacketLogsButton = document.getElementById('copyPacketLogsButton')
  const messageLog = document.getElementById('message-log')

  if (copyPacketLogsButton && messageLog) {
    copyPacketLogsButton.addEventListener('click', async () => {
      const originalHTML = copyPacketLogsButton.innerHTML
      const originalClass = copyPacketLogsButton.className

      try {
        const allEntries = messageLog.querySelectorAll(':scope > div')
        const logEntries = Array.from(allEntries).filter(entry => {
          const style = window.getComputedStyle(entry)
          return style.display !== 'none' && style.visibility !== 'hidden' && !entry.classList.contains('hidden')
        })

        const logsToCopy = []
        logEntries.forEach(entry => {
          const isIncoming = entry.querySelector('.fa-arrow-down')
          const isOutgoing = entry.querySelector('.fa-arrow-up')
          const messageContainer = entry.querySelector(':scope > div:nth-child(2)')
          const logText = (messageContainer ? messageContainer.textContent : entry.textContent).trim()

          if (logText) {
            if (isIncoming) logsToCopy.push(`In: ${logText}`)
            else if (isOutgoing) logsToCopy.push(`Out: ${logText}`)
            else logsToCopy.push(logText)
          }
        })

        if (logsToCopy.length > 0) {
          await navigator.clipboard.writeText(logsToCopy.join('\n'))
          copyPacketLogsButton.innerHTML = '<i class="fas fa-check text-sm"></i>'
          copyPacketLogsButton.className = 'text-highlight-green p-1.5 rounded transition-all'
        } else {
          copyPacketLogsButton.innerHTML = '<i class="fas fa-exclamation-triangle text-sm"></i>'
          copyPacketLogsButton.className = 'text-error-red p-1.5 rounded transition-all'
        }
      } catch (err) {
        copyPacketLogsButton.innerHTML = '<i class="fas fa-times text-sm"></i>'
        copyPacketLogsButton.className = 'text-error-red p-1.5 rounded transition-all'
      } finally {
        setTimeout(() => {
          copyPacketLogsButton.innerHTML = originalHTML
          copyPacketLogsButton.className = originalClass
        }, 2000)
      }
    })
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

const startPluginRefreshAnimation = () => {
  const pluginsSectionContent = document.getElementById("pluginsSectionContent");
  const pluginList = document.getElementById("pluginList");
  const refreshButton = document.getElementById("refreshPluginsSection");
  const refreshIcon = refreshButton ? refreshButton.querySelector("i") : null;

  if (!pluginsSectionContent || !pluginList || !refreshButton || !refreshIcon) {
    return;
  }

  refreshButton.disabled = true;
  pluginsSectionContent.classList.add("plugins-refreshing", "refresh-shimmer");
  refreshIcon.classList.add("refresh-spinning");

  const pluginItems = pluginList.querySelectorAll("li");
  pluginItems.forEach((plugin, index) => {
    const cleanup = () => {
      plugin.classList.remove("refreshing-fade-out");
      plugin.style.animationDelay = "";
      plugin.removeEventListener("animationend", cleanup);
    };

    plugin.classList.remove("refreshing-fade-in");
    plugin.style.animationDelay = `${index * 40}ms`;
    plugin.classList.add("refreshing-fade-out");
    plugin.addEventListener("animationend", cleanup);
  });
};

const completePluginRefreshAnimation = () => {
  setTimeout(() => {
    const pluginsSectionContent = document.getElementById("pluginsSectionContent");
    const pluginList = document.getElementById("pluginList");
    const refreshIcon = document.querySelector("#refreshPluginsSection i");
    const refreshButton = document.getElementById("refreshPluginsSection");

    if (!pluginsSectionContent || !pluginList || !refreshIcon || !refreshButton) {
      return;
    }

    pluginsSectionContent.classList.remove("plugins-refreshing", "refresh-shimmer");
    refreshIcon.classList.remove("refresh-spinning");
    refreshButton.disabled = false;

    const newPlugins = pluginList.querySelectorAll("li");
    newPlugins.forEach((plugin, index) => {
      const cleanup = () => {
        plugin.classList.remove("refreshing-fade-in");
        plugin.style.animationDelay = "";
        plugin.removeEventListener("animationend", cleanup);
      };

      plugin.style.animationDelay = `${index * 50}ms`;
      plugin.classList.add("refreshing-fade-in");
      plugin.addEventListener("animationend", cleanup);
    });
  }, 120);
};

const setupAppEvents = () => {
  application
    .on('ready', () => application.activateAutoComplete())
    .on('refresh:plugins:start', () => {
      startPluginRefreshAnimation()
    })
    .on('refresh:plugins', () => {
      application.refreshAutoComplete()
      application.attachNetworkingEvents()
      completePluginRefreshAnimation()
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
