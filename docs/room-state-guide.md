# Room State Guide (Post-Reversion to @jam-master Logic)

This document outlines how to interact with room state in Strawberry Jam after the core logic has been reverted to align with `@jam-master`'s original approach.

## Overview of Changes

The previously documented "Standardized Room State Utilities" (formerly accessed via `window.jam.roomState`) are **deprecated or no longer fully functional** as described before. The system now relies on a simpler model where the core provides basic room identification, and plugins are responsible for more detailed state management.

## Accessing Basic Room State

The primary way for plugins to get the current basic room identifier is through the `dispatch` object:

```javascript
// Ensure dispatch is available (e.g., passed to your plugin or via window.jam.dispatch)
const dispatch = window.jam.dispatch;

// Get the current room ID string
const currentRoomId = dispatch.getState('room');

if (currentRoomId) {
  console.log('Current Room ID:', currentRoomId);
  // Use currentRoomId in your plugin logic, e.g., for sending packets
} else {
  console.warn('Not currently in a known room or room state not yet set.');
}
```

The `dispatch.state.room` is typically set by the core system when a room join (`rj`) packet is successfully processed.

Similarly, basic player information (from the `login` packet) can be accessed:
```javascript
const playerData = dispatch.getState('player');

if (playerData) {
  console.log('Player Data:', playerData);
  // Example: const userId = playerData.userId;
}
```

## Plugin Responsibility for Detailed Room State

After this reversion, plugins are responsible for managing any detailed room state they require beyond the basic `roomId` and `playerData` provided by `dispatch.getState()`. This includes:

*   **Player Lists:** Tracking which players are in the current room.
*   **Player Positions:** Monitoring player movements.
*   **Den Items:** Knowing the items and their layout in a den.
*   **Internal Room IDs / Full Room Names:** If a plugin needs the internal numeric ID of a room or its descriptive name (e.g., "Sarepia Forest"), it must parse this from the relevant packets (like `rj`).
*   **Adventure-Specific State:** Tracking progress, objectives, or specific states within game adventures.

To achieve this, plugins must use `dispatch.onMessage` to listen for and parse the relevant XT packets from the server (e.g., `ap` - add player, `lp` - leave player, `s#up` - user position, `s#mp` - map player, `s#dp` - den items, `rj` - for detailed room info).

**Example: Listening for Players Joining**
```javascript
// Inside your plugin
dispatch.onMessage({
  type: 'aj', // Message from Animal Jam server
  message: 'ap', // Add Player packet type (verify exact type)
  callback: ({ message }) => {
    // 'message' is the parsed packet object (e.g., XtMessage)
    // message.value will contain the packet data array
    // Example: const newPlayerId = message.value[4]; // Index depends on packet structure
    // Add logic to store and manage your player list
    console.log('Player joined/appeared:', message.value);
  }
});
```

## `{room}` Placeholder in Packets

The functionality for replacing a `{room}` placeholder in packets sent via `dispatch.sendRemoteMessage()` or `dispatch.sendConnectionMessage()` (if handled by `Application.js`) should still work for substituting the basic `currentRoomId` obtained from `dispatch.getState('room')`.

Example:
```javascript
const chatMessage = "Hello everyone in {room}!";
// Application.js might process this to:
// const processedMessage = chatMessage.replaceAll('{room}', dispatch.getState('room'));
// dispatch.sendRemoteMessage(`<msg t="sys"><body>...${processedMessage}...</body></msg>`);
```
Plugins can rely on this for simple room ID substitution in outgoing packets. If more complex room ID formatting is needed (e.g., the "effective room ID" for different packet types), plugins might need to incorporate logic similar to what was in `src/utils/room-tracking.js`'s `getEffectiveRoomId` function, or that utility could be maintained for this specific purpose.

## Room Change Notifications

The `window.jam.roomState.onRoomChange()` mechanism is deprecated. Plugins that need to react to room changes should listen for the `rj` (room join) packet via `dispatch.onMessage` and then check `dispatch.getState('room')` to see if it has changed from their previously known room.

## Summary for Plugin Developers

1.  **Primary Room ID:** Use `window.jam.dispatch.getState('room')` for the basic current room identifier.
2.  **Detailed State:** Implement your own packet listeners (`dispatch.onMessage`) and parsers for any detailed room state (player lists, positions, item states, full room names, internal IDs, etc.).
3.  **`{room}` Placeholder:** Can likely still be used for basic room ID substitution in outgoing packets.
4.  **Deprecated:** `window.jam.roomState` and its associated methods (`getCurrentRoom`, `isValidRoom`, `onRoomChange`, `processRoomPlaceholders` for detailed state) should no longer be relied upon as they were previously documented.

This guide reflects the shift towards a more decentralized, plugin-driven approach to detailed room state management, aligning with the original `@jam-master` architecture.
