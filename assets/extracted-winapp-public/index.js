"use strict";

const {app, BrowserWindow, clipboard, dialog, ipcMain, Menu, shell, globalShortcut, session} = require("electron"); // Added globalShortcut, session
const {autoUpdater} = require("electron-updater");
const crypto = require("crypto");
const path = require("path");
const Store = require("electron-store");
const {machineId} = require("node-machine-id");
const {v4: uuidv4} = require('uuid');
const os = require("os");
const fs = require("fs"); // Use standard fs for sync operations if needed, promises for async
const fsPromises = fs.promises; // Keep promises version available
// Keytar has been completely removed.
const config = require("./config.js");
const server = require("./server.js");
const translation = require("./translation.js");
const net = require('net');

// All Keytar-related service names and constants have been removed.

// --- Storage Keys ---
const STORE_KEY_UUID_SPOOFER = 'uuid_spoofer_enabled'; // Added for UUID spoofing toggle
const STORE_KEY_SAVED_ACCOUNTS = 'saved_accounts'; // For Account Management
// --- End Storage Keys ---

const AUTO_UPDATE_STARTUP_DELAY_MS = 2000;
const AUTO_UPDATE_PERIODIC_DELAY_MS = 1 * 60 * 60 * 1000; 

let win = null;
// let gameWebviewContentsId = null; // Main process will not directly manage game webview DevTools via ID.

let printWindow = null;
let isClosing = false;

const store = new Store();

// UUID spoofing functionality
let originalMachineId = null;
let spoofedUuid = null;

// Get original machine ID once at startup
(async function() {
  try {
    originalMachineId = await machineId();
    log("debug", `[UUID] Original machine ID retrieved: ${originalMachineId.substr(0, 8)}...`);
  } catch (err) {
    log("error", `[UUID] Failed to get original machine ID: ${err.message}`);
  }
})();

// Function to toggle UUID spoofing
async function toggleUuidSpoofing(enable) {
  let logMsg = enable ? "Enabling" : "Disabling";
  log("info", `[UUID Spoofer] ${logMsg} UUID spoofing`);

  try {
    // Always save the setting first
    store.set(STORE_KEY_UUID_SPOOFER, enable);
    
    if (win) {
      if (enable) {
        // Generate a new random UUID
        const newUuid = uuidv4();
        log("info", `[UUID Spoofer] Generated random UUID: ${newUuid.substr(0, 8)}...`);
        
        // Send the new random UUID to the renderer
        win.webContents.send('update-df', newUuid);
        
        return { success: true, uuid: newUuid };
      } else {
        // When disabling, get the real machine ID and send it to the renderer
        try {
          // Clear the spoofed UUID when disabling
          spoofedUuid = null;
          
          // Get the real machine ID - use the stored original instead of getCurrentMachineId
          // to avoid potential circular reference since getCurrentMachineId() calls this function
          const realId = originalMachineId || await machineId();
          log("info", `[UUID Spoofer] Restoring original machine ID: ${realId.substr(0, 8)}...`);
          
          // Send the actual machine ID to the renderer
          win.webContents.send('update-df', realId);
          
          return { success: true, uuid: realId };
        } catch (idErr) {
          log("error", `[UUID Spoofer] Failed to get actual machine ID: ${idErr}`);
          return { success: false, error: "Failed to get actual machine ID" };
        }
      }
    } else {
      log("error", "[UUID Spoofer] Window not available");
      return { success: false, error: "Window not available" };
    }
  } catch (err) {
    log("error", `[UUID Spoofer] Error toggling UUID spoofing: ${err}`);
    return { success: false, error: err.message || String(err) };
  }
}

// Show confirmation dialog for UUID activation
async function showUuidActivationConfirmation() {
  const uuidEnabled = store.get(STORE_KEY_UUID_SPOOFER, false);
  
  if (uuidEnabled) {
    return true; // Already enabled, no need to confirm
  }
  
  const confirmOptions = {
    type: 'warning',
    title: 'UUID Spoofing Activation',
    message: 'Are you sure you want to enable UUID spoofing?',
    detail: 'This will cause issues with 2FA accounts. This is a safety feature to protect your main accounts unique identifier from being linked to other accounts. This does not affect IP which will still be exposed.',
    buttons: ['Cancel', 'Enable'],
    defaultId: 0,
    cancelId: 0
  };
  
  const result = await dialog.showMessageBox(win, confirmOptions);
  return result.response === 1; // 1 = second button (Enable)
}

// Function to get current machine ID (original or spoofed)
async function getCurrentMachineId() {
  const uuidEnabled = store.get(STORE_KEY_UUID_SPOOFER, false);
  
  if (uuidEnabled && spoofedUuid) {
    log("debug", `[UUID] Using spoofed UUID: ${spoofedUuid.substr(0, 8)}...`);
    return spoofedUuid;
  } else {
    // If spoofing is not enabled or failed, use the original ID
    if (!originalMachineId) {
      try {
        originalMachineId = await machineId();
        log("debug", `[UUID] Retrieved original machine ID: ${originalMachineId.substr(0, 8)}...`);
      } catch (err) {
        log("error", `[UUID] Failed to get machine ID: ${err.message}`);
        const fallbackUuid = uuidv4();
        log("debug", `[UUID] Using fallback random UUID: ${fallbackUuid.substr(0, 8)}...`);
        return fallbackUuid; // Fallback to a random UUID if everything fails
      }
    }
    log("debug", `[UUID] Using original machine ID: ${originalMachineId.substr(0, 8)}...`);
    return originalMachineId;
  }
}

