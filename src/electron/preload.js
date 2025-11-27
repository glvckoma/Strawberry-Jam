const __init__ = async () => {
  const isPluginPage = window.location.pathname.includes('plugins')

  const cssPath = 'app://assets/css/style.css'

  const link = document.createElement('link')
  link.setAttribute('rel', 'stylesheet')
  link.setAttribute('href', cssPath)

  document.head.appendChild(link)

  if (isPluginPage) {
    window.jQuery = window.$ = require('jquery')
  }
}

window.__init__ = __init__

document.addEventListener('DOMContentLoaded', window.__init__)

// Expose jam.onPacket for UI plugins to receive live packet events
try {
  const { ipcRenderer } = require('electron');
  
  // Ensure window.jam exists
  window.jam = window.jam || {};

  // Define onPacket function, only if it doesn't exist
  if (!window.jam.onPacket) {
    window.jam.onPacket = function (callback) {
      if (typeof callback !== 'function') {
        console.error("[Preload] Invalid callback provided to jam.onPacket");
        return function unsubscribe() {}; // Return no-op unsubscribe
      }

      const listener = (event, packetData) => {
        try {
          // Simply forward the packet data to the registered callback
          callback(packetData);
        } catch (err) {
          console.error("[Preload] Error in packet callback:", err);
        }
      };
      
      ipcRenderer.on('packet-event', listener);
      
      // Return an unsubscribe function
      return function unsubscribe() {
        try {
          ipcRenderer.removeListener('packet-event', listener);
        } catch (e) {
           console.error("[Preload] Error removing packet-event listener:", e);
        }
      };
    };
  }
} catch (e) {
  console.error("[Preload] Error setting up window.jam.onPacket:", e);
}

// Expose room tracking utilities needed by plugins
try {
  const roomUtils = require('../utils/room-tracking'); // Adjust path relative to preload.js

  // Ensure window.jam exists
  window.jam = window.jam || {};

  // Expose all room utility functions
  window.jam.roomUtils = {
    getEffectiveRoomId: roomUtils.getEffectiveRoomId,
    isAdventureRoom: roomUtils.isAdventureRoom,
    processRoomInPacket: roomUtils.processRoomInPacket,
    parseRoomPacket: roomUtils.parseRoomPacket,
    updateRoomStateFromPacket: roomUtils.updateRoomStateFromPacket
  };
} catch (e) {
  console.error("[Preload] Error setting up window.jam.roomUtils:", e);
}

// Expose room state management utilities
try {
  const { RoomState } = require('../utils/room-state');
  
  // Ensure window.jam exists
  window.jam = window.jam || {};
  
  // Create instance of RoomState
  // Note: This will work without the dispatch, but will be initialized properly
  // when dispatch becomes available
  window.jam.roomState = new RoomState();
} catch (e) {
  console.error("[Preload] Error setting up window.jam.roomState:", e);
}

// Expose IS_DEV flag
try {
  // In Electron's renderer process (with nodeIntegration: true and contextIsolation: false),
  // process.env should be available if set in the main process.
  // However, to be more robust, especially if NODE_ENV isn't explicitly passed,
  // we can ask the main process for it or rely on a flag set by the main process.
  // For now, let's assume NODE_ENV is accessible or we can use a simplified check.
  // A more robust way would be ipcRenderer.invoke('get-is-development') if main process exposed it.
  // Given the current structure, we'll try to infer it.
  // The main process sets `isDevelopment` based on `process.env.NODE_ENV`.
  // We'll try to access `process.env.NODE_ENV` here.
  // If `process` is not available, this will error, and we default to false.
  const nodeEnv = typeof process !== 'undefined' && process.env && process.env.NODE_ENV;
  window.IS_DEV = nodeEnv === 'development';
} catch (e) {
  console.error("[Preload] Error setting up IS_DEV global variable:", e);
  window.IS_DEV = false; // Default to false on error
}

// Expose a limited dispatch interface for UI plugins
try {
  const { ipcRenderer } = require('electron');

  window.jam = window.jam || {};
  window.jam.dispatch = window.jam.dispatch || {};

  // Expose sendRemoteMessage
  if (!window.jam.dispatch.sendRemoteMessage) {
    window.jam.dispatch.sendRemoteMessage = function(message, options) {
      try {
        if (options && (options.targetUsername || options.targetClientId)) {
          ipcRenderer.send('send-remote-message', { message, options });
        } else {
          ipcRenderer.send('plugin-remote-message', message);
        }
      } catch (e) {
        console.error("[Preload] Error in jam.dispatch.sendRemoteMessage:", e);
      }
    };
  }

  // Expose getConnectedClients
  if (!window.jam.dispatch.getConnectedClients) {
    window.jam.dispatch.getConnectedClients = async function() {
      try {
        return await ipcRenderer.invoke('dispatch-get-connected-clients');
      } catch (e) {
        console.error("[Preload] Error in jam.dispatch.getConnectedClients:", e);
        return [];
      }
    };
  }

  // Expose sendConnectionMessage
  if (!window.jam.dispatch.sendConnectionMessage) {
    window.jam.dispatch.sendConnectionMessage = function(message) {
      try {
        ipcRenderer.send('plugin-connection-message', message);
      } catch (e) {
        console.error("[Preload] Error in jam.dispatch.sendConnectionMessage:", e);
      }
    };
  }

  // Expose getState (now asynchronous)
  if (!window.jam.dispatch.getState) {
    window.jam.dispatch.getState = async function(key) { // Made async
      try {
        // Using the existing asynchronous handler 'dispatch-get-state'
        return await ipcRenderer.invoke('dispatch-get-state', key); // Changed to invoke
      } catch (e) {
        console.error(`[Preload] Error in jam.dispatch.getState for key '${key}':`, e);
        return null;
      }
    };
  }

  // Expose waitForJQuery
  if (!window.jam.dispatch.waitForJQuery) {
    window.jam.dispatch.waitForJQuery = function (pluginWindow, callback) {
      // Implementation copied from main Dispatch class
      return new Promise((resolve, reject) => {
        const checkInterval = 100;
        const maxRetries = 100;
        let retries = 0;

        const intervalId = setInterval(() => {
          if (typeof pluginWindow.$ !== 'undefined') {
            clearInterval(intervalId);
            try {
              callback();
              resolve();
            } catch (error) {
              reject(error);
            }
          } else if (retries >= maxRetries) {
            clearInterval(intervalId);
            reject(new Error('jQuery was not found within the expected time.'));
          } else {
            retries++;
          }
        }, checkInterval);
      });
    };
  }

  // Expose file system and notification functions
  window.jam.readJsonFile = async function(filePath, defaultValue = null) {
    try {
      return await ipcRenderer.invoke('read-json-file', filePath, defaultValue);
    } catch (e) {
      console.error(`[Preload] Error reading JSON file '${filePath}':`, e);
      return defaultValue;
    }
  };

  window.jam.writeJsonFile = async function(filePath, data) {
    try {
      return await ipcRenderer.invoke('write-json-file', filePath, data);
    } catch (e) {
      console.error(`[Preload] Error writing JSON file '${filePath}':`, e);
      return false;
    }
  };

  window.jam.showToast = function(message, type = 'info') {
    try {
      ipcRenderer.send('show-toast', { message, type });
    } catch (e) {
      console.error(`[Preload] Error showing toast:`, e);
    }
  };
} catch (e) {
  console.error("[Preload] Error setting up window.jam.dispatch for UI plugins:", e);
}
