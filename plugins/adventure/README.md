# Adventure Plugin

A useful plugin that automatically generates treasure chests and provides experience in Animal Jam Classic adventures.

## Features

- Automatically spawns treasure chests in your current room
- Grants adventure experience points
- Toggle on/off with a simple command
- Operates on a timer for continuous benefits

## How to Use

1. Enable the plugin through your plugin manager
2. Join a room in Animal Jam Classic (preferably an adventure area)
3. Type the following command in the console:

```
adventure
```

4. Treasure chests will begin to appear and provide experience
5. Type the command again to stop the automatic treasure spawning:

```
adventure
```

## Important Notes

- You must be in a room to use this plugin
- Works best in adventure areas where treasures naturally spawn
- The plugin sends treasure spawn packets every 0.6 seconds
- Excessive use may be detected by game moderators

## How It Works

This plugin sends specialized treasure chest packets to the server that:
1. Requests a treasure spawn (`qat` packet)
2. Claims the treasure reward (`qatt` packet)

These actions happen automatically every 600 milliseconds while the plugin is active.

## Compatibility

This plugin is designed for Animal Jam Classic only.

## Benefits

- Quickly level up your adventure rank
- Obtain adventure rewards faster