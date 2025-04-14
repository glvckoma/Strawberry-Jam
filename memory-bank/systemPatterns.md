# System Patterns: Strawberry Jam

> **Note:** This project is a fork of the original Jam by sxip. All new work, documentation, and branding is under the name "Strawberry Jam".

---

## April 2025: Patterns & Integration

- **Plugin Settings Access Pattern:** Plugins (e.g., UsernameLogger) must fetch sensitive settings (like API keys) from the main process via IPC (`ipcRenderer.invoke('get-setting', ...)`) at the time the setting is needed (e.g., inside a command handler). Loading settings during plugin instantiation is unreliable.
- **Plugin State Access Pattern (UI Plugins):** UI plugins (like advertising) must use `dispatch.getState(key)` to access core application state. The IPC bridge for this was refactored to use an asynchronous request/reply pattern between the main process and main renderer, supporting reliable cross-window communication.
- **Room State Tracking:** The core dispatch system now hooks `j#jr` (join room) and `j#l` (leave room) packets to automatically update `dispatch.state.room`, ensuring plugins can always access the current room ID.
- **Preview Button Pattern:** UI plugins can implement a "Preview" or "Send" button that sends a message to the game by constructing the appropriate packet and calling `dispatch.sendRemoteMessage(packet)`. The advertising plugin now uses this pattern for its preview button.
- **Build Compatibility:** UI plugins that use only standard web technologies, jQuery (injected by the main app), and the `window.jam` object for IPC do not require any special build configuration or extra dependencies. The advertising plugin is confirmed to work in both development and packaged builds.
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
...
