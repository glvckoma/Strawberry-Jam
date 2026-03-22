const path = require('path')
const fs = require('fs')
const { rename, copyFile, rm, mkdir, cp } = fs.promises
const { existsSync } = fs
const { spawn } = require('child_process')
const { ipcRenderer } = require('electron')
const CacheCleaner = require('../../../../utils/CacheCleaner')
const PlatformPaths = require('../../../../PlatformPaths')

const isDevelopment = process.env.NODE_ENV === 'development';

const ANIMAL_JAM_CLASSIC_BASE_PATH = PlatformPaths.getAnimalJamClassicBasePath()
const ANIMAL_JAM_CLASSIC_CACHE_PATH = PlatformPaths.getAnimalJamClassicCachePath()
const STRAWBERRY_JAM_CLASSIC_BASE_PATH = PlatformPaths.getStrawberryJamClassicBasePath()
const STRAWBERRY_JAM_CLASSIC_CACHE_PATH = PlatformPaths.getStrawberryJamClassicCachePath()

const APP_ASAR_PATH = path.join(STRAWBERRY_JAM_CLASSIC_BASE_PATH, 'resources', 'app.asar')
const BACKUP_ASAR_PATH = `${APP_ASAR_PATH}.unpatched`


module.exports = class Patcher {
  /**
   * Creates an instance of the Patcher class.
   * @param {Settings} application - The application that instantiated this patcher.
   */
  constructor (application, assetsPath) {
    this._application = application
    this._animalJamProcess = null
    this.assetsPath = assetsPath
  }

  /**
   * Starts Animal Jam Classic process after patching it, if necessary.
   * @returns {Promise<void>}
   */
  async killProcessAndPatch () {
    try {
      await this.ensureStrawberryJamVersionExists()
      
      if (existsSync(STRAWBERRY_JAM_CLASSIC_CACHE_PATH)) {
        try {
          const cacheCleaner = new CacheCleaner()
          const result = await cacheCleaner.clearSafeCacheFiles(STRAWBERRY_JAM_CLASSIC_CACHE_PATH)
          
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
      
      if (!existsSync(STRAWBERRY_JAM_CLASSIC_CACHE_PATH)) {
        await mkdir(STRAWBERRY_JAM_CLASSIC_CACHE_PATH, { recursive: true })
      }
      
      await this.patchApplication()

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

  /**
   * Ensures that the Strawberry Jam version of Animal Jam exists.
   * Creates a copy of the original installation if it doesn't exist.
   * @returns {Promise<void>}
   */
  async ensureStrawberryJamVersionExists() {
    try {
      // Check if the Strawberry Jam installation already exists
      if (!existsSync(STRAWBERRY_JAM_CLASSIC_BASE_PATH)) {
        const message = 'Creating Strawberry Jam Classic installation (this only happens once)...'
        if (this._application) {
          this._application.consoleMessage({
            message,
            type: 'wait'
          })
        } else {
          console.log(message)
        }

        // Verify the original AJC installation exists
        if (!existsSync(ANIMAL_JAM_CLASSIC_BASE_PATH)) {
          throw new Error('Animal Jam Classic installation not found. Please install the original game first.')
        }

        // Create parent directory if needed
        const parentDir = path.dirname(STRAWBERRY_JAM_CLASSIC_BASE_PATH)
        if (!existsSync(parentDir)) {
          await mkdir(parentDir, { recursive: true })
        }

        try {
          const copyMessage = 'Copying Animal Jam files to Strawberry Jam directory...'
          if (this._application) {
            this._application.consoleMessage({
              message: copyMessage,
              type: 'wait'
            })
          } else {
            console.log(copyMessage)
          }

          // Create the target directory
          await mkdir(STRAWBERRY_JAM_CLASSIC_BASE_PATH, { recursive: true })

          const { exec } = require('child_process')
          if (PlatformPaths.platform === 'win32') {
            await new Promise((resolve, reject) => {
              exec(`xcopy "${ANIMAL_JAM_CLASSIC_BASE_PATH}" "${STRAWBERRY_JAM_CLASSIC_BASE_PATH}" /E /I /H /Y`,
                (error) => error ? reject(error) : resolve())
            })
          } else {
            await new Promise((resolve, reject) => {
              exec(`cp -R "${ANIMAL_JAM_CLASSIC_BASE_PATH}/"* "${STRAWBERRY_JAM_CLASSIC_BASE_PATH}/"`,
                (error) => error ? reject(error) : resolve())
            })
          }

          const successMessage = 'Files copied successfully.'
          if (this._application) {
            this._application.consoleMessage({
              message: successMessage,
              type: 'success'
            })
          } else {
            console.log(successMessage)
          }
        } catch (copyError) {
          throw new Error(`Failed to copy files: ${copyError.message}`)
        }

        // Patch the custom installation
        await this.patchCustomInstallation()

        const completedMessage = 'Strawberry Jam Classic installation created successfully!'
        if (this._application) {
          this._application.consoleMessage({
            message: completedMessage,
            type: 'success'
          })
        } else {
          console.log(completedMessage)
        }
      }
    } catch (error) {
      const errorMsg = `Failed to create Strawberry Jam Classic: ${error.message}`
      if (this._application) {
        this._application.consoleMessage({
          message: errorMsg,
          type: 'error'
        })
      } else {
        console.error(errorMsg)
      }
      throw error
    }
  }

  /**
   * Patches the custom Strawberry Jam installation with the modified asar.
   * @returns {Promise<void>}
   */
  async patchCustomInstallation() {
    const resourcesDir = path.join(STRAWBERRY_JAM_CLASSIC_BASE_PATH, 'resources')
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
        this._application.consoleMessage({
          message: copyMessage,
          type: 'notify'
        })
      } else {
        console.log(copyMessage)
      }

      await copyFile(customAsarPath, asarPath)

      const exePath = PlatformPaths.getGameExecutablePath(STRAWBERRY_JAM_CLASSIC_BASE_PATH)

      if (!existsSync(exePath)) {
        throw new Error(`Executable not found at: ${exePath}`)
      }

      const successMessage = 'Application successfully patched.'
      if (this._application) {
        this._application.consoleMessage({
          message: successMessage,
          type: 'success'
        })
      } else {
        console.log(successMessage)
      }
    } catch (error) {
      const errorMsg = `Failed to patch Strawberry Jam Classic: ${error.message}`
      if (this._application) {
        this._application.consoleMessage({
          message: errorMsg,
          type: 'error'
        })
      } else {
        console.error(errorMsg)
      }
      throw error
    } finally {
      process.noAsar = false
    }
  }

  /**
   * Patches Animal Jam Classic with custom application files.
   * @returns {Promise<void>}
   */
  async patchApplication () {
    try {
      process.noAsar = true

      const customAsarPath = path.join(this.assetsPath, 'app-client.asar')
      const resourcesDir = path.join(STRAWBERRY_JAM_CLASSIC_BASE_PATH, 'resources')
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

      // We no longer log success messages for patching here to keep the UI clean

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

  // The restoreOriginalAsar method has been removed as it's no longer needed with the standalone installation approach
}
