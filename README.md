<div align="center">
  <img src="assets/strawberry-jam.png" alt="Strawberry Jam Logo" width="200"/>
  <h1>Strawberry Jam</h1>
  <a href='https://discord.gg/HzFe7XpuPs'>
    <img src="https://discord.com/api/guilds/1355727306177380392/widget.png?style=shield" alt="Discord" />
  </a>
</div>

<br />

<div align="center">
A tool for exploring and extending <a href="https://classic.animaljam.com">Animal Jam Classic</a>!
<br /><br /></div>

## 🍓 What's Different from the Original Jam?

Strawberry Jam is a fork of the original [Jam](https://github.com/Sxip/jam) project, with new features, plugins, and improvements not found in the original.  
See [Strawberry Jam vs. Jam: What's Different?](community-guide/strawberry-jam-vs-jam.md) for a friendly and technical comparison.

## 🚀 Quick Start

###  Windows
1.  Download `Strawberry-Jam-Setup.exe` from our [latest release](https://github.com/glvckoma/strawberry-jam/releases/latest)
2.  Run the installer
3.  Launch Strawberry Jam from your Start menu

###  MacOS

1.  Go to the [latest release page](https://github.com/glvckoma/strawberry-jam/releases/latest).
2.  Download the file ending in `.zip` (like `Strawberry-Jam-mac-1.0.2.zip`) or (`strawberry-jam-1.0.1-arm64-mac.zip.`)
3.  Find the downloaded `.zip` file (usually in your Downloads folder) and double-click it to unzip. This will create a **Strawberry Jam.app** file.
4.  Drag the **Strawberry Jam.app** file into your **Applications** folder.
5.  **Important First Run:** You need to open the **Terminal** app (you can find it using Spotlight search - the magnifying glass at the top right).
6.  Carefully copy and paste this *exact* command into the Terminal and press Enter:
    ```bash
    sudo xattr -rd com.apple.quarantine /Applications/strawberry-jam.app
    ```
    *   **Note:** Double-check the exact application name in your Applications folder. It might be `strawberry-jam.app` (lowercase, hyphenated) or `Strawberry Jam.app`. Adjust the command above if needed!
    *   **Why do I need to do this?** Your Mac has a security guard called Gatekeeper. When you download apps from the internet (like Strawberry Jam), Gatekeeper gets a little suspicious and puts them in "quarantine" just in case. This command tells Gatekeeper, "Hey, this Strawberry Jam app is safe, you can let it run!"
    *   It will ask for your Mac's login password. Type it in (you won't see anything appear as you type, that's normal!) and press Enter.
    *   You only need to do this command **one time** after installing or updating Strawberry Jam!
7.  Try opening **Strawberry Jam** from your Applications folder like any other app.
8.  **If it doesn't open (Permissions Error):** Sometimes, even after removing quarantine, macOS might still block the app due to permissions. If double-clicking doesn't work, you might need to run it from the Terminal using `sudo`:
    *   Open the **Terminal** app again.
    *   Carefully copy and paste this command and press Enter (adjust the app name if needed):
        ```bash
        sudo /Applications/strawberry-jam.app/Contents/MacOS/strawberry-jam
        ```
    *   Enter your password when prompted. This should launch the app with the necessary permissions. You might need to do this each time you run the app.
    *   **Full Disk Access:** You might also need to grant "Full Disk Access" to the **Terminal** app itself. Go to System Settings -> Privacy & Security -> Full Disk Access, and make sure Terminal is enabled.

> **⚠️ Mac Compatibility Note:** Strawberry Jam is mostly built and tested on Windows. While we try to make it work on Mac, you might run into some bugs or issues like the permissions problem mentioned above. If you find problems, please let us know by [creating an issue](https://github.com/glvckoma/strawberry-jam/issues)!

## ✨ Features

*   **🔍 Network Analysis:** Watch messages between your game and AJ's servers
*   **🔌 Plugin System:** Add cool new features with plugins
*   **🖥️ Easy to Use:** Simple desktop app with everything you need

## ⚠️ Important Warning!

Using tools like Strawberry Jam might break the game's rules and result in account termination. Please be careful and use it responsibly. Neither I nor Sxip are responsible for any loss of accounts.

## 📚 Learning More

New to Strawberry Jam? Check out our guides:

*   [Understanding the Strawberry Jam Window](community-guide/understanding-ui.md)
*   [Introduction to Packet Viewing](community-guide/packet-viewing.md)
*   [Using and Developing Plugins](community-guide/plugins.md)

## 💡 Have an Idea?

Got a cool idea for Strawberry Jam? We'd love to hear it!

*   **📝 Create an Issue:**
    *   Visit our [Issues page](https://github.com/glvckoma/strawberry-jam/issues)
    *   Click "New Issue"
    *   Tell us:
        *   What your idea does
        *   Why it would be fun/useful
    *   Don't worry about making it perfect!

*   **💬 Message on Discord:**
    *   Rather chat? Message me (**_glockoma**) on Discord!
    *   I'm always happy to hear your ideas

## 👩‍💻 For Developers

Want to run from source or create plugins? Here's how to get started:

1.  Install [Node.js](https://nodejs.org)
2.  Clone the repo:
    ```bash
    git clone https://github.com/glvckoma/strawberry-jam.git
    cd strawberry-jam
    npm install
    npm run dev
    ```
