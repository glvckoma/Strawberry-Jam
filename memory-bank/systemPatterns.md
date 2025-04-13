# System Patterns: Strawberry Jam

> **Note:** This project is a fork of the original Jam by sxip. All new work, documentation, and branding is under the name "Strawberry Jam".

---

## April 2025: Patterns & Integration

- **Plugin Settings Access Pattern:** Plugins (e.g., UsernameLogger) must fetch sensitive settings (like API keys) from the main process via IPC (`ipcRenderer.invoke('get-setting', ...)`) at the time the setting is needed (e.g., inside a command handler). Loading settings during plugin instantiation is unreliable.
- **Separation of Concerns:** process_logs.js is a standalone CLI script and is not used for leak checking logic inside UsernameLogger. All plugin logic is self-contained.
- **Staged, Test-Driven Workflow:** Features are delivered in stages, starting with the easiest task. User tests after each stage before proceeding. All changes and findings are documented in the memory-bank.
- **Robust Error Handling & State Reset for Long-Running Tasks:** Long-running plugin tasks (e.g., UsernameLogger leak check) must wrap their main processing loop in robust error handling (try/catch/finally or equivalent). A dedicated reset helper should always clear state flags (e.g., isLeakCheckRunning, isLeakCheckPaused) after completion, stop, pause, or error. This prevents plugins from getting "stuck" and ensures reliable stop/restart within the same session.
- **Batch File Writes for Performance:** For loops involving frequent file appends (like UsernameLogger leak check results), collect data in temporary arrays/sets within the loop. Write the collected data to the target files in batches (e.g., every N iterations or at the end/pause/stop) using a helper function. This significantly reduces I/O overhead and prevents performance degradation on large datasets.
- **Standalone CLI Scripts:** For tasks requiring independence from the Electron app (e.g., batch processing, long-running checks like `process_logs.js`), create standalone Node.js scripts.
    - Use `yargs` for robust command-line argument parsing (API keys, paths, limits, flags) and provide clear usage instructions (`.usage()`, `.epilogue()`, `.help()`).
    - Prioritize CLI arguments for configuration, potentially falling back to reading application config files (e.g., AppData `config.json`) or project files (`settings.json`) if appropriate. Clearly log the configuration source.
    - For interactive use, employ `inquirer` (using dynamic `import()`) to prompt the user for confirmation before execution. Include a `--non-interactive` flag to bypass prompts.
    - For long-running processes needing interruption, use `readline` to listen for specific keypresses (e.g., 's') or Ctrl+C to trigger a clean shutdown, ensuring final operations (like batch writes) are completed.
- **Memory Bank Update Policy:** All new work, patterns, and findings are documented in activeContext.md, progress.md, and systemPatterns.md as appropriate, per project policy.

---

## Core Architecture

Jam follows a typical Electron application structure combined with a network proxy:

1.  **Main Process (`src/electron/index.js`):**
    *   Manages the application lifecycle and native OS interactions.
    *   Creates the main browser window (`BrowserWindow`).
    *   Sets up insecure `webPreferences` for the renderer process (`nodeIntegration: true`, `contextIsolation: false`, etc.).
    *   Handles IPC communication from the renderer (window controls, file/URL opening via `ipcMain.on`).
    *   Spawns a separate Node.js process for the internal API server (`src/api/index.js`) using `child_process.fork`, enabling IPC between main and API processes.
    *   Instantiates the `Server` class (`src/networking/server/index.js`) which listens for the game client.
    *   Handles custom `app://` protocol for serving local assets via `protocol.handle`.
    *   Handles auto-updates via `electron-updater`.
    *   Implements startup proxy selection logic (`_selectAndTestProxyAtStartup`), setting `process.env.JAM_SELECTED_PROXY`.

