module.exports = function ({ dispatch, application }) {
  let active = true // Default to ON
  let membershipLevel = 2 // Default membership level

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
  }

  /**
   * Handles the login message.
   */
  const handleLoginMessage = ({ message }) => {
    if (!active) return // Only modify login when plugin is active

    const { params } = message.value.b.o
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
}
