const { ConnectionMessageTypes } = require('../../src/Constants');

module.exports = function ({ dispatch, application }) {
  let isEnabled = false;
  const userStates = new Map();

  const log = (type, msg) => application.consoleMessage({ type, message: msg });

  const handleDrcPacket = ({ message, type }) => {
    if (!isEnabled) return;
    if (type !== ConnectionMessageTypes.aj) return;
    if (!message || message.type !== 'drc') return;

    const parts = message.value;
    if (!parts || parts.length < 7) return;

    const username = parts[6];
    if (!username) return;

    const isCurrentlyIn = userStates.get(username) || false;
    userStates.set(username, !isCurrentlyIn);

    if (isCurrentlyIn) {
      application.consoleMessage({
        type: 'notify',
        message: `${username} has just left your den!`,
        style: 'color: #ef4444;'
      });
    } else {
      application.consoleMessage({
        type: 'notify',
        message: `${username} has just entered your den!`,
        style: 'color: #22c55e;'
      });
    }
  };

  dispatch.onCommand({
    name: 'denlog',
    description: 'Toggle den entry logging on/off',
    callback: () => {
      isEnabled = !isEnabled;
      if (!isEnabled) {
        userStates.clear();
      }
      log(isEnabled ? 'success' : 'warn',
          `Den logging ${isEnabled ? 'enabled' : 'disabled'}.`);
    }
  });

  dispatch.onMessage({
    type: ConnectionMessageTypes.any,
    callback: handleDrcPacket
  });
};
