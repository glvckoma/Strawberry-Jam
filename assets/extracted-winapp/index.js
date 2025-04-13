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
const config = require("./config.js");
const server = require("./server.js");
const translation = require("./translation.js");

// --- Tester File Paths ---
const worksFilePath = path.join(app.getPath('userData'), 'tester_works.txt');
const doesNotWorkFilePath = path.join(app.getPath('userData'), 'tester_does_not_work.txt');
// --- End Tester File Paths ---

// --- Storage Keys ---
const STORE_KEY_TESTER_LAST_FILE_PATH = 'tester_lastFilePath';
const STORE_KEY_TESTER_SAVE_FILE_PATH = 'tester_saveFilePath';
const STORE_KEY_TESTER_INTER_TEST_DELAY = 'tester_interTestDelay';
const STORE_KEY_TESTER_RETRY_DELAY = 'tester_retryDelay';
const STORE_KEY_TESTER_DEBUG_LOGGING = 'tester_debugLoggingEnabled';
const STORE_KEY_TESTER_ACTUAL_LOGIN = 'tester_actualLoginEnabled'; // Added
const STORE_KEY_TESTER_DISABLE_DEVTOOLS = 'tester_disableDevToolsEnabled'; // Added
// --- End Storage Keys ---

const AUTO_UPDATE_STARTUP_DELAY_MS = 2000;
const AUTO_UPDATE_PERIODIC_DELAY_MS = 1 * 60 * 60 * 1000; 

let win = null;

let printWindow = null;

const store = new Store();

// Variables to hold the latest known delay values from the renderer
let latestInterTestDelay = store.get(STORE_KEY_TESTER_INTER_TEST_DELAY, 1000);
let latestRetryDelay = store.get(STORE_KEY_TESTER_RETRY_DELAY, 10000);
let latestDebugMode = store.get(STORE_KEY_TESTER_DEBUG_LOGGING, false); // Added for debug state

const log = (level, message) => {
  // Basic check if debug logging is enabled for 'debug' level messages
  if (level === 'debug' && !latestDebugMode) {
      return; // Skip logging if debug mode is off
  }

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
        win.webContents.reloadIgnoringCache();
      },
    }, {
      label: "Toggle DevTools",
      accelerator: "CmdOrCtrl+Shift+I",
      click: () => {
        win.toggleDevTools();
        win.webContents.send("toggleDevTools");
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
  win.webContents.send("autoUpdateStatus", updateStatus);
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
  const authToken = store.get("login.authToken") || null;
  const refreshToken = store.get("login.refreshToken") || null;
  const df = await getDf();

  webview.send("loginInfoLoaded", {
    username,
    authToken,
    refreshToken,
    rememberMe,
    df,
    config,
    rcToken,
  });

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
          win.webContents.send("obtainedToken", {
            token: data.authToken,
          });
        }
      }
      catch (err) {
        log("debugError", JSON.stringify(err));
      }
    })();
  }
  // TODO: Optimize this, when returning to maximized from full screen it fires of a leave-full-screen event and triggers an extra  disk write with the "windowed" state

  // Maximize event fires after the full screen event
  win.on("enter-full-screen", () => {
    setTimeout(() => {
      // win.webContents.send("log", "fullScreen");
      store.set("window.state", "fullScreen");
      webview.send("screenChange", "fullScreen");
    }, 1);
  });

  win.on("maximize", () => {
    // win.webContents.send("log", "maximized");
    store.set("window.state", "maximized");
    webview.send("screenChange", "maximized");
  });

  win.on("unmaximize", () => {
    // win.webContents.send("log", "windowed");
    store.set("window.state", "windowed");
    webview.send("screenChange", "windowed");
  });

  win.on("leave-full-screen", () => {
    // win.webContents.send("log", "windowed");
    store.set("window.state", "windowed");
    webview.send("screenChange", "windowed");
  });

  win.on("close", () => {
    const position = win.getPosition();
    store.set("window.x", position[0]);
    store.set("window.y", position[1]);
  });
});

ipcMain.on("loginSucceeded", (event, message) => {
  log("debug", `[IPC] loginSucceeded received. Saving login data for ${message.username}`);
  server.stop();

  store.set("login.username", message.username);
  store.set("login.language", message.language);
  translation.setLanguage(message.language);
  store.set("login.rememberMe", message.rememberMe);
  if (message.rememberMe) {
    store.set("login.authToken", message.authToken);
    if (message.refreshToken) {
      store.set("login.refreshToken", message.refreshToken);
    }
  }
  else {
    store.delete("login.authToken");
    store.delete("login.refreshToken");
  }

  // Always set the application menu to include Development tools
  // Preserve Jam's original behavior of checking accountType
  if (message.accountType > 2) {
    setApplicationMenu();
  }
});

ipcMain.on("rememberMeStateUpdated", async (event, message) => {
  log('debug', `[IPC] rememberMeStateUpdated received: ${message.newValue}`);
  store.set("login.rememberMe", message.newValue);
});

