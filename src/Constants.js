const path = require('path') // Keep path require

/**
 * Connection message types.
 * @enum
 */
const ConnectionMessageTypes = Object.freeze({
  connection: 'connection',
  aj: 'aj',
  any: '*'
})

/**
 * Returns the appropriate data directory path based on the environment.
 * In development, returns the 'data' folder in the project root.
 * In production (packaged), returns '%LOCALAPPDATA%\\Programs\\aj-classic\\data'.
 * @param {import('electron').App} app - The Electron app object.
 * @returns {string} The data directory path.
 */
const getDataPath = (app) => { // Accept app as parameter
  if (!app) {
    console.error("[Constants] getDataPath called without app object!");
    // Fallback or throw error? Fallback might hide issues. Let's throw.
    throw new Error("getDataPath requires the Electron app object as an argument.");
  }
  if (app.isPackaged) {
    // Use the standard user data directory provided by Electron,
    // appending a '/data' subfolder for organization.
    // Example: C:\\Users\\Username\\AppData\\Roaming\\strawberry-jam\\data
    return path.join(app.getPath('userData'), 'data'); // Append '/data'
  } else {
    // Path for development environment (project root/data)
    return path.join(app.getAppPath(), 'data')
  }
}

/**
 * Returns the appropriate assets directory path based on the environment.
 * @param {import('electron').App} app - The Electron app object.
 * @returns {string} The assets directory path.
 */
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

/**
 * Returns the Username Logger directory path.
 * In production, returns '%LOCALAPPDATA%\strawberry-jam\UsernameLogger'.
 * In development, returns the 'UsernameLogger' folder in the project root.
 * @param {import('electron').App} app - The Electron app object.
 * @returns {string} The Username Logger directory path.
 */
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

/**
 * Returns the user plugins directory path.
 * In production, returns '%LOCALAPPDATA%\strawberry-jam\plugins'.
 * In development, returns the 'plugins' folder in the project root.
 * @param {import('electron').App} app - The Electron app object.
 * @returns {string} The user plugins directory path.
 */
const getPluginsPath = (app) => {
  if (!app) {
    throw new Error("getPluginsPath requires the Electron app object as an argument.");
  }
  if (app.isPackaged) {
    return path.join(app.getPath('userData'), 'plugins');
  } else {
    return path.join(app.getAppPath(), 'plugins');
  }
};

/**
 * Plugin types.
 * @enum
 */
const PluginTypes = Object.freeze({
  ui: 'ui',
  game: 'game'
})

module.exports = { ConnectionMessageTypes, PluginTypes, getDataPath, getAssetsPath, getUsernameLoggerPath, getPluginsPath }
