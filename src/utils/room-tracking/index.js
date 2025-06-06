/**
 * Room Tracking Utilities
 * 
 * This module provides utility functions for tracking and managing room identifiers
 * in Animal Jam, handling both regular rooms and adventure rooms.
 */
const logManager = require('../LogManager');

/**
 * Determines if a room is an adventure room based on its identifier.
 * Adventure rooms have different formats than regular rooms.
 * 
 * @param {string} room - The room identifier from the game
 * @returns {boolean} - True if this is an adventure room
 */
const isAdventureRoom = (room) => {
  if (!room) return false;
  
  // Adventure rooms can have various formats
  return room.includes('quest_') || 
         room.includes('adventures.room_adventure') || 
         room.includes('room_adventure') ||
         room.match(/quest_\d+_\d+_\d+/) ||
         room.includes('adventures.') ||
         /^quest_\w+$/.test(room) ||
         // Some adventure room IDs are just consecutive numbers
         (typeof room === 'string' && /^\d+$/.test(room) && room.length >= 6);
}

/**
 * Gets the effective room ID for use in packets.
 * Different packet types need different room ID formats.
 * 
 * @param {string} room - The room identifier from the game
 * @returns {string} - The effective room ID to use in packets
 */
const getEffectiveRoomId = (room) => {
  if (!room) return '';
  
  // Debug log to help diagnose issues
  logManager.debug(`[RoomTracking] Getting effective room ID for: ${room} (${typeof room})`);
  
  // Handle numeric room IDs
  if (!isNaN(room) || /^\d+$/.test(room)) {
    return room;
  }
  
  // Handle adventure rooms
  if (isAdventureRoom(room)) {
    return room;
  }
  
  // Player den format that uses full name format: player_den.room_main_freedenspring
  if (room.startsWith('player_den.')) {
    return room;
  }
  
  // Handle den name format: dennodobird (den + username)
  if (room.startsWith('den') && !room.includes('.') && !/^den\d+$/.test(room)) {
    return room;
  }
  
  // For standard rooms with '#' character
  // Example: transform "sarepia.room_main#3" to "sarepia.room_main#3"
  if (room.includes('#')) {
    return room;
  }
  
  // For other dot-notation rooms without special handling
  return room;
}

/**
 * Processes packet content by replacing {room} placeholders with the appropriate room ID.
 * 
 * @param {string} content - The packet content with {room} placeholders
 * @param {string} room - The current room identifier
 * @returns {string} - The processed content with replaced room IDs
 */
const processRoomInPacket = (content, room) => {
  if (!content || !room) return content
  
  if (content.includes('{room}')) {
    const effectiveRoomId = getEffectiveRoomId(room)
    return content.replaceAll('{room}', effectiveRoomId)
  }
  
  return content
}

/**
 * Parses a room-related packet to extract room information.
 * 
 * @param {string} packet - The raw packet content
 * @returns {object|null} - Room information if successfully parsed, null otherwise
 */
const parseRoomPacket = (packet) => {
  if (!packet || typeof packet !== 'string') return null
  
  const parts = packet.split('%')
  
  // Check if this is an XT packet
  if (parts[0] !== '' || parts[parts.length - 1] !== '') return null
  
  // Handle room change (rc) packet: %xt%o%rc%1476367%
  if (parts[2] === 'o' && parts[3] === 'rc') {
    return {
      type: 'room_change',
      userId: parts[4],
      roomId: null // Init request, doesn't include room yet
    }
  }
  
  // Handle outgoing room join (rj) request: %xt%o%rj%1476367%sarepia.room_main#3%1%0%0%
  if (parts[2] === 'o' && parts[3] === 'rj') {
    return {
      type: 'room_join_request',
      userId: parts[4],
      roomId: parts[5],
      params: parts.slice(6, -1) // Additional join parameters
    }
  }
  
  // Handle incoming room join (rj) response: %xt%rj%1476367%1%sarepia.room_main#6%9607%7%30%0%0%0%0%0%0%0%Sarepia Forest%18244%1%2%0%0%
  if (parts[2] === 'rj') {
    return {
      type: 'room_join_response',
      userId: parts[3],
      status: parts[4],
      roomId: parts[5],
      internalRoomId: parts[6], // Important to track
      roomName: parts[15], // Room display name
      additionalData: parts.slice(7, -1)
    }
  }
  
  // Handle room player (rp) packet: %xt%rp%9607%sarepia.room_main#6%0%0%0%100%119%%
  if (parts[2] === 'rp') {
    return {
      type: 'room_player',
      internalRoomId: parts[3],
      roomId: parts[4],
      playerData: parts.slice(5, -1)
    }
  }
  
  // No recognized room packet
  return null
}