ipcMain.on("clearAuthToken", async (event, message) => {
  log('debug', '[IPC] clearAuthToken received.');
  store.delete("login.authToken");
});

ipcMain.on("clearRefreshToken", async (event, message) => {
  log('debug', '[IPC] clearRefreshToken received.');
  store.delete("login.refreshToken");
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
  let df = store.get("login.df");
  if (df === undefined) {
    try {
      df = await machineId({original: true});
    }
    catch (err) {
      log("debugError", JSON.stringify(err));
      df = uuidv4();
    }
    store.set("login.df", df);
  }
  return df;
};

// webview ready
ipcMain.on("ready", () => {
  webview.send("postSystemData", getSystemData());
  const screenState = store.get("window.state");
  webview.send("screenChange", screenState);
});
// renderer process ready
ipcMain.on("winReady", () => {
  win.webContents.send("postSystemData", getSystemData());
  
  // Send a signal that the main process is fully ready for IPC communication
  // This ensures all IPC handlers are registered before auto-load attempts
  log('info', '[IPC] Sending tester-main-ready signal to renderer');
  setTimeout(() => {
    if (win && !win.isDestroyed()) {
      win.webContents.send("tester-main-ready", true);
      log('info', '[IPC] tester-main-ready signal sent successfully');
    } else {
      log('error', '[IPC] Failed to send tester-main-ready signal - window destroyed');
    }
  }, 500); // Small delay to ensure all handlers are registered
});

const handleKey = event => {
  const platform = getSystemData().platform;
  // fullscreen
  if (
    (event.key === "Enter" && event.altKey && platform === "win32")
    || (event.key === "F11" && platform === "win32")
    || (event.key === "f" && event.ctrlKey && event.metaKey && platform === "darwin")
  ) {
    win.setFullScreen(!win.isFullScreen());
  }
  // quit
  else if (
    (event.key === "q" && event.ctrlKey && platform === "win32")
    || (event.key === "F4" && event.altKey && platform === "win32")
    || (event.key === "q" && event.metaKey && platform === "darwin")
  ) {
    app.quit();
  }
};

ipcMain.on("openExternal", (event, message) => {
  // open http/https url in default browser
  if (['https:', 'http:'].includes(new URL(message.url).protocol)) {
    shell.openExternal(message.url);
  }
});

ipcMain.on("keyEvent", (event, message) => handleKey(message));

// UPDATE LOCAL DATA
//  before 0.3.0 full screen was not stored in window.state
if (store.get("window.fullscreen")) {
  store.set("window.state", "fullScreen");
  store.delete("window.fullscreen");
}

// Handle system commands
ipcMain.on("systemCommand", (event, message) => {
  if (message.command === "toggleFullScreen") {
    win.setFullScreen(!win.isFullScreen());
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
        contextIsolation: true,
        nodeIntegration: false,
        preload: path.join(__dirname, "gui/printPreload.js"),
      },
      fullscreen: false,
      fullscreenable: false,
      backgroundColor: "#FFFFFF",
    });
    // Bug on windows where you cant spawn a window larger than the max monitor size
    // https://github.com/electron/electron/issues/4932
    printWindow.setSize(2480, 3508);
    if (config.showTools) {
      printWindow.webContents.openDevTools();
    }
    else {
      printWindow.hide();
    }
    printWindow.loadURL(`file://${__dirname}/gui/print.html`);

    ipcMain.on("readyForImage", event => {
      log("debug", "Got readyForImage, sending image.");
      event.sender.send("setImage", {
        image: message.image,
        width: message.width,
        height: message.height,
      });
      printWindow.webContents.print({silent: false, printBackground: false, deviceName: ""});
    });

    ipcMain.on("closePrintWindow", event => {
      printWindow.close();
    });
  }
});

// --- Tester File Operations ---
async function loadAccountsFromFile(filePath) {
  log('info', `[DIAGNOSTIC] [loadAccountsFromFile] START - Attempting to read file: ${filePath}`);
  try {
    log('info', `[DIAGNOSTIC] [loadAccountsFromFile] Before fsPromises.readFile for: ${filePath}`);
    const data = await fsPromises.readFile(filePath, 'utf8');
    log('info', `[DIAGNOSTIC] [loadAccountsFromFile] After fsPromises.readFile - Successfully read file: ${filePath}`);
    log('info', `[DIAGNOSTIC] [loadAccountsFromFile] File content length: ${data.length} bytes`);
    
    // Split by newline, filter empty lines, trim whitespace
    const lines = data.split(/[\r\n]+/).filter(line => line.trim() !== '');
    log('info', `[DIAGNOSTIC] [loadAccountsFromFile] Split into ${lines.length} non-empty lines`);
    
    // Basic format check (e.g., contains ':') - can be enhanced
    const accounts = lines.map((line, index) => {
      const parts = line.split(':');
      if (parts.length >= 2) {
        return { username: parts[0].trim(), password: parts.slice(1).join(':').trim(), status: 'pending' };
      }
      log('warn', `[DIAGNOSTIC] [loadAccountsFromFile] Invalid format at line ${index + 1}: ${line.substring(0, 20)}...`);
      return null; // Invalid format
    }).filter(account => account !== null); // Remove invalid lines
    
    log('info', `[DIAGNOSTIC] [loadAccountsFromFile] COMPLETE - Parsed ${accounts.length} accounts from ${filePath}`);
    return accounts;
  } catch (error) {
    log('error', `[DIAGNOSTIC] [loadAccountsFromFile] ERROR - Reading account file ${filePath}: ${error.message} (${error.code})`);
    log('error', `[DIAGNOSTIC] [loadAccountsFromFile] Error stack: ${error.stack}`);
    throw error; // Re-throw to be caught by the caller
  }
}

