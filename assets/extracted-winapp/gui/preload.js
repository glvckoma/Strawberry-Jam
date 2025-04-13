"use strict";

const { ipcRenderer, contextBridge } = require("electron");
const { v4: uuidv4 } = require('uuid'); // Import uuid v4

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
  // App State channels
  .add("get-app-state")
  .add("set-app-state")
  // Tester channels (Renderer -> Main)
  .add("tester-load-accounts")
  .add("tester-save-works")
  .add("tester-save-does-not-work")
  .add("tester-get-last-path")
  .add("tester-set-last-path")
  .add("tester-select-save-path") // Added
  .add("tester-get-save-path")    // Added
  .add("tester-set-save-path")   // Added
  .add("tester-reload-list-request") // Added for reload
  .add("tester-set-debug-mode") // Added for debug toggle
  .add("tester-get-debug-mode") // Added for debug toggle
  .add("tester-set-actual-login-mode") // Added for actual login toggle
  .add("tester-get-actual-login-mode") // Added for actual login toggle
  .add("tester-set-disable-devtools-mode") // Added for disable devtools toggle
  .add("tester-get-disable-devtools-mode")
  .add("tester-cleanup-processed") // Added for cleanup functionality
  .add("tester-load-specific-file") // Added for auto-load on startup
  .add("tester-set-delay") // ADDED: for delay persistence
  .add("tester-get-delays") // ADDED: for delay persistence
  // Specific file load channels for swap buttons
  .add("tester-load-all-accounts")
  .add("tester-load-confirmed-accounts")
  .add("tester-load-works-accounts");

// main -> renderer
const receiveWhitelist = new Set()
  .add("autoUpdateStatus")
  .add("log")
  .add("loginInfoLoaded")
  .add("postSystemData")
  .add("obtainedToken")
  .add("screenChange")
  .add("signupCompleted")
  .add("toggleDevTools")
  .add("translate")
  // Tester channels (Main -> Renderer)
  .add("tester-accounts-loaded")
  .add("tester-last-path-result")
  .add("tester-trigger-works")
  .add("tester-trigger-does-not-work")
  .add("tester-save-path-result") // Added
  .add("tester-auto-load-result") // Added for auto-load
  .add("tester-reload-list-result") // Added for reload
  .add("tester-debug-mode-loaded") // Added for debug toggle
  .add("tester-actual-login-mode-loaded") // Added for actual login toggle
  .add("tester-disable-devtools-mode-loaded")
  .add("tester-main-ready") // Added for initialization sequence
  .add("tester-specific-file-loaded") // Added for auto-load response
  .add("tester-delays-loaded"); // ADDED: for delay persistence

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
    off: (channel, listener) => {
      if (receiveWhitelist.has(channel)) {
        ipcRenderer.removeListener(channel, listener);
      }
    },
    invoke: (channel, ...args) => {
      if (sendWhitelist.has(channel)) {
        return ipcRenderer.invoke(channel, ...args);
      }
      return Promise.reject(new Error(`Invoke to channel '${channel}' is not allowed`));
    },
    // --- Expose Session User Agent Setter ---
    setUserAgent: (userAgent) => ipcRenderer.invoke('set-user-agent', userAgent),
    // --- End Session User Agent Setter ---
    // --- Expose UUID ---
    uuidv4: () => uuidv4() // Expose the uuidv4 function
  }
);

ipcRenderer.on("redirect-url", (event, url) => {
  console.log("REDIRECT");
});
