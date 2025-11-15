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
      callback: ({ message }) => {
        if (message.value && message.value.b && message.value.b.o && message.value.b.o.params) {
          const playerData = message.value.b.o.params
          this.setState('player', playerData)
          if (playerData[0]) {
            this.setState('userId', playerData[0])
          }
        }
      }
    })
  }
}