async function saveResultToFile(filePath, accountString) {
  log('debug', `[saveResultToFile] Attempting to append to file: ${filePath}`);
  try {
    await fsPromises.appendFile(filePath, accountString + os.EOL, 'utf8');
    log('debug', `[saveResultToFile] Successfully appended to ${filePath}`);
  } catch (error) {
    log('error', `[saveResultToFile] Error saving result to ${path.basename(filePath)}: ${error.message}`);
  }
}
// --- End Tester File Operations ---


// --- Tester IPC Handlers ---
ipcMain.on('tester-load-accounts', async (event) => {
  log('debug', '[IPC] Received tester-load-accounts');
  try {
    const result = await dialog.showOpenDialog(win, {
      title: 'Load Account List',
      properties: ['openFile'],
      filters: [{ name: 'Text Files', extensions: ['txt'] }]
    });
    if (!result.canceled && result.filePaths.length > 0) {
      const filePath = result.filePaths[0];
      log('debug', `[IPC] tester-load-accounts: File selected: ${filePath}`);
      const accounts = await loadAccountsFromFile(filePath);
      store.set(STORE_KEY_TESTER_LAST_FILE_PATH, filePath); // Save the path
      log('debug', `[IPC] tester-load-accounts: Sending ${accounts.length} accounts to renderer.`);
      event.sender.send('tester-accounts-loaded', { success: true, accounts: accounts, filePath: filePath });
    } else {
      log('debug', '[IPC] tester-load-accounts: File selection canceled.');
      event.sender.send('tester-accounts-loaded', { success: false, error: 'File selection canceled.' });
    }
  } catch (error) {
    log('error', `[IPC] tester-load-accounts: Error - ${error.message}`);
    event.sender.send('tester-accounts-loaded', { success: false, error: error.message });
  }
});

// Handle selecting the save file path for 'works' accounts
ipcMain.on('tester-select-save-path', async (event) => {
  log('debug', '[IPC] Received tester-select-save-path');
  try {
    const result = await dialog.showSaveDialog(win, {
      title: 'Select Save File for Working Accounts',
      defaultPath: path.join(app.getPath('documents'), 'ajc_tester_works.txt'), // Suggest default
      filters: [{ name: 'Text Files', extensions: ['txt'] }]
    });
    if (!result.canceled && result.filePath) {
      log('debug', `[IPC] tester-select-save-path: Path selected: ${result.filePath}`);
      event.sender.send('tester-save-path-result', { success: true, filePath: result.filePath });
    } else {
      log('debug', '[IPC] tester-select-save-path: Dialog canceled.');
      // Send cancellation back to renderer
      event.sender.send('tester-save-path-result', { success: false, canceled: true });
    }
  } catch (error) {
    log('error', `[IPC] tester-select-save-path: Error showing save dialog: ${error.message}`);
    event.sender.send('tester-save-path-result', { success: false, error: error.message });
  }
});

// Handle saving the chosen path
ipcMain.on('tester-set-save-path', (event, filePath) => {
  log('debug', '[IPC] Received tester-set-save-path with path:', filePath);
  if (filePath && typeof filePath === 'string') {
    store.set(STORE_KEY_TESTER_SAVE_FILE_PATH, filePath);
     log('info', `[Store] Set ${STORE_KEY_TESTER_SAVE_FILE_PATH} to: ${filePath}`);
  } else {
    store.delete(STORE_KEY_TESTER_SAVE_FILE_PATH); // Clear if null/undefined
     log('info', `[Store] Cleared ${STORE_KEY_TESTER_SAVE_FILE_PATH}.`);
  }
});

// Handle retrieving the stored path
ipcMain.on('tester-get-save-path', (event) => {
  log('debug', '[IPC] Received tester-get-save-path');
  const savePath = store.get(STORE_KEY_TESTER_SAVE_FILE_PATH);
  log('debug', `[IPC] Sending tester-save-path-result with path: ${savePath}`);
  // Send path back immediately if found (even if null)
  event.sender.send('tester-save-path-result', { success: true, filePath: savePath });
});