const log = (level, message) => {
  if (win) {
    if (typeof message === "object") {
      message = message.stack || message.error?.stack || JSON.stringify(message); // Improved object logging
    }
    // Always send debug logs if enabled, otherwise respect config.showTools
    // Send 'debug' logs as 'debug', 'debugError' as 'error'
    if (level === 'debug' || level === 'debugError') {
        win.webContents.send("log", {level: level === 'debug' ? 'debug' : 'error', message});
    }
    else {
      if (["info", "warn", "error"].includes(level)) {
        win.webContents.send("log", {level, message});
      }
    }
  }
  else {
    setTimeout(() => {
      log(level, message);
    }, 1000);
  }
};

process.on("uncaughtException", err => {
  log("error", `[App] Uncaught exception: ${err.stack || err.error?.stack || err}`);
  setTimeout(() => {
    process.exit(1);
  }, 100);
});

process.on("unhandledRejection", err => {
  log("error", `[App] Unhandled rejection: ${err.stack || err.error?.stack || err}`);
});

let rcToken = "";
for (let i = 0; i < process.argv.length; i++) {
  if (process.argv[i] == "--rc-token") {
    if (process.argv[++i]) {
      rcToken = crypto.createHash("sha1").update(process.argv[i]).digest("hex");
      break;
    }
  }
}

const pack = require("./package.json");

// clear local save data
if (config.clearStorage) {
  store.clear();
}

let webview = null; // ref to webview within index.html

const setApplicationMenu = () => {
  log("info", "Enabling Dev Menu.");
  Menu.setApplicationMenu(Menu.buildFromTemplate([{
    label: "Development",
    submenu: [{
      label: "Reload",
      accelerator: "CmdOrCtrl+R",
      click: () => {
        if (win && win.webContents && !win.isDestroyed()) {
          win.webContents.reloadIgnoringCache();
        }
      },
    }, {
      label: "Toggle DevTools",
      accelerator: "CmdOrCtrl+Shift+I",
      click: () => {
        if (win && win.webContents && !win.isDestroyed()) {
          if (win.webContents.isDevToolsOpened()) {
            win.webContents.closeDevTools();
          } else {
            win.webContents.openDevTools({ mode: 'detach' });
          }
          log('info', '[DevTools] Toggled for main window.');
          win.webContents.send("toggleDevTools");
        }
      },
    }],
  }]));
};

const loadClient = () => {
  win.loadURL(`file://${__dirname}/gui/index.html`);
};

const updateStatus = {
  state: "idle",
  progress: 0,
};

let autoUpdateTimeoutId = null;

const scheduleAutoUpdate = (delayMs) => {
  log("debug", `Scheduled update check: ${delayMs}ms`);
  if (autoUpdateTimeoutId !== null) {
    clearTimeout(autoUpdateTimeoutId);
  }
  autoUpdateTimeoutId = setTimeout(() => autoUpdater.checkForUpdates(), delayMs);
};

const autoUpdateProgress = (state, progress = null) => {
  updateStatus.state = state;
  updateStatus.progress = progress || null;
  if (win && win.webContents && !win.isDestroyed()) {
    win.webContents.send("autoUpdateStatus", updateStatus);
  }
};

if (!config.noUpdater) {
  scheduleAutoUpdate(AUTO_UPDATE_STARTUP_DELAY_MS);
  autoUpdater.on("error", (error) => {
    log("error", `[AutoUpdate] Error: ${error}`);
    autoUpdateProgress("error");
    scheduleAutoUpdate(AUTO_UPDATE_PERIODIC_DELAY_MS);
  });
  autoUpdater.on("checking-for-update", () => {
    log("info", "[AutoUpdate] Checking for update...");
    autoUpdateProgress("check");
  });
  autoUpdater.on("update-available", () => {
    log("info", "[AutoUpdate] Update available.");
    autoUpdateProgress("download", 1);
  });
  autoUpdater.on("update-not-available", () => {
    log("info", "[AutoUpdate] Update not available.");
    autoUpdateProgress("idle");
    scheduleAutoUpdate(AUTO_UPDATE_PERIODIC_DELAY_MS);
  });
  autoUpdater.on("download-progress", (progress) => {
    log("info", `[AutoUpdate] Download progress: ${progress.percent}%`);
    autoUpdateProgress("download", progress.percent);
  });
  autoUpdater.on("update-downloaded", () => {
    log("info", "[AutoUpdate] Update downloaded, will install on next restart.");
    autoUpdateProgress("restart");
    store.set("app.lastUpdatedAt", new Date().getTime());
  });
}

