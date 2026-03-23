const path = require('path')
const fs = require('fs')
const { rename, copyFile, rm, mkdir, cp } = fs.promises
const { existsSync } = fs
const { spawn } = require('child_process')
const { ipcRenderer } = require('electron')
const CacheCleaner = require('../../../../utils/CacheCleaner')
const PlatformPaths = require('../../../../PlatformPaths')

const isDevelopment = process.env.NODE_ENV === 'development';

const getLinuxCompat = async () => {
  if (PlatformPaths.platform !== 'linux') return { compat: null, prefix: '' }
  try {
    const compatSetting = await ipcRenderer.invoke('get-setting', 'linux.compatibilityLayer') || 'auto'
    const winePrefix = await ipcRenderer.invoke('get-setting', 'linux.winePrefix') || ''

    if (compatSetting === 'none') return { compat: null, prefix: winePrefix }
    if (compatSetting === 'wine' || compatSetting === 'bottles') return { compat: compatSetting, prefix: winePrefix }

    const detected = PlatformPaths.detectCompatibilityLayer()
    return { compat: detected[0] || null, prefix: winePrefix }
  } catch (e) {
    return { compat: null, prefix: '' }
  }
}

const getPaths = async () => {
  const { compat, prefix } = await getLinuxCompat()
  const ajBase = PlatformPaths.getAnimalJamClassicBasePath(compat, prefix)
  const ajCache = PlatformPaths.getAnimalJamClassicCachePath(compat, prefix)
  const sjBase = PlatformPaths.getStrawberryJamClassicBasePath(compat, prefix)
  const sjCache = PlatformPaths.getStrawberryJamClassicCachePath(compat, prefix)
  const asarPath = path.join(sjBase, 'resources', 'app.asar')
  const backupPath = `${asarPath}.unpatched`
  return { ajBase, ajCache, sjBase, sjCache, asarPath, backupPath, compat }
}