ipcMain.on('tester-save-works', (event, accountString) => {
  log('debug', '[IPC] Received tester-save-works for account:', accountString ? accountString.split(':')[0] : 'N/A');
  const customSavePath = store.get(STORE_KEY_TESTER_SAVE_FILE_PATH);
  const finalPath = customSavePath || worksFilePath; // Use custom path if set, else default
  log('info', `[FileOp] Saving 'works' result to: ${finalPath}`);
  saveResultToFile(finalPath, accountString);
});

ipcMain.on('tester-get-last-path', (event) => {
  log('debug', '[IPC] Received tester-get-last-path');
  const lastPath = store.get(STORE_KEY_TESTER_LAST_FILE_PATH);
  log('debug', `[IPC] Sending tester-last-path-result with path: ${lastPath}`);
  event.sender.send('tester-last-path-result', lastPath);
});

ipcMain.on('tester-set-last-path', (event, filePath) => {
  log('debug', '[IPC] Received tester-set-last-path with path:', filePath);
  if (filePath && typeof filePath === 'string') {
    store.set(STORE_KEY_TESTER_LAST_FILE_PATH, filePath);
    log('info', `[Store] Set ${STORE_KEY_TESTER_LAST_FILE_PATH} to: ${filePath}`);
  }
});

// Handle saving delay settings
ipcMain.on('tester-set-delay', (event, { key, value }) => {
  log('debug', `[IPC] Received tester-set-delay: key=${key}, value=${value}`);
  let storeKey = null;
  if ((key === 'interTestDelay' || key === 'retryDelay') && typeof value === 'number' && value >= 0) {
    // Update the latest known value in the main process
    if (key === 'interTestDelay') {
      log('debug', `[State] Updating latestInterTestDelay to ${value}`);
      latestInterTestDelay = value;
      storeKey = STORE_KEY_TESTER_INTER_TEST_DELAY;
    } else if (key === 'retryDelay') {
      log('debug', `[State] Updating latestRetryDelay to ${value}`);
      latestRetryDelay = value;
      storeKey = STORE_KEY_TESTER_RETRY_DELAY;
    }

    if (storeKey) {
      log('debug', `[Store] Setting ${storeKey} to ${value}`);
      store.set(storeKey, value);
      // Confirm the value was saved
      const saved = store.get(storeKey);
      log('debug', `[Store] Confirmed saved value for ${storeKey}: ${saved}`);
    } else {
      log('warn', `[Tester Integration] Unknown delay key received: ${key}`);
    }
  } else {
    log('warn', `[Tester Integration] Invalid delay setting received: key=${key}, value=${value}`);
  }
});

// Handle retrieving delay settings
ipcMain.on('tester-get-delays', (event) => {
  log('debug', '[IPC] Received tester-get-delays');
  const interTestDelay = store.get(STORE_KEY_TESTER_INTER_TEST_DELAY, 1000); // Default 1000ms
  const retryDelay = store.get(STORE_KEY_TESTER_RETRY_DELAY, 10000); // Default 10000ms
  log('debug', `[IPC] Sending tester-delays-loaded: interTest=${interTestDelay}, retry=${retryDelay}`);
  event.sender.send('tester-delays-loaded', { interTestDelay, retryDelay });
  // log('info', `[Tester Integration] Sending loaded delays: interTest=${interTestDelay}, retry=${retryDelay}`); // Redundant with debug log
});

