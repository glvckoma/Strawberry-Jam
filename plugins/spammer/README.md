# Packet Spammer

A powerful packet manipulation tool that allows you to send custom packets with advanced scheduling capabilities.

## Features

- Send individual packets or multi-line packets
- Create queues of packets to be sent sequentially
- Set custom delays between packets
- Run packets in loop or one-time mode
- Save and load packet configurations
- Support for room placeholder replacement

## How to Use

### Basic Usage

1. Enter your packet content in the text area
2. Select the packet type:
   - **Client** - Sends a connection packet
   - **Animal Jam** - Sends a game-specific packet
3. Click **Send** to immediately send the packet

### Creating Packet Queues

1. Enter packet content in the text area
2. Set the packet type (Client/Animal Jam)
3. Set the delay (in seconds) before the next packet is sent
4. Click **Add** to add the packet to the queue
5. Repeat steps 1-4 to add more packets to your queue
6. Use the **Start** button to begin running your packet queue

### Running Options

- **Loop** - Continuously runs through all packets in the queue
- **Once** - Runs through all packets in the queue once and stops

### Advanced Features

#### Multi-line Packets

You can enter multiple lines in the text area to send multiple packets at once:
```
%xt%o%gn%-1%
%xt%o%gz%-1%
```

#### Room Placeholder

Use `{room}` in your packets to automatically replace it with your current room ID:
```
%xt%o%gp%{room}%
```

### Saving and Loading

- **Save** - Save your current packet queue to a JSON file
- **Load** - Load a previously saved packet queue

## Tips

- Use the tab key in the text area for better formatting
- You can stop a running queue anytime using the **Stop** button
- Hover over packet content in the queue to see the full text
- Delete individual packets from the queue using the trash icon

## Notes

- Use responsibly and be aware of rate limits