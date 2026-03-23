module.exports = function ({ dispatch, application, dataPath }) {
  const path = require('path');
  const fs = require('fs');
  const settingsFile = path.join(dataPath, 'denlog-settings.json');

  const loadSettings = () => {
    try {
      if (fs.existsSync(settingsFile)) {
        return JSON.parse(fs.readFileSync(settingsFile, 'utf8'));
      }
    } catch (e) {}
    return { enabled: false };
  };

  const saveSettings = () => {
    try {
      fs.mkdirSync(path.dirname(settingsFile), { recursive: true });
      fs.writeFileSync(settingsFile, JSON.stringify({ enabled: isEnabled }));
    } catch (e) {}
  };

  const settings = loadSettings();
  let isEnabled = settings.enabled;
  const userStates = new Map();

  const log = (type, msg) => application.consoleMessage({ type, message: msg });

  const handleDrcPacket = ({ message, type }) => {
    if (!isEnabled) return;
    if (type !== dispatch.ConnectionMessageTypes.aj) return;
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
      saveSettings();
      log(isEnabled ? 'success' : 'warn',
          `Den logging ${isEnabled ? 'enabled' : 'disabled'}.`);
    }
  });

  dispatch.onMessage({
    type: dispatch.ConnectionMessageTypes.any,
    callback: handleDrcPacket
  });

  if (isEnabled) {
    log('success', 'Den logging restored from previous session.');
  }
};