// Handle loading a specific file path (for auto-load on startup)
ipcMain.on('tester-load-specific-file', async (event, filePath) => {
  log('info', `[DIAGNOSTIC] [IPC] START - Received tester-load-specific-file for path: ${filePath}`);
  
  // Store the event.sender for debugging
  const sender = event.sender;
  log('info', `[DIAGNOSTIC] [IPC] Sender valid: ${!!sender}, destroyed: ${sender?.isDestroyed?.() || 'unknown'}`);
  
  if (!filePath || typeof filePath !== 'string') {
    log('warn', '[DIAGNOSTIC] [IPC] Invalid file path provided.');
    try {
      log('info', `[DIAGNOSTIC] [IPC] Attempting to send error response for invalid path`);
      event.sender.send('tester-specific-file-loaded', { success: false, error: 'Invalid file path provided.' });
      log('info', `[DIAGNOSTIC] [IPC] Successfully sent error response for invalid path`);
    } catch (sendError) {
      log('error', `[DIAGNOSTIC] [IPC] Failed to send error response: ${sendError.message}`);
    }
    return;
  }
  
  // Add retry mechanism for auto-load
  const maxRetries = 3;
  const retryDelay = 500; // ms
  let lastError = null;
  
  log('info', `[DIAGNOSTIC] [FileOp] Attempting to auto-load file with retries: ${filePath}`);
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    log('info', `[DIAGNOSTIC] [IPC Handler] Starting attempt ${attempt}/${maxRetries}`);
    try {
      log('info', `[DIAGNOSTIC] [FileOp] Auto-load attempt ${attempt}/${maxRetries} for ${filePath}`);

      // Check if file exists before attempting to read
      log('info', `[DIAGNOSTIC] [FileOp] Checking file access for ${filePath}`);
      await fsPromises.access(filePath, fs.constants.R_OK); // Check read access
      log('info', `[DIAGNOSTIC] [FileOp] File access check passed for ${filePath}`);
      log('info', `[DIAGNOSTIC] [FileOp] Calling loadAccountsFromFile for ${filePath}`);
      const accounts = await loadAccountsFromFile(filePath);
      log('info', `[DIAGNOSTIC] [FileOp] loadAccountsFromFile SUCCEEDED, returned ${accounts.length} accounts`);

      // Success - send accounts to renderer
      log('info', `[DIAGNOSTIC] [IPC] Preparing SUCCESS response with ${accounts.length} accounts`);
      
      // Check if sender is still valid
      if (sender.isDestroyed()) {
        log('error', `[DIAGNOSTIC] [IPC] Cannot send response - sender is destroyed`);
        return;
      }
      try {
        // Create response object
        const response = {
          success: true,
          accounts: accounts,
          filePath: filePath
        };

        log('info', `[DIAGNOSTIC] [IPC] Attempting to SEND success response for tester-specific-file-loaded`);
        event.sender.send('tester-specific-file-loaded', response);
        log('info', `[DIAGNOSTIC] [IPC] Successfully SENT success response for tester-specific-file-loaded`);
        return; // Exit after successful load
      } catch (sendError) {
        log('error', `[DIAGNOSTIC] [IPC] Error SENDING success response: ${sendError.message}`);
        log('error', `[DIAGNOSTIC] [IPC] Send Error stack: ${sendError.stack}`);
        // Treat send error as a failure for this attempt, allowing retry
        lastError = sendError; // Store send error to report if all retries fail
        log('warn', `[DIAGNOSTIC] [IPC Handler] Send failed on attempt ${attempt}, will retry if possible.`);
        // No 'throw' here, let the loop continue to the delay/next attempt
      }
    } catch (error) {
      log('error', `[DIAGNOSTIC] [IPC Handler] Caught error during attempt ${attempt}: ${error.message}`); // Log at start of catch
      lastError = error;
      log('warn', `[DIAGNOSTIC] [FileOp] Auto-load attempt ${attempt} failed (details above).`);
      
      if (attempt < maxRetries) {
        // Wait before retrying
        log('info', `[DIAGNOSTIC] [FileOp] Waiting ${retryDelay}ms before retry ${attempt + 1}`);
        await new Promise(resolve => setTimeout(resolve, retryDelay));
      }
    }
  }

  // All retries failed - send error to renderer
  log('error', `[DIAGNOSTIC] [IPC Handler] All ${maxRetries} attempts failed. Last error: ${lastError.message}`);

  // Send specific error message back to renderer
  let userMessage = lastError.message; // Default to the last error message
  if (lastError.code === 'ENOENT') {
    userMessage = `File not found: ${filePath}`;
  } else if (lastError.code === 'EACCES') {
    userMessage = `Permission denied reading file: ${filePath}`;
  }
  try {
    log('info', `[DIAGNOSTIC] [IPC] Attempting to SEND final error response for tester-specific-file-loaded`);
    event.sender.send('tester-specific-file-loaded', { success: false, error: userMessage, filePath: filePath });
    log('info', `[DIAGNOSTIC] [IPC] Successfully SENT final error response`);
  } catch (sendError) {
    log('error', `[DIAGNOSTIC] [IPC] CRITICAL - Failed to send final error response: ${sendError.message}`);
  }
});

// Handle reloading the current list from its source file
ipcMain.on('tester-reload-list-request', async (event) => {
  log('debug', '[IPC] Received tester-reload-list-request');
  const lastFilePath = store.get(STORE_KEY_TESTER_LAST_FILE_PATH);
  if (!lastFilePath || typeof lastFilePath !== 'string') {
    log('warn', '[IPC] tester-reload-list-request: No file path known for reload.');
    event.sender.send('tester-reload-list-result', { success: false, error: 'No file path known for reload.' });
    return;
  }
  log('info', `[FileOp] Attempting to reload file: ${lastFilePath}`);
  try {
    // Check if file exists before attempting to read
    await fsPromises.access(lastFilePath, fs.constants.R_OK); // Check read access
    const accounts = await loadAccountsFromFile(lastFilePath);
    // Send back the reloaded accounts
    log('debug', `[IPC] tester-reload-list-request: Sending ${accounts.length} reloaded accounts to renderer.`);
    event.sender.send('tester-reload-list-result', { success: true, accounts: accounts, filePath: lastFilePath });
    log('info', `[Tester Integration] Reload successful for ${lastFilePath}. Sent ${accounts.length} accounts.`);
  } catch (error) {
     log('error', `[FileOp] Error reloading file ${lastFilePath}: ${error.message}`);
     // Send specific error message back to renderer
     let userMessage = error.message;
     if (error.code === 'ENOENT') {
         userMessage = `File not found: ${lastFilePath}`;
     } else if (error.code === 'EACCES') {
         userMessage = `Permission denied reading file: ${lastFilePath}`;
     }
    event.sender.send('tester-reload-list-result', { success: false, error: userMessage, filePath: lastFilePath });
  }
});

