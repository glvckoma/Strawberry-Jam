# Phantoms Plugin

A plugin that automates the Phantoms adventure on Hard Mode in Animal Jam Classic: loops adventure packets, collects chest prizes, and recycles non‑clothing beta items for gems when filtering is on.

## Features

- Automatically loops through the Phantoms adventure sequence (800 ms interval)
- Toggle IL filtering on/off to recycle unwanted items
- `/phantoms` toggles both the adventure loop and item filtering
- `/phantoms off` keeps the loop running but disables IL‑based recycling
- Smart IL sniffing: only recycles items when packet length and ID match criteria (exactly 14 fields, IDs ≠ 138/148/342)

## How to Use

1. Join a room in Animal Jam Classic.
2. In the console, type:
   ```
   /phantoms
   ```
   This starts the adventure loop **and** IL filtering.
3. To disable filtering but keep the adventure running:
   ```
   /phantoms off
   ```
4. To stop the adventure loop entirely:
   ```
   /phantoms
   ```

## Toggle Off

Running `/phantoms` when active will stop both the loop and IL sniffing:

```
/phantoms
```

## Tips

- Filtering is enabled by default when you first run `/phantoms`.
- Filtering recycles any non‑clothing‑beta items (IDs other than `138`, `148`, and `342`) immediately.
- Ensure you're in a room before using the plugin; otherwise, no packets will be sent.

## How It Works

- The plugin sends a predefined sequence of packets to start and complete the Phantoms adventure on Hard Mode every 800 ms.
- When IL sniffing is enabled, it listens for `il` packets of exact length (14 fields) and sends a recycle packet for any item IDs that aren't `138`, `148`, or `342`.
- The loop and sniffing states can be toggled independently using the `/phantoms` and `/phantoms off` commands.

## Compatibility

This plugin is designed specifically for Animal Jam Classic and requires Jam's plugin API (`dispatch`, `application`).

## Author

Nosmile
