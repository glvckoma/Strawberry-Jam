module.exports = function ({ dispatch, application }) {
  /**
   * Color interval.
   */
  let interval = null

  /**
   * Handles adventure command.
   */
  const handleAdventureCommnd = async () => {
    const textualRoomId = await dispatch.getState('room');
    const internalRoomIdValue = await dispatch.getState('internalRoomId');
    let parsedInternalRoomId = null;

    if (internalRoomIdValue !== null && internalRoomIdValue !== undefined) {
        parsedInternalRoomId = parseInt(internalRoomIdValue, 10);
        if (isNaN(parsedInternalRoomId)) {
            console.warn(`[Adventure Plugin] internalRoomId '${internalRoomIdValue}' could not be parsed to a number.`);
            parsedInternalRoomId = null;
        }
    }

    let roomIdToUse = null;
    if (parsedInternalRoomId !== null) {
        roomIdToUse = parsedInternalRoomId;
        if (window.IS_DEV) {
            console.log(`[Adventure Plugin] Using parsed internalRoomId: ${parsedInternalRoomId}`);
        }
    } else if (textualRoomId) {
        roomIdToUse = textualRoomId;
        console.warn(`[Adventure Plugin] Parsed internalRoomId not available (original value: ${internalRoomIdValue}). Falling back to textualRoomId: ${textualRoomId}. Adventure packets might not work as expected.`);
    }

    if (!roomIdToUse) {
      if (typeof application !== 'undefined' && application.consoleMessage) {
        application.consoleMessage({
          message: 'Adventure: You must be in a room to use this plugin (room ID not found).',
          type: 'error'
        });
      } else {
        console.error('[Adventure Plugin] You must be in a room to use this plugin (room ID not found). `application` object not available for console message.');
      }
      return;
    }

    if (interval) return clear()
    // Pass the determined roomIdToUse to the adventure function
    interval = dispatch.setInterval(() => adventure(roomIdToUse), 600)
  }

  /**
   * Sends the treasure packet to the server.
   */
  const adventure = async (room) => {
    await dispatch.sendRemoteMessage(`%xt%o%qat%${room}%treasure_1%0%`)
    dispatch.sendRemoteMessage(`%xt%o%qatt%${room}%treasure_1%1%`)
  }

  /**
   * Clears an interval.
   */
  const clear = () => {
    dispatch.clearInterval(interval)
    interval = null
  }

  /**
   * Chat message hook.
   */
  dispatch.onCommand({
    name: 'adventure',
    description: 'Loads chests and gives experience.',
    callback: handleAdventureCommnd
  })
}
