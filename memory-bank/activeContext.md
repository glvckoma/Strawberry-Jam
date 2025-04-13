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

-   **README.md Revamp (April 2025):**
    -   Overhauled the main `README.md` for clarity, accuracy, and completeness.
    -   Added prominent Security/ToS warnings.
    -   Updated Installation, Setup (incl. `hosts` file, API key config), Running, Usage (incl. `process_logs.js`), Plugin Development, Known Issues, and Troubleshooting sections based on current project state and memory bank context.

-   **process_logs.js CLI Refactor & Interactivity (April 2025):**
    -   Refactored `process_logs.js` into a standalone CLI script using `yargs` for argument parsing.
    -   Script now accepts API key, input/processed file paths, output directory, processing limit, and API delay via command-line arguments.
    -   Configuration loading prioritizes CLI arguments, then checks AppData config (`.../AppData/Roaming/jam/config.json`), falling back to root `settings.json` only if necessary.
    -   Removed dependencies on the Electron app context.
    -   Added a `--no-overwrite-input` flag to optionally preserve the original collected usernames file.
    -   Added interactive confirmation prompt using `inquirer` before starting the process (can be skipped with `--non-interactive`).
    -   Added a stop key listener using `readline` ('s' or Ctrl+C) to allow clean interruption and final batch writing.
    -   Improved console logging for better user feedback.
    -   Fixed `inquirer` import issue by using dynamic `import()`.
    -   Included usage instructions in comments.

-   **Settings Modal Refactor (April 2025):**
    -   Refactored the settings modal UI (`src/electron/renderer/application/modals/settings.js`).
    -   Renamed modal title from "Network Settings" to "Settings".
    -   Removed the LeakCheck start/pause/stop buttons and status display.
    -   Created a dedicated "LeakCheck Settings" section.
    -   Moved the LeakCheck API Key input and Output Directory selector into the new section.
    -   Removed associated JavaScript logic for the deleted buttons and status elements.

-   **LeakCheck Logic Fix & Optimization (April 2025):**
    -   Audited and refactored the leak check logic in UsernameLogger. The main processing loop is now wrapped in robust error handling, with a `resetLeakCheckState` helper to ensure `isLeakCheckRunning` and `isLeakCheckPaused` are always reset after completion, stop, pause, or error.
    -   **Optimization:** Implemented batch file writing for leak check results (`processed`, `found`, `ajc`, `potential` files). Instead of appending on every username, results are collected in arrays and written periodically (every 100 usernames) and at the end/pause/stop. This significantly reduces file I/O overhead and should prevent slowdown during long runs.
    -   This prevents the plugin from getting "stuck" and allows leak check to be stopped and restarted reliably within the same session.
    -   Additional logging was added for state transitions and errors. The plugin is now more robust against unhandled exceptions, resource leaks, and I/O bottlenecks during leak checking.

-   **UsernameLogger & TradeLogger Plugin Refactors (April 2025):**
    -   Updated both plugins to use a consistent, object-based constructor signature for compatibility with the current plugin API.
    -   Cleaned up and streamlined the UsernameLogger command set: removed all legacy/alias commands (`buddylog`, `buddylogpath`), removed redundant commands (`leakcheckpause`, `leakcheckstatus`), and renamed `clearlogs` to `clearleaklogs` (now only clears leak check result files).
    -   Added a user-friendly `userloghelp` command with clear, prefix-free help text.
    -   Improved debug output: API key status is now concise and user-friendly, with fallback only if needed.
    -   Fixed plugin instantiation errors (e.g., "this.dispatch.onMessage is not a function" in tradeLogger).
    -   Verified that both plugins load and operate cleanly with no legacy command registration or confusing logs.
-   **TradeLogger Plugin Deployed:** Created and enabled a plugin that logs both trade-related and shop-related XT packets ("ti", "ts", "tl", "tb", "ka", "dsi") to `data/trade_packets.log`. This supports systematic analysis of shop access issues for trade-locked users and further protocol research.
-   **Comprehensive README.md Created:** Added a detailed README at the project root, covering project overview, installation, usage, plugin development, troubleshooting, and security.
-   **ASAR Patching Speed and Reliability Improved:** Refactored patching logic to use process tree cleanup (`tree-kill`), ensuring all game/Electron/bash processes are terminated and the original `app.asar` is restored promptly and reliably in both development and distribution environments.
-   **Fixed Network Packet Logs Auto-Clearing:** Fixed the auto-clearing functionality for network packet logs to work consistently like the console log auto-clear. The issue was caused by duplicate append operations and incorrect packet log count tracking.
-   **Refactored & Fixed Buddy List Logging Plugin:**
    -   Refactored `plugins/buddyListLogger/index.js` to export a class, resolving plugin loading errors.
    -   **Fixed API Key Loading (Attempt 2):** Modified the plugin's `runLeakCheck` method to fetch the LeakCheck API key directly from the main process store via IPC (`ipcRenderer.invoke('get-setting', ...)`) *at the time the command is executed*. This ensures IPC is ready and avoids issues with loading the key during instantiation. Removed previous attempts to load the key via `application.settings.get()` or pass it via the constructor.
    -   Consolidated username logging (nearby + leak check results) into a single `collected_usernames.txt` file.
    -   Standardized data file names (`processed_usernames.txt`, `potential_accounts.txt`, `found_accounts.txt`, `ajc_accounts.txt`).
    -   Removed the automatic data migration logic (`migrateData` function) as file renaming was handled manually.
    -   Fixed pause/stop commands by adding an explicit stop check within the `runLeakCheck` loop and ensuring state flags are set correctly.
    -   Corrected `ajcConfirmedPath is not defined` error by using the correct variable (`ajcAccountsPath`) in a logging statement.
