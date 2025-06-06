module.exports = function ({ dispatch, application }) {
  /**
   * Color interval.
   */
  let interval = null

  /**
   * Handles glow command.
   */
  const handleGlowCommnd = async () => {
    const textualRoomId = await dispatch.getState('room');
    const internalRoomIdValue = await dispatch.getState('internalRoomId');
    let parsedInternalRoomId = null;

    if (internalRoomIdValue !== null && internalRoomIdValue !== undefined) {
        parsedInternalRoomId = parseInt(internalRoomIdValue, 10);
        if (isNaN(parsedInternalRoomId)) {
            console.warn(`[Glow Plugin] internalRoomId '${internalRoomIdValue}' could not be parsed to a number.`);
            parsedInternalRoomId = null;
        }
    }

    let roomIdToUse = null;
    // For pubMsg, the numerical ID is preferred.
    if (parsedInternalRoomId !== null) {
        roomIdToUse = parsedInternalRoomId;
        if (window.IS_DEV) {
            console.log(`[Glow Plugin] Using parsed internalRoomId: ${parsedInternalRoomId}`);
        }
    } else if (textualRoomId) {
        roomIdToUse = textualRoomId; // Fallback, though pubMsg might not work correctly with textual ID
        console.warn(`[Glow Plugin] Parsed internalRoomId not available (original value: ${internalRoomIdValue}). Falling back to textualRoomId: ${textualRoomId}. Glow might not work as expected.`);
    }

    if (!roomIdToUse) {
      if (typeof application !== 'undefined' && application.consoleMessage) {
        application.consoleMessage({
          message: 'Glow: You must be in a room to use this plugin (room ID not found).',
          type: 'error'
        });
      } else {
        console.error('[Glow Plugin] You must be in a room to use this plugin (room ID not found). `application` object not available for console message.');
      }
      return;
    }

    if (interval) return clear()

    interval = dispatch.setInterval(() => glow(roomIdToUse), 600)
    dispatch.serverMessage('Only other players will be able to see your glow.')
  }

  /**
   * Sends the glow packet to the server.
   */
  const glow = (room) => {
    const color = dispatch.random(1019311667, 4348810240)
    dispatch.sendRemoteMessage(`<msg t="sys"><body action="pubMsg" r="${room}"><txt><![CDATA[${color}%8]]></txt></body></msg>`)
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
    name: 'glow',
    description: 'Changes your avatar color glow randomly.',
    callback: handleGlowCommnd
  })
}