// communication with renderer
ipcMain.on("loaded", async (event, message) => {
  webview = event.sender;
  const username = store.get("login.username") || "";
  // Default remember me to true
  const rememberMe = store.get("login.rememberMe") !== false;
  let authToken = null;
  let refreshToken = null;

  // Always retrieve tokens for the last user, regardless of rememberMe status.
  // The renderer will decide whether to use them for auto-login.
  if (username) {
    authToken = store.get(`accounts.${username}.authToken`);
    refreshToken = store.get(`accounts.${username}.refreshToken`);
  }

  const df = await getDf();

  if (webview && webview.send) { // Check if webview is still valid
    webview.send("loginInfoLoaded", {
      username,
      authToken,
      refreshToken,
      rememberMe,
      df,
      config,
      rcToken,
    });
  }


  if (Object.keys(store.store).length === 0) {
    log("debug", "Listening for Autologin data.");
    (async () => {
      try {
        const data = await server.listenForAutoLogin();
        log("debug", `Webserver stopped, ${data ? "received data." : "did not receive data."}`);
        if (data) {
          if (data.affiliateCode) {
            store.set("login.affiliateCode", data.affiliateCode);
          }
          if (win && win.webContents && !win.isDestroyed()) {
            win.webContents.send("obtainedToken", {
              token: data.authToken,
            });
          }
        }
      }
      catch (err) {
        log("debugError", JSON.stringify(err));
      }
    })();
  }

  win.on("enter-full-screen", () => {
    setTimeout(() => {
      store.set("window.state", "fullScreen");
      if (webview && webview.send) webview.send("screenChange", "fullScreen");
    }, 1);
  });

  win.on("maximize", () => {
    store.set("window.state", "maximized");
    if (webview && webview.send) webview.send("screenChange", "maximized");
  });

  win.on("unmaximize", () => {
    store.set("window.state", "windowed");
    if (webview && webview.send) webview.send("screenChange", "windowed");
  });

  win.on("leave-full-screen", () => {
    store.set("window.state", "windowed");
    if (webview && webview.send) webview.send("screenChange", "windowed");
  });

  win.on("minimize", () => {
    log("debug", "[Window] Window minimized");
    // Check background processing setting
    const backgroundProcessing = store.get("backgroundProcessing", true); // Default to true
    if (backgroundProcessing) {
      // Disable background throttling to keep game running
      if (win && win.webContents && !win.isDestroyed()) {
        win.webContents.backgroundThrottling = false;
      }
    }
    // Notify webview about minimize state
    if (webview && webview.send) {
      webview.send("screenChange", "minimized");
    }
  });

  win.on("restore", () => {
    log("debug", "[Window] Window restored");
    // Re-enable background throttling (normal behavior)
    if (win && win.webContents && !win.isDestroyed()) {
      win.webContents.backgroundThrottling = true;
    }
    // Notify webview about restore state
    if (webview && webview.send) {
      webview.send("screenChange", "restored");
    }
  });

  win.on("close", (event) => {
    log("debug", `[Exit Confirmation] Window close event triggered. isClosing: ${isClosing}`);
    
    if (isClosing) {
      // Allow close to proceed
      log("info", "[Exit Confirmation] isClosing=true, allowing window to close");
      try {
        const position = win.getPosition();
        store.set("window.x", position[0]);
        store.set("window.y", position[1]);
        log("debug", "[Exit Confirmation] Saved window position");
      } catch (err) {
        log("warn", `[Exit Confirmation] Failed to save window position: ${err.message}`);
      }
      
      // Notify Strawberry Jam that AJ Classic is closing
      notifyStrawberryJamClose();
      log("debug", "[Exit Confirmation] Close notification sent, allowing close to proceed");
      return;
    }
    
    // Prevent default close
    event.preventDefault();
    
    // Check if user has disabled the confirmation
    const skipConfirmation = store.get("ui.skipExitConfirmation", false);
    log("debug", `[Exit Confirmation] Skip confirmation setting: ${skipConfirmation}`);
    
    if (skipConfirmation) {
      log("info", "[Exit Confirmation] Skipping confirmation due to user preference");
      // Close directly without confirmation
      isClosing = true;
      win.close();
      return;
    }
    
    // Show exit confirmation modal
    if (win && win.webContents && !win.isDestroyed()) {
      log("debug", "[Exit Confirmation] Sending show-exit-confirmation to renderer");
      win.webContents.send("show-exit-confirmation");
    } else {
      log("error", "[Exit Confirmation] Cannot send to renderer - window not available");
    }
  });
});

ipcMain.on("loginSucceeded", async (event, message) => {
  log("debug", `[IPC] loginSucceeded received. Saving login data for ${message.username}`);
  server.stop();

  store.set("login.username", message.username);
  store.set("login.language", message.language);
  translation.setLanguage(message.language);
  store.set("login.rememberMe", message.rememberMe);

  // Always store tokens for the account to allow for quick re-login,
  // regardless of the "Remember Me" setting for auto-login.
  store.set(`accounts.${message.username}.authToken`, message.authToken);
  if (message.refreshToken) {
    store.set(`accounts.${message.username}.refreshToken`, message.refreshToken);
  }
});

ipcMain.on("rememberMeStateUpdated", async (event, message) => {
  log('debug', `[IPC] rememberMeStateUpdated received: ${message.newValue}`);
  store.set("login.rememberMe", message.newValue);
});

ipcMain.on("clearAuthToken", async (event, message) => {
  log('debug', '[IPC] clearAuthToken received.');
  store.delete("login.authToken"); 
  const username = store.get("login.username");
  if (username) {
    store.delete(`accounts.${username}.authToken`);
  }
});

ipcMain.on("clearRefreshToken", async (event, message) => {
  log('debug', '[IPC] clearRefreshToken received.');
  store.delete("login.refreshToken"); 
  const username = store.get("login.username");
  if (username) {
    store.delete(`accounts.${username}.refreshToken`);
  }
});

ipcMain.on("about", async (event, message) => {
  if (win) {
    const details = [
      `${translate("version")}: ${pack.version}`,
      `${translate("os")}: ${getOsName()} ${os.arch()} ${os.release()}`,
    ];
    const lastUpdatedAt = store.get("app.lastUpdatedAt");
    if (lastUpdatedAt) {
      details.push(`${translate("lastUpdated")}: ${lastUpdatedAt}`);
    }
    const username = store.get("login.username");
    if (username) {
      details.push(`${translate("username")}: ${username}`);
    }
    const buttons = [translate("copyDetails"), translate("ok")];
    if (updateStatus.state == "restart") {
      details.push(`\n${translate("restartMessage")}`);
      buttons.unshift(translate("restartButton"));
    }
    else if (updateStatus.state == "error") {
      details.push(`\n${translate("updateError")}`);
      buttons.unshift(translate("websiteButton"));
    }
    const returnValue = await dialog.showMessageBox(win, {
      type: "none",
      icon: __dirname + '/gui/images/icon.png',
      title: `${pack.productName}`,
      message: `${pack.productName}`,
      detail: details.join("\n"),
      buttons,
      cancelId: buttons.length - 1,
      defaultId: buttons.length - 1,
    });
    if (updateStatus.state == "restart" && returnValue.response == 0) {
      autoUpdater.quitAndInstall();
    }
    if (updateStatus.state == "error" && returnValue.response == 0) {
      shell.openExternal(config.webClassic);
    }
    else if (returnValue.response == buttons.length - 2) {
      clipboard.writeText(details.join("\n"));
    }
  }
});

