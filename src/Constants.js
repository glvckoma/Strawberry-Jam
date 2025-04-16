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
 * In production (packaged), returns '%LOCALAPPDATA%\Programs\aj-classic\data'.
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
    // Path for packaged app (e.g., C:\Users\Username\AppData\Local\Programs\aj-classic\data)
    // Note: app.getPath('appData') gives Roaming, app.getPath('userData') gives Roaming\strawberry-jam
    // We need Local AppData, so construct it manually.
    const localAppData = process.env.LOCALAPPDATA || path.join(app.getPath('home'), 'AppData', 'Local')
    return path.join(localAppData, 'Programs', 'aj-classic', 'data')
  } else {
    // Path for development environment (project root/data)
    return path.join(app.getAppPath(), 'data')
  }
}

/**
 * Plugin types.
 * @enum
 */
const PluginTypes = Object.freeze({
  ui: 'ui',
  game: 'game'
})

module.exports = { ConnectionMessageTypes, PluginTypes, getDataPath }
