module.exports = function ({ application, dispatch }) {
  const XtMessage = dispatch.XtMessage;
  /**
   * Handles the login message.
   */
  const handleLoginMessage = ({ message }) => {
    const { params } = message.value.b.o

    dispatch.setState('player', params)

    application.consoleMessage({
      message: 'Successfully logged in!',
      type: 'action'
    });

    // Automatically request buddy list after successful login
    try {
      const request = new XtMessage('bl');
      // Send the string representation of the message
      dispatch.sendRemoteMessage({ type: 'aj', message: request.toMessage() });
      // Use console.log instead of application.consoleMessage here
      console.log('[Login Plugin] Sent buddy list request (bl).');
    } catch (error) {
      // Use console.error instead of application.consoleMessage here
      console.error(`[Login Plugin] Error sending buddy list request: ${error.message}`);
      console.error("[Login Plugin] Error sending buddy list request:", error); // Log full error for debugging
    }
  }

  /**
   * Hooks the login packet.
   */
  dispatch.onMessage({
    type: 'aj',
    message: 'login',
    callback: handleLoginMessage
  })
}
