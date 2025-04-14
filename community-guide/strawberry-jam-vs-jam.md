# Strawberry Jam vs. Jam: What's Different?

---

## 🍓 For Everyone (Kids/Easy-to-Read)

**Strawberry Jam** is a special, improved version of the original Jam project for Animal Jam Classic. Here’s what makes it different and better:

- **New Tools!**
  - **Login Packet Manipulator:** Lets you change how you log in (not possible in the original Jam).
  - **Account Tester:** Helps you check lots of accounts quickly and safely.
  - **Username Logger:** Collects and checks usernames for you.

- **Safety & Privacy**
  - **UUID Rotation:** Changes your computer’s ID to help you stay safe (but you’ll need to use OTP every time).
  - **LeakCheck Integration:** Checks usernames with a special database (you’ll need your own API key).

- **Cleaner & Faster**
  - **Auto-Clearing Logs:** Console and network logs clear themselves after 600 messages, so things never get too messy or slow.

- **Just for Fun**
  - More features and improvements are coming all the time!

---

## 🛠️ For Developers & Power Users

### **Why Fork?**

Implementing advanced features like the login packet manipulator, semi-automatic account tester, and robust username logger required significant changes to Jam’s core. These features are not compatible with the original Jam and are unique to Strawberry Jam.

### **Major Features & Differences**

| Feature/Change                        | Strawberry Jam | Original Jam | Notes/Reasoning |
|---------------------------------------|:--------------:|:------------:|-----------------|
| **Login Packet Manipulator**          | ✅             | ❌           | Core changes required for plugin support |
| **Account Tester (semi-auto)**        | ✅             | ❌           | Major refactor, still being tested for release |
| **Username Logger (improved)**        | ✅             | Partial      | Refactored, more robust, batch file writing, stateful |
| **UUID Rotation (HWID spoofing)**     | ✅             | ❌           | Optional, togglable, helps avoid detection (requires OTP) |
| **LeakCheck API Integration**         | ✅             | ❌           | For automatic username checking (API key required) |
| **Auto-Clearing Console/Network Logs**| ✅             | ❌           | Prevents UI lag, keeps logs manageable |
| **Plugin System Improvements**        | ✅             | Partial      | More robust plugin loading, error handling, UI plugins |
| **Settings Refactor**                 | ✅             | ❌           | Dedicated sections for API keys, improved UX |
| **Distribution-Ready Build System**   | ✅             | ❌           | Excludes sensitive/dev files, supports Windows/Mac |
| **Security Warnings & ToS Notices**   | ✅             | ❌           | Prominent in README and docs |
| **Memory Bank Documentation**         | ✅             | ❌           | All context, progress, and patterns tracked in markdown |
| **ASAR Patching Workflow**            | ✅             | Partial      | Faster, more reliable, supports dev/public separation |
| **UI/UX Improvements**                | ✅             | Partial      | Draggable plugin windows, better modal design |
| **Bug Fixes & Personal Tweaks**       | ✅             | ❌           | Many minor changes for stability and preference |
| **Removed/Disabled Features**         | See below     | See below    | Some unstable or legacy features removed/refactored |

### **Removed/Disabled/Refactored Features**
- Legacy buddy list logger replaced with improved Username Logger.
- Unstable/legacy command and timer-based plugins refactored or removed.
- All Account Tester/ASAR-patched client work is tracked separately and modularized.

### **Security & Stability**
- Electron security settings remain intentionally loose for plugin flexibility, but all risks are documented.
- Plugin loading is more robust, with better error handling and state management.
- Build system excludes sensitive files and dev artifacts.

### **Documentation**
- All project context, patterns, and progress are tracked in the `memory-bank/` directory.
- Community guide and README are kept up to date with all major changes.

---

## 🔗 Want to Learn More?

- See the [README.md](../README.md) for a quick start and important warnings.
- For a full technical diff, compare this repo with [Sxip's original Jam](https://github.com/Sxip/jam).

---

*Strawberry Jam is always evolving! If you have questions or want to help, check out the community guide or open an issue on GitHub.*