// Handle setting debug mode state
ipcMain.on('tester-set-debug-mode', (event, isEnabled) => {
  log('debug', `[IPC] Received tester-set-debug-mode: ${isEnabled}`);
  latestDebugMode = !!isEnabled; // Ensure boolean
  store.set(STORE_KEY_TESTER_DEBUG_LOGGING, latestDebugMode);
  log('info', `[Store] Debug mode set to: ${latestDebugMode}`);
});

// Handle retrieving debug mode state
ipcMain.on('tester-get-debug-mode', (event) => {
  log('debug', '[IPC] Received tester-get-debug-mode');
  const isEnabled = store.get(STORE_KEY_TESTER_DEBUG_LOGGING, false); // Default to false
  log('debug', `[IPC] Sending tester-debug-mode-loaded: ${isEnabled}`);
  event.sender.send('tester-debug-mode-loaded', isEnabled);
  // log('info', `[Tester Integration] Sending loaded debug mode state: ${isEnabled}`); // Redundant with debug log
});

// Handle setting actual login mode state
ipcMain.on('tester-set-actual-login-mode', (event, isEnabled) => {
  log('debug', `[IPC] Received tester-set-actual-login-mode: ${isEnabled}`);
  store.set(STORE_KEY_TESTER_ACTUAL_LOGIN, !!isEnabled); // Ensure boolean
  log('info', `[Store] Actual login mode set to: ${!!isEnabled}`);
});

// Handle retrieving actual login mode state
ipcMain.on('tester-get-actual-login-mode', (event) => {
  log('debug', '[IPC] Received tester-get-actual-login-mode');
  const isEnabled = store.get(STORE_KEY_TESTER_ACTUAL_LOGIN, false); // Default to false
  log('debug', `[IPC] Sending tester-actual-login-mode-loaded: ${isEnabled}`);
  event.sender.send('tester-actual-login-mode-loaded', isEnabled);
});

// Handle setting disable devtools mode state
ipcMain.on('tester-set-disable-devtools-mode', (event, isEnabled) => {
  log('debug', `[IPC] Received tester-set-disable-devtools-mode: ${isEnabled}`);
  store.set(STORE_KEY_TESTER_DISABLE_DEVTOOLS, !!isEnabled); // Ensure boolean
  log('info', `[Store] Disable devtools mode set to: ${!!isEnabled}`);
});

// Handle retrieving disable devtools mode state
ipcMain.on('tester-get-disable-devtools-mode', (event) => {
  log('debug', '[IPC] Received tester-get-disable-devtools-mode');
  const isEnabled = store.get(STORE_KEY_TESTER_DISABLE_DEVTOOLS, false); // Default to false
  log('debug', `[IPC] Sending tester-disable-devtools-mode-loaded: ${isEnabled}`);
  event.sender.send('tester-disable-devtools-mode-loaded', isEnabled);
});

