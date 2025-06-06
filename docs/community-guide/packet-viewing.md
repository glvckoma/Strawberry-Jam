<div align="center">
  <h1>📡 Understanding Network Packets</h1>
  <p>Learn how to read the secret messages between your game and Animal Jam's servers!</p>
</div>

## 👋 For Everyone

Think of network packets like letters being sent back and forth between friends:

### 📨 Types of Messages

*   **⬆️ Messages You Send (Yellow Up Arrow)**
    *   When you want to move your animal
    *   When you type in chat
    *   When you try to buy something
*   **⬇️ Messages You Receive (Green Down Arrow)**
    *   Where other players are
    *   What others are saying
    *   If you got a new item

### 📝 What the Messages Look Like

The text might look like computer code, but there are patterns you can spot:
*   Messages between `< >` are called **XML** messages
*   Messages between `% %` are called **XT** messages

### 🔍 Fun Things to Watch For

*   **💭 Chat Messages:** Look for `%xt%c%...%`
*   **🏃 Movement:** Watch the messages when you walk around
*   **🎮 Actions:** See what happens when you click buttons!

Don't worry if it seems confusing - just watching the messages flow can be interesting!

## 👩‍💻 For Developers

### 📊 Message Types in Detail

*   **📜 XML Format (`<...>`)**
    *   Used for: Login, setup, some game actions
    *   Parsed with: `cheerio` library
    *   Easy to read but verbose

*   **🔤 XT Format (`%xt%...%`)**
    *   Used for: Most real-time game actions
    *   Structure: `%xt%COMMAND%PARAM1%PARAM2%...%`
    *   Most common type you'll work with

*   **📋 JSON Format (`{...}`)**
    *   Used for: Special data transfers
    *   Less common but good to know about

### 🎯 Common XT Commands

*   **💬 Chat:** `%xt%c%...%`
*   **🏃 Movement:** `%xt%m%...%`
*   **🚪 Room Join:** `%xt%j%...%`
*   **🎒 Inventory:** `%xt%i%...%`
*   **ℹ️ Info:** `%xt%g%...%`

### 🔧 Development Tips

*   **🔍 Finding Packets**
    *   Do actions in-game and watch the Network tab
    *   Check `dev/1714-defPacks/` for item/room IDs
    *   Study `dev/SVF_Decompiled/` for packet handling logic

*   **🛠️ Plugin Development**
    *   Listen for packets with `dispatch.onMessage`
    *   Send packets with `dispatch.sendRemoteMessage`
    *   Test responses with `dispatch.sendConnectionMessage`
    *   **Use Logs for Debugging:** When you're working with packets, things might not always go as planned. Strawberry Jam 3.0.0 has an improved logging system. You can add log messages in your plugin code like `window.jam.logManager.debug('Packet received:', packetData)` or `window.jam.logManager.error('Failed to send packet')`. These logs will appear in the developer console and are very helpful for figuring out what's happening with your packets. They are also included if you use the "Report a Problem" feature.

### 💡 Pro Tips

*   **📝 Take Notes:** Record patterns you find
*   **🔄 Be Patient:** Test thoroughly before using packets in plugins
*   **🔬 Analyze Responses:** Server replies tell you if actions worked