-   **Disabled Auto-Clear in Username Logger:** Commented out the automatic clearing of `collected_usernames.txt` after a leak check completes to prevent data loss from usernames collected during the check.
-   **Renamed `buddyListLogger` Plugin:** Renamed the plugin directory and updated internal references (code, config, readme) to `UsernameLogger` (the original `buddyListLogger` was moved externally).
-   **Updated Potential Account Handling:** Modified the `Username Logger` plugin to add usernames with invalid characters (that are added to `potential_accounts.txt`) to `processed_usernames.txt` as well. **Rationale:** This prevents re-checking usernames that failed initial validation due to special characters and require manual review.
-   **Removed API Key Init Warning:** Removed the console warning message in `UsernameLogger` about the API key not being found during instantiation, as the key is fetched on demand.
-   **Removed Debug Logs:** Commented out debug `console.log` statements related to initial state loading and button updates in `src/electron/renderer/application/modals/settings.js`.

## Recent Activities & Findings

### 1. ASAR Patching Process Analysis

The current ASAR patching process in `Patcher` class (`src/electron/renderer/application/patcher/index.js`) works as follows:
- `patchApplication()`: Backs up original `app.asar`, copies custom ASAR, clears cache
- `killProcessAndPatch()`: Orchestrates patching, launching the game, and restoring the original ASAR
- `restoreOriginalAsar()`: Restores the backed-up `app.asar`

The restoration process can take minutes to complete because it waits for the game process to fully exit before restoring the original ASAR. This delay impacts user experience when restarting the game.

### 2. Trade Lock Packet Analysis

Initial analysis shows identical packet structure between locked and non-locked accounts. The only difference is the numeric ID (likely a session/room ID). This suggests trade locking is enforced server-side rather than through packet differences.

### 3. Network Packet Logs Auto-Clearing Issue (Status Uncertain)

The console log auto-clearing works via `_cleanOldLogs()` in `src/electron/renderer/application/index.js`. This method also contains logic for packet log cleaning, but its current functionality is uncertain and requires testing/verification. Previous notes indicated it was fixed, but confirmation is needed.

### 4. ~~Buddy List Logging Requirements~~ (Outdated)

~~Need to create a separate plugin for buddy list logging with:~~
~~- Enable/disable functionality via console command~~
~~- Proper logging with timestamps~~
~~- State persistence~~
*(This requirement is outdated. The original `buddyListLogger` was moved externally. The current `UsernameLogger` handles relevant logging within this project).*

### 5. GitHub README Development

Need to develop a comprehensive README for GitHub distribution covering:
- Project overview and purpose
- Installation instructions
- Usage guide
- Feature documentation
- Plugin development guide
- Troubleshooting section
- Security considerations

## 5. Next Steps

1.  **Update Memory Bank:** (Complete) Documented recent distribution readiness and UI/UX changes.
2.  **UI/UX & Log Improvements:**
    -   Implement virtualized rendering for console/network logs to improve performance.
    -   Review/adjust log retention limits if performance issues persist.
3.  **SVF Decompiled Analysis:**
    -   Inspect enums for def id/name fetching methods.
    -   Search for keep-alive/anti-logout packets.
4.  **Develop Invisible Mod Command Plugin:** Implement a new plugin to toggle invisibility using the `%xt%fi%-1%` packet (and the correct "off" command, to be determined). Provide a simple console command for toggling, and include a clear warning in the README about the risks of using mod commands.
5.  **Improve ASAR Patching Speed:**
    -   Modify `killProcessAndPatch()` to use a timeout for restoration.
    -   Consider implementing a separate process for restoration.
    -   Explore file system optimization options.
6.  **Continue Trade Lock Packet Analysis:**
    -   Conduct deeper analysis of trade-related packets.
    -   Monitor for additional packets that might appear only in successful trades.
    -   Examine server responses to trade packets.
    -   Investigate user flag packets related to account status.
7.  **Network Packet Logs Auto-Clearing (Verification):**
    -   Test and verify the current implementation of network packet log auto-clearing.
    -   Fix any remaining issues to ensure logs are managed consistently.

*Note: All Account Tester/ASAR-patched client and related UI work is now tracked exclusively in `assets/memory-bank/`. Only core Strawberry Jam proxy, plugin, and Electron app development is tracked here.*
