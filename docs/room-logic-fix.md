# Room Logic Fix

## Overview
This fix implements consistent room state management across all plugins in the Strawberry Jam application. It addresses the "need to be in a room" errors by providing robust packet parsing, consistent state storage, and improved error handling.

## Changes Made

### 1. Enhanced Room Tracking Utilities
- Added packet parsing functions in `src/utils/room-tracking/index.js`
- Created dedicated functions to parse room-related packets:
  - `parseRoomPacket()` - Extracts room information from XT packets
  - `updateRoomStateFromPacket()` - Manages state updates based on packet data
  - Improved `getEffectiveRoomId()` - Returns the appropriate room ID format for packets

### 2. Room State Management in Dispatch
- Updated the dispatch system in `src/electron/renderer/application/dispatch/index.js`
- Added optimized `getStateSync()` method for synchronous room state access
- Enhanced `setState()` to prevent unnecessary updates
- Added proper logging for room state changes. (In Strawberry Jam 3.0.0, this uses the improved `LogManager` for more consistent and detailed logging, which helps in diagnosing issues. For example, you might see `logManager.debug('[Dispatch] Room state updated...')` in the development logs.)

### 3. Core Packet Handler Integration
- Updated `src/electron/renderer/application/index.js` network event handler
- Added automatic room state tracking for all incoming packets
- Centralized room state parsing to ensure consistency

### 4. Plugin Exposure
- Enhanced `src/electron/preload.js` to expose all room utility functions to plugins
- Made room utilities available via `window.jam.roomUtils` interface

### 5. Plugin-Specific Improvements
- Updated TFD Automator plugin:
  - Enhanced room detection in `handleJoinRoom()`
  - Added better fallbacks in `sendNextPacket()`
  - Added proper error messages when room isn't available
- Updated Spammer plugin:
  - Added clear error messages for room-dependent functions
  - Prevented sending packets when room is required but not available
  - Added multiple fallback methods to get room state

## Packet Format Reference

The room-related packets follow these patterns:

### Room Change (rc)
```
%xt%o%rc%1476367%
```
- Initiates a room change for the user ID

### Room Join Request (rj)
```
%xt%o%rj%1476367%sarepia.room_main#3%1%0%0%
```
- User ID: 1476367
- Target Room: sarepia.room_main#3
- Parameters: 1, 0, 0

### Room Join Response (rj)
```
%xt%rj%1476367%1%sarepia.room_main#6%9607%7%30%0%0%0%0%0%0%0%Sarepia Forest%18244%1%2%0%0%
```
- User ID: 1476367
- Status: 1 (success)
- Room ID: sarepia.room_main#6
- Internal Room ID: 9607
- Room Name: Sarepia Forest
- Additional data: various room parameters

### Room Player (rp)
```
%xt%rp%9607%sarepia.room_main#6%0%0%0%100%119%%
```
- Internal Room ID: 9607
- Room ID: sarepia.room_main#6
- Player data: position and state information

## Testing
When testing the changes, verify:
1. All plugins can successfully detect the current room
2. Changing rooms properly updates the room state
3. Room-dependent functions show appropriate error messages
4. TFD Automator successfully detects when in the user's den
