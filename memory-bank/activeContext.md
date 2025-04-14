# Active Context: Strawberry Jam

> **Note:** This project is a fork of the original Jam by sxip. All new work, documentation, and branding is under the name "Strawberry Jam".

---

## Project Renaming (April 2025)

- **New Name:** The project is now officially **Strawberry Jam**.
- **Origin:** This is a fork of the original **Jam** project by **sxip** ([https://github.com/Sxip/jam](https://github.com/Sxip/jam)).
- **Action:** Nomenclature will be gradually updated from "Jam" to "Strawberry Jam" across documentation and code as files are modified. `.clinerules` and `README.md` have been updated.

---

## April 2025: Current Focus & Roadmap

**Immediate Priorities:**
- **UsernameLogger LeakCheck Stability:** Audit and fix the leak check logic in the UsernameLogger plugin. Issue: after running for a while, logs stop and restarting leak check in-session only displays indexes. Suspected cause: memory/resource leak, unhandled error, or state flag issue. Plan: Add robust error handling, ensure state resets, and test with large input. *Confirmed: process_logs.js is NOT used in UsernameLogger leak check logic.*
- **Settings Refactor:** Remove start/stop controls for leak check from the settings UI. Move LeakCheck API key to a dedicated "LeakCheck" section (with API key and directory selector). Ensure UsernameLogger fetches API key from settings at runtime via IPC. Rename "Network settings" to "Settings".
- **process_logs.js CLI Refactor:** Refactor process_logs.js to run fully headless/CLI, independent of the Electron app. Accept parameters via CLI/env, read settings.json directly if needed, and document usage.
- **svf_decompiled Packet Analysis:** Systematically inspect dev/SVF_Decompiled/scripts for privileged, mod, admin, or exploitable packets. Update packets.md with new findings in a dedicated section.

**Memory Bank Policy:** All new work, findings, and patterns are documented here and in progress.md/systemPatterns.md as appropriate.

---

## Current Focus

-   **Pushed Buddy List Plugin to GitHub:** Pushed the original `buddyListLogger` plugin to 'https://github.com/glvckoma/Buddy-list-plugin' for separate distribution. The plugin within *this* project has been refactored and renamed to `UsernameLogger`.

## Recently Completed

- **Advertising Plugin & IPC Refactor (April 2025):**
    - Refactored the IPC bridge for plugin state access (`dispatch.getState`) to use an asynchronous request/reply pattern between the main process and main renderer, ensuring reliable cross-window communication for UI plugins.
    - Added room state tracking in the dispatch system: hooks for `j#jr` (join room) and `j#l` (leave room) packets now update `dispatch.state.room` automatically.
    - Updated the advertising plugin's preview button: clicking "Preview" now sends the message typed in the UI to the game as a real packet, using the current room ID.
    - Confirmed that the advertising plugin has no extra Node.js dependencies and works in the built `.exe` without additional build configuration.
    - All changes tested and verified in both development and packaged builds.

-   **Distribution Readiness (April 2025):**
    -   **Privacy & Packaging:** Audited `.gitignore`, `settings.json`, `data/`, `plugins/UsernameLogger/config.json`. Updated `electron-builder.json` to exclude `data/**/*`, `assets/extracted-winapp/**/*`, `assets/memory-bank/**/*`, and `plugins/UsernameLogger/**/*` from builds. Fixed asset duplication under `resources/`.
    -   **Plugin Compatibility (.exe):**
        -   Exposed `XtMessage` via `dispatch.XtMessage` in `src/electron/renderer/application/index.js`.
        -   Updated `plugins/login/index.js` to use `dispatch.XtMessage` instead of `require`, resolving "Cannot find module" errors in packaged builds.
        -   Confirmed `axios` dependency is declared in `plugins/UsernameLogger/plugin.json` for .exe compatibility (though plugin is currently excluded from build).
        -   Updated `plugins/spammer/index.js` to wait for `dispatch` to be ready, improving .exe stability.
    -   **Dev Console:** Modified `src/electron/index.js` to prevent dev console from opening for plugins in production builds.
    -   **Plugin UI:** Added draggable headers and close buttons to `plugins/spammer/index.html` and `plugins/loginPacketManipulator/index.html`.
    -   **Extracted Client Version:** Updated version in `assets/extracted-winapp/package.json` to `1.5.7`.
    -   **Extracted Client Updates:** Confirmed update check logic (`checkForUpdates`) exists in `assets/extracted-winapp/index.js` and was not removed or commented out.
    -   **Install Directory Audit:** Reviewed install directory contents; build configuration updated to exclude development artifacts.
-   **UI/UX & Logging Improvements (April 2025):**
    -   **Play Button State:** Implemented logic to make the Play button opaque and unclickable during the ASAR patching process (`killProcessAndPatch`).
    -   **Log Retention:** Reviewed current log limits (`_maxLogEntries = 1000`, `_cleanPercentage = 0.2`); deemed acceptable for now.
    -   **Auto-Scroll:** Verified that existing `consoleMessage` logic should provide auto-scrolling for LeakCheck logs.
    -   **Advertising Plugin UI:** Added draggable header and close button to `plugins/advertising/index.html` for consistency.
-   **Advertising Plugin UI Fix (April 2025):**
    -   Modified `plugins/advertising/index.html` to correctly wait for `window.jam.dispatch` and utilize automatically injected jQuery, fixing unresponsive UI buttons.
    -   Updated `src/electron/index.js` to automatically inject jQuery into UI plugin windows and handle dev tools opening within `did-finish-load`.
...
