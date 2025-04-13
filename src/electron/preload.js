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

console.log('[Preload] Main application preload script executed (contextIsolation: false).'); // Added note

// Expose jam.onPacket for UI plugins to receive live packet events
try {
  const { ipcRenderer } = require('electron');
  console.log("[Preload] Setting up window.jam.onPacket...");
  
  // Ensure window.jam exists
  window.jam = window.jam || {};

  // Define onPacket function, only if it doesn't exist
  if (!window.jam.onPacket) {
    window.jam.onPacket = function (callback) {
      // console.log("[Preload] jam.onPacket called with callback:", typeof callback); // Removed log
      if (typeof callback !== 'function') {
        console.error("[Preload] Invalid callback provided to jam.onPacket");
        return;
      }

      // console.log("[Preload] Subscribing to packet-event"); // Removed log
      ipcRenderer.on('packet-event', (event, packetData) => {
        // console.log("[Preload] Received packet-event, forwarding to callback"); // Keep commented unless needed
        try {
          callback(packetData);
        } catch (err) {
          console.error("[Preload] Error in packet callback:", err);
        }
      });
    }; // End of function assignment
    // console.log("[Preload] Successfully set up window.jam.onPacket"); // Removed log
  } else {
    // console.log("[Preload] window.jam.onPacket already exists, skipping setup."); // Removed log
  }
} catch (e) {
  console.error("[Preload] Error setting up window.jam.onPacket:", e);
}
