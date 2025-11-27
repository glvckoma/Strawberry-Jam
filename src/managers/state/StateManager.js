const { ConnectionMessageTypes } = require('../../Constants')

const isDevelopment = process.env.NODE_ENV === 'development'

module.exports = class StateManager {
  constructor(state, onMessageCallback) {
    this.state = state
    this.onMessage = onMessageCallback
  }

  setState(key, value) {
    if (this.state[key] === value) {
      if (key === 'room') {}
      return this
    }
    
    this.state[key] = value
    if (key === 'room') {}
    
    return this
  }

  getStateSync(key) {
    if (this.state[key] !== undefined) {
      return this.state[key]
    }
    
    if (typeof require === 'function') {
      try {
        const { ipcRenderer } = require('electron')
        const value = ipcRenderer.sendSync('dispatch-get-state-sync', key)
        if (value !== undefined) {
          this.state[key] = value
          return value
        }
      } catch (e) {
        console.error(`[StateManager] Error in getStateSync for key ${key}:`, e)
      }
    }
    
    return null
  }

  getState(key, defaultValue = null) {
    const value = this.state[key] !== undefined ? this.state[key] : defaultValue
    if (key === 'room') {} else if (key === 'player') {}
    return value
  }

  updateState(key, value) {
    if (this.state[key]) {
      this.state[key] = value
    } else {
      throw new Error('Invalid state key.')
    }
    return this
  }

  initializeDefaultStateHandlers() {
    this.onMessage({
      type: ConnectionMessageTypes.aj,
      message: 'rj',
      callback: ({ message }) => {
        if (message.value && message.value.length > 6 && message.value[4] === '1') {
          const textualRoomId = message.value[5]
          const numericalInstanceRoomId = message.value[6]

          if (textualRoomId) {
            this.setState('room', textualRoomId)
          }

          if (numericalInstanceRoomId && !isNaN(parseInt(numericalInstanceRoomId))) {
            this.setState('internalRoomId', numericalInstanceRoomId)
          } else {
            if (textualRoomId && !isNaN(parseInt(textualRoomId))) {
              this.setState('internalRoomId', textualRoomId)
              if (isDevelopment) console.warn(`[StateManager] Fallback: Using textualRoomId '${textualRoomId}' as internalRoomId because numericalInstanceRoomId was invalid.`)
            } else {
              this.setState('internalRoomId', null)
              if (isDevelopment) console.warn(`[StateManager] No valid numerical room ID found in 'rj' packet. 'internalRoomId' set to null.`)
            }
          }
        } else {
          this.setState('room', null)
          this.setState('internalRoomId', null)
        }
      }
    })

    this.onMessage({
      type: ConnectionMessageTypes.aj,
      message: 'login',
      callback: ({ message, client }) => {
        if (message.value && message.value.b && message.value.b.o && message.value.b.o.params) {
          const playerData = message.value.b.o.params
          this.setState('player', playerData)
          
          // Track username and userId on the client instance
          if (client) {
            // Debug: log the structure in development
            if (isDevelopment) {
              console.log('[StateManager] Login packet received, playerData type:', typeof playerData, 'isArray:', Array.isArray(playerData))
              console.log('[StateManager] playerData keys/sample:', Array.isArray(playerData) ? `Array[${playerData.length}]` : Object.keys(playerData || {}).slice(0, 10))
            }
            
            // Login packet params is typically an object with properties
            if (typeof playerData === 'object' && playerData !== null) {
              // Try various possible username fields (check userName first as it's the actual field name)
              const usernameFields = ['userName', 'username', 'name', 'screenName', 'screen_name', 'playerName', 'player_name']
              for (const field of usernameFields) {
                if (playerData[field] && typeof playerData[field] === 'string') {
                  client.username = String(playerData[field])
                  break
                }
              }
              
              // Try various possible userId fields (userId is the actual field name)
              const userIdFields = ['userId', 'id', 'dbUserId', 'dbId', 'playerId', 'player_id']
              for (const field of userIdFields) {
                if (playerData[field] !== undefined && playerData[field] !== null) {
                  client.userId = String(playerData[field])
                  this.setState('userId', playerData[field])
                  break
                }
              }
            }
            // Fallback: Handle array format if it's actually an array
            else if (Array.isArray(playerData)) {
              if (playerData[0] !== undefined && playerData[0] !== null) {
                client.userId = String(playerData[0])
                this.setState('userId', playerData[0])
              }
              if (playerData[1] && typeof playerData[1] === 'string') {
                client.username = playerData[1]
              }
            }
            
            // Debug logging
            if (isDevelopment) {
              console.log(`[StateManager] Client ${client.clientId} - username: "${client.username || 'NOT SET'}", userId: "${client.userId || 'NOT SET'}"`)
            }
          } else if (isDevelopment) {
            console.warn('[StateManager] Login packet received but client parameter is missing!')
          }
        }
      }
    })
  }
}

