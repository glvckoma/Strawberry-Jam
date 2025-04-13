# Progress & Status: Strawberry Jam

> **Note:** This project is a fork of the original Jam by sxip. All new work, documentation, and branding is under the name "Strawberry Jam".

---

## April 2025: Roadmap & Status Update

**Current Roadmap:**
- **1. UsernameLogger LeakCheck Fix:** Audit and fix the leak check logic in the UsernameLogger plugin (logs stop after a while, restart only shows indexes). Add robust error handling, ensure state resets, and test with large input. *Confirmed: process_logs.js is NOT used in UsernameLogger leak check logic.*
- **2. Settings Refactor:** Remove start/stop controls for leak check from settings UI. Move LeakCheck API key to a dedicated section (with API key and directory selector). Ensure UsernameLogger fetches API key from settings at runtime via IPC. Rename "Network settings" to "Settings".
- **3. process_logs.js CLI Refactor:** Refactor process_logs.js to run fully headless/CLI, independent of the Electron app. Accept parameters via CLI/env, read settings.json directly if needed, and document usage.
- **4. svf_decompiled Packet Analysis:** Systematically inspect dev/SVF_Decompiled/scripts for privileged, mod, admin, or exploitable packets. Update packets.md with new findings in a dedicated section.

**Staged Approach:**  
Proceed with the easiest task first, allow user to test, then move to the next. All findings and changes are documented in the memory-bank.

---

## What Works

-   **process_logs.js CLI Refactor & Interactivity (April 2025):** Refactored `process_logs.js` into a standalone CLI script using `yargs`. Accepts configuration (API key, paths, limit, delay) via arguments, removing Electron dependency. Added interactive confirmation prompt (`inquirer`), stop key listener (`readline`), improved API key detection (CLI > AppData > Root Settings), and enhanced user feedback. Includes usage instructions.

-   **Settings Modal Refactor (April 2025):** Refactored the settings modal UI and logic. Renamed title to "Settings", removed LeakCheck start/stop/status controls, created a dedicated "LeakCheck Settings" section containing the API Key input and Output Directory selector.

-   **UsernameLogger LeakCheck Logic Fix & Optimization (April 2025):**
    - Leak check logic in UsernameLogger is now robust against unhandled exceptions and resource leaks. The main loop is wrapped in error handling, and a `resetLeakCheckState` helper ensures state flags are always reset after completion, stop, pause, or error.
    - **Optimization:** Implemented batch file writing for leak check results (`processed`, `found`, `ajc`, `potential` files) to reduce file I/O overhead and prevent slowdown during long runs.
    - The plugin can now reliably stop and restart leak checks within the same session, with improved logging for state transitions and errors.

-   Core proxy functionality.
-   Basic UI.
-   Packet viewing.
-   External log processing script (`process_logs.js`).
-   ~~DefPack data files available.~~ (DefPacks are external/out of scope).
-   GitHub Actions build workflow (Windows).
-   Partial plugin functionality (UI loading, some core functions).
-   Startup-based proxy rotation mechanism.
-   **TradeLogger Plugin:** Logs both trade-related and shop-related XT packets ("ti", "ts", "tl", "tb", "ka", "dsi") to `data/trade_packets.log` for systematic analysis of shop access and trade lock issues.
-   **UsernameLogger & TradeLogger Plugin Refactors (April 2025):**
    -   Both plugins now use a consistent, object-based constructor signature for compatibility with the current plugin API.
    -   UsernameLogger command set is streamlined: all legacy/alias commands (`buddylog`, `buddylogpath`) and redundant commands (`leakcheckpause`, `leakcheckstatus`) removed; `clearlogs` renamed to `clearleaklogs` (now only clears leak check result files).
    -   Added a user-friendly `userloghelp` command with clear, prefix-free help text.
    -   Debug output is concise and user-friendly, with fallback only if needed.
    -   Plugin instantiation errors (e.g., "this.dispatch.onMessage is not a function" in tradeLogger) are fixed.
    -   Both plugins load and operate cleanly with no legacy command registration or confusing logs.
