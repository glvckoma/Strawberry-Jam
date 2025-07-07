"use strict";

const { ipcRenderer, contextBridge } = require("electron");
const { v4: uuidv4 } = require('uuid'); // Import uuid v4
const fs = require('fs');
const path = require('path');
const osModule = require('os'); // Renamed for clarity and to get a direct reference
const getHomeDirFunction = osModule.homedir; // Get a direct reference to the homedir function

let mainLogPathReceived = null;

// renderer -> main
const sendWhitelist = new Set()
  .add("about")
  .add("clearAuthToken")
  .add("clearRefreshToken")
  .add("keyEvent")
  .add("loaded")
  .add("loginSucceeded")
  .add("openExternal")
  .add("ready")
  .add("rememberMeStateUpdated")
  .add("systemCommand")
  .add("translate")
  // Settings channels
  .add("get-setting")        // Added for settings access
  .add("set-setting")        // Added for settings access
  // App State channels
  .add("get-app-state")
  .add("set-app-state")
  .add("get-df") // ADDED: Allow renderer to request current DF
  .add("toggle-uuid-spoofing") // ADDED: For UUID activation dialog
  .add("winReady") // Used to signal the window is ready
  .add("refresh-df") // ADDED: For refreshing UUID on login
  // Account Management Channels
  .add('get-saved-accounts')
  .add('save-account')
  .add('delete-account')
  .add('toggle-pin-account')
  .add('open-user-cache-file')
  .add('request-main-log-path') // CHANGED: For send/on pattern
  .add('exit-confirmation-response'); // ADDED: For exit confirmation modal

// main -> renderer
const receiveWhitelist = new Set()
  .add("set-main-log-path") // Original channel, can be kept or removed if not used elsewhere
  .add("response-main-log-path") // ADDED: For send/on pattern reply
  .add("autoUpdateStatus")
  .add("log")
  .add("loginInfoLoaded")
  .add("postSystemData")
  .add("obtainedToken")
  .add("screenChange")
  .add("signupCompleted")
  .add("toggleDevTools")
  .add("translate")
  .add("request-toggle-game-client-devtools") // Added for game client devtools
  .add("show-exit-confirmation"); // ADDED: For exit confirmation modal

  // allow renderer process to safely communicate with main process
contextBridge.exposeInMainWorld(
  "ipc", {
    send: (channel, ...args) => {
      if (sendWhitelist.has(channel)) {
        ipcRenderer.send(channel, ...args);
      }
    },
    on: (channel, listener) => {
      if (receiveWhitelist.has(channel)) {
        ipcRenderer.on(channel, listener);
      }
    },
    once: (channel, listener) => { // ADDED: Expose ipcRenderer.once
      if (receiveWhitelist.has(channel)) {
        ipcRenderer.once(channel, listener);
      }
    },
    off: (channel, listener) => {
      if (receiveWhitelist.has(channel)) {
        ipcRenderer.removeListener(channel, listener);
      }
    },
    invoke: (channel, ...args) => { // Restoring the invoke function
      if (sendWhitelist.has(channel)) {
        return ipcRenderer.invoke(channel, ...args);
      }
      // This will correctly reject an attempt to INVOKE 'get-main-log-path'
      // as 'get-main-log-path' is (and should remain) NOT in sendWhitelist for invoke.
      // We use send/on for 'request-main-log-path' / 'response-main-log-path'.
      return Promise.reject(new Error(`Invoke to channel '${channel}' is not allowed via this preload's invoke whitelist.`));
    },
    // --- Expose Session User Agent Setter ---
    setUserAgent: (userAgent) => ipcRenderer.invoke('set-user-agent', userAgent),
    // --- End Session User Agent Setter ---
    // --- Expose Settings Handlers ---
    getSetting: (key) => ipcRenderer.invoke('get-setting', key),
    setSetting: (key, value) => ipcRenderer.invoke('set-setting', key, value),
    // --- End Settings Handlers ---
    // --- Expose DF Handler ---
    getDf: () => ipcRenderer.invoke('get-df'),
    refreshDf: () => ipcRenderer.invoke('refresh-df'), // ADDED: Refresh DF function
    // --- End DF Handler ---
    // --- Expose UUID ---
    uuidv4: () => uuidv4(), // Expose the uuidv4 function
    // --- Expose fs and path for direct log saving ---
    electronFs: {
      writeFileSync: (filePath, data, encoding) => fs.writeFileSync(filePath, data, encoding),
      readdirSync: (dirPath) => fs.readdirSync(dirPath),
      unlinkSync: (filePath) => fs.unlinkSync(filePath)
    },
    electronPath: {
      join: (...paths) => path.join(...paths)
    },
    getMainLogPath: () => mainLogPathReceived, // This will no longer be used by LoginScreen for this feature
    electronOs: { // Expose os.homedir()
      homedir: () => getHomeDirFunction() // Call the direct function reference
    }
  }
);

// Listen for the main log path from the main host application
// This listener is in the preload script of winapp.asar's renderer process.
// It's intended to receive a message from the main host application's main process.
ipcRenderer.on('set-main-log-path', (event, receivedPath) => {
  if (typeof console !== 'undefined' && console.log) { // Ensure console is available
    console.log(`[winapp-preload] Received main log path: ${receivedPath}`);
  }
  mainLogPathReceived = receivedPath;
});

ipcRenderer.on("redirect-url", (event, url) => {
  if (typeof console !== 'undefined' && console.log) {
    console.log("REDIRECT");
  }
});

// Listen for the message from main process to open game webview devtools
ipcRenderer.on('open-game-devtools', () => {
  try {
    // Assuming the webview in GameScreen.js has id="flash-game-webview"
    const gameWebview = document.getElementById('flash-game-webview');
    if (gameWebview && typeof gameWebview.openDevTools === 'function') {
      gameWebview.openDevTools();
      console.log('[winapp-preload] Opened dev tools for game webview.');
    } else if (gameWebview) {
      console.warn('[winapp-preload] gameWebview found, but openDevTools is not a function. Is it a proper webview tag?');
    } else {
      console.warn('[winapp-preload] Game webview with ID "flash-game-webview" not found.');
    }
  } catch (err) {
    console.error('[winapp-preload] Error opening game webview dev tools:', err);
  }
});