module.exports = class Patcher {
  constructor (application, assetsPath) {
    this._application = application
    this._animalJamProcess = null
    this.assetsPath = assetsPath
  }

  async killProcessAndPatch () {
    try {
      const paths = await getPaths()
      await this.ensureStrawberryJamVersionExists(paths)

      if (existsSync(paths.sjCache)) {
        try {
          const cacheCleaner = new CacheCleaner()
          const result = await cacheCleaner.clearSafeCacheFiles(paths.sjCache)

          if (result.failed.length > 0 || result.skipped.length > 0) {
            if (isDevelopment) {
              console.warn(`[Cache Cleanup] Some files could not be deleted: ${result.failed.length} failed, ${result.skipped.length} skipped (locked)`)
            }
          }
        } catch (cacheError) {
          if (isDevelopment) {
            console.warn(`[Cache Cleanup] Error during cache cleanup: ${cacheError.message}`)
          }
        }
      }

      if (!existsSync(paths.sjCache)) {
        await mkdir(paths.sjCache, { recursive: true })
      }

      await this.patchApplication(paths)

      ipcRenderer.send('launch-game-client');

    } catch (error) {
      const errorMsg = `Failed to start Animal Jam Classic: ${error.message}`
      if (this._application) {
        this._application.consoleMessage({
          message: errorMsg,
          type: 'error'
        })
      } else {
        console.error(errorMsg)
      }
    }
  }

  async ensureStrawberryJamVersionExists(paths) {
    try {
      if (!existsSync(paths.sjBase)) {
        const message = 'Creating Strawberry Jam Classic installation (this only happens once)...'
        if (this._application) {
          this._application.consoleMessage({ message, type: 'wait' })
        } else {
          console.log(message)
        }

        if (!existsSync(paths.ajBase)) {
          throw new Error('Animal Jam Classic installation not found. Please install the original game first.')
        }

        const parentDir = path.dirname(paths.sjBase)
        if (!existsSync(parentDir)) {
          await mkdir(parentDir, { recursive: true })
        }

        try {
          const copyMessage = 'Copying Animal Jam files to Strawberry Jam directory...'
          if (this._application) {
            this._application.consoleMessage({ message: copyMessage, type: 'wait' })
          } else {
            console.log(copyMessage)
          }

          await mkdir(paths.sjBase, { recursive: true })

          const { exec } = require('child_process')
          if (PlatformPaths.platform === 'win32') {
            await new Promise((resolve, reject) => {
              exec(`xcopy "${paths.ajBase}" "${paths.sjBase}" /E /I /H /Y`,
                (error) => error ? reject(error) : resolve())
            })
          } else {
            await new Promise((resolve, reject) => {
              exec(`cp -R "${paths.ajBase}/"* "${paths.sjBase}/"`,
                (error) => error ? reject(error) : resolve())
            })
          }

          const successMessage = 'Files copied successfully.'
          if (this._application) {
            this._application.consoleMessage({ message: successMessage, type: 'success' })
          } else {
            console.log(successMessage)
          }
        } catch (copyError) {
          throw new Error(`Failed to copy files: ${copyError.message}`)
        }

        await this.patchCustomInstallation(paths)

        const completedMessage = 'Strawberry Jam Classic installation created successfully!'
        if (this._application) {
          this._application.consoleMessage({ message: completedMessage, type: 'success' })
        } else {
          console.log(completedMessage)
        }
      }
    } catch (error) {
      const errorMsg = `Failed to create Strawberry Jam Classic: ${error.message}`
      if (this._application) {
        this._application.consoleMessage({ message: errorMsg, type: 'error' })
      } else {
        console.error(errorMsg)
      }
      throw error
    }
  }

  async patchCustomInstallation(paths) {
    const resourcesDir = path.join(paths.sjBase, 'resources')
    const asarPath = path.join(resourcesDir, 'app.asar')
    const asarUnpackedPath = path.join(resourcesDir, 'app.asar.unpacked')
    const customAsarPath = path.join(this.assetsPath, 'app-client.asar')

    try {
      process.noAsar = true

      if (!existsSync(resourcesDir)) {
        await mkdir(resourcesDir, { recursive: true })
      }

      if (!existsSync(customAsarPath)) {
        throw new Error(`Custom asar file not found at: ${customAsarPath}`)
      }

      let allowMultipleInstances = false;
      try {
        allowMultipleInstances = await ipcRenderer.invoke('get-setting', 'ui.allowMultipleInstances');
      } catch (e) {
        allowMultipleInstances = false;
      }

      const appDirPath = path.join(resourcesDir, 'app')
      if (existsSync(appDirPath)) {
        await rm(appDirPath, { recursive: true }).catch(() => {})
      }

      if (existsSync(asarPath)) {
        await rm(asarPath).catch(err => {
          if (err.code === 'EBUSY' && !allowMultipleInstances) {
            throw new Error(PlatformPaths.getBusyProcessErrorMessage())
          } else if (err.code === 'EPERM') {
            throw new Error(PlatformPaths.getPermissionErrorMessage())
          }
        })
      }
      if (existsSync(asarUnpackedPath)) {
        await rm(asarUnpackedPath, { recursive: true }).catch(err => {
          if (err.code === 'EBUSY' && !allowMultipleInstances) {
            throw new Error(PlatformPaths.getBusyProcessErrorMessage())
          } else if (err.code === 'EPERM') {
            throw new Error(PlatformPaths.getPermissionErrorMessage())
          }
        })
      }

      const copyMessage = `Copying asar from ${customAsarPath} to ${asarPath}...`
      if (this._application) {
        this._application.consoleMessage({ message: copyMessage, type: 'notify' })
      } else {
        console.log(copyMessage)
      }

      await copyFile(customAsarPath, asarPath)

      const exePath = PlatformPaths.getGameExecutablePath(paths.sjBase, paths.compat)
      if (!existsSync(exePath)) {
        throw new Error(`Executable not found at: ${exePath}`)
      }

      const successMessage = 'Application successfully patched.'
      if (this._application) {
        this._application.consoleMessage({ message: successMessage, type: 'success' })
      } else {
        console.log(successMessage)
      }
    } catch (error) {
      const errorMsg = `Failed to patch Strawberry Jam Classic: ${error.message}`
      if (this._application) {
        this._application.consoleMessage({ message: errorMsg, type: 'error' })
      } else {
        console.error(errorMsg)
      }
      throw error
    } finally {
      process.noAsar = false
    }
  }

  async patchApplication (paths) {
    if (!paths) paths = await getPaths()
    try {
      process.noAsar = true

      const customAsarPath = path.join(this.assetsPath, 'app-client.asar')
      const resourcesDir = path.join(paths.sjBase, 'resources')
      const asarPath = path.join(resourcesDir, 'app.asar')
      const asarUnpackedPath = `${asarPath}.unpacked`

      if (!existsSync(resourcesDir)) {
        await mkdir(resourcesDir, { recursive: true })
      }

      if (!existsSync(customAsarPath)) {
        throw new Error(`Custom ASAR file not found at: ${customAsarPath}`)
      }

      let allowMultipleInstances = false;
      try {
        allowMultipleInstances = await ipcRenderer.invoke('get-setting', 'ui.allowMultipleInstances');
      } catch (error) {
        allowMultipleInstances = false;
      }

      const appDirPath = path.join(resourcesDir, 'app')
      if (existsSync(appDirPath)) {
        await rm(appDirPath, { recursive: true }).catch(() => {})
      }

      if (existsSync(asarPath)) {
        await rm(asarPath).catch(err => {
          if (err.code === 'EBUSY' && !allowMultipleInstances) {
            throw new Error(PlatformPaths.getBusyProcessErrorMessage())
          } else if (err.code === 'EPERM') {
            throw new Error(PlatformPaths.getPermissionErrorMessage())
          } else if (err.code !== 'EBUSY') {
            throw new Error(`Error removing existing ASAR: ${err.message}`)
          }
        })
      }
      if (existsSync(asarUnpackedPath)) {
        await rm(asarUnpackedPath, { recursive: true }).catch(err => {
          if (err.code === 'EBUSY' && !allowMultipleInstances) {
            throw new Error(PlatformPaths.getBusyProcessErrorMessage())
          } else if (err.code === 'EPERM') {
            throw new Error(PlatformPaths.getPermissionErrorMessage())
          } else if (err.code !== 'EBUSY') {
            throw new Error(`Error removing existing ASAR.unpacked: ${err.message}`)
          }
        })
      }

      await copyFile(customAsarPath, asarPath)

    } catch (error) {
      if (isDevelopment) {
        const errorMsg = `Failed to prepare Animal Jam Classic: ${error.message}`
        if (this._application) {
          this._application.consoleMessage({
            message: errorMsg,
            type: 'error'
          })
        } else {
          console.error(errorMsg)
        }
      }
      throw error
    } finally {
      process.noAsar = false
    }
  }

}