2.  **Renderer Process (`src/electron/renderer/index.js`):**
    *   Entry point instantiates the core `Application` class (`src/electron/renderer/application/index.js`).
    *   `Application` class manages UI logic, holds references to `Server`, `Settings`, `Patcher`, `Dispatch`, `ModalSystem`.
    *   Runs the web-based UI (HTML, CSS - Tailwind, JS - jQuery).
    *   Has full Node.js access due to insecure settings (`nodeIntegration: true`, `contextIsolation: false`).
    *   **IPC Communication:** Because `contextIsolation` is `false`, the preload script (`src/electron/preload.js`) runs in the same context. Renderer code (like modals) accesses IPC functionality by directly requiring it: `require('electron').ipcRenderer`. No `contextBridge` or preload whitelisting is used or needed for this window.
    *   Handles plugin loading, message dispatching, command registration, state management, and timer wrapping via the `Dispatch` class (`src/electron/renderer/application/dispatch/index.js`).
    *   Executes command callbacks registered in `Dispatch` via logic in `Application` class (lacks robust error handling around callback execution, contributing to instability).
    *   Uses `ipcRenderer` (required directly) to communicate with the Main process (e.g., for window controls). Listens for IPC messages from Main (e.g., `credentials-from-api`).
    *   Uses `application.consoleMessage` for logging to the UI console; **this method throws the "Invalid Status Type" error if an unknown message `type` is provided**, making it a primary suspect for this recurring error.
    *   Overrides `console.log` to redirect to `application.consoleMessage`.
    *   Exposes core components (`application`, `dispatch`, `settings`, `server`) globally via `window.jam` for UI plugins.

3.  **Network Proxy (`src/networking/`):**
    *   **Server (`server/index.js`):** `Server` class uses Node.js `net.createServer` to listen on `127.0.0.1:443` (requires privileges). For each incoming game client connection (`_onConnection`), it instantiates a `Client`.
    *   **Client (`client/index.js`):** `Client` class manages paired sockets (`_connection` to local client, `_aj` to remote server).
        *   Connects `_aj` using `net.Socket` or `tls.TLSSocket` based on `secureConnection` setting. Uses `rejectUnauthorized: false` for TLS.
        *   **Proxy Agent:** Reads `process.env.JAM_SELECTED_PROXY` (set at startup) and uses `https-proxy-agent` to route the outgoing `_aj` connection if a proxy is specified.
        *   Provides `sendRemoteMessage` (to server) and `sendConnectionMessage` (to client).
    *   **Message Handling (`messages/`, `transform/`):**
        *   Uses `DelimiterTransform` (null byte `\x00`) stream to split raw TCP data into packets.
        *   `Client.validate` identifies message types (XML, XT, JSON) based on delimiters (`<>`, `%%`, `{}`).
        *   Instantiates specific message classes (`XmlMessage`, `XtMessage`, `JsonMessage`) which parse the raw string (using `cheerio` for XML, `split` for XT, `JSON.parse` for JSON) and provide a `toMessage()` method.
        *   `Client._onMessageReceived` calls `dispatch.all()` to allow plugin hooks to intercept/modify messages (via `message.send = false`).
        *   Forwards messages between client/server unless blocked by plugins or specific conditions (e.g., `preventAutoLogin`). Handles Flash cross-domain policy requests.

4.  **Plugin System (`plugins/`, `src/electron/renderer/application/dispatch/index.js`):**
    *   Managed by the `Dispatch` class.
    *   Plugins loaded from `plugins/` based on `plugin.json` manifests (validated using `ajv`), including the `Username Logger` (previously `buddyListLogger`).
    *   **Dependency Management:** Uses `live-plugin-manager` to install dependencies listed in `plugin.json` at runtime (security risk). Provides `dispatch.require()` to access these dependencies.
    *   **Plugin Loading:**
        *   **Game-type plugins:** Default type. Loaded using `require()` directly in the insecure renderer process (security risk). **Crucially, the plugin's main file (`index.js`) MUST export a class or constructor function.** The `Dispatch` class instantiates the plugin using `new PluginInstance(...)`. Receives `dispatch` and `application` instances in the constructor.
        *   **UI-type plugins:** Defined by `"type": "ui"` and `"main": "index.html"`. Loaded into separate windows via `dispatch.open()`. Access core functionality via the global `window.jam` object.
    *   **Plugin Settings/Data Access:** Accessing sensitive data stored in the main process (like API keys from `electron-store`) from within a renderer-process plugin can be tricky due to timing/context. The most reliable pattern found so far is for the plugin to use `require('electron').ipcRenderer.invoke('channel-name', ...)` *at the point the data is needed* (e.g., within a command handler like `runLeakCheck`) to request it from the main process. Attempts to load the key during plugin instantiation (either directly in the plugin or via the `Dispatch` loader) have proven unreliable.
    *   **Event Handling:** Provides `dispatch.onMessage` (for network packets), `dispatch.onCommand` (for chat commands), `dispatch.offMessage`, `dispatch.offCommand`.
    *   **Actions:** Provides `dispatch.sendRemoteMessage`, `dispatch.sendConnectionMessage`, `dispatch.setInterval`, `dispatch.clearInterval`, `dispatch.setState`, `dispatch.getState`.
    *   **Instability:** The `dispatch.onCommand` callback execution and `dispatch.sendRemoteMessage` from timers (`setInterval`) are known sources of instability ("Invalid Status Type" error). Synchronous file I/O during plugin load can also cause errors.

