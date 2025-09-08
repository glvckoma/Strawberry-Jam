# Packet Editor Plugin

A comprehensive UI plugin for editing all variables in server-sent login packets in Animal Jam Classic.

## Features

- **Complete Packet Control**: Edit every variable in the login packet including user info, currency, settings, and more
- **User-Friendly Interface**: Organized sections for different types of packet data
- **Real-time Editing**: Modify values and see changes take effect on your next login
- **Settings Persistence**: All modifications are saved and restored between sessions
- **Packet Capture**: Automatically captures and stores the last received login packet
- **Reset Functionality**: Reset all values to default or load from last packet

## Usage

1. **Enable the Plugin**: Toggle the "Packet Modification" switch at the top
2. **Edit Values**: Modify any of the packet variables in the organized sections
3. **Save Settings**: Click "Save Settings" to persist your changes
4. **Login**: Re-login to see your modifications take effect

## Available Sections

### Basic User Information

- Username, User ID, Database User ID
- Email, Avatar Name, UUID

### Account Settings

- Account Type (Free, Member, Premium, Diamond)
- Moderator/Guide status
- Session ID, Login count, Jamaa date

### Currency & Items

- All currency types (Gems, Diamonds, Gold, Silver, etc.)
- Item counts and credits

### Advanced Settings

- Pet and Den room IDs
- Interaction counts and flags
- Timestamps and percentages

### Privacy & Chat Settings

- Den privacy, E-card settings
- Chat type and wall settings
- Online buddy status

### Subscription Settings

- Subscription type and duration
- Gift card counts
- Redemption cards

### Message Settings

- Broadcast messages
- Username moderation status

## Technical Details

- **Plugin Type**: UI Plugin
- **Settings File**: `packet-editor-settings.json`
- **Packet Storage**: `packet-editor-last-packet.json`
- **Packet Hook**: Intercepts `aj` type `login` messages

## Notes

- Changes only take effect on your next login
- The plugin automatically captures the last received login packet
- All modifications are persistent across application restarts
- Use the "Load from Last Packet" button to populate fields with actual server data
