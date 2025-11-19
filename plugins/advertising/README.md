# Auto Advertising Plugin

A powerful UI-based plugin that allows you to set up and schedule automated advertisement messages in Animal Jam.

## Features

- Create multiple custom advertisement messages
- Automatically rotate through messages at specified intervals
- Choose between sequential or random message ordering
- Save and load advertisement configurations
- Simple start/stop controls with status indicator
- Customizable time intervals between messages
- Configurable packet suffix to match your current game session

## How to Use

### Setting Up Messages

1. Enable the plugin through your plugin manager
2. Add advertisement messages using the "+ Add Message" button
3. Enter your messages in the text boxes
4. Use the "Preview" button to see how your message will appear
5. Remove any unwanted messages with the "Remove" button

### Configuration Options

#### Message Interval
- Set the time between messages (in seconds)
- Minimum recommended interval: 10 seconds
- Default interval: 60 seconds

#### Message Order
- **Sequential**: Messages are sent in the order they appear (1, 2, 3, etc.)
- **Random**: Messages are sent in random order

#### Message Suffix
- Use the **Message Suffix** field to control what is appended to every packet, defaulting to `%0`
- If advertising stops working, send a manual chat and inspect the raw payload to see the suffix after `${messageToSend}` inside `<msg t="sys"><body action="pubMsg" r="${targetRoomId}"><txt><![CDATA[${messageToSend}%0]]></txt></body></msg>`; copy that value into the input (only the part after the message)
- Saved configurations and local storage both remember this value, so update it whenever you notice the suffix changing

### Starting and Stopping

- Click the "Start" button to begin automatic advertising
- Click the "Stop" button to pause the message rotation
- Status indicator will show whether advertising is active or inactive

### Saving and Loading Configurations

- **Save**: Export your current message setup and settings to a JSON file
- **Load**: Import a previously saved configuration file

## Important Notes

- You must be in a room for messages to be sent
- At least one non-empty message is required to start advertising
- Using very short intervals may lead to chat restrictions
- The plugin will stop if you leave a room or disconnect from the game

## Compatibility

This plugin is designed for Animal Jam (Classic and Play Wild).

## Tips

- Create themed sets of advertisements for different purposes
- Consider the chat environment before setting intervals that are too frequent
- Use save/load feature to quickly switch between different advertisement sets
- Keep messages concise and within the game's chat character limits