const getOsName = () => {
  switch (os.platform()) {
    case "win32": return "Windows";
    case "darwin": return "macOS";
    case "linux": return "Linux";
    default: return "Unknown";
  }
};

const getSystemData = () => {
  const language = store.get("login.language") || app.getLocale().split("-")[0];
  translation.setLanguage(language);
  return {
    version: pack.version,
    platform: os.platform(),
    platformRelease: os.release(),
    language,
    affiliateCode: store.get("login.affiliateCode") || "",
  };
};

const getDf = async () => {
  const uuidSpooferEnabled = store.get(STORE_KEY_UUID_SPOOFER, false);
  if (uuidSpooferEnabled) {
    if (spoofedUuid) {
      log("debug", `[DF] UUID spoofing enabled, using existing spoofed UUID: ${spoofedUuid.substr(0, 8)}...`);
      return spoofedUuid;
    }
    const newUuid = uuidv4();
    spoofedUuid = newUuid; 
    log("debug", `[DF] UUID spoofing enabled, generated new spoofed UUID: ${newUuid.substr(0, 8)}...`);
    return newUuid;
  }
  try {
    const realMachineId = await getCurrentMachineId();
    store.set("login.df", realMachineId);
    log("debug", `[DF] UUID spoofing disabled, using original machine ID: ${realMachineId.substr(0, 8)}...`);
    return realMachineId;
  } catch (err) {
    log("debugError", `[DF] Error getting machine ID: ${JSON.stringify(err)}`);
    const storedDf = store.get("login.df");
    if (storedDf) {
      log("debug", `[DF] Using stored machine ID: ${storedDf.substr(0, 8)}...`);
      return storedDf;
    } else {
      const fallbackUuid = uuidv4();
      store.set("login.df", fallbackUuid);
      log("debug", `[DF] Using random UUID as fallback machine ID: ${fallbackUuid.substr(0, 8)}...`);
      return fallbackUuid;
    }
  }
};

ipcMain.on("ready", () => {
  if (webview && webview.send) {
    webview.send("postSystemData", getSystemData());
    const screenState = store.get("window.state");
    webview.send("screenChange", screenState);
  }
});

ipcMain.on("winReady", () => {
  if (win && win.webContents && !win.isDestroyed()) {
    win.webContents.send("postSystemData", getSystemData());
  }
});

// ipcMain.on('game-webview-ready', ... ) // This listener is removed.

ipcMain.on('user-now-logged-in', () => {
  isUserLoggedIn = true;
  log('info', '[App IPC] Received user-now-logged-in. Status: true');
});

ipcMain.on('user-now-logged-out', () => {
  isUserLoggedIn = false;
  log('info', '[App IPC] Received user-now-logged-out. Status: false');
});

const handleKey = event => {
  const platform = getSystemData().platform;
  if (
    (event.key === "Enter" && event.altKey && platform === "win32")
    || (event.key === "F11" && platform === "win32")
    || (event.key === "f" && event.ctrlKey && event.metaKey && platform === "darwin")
  ) {
    if (win) win.setFullScreen(!win.isFullScreen());
  }
  else if (
    (event.key === "q" && event.ctrlKey && platform === "win32")
    || (event.key === "F4" && event.altKey && platform === "win32")
    || (event.key === "q" && event.metaKey && platform === "darwin")
  ) {
    app.quit();
  }
};

ipcMain.on("openExternal", (event, message) => {
  if (['https:', 'http:'].includes(new URL(message.url).protocol)) {
    shell.openExternal(message.url);
  }
});

ipcMain.on("keyEvent", (event, message) => handleKey(message));

if (store.get("window.fullscreen")) {
  store.set("window.state", "fullScreen");
  store.delete("window.fullscreen");
}

ipcMain.on("systemCommand", (event, message) => {
  if (message.command === "toggleFullScreen") {
    if (win) win.setFullScreen(!win.isFullScreen());
  }
  else if (message.command === "exit") {
    app.quit();
  }
  else if (message.command === "print") {
    printWindow = new BrowserWindow({
      icon: __dirname + '/gui/images/icon.png',
      enableLargerThanScreen: true,
      x: 0,
      y: 0,
      useContentSize: true,
      resizable: false,
      webPreferences: {
        contextIsolation: false,
        nodeIntegration: false,
        preload: path.join(__dirname, "gui/printPreload.js"),
      },
      fullscreen: false,
      fullscreenable: false,
      backgroundColor: "#FFFFFF",
    });
    printWindow.setSize(2480, 3508);
    if (config.showTools) {
      if (printWindow.webContents && !printWindow.isDestroyed()) printWindow.webContents.openDevTools();
    }
    else {
      printWindow.hide();
    }
    printWindow.loadURL(`file://${__dirname}/gui/print.html`);

    ipcMain.on("readyForImage", event => {
      if (event.sender && event.sender.send) {
        event.sender.send("setImage", {
          image: message.image,
          width: message.width,
          height: message.height,
        });
      }
      if (printWindow && printWindow.webContents && !printWindow.isDestroyed()) {
        printWindow.webContents.print({silent: false, printBackground: false, deviceName: ""});
      }
    });

    ipcMain.on("closePrintWindow", event => {
      if (printWindow) printWindow.close();
    });
  }
});

