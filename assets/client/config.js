"use strict";

const os = require('os');

const flashPluginNames = {
  win32: 'pepflashplayer.dll',
  darwin: 'PepperFlashPlayer.plugin',
  linux: 'libpepflashplayer.so'
};

module.exports = {
  gameWebClient: "https://desktop.animaljam.com/gameClient/game/index.html",
  api: "https://ajelectronapi.animaljam.com",
  authenticator: "https://authenticator.animaljam.com",
  playerSessionData: "https://player-session-data.animaljam.com",
  update: "https://classic-download.animaljam.com/win",
  webApi: "https://api.animaljam.com",
  web: "https://www.animaljam.com",
  webClassic: "https://classic.animaljam.com",
  noUpdater: false,
  showTools: false,
  clearCache: false,
  clearStorage: false,
  pluginPath: "../../",
  pluginName: flashPluginNames[os.platform()] || flashPluginNames.win32,
  serverPort: 8088,
  origin: "https://www.animaljam.com",
};
