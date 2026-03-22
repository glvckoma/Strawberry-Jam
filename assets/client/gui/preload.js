"use strict";

const { ipcRenderer, contextBridge } = require("electron");
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');
const osModule = require('os');
const getHomeDirFunction = osModule.homedir;

let mainLogPathReceived = null;

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
  .add("get-setting")
  .add("set-setting")
  .add("get-api-port")
  .add("get-server-port")
  .add("terminate-port")
  .add("get-app-state")
  .add("set-app-state")
  .add("get-df")
  .add("toggle-uuid-spoofing")
  .add("winReady")
  .add("refresh-df")
  .add('get-saved-accounts')
  .add('get-account-tokens')
  .add('save-account')
  .add('delete-account')
  .add('toggle-pin-account')
  .add('open-user-cache-file')
  .add('import-accounts')
  .add('delete-all-accounts')
  .add('request-main-log-path')
  .add('exit-confirmation-response')
  .add('open-devtools-both')
  .add('game-webview-console-error');

const receiveWhitelist = new Set()
  .add("set-main-log-path")
  .add("response-main-log-path")
  .add("autoUpdateStatus")
  .add("log")
  .add("loginInfoLoaded")
  .add("postSystemData")
  .add("obtainedToken")
  .add("screenChange")
  .add("signupCompleted")
  .add("toggleDevTools")
  .add("translate")
  .add("request-toggle-game-client-devtools")
  .add("show-exit-confirmation")
  .add("game-webview-console-error")
  .add("port-error");

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
    once: (channel, listener) => {
      if (receiveWhitelist.has(channel)) {
        ipcRenderer.once(channel, listener);
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
      return Promise.reject(new Error(`Invoke to channel '${channel}' is not allowed via this preload's invoke whitelist.`));
    },
    setUserAgent: (userAgent) => ipcRenderer.invoke('set-user-agent', userAgent),
    getSetting: (key) => ipcRenderer.invoke('get-setting', key),
    setSetting: (key, value) => ipcRenderer.invoke('set-setting', key, value),
    getDf: () => ipcRenderer.invoke('get-df'),
    refreshDf: () => ipcRenderer.invoke('refresh-df'),
    uuidv4: () => uuidv4(),
    electronFs: {
      writeFileSync: (filePath, data, encoding) => fs.writeFileSync(filePath, data, encoding),
      readdirSync: (dirPath) => fs.readdirSync(dirPath),
      unlinkSync: (filePath) => fs.unlinkSync(filePath)
    },
    electronPath: {
      join: (...paths) => path.join(...paths)
    },
    getMainLogPath: () => mainLogPathReceived,
    electronOs: {
      homedir: () => getHomeDirFunction()
    }
  }
);

ipcRenderer.on('set-main-log-path', (event, receivedPath) => {
  if (typeof console !== 'undefined' && console.log) {
    console.log(`[winapp-preload] Received main log path: ${receivedPath}`);
  }
  mainLogPathReceived = receivedPath;
});

ipcRenderer.on("redirect-url", (event, url) => {
  if (typeof console !== 'undefined' && console.log) {
    console.log("REDIRECT");
  }
});

ipcRenderer.on('open-game-devtools', () => {
  try {
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