ipcMain.handle("toggle-uuid-spoofing", async (event, enable) => {
  try {
    log("debug", `[UUID] Received toggle-uuid-spoofing: ${enable}`);
    if (enable) {
      const confirmed = await showUuidActivationConfirmation();
      if (!confirmed) {
        log("info", "[UUID] User cancelled UUID spoofing activation");
        return { success: false, message: "Activation cancelled by user" };
      }
    }
    const result = await toggleUuidSpoofing(enable);
    if (result.success) {
      return { success: true, enabled: enable, message: enable ? "UUID spoofing enabled" : "UUID spoofing disabled" };
    } else {
      return { success: false, message: result.error || "Failed to toggle UUID spoofing" };
    }
  } catch (error) {
    log("error", `[UUID] Error in toggle-uuid-spoofing handler: ${error.message}`);
    return { success: false, message: error.message || "An unknown error occurred" };
  }
});

const DEFAULT_APP_STATE = {
  accountTester: {
    currentFile: null,
    scrollIndex: {},
    filterQuery: {},
    fileStates: {}
  }
};
let appState = { ...DEFAULT_APP_STATE };

function initializeAppState() {
  log('debug', '[AppState] Initializing app state from store');
  try {
    const storedState = store.get('app_state');
    if (storedState) {
      appState = {
        ...DEFAULT_APP_STATE,
        ...storedState,
        accountTester: {
          ...DEFAULT_APP_STATE.accountTester,
          ...(storedState.accountTester || {}),
          fileStates: {
            ...DEFAULT_APP_STATE.accountTester.fileStates,
            ...(storedState.accountTester?.fileStates || {})
          },
          scrollIndex: {
            ...DEFAULT_APP_STATE.accountTester.scrollIndex,
            ...(storedState.accountTester?.scrollIndex || {})
          },
          filterQuery: {
            ...DEFAULT_APP_STATE.accountTester.filterQuery,
            ...(storedState.accountTester?.filterQuery || {})
          }
        }
      };
      log('debug', '[AppState] Loaded state from store');
    } else {
      log('debug', '[AppState] No stored state found, using defaults');
      appState = { ...DEFAULT_APP_STATE };
    }
  } catch (error) {
    log('error', `[AppState] Error initializing app state: ${error.message}`);
    appState = { ...DEFAULT_APP_STATE };
  }
}

async function saveAppState() {
  log('debug', '[AppState] Saving app state to store');
  try {
    store.set('app_state', appState);
    log('debug', '[AppState] State saved successfully');
    return true;
  } catch (error) {
    log('error', `[AppState] Error saving app state: ${error.message}`);
    return false;
  }
}

ipcMain.handle('get-app-state', async () => {
  log('debug', '[IPC] Handling get-app-state request');
  return appState;
});

ipcMain.handle('set-app-state', async (event, newState) => {
  log('debug', '[IPC] Handling set-app-state request');
  if (!newState || typeof newState !== 'object') {
    log('error', '[IPC] Invalid state provided to set-app-state');
    return { success: false, error: 'Invalid state object' };
  }
  try {
    appState = {
      ...appState,
      ...newState,
      accountTester: {
        ...appState.accountTester,
        ...(newState.accountTester || {}),
        fileStates: {
          ...appState.accountTester.fileStates,
          ...(newState.accountTester?.fileStates || {})
        },
        scrollIndex: {
          ...appState.accountTester.scrollIndex,
          ...(newState.accountTester?.scrollIndex || {})
        },
        filterQuery: {
          ...appState.accountTester.filterQuery,
          ...(newState.accountTester?.filterQuery || {})
        }
      }
    };
    await saveAppState();
    log('debug', '[IPC] App state updated successfully');
    return { success: true };
  } catch (error) {
    log('error', `[IPC] Error updating app state: ${error.message}`);
    return { success: false, error: error.message };
  }
});

async function getSavedAccountsData() {
  log('debug', '[AccMan Helper] Fetching saved accounts data (using plaintext store).');
  const accountsFromStore = store.get(STORE_KEY_SAVED_ACCOUNTS, []);
  const accountsWithPasswords = [];
  for (const acc of accountsFromStore) {
    const storedPassword = store.get(`savedAccountPasswords.${acc.username}`);
    accountsWithPasswords.push({ ...acc, password: storedPassword || null });
    if (storedPassword) {
      log('warn', `[WINAPP AccMan Helper] Retrieved plaintext password for ${acc.username} from electron-store.`);
    } else {
      log('info', `[WINAPP AccMan Helper] No plaintext password found in electron-store for ${acc.username}.`);
    }
  }
  return accountsWithPasswords;
}

ipcMain.handle('get-saved-accounts', async () => {
  log('debug', '[AccMan IPC] Handling get-saved-accounts request');
  return await getSavedAccountsData();
});