/**
 * Updates the room state based on received packets.
 * Call this function whenever a packet is received to keep room state updated.
 * 
 * @param {string} packet - The raw packet content
 * @param {function} setStateCallback - Function to update the state (should accept key and value)
 * @returns {boolean} - True if packet was a room packet and state was updated
 */
const updateRoomStateFromPacket = (packet, setStateCallback) => {
  if (!packet || !setStateCallback || typeof setStateCallback !== 'function') return false;
  
  try {
    // First, try to use the more structured parsing function
    const roomData = parseRoomPacket(packet);
    if (roomData) {
      // Handle different packet types
      switch (roomData.type) {
        case 'room_join_response':
          // Successfully joined a room
          if (roomData.status === '1') {
            setStateCallback('room', roomData.roomId);
            setStateCallback('internalRoomId', roomData.internalRoomId);
            setStateCallback('roomName', roomData.roomName);
            logManager.debug(`[RoomTracking] Updated room state from rj packet: ${roomData.roomId}`);
            return true;
          }
          break;
          
        case 'room_player':
          // Update with current room data if available
          if (roomData.roomId) {
            setStateCallback('room', roomData.roomId);
            setStateCallback('internalRoomId', roomData.internalRoomId);
            logManager.debug(`[RoomTracking] Updated room state from rp packet: ${roomData.roomId}`);
            return true;
          }
          break;
          
        case 'room_join_request':
          // Store the requested room, but don't count it as joined yet
          if (roomData.roomId) {
            setStateCallback('requestedRoom', roomData.roomId);
            logManager.debug(`[RoomTracking] Stored requested room: ${roomData.roomId}`);
            // Don't return true as we haven't actually joined the room yet
          }
          break;
      }
    }
    
    // Additional checks for more packet formats not handled by parseRoomPacket
    
    // Check for den join packet: %xt%o%dj%2910%dennodobird%1%-1%
    const denJoinMatch = packet.match(/%xt%o%dj%\d+%([^%]+)%\d+%/);
    if (denJoinMatch && denJoinMatch[1]) {
      const denName = denJoinMatch[1];
      logManager.debug(`[RoomTracking] Detected den join packet for: ${denName}`);
      setStateCallback('room', denName);
      return true;
    }
    
    // Check for alternative room update formats
    const roomUpdateMatch = packet.match(/%xt%rj%\d+%1%([^%]+)%\d+%/);
    if (roomUpdateMatch && roomUpdateMatch[1]) {
      const roomId = roomUpdateMatch[1];
      logManager.debug(`[RoomTracking] Detected alternative room join for: ${roomId}`);
      setStateCallback('room', roomId);
      return true;
    }
    
    // Check for player_den formats
    if (packet.includes('player_den.room_main_') && packet.includes('%rp%')) {
      const playerDenMatch = packet.match(/%rp%\d+%([^%]+)%/);
      if (playerDenMatch && playerDenMatch[1]) {
        const roomId = playerDenMatch[1];
        logManager.debug(`[RoomTracking] Detected player den format: ${roomId}`);
        setStateCallback('room', roomId);
        return true;
      }
    }
    
    return false;
  } catch (error) {
    logManager.error(`[RoomTracking] Error updating room state: ${error.message}`, error);
    return false;
  }
}

module.exports = {
  isAdventureRoom,
  getEffectiveRoomId,
  processRoomInPacket,
  parseRoomPacket,
  updateRoomStateFromPacket
}
