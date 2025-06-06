module.exports = function ({ dispatch, application }) {
  let size = 13
  let active = false

  /**
   * Handles the humongous command.
   * @returns
   */
  const handleHumongousCommand = async ({ parameters }) => {
    console.log(`[Humongous Plugin] handleHumongousCommand: Called. Current active state: ${active}`);
    active = !active;
    console.log(`[Humongous Plugin] handleHumongousCommand: Toggled active state to: ${active}`);

    // Check room presence when command is toggled
    const textualRoomId = await dispatch.getState('room');
    console.log(`[Humongous Plugin] handleHumongousCommand: textualRoomId from getState: ${textualRoomId}`);
    if (!textualRoomId) { // For the initial check, textualRoomId is sufficient to know if in a room
      console.log('[Humongous Plugin] handleHumongousCommand: Not in a room, setting active to false.');
      active = false; // Ensure plugin is not active if not in a room
      return application.consoleMessage({
        message: 'Humongous: You must be in a room to use this plugin.',
        type: 'error'
      });
    }

    if (active) {
      dispatch.serverMessage('You are now humongous! Re-join the room so other players can see you as a giant.')
    }

    size = parseInt(parameters[0]) || 13;
    console.log(`[Humongous Plugin] handleHumongousCommand: Parameters: ${parameters[0]}, Size set to: ${size}`);
  }

  /**
   * Handles movement updates.
   * @param {Object} param The parameter object.
   * @param {Object} param.message The message object.
   * @returns
   */
  const handleMovementUpdate = async ({ message }) => {
    if (window.IS_DEV) {
      console.log(`[Humongous Plugin] handleMovementUpdate: Called. Current active state: ${active}`);
    }
    if (!active) return

    const textualRoomId = await dispatch.getState('room');
    const internalRoomIdValue = await dispatch.getState('internalRoomId');
    let parsedInternalRoomId = null;

    if (internalRoomIdValue !== null && internalRoomIdValue !== undefined) {
        parsedInternalRoomId = parseInt(internalRoomIdValue, 10);
        if (isNaN(parsedInternalRoomId)) {
            console.warn(`[Humongous Plugin] internalRoomId '${internalRoomIdValue}' could not be parsed to a number.`);
            parsedInternalRoomId = null;
        }
    }

    let roomIdToUse = null;
    if (parsedInternalRoomId !== null) {
        roomIdToUse = parsedInternalRoomId;
    } else if (textualRoomId) {
        roomIdToUse = textualRoomId;
        console.warn(`[Humongous Plugin] Parsed internalRoomId not available (original value: ${internalRoomIdValue}). Falling back to textualRoomId: ${textualRoomId}. 'au' packet might use incorrect room ID type.`);
    }

    if (!roomIdToUse) {
      // Don't send if no room ID is found, though 'active' should ideally prevent this if initial check worked.
      console.error('[Humongous Plugin] Movement update: No room ID available.');
      return;
    }

    const x = message.value[6]
    const y = message.value[7]

    message.send = false // Prevent original movement packet
    dispatch.sendRemoteMessage(`%xt%o%au%${roomIdToUse}%1%${x}%${y}%${size}%1%`)
  }

  /**
   * Handles movement updates.
   */
  dispatch.onMessage({
    type: 'connection',
    message: 'au',
    callback: handleMovementUpdate
  })

  /**
   * Handles humongous command.
   */
  dispatch.onCommand({
    name: 'humongous',
    description: 'Look down on all the other animals with this humongous size hack!',
    callback: handleHumongousCommand
  })
}
