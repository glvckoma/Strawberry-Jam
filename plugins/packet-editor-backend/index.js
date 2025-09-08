const { ipcRenderer } = require('electron')

module.exports = function ({ dispatch, application }) {
  let active = false
  let packetModifications = {}
  let customVariables = {}
  const SETTINGS_FILE = 'packet-editor-settings.json'

  /**
   * Load settings from the settings file.
   */
  const loadSettings = async () => {
    try {
      const settings = await ipcRenderer.invoke('read-json-file', SETTINGS_FILE, {
        active: false,
        modifications: {},
        customVariables: {}
      })
      active = settings.active
      packetModifications = settings.modifications || {}
      customVariables = settings.customVariables || {}
    } catch (error) {
      console.error('[Packet Editor Backend] Error loading settings:', error)
      active = false
      packetModifications = {}
    }
  }

  /**
   * Reload settings (called periodically to sync with UI)
   */
  const reloadSettings = async () => {
    await loadSettings()
  }

  /**
   * Handles the login message and applies modifications.
   */
  const handleLoginMessage = ({ message }) => {
    if (!active) return // Only modify login when plugin is active

    // Get original params
    const originalParams = message.value.b.o.params
    
    // Combine regular modifications and custom variables
    const allModifications = { ...packetModifications, ...customVariables }
    
    // Create new params object with custom variables inserted after isModerator
    const newParams = {}
    let insertedCustomVars = false
    
    // Copy original params and insert custom variables after isModerator
    Object.keys(originalParams).forEach(key => {
      // Apply modifications to existing keys
      if (allModifications[key] !== undefined && allModifications[key] !== null) {
        // Handle special cases for boolean values
        if (typeof allModifications[key] === 'string') {
          if (allModifications[key] === 'true') {
            newParams[key] = true
          } else if (allModifications[key] === 'false') {
            newParams[key] = false
          } else {
            newParams[key] = allModifications[key]
          }
        } else {
          newParams[key] = allModifications[key]
        }
      } else {
        newParams[key] = originalParams[key]
      }
      
      // Insert custom variables after isModerator
      if (key === 'isModerator' && !insertedCustomVars) {
        Object.keys(customVariables).forEach(customKey => {
          if (packetModifications[customKey] === undefined) {
            // Only add if not already in regular modifications
            if (typeof customVariables[customKey] === 'string') {
              if (customVariables[customKey] === 'true') {
                newParams[customKey] = true
              } else if (customVariables[customKey] === 'false') {
                newParams[customKey] = false
              } else {
                newParams[customKey] = customVariables[customKey]
              }
            } else {
              newParams[customKey] = customVariables[customKey]
            }
          }
        })
        insertedCustomVars = true
      }
    })
    
    // Replace the params object
    message.value.b.o.params = newParams
    
    console.log('[Packet Editor Backend] Login packet modified with user settings')
    console.log('[Packet Editor Backend] Custom variables inserted after isModerator:', Object.keys(customVariables))
  }

  /**
   * Hook the login packet.
   */
  dispatch.onMessage({
    type: 'aj',
    message: 'login',
    callback: handleLoginMessage
  })

  // Load settings when the plugin is initialized
  loadSettings()

  // Reload settings every 2 seconds to stay in sync with UI changes
  setInterval(reloadSettings, 2000)
}
