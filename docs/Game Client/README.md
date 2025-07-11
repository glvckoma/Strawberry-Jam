# Game Client Documentation

Welcome to the Game Client documentation! This section explains the part of Strawberry Jam that actually runs the Animal Jam game.

## What is the Game Client?

The Game Client is the second half of Strawberry Jam - it's the actual Animal Jam game window that you play in. Think of it as a modified version of the original Animal Jam desktop app, but with special features added by Strawberry Jam.

## How is it Different from Regular Animal Jam?

The Game Client is based on Animal Jam's original desktop application, but Strawberry Jam has made some important changes:

### What's Been Added:
- **Account Management**: Switch between multiple accounts easily
- **Enhanced Login**: Automatic login features and account saving
- **Plugin Integration**: Plugins can modify how the game looks and behaves
- **Network Communication**: Talks to the Main Client to share information
- **Security Features**: UUID spoofing and other privacy protections

### What Stays the Same:
- **Game Content**: All the rooms, games, and items work exactly like normal
- **Flash Game**: The core Animal Jam game (the `.swf` file) is unchanged
- **Game Features**: Trading, chatting, and playing all work normally

## Where Does It Come From?

The Game Client files live in the `assets/extracted-winapp-public/` folder. These files are:

### **Extracted Files**
- Originally, Animal Jam comes as a packaged `.asar` file (like a zip file)
- Strawberry Jam "unpacks" this file so we can modify it
- The extracted files contain the entire Animal Jam desktop application
- When you run `npm run pack`, these files get packaged back together

### **Live Editing**
- You can edit files in `extracted-winapp-public/` and see changes immediately
- Just remember to run `npm run pack` before testing your changes
- This is like editing a website while it's running - very powerful for development!

## Key Components

### Main Application Files

#### **`index.js`**
This is the "brain" of the Game Client. It:
- Starts the Electron window that contains the game
- Sets up communication with the Main Client
- Handles account switching and login automation
- Manages the game window (size, controls, etc.)

#### **`gui/index.html`**
This is the main game window - what you actually see when playing. It contains:
- The login screen interface
- The game container where the Flash game runs
- Account management controls
- Error messages and loading screens

#### **`gui/preload.js`**
This runs before the game loads and sets up:
- Communication between the game and Main Client
- Special features like account switching
- Security protections and UUID spoofing
- Plugin integration hooks

### User Interface Components

The Game Client has several important UI parts:

#### **Login System (`gui/components/LoginScreen.js`)**
- **Automatic Login**: Can log in without typing username/password
- **Account Switching**: Switch between saved accounts quickly
- **Remember Accounts**: Saves account information securely
- **Error Handling**: Shows helpful messages when login fails

#### **Account Management (`gui/components/AccountManagementPanel.js`)**
- **Add Accounts**: Save new Animal Jam accounts
- **Switch Accounts**: Change accounts without restarting
- **Remove Accounts**: Delete saved accounts
- **Account Status**: Shows which account is currently active

#### **Game Screen (`gui/components/GameScreen.js`)**
- **Flash Container**: Holds the actual Animal Jam game
- **Game Controls**: Fullscreen, exit, and other game controls
- **Status Display**: Shows connection status and account info
- **Plugin Integration**: Allows plugins to add features to the game screen

#### **Modal System**
Various popup windows for different purposes:
- **Error Messages**: When something goes wrong
- **Confirmation Dialogs**: Before important actions
- **Settings Panels**: For configuring game options
- **Plugin Windows**: When plugins need to show interfaces

### Game Integration

#### **Flash Game (`assets/flash/ajclient.swf`)**
- This is the actual Animal Jam game - the same Flash file that runs on the website
- The Game Client loads this file and displays it in a special container
- Plugins and modifications can interact with this game through network messages
- The game itself remains unchanged - modifications happen through communication

#### **Asset System**
The Game Client includes:
- **Images**: Buttons, backgrounds, login graphics, and UI elements
- **Stylesheets**: CSS files that control how the interface looks
- **Scripts**: JavaScript files that add functionality
- **Configuration**: Settings files that control game behavior

## How It Communicates

### With the Main Client
The Game Client constantly talks to the Main Client through something called **IPC** (Inter-Process Communication). Think of it like two people passing notes:

- **Account Changes**: "User wants to switch to account X"
- **Game Events**: "Player joined a new room"
- **Plugin Requests**: "Plugin wants to send a chat message"
- **Status Updates**: "Game is loading" or "Connection lost"

### With Animal Jam Servers
The Game Client doesn't talk directly to Animal Jam's servers. Instead:
1. Game wants to send a message to the server
2. Message gets sent to the Main Client first
3. Main Client (and plugins) can modify the message
4. Main Client sends the final message to Animal Jam servers
5. Responses come back the same way

This "middleman" approach is what allows plugins to modify game behavior.

## Modification & Development

### Making Changes
When you want to modify the Game Client:

1. **Edit Files**: Make changes to files in `assets/extracted-winapp-public/`
2. **Pack Changes**: Run `npm run pack` to bundle your changes
3. **Test**: Run `npm run dev` or `npm run test` to see your changes
4. **Repeat**: Keep editing and testing until everything works

### Common Modifications

#### **UI Changes**
- Edit HTML files to change how interfaces look
- Modify CSS files to change colors, layouts, and styling
- Update JavaScript files to add new functionality

#### **Account Features**
- Add new account management options
- Create custom login flows
- Implement account-specific settings

#### **Game Integration**
- Add new buttons or controls to the game screen
- Create custom loading screens or splash pages
- Implement new ways for plugins to interact with the game

### Safety & Best Practices

#### **Backup Original Files**
- Always keep a copy of the original extracted files
- If something breaks, you can restore from the backup
- The original `.asar` file is your ultimate backup

#### **Test Thoroughly**
- Always test changes with `npm run dev` first
- Make sure the game still loads and plays normally
- Check that account switching and login still work

#### **Incremental Changes**
- Make small changes one at a time
- Test each change before making the next one
- This makes it easier to find and fix problems

## Understanding the Architecture

### Why Separate from Main Client?
The Game Client is separate because:
- **Security**: If the game crashes, the Main Client keeps running
- **Updates**: Animal Jam can update the game without breaking Strawberry Jam
- **Performance**: Each process can use computer resources more efficiently
- **Isolation**: Game modifications don't affect the Main Client

### Integration Points
The Game Client connects to the Main Client at several key points:
- **Startup**: Main Client launches the Game Client
- **Account Management**: Game Client asks Main Client for account information
- **Network Traffic**: All game messages pass through the Main Client
- **Plugin Communication**: Plugins can send messages to the Game Client

## Troubleshooting Common Issues

### Game Won't Load
- Make sure you ran `npm run pack` after making changes
- Check that the Flash file (`ajclient.swf`) is present and not corrupted
- Verify that account information is correct

### Account Switching Problems
- Check that accounts are saved correctly in the Main Client
- Make sure IPC communication is working between processes
- Verify that login credentials are valid

### UI Problems
- Check browser console for JavaScript errors
- Verify that CSS files are loading correctly
- Make sure HTML files have proper structure

## Next Steps

Now that you understand the Game Client, you might want to learn about:
- **[Main Client](../Main%20Client/)** - How the control center works
- **[Plugins](../Plugins/)** - How to create modifications that work with the Game Client
- **[Packets](../Packets/)** - How the Game Client sends and receives network messages

Remember: The Game Client is where the actual game runs, but the Main Client is what makes all the magic possible!