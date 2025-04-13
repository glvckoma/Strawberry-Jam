# Login Packet Manipulator UI Plugin

**For Strawberry Jam (fork of Jam by sxip)**  
Author: Glockoma

---

## Overview

This UI plugin allows you to view, intercept, edit, block, and replay login-related packets (both outgoing and incoming) during the Animal Jam Classic login flow. It is designed for protocol research, experimentation, and advanced debugging.

**WARNING:** Manipulating login packets can result in account bans, instability, or data loss. Use at your own risk. This tool is for educational and research purposes only.

---

## Features

- **Dynamic Packet Editor:**  
  Automatically displays all fields and params present in each intercepted login packet. The UI adapts to the structure of each packet, so any param (e.g., `email`, `pendingEmail`, etc.) will appear as an editable field if present.
- **Live Interception:**  
  View and modify packets in real time as they are received.
- **Replay & Block:**  
  Instantly resend or block any packet.
- **Status Panel:**  
  All plugin actions are logged to the status panel and the main console.

---

## Installation

1. **Copy the Plugin Folder:**  
   Place the entire `loginPacketManipulator` folder in your `plugins/` directory.

2. **Enable the Plugin:**  
   - Ensure `plugin.json` is present and `"type"` is `"ui"`.
   - Load the plugin from the Strawberry Jam UI.

---

## Usage

- The plugin window will open and display incoming login packets.
- All fields and params present in the packet will be shown as editable fields.
- Edit any value and click "Send Modified Login Packet to Client" to send your changes.
- The UI will always reflect the actual structure of the intercepted packet.

---

## Required Modifications to Jam/Strawberry Jam

> **This plugin requires core modifications to the Jam/Strawberry Jam codebase to work.**  
> These changes are NOT present in upstream Jam and must be applied to your fork.

### 1. `src/electron/preload.js`

- **Expose `window.jam.onPacket`** to UI plugins:
  ```js
  // At the end of preload.js
  const { ipcRenderer } = require('electron');
  window.jam = window.jam || {};
  window.jam.onPacket = function (callback) {
    if (typeof callback !== 'function') return;
    ipcRenderer.on('packet-event', (event, packetData) => {
      try { callback(packetData); } catch (err) { console.error(err); }
    });
  };
  ```

### 2. `src/electron/index.js`

- **Broadcast packet events to all renderer/plugin windows:**
  ```js
  const { ipcMain, BrowserWindow } = require('electron');
  ipcMain.on('packet-event', (event, packetData) => {
    const windows = BrowserWindow.getAllWindows();
    windows.forEach(win => {
      if (win && win.webContents && !win.webContents.isDestroyed()) {
        win.webContents.send('packet-event', packetData);
      }
    });
  });
  ```

### 3. `src/electron/renderer/application/index.js`

- **Send packet events to main process when a packet is processed:**
  ```js
  const { ipcRenderer } = require('electron');
  // Wherever packets are processed:
  ipcRenderer.send('packet-event', {
    raw: message.toMessage(),
    // ...any other relevant data
  });
  ```

> **Note:**  
> The exact location for sending the packet event may vary depending on your Jam fork's architecture.  
> The key is to ensure that every time a packet is received or sent, the event is forwarded to the main process and then broadcast to all windows.

---

## Example Patch Workflow

1. Apply the above code snippets to your Jam/Strawberry Jam fork.
2. Rebuild or restart the app to ensure the changes take effect.
3. Place the `loginPacketManipulator` plugin in your `plugins/` directory.
4. Load the plugin from the UI.

---

## Warnings & Disclaimers

- **Account Safety:**  
  Manipulating login packets can break your session, cause crashes, or result in bans.
- **Security:**  
  This plugin relies on insecure Electron settings and IPC. Do not use on untrusted systems.
- **Distribution:**  
  If you distribute this plugin, make it clear that it requires a patched Jam/Strawberry Jam core.

---

## License

MIT

---
