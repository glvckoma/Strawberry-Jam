# Username Logger Plugin

This plugin provides a unified system for collecting and analyzing usernames in Animal Jam Classic, integrating leak checking functionality.

## Features

- **Unified Username Collection**: Collects usernames from multiple sources:
  - Nearby players (from 'ac' messages)
  - Buddy list (from 'bl' messages)
  - Newly added buddies (from 'ba' messages)
  - Buddies coming online (from 'bon' messages)

- **Configurable Collection**: Choose which types of usernames to collect:
  - Nearby players only
  - Buddies only
  - Both (default)

- **Integrated Leak Checking**: Check collected usernames against the LeakCheck API:
  - Find leaked credentials
  - Separate Animal Jam specific leaks
  - Resume interrupted checks
  - Pause/stop running checks

- **Flexible Output Management**:
  - Custom output directory support
  - Automatic file creation
  - Desktop fallback if data directory is unavailable

- **Persistent Configuration**:
  - Settings saved between sessions
  - API key loaded from Jam settings

## Commands

### Logging Control

- `userlog [on|off|status]` - Toggle username logging or check status
- `userlogpath [directory]` - Set custom directory for log files
- `userlogsettings [setting] [value]` - Configure logging settings
  - `userlogsettings nearby [on|off]` - Toggle nearby player collection
  - `userlogsettings buddies [on|off]` - Toggle buddy collection
  - `userlogsettings autoleakcheck [on|off]` - Toggle automatic leak checking
  - `userlogsettings threshold [number]` - Set auto leak check threshold
  - `userlogsettings reset` - Reset settings to defaults
- `clearleaklogs` - Clear only leak check result files


### API Configuration

- `setapikey [api_key]` - Set the LeakCheck API key directly in the plugin
- `debug` - Show debug information about the plugin state and API key

### Legacy Commands (Backward Compatibility)

- `!buddylog` - Alias for `!userlog`
- `!buddylogpath` - Alias for `!userlogpath`

## Output Files

The plugin creates and manages the following files in the configured output directory (defaults to `./data/`):

- `collected_usernames.txt`: All unique usernames collected during logging sessions (with timestamps).
- `processed_usernames.txt`: Usernames that have been successfully processed by the leak checker (found or not found). This acts as the ignore list.
- `potential_accounts.txt`: Usernames that failed the leak check due to invalid characters or other API issues.
- `found_accounts.txt`: Found credentials (`username:password`) from any source during leak checks.
- `ajc_accounts.txt`: Found credentials (`username:password`) specifically identified as coming from Animal Jam leaks.

## Setup

1. Ensure the plugin is installed in the `plugins/UsernameLogger` directory.
2. Set your LeakCheck API key using one of these methods:
   - In Jam settings (`leakCheckApiKey` property - may be unreliable).
   - **Recommended:** Directly in the plugin console with `setapikey YOUR_API_KEY`.
3. Enable logging with `userlog on`.
4. Configure settings as needed with `userlogsettings`.

## Auto Leak Check

When enabled, the plugin will automatically run a leak check after collecting a specified number of usernames (default: 50). This can be configured with:

```
userlogsettings autoleakcheck on
userlogsettings threshold 100
```

## Notes

- The plugin requires the LeakCheck API key for leak checking functionality. Using the `!setapikey` command is the most reliable way to provide it.
- Usernames collected are deduplicated within the current session before being logged.
- The `processed_usernames.txt` file acts as an ignore list to prevent re-processing usernames in subsequent leak checks.
- All log files are created in the specified output directory (defaults to `./data/`).
