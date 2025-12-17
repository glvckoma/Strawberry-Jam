const { ipcRenderer } = require('electron')

module.exports = function ({ dispatch, application }) {
  let active = true
  let membershipLevel = 2
  const SETTINGS_FILE = 'membership-settings.json'
  const isDevelopment = process.env.NODE_ENV === 'development'

  /**
   * Load settings from the settings file.
   */
  const loadSettings = async () => {
    const settings = await ipcRenderer.invoke('read-json-file', SETTINGS_FILE, {
      active: true,
      membershipLevel: 2
    })
    active = settings.active
    membershipLevel = settings.membershipLevel
  }

  /**
   * Save settings to the settings file.
   */
  const saveSettings = async () => {
    await ipcRenderer.invoke('write-json-file', SETTINGS_FILE, {
      active,
      membershipLevel
    })
  }

  /**
   * Handles the membership command to toggle fake membership.
   */
  const handleMembershipCommand = async ({ parameters }) => {
    const level = parameters[0]
    if (level && !isNaN(parseInt(level, 10))) {
      membershipLevel = parseInt(level, 10)
      active = true
      dispatch.serverMessage(`Fake membership level set to ${membershipLevel}. This will take effect on your next login.`)
      console.log(`[Membership] Fake membership level set to ${membershipLevel}. Re-login to see changes.`)
    } else {
      active = !active
      if (active) {
        dispatch.serverMessage('Fake membership enabled! This will take effect on your next login.')
        console.log('[Membership] Fake membership ON. Re-login to see changes.')
      } else {
        dispatch.serverMessage('Fake membership disabled. This will take effect on your next login.')
        console.log('[Membership] Fake membership OFF. Re-login to see changes.')
      }
    }
    await saveSettings()
  }

  /**
   * Handles the login message.
   */
  const handleLoginMessage = ({ message }) => {
    if (!active) return

    const { params } = message.value.b.o
    const originalAccountType = params.accountType
    
    if (originalAccountType !== undefined && originalAccountType >= 2) {
      if (isDevelopment) {
        console.log(`[Membership] Account already has membership (accountType: ${originalAccountType}), skipping modification`)
      }
      return
    }
    
    if (isDevelopment) {
      console.log(`[Membership] Modifying accountType from ${originalAccountType} to ${membershipLevel}`)
    }
    params.accountType = membershipLevel
  }

  /**
   * Hooks the login packet.
   */
  dispatch.onMessage({
    type: 'aj',
    message: 'login',
    callback: handleLoginMessage
  })

  /**
   * Register the membership toggle command.
   */
  dispatch.onCommand({
    name: 'membership',
    description: 'Toggle fake membership or set a specific level (e.g., membership 3).',
    callback: handleMembershipCommand,
    parameters: [
      {
        name: 'level',
        description: 'The membership level to set.',
        required: false
      }
    ]
  })

  // Load settings when the plugin is initialized
  loadSettings()
}
