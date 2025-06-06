# Humongous Plugin

A fun modification that allows your character to appear gigantic in Animal Jam Classic!

## Features

- Makes your animal character appear much larger than normal
- Customizable size parameter (default: `13` normal size)
- Toggle on/off with a simple command
- Visible to other players in the game

## How to Use

1. Join a room in Animal Jam Classic
2. Type the following command in the console

```
humongous
```

To customize the size, you can specify a number after the command:

```
humongous 9002
```

4. Re-join the room for other players to see you as a giant

## Toggle Off

Simply type the command again to return to normal size:

```
humongous
```

## Tips

- The default size is `13` normal size if no number is specified
- You must be in a room to use this plugin

## How It Works

This plugin intercepts your character's movement update packets and modifies the size parameter before sending them to the server, making your character appear much larger than normal to everyone in the room.

## Compatibility

This plugin is designed for Animal Jam Classic only.