# Strawberry Jam Documentation

Welcome to the complete documentation for Strawberry Jam! This guide will help you understand, use, and develop with Strawberry Jam - the powerful modding tool for Animal Jam Classic.

## What is Strawberry Jam?

Strawberry Jam is an Electron-based modding tool that allows you to enhance your Animal Jam Classic experience through plugins, network analysis, and game modifications. Whether you're a player wanting to use cool features or a developer wanting to create new functionality, this documentation has everything you need.

Think of Strawberry Jam as a "supercharged" version of Animal Jam that lets you:
- **Add new features** through plugins
- **Automate repetitive tasks** like playing adventures
- **Monitor and analyze** network traffic
- **Customize your game experience** in ways not normally possible
- **Develop your own modifications** using a powerful plugin system

## How This Documentation is Organized

This documentation is split into four main sections, each covering a different aspect of Strawberry Jam:

### 📱 [Main Client](./Main%20Client/)
**What it covers**: The control center of Strawberry Jam
- How the main application works
- The dual-process architecture
- Plugin management system
- Network interception and monitoring
- Development workflow and commands
- Settings and storage systems

**Read this if you want to**:
- Understand how Strawberry Jam works "under the hood"
- Learn about the development environment
- Understand the plugin system architecture
- Learn how to build and modify Strawberry Jam itself

### 🎮 [Game Client](./Game%20Client/)
**What it covers**: The actual Animal Jam game window
- How the modified Animal Jam client works
- Account management and switching
- Game integration and communication
- User interface components
- Asset modification and repacking

**Read this if you want to**:
- Understand how the game window is modified
- Learn about account management features
- Understand how plugins interact with the game
- Learn how to modify game client files

### 🔌 [Plugins](./Plugins/)
**What it covers**: Creating and using add-on features
- How plugins work and what they can do
- Types of plugins (UI vs Game)
- Plugin development guide
- API reference and available functions
- Examples using real plugins like Username Logger, TFD Automation, Spammer, Phantoms, and Invisible Toggle

**Read this if you want to**:
- Create your own plugins
- Understand how existing plugins work
- Learn the plugin API
- Get inspired by plugin examples
- Troubleshoot plugin issues

### 📡 [Packets](./Packets/)
**What it covers**: Network communication and manipulation
- How Animal Jam's network protocol works
- Types of network messages (XML, XT, JSON)
- How to intercept and modify packets
- Using the Spammer plugin for testing
- Safety and responsible packet manipulation

**Read this if you want to**:
- Understand how Animal Jam communicates over the network
- Learn how to monitor network traffic
- Create plugins that modify game behavior
- Safely experiment with packet manipulation
- Use network analysis for game research

## Getting Started

### For New Users
If you're new to Strawberry Jam, start here:

1. **[Main Client Overview](./Main%20Client/#what-is-the-main-client)** - Learn what Strawberry Jam is and how it works
2. **[Game Client Basics](./Game%20Client/#what-is-the-game-client)** - Understand the game window and account features
3. **[Plugin Basics](./Plugins/#what-are-plugins)** - Learn about the plugins that add features to your game
4. **[Network Basics](./Packets/#what-are-packets)** - Understand how the game communicates (optional, for curious users)

### For Plugin Users
If you want to use existing plugins:

1. **[Plugin Types](./Plugins/#types-of-plugins)** - Understand UI vs Game plugins
2. **[Plugin Examples](./Plugins/#plugin-examples)** - See what popular plugins do
3. **[Main Client Plugin Management](./Main%20Client/#plugin-system)** - Learn how to install and manage plugins

### For Developers
If you want to create plugins or modify Strawberry Jam:

1. **[Main Client Architecture](./Main%20Client/#how-is-it-built)** - Understand the system architecture
2. **[Development Workflow](./Main%20Client/#development-workflow)** - Learn the development commands and process
3. **[Plugin Development Guide](./Plugins/#creating-your-first-plugin)** - Start creating your own plugins
4. **[Packet Manipulation](./Packets/#how-packets-can-be-manipulated)** - Learn advanced network modification techniques

### For Researchers
If you want to analyze or understand Animal Jam's systems:

1. **[Network Protocol](./Packets/#how-animal-jams-network-protocol-works)** - Learn how Animal Jam communicates
2. **[Message Types](./Packets/#types-of-network-messages)** - Understand different packet formats
3. **[Packet Analysis](./Packets/#learning-more-about-packets)** - Learn observation and experimentation techniques
4. **[Plugin Examples for Research](./Plugins/#username-logger-plugin)** - See how plugins can collect data

## Key Concepts

### Dual-Process Architecture
Strawberry Jam runs two separate programs that work together:
- **Main Client**: The control center that manages plugins and network traffic
- **Game Client**: The actual Animal Jam game window with enhanced features

This separation provides better security, stability, and flexibility.

### Plugin System
Plugins are add-on modules that extend Strawberry Jam's functionality:
- **UI Plugins**: Create user interfaces and control panels
- **Game Plugins**: Modify gameplay and game behavior
- **Live Loading**: Plugins can be enabled/disabled without restarting

### Network Interception
Strawberry Jam sits between your game and Animal Jam's servers:
- **Monitoring**: See all network traffic in real-time
- **Modification**: Change messages before they're sent or received
- **Injection**: Create and send custom messages
- **Analysis**: Study how Animal Jam's protocol works

## Safety and Responsibility

### Important Reminders
- **Account Safety**: Always test on non-main accounts when possible
- **Respect Others**: Don't use modifications to harm or harass other players
- **Follow Terms of Service**: Respect Animal Jam's rules and guidelines
- **Start Small**: Test modifications carefully before using them extensively

### Best Practices
- **Regular Backups**: Keep backups of important files before making changes
- **Incremental Testing**: Test small changes before making larger ones
- **Safe Development**: Use development accounts for plugin testing
- **Responsible Use**: Consider the impact of your modifications on others

## Common Use Cases

### Content Creation
- **Recording**: Use plugins to enhance recorded content
- **Analysis**: Study game mechanics for educational content
- **Automation**: Automate repetitive tasks for more engaging content

### Game Research
- **Protocol Analysis**: Study how Animal Jam's network protocol works
- **Feature Research**: Understand game mechanics and systems
- **Data Collection**: Gather information about game activity and patterns

### Quality of Life Improvements
- **Account Management**: Easily switch between multiple accounts
- **Automation**: Automate boring or repetitive tasks
- **Enhanced Features**: Add functionality not available in the base game

### Educational Purposes
- **Learning Programming**: Practice development skills with a real project
- **Network Education**: Learn about network protocols and communication
- **Game Development**: Understand how online games work

## Getting Help

### Documentation Navigation
- Each section has detailed explanations with real-world examples
- Use the links above to jump to specific topics
- All documentation is written for beginners but includes advanced topics

### Community and Support
- Read error messages carefully - they usually explain what's wrong
- Start with simple examples before attempting complex modifications
- Test changes incrementally to identify issues quickly
- Keep backups of working configurations

### Development Resources
- **CLAUDE.md**: Contains technical development guidelines
- **Plugin Examples**: Study existing plugins in the `plugins/` folder
- **Source Code**: All source code is available for learning and reference

## What's Next?

Choose your path based on what you want to accomplish:

**🚀 Just Getting Started?**
→ [Main Client Overview](./Main%20Client/#what-is-the-main-client)

**🔌 Want to Use Plugins?**
→ [Plugin Basics](./Plugins/#what-are-plugins)

**⚒️ Ready to Develop?**
→ [Development Workflow](./Main%20Client/#development-workflow)

**🔬 Interested in Research?**
→ [Network Protocol](./Packets/#how-animal-jams-network-protocol-works)

---

Remember: Strawberry Jam is a powerful tool that opens up many possibilities. Whether you're using it for fun, learning, or serious development, always prioritize safety, responsibility, and respect for the Animal Jam community.

Happy modding! 🍓