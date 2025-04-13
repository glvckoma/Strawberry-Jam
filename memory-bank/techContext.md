# Technical Context: Strawberry Jam

> **Note:** This project is a fork of the original Jam by sxip. All new work, documentation, and branding is under the name "Strawberry Jam".

## Core Technologies

-   **Runtime:** Node.js (v20.16.0). The `Username Logger` plugin (refactored from the original `buddyListLogger`, which was moved externally) is the primary plugin example.
-   **Framework:** Electron (v32.0.1) - Used for creating the cross-platform desktop application shell.
-   **UI:** HTML, CSS (Tailwind CSS), JavaScript (including jQuery).
-   **Networking:** Node.js `net` and `tls` modules for TCP/TLS proxying.
-   **API Server:** Express.js (v4.17.1) - Used for an internal API (port 8080), primarily for serving assets like the modified SWF.
-   **Package Management:** npm (v10.8.2 used as a dependency, system npm also required).

## Key Dependencies

-   `electron`: Core framework.
-   `electron-builder`: Used for packaging the application.
-   `ajv`: JSON Schema validator (used in `Dispatch` for `plugin.json`).
-   `cheerio`: Server-side HTML/XML parser (used in `XmlMessage.js`).
-   `electron-updater`: Handles application updates (used in `src/electron/index.js`).
-   `express`: Runs the internal API server (`src/api/`).
-   `axios`: Used for external API calls (`process_logs.js`, startup proxy test).
-   `https-proxy-agent`: Used in `Client.js` for proxy rotation.
-   `live-plugin-manager`: Used by `Dispatch` to dynamically install plugin dependencies (security risk).
-   `lodash`: Used for `debounce` in `Settings.js`.
-   `nodemon`: Used for development (`npm run dev`).
-   `cross-env`: Used for setting environment variables in npm scripts.
-   `tailwindcss`: Used for CSS styling (compiled via `nodemon`).
-   `request`, `request-promise-native`: Deprecated HTTP clients (used in `HttpClient.js`).
-   `eslint`: Used for code linting.
-   *Note:* Settings (`settings.json`) are managed manually via the `Settings` class (`fs.promises`), not `electron-store`.

## Development Setup

-   Clone repository: `git clone https://github.com/Sxip/jam.git`
-   Install dependencies: `cd jam && npm install`
-   Run in development mode: `npm run dev` (uses `nodemon` for auto-restarts).

## Technical Constraints & Issues

-   **Electron Security Configuration:** Runs with highly insecure settings (`webSecurity: false`, `nodeIntegration: true`, `contextIsolation: false`, `enableRemoteModule: true`), significantly increasing vulnerability by giving renderer process full Node.js access.
-   **TLS Validation:** Disables TLS certificate validation (`rejectUnauthorized: false` in `Client.js`) when connecting to the game server, enabling MITM but creating security risks on untrusted networks.
-   **Internal Stability ("Invalid Status Type"):** Exhibits recurring errors, strongly suspected to originate from `application.consoleMessage` when passed an invalid `type`. Triggered by unstable command callbacks (`dispatch.onCommand`), timed packet sending (`dispatch.setInterval` + `sendRemoteMessage`), and potentially synchronous file I/O during plugin load (`nearbyUsernames`).
-   **Plugin Security Risks:**
    *   Uses `live-plugin-manager` for runtime dependency installation (arbitrary code execution risk).
    *   Loads "game" type plugins via `require()` directly into the insecure renderer process (arbitrary code execution risk).
-   **Deprecated Dependencies:** Relies on unmaintained libraries (`request`, `request-promise-native` in `HttpClient.js`).
-   **Synchronous I/O:** Uses `fs.readFileSync` during plugin load (`nearbyUsernames`), potentially causing blocking or errors.
-   **DefPack Management (External/Out of Scope):** Lacks built-in support. Relies on external files or tools. DefPacks are currently considered out of scope for this project's active development.
-   **Client Interaction:** Relies on `hosts` file modification for MITM redirection. Modifies the AJC client's `app.asar` using the `Patcher` class.
-   **Privilege Requirement:** Requires elevated privileges (`sudo`/Admin) to run, due to binding to privileged port 443 (`Server.js`).
-   **AJ Play Wild Support (Likely Outdated):** Documentation (`docs/play-wild.md`) suggests potential support for proxying AJ Play Wild, but this is likely outdated as the current focus is AJ Classic.
-   **ASAR Dependency Incompatibility:** Dependencies installed via `npm install` (using modern Node.js) into `assets/extracted-winapp/node_modules` may use syntax (e.g., `require('fs/promises')`) incompatible with the older Node.js version bundled in the AJ Classic client's Electron runtime. Packing these incompatible modules leads to "Cannot find module" or syntax errors at runtime. Requires using compatible `node_modules` (e.g., copied from a working extracted ASAR) when packing.
-   **Plugin Settings Access Pattern:** Accessing settings stored in the main process (e.g., API keys via `electron-store`) from renderer-based plugins is unreliable during initial plugin load (`constructor` or `loadConfig`). The current working pattern is for the plugin to fetch the required setting via `require('electron').ipcRenderer.invoke('get-setting', 'settingKey')` *at the time the setting is needed* (e.g., inside the command handler that uses the API key).
