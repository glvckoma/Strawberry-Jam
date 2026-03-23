const path = require('path')
const os = require('os')
const fs = require('fs')

const platform = process.platform

const DEFAULT_WINE_PREFIX = path.join(os.homedir(), '.wine')
const BOTTLES_BASE = path.join(os.homedir(), '.var', 'app', 'com.usebottles.bottles', 'data', 'bottles', 'bottles')
const FLATPAK_BOTTLES_BASE = path.join(os.homedir(), '.local', 'share', 'bottles', 'bottles')

const getWineAjClassicPath = (winePrefix) => {
  const driveC = path.join(winePrefix, 'drive_c')
  const possiblePaths = [
    path.join(driveC, 'users', os.userInfo().username, 'AppData', 'Local', 'Programs', 'aj-classic'),
    path.join(driveC, 'users', os.userInfo().username, 'Local Settings', 'Application Data', 'Programs', 'aj-classic'),
    path.join(driveC, 'Program Files', 'aj-classic'),
    path.join(driveC, 'Program Files (x86)', 'aj-classic')
  ]
  return possiblePaths.find(p => fs.existsSync(p)) || null
}

const getWineStrawberryJamPath = (winePrefix) => {
  const driveC = path.join(winePrefix, 'drive_c')
  const possiblePaths = [
    path.join(driveC, 'users', os.userInfo().username, 'AppData', 'Local', 'Programs', 'strawberry-jam-classic'),
    path.join(driveC, 'users', os.userInfo().username, 'Local Settings', 'Application Data', 'Programs', 'strawberry-jam-classic'),
    path.join(driveC, 'Program Files', 'strawberry-jam-classic')
  ]
  return possiblePaths.find(p => fs.existsSync(p)) || possiblePaths[0]
}

const detectWinePrefix = (customPrefix) => {
  if (customPrefix && fs.existsSync(path.join(customPrefix, 'drive_c'))) {
    return customPrefix
  }

  if (fs.existsSync(path.join(DEFAULT_WINE_PREFIX, 'drive_c'))) {
    return DEFAULT_WINE_PREFIX
  }

  for (const bottlesBase of [BOTTLES_BASE, FLATPAK_BOTTLES_BASE]) {
    if (fs.existsSync(bottlesBase)) {
      try {
        const bottles = fs.readdirSync(bottlesBase)
        for (const bottle of bottles) {
          const bottlePath = path.join(bottlesBase, bottle)
          if (fs.existsSync(path.join(bottlePath, 'drive_c'))) {
            const ajPath = getWineAjClassicPath(bottlePath)
            if (ajPath) return bottlePath
          }
        }
      } catch (e) {}
    }
  }

  return DEFAULT_WINE_PREFIX
}

const detectCompatibilityLayer = () => {
  const { execSync } = require('child_process')
  const layers = []

  try {
    execSync('which wine', { stdio: 'ignore' })
    layers.push('wine')
  } catch (e) {}

  try {
    execSync('which flatpak', { stdio: 'ignore' })
    try {
      const output = execSync('flatpak list --app', { encoding: 'utf8' })
      if (output.includes('com.usebottles.bottles')) {
        layers.push('bottles')
      }
    } catch (e) {}
  } catch (e) {}

  try {
    execSync('which bottles-cli', { stdio: 'ignore' })
    if (!layers.includes('bottles')) layers.push('bottles')
  } catch (e) {}

  return layers
}

const getStrawberryJamClassicBasePath = (compatLayer, winePrefix) => {
  if (platform === 'win32') {
    return path.join(os.homedir(), 'AppData', 'Local', 'Programs', 'strawberry-jam-classic')
  }
  if (platform === 'darwin') {
    return path.join('/', 'Applications', 'Strawberry Jam Classic.app', 'Contents')
  }

  if (compatLayer && compatLayer !== 'none') {
    const prefix = detectWinePrefix(winePrefix)
    return getWineStrawberryJamPath(prefix)
  }

  return path.join(os.homedir(), '.local', 'share', 'strawberry-jam-classic')
}

const getAnimalJamClassicBasePath = (compatLayer, winePrefix) => {
  if (platform === 'win32') {
    return path.join(os.homedir(), 'AppData', 'Local', 'Programs', 'aj-classic')
  }
  if (platform === 'darwin') {
    return path.join('/', 'Applications', 'AJ Classic.app', 'Contents')
  }

  if (compatLayer && compatLayer !== 'none') {
    const prefix = detectWinePrefix(winePrefix)
    const winePath = getWineAjClassicPath(prefix)
    if (winePath) return winePath
  }

  const possiblePaths = [
    path.join(os.homedir(), '.local', 'share', 'aj-classic'),
    path.join('/opt', 'aj-classic'),
    path.join('/usr', 'local', 'bin', 'aj-classic')
  ]
  return possiblePaths.find(p => fs.existsSync(p)) || possiblePaths[0]
}

const getAnimalJamClassicCachePath = (compatLayer, winePrefix) => {
  if (platform === 'win32') {
    return path.join(os.homedir(), 'AppData', 'Roaming', 'AJ Classic', 'Cache')
  }
  if (platform === 'darwin') {
    return path.join(os.homedir(), 'Library', 'Application Support', 'AJ Classic', 'Cache')
  }
  if (compatLayer && compatLayer !== 'none') {
    const prefix = detectWinePrefix(winePrefix)
    return path.join(prefix, 'drive_c', 'users', os.userInfo().username, 'AppData', 'Roaming', 'AJ Classic', 'Cache')
  }
  return path.join(os.homedir(), '.cache', 'aj-classic')
}

const getStrawberryJamClassicCachePath = (compatLayer, winePrefix) => {
  if (platform === 'win32') {
    return path.join(os.homedir(), 'AppData', 'Roaming', 'strawberry-jam-classic', 'Cache')
  }
  if (platform === 'darwin') {
    return path.join(os.homedir(), 'Library', 'Application Support', 'Strawberry Jam Classic', 'Cache')
  }
  if (compatLayer && compatLayer !== 'none') {
    const prefix = detectWinePrefix(winePrefix)
    return path.join(prefix, 'drive_c', 'users', os.userInfo().username, 'AppData', 'Roaming', 'strawberry-jam-classic', 'Cache')
  }
  return path.join(os.homedir(), '.cache', 'strawberry-jam-classic')
}

const getGameExecutablePath = (basePath, compatLayer) => {
  if (platform === 'win32') {
    return path.join(basePath, 'AJ Classic.exe')
  }
  if (platform === 'darwin') {
    return path.join(basePath, 'MacOS', 'AJ Classic')
  }
  if (compatLayer && compatLayer !== 'none') {
    return path.join(basePath, 'AJ Classic.exe')
  }
  return path.join(basePath, 'aj-classic')
}

const getBundledPluginsPath = (dirname) => {
  if (platform === 'win32') {
    return path.resolve('plugins/')
  }
  return path.join(dirname, '..', '..', '..', '..', '..', '..', '..', 'plugins/')
}

const getPluginManagerConfig = (dirname) => {
  if (platform === 'win32') return {}
  return { pluginsPath: path.join(dirname, '..', '..', '..', '..', '..', '..', '..', 'plugin_packages') }
}

const getBusyProcessErrorMessage = () => {
  if (platform === 'win32') {
    return 'AJ Classic is running in the background. Check Task Manager and end the "AJ Classic.exe" processes, then try again. You can also use the "end" command to close AJ Classic processes.'
  }
  if (platform === 'darwin') {
    return 'AJ Classic is running in the background. Open Activity Monitor and quit "AJ Classic", then try again. You can also use the "end" command to close AJ Classic processes.'
  }
  return 'AJ Classic is running in the background. Run "pkill -f aj-classic" or use your system monitor to end the process, then try again. You can also use the "end" command to close AJ Classic processes.'
}

const getPermissionErrorMessage = () => {
  if (platform === 'win32') {
    return 'It seems like you installed Strawberry Jam in C:\\Program Files instead of C:\\Users\\User\\AppData\\Local\\Programs\\. Rerun the setup and change the installation location.'
  }
  return 'Permission denied. Check that the application has write access to the installation directory.'
}

const getProcessNames = () => {
  if (platform === 'win32') return ['AJ Classic.exe']
  if (platform === 'darwin') return ['AJ Classic']
  return ['aj-classic', 'AJ Classic']
}

const getClientOS = () => {
  if (platform === 'darwin') return 'mac'
  if (platform === 'win32') return 'win'
  return 'linux'
}

module.exports = {
  platform,
  getStrawberryJamClassicBasePath,
  getAnimalJamClassicBasePath,
  getAnimalJamClassicCachePath,
  getStrawberryJamClassicCachePath,
  getGameExecutablePath,
  getBundledPluginsPath,
  getPluginManagerConfig,
  getBusyProcessErrorMessage,
  getPermissionErrorMessage,
  getProcessNames,
  getClientOS,
  detectWinePrefix,
  detectCompatibilityLayer
}