5.  **Internal API (`src/api/`):**
    *   A simple Express.js server (`src/api/index.js`) running in a separate process via `child_process.fork`.
    *   Listens on port 8080.
    *   Routes defined in `src/api/routes/index.js`:
        *   Serves local `ajclient.swf` via `FilesController.game`.
        *   Proxies other asset requests to AJ CDN (`ajcontent.akamaized.net`) via `FilesController.index` using `HttpClient.proxy` (which uses the deprecated `request` library).
        *   Includes `/api/send-credentials` (POST) endpoint to receive login details (e.g., from external tools) and send them to the main Electron process via `process.send` (IPC).
        *   Includes `/api/get-pending-credentials` (GET) as a fallback retrieval method.

6.  **Patcher (`src/electron/renderer/application/patcher/index.js`):**
    *   `Patcher` class handles modifying the AJ Classic client installation.
    *   `patchApplication()`: Backs up original `app.asar`, copies custom `winapp.asar` or `osxapp.asar` over it, clears/recreates game cache. Uses `process.noAsar = true` during modification.
    *   `restoreOriginalAsar()`: Restores the backed-up `app.asar`.
    *   `killProcessAndPatch()`: Orchestrates patching, launching the game executable (`execFileAsync`), and restoring the original ASAR afterwards. Attempts to pass credentials received via IPC by setting `process.env.AJC_USERNAME` and `process.env.AJC_PASSWORD`, relying on the custom ASAR to read them. Contains outdated proxy logic (setting `JAM_PROXY_TARGET`).
    *   **Dependency Requirement:** For the patched ASAR (`winapp.asar` / `osxapp.asar`) to function correctly, the source directory (`assets/extracted-winapp`) *must* contain a `node_modules` folder with versions of dependencies compatible with the game client's Electron/Node.js environment *before* packing with `npx asar pack`. Simply running `npm install` in the source directory may install incompatible versions. Copying `node_modules` from a known-good extracted ASAR is the recommended approach.

## Key Design Patterns & Decisions

-   **Man-in-the-Middle (MITM):** Core pattern. Relies on local redirection (`hosts` file) to route game traffic to Jam's `Server` listening on `127.0.0.1:443`.
-   **ASAR Patching:** Modifies the game client's `app.asar` using the `Patcher` class to inject necessary hooks or modifications. Uses `process.noAsar = true` during patching.
-   **Event-Driven:** Node.js event listeners (`net.Server`, `Socket`, `TLSSocket`), Electron IPC (`ipcMain`, `ipcRenderer`), and custom event system via `Dispatch` (`onMessage`, `onCommand`).
-   **Modular Plugins:** Extensibility via `Dispatch`. Security risks due to `live-plugin-manager` and direct `require()` in renderer. Stability issues with `onCommand` callbacks and timed `sendRemoteMessage`. Shared state via `dispatch.setState/getState`. UI plugins access core via `window.jam`. The `UsernameLogger` plugin is the primary example in this project (the original `buddyListLogger` was moved externally).
-   **Settings Persistence:** `Settings` class manages `settings.json` using `fs.promises` and `lodash.debounce` for saving.
-   **Insecure by Design:** Deliberate disabling of Electron security (`nodeIntegration`, `contextIsolation`, `webSecurity`) and TLS validation (`rejectUnauthorized: false`) to enable MITM and plugin functionality.
-   **Workarounds:** External scripts (`process_logs.js`) used for complex/API-dependent tasks due to internal instability. ~~`defpackHelper` plugin created to isolate MCP calls from UI plugin context.~~ (DefPack helper plugin not present/used).
-   **Proxy Rotation:** Implemented via `HttpsProxyAgent` in `Client.connect`, configured by environment variable (`JAM_SELECTED_PROXY`) set at startup by logic in `src/electron/index.js`. (Outdated logic exists in `Patcher`). **Note:** Attempts to implement dynamic/session-based proxy rotation failed and were reverted.
