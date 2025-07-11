# Main Client Documentation

Welcome to the Main Client documentation! This section explains how Strawberry Jam's main application works, from the ground up.

## What is the Main Client?

The Main Client is the heart of Strawberry Jam - it's the main window you see when you start the application. Think of it as the control center that manages everything else. It's like the dashboard of a car: it shows you what's happening and lets you control all the different parts.

## What Does It Do?

The Main Client handles several important jobs:

### 1. **Plugin Management**
- Loads and runs all your plugins (like Username Logger, TFD Automation, etc.)
- Lets you turn plugins on/off without restarting
- Provides a safe environment for plugins to run in

### 2. **Network Monitoring**
- Acts like a "middleman" between Animal Jam and the game servers
- Watches all the messages going back and forth
- Lets plugins see and modify these messages

### 3. **Game Client Control**
- Starts and manages the actual Animal Jam game window
- Sends instructions between the game and your plugins
- Handles account switching and login management

### 4. **Settings & Storage**
- Saves your preferences and plugin settings
- Manages your account information securely
- Keeps logs of what's happening

## How Is It Built?

The Main Client is built using **Electron**, which is a technology that lets you create desktop applications using web technologies (like websites). Think of it as a special web browser that only runs Strawberry Jam.

### The Two-Process System

Strawberry Jam uses a unique "two-process" approach:

1. **Main Client Process** - The control center (this documentation covers this)
2. **Game Client Process** - The actual Animal Jam game window

This is like having two separate programs that work together. The Main Client is the boss that tells the Game Client what to do.

## Key Components

### User Interface
The Main Client window contains:
- **Plugin Manager**: Shows all available plugins and their status
- **Settings Panel**: Configure how Strawberry Jam behaves
- **Network Monitor**: See live network traffic (if enabled)
- **Account Manager**: Switch between different Animal Jam accounts

### Behind the Scenes
Several important systems run in the background:

#### Plugin System
- **Plugin Loader**: Finds and starts plugins automatically
- **Plugin Communication**: Lets plugins talk to each other and the game
- **Security Manager**: Keeps plugins from doing harmful things

#### Network System
- **Proxy Server**: Intercepts all network traffic to/from Animal Jam
- **Message Parser**: Understands different types of game messages
- **Transform Pipeline**: Lets plugins modify messages before they reach the game

#### Storage System
- **Settings Manager**: Saves preferences using Electron's built-in storage
- **User Data**: Stores logs, account info, and plugin data
- **Secure Storage**: Uses your computer's secure storage for sensitive information

## Development Workflow

### Getting Started
When you want to work on Strawberry Jam, you'll use these commands:

- **Development Mode**: `npm run dev` - For testing changes as you make them
- **Production Mode**: `npm run test` - For testing the final version
- **Build Assets**: `npm run pack` - Packages everything together
- **Create Installer**: `npm run build` - Makes the final installer

### Making Changes
The typical workflow for developers:

1. **Edit Code**: Make changes to files in the `src/` folder
2. **Pack Assets**: Run `npm run pack` to update the game client
3. **Test Changes**: Run `npm run dev` to see your changes
4. **Repeat**: Keep making changes until everything works
5. **Final Test**: Run `npm run test` to make sure everything works in production mode

### File Structure
The Main Client files are organized like this:

- **`src/electron/`** - The main Electron application code
- **`src/networking/`** - Network interception and message handling
- **`src/api/`** - Internal web server for file operations
- **`src/utils/`** - Helper functions used throughout the app
- **`src/services/`** - Connections to external services

## Security & Safety

### Plugin Security
The Main Client keeps plugins secure by:
- **Isolation**: Each plugin runs in its own protected space
- **Permission Control**: Plugins can only do what they're allowed to do
- **Communication Limits**: Plugins talk through controlled channels only

### Network Security
- **Traffic Validation**: All network messages are checked for safety
- **Secure Storage**: Passwords and sensitive data are encrypted
- **Process Separation**: The game and main client are kept separate for safety

### User Protection
- **No Sensitive Data Logging**: Personal information is never logged
- **Secure Account Storage**: Account details are encrypted on your computer
- **Safe Plugin Loading**: Only verified plugins are loaded automatically

## Common Questions

### "Why Two Separate Processes?"
Having the Main Client and Game Client separate means:
- If one crashes, the other keeps running
- Updates can be made without affecting the game
- Better security through isolation
- Easier to debug problems

### "How Do Plugins Work With This?"
Plugins connect to the Main Client, which then:
- Gives them access to network messages
- Lets them control game features
- Provides them with game state information
- Handles their user interfaces

### "Is This Safe to Use?"
Yes! The Main Client is designed with safety in mind:
- It doesn't modify Animal Jam's actual game files
- All changes are temporary and reversible
- Network traffic is monitored but not stored permanently
- Your account information is kept secure

## Next Steps

Now that you understand the Main Client, you might want to learn about:
- **[Game Client](../Game%20Client/)** - How the actual game window works
- **[Plugins](../Plugins/)** - How to create and use plugins
- **[Packets](../Packets/)** - How network messages work

Remember: The Main Client is just the control center. The real magic happens when it works together with plugins and the game client to create powerful modding capabilities!