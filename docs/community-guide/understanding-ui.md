<div align="center">
  <h1>🖥️ Understanding the Strawberry Jam Window</h1>
  <p>A guide to all the tabs and features in Strawberry Jam!</p>
</div>

## 👋 For Everyone

The main Strawberry Jam window has three important tabs at the top:

### 📜 Console Tab
*   Think of this like a message board for Strawberry Jam and its plugins
*   See messages when:
    *   Strawberry Jam starts up
    *   Plugins load or run
    *   Something goes wrong (errors show up here)
*   Some plugins print helpful info here too!
*   **Tip:** The messages in this tab are very useful if you need to use the "Report a Problem" feature, as they help developers understand what was happening in the app.

### 📡 Network Tab
*   This shows messages between your computer and Animal Jam's servers
*   Look for these indicators:
    *   **⬆️ Yellow Up Arrow:** Messages you're sending to the server (like when you move or chat)
    *   **⬇️ Green Down Arrow:** Messages the server is sending back (like where other players are)
*   It might look complicated, but it shows exactly what's happening in the game!
*   **Tip:** You can configure in the Settings how many messages are kept in this tab to help keep the app running smoothly.

### 🔌 Plugins Tab
*   Lists all your installed plugins (add-ons)
*   Shows if each plugin loaded correctly
*   Some plugins add their own buttons here

## 👩‍💻 For Developers

Want to dig deeper? Here's what each tab offers for development:

### 📜 Console Tab (Advanced)
*   **🐛 Debugging:** Watch `console.log` and `application.consoleMessage` outputs
*   **📊 Status Updates:** See core app and plugin status messages
*   **💬 Command Results:** Track command successes and failures

### 📡 Network Tab (Advanced)
*   **🔍 Protocol Analysis:** Study the raw XML and XT packet data
*   **🔧 Plugin Testing:** Check if your plugins are:
    *   Catching the right packets (`dispatch.onMessage`)
    *   Sending correct data (`dispatch.sendRemoteMessage`)
    *   Modifying packets properly

### 🔌 Plugins Tab (Advanced)
*   **✅ Load Status:** Verify your plugins are loading correctly
*   **⚙️ Management:** Central place to monitor all active plugins