-   **Comprehensive README.md (Revamped April 2025):** Project root README overhauled for clarity, accuracy, and completeness, including updated setup, usage, features, known issues, and security warnings based on current state.
-   **ASAR Patching Speed and Reliability:** Patching logic now uses process tree cleanup (`tree-kill`), ensuring all game/Electron/bash processes are terminated and the original `app.asar` is restored promptly and reliably in both development and distribution environments.
-   **Network Packet Logs Auto-Clearing (Status Uncertain):** Logic exists, but functionality needs verification/testing.
-   **~~Buddy List Logging Plugin:~~** ~~Created a separate plugin for buddy list logging...~~ *(Outdated - Original `buddyListLogger` moved externally. `UsernameLogger` handles logging in this project).*
-   **Integrated Account Tester:** Merged `ajc-account-tester` functionality into `winapp.asar`. Application launches, and the tester UI appears on the login screen. (Basic functionality confirmed, deeper testing/SWF conflicts pending).
-   **Integrated Leak Checker (Tested & Enhanced):**
    -   Ported `process_logs.js` logic into Jam, added UI trigger in settings modal, and necessary IPC communication.
    -   Debugged IPC issues and confirmed functionality via console logs.
    -   Added UI and logic for user to select a custom output directory (defaults to project `data` folder). Output files are saved to the selected/default location.
    -   Corrected output filenames to match original script (`accounts.txt`, `ajc_confirmed_accounts.txt`, etc.) for compatibility.
-   **Foundation & Stability (Completed):**
    *   Auto-Updates disabled.
    *   Build includes `data/` directory.
-   **Core State Management (Foundation Completed):**
    *   `jam_state.json` read/write logic implemented in main process.
-   **Leak Check State Integration (Pause/Resume Infrastructure Completed):**
    *   Leak Check process supports start index, state callbacks, pause/stop checks.
    *   Main process handles start/pause/stop IPC signals and state flags.
    *   Settings UI includes Pause/Stop buttons and reflects state.
*   **Leak Check Auto-Resume (Completed):**
    *   Leak Check now automatically resumes from its last state (`running` or `paused`) on application startup.
    *   Logic moved to `renderer-ready` IPC listener to ensure proper timing.
*   **UI Styling Fix (Completed):**
    *   Added missing CSS link to `index.html`.
    *   Corrected `app://` protocol handler registration timing in `index.js` to resolve errors and ensure assets load reliably.
*   **Refactor `LoginScreen.js` (Setup Completed, Refactor Deferred):**
    *   Placeholder module files created (`tester-state.js`, `tester-ui.js`, `tester-logic.js`, `tester-ipc.js`).
    *   **Decision:** Deferred refactoring due to prior issues with module loading/IPC within ASAR. State integration will target the monolithic file first.
*   **Leak Check UI & State Fixes (Completed):**
    *   Disabled auto-start/resume on application launch.
    *   Fixed Pause/Stop button IPC calls in settings modal.
    *   Resolved race condition in main process stop handler.
    *   Added verification logic to settings modal to handle stale 'running'/'paused' state on load.
    *   Resolved button reverting race condition in settings modal UI.
    *   Corrected IPC access method in settings modal (`require('electron').ipcRenderer`) to match `contextIsolation: false` setting.
    *   Fixed Pause/Stop buttons not enabling reliably by removing detailed progress string IPC messages from `leakChecker.js` that interfered with state updates.
-   **Buddy List Logger Refactor & Fixes:**
    -   Refactored plugin to export a class, fixing load errors.
    -   Fixed API key loading by fetching the key via IPC (`ipcRenderer.invoke`) within the `runLeakCheck` method when the command is executed.
    -   Fixed pause/stop commands by adding explicit checks within the `runLeakCheck` loop.
    -   Fixed `ajcConfirmedPath is not defined` error by correcting variable name (`ajcAccountsPath`) in logging statement.
    -   Consolidated logging to `collected_usernames.txt`.
    -   Standardized data file names.
    -   Removed unused data migration code.
    -   Disabled automatic clearing of `collected_usernames.txt` after leak check to prevent data loss.
    -   Renamed plugin directory and internal references to `UsernameLogger`.
    -   Updated leak check logic to add usernames with invalid characters (that are added to `potential_accounts.txt`) to `processed_usernames.txt` as well. **Rationale:** This prevents re-checking usernames that failed initial validation due to special characters and require manual review.
    -   Removed API key warning message during plugin initialization (`loadConfig`).
-   **Removed Debug Logs:** Commented out console logs for initial state and button updates in the settings modal (`settings.js`).
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
-   **Git Repository Setup (April 2025):**
    -   Created and switched to `main` branch.
    -   Confirmed `origin` remote points to `https://github.com/glvckoma/strawberry-jam.git`.
    -   Updated `.gitignore` to include `settings.json` and verified other exclusions.
    -   Staged all current project files.
    -   Created initial commit (`f26fbd7`) representing the local project state, ready for future push.