// Handle cleanup of processed accounts from file
ipcMain.handle('tester-cleanup-processed', async (event, filePath) => {
  log('debug', `[IPC] Handling 'tester-cleanup-processed' for file: ${filePath}`);
  if (!filePath) {
    return { success: false, error: 'File path is required.' };
  }

  try {
    // 1. Get current state
    const fileState = appState?.accountTester?.fileStates?.[filePath];

    if (!fileState) {
      log('debug', `[Cleanup] No state found for file ${filePath}. Nothing to clean.`);
      return { success: true, removedCount: 0, message: 'No state found for this file.' };
    }

    // 2. Read the account file content
    let fileContent;
    try {
      fileContent = await fsPromises.readFile(filePath, 'utf-8');
    } catch (readError) {
      if (readError.code === 'ENOENT') {
        log('error', `[Cleanup] Account file not found: ${filePath}`);
        return { success: false, error: `Account file not found: ${filePath}` };
      }
      throw readError; // Re-throw other read errors
    }

    const lines = fileContent.split(/\r?\n/);
    let originalCount = 0;
    const linesToKeep = [];

    // 3. Filter lines based on state
    for (const line of lines) {
      const trimmedLine = line.trim();
      if (!trimmedLine) continue; // Skip empty lines

      originalCount++;
      const accountKey = trimmedLine; // Assuming line is "user:pass" which is the key in state
      const status = fileState[accountKey];

      // Keep lines that are pending, testing, or not found in state
      if (!status || status === 'pending' || status === 'testing') {
        linesToKeep.push(line); // Keep the original line ending
      } else {
        log('debug', `[Cleanup] Removing tested account: ${accountKey} (Status: ${status})`);
      }
    }

    const removedCount = originalCount - linesToKeep.length;
    log('debug', `[Cleanup] Original lines: ${originalCount}, Lines to keep: ${linesToKeep.length}, Removed: ${removedCount}`);

    // 4. Write the filtered content back to the file
    await fsPromises.writeFile(filePath, linesToKeep.join('\n'), 'utf-8'); // Use '\n' for consistency
    log('debug', `[Cleanup] Successfully wrote cleaned file: ${filePath}`);

    // 5. Clean up the state to match the file contents
    // Create a new state object with only the kept accounts
    const newFileState = {};
    for (const line of linesToKeep) {
      const trimmedLine = line.trim();
      if (trimmedLine) {
        // If the account was in the original state, preserve its status
        // Otherwise, it will be undefined and handled appropriately by the renderer
        newFileState[trimmedLine] = fileState[trimmedLine];
      }
    }

    // Update the app state with the new file state
    appState.accountTester.fileStates[filePath] = newFileState;
    
    // Save the updated state
    await saveAppState();
    log('debug', `[Cleanup] Successfully updated state for file: ${filePath}`);

    return { success: true, removedCount: removedCount };

  } catch (error) {
    log('error', `[Cleanup] Error processing file ${filePath}:`, error);
    return { success: false, error: error.message || 'An unknown error occurred during cleanup.' };
  }
});
// --- End Tester IPC Handlers ---

// --- App State Management ---
// Create a default app state structure
const DEFAULT_APP_STATE = {
  accountTester: {
    currentFile: null,
    scrollIndex: {},  // Map of file paths to scroll positions
    filterQuery: {},  // Map of file paths to filter queries
    fileStates: {}    // Map of file paths to account states
  }
};

// In-memory app state (will be persisted to store)
let appState = { ...DEFAULT_APP_STATE };

// Initialize app state from store
function initializeAppState() {
  log('debug', '[AppState] Initializing app state from store');
  try {
    // Load from store if exists
    const storedState = store.get('app_state');
    if (storedState) {
      // Deep merge with default state to ensure all properties exist
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

// Save app state to store
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

// IPC handlers for app state
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
    // Deep merge the new state
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
    
    // Save to store
    await saveAppState();
    log('debug', '[IPC] App state updated successfully');
    return { success: true };
  } catch (error) {
    log('error', `[IPC] Error updating app state: ${error.message}`);
    return { success: false, error: error.message };
  }
});
// --- End App State Management ---

