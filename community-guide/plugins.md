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
*   **📊 DefPacks:** Find IDs in `dev/1714-defPacks/`
*   **🔍 Game Code:** Study `dev/SVF_Decompiled/`

### ⚠️ Important Notes

*   **🐛 Stability:** Test plugins thoroughly (especially commands & timers)
*   **🔒 Security:** Be careful with sensitive data
*   **📦 Dependencies:** List them in `plugin.json`