-   **ASAR Build Separation (Dev/Public) (April 2025):**
    -   Renamed ASAR source folder `assets/extracted-winapp` to `assets/extracted-winapp-dev`.
    -   Created `assets/extracted-winapp-public` by copying the dev version.
    -   Removed Account Tester code (HTML, JS, CSS references) from `assets/extracted-winapp-public/gui/components/LoginScreen.js`.
    -   Updated `pack-and-run.js` to interactively prompt (using `inquirer`) for 'dev' or 'public' build type and pack the corresponding source directory into `assets/winapp.asar`.
    -   Verified `Patcher` logic correctly uses the generated `assets/winapp.asar`.
    -   Updated `.gitignore` to ignore both `assets/extracted-winapp-dev/` and `assets/extracted-winapp-public/`, as well as built ASAR files (`assets/winapp.asar`, `assets/osxapp.asar`, `*-backup.asar`, `*-dev.asar`).
-   **Icon Restoration (April 2025):** User manually restored missing custom icons/images by cloning the private `Blackberry-Jam` repository and copying the necessary files into the `strawberry-jam/assets/` directory.

## Known Issues & Limitations

-   **Invisible Mod Command Plugin Requirement:** Need to create a new plugin that toggles invisibility using the `%xt%fi%-1%` packet (and the correct "off" command, to be determined). Should be a simple console command toggle (on/off) with a clear warning in the README that this is a "mod" command, use at your own risk.
-   **ASAR Merge - SWF Conflicts:** Potential incompatibilities between merged JavaScript code and Jam's original `ajclient.swf` remain untested and are a significant risk. May require ActionScript expertise to resolve.
-   **LoginScreen.js Complexity:** The merged `assets/extracted-winapp/gui/components/LoginScreen.js` is very large (~2k lines) and difficult to maintain/update within the ASAR patching workflow. Needs refactoring.
-   **Leak Check Startup Error:** Fails with `defaultDataDir is not defined` in `src/electron/index.js` due to missing constant definition.
-   **IPC Error in Patched Client:** Runtime errors `Uncaught TypeError: window.ipc.invoke is not a function` occur in `LoginScreen.js` (within `winapp.asar`) when using Account Tester features that rely on `invoke` for state saving/loading. The preload script likely doesn't expose `invoke`.
-   **Account Tester State Management Issues:**
    -   **File Swap Buttons Not Working:** The "Load All", "Load Works", and "Load Confirmed" buttons don't function properly.
    -   **Search/Filter Not Working:** The filter input field doesn't filter the account list.
    -   **State Persistence Not Working:** Account states (works, invalid, etc.) don't persist between application restarts - tested accounts revert to "pending" status.
-   **ASAR Patching Speed Issue:** The process of rewriting and reverting the ajclassic folder with the modified winapp.asar at runtime can take minutes to complete, impacting user experience when restarting the game.

## What's Left / Next Steps (Revised Feature Roadmap)

**Prioritized Tasks:**

1.  **UI/UX & Log Improvements:**
    -   Implement virtualized rendering for console/network logs to improve performance.
    -   Review/adjust log retention limits if performance issues persist.
2.  **SVF Decompiled Analysis:**
    -   Inspect enums for def id/name fetching methods.
    -   Search for keep-alive/anti-logout packets.
3.  **Develop Invisible Mod Command Plugin:** Implement a new plugin to toggle invisibility using the `%xt%fi%-1%` packet (and the correct "off" command, to be determined). Provide a simple console command for toggling, and include a clear warning in the README about the risks of using mod commands.
4.  **Improve ASAR Patching Speed:**
    -   Modify `killProcessAndPatch()` to use a timeout for restoration.
    -   Consider implementing a separate process for restoration.
    -   Explore file system optimization options.
5.  **Continue Trade Lock Packet Analysis:**
    -   Conduct deeper analysis of trade-related packets.
    -   Monitor for additional packets that might appear only in successful trades.
    -   Examine server responses to trade packets.
    -   Investigate user flag packets related to account status.
6.  **Network Packet Logs Auto-Clearing (Verification):**
    -   Test and verify the current implementation of network packet log auto-clearing.
    -   Fix any remaining issues to ensure logs are managed consistently.

*Note: All Account Tester/ASAR-patched client and related UI work is now tracked exclusively in `assets/memory-bank/`. Only core Strawberry Jam proxy, plugin, and Electron app development is tracked here.*
