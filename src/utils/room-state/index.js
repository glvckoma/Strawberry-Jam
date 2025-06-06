/**
 * Room State Management Module
 * 
 * This module provides a standardized way to interact with room state
 * across the application and plugins. It handles room state validation,
 * access methods, and change notifications.
 * 
 * This is the recommended way to access room state in all plugins.
 */

const roomTracking = require('../room-tracking');
const { ipcRenderer } = typeof require === 'function' ? require('electron') : { ipcRenderer: null };

/**
 * Room state access methods
 */
class RoomState {
  /**
   * Creates a new RoomState instance
   * @param {Object} dispatch - The dispatch instance from the application
   */
  constructor(dispatch) {
    this.dispatch = dispatch;
    this.changeListeners = new Set();
    this._lastValidRoom = null;
    
    // Set up listener for state changes if dispatch is available
    if (dispatch && typeof dispatch.setState === 'function') {
      // Save original setState to wrap it
      this._originalSetState = dispatch.setState;
      
      // Override setState to intercept room changes for listeners
      dispatch.setState = (key, value) => {
        const oldValue = dispatch.state[key];
        
        // Call original setState implementation
        const result = this._originalSetState.call(dispatch, key, value);
        
        // Notify listeners if room state changed
        if (key === 'room' && oldValue !== value) {
          this._notifyRoomChangeListeners(oldValue, value);
          
          // Update last valid room if the new value is valid
          if (this.isValidRoom(value)) {
            this._lastValidRoom = value;
          }
        }
        
        return result;
      };
    }
  }
  
  /**
   * Get the current room ID
   * @param {Object} options - Options for getting room state
   * @param {boolean} options.useEffectiveId - Whether to return the effective room ID
   * @param {boolean} options.allowFallback - Whether to allow fallback methods
   * @returns {string|null} - The current room ID or null if not available
   */
  getCurrentRoom({ useEffectiveId = false, allowFallback = true } = {}) {
    let room = null;
    let method = null;
    
    // Try to get room from dispatch using the most reliable methods first
    if (this.dispatch) {
      // Try synchronous method first (most reliable)
      if (this.dispatch.getStateSync && typeof this.dispatch.getStateSync === 'function') {
        try {
          room = this.dispatch.getStateSync('room');
          method = 'getStateSync';
        } catch (err) {
          console.warn('[RoomState] Error getting room with getStateSync:', err);
        }
      }
      
      // Fall back to state property access
      if (!room && this.dispatch.state && allowFallback) {
        room = this.dispatch.state.room;
        method = 'state.room';
      }
    }
    
    // Fall back to window.jam.state if available
    if (!room && window.jam && window.jam.state && allowFallback) {
      room = window.jam.state.room;
      method = 'window.jam.state.room';
    }
    
    // Fall back to last valid room if needed
    if (!room && this._lastValidRoom && allowFallback) {
      room = this._lastValidRoom;
      method = 'lastValidRoom';
    }
    
    // Additional debugging information about the received room
    if (room) {
      console.log(`[RoomState] Before processing - Room: '${room}', Type: ${typeof room}, Method: ${method}`);
    } else {
      console.log(`[RoomState] No room available from any source method`);
      return null;
    }
    
    // Get effective room ID if requested and room utils are available
    if (room && useEffectiveId && window.jam && window.jam.roomUtils) {
      try {
        const effectiveRoom = window.jam.roomUtils.getEffectiveRoomId(room);
        console.log(`[RoomState] Effective room ID: ${effectiveRoom} (original: ${room})`);
        return effectiveRoom;
      } catch (err) {
        console.warn('[RoomState] Error getting effective room ID:', err);
        return room; // Fall back to original room if error
      }
    }
    
    if (room) {
      console.log(`[RoomState] Got room '${room}' using method: ${method}`);
    }
    
    return room;
  }
  