ipcMain.handle('save-account', async (event, accountData) => {
  log('debug', `[AccMan] Handling save-account request for ${accountData.username}`);
  if (!accountData || !accountData.username || !accountData.password) {
    log('error', '[AccMan] Invalid account data provided to save-account');
    return { success: false, error: 'Invalid account data' };
  }
  try {
    let savedAccountsMetadata = store.get(STORE_KEY_SAVED_ACCOUNTS, []);
    const accountMetadata = { username: accountData.username };
    const existingAccountIndex = savedAccountsMetadata.findIndex(acc => acc.username.toLowerCase() === accountData.username.toLowerCase());
    if (existingAccountIndex !== -1) {
      savedAccountsMetadata[existingAccountIndex] = accountMetadata;
      log('info', `[AccMan] Updated existing account metadata: ${accountData.username}`);
    } else {
      savedAccountsMetadata.push(accountMetadata);
      log('info', `[AccMan] Added new account metadata: ${accountData.username}`);
    }
    // Store plaintext password in electron-store
    store.set(`savedAccountPasswords.${accountData.username}`, accountData.password);
    log('warn', `[WINAPP AccMan] Stored plaintext password for ${accountData.username} in electron-store.`);
    store.set(STORE_KEY_SAVED_ACCOUNTS, savedAccountsMetadata);
    const updatedAccountsWithPasswords = await getSavedAccountsData();
    return { success: true, accounts: updatedAccountsWithPasswords };
  } catch (error) {
    log('error', `[AccMan] Error saving account: ${error.message}`);
    return { success: false, error: error.message };
  }
});

ipcMain.handle('delete-account', async (event, username) => {
  log('debug', `[AccMan] Handling delete-account request for ${username}`);
  if (!username) {
    log('error', '[AccMan] Invalid username provided to delete-account');
    return { success: false, error: 'Invalid username' };
  }
  try {
    let savedAccountsMetadata = store.get(STORE_KEY_SAVED_ACCOUNTS, []);
    const initialLength = savedAccountsMetadata.length;
    savedAccountsMetadata = savedAccountsMetadata.filter(acc => acc.username.toLowerCase() !== username.toLowerCase());
    if (savedAccountsMetadata.length < initialLength) {
      store.set(STORE_KEY_SAVED_ACCOUNTS, savedAccountsMetadata);
      log('info', `[AccMan] Deleted account metadata for: ${username}`);
      // Delete plaintext password from electron-store
      store.delete(`savedAccountPasswords.${username}`);
      log('warn', `[WINAPP AccMan] Deleted plaintext password for ${username} from electron-store.`);
      const updatedAccountsWithPasswords = await getSavedAccountsData();
      return { success: true, accounts: updatedAccountsWithPasswords };
    } else {
      log('warn', `[AccMan] Account metadata not found for deletion: ${username}`);
      // Ensure password is also deleted if somehow present without metadata (cleanup)
      store.delete(`savedAccountPasswords.${username}`);
      const updatedAccountsWithPasswords = await getSavedAccountsData();
      return { success: false, error: 'Account not found', accounts: updatedAccountsWithPasswords };
    }
  } catch (error) {
    log('error', `[AccMan] Error deleting account: ${error.message}`);
    return { success: false, error: error.message };
  }
});

ipcMain.handle('toggle-pin-account', async (event, username) => {
  log('debug', `[AccMan] Handling toggle-pin-account request for ${username}`);
  if (!username) {
    log('error', '[AccMan] Invalid username provided to toggle-pin-account');
    return { success: false, error: 'Invalid username' };
  }
  try {
    let savedAccountsMetadata = store.get(STORE_KEY_SAVED_ACCOUNTS, []);
    const accountIndex = savedAccountsMetadata.findIndex(acc => acc.username.toLowerCase() === username.toLowerCase());
    
    if (accountIndex === -1) {
      log('warn', `[AccMan] Account metadata not found for pin toggle: ${username}`);
      return { success: false, error: 'Account not found' };
    }
    
    // Toggle the pinned status
    savedAccountsMetadata[accountIndex].pinned = !savedAccountsMetadata[accountIndex].pinned;
    
    store.set(STORE_KEY_SAVED_ACCOUNTS, savedAccountsMetadata);
    log('info', `[AccMan] Toggled pin status for: ${username} to ${savedAccountsMetadata[accountIndex].pinned}`);
    
    const updatedAccountsWithPasswords = await getSavedAccountsData();
    return { success: true, accounts: updatedAccountsWithPasswords };
  } catch (error) {
    log('error', `[AccMan] Error toggling pin status: ${error.message}`);
    return { success: false, error: error.message };
  }
});

ipcMain.handle('open-user-cache-file', async () => {
  try {
    const filePath = store.path;
    shell.openPath(filePath);
    log('info', `[AccMan] Opened user cache file: ${filePath}`);
    return { success: true, path: filePath };
  } catch (error) {
    log('error', `[AccMan] Error opening user cache file: ${error.message}`);
    return { success: false, error: error.message };
  }
});

// Import accounts from array
ipcMain.handle('import-accounts', async (event, accounts) => {
  log('debug', `[AccMan] Handling import-accounts request for ${accounts.length} accounts`);
  if (!Array.isArray(accounts) || accounts.length === 0) {
    log('error', '[AccMan] Invalid accounts array provided to import-accounts');
    return { success: false, error: 'Invalid accounts array' };
  }

  try {
    let savedAccountsMetadata = store.get(STORE_KEY_SAVED_ACCOUNTS, []);
    let importedCount = 0;

    for (const account of accounts) {
      if (!account.username || !account.password) {
        log('warn', `[AccMan] Skipping invalid account: ${JSON.stringify(account)}`);
        continue;
      }

      const accountMetadata = { username: account.username };
      const existingAccountIndex = savedAccountsMetadata.findIndex(acc => 
        acc.username.toLowerCase() === account.username.toLowerCase()
      );

      if (existingAccountIndex !== -1) {
        // Update existing account
        savedAccountsMetadata[existingAccountIndex] = accountMetadata;
        log('info', `[AccMan] Updated existing account: ${account.username}`);
      } else {
        // Add new account
        savedAccountsMetadata.push(accountMetadata);
        log('info', `[AccMan] Added new account: ${account.username}`);
      }

      // Store plaintext password
      store.set(`savedAccountPasswords.${account.username}`, account.password);
      importedCount++;
    }

    store.set(STORE_KEY_SAVED_ACCOUNTS, savedAccountsMetadata);
    log('info', `[AccMan] Import completed: ${importedCount} accounts imported`);

    const updatedAccountsWithPasswords = await getSavedAccountsData();
    return { 
      success: true, 
      imported: importedCount, 
      total: accounts.length,
      accounts: updatedAccountsWithPasswords 
    };
  } catch (error) {
    log('error', `[AccMan] Error importing accounts: ${error.message}`);
    return { success: false, error: error.message };
  }
});

ipcMain.handle('get-df', async () => {
  try {
    const currentDf = await getDf();
    log('debug', `[IPC] Returning DF to renderer: ${currentDf}`);
    return currentDf;
  } catch (error) {
    log('error', `[IPC] Error handling get-df: ${error.message}`);
    return null; 
  }
});

ipcMain.handle("refresh-df", async (event) => {
  if (store.get(STORE_KEY_UUID_SPOOFER, false)) {
    const newUuid = uuidv4();
    spoofedUuid = newUuid;
    log("debug", `[DF] Refreshed DF - generated new UUID: ${newUuid}`);
    return newUuid;
  }
  return null;
});

const translate = (phrase) => {
  const {error, value} = translation.translate(phrase);
  if (error) {
    log("warn", error);
  }
  return value;
};

// Function to notify Strawberry Jam when AJ Classic is closing
let isNotificationSent = false;
const notifyStrawberryJamClose = () => {
  try {
    // Prevent multiple notifications
    if (isNotificationSent) {
      log("debug", "[AJ Classic Close] Notification already sent, skipping duplicate call");
      return;
    }
    
    log("info", "[AJ Classic Close] notifyStrawberryJamClose called - attempting to notify main Strawberry Jam app");
    
    // Try to connect to Strawberry Jam's API server to notify about AJ Classic closing
    const strawberryJamDataPath = process.env.STRAWBERRY_JAM_DATA_PATH;
    if (strawberryJamDataPath) {
      log("debug", `[AJ Classic Close] Found STRAWBERRY_JAM_DATA_PATH: ${strawberryJamDataPath}`);
      // Send a HTTP request to the main Strawberry Jam application to close plugins
      const http = require('http');
      
      // Try common ports that Strawberry Jam API might be running on
      const ports = [8080, 8081, 8082, 9080, 3000];
      let notificationSuccessful = false;
      
      const tryPort = (portIndex) => {
        if (portIndex >= ports.length || notificationSuccessful) {
          if (!notificationSuccessful) {
            log("warn", "[AJ Classic Close] Failed to notify Strawberry Jam on any port");
          }
          return;
        }
        
        const port = ports[portIndex];
        const postData = JSON.stringify({
          action: 'aj-classic-closing',
          timestamp: Date.now()
        });
        
        const options = {
          hostname: '127.0.0.1',
          port: port,
          path: '/api/aj-classic-close',
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(postData)
          },
          timeout: 1000  // 1 second timeout
        };
        
        const req = http.request(options, (res) => {
          if (res.statusCode === 200 && !notificationSuccessful) {
            notificationSuccessful = true;
            isNotificationSent = true;
            log("info", `[AJ Classic Close] Successfully notified Strawberry Jam on port ${port}`);
          } else if (res.statusCode !== 200) {
            log("debug", `[AJ Classic Close] Unexpected response code ${res.statusCode} from port ${port}`);
            setTimeout(() => tryPort(portIndex + 1), 100);
          }
        });
        
        req.on('error', (err) => {
          log("debug", `[AJ Classic Close] Connection failed for port ${port}: ${err.message}`);
          setTimeout(() => tryPort(portIndex + 1), 100);
        });
        
        req.on('timeout', () => {
          log("debug", `[AJ Classic Close] Request timeout for port ${port}`);
          req.destroy();
          setTimeout(() => tryPort(portIndex + 1), 100);
        });
        
        req.write(postData);
        req.end();
      };
      
      tryPort(0);
    } else {
      log("warn", "[AJ Classic Close] STRAWBERRY_JAM_DATA_PATH environment variable not set - cannot notify main app");
    }
  } catch (error) {
    log("error", `[AJ Classic Close] Error in notifyStrawberryJamClose: ${error.message}`);
  }
};

// Handle exit confirmation response from renderer
ipcMain.on("exit-confirmation-response", (event, { confirmed, dontAskAgain }) => {
  log("debug", `[Exit Confirmation] Received response: confirmed=${confirmed}, dontAskAgain=${dontAskAgain}`);
  
  if (dontAskAgain) {
    store.set("ui.skipExitConfirmation", true);
    log("info", "[Exit Confirmation] User chose to skip confirmation in future");
  }
  
  if (confirmed) {
    log("info", "[Exit Confirmation] User confirmed exit, closing application");
    isClosing = true;
    
    // Force quit the application to prevent hanging
    setTimeout(() => {
      log("warn", "[Exit Confirmation] Force quitting application due to timeout");
      app.quit();
    }, 2000);
    
    if (win && !win.isDestroyed()) {
      log("debug", "[Exit Confirmation] Calling win.close()");
      win.close();
    } else {
      log("warn", "[Exit Confirmation] Window already destroyed or null, calling app.quit()");
      app.quit();
    }
  } else {
    log("debug", "[Exit Confirmation] User cancelled exit");
  }
});

ipcMain.on("translate", (event, message) => {
  if (win && win.webContents && !win.isDestroyed()) {
    win.webContents.send("translate", {
      phrase: message.phrase,
      requestId: message.requestId,
      value: translate(message.phrase),
    });
  }
});

