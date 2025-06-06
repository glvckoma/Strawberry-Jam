# Strawberry Jam vs. Jam: What's Different?

---

## 🍓 For Everyone (Kids/Easy-to-Read)

**Strawberry Jam** is a special, improved version of the original Jam project for Animal Jam Classic. Here's what makes it different and better:

- **New & Improved Tools!**
  - **Login Packet Manipulator:** Lets you change how you log in (not possible in the original Jam).
  - **Username Logger:** Collects and checks usernames for you.
  - **Better "Report a Problem":** If something goes wrong, it's now easier to send helpful information to developers, as the app collects more detailed logs automatically.
  - **Secure Account Saving:** If you choose to save your login details, they are now stored more securely using your computer's built-in secure storage (thanks to Keytar integration).

- **Safety & Privacy**
  - **LeakCheck Integration:** Checks usernames with a special database (you'll need your own API key).
  - **Secure Account Storage:** As mentioned above, your saved accounts are better protected.

- **Cleaner & Faster**
  - **Auto-Clearing Logs:** Console and network logs can be set to clear themselves after a certain number of messages, so things don't get too messy or slow.
  - **Automatic Old Log Cleanup:** The app now automatically cleans up very old log files to save space.

- **Just for Fun**
  - More features and improvements are coming all the time!

---

## 🛠️ For Developers & Power Users

### **Why Fork?**

Implementing advanced features like the login packet manipulator, semi-automatic account tester, and robust username logger required significant changes to Jam's core. These features are not compatible with the original Jam and are unique to Strawberry Jam.

### **Major Features & Differences**

| Feature/Change                        | Strawberry Jam | Original Jam | Notes/Reasoning |
|---------------------------------------|:--------------:|:------------:|-----------------|
| **Login Packet Manipulator**          | ✅             | ❌           | Core changes required for plugin support |
| **Secure Account Storage (Keytar)**   | ✅             | ❌           | Uses system keychain for safer credential storage. |
| **"Tester" Functionality**            | ❌             | Partial      | Removed in Strawberry Jam 3.0.0 for simplification. |
| **Username Logger (improved)**        | ✅             | Partial      | Refactored, more robust, batch file writing, stateful |
| **LeakCheck API Integration**         | ✅             | ❌           | For automatic username checking (API key required) |
| **Advanced Logging System**           | ✅             | ❌           | Comprehensive `LogManager`, better "Report a Problem", `winapp.asar` log capture, auto-cleanup of old logs. |
| **Configurable Log Auto-Clearing**    | ✅             | ❌           | Prevents UI lag, keeps console/network logs manageable. |
| **Plugin System Improvements**        | ✅             | Partial      | More robust plugin loading, error handling, UI plugins |
| **Settings Refactor & Enhancements**  | ✅             | ❌           | Dedicated sections, API keys, log limiting options, improved UX. |
| **Streamlined Build System**          | ✅             | ❌           | Simplified `npm run build`, OS-agnostic focus, excludes sensitive/dev files. |
| **Security Warnings & ToS Notices**   | ✅             | ❌           | Prominent in README and docs |
| **Memory Bank Documentation**         | ✅             | ❌           | All context, progress, and patterns tracked in markdown |
| **ASAR Patching Workflow**            | ✅             | Partial      | Faster, more reliable, supports dev/public separation |
| **UI/UX Improvements**                | ✅             | Partial      | Draggable plugin windows, better modal design |
| **Bug Fixes & Personal Tweaks**       | ✅             | ❌           | Many minor changes for stability and preference |
| **Removed/Disabled Features**         | See below     | See below    | Some unstable or legacy features removed/refactored |

### **Removed/Disabled/Refactored Features**
- Legacy buddy list logger replaced with improved Username Logger.
- "Tester" functionality and related code completely removed.
- Unstable/legacy command and timer-based plugins refactored or removed.

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
