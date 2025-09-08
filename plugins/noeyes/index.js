module.exports = function ({ dispatch, application }) {
  /**
   * Handles the noeyes command.
   * Sends a packet to remove eyes from the avatar.
   * @param {Object} param The parameter object.
   * @param {Array} param.parameters Command parameters (unused).
   * @returns
   */
  const handleNoEyesCommand = async ({ parameters }) => {
    // Get current room information
    const textualRoomId = await dispatch.getState('room');
    const internalRoomIdValue = await dispatch.getState('internalRoomId');
    
    if (!textualRoomId) {
      return application.consoleMessage({
        message: 'No Eyes: You must be in a room to use this plugin.',
        type: 'error'
      });
    }

    let roomIdToUse = null;
    if (internalRoomIdValue !== null && internalRoomIdValue !== undefined) {
      const parsedInternalRoomId = parseInt(internalRoomIdValue, 10);
      if (!isNaN(parsedInternalRoomId)) {
        roomIdToUse = parsedInternalRoomId;
      }
    }
    
    if (!roomIdToUse && textualRoomId) {
      roomIdToUse = textualRoomId;
    }

    if (!roomIdToUse) {
      return application.consoleMessage({
        message: 'No Eyes: Could not determine room ID.',
        type: 'error'
      });
    }

    // Send the no eyes packet
    dispatch.sendRemoteMessage(`%xt%o%iu%${roomIdToUse}%1%1%-315%-314%`);
    
    application.consoleMessage({
      message: 'No Eyes: Eyes removed! Re-join the room to see the changes.',
      type: 'info'
    });
  };

  /**
   * Handles noeyes command.
   */
  dispatch.onCommand({
    name: 'noeyes',
    description: 'Remove eyes from your avatar',
    callback: handleNoEyesCommand
  });
};