app.commandLine.appendSwitch("ppapi-flash-path", path.join(__dirname, `${config.pluginPath}${config.pluginName}`));

app.on('certificate-error', (event, webContents, url, error, certificate, callback) => {
  console.log(`Certificate error: ${error} for ${url}`);
  event.preventDefault();
  callback(true);
});

const MIGRATION_FLAG_KEYTAR_V1 = 'credentialsMigratedToKeytar_v1';

async function migrateCredentialsToKeytar() {
  // This function is a no-op as Keytar has been removed.
  // Ensure the migration flag is set to prevent any legacy logic from running.
  if (!store.get(MIGRATION_FLAG_KEYTAR_V1)) {
    store.set(MIGRATION_FLAG_KEYTAR_V1, true);
  } else {
  }
}

app.whenReady().then(async () => {
  log('info', '[App] App ready event triggered.');

  await migrateCredentialsToKeytar();
  initializeAppState();
  // log('info', '[App] App state initialized.'); // Moved up
  if (!store.has(STORE_KEY_UUID_SPOOFER)) {
    store.set(STORE_KEY_UUID_SPOOFER, false);
    log('info', '[Store] Initialized default UUID spoofer setting.');
  }
  if (!Array.isArray(store.get(STORE_KEY_SAVED_ACCOUNTS))) {
    store.set(STORE_KEY_SAVED_ACCOUNTS, []);
    log('info', '[Store] Initialized saved_accounts as empty array.');
  }
  if (!store.has('disableDevToolsEnabled')) {
    store.set('disableDevToolsEnabled', false);
    log('info', '[Store] Initialized default disableDevToolsEnabled.');
  }
  const minWidth = 900;
  const minHeight = 550;
  win = new BrowserWindow({
    icon: __dirname + '/gui/images/icon.png',
    minWidth,
    minHeight,
    width: store.get("window.width") || 1440,
    height: store.get("window.height") || 880,
    x: store.get("window.x") || 0,
    y: store.get("window.y") || 0,
    useContentSize: true,
    resizable: true,
    webPreferences: {
      contextIsolation: true,
      webviewTag: true,
      nodeIntegration: true,
      preload: path.join(__dirname, "gui/preload.js"),
      plugins: true,
    },
    autoHideMenuBar: true,
    fullscreen: store.get("window.state") === "fullScreen",
    fullscreenable: true,
    backgroundColor: "#F5C86D",
  });
  win.setMenu(null);
  const winState = store.get("window.state");
  if (winState === "fullScreen") {
    win.setFullScreen(true);
  }
  else if (winState === "maximized") {
    win.maximize();
  }
  if (config.clearCache) {
    if (win.webContents && !win.isDestroyed()) {
      win.webContents.session.clearCache(() => {});
    }
  }
  loadClient();

  if (config.showTools && win && win.webContents && !win.isDestroyed()) {
      win.webContents.openDevTools({ mode: 'detach' }); // Opens DevTools for the main window
      log('info', '[DevTools] Main window DevTools opened on startup due to config.showTools. GameScreen will handle its own if present.');
  }

  setApplicationMenu();
  win.on("closed", () => {
    win = null;
    if (printWindow) {
      printWindow.close();
    }
  });
  win.on("resize", () => {
    if (win) {
      const bounds = win.getBounds();
      store.set("window.width", bounds.width);
      store.set("window.height", bounds.height);
    }
  });
  log('info', '[App] Auto-loading will be handled by renderer process.');
});

app.on("window-all-closed", () => {
  log('info', '[App] window-all-closed event triggered.');
  app.quit();
});

app.on('will-quit', () => {
  log('info', '[App] will-quit event triggered.');
  globalShortcut.unregisterAll();
  log('info', '[Shortcut] Unregistered all global shortcuts.');
});

ipcMain.handle('set-user-agent', async (event, userAgent) => {
  if (userAgent && typeof userAgent === 'string') {
    try {
      await session.defaultSession.setUserAgent(userAgent);
      return true;
    } catch (err) {
      console.error('[Tester Integration] Failed to set User-Agent on session:', err);
      return false;
    }
  } else {
    console.warn('[Tester Integration] Invalid User-Agent received for session:', userAgent);
    return false;
  }
});

ipcMain.handle("get-setting", async (event, key) => {
  try {
    if (key === 'uuidSpoofingEnabled') {
      return store.get(STORE_KEY_UUID_SPOOFER, false);
    } else if (key === 'debug.country') {
      return store.get('debug.country', '');
    } else if (key === 'debug.locale') {
      return store.get('debug.locale', '');
    }
    return store.get(key);
  } catch (error) {
    log('error', `[IPC] Error getting setting ${key}: ${error.message}`);
    return null;
  }
});

ipcMain.handle('set-setting', async (event, key, value) => {
  log('debug', `[IPC] Handling set-setting request for key: ${key}`);
  if (!key || typeof key !== 'string') {
    log('error', '[IPC] Invalid key provided to set-setting');
    return { success: false, error: 'Invalid key' };
  }
  try {
    if (key === 'uuid_spoofer_enabled') {
      store.set(STORE_KEY_UUID_SPOOFER, value === true);
      log("info", `[Settings] UUID spoofer set to: ${value === true}`);
      return true;
    } else if (key === 'debug.country') {
      store.set('debug.country', value);
      log("info", `[Settings] Country override set to: ${value || 'none'}`);
      return true;
    } else if (key === 'debug.locale') {
      store.set('debug.locale', value);
      log("info", `[Settings] Locale override set to: ${value || 'none'}`);
      return true;
    }
    store.set(key, value);
    return true;
  } catch (error) {
    log('error', `[IPC] Error updating setting ${key}: ${error.message}`);
    return { success: false, error: error.message };
  }
});
