const path = require('path')

const ConnectionMessageTypes = Object.freeze({
  connection: 'connection',
  aj: 'aj',
  any: '*'
})

const getDataPath = (app) => {
  if (!app) {
    throw new Error("getDataPath requires the Electron app object as an argument.");
  }
  if (app.isPackaged) {
    return path.join(app.getPath('userData'), 'data');
  } else {
    return path.join(app.getAppPath(), 'data')
  }
}

const getAssetsPath = (app) => {
  if (!app) {
    throw new Error("getAssetsPath requires the Electron app object as an argument.");
  }
  if (app.isPackaged) {
    return path.join(process.resourcesPath, 'assets');
  } else {
    return path.join(app.getAppPath(), 'assets');
  }
};

const getUsernameLoggerPath = (app) => {
  if (!app) {
    throw new Error("getUsernameLoggerPath requires the Electron app object as an argument.");
  }
  if (app.isPackaged) {
    return path.join(app.getPath('userData'), 'UsernameLogger');
  } else {
    return path.join(app.getAppPath(), 'UsernameLogger');
  }
};

const PluginTypes = Object.freeze({
  ui: 'ui',
  game: 'game'
})

const TCP_SERVER_PORTS = Object.freeze([443, 8443, 9443])
const API_SERVER_PORTS = Object.freeze([7681, 7682, 7683, 7684])

module.exports = { ConnectionMessageTypes, PluginTypes, getDataPath, getAssetsPath, getUsernameLoggerPath, TCP_SERVER_PORTS, API_SERVER_PORTS }
