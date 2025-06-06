# Membership Plugin

A simple but useful plugin that simulates membership status by modifying your client-side account type.

## What This Plugin Does

The Membership plugin modifies your login packets to make your game client believe you have membership status. This allows you to see the game as if you were a member, without actually purchasing a membership.

## Features

- Simulates membership status locally
- Works automatically upon login
- No configuration needed

## Important Limitations

Please be aware of the following limitations:

- **Local Effect Only**: The membership status is only visible to you, not to other players
- **Cannot Purchase Member Items**: You cannot buy member-only items or animals
- **No Member Quests**: You cannot participate in member-only quests
- **No Premium Features**: Other premium membership features requiring server validation will not work

## How It Works

This plugin intercepts the login message packet and modifies the `accountType` parameter to "2", which is the code for membership status. This tricks your local game client into displaying membership features without actually changing your account status on the server.

## Compatibility

This plugin is designed for Animal Jam Classic only.