// --- IPC Handler for Setting Session User Agent ---
ipcMain.handle('set-user-agent', async (event, userAgent) => {
  if (userAgent && typeof userAgent === 'string') {
    try {
      // Use defaultSession
      await session.defaultSession.setUserAgent(userAgent);
      // console.log(`[Tester Integration] Session User-Agent set to: ${userAgent}`);
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
// --- End IPC Handler for Setting Session User Agent ---

const translate = (phrase) => {
  const {error, value} = translation.translate(phrase);
  if (error) {
    log("warn", error);
  }
  return value;
};

ipcMain.on("translate", (event, message) => {
  if (win) {
    win.webContents.send("translate", {
      phrase: message.phrase,
      requestId: message.requestId,
      value: translate(message.phrase),
    });
  }
});

// add flash plugin
app.commandLine.appendSwitch("ppapi-flash-path", path.join(__dirname, `${config.pluginPath}${config.pluginName}`));

app.on('certificate-error', (event, webContents, url, error, certificate, callback) => {
  console.log(`Certificate error: ${error} for ${url}`);
  event.preventDefault();
  callback(true); // Allow the invalid certificate
});

app.whenReady().then(() => {
  log('info', '[App] App ready event triggered.'); // Added log

  // Initialize app state
  initializeAppState();
  log('info', '[App] App state initialized.');

  // --- Ensure default tester delays exist in store ---
  if (!store.has(STORE_KEY_TESTER_INTER_TEST_DELAY)) {
    store.set(STORE_KEY_TESTER_INTER_TEST_DELAY, 1000);
    log('info', `[Store] Initialized default ${STORE_KEY_TESTER_INTER_TEST_DELAY}.`);
  }
  if (!store.has(STORE_KEY_TESTER_RETRY_DELAY)) {
    store.set(STORE_KEY_TESTER_RETRY_DELAY, 10000);
     log('info', `[Store] Initialized default ${STORE_KEY_TESTER_RETRY_DELAY}.`);
  }
  if (!store.has(STORE_KEY_TESTER_DEBUG_LOGGING)) { // Added check for debug mode default
    store.set(STORE_KEY_TESTER_DEBUG_LOGGING, false);
    log('info', `[Store] Initialized default ${STORE_KEY_TESTER_DEBUG_LOGGING}.`);
  }
  if (!store.has(STORE_KEY_TESTER_ACTUAL_LOGIN)) { // Added check for actual login default
    store.set(STORE_KEY_TESTER_ACTUAL_LOGIN, false);
    log('info', '[Store] Initialized default actualLoginEnabled.');
  }
  if (!store.has(STORE_KEY_TESTER_DISABLE_DEVTOOLS)) { // Added check for disable devtools default
    store.set(STORE_KEY_TESTER_DISABLE_DEVTOOLS, false);
    log('info', '[Store] Initialized default disableDevToolsEnabled.');
  }
  // --- End Ensure Defaults ---

  // --- Register Global Shortcuts ---
  function registerTesterShortcuts() {
    log('debug', '[Shortcut] Attempting to register shortcuts.');
    const retY = globalShortcut.register('CommandOrControl+Shift+Y', () => {
      log('info', '[Shortcut] Ctrl+Shift+Y pressed');
      if (win) {
        win.webContents.send('tester-trigger-works');
      }
    });
    if (!retY) {
      log('error', '[Shortcut] Failed to register Ctrl+Shift+Y');
    } else {
      log('info', '[Shortcut] Registered Ctrl+Shift+Y');
    }

    const retN = globalShortcut.register('CommandOrControl+Shift+N', () => {
      log('info', '[Shortcut] Ctrl+Shift+N pressed');
      if (win) {
        win.webContents.send('tester-trigger-does-not-work');
      }
    });
    if (!retN) {
      log('error', '[Shortcut] Failed to register Ctrl+Shift+N');
    } else {
      log('info', '[Shortcut] Registered Ctrl+Shift+N');
    }
  }
  // --- End Register Global Shortcuts ---


  const minWidth = 900;
  const minHeight = 550;

  // Create the browser window.
  win = new BrowserWindow({
    icon: __dirname + '/gui/images/icon.png',
    minWidth,
    minHeight,
    // 160% min size
    width: store.get("window.width") || 1440,
    height: store.get("window.height") || 880,
    x: store.get("window.x") || 0,
    y: store.get("window.y") || 0,
    useContentSize: true,
    resizable: true,
    webPreferences: {
      contextIsolation: true,
      webviewTag: true,
      nodeIntegration: false,
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
    win.webContents.session.clearCache(() => {});
  }

  loadClient();
  // Conditionally open DevTools based on setting
  const disableDevTools = store.get(STORE_KEY_TESTER_DISABLE_DEVTOOLS, false);
  log('info', `[DevTools] Disable Developer Console setting: ${disableDevTools}`);
  if (!disableDevTools) {
    log('info', '[DevTools] Opening Developer Console.');
    win.webContents.openDevTools();
  } else {
    log('info', '[DevTools] Developer Console disabled by setting.');
  }
  // Original config check (can be kept or removed depending on desired behavior)
  // if (config.showTools && !disableDevTools) {
  //   win.webContents.openDevTools();
  // }

  win.on("closed", () => {
    win = null;
    if (printWindow) {
      printWindow.close();
    }
  });

  win.on("resize", () => {
    const bounds = win.getBounds();
    store.set("window.width", bounds.width);
    store.set("window.height", bounds.height);
  });

  // Register shortcuts after window is ready
  registerTesterShortcuts();

  // Auto-loading is now handled entirely through the renderer's tester-specific-file-loaded path
  // This ensures consistent state restoration and UI updates
  log('info', '[App] Auto-loading will be handled by renderer process.');

});

app.on("window-all-closed", () => {
  log('info', '[App] window-all-closed event triggered.'); // Added log
  app.quit();
});

// Unregister shortcuts and attempt final save before quitting
app.on('will-quit', () => {
  log('info', '[App] will-quit event triggered.');

  // No need for final save of delays here, they are saved immediately via IPC
  try {
    log('info', `[Store] Attempting final save on will-quit: debug=${latestDebugMode}, actualLogin=${store.get(STORE_KEY_TESTER_ACTUAL_LOGIN)}, disableDevTools=${store.get(STORE_KEY_TESTER_DISABLE_DEVTOOLS)}`);
    // store.set(STORE_KEY_TESTER_INTER_TEST_DELAY, latestInterTestDelay); // Removed
    // store.set(STORE_KEY_TESTER_RETRY_DELAY, latestRetryDelay); // Removed
    store.set(STORE_KEY_TESTER_DEBUG_LOGGING, latestDebugMode); // Keep debug save
    // No need to save actualLogin or disableDevTools here, they are saved immediately via IPC
    log('info', '[Store] Final save attempt completed for debug mode.');
  } catch (err) {
    log('error', `[Store] Error during final save on will-quit: ${err}`);
  }

  globalShortcut.unregisterAll();
  log('info', '[Shortcut] Unregistered all global shortcuts.');
});
