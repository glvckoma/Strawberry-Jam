<div align="center">
  <h1>🔌 Using & Creating Plugins</h1>
  <p>Learn how to add new features to Strawberry Jam!</p>
</div>

## 🎮 For Everyone: Using Plugins

### ✨ What Are Plugins?

Plugins are like power-ups that add cool new features to Strawberry Jam! Some examples:
*   **👥 Player Logging:** Keep track of who you see in-game
*   **💬 Auto Chat:** Send messages automatically
*   **🎨 Quick Colors:** Change your animal's colors instantly
*   **🖥️ New Windows:** Add special screens to Strawberry Jam

### 📂 Finding the Plugins Folder

Your plugins folder location depends on how you installed Strawberry Jam:

#### 🪟 Windows (.exe Install)
1.  Open File Explorer
2.  Go to: `C:\Users\<YourUsername>\AppData\Local\Programs\strawberry-jam\resources\app\plugins`
    *   Can't see `AppData`? Click "View" at the top → Check "Hidden items"
    *   Replace `<YourUsername>` with your Windows username

#### 🍎 MacOS (.dmg Install)
1.  Find `Strawberry Jam.app` in Applications
2.  Right-click (or Ctrl-click) → "Show Package Contents"
3.  Go to: `Contents/Resources/app/plugins`

### 🚀 Installing a Plugin

1.  **📥 Download:** Get the plugin folder (it should have files like `plugin.json` inside)
2.  **📋 Copy:** Copy the entire plugin folder
3.  **📁 Paste:** Put it in your Strawberry Jam `plugins` folder
4.  **🔄 Restart:** Close and reopen Strawberry Jam

## 👩‍💻 For Developers: Creating Plugins

### 📝 Basic Plugin Structure

Every plugin needs:

1.  **📁 A Folder:** Create a new folder in `plugins/`
2.  **ℹ️ plugin.json:** The plugin's ID card
    ```json
    {
      "name": "MyCoolPlugin",
      "version": "1.0.0",
      "author": "YourName",
      "description": "Does something awesome!",
      "main": "index.js"
    }
    ```

3.  **🔧 Main File:** Either `index.js` or `index.html`

### 💡 Two Types of Plugins

#### 1️⃣ Command/Background Plugins (`index.js`)
```javascript
module.exports = class MyCoolPlugin {
  constructor(dispatch, application) {
    this.dispatch = dispatch;
    this.application = application;
    
    // Listen for commands
    this.dispatch.onCommand('mycmd', this.handleCommand.bind(this));
    
    // Watch for packets
    this.dispatch.onMessage('*', this.handlePacket.bind(this));
  }
}
```

#### 2️⃣ UI Plugins (`index.html` + `"type": "ui"`)
*   Create windows with HTML/CSS/JavaScript
*   Use `window.jam.dispatch` to talk to the game
*   Check out the `spammer` plugin for an example!

### 📚 Learning Resources

#### 🎯 Example Plugins to Study
*   **📝 UsernameLogger:** Background tasks & file handling
*   **💬 Spammer:** UI windows & sending packets
*   **💭 Chat:** Simple command handling
*   **🔑 Login:** Packet modification

#### 🛠️ Helpful Tools
*   **📊 DefPacks:** Find item, room, and other game IDs in the `dev/1714-defPacks/` folder.
*   **🔍 Game Code:** For advanced understanding, you can study the decompiled game code in `dev/SVF_Decompiled/`.
*   **📝 Logging for Debugging:** When your plugin isn't behaving as expected, good logging is your best friend! Strawberry Jam 3.0.0 has an improved logging system. In your plugin's JavaScript code, you can write messages like:
    *   `window.jam.logManager.debug('My plugin is doing this...');`
    *   `window.jam.logManager.warn('Something unexpected happened.');`
    *   `window.jam.logManager.error('Oops, an error occurred!');`
    These messages will show up in the developer console and are included in the "Report a Problem" logs, making it easier to find and fix issues.

### ⚠️ Important Notes

*   **🐛 Stability:** Test your plugins thoroughly, especially if they use commands or timers, to make sure they don't cause problems.
*   **🔒 Security:** Be very careful if your plugin handles any sensitive information.
*   **📦 Dependencies:** If your plugin needs other software libraries to work, list them in your `plugin.json` file.
*   **🍓 Strawberry Jam Build Process:** If you're building Strawberry Jam from source to test your plugins, remember that the main build commands have been updated in version 3.0.0. Check the main `README.md` for the latest instructions (like using `npm run build`).
