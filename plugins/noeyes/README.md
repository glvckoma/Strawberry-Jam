# No Eyes Plugin

A simple plugin for Strawberry Jam that removes eyes from your avatar.

## Description

The No Eyes plugin allows you to remove the eyes from your avatar by sending a specific packet to the game server. This creates a unique appearance where your character appears without eyes.

## Usage

1. Make sure you are in a room in Animal Jam
2. Type the command: `noeyes`
3. Re-join the room to see the changes take effect

## Commands

- `noeyes` - Removes eyes from your avatar

## Technical Details

The plugin sends the packet: `%xt%o%iu%{room}%1%1%-315%-314%`

Where `{room}` is replaced with the current room ID.

## Requirements

- Must be in a room to use the plugin
- Requires Strawberry Jam client

## Installation

This plugin is included with Strawberry Jam. No additional installation required.

## Author

GlockGoat

## Version

1.0.0
