# Plugin Documentation

Welcome to the Plugin documentation! This section will teach you everything about creating, using, and understanding plugins in Strawberry Jam.

## What are Plugins?

Plugins are like "add-ons" or "mods" for Animal Jam that add new features or change how the game works. Think of them like apps on your phone - each plugin does something specific and useful.

For example:
- **Username Logger** keeps track of all the usernames you see in the game
- **TFD Automation** helps automate playing The Forgotten Desert adventure
- **Spammer** can send repeated messages (for testing purposes)
- **Phantoms** adds phantom-related features to your game experience
- **Invisible Toggle** can make your animal appear invisible to others

## Types of Plugins

Strawberry Jam supports two main types of plugins:

### **UI Plugins** (`type: "ui"`)
These plugins create **user interfaces** - windows, buttons, and menus that you can interact with.

**Examples:**
- **Username Logger**: Shows a window with all the usernames it has collected
- **TFD Automation**: Has a control panel where you can start/stop automation
- **Spammer**: Provides a form where you can type messages to spam

**What they can do:**
- Open windows with forms, buttons, and displays
- Show information to the user
- Let users configure settings
- Display logs, statistics, or other data

### **Game Plugins** (`type: "game"`)
These plugins modify **gameplay** - they change how the game behaves or add new game features.

**Examples:**
- **Phantoms**: Modifies game behavior related to phantoms
- **Invisible Toggle**: Changes how your animal appears to other players

**What they can do:**
- Send fake messages to the game server
- Modify messages between the game and server
- Change how your character behaves
- Add new game mechanics

## How Plugins Work

### The Plugin System
Think of the plugin system like a post office:

1. **Plugin Manager** (the postmaster): Keeps track of all plugins and delivers messages
2. **Plugins** (the customers): Send and receive messages through the post office
3. **Game Client** (another customer): Also sends and receives messages
4. **Network Messages** (the mail): Information flowing between everyone

### Plugin Communication
Plugins don't talk directly to the game. Instead, they talk to the **Main Client**, which acts like a translator:

1. **Plugin wants to do something**: "I want to send a chat message"
2. **Main Client receives request**: "Plugin X wants to send a chat message"
3. **Main Client processes request**: Checks if it's safe and allowed
4. **Main Client executes**: Actually sends the chat message to the game

This system keeps everything safe and organized.

## Plugin Structure

Every plugin needs certain files to work properly:

### **Required Files**

#### **`plugin.json`** - The Plugin's ID Card
This file tells Strawberry Jam what your plugin is and how to run it:

**Basic Information:**
- **Name**: What your plugin is called
- **Version**: What version it is (like 1.0.0)
- **Description**: What your plugin does
- **Type**: Whether it's "ui" or "game"

**Technical Information:**
- **Main File**: Which file to run (usually "index.js" or "index.html")
- **Dependencies**: Other software your plugin needs
- **Commands**: Special chat commands your plugin adds (like "!spam")

#### **Main File** - The Plugin's Brain
- **For UI Plugins**: Usually an HTML file that creates the user interface
- **For Game Plugins**: Usually a JavaScript file that handles game logic

### **Optional Files**
- **CSS Files**: Make your plugin's interface look nice
- **JavaScript Files**: Add functionality and logic
- **Image Files**: Icons, backgrounds, or other graphics
- **Configuration Files**: Settings and preferences

## Plugin Examples

Let's look at how some real plugins work:

### **Username Logger Plugin**
**What it does**: Keeps track of every username you see in Animal Jam

**How it works:**
1. **Watches Network Messages**: Listens for messages that contain usernames
2. **Extracts Usernames**: Pulls out the username from each message
3. **Stores Information**: Saves the username, when you saw it, and where
4. **Shows Results**: Displays all collected usernames in a nice interface

**Why it's useful**: You can remember players you've met, track friends, or see who was in a room

### **TFD Automation Plugin**
**What it does**: Automatically plays The Forgotten Desert adventure for you

**How it works:**
1. **Watches Game State**: Monitors what's happening in the adventure
2. **Makes Decisions**: Decides which direction to go or what to do next
3. **Sends Commands**: Tells the game to move your character or perform actions
4. **Tracks Progress**: Keeps track of what treasures you've found

**Why it's useful**: You can earn adventure rewards without manually playing

### **Spammer Plugin**
**What it does**: Sends repeated messages quickly (mainly for testing)

**How it works:**
1. **User Input**: You type a message and set how many times to send it
2. **Message Creation**: Creates multiple copies of your message
3. **Rapid Sending**: Sends all the messages to the chat quickly
4. **Rate Control**: Can control how fast messages are sent

**Why it's useful**: For testing how the game handles lots of messages, or for making announcements

### **Phantoms Plugin**
**What it does**: Adds special phantom-related features to your game experience

**How it works:**
1. **Game Monitoring**: Watches for phantom-related game events
2. **Enhanced Features**: Adds new phantom-related abilities or information
3. **Custom Behavior**: Changes how phantoms interact with your character
4. **Special Effects**: May add visual or gameplay effects related to phantoms

### **Invisible Toggle Plugin**
**What it does**: Makes your animal appear invisible to other players

**How it works:**
1. **Message Interception**: Catches messages that tell other players where you are
2. **Message Modification**: Changes or blocks these location messages
3. **Selective Visibility**: You can choose when to be invisible or visible
4. **Status Control**: Lets you toggle invisibility on and off easily

## Creating Your First Plugin

### **Step 1: Choose Your Plugin Type**
- **Want to create a user interface?** Choose "ui" type
- **Want to modify gameplay?** Choose "game" type

### **Step 2: Create the Basic Structure**
1. **Make a folder** in the `plugins/` directory with your plugin's name
2. **Create a `plugin.json`** file with your plugin's information
3. **Create your main file** (index.html for UI plugins, index.js for game plugins)

### **Step 3: Define What Your Plugin Does**
- **UI Plugin**: Design your interface - what buttons, forms, or displays do you need?
- **Game Plugin**: Plan your game modifications - what messages do you need to watch or send?

### **Step 4: Connect to the Plugin System**
- **Learn the Plugin API**: Understand what functions are available to use
- **Handle Events**: Set up your plugin to respond to game events
- **Test Thoroughly**: Make sure your plugin works and doesn't break anything

## Plugin API Basics

### **Available Functions**
Plugins can use several built-in functions:

#### **For All Plugins:**
- **Get Game State**: Access information about what's happening in the game
- **Send Messages**: Send network messages to the game or server
- **Access Settings**: Read and write plugin-specific settings
- **Use Logging**: Write messages to logs for debugging

#### **For UI Plugins:**
- **Open Windows**: Create and manage plugin windows
- **Handle User Input**: Respond to button clicks, form submissions, etc.
- **Update Displays**: Change what's shown in your plugin's interface

#### **For Game Plugins:**
- **Monitor Messages**: Watch network traffic for specific types of messages
- **Modify Messages**: Change messages before they reach the game or server
- **Inject Messages**: Send fake messages to test or modify game behavior

### **Event System**
Plugins can "listen" for specific events and respond automatically:

- **Player Joins Room**: When someone enters the room you're in
- **Chat Message Received**: When someone sends a chat message
- **Game State Changes**: When something important happens in the game
- **Network Connection Events**: When the game connects or disconnects

## Plugin Safety & Best Practices

### **Security Guidelines**
- **Don't Store Passwords**: Never save account passwords in your plugin
- **Validate Input**: Always check that user input is safe before using it
- **Respect Rate Limits**: Don't send messages too quickly or you might get banned
- **Handle Errors Gracefully**: Make sure your plugin doesn't crash if something goes wrong

### **Performance Tips**
- **Be Efficient**: Don't use more computer resources than necessary
- **Clean Up**: Stop any timers or listeners when your plugin is disabled
- **Test Thoroughly**: Make sure your plugin works in different situations

### **User Experience**
- **Clear Interfaces**: Make your plugin easy to understand and use
- **Helpful Messages**: Show users what's happening and what they need to do
- **Reasonable Defaults**: Choose good default settings so users don't have to configure everything

## Advanced Features

### **Background Plugins**
Some plugins can run in the background even when their interface isn't open. This is useful for:
- **Automatic Logging**: Continuously collecting data
- **Monitoring**: Watching for specific events
- **Automation**: Performing tasks without user interaction

### **Chat Commands**
Plugins can add new chat commands that players can type in the game:
- **Format**: Commands usually start with "!" (like "!spam" or "!invisible")
- **Parameters**: Commands can accept additional information (like "!spam Hello World 5")
- **Responses**: Commands can send messages back to the player

### **Inter-Plugin Communication**
Plugins can sometimes work together:
- **Shared Data**: One plugin can share information with another
- **Event Broadcasting**: Plugins can notify other plugins when something happens
- **Coordinated Actions**: Multiple plugins can work together on complex tasks

## Troubleshooting

### **Common Problems**

#### **Plugin Won't Load**
- Check that `plugin.json` is formatted correctly
- Make sure all required files are present
- Verify that the plugin type is set correctly

#### **Plugin Crashes**
- Check the console for error messages
- Make sure all required dependencies are installed
- Verify that your code handles errors properly

#### **Plugin Doesn't Work as Expected**
- Test with simple examples first
- Check that you're using the plugin API correctly
- Make sure the game is in the right state for your plugin to work

### **Debugging Tips**
- **Use Console Logging**: Add messages to help track what your plugin is doing
- **Test Step by Step**: Test each part of your plugin separately
- **Read Error Messages**: Error messages usually tell you exactly what's wrong
- **Start Simple**: Begin with basic functionality and add complexity gradually

## Next Steps

Now that you understand plugins, you might want to learn about:
- **[Main Client](../Main%20Client/)** - How the system that runs plugins works
- **[Game Client](../Game%20Client/)** - How plugins interact with the game
- **[Packets](../Packets/)** - How plugins send and receive network messages

Remember: Plugins are powerful tools that can greatly enhance your Animal Jam experience, but with great power comes great responsibility. Always use plugins safely and respectfully!