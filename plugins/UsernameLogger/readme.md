# Username Logger Plugin

A helpful Animal Jam Classic plugin that safely collects and stores usernames of players you encounter in the game. It can also check if those usernames appear in any public data leaks using the LeakCheck.io service.

## What This Plugin Does

- **Collects Usernames**: Records the usernames of nearby players and buddies you meet while playing
- **Keeps Lists**: Saves all collected usernames in organized text files
- **Safety Checking**: Can check if usernames appear in public data leaks (requires LeakCheck.io API key)
- **Finds Information**: Helps identify potentially compromised Animal Jam accounts
- **Remembers Progress**: Keeps track of what it's already checked, even when you restart
- **Easy Commands**: Simple commands to control all features

## Modular Architecture

This plugin follows the "One File, One Function" architecture principle to improve maintainability, testability, and scalability.

### Directory Structure

```
/UsernameLogger
├── index.js                 # Entry point (thin orchestration layer)
├── config.json              # Configuration file 
├── plugin.json              # Plugin metadata
├── readme.md                # Documentation
├── /constants/              # Shared constants
│   └── constants.js         # All hardcoded values 
├── /models/                 # Data models
│   ├── config-model.js      # Configuration management
│   └── state-model.js       # Runtime state management
├── /services/               # Core services
│   ├── file-service.js      # File operations
│   ├── api-service.js       # API communications
│   ├── leak-check-service.js # Leak checking logic
│   └── migration-service.js # Data migration
├── /handlers/               # Event handlers
│   ├── command-handlers.js  # Command processing
│   └── message-handlers.js  # Game message processing 
└── /utils/                  # Utility functions
    ├── batch-logger.js      # Batched logging
    ├── path-utils.js        # Path management
    └── username-utils.js    # Username processing
```

### Component Responsibilities

#### Models
- **ConfigModel** - Manages loading, saving, and accessing configuration
- **StateModel** - Manages runtime state (leak check status, username lists, etc.)

#### Services
- **FileService** - Handles all file I/O operations
- **ApiService** - Manages communication with external APIs
- **LeakCheckService** - Performs leak checking operations
- **MigrationService** - Handles data migration between versions

#### Handlers
- **CommandHandlers** - Processes user commands
- **MessageHandlers** - Processes game messages to extract usernames

#### Utils
- **BatchLogger** - Manages batched console message display
- **PathUtils** - Handles file path resolution and management
- **UsernameUtils** - Provides username processing and validation functions

## Commands

- `!userlog` - Toggles username logging on/off
- `!userlogsettings [setting] [value]` - Configure settings (nearby, buddies, autoleakcheck, threshold, reset)
- `!leakcheck [all|number]` - Run a leak check on collected usernames
- `!leakcheckstop` - Stop a running leak check
- `!setapikey YOUR_API_KEY` - Set the LeakCheck API key
- `!testapikey` - Test if the current API key is valid
- `!trimprocessed` - Remove processed usernames from the collected list and reset index
- `!usercount` - Display the number of usernames in the collected username files

## Configuration

The plugin stores its configuration in `config.json` with the following settings:

- `isLoggingEnabled` - Whether username logging is enabled
- `collectNearbyPlayers` - Whether to collect usernames from nearby players
- `collectBuddies` - Whether to collect usernames from buddies
- `autoLeakCheck` - Whether to automatically run leak checks
- `autoLeakCheckThreshold` - Number of usernames to collect before auto-running leak check
- `leakCheckLastProcessedIndex` - Index tracking leak check progress
- `migrationCompleted` - Whether data migration has been completed

## Implementation Details

This plugin follows clean code principles:

1. **Single Responsibility Principle** - Each file has one clear purpose
2. **Explicit Dependencies** - Dependencies are clearly declared and injected
3. **Error Handling** - Robust error handling with appropriate feedback
4. **State Management** - Clear state ownership and transitions
5. **Asynchronous Operations** - Proper use of async/await for file and network operations
6. **Batch Processing** - Efficient batch handling for both UI feedback and file I/O

## LeakCheck.io API Requirements

### What is LeakCheck.io?
LeakCheck.io is an online service that maintains a database of usernames and passwords that have been made public in data breaches. This plugin uses LeakCheck.io to check if Animal Jam usernames appear in these databases.

### Getting an API Key
To use the leak checking features, you need a LeakCheck.io API key, which requires a paid subscription:

1. Visit [LeakCheck.io](https://leakcheck.io) and create an account
2. Purchase a subscription plan (Pro plan or higher is required for API access)
3. Go to your account settings to find your API key
4. In the plugin, use the command `!setapikey YOUR_API_KEY` to set your key

### Using Your API Key
- The API key only needs to be set once, as it will be saved in your settings
- You can test if your API key is working with the `!testapikey` command
- Your key can also be set in the application settings screen
- Each API request counts toward your LeakCheck.io quota (check your plan limits)

### Privacy and Safety
- The plugin only sends usernames to LeakCheck.io, never any personal information
- All results are stored locally on your computer
- API keys are stored securely in the application settings
- No data is shared with other users or third parties

## Data Files

When using the plugin, it creates several data files:

- `collected_usernames.txt` - All usernames collected from the game
- `processed_usernames.txt` - Usernames that have been checked
- `found_accounts.txt` - Accounts found in public data leaks
- `ajc_accounts.txt` - Accounts specifically from Animal Jam data leaks
- `potential_accounts.txt` - Usernames that might need manual verification
- `working_accounts.txt` - Working accounts that have been verified
