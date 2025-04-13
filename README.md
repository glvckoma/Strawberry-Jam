# Strawberry Jam

**A modular MITM proxy and plugin platform for Animal Jam Classic**  
_Forked from [Jam by sxip](https://github.com/Sxip/jam)_

---

## What is Strawberry Jam?

Strawberry Jam is a powerful, extensible Man-in-the-Middle (MITM) proxy and plugin system for Animal Jam Classic. It allows you to intercept, analyze, and modify network traffic between the AJC client and servers, develop custom plugins, and automate or enhance gameplay in ways not possible with the official client.

> **This project is a fork of the original [Jam](https://github.com/Sxip/jam) by sxip. All new work, documentation, and branding is under the name "Strawberry Jam".**

---

## Features

- **MITM Proxy:** Intercept and forward all AJC network traffic (port 443).
- **Packet Analysis & Manipulation:** View, log, and modify XML/XT packets in real time.
- **Plugin System:** Write and load custom plugins (JavaScript) to automate actions, log data, or change game behavior.
- **Electron UI:** Desktop app for managing the proxy, viewing traffic, and interacting with plugins.
- **Dynamic Plugin UI:** Plugins can provide their own UI windows for advanced features.
- **Extensive Documentation:** All context, planning, and technical details are tracked in the `memory-bank/` directory.

---

## Installation

1. **Clone the Repository:**
   ```sh
   git clone https://github.com/YOUR_USERNAME/strawberry-jam.git
   cd strawberry-jam
   ```

2. **Install Dependencies:**
   ```sh
   npm install
   ```

3. **Run in Development Mode:**
   ```sh
   npm run dev
   ```

4. **Configure Your System:**
   - Update your system `hosts` file to redirect AJC traffic to `127.0.0.1`.
   - Place your API keys and settings in `settings.json` as needed.

5. **Load Plugins:**
   - Place plugin folders in the `plugins/` directory.
   - UI plugins (like Login Packet Manipulator) require core modifications (see below).

---

## Upgrading from Jam

Strawberry Jam is a direct fork of Jam, but with:
- Improved documentation and planning (see `memory-bank/`)
- Updated branding and nomenclature throughout the codebase and UI
- New plugins and plugin UI support
- Bug fixes, stability improvements, and new features

**All references to "Jam" in documentation, UI, and code have been updated to "Strawberry Jam" except where historical attribution is required.**

---

## Required Core Modifications for UI Plugins

> **To use advanced UI plugins (like Login Packet Manipulator), you must patch the following files:**

- `src/electron/preload.js`: Expose `window.jam.onPacket` for plugin windows.
- `src/electron/index.js`: Broadcast `packet-event` to all renderer/plugin windows.
- `src/electron/renderer/application/index.js`: Send `packet-event` to main process when packets are processed.

See the plugin's `readme.md` for code snippets and detailed instructions.

---

## Documentation & Planning

All project context, planning, and technical documentation is tracked in the `memory-bank/` directory:
- `projectbrief.md`, `productContext.md`, `systemPatterns.md`, `techContext.md`, `activeContext.md`, `progress.md`

**Please read these files for a deep understanding of the project's goals, architecture, and current status.**

---

## Attribution

Strawberry Jam is a fork of [Jam by sxip](https://github.com/Sxip/jam).  
All original authors and contributors are acknowledged.  
All new work is under the "Strawberry Jam" name.

---

## License

MIT

---

## Security & Disclaimer

- **Security:** Strawberry Jam is for research and educational use only. It disables many Electron security features and should not be used on untrusted systems.
- **Account Safety:** Use at your own risk. Manipulating packets can result in bans or data loss.
- **Distribution:** If you distribute this project or plugins, make it clear that it is a fork and requires a patched core.

---