  /**
   * Get the current room asynchronously (Promise-based)
   * @param {Object} options - Options for getting room state
   * @param {boolean} options.useEffectiveId - Whether to return the effective room ID
   * @param {boolean} options.allowFallback - Whether to allow fallback methods
   * @returns {Promise<string|null>} - Promise resolving to the room ID
   */
  async getCurrentRoomAsync({ useEffectiveId = false, allowFallback = true } = {}) {
    // First try sync methods
    let room = this.getCurrentRoom({ useEffectiveId, allowFallback });
    
    // If we already have a room, just return it
    if (room) {
      return room;
    }
    
    // Try async getState method if available
    if (this.dispatch && this.dispatch.getState && typeof this.dispatch.getState === 'function') {
      try {
        room = await this.dispatch.getState('room');
        
        // Get effective room ID if requested
        if (room && useEffectiveId && window.jam && window.jam.roomUtils) {
          try {
            room = window.jam.roomUtils.getEffectiveRoomId(room);
          } catch (err) {
            console.warn('[RoomState] Error getting effective room ID:', err);
            // Continue with original room
          }
        }
        
        return room;
      } catch (err) {
        console.warn('[RoomState] Error getting room with getState:', err);
      }
    }
    
    // Fall back to last valid room if nothing else worked
    if (!room && this._lastValidRoom && allowFallback) {
      room = this._lastValidRoom;
      
      // Get effective room ID if requested
      if (room && useEffectiveId && window.jam && window.jam.roomUtils) {
        try {
          room = window.jam.roomUtils.getEffectiveRoomId(room);
        } catch (err) {
          console.warn('[RoomState] Error getting effective room ID:', err);
          // Continue with original room
        }
      }
    }
    
    return room;
  }
  
  /**
   * Check if the current room is valid
   * @param {string} room - The room ID to validate
   * @returns {boolean} - Whether the room is valid
   */
  isValidRoom(room) {
    if (!room) return false;
    
    // Basic validation
    if (typeof room !== 'string') return false;
    if (room.trim() === '') return false;
    
    // Check for common room formats
    const isValidFormat = 
      // Regular rooms: sarepia.room_main#3
      /^[a-zA-Z0-9_]+\.[a-zA-Z0-9_]+#\d+$/.test(room) || 
      // Adventure rooms
      roomTracking.isAdventureRoom(room) ||
      // Den rooms: den12345
      /^den\d+$/.test(room) ||
      // Numeric rooms (internal IDs)
      /^\d+$/.test(room) ||
      // Player den format: player_den.room_main_freedenspring
      /^player_den\.room_main_\w+$/.test(room) ||
      // Den name format: dennodobird (den + username)
      /^den[a-zA-Z0-9_]+$/.test(room) ||
      // Additional check for all room formats with dot notation
      /^[a-zA-Z0-9_]+\.[a-zA-Z0-9_]+$/.test(room);
    
    return isValidFormat;
  }
  
  /**
   * Register a listener for room state changes
   * @param {Function} listener - The callback function to call when room state changes
   * @returns {Function} - A function to unregister the listener
   */
  onRoomChange(listener) {
    if (typeof listener !== 'function') {
      throw new Error('[RoomState] Listener must be a function');
    }
    
    this.changeListeners.add(listener);
    
    // Return a function to unregister the listener
    return () => {
      this.changeListeners.delete(listener);
    };
  }
  
  /**
   * Notify all registered listeners about a room state change
   * @param {string} oldRoom - The previous room ID
   * @param {string} newRoom - The new room ID
   * @private
   */
  _notifyRoomChangeListeners(oldRoom, newRoom) {
    // Don't notify if room hasn't actually changed
    if (oldRoom === newRoom) return;
    
    // Notify all listeners
    for (const listener of this.changeListeners) {
      try {
        listener(oldRoom, newRoom);
      } catch (err) {
        console.error('[RoomState] Error in room change listener:', err);
      }
    }
  }
  
  /**
   * Process a message containing {room} placeholders
   * @param {string} message - The message to process
   * @returns {string} - The processed message
   */
  processRoomPlaceholders(message) {
    if (typeof message !== 'string' || !message.includes('{room}')) {
      return message;
    }
    
    const room = this.getCurrentRoom({ useEffectiveId: true });
    
    if (!room) {
      throw new Error('[RoomState] Cannot process room placeholders: No room available');
    }
    
    return message.replace(/\{room\}/g, room);
  }
}

// Create singleton instance for main process
let instance = null;

/**
 * Get the RoomState instance
 * @param {Object} dispatch - The dispatch instance from the application
 * @returns {RoomState} - The RoomState instance
 */
function getRoomState(dispatch) {
  if (!instance) {
    instance = new RoomState(dispatch);
  }
  return instance;
}

module.exports = {
  getRoomState,
  RoomState
}; 