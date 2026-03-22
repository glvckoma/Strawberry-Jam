const path = require('path')
const os = require('os')
const fs = require('fs')

const platform = process.platform

const getStrawberryJamClassicBasePath = () => {
  if (platform === 'win32') {
    return path.join(os.homedir(), 'AppData', 'Local', 'Programs', 'strawberry-jam-classic')
  }
  if (platform === 'darwin') {
    return path.join('/', 'Applications', 'Strawberry Jam Classic.app', 'Contents')
  }
  return path.join(os.homedir(), '.local', 'share', 'strawberry-jam-classic')
}

const getAnimalJamClassicBasePath = () => {
  if (platform === 'win32') {
    return path.join(os.homedir(), 'AppData', 'Local', 'Programs', 'aj-classic')
  }
  if (platform === 'darwin') {
    return path.join('/', 'Applications', 'AJ Classic.app', 'Contents')
  }
  const possiblePaths = [
    path.join(os.homedir(), '.local', 'share', 'aj-classic'),
    path.join('/opt', 'aj-classic'),
    path.join('/usr', 'local', 'bin', 'aj-classic')
  ]
  return possiblePaths.find(p => fs.existsSync(p)) || possiblePaths[0]
}

const getAnimalJamClassicCachePath = () => {
  if (platform === 'win32') {
    return path.join(os.homedir(), 'AppData', 'Roaming', 'AJ Classic', 'Cache')
  }
  if (platform === 'darwin') {
    return path.join(os.homedir(), 'Library', 'Application Support', 'AJ Classic', 'Cache')
  }
  return path.join(os.homedir(), '.cache', 'aj-classic')
}

const getStrawberryJamClassicCachePath = () => {
  if (platform === 'win32') {
    return path.join(os.homedir(), 'AppData', 'Roaming', 'strawberry-jam-classic', 'Cache')
  }
  if (platform === 'darwin') {
    return path.join(os.homedir(), 'Library', 'Application Support', 'Strawberry Jam Classic', 'Cache')
  }
  return path.join(os.homedir(), '.cache', 'strawberry-jam-classic')
}

const getGameExecutablePath = (basePath) => {
  if (platform === 'win32') {
    return path.join(basePath, 'AJ Classic.exe')
  }
  if (platform === 'darwin') {
    return path.join(basePath, 'MacOS', 'AJ Classic')
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
  getClientOS
}
