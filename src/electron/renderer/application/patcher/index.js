const path = require('path')
const os = require('os')
const { rename, copyFile, rm, mkdir, cp } = require('fs/promises') // Keep only one declaration
const { existsSync } = require('fs') // Keep only one declaration
const { spawn } = require('child_process')
const { ipcRenderer } = require('electron')
// Removed treeKill as it's not used in the restore logic directly
const { promisify } = require('util')
// Removed execFileAsync as we'll use spawn and handle exit differently

// Define isDevelopment for environment checks
const isDevelopment = process.env.NODE_ENV === 'development';

/**
 * Original Animal Jam Classic base path.
 * @constant
 */
const ANIMAL_JAM_CLASSIC_BASE_PATH = process.platform === 'win32'
  ? path.join(os.homedir(), 'AppData', 'Local', 'Programs', 'aj-classic')
  : process.platform === 'darwin'
    ? path.join('/', 'Applications', 'AJ Classic.app', 'Contents')
    : undefined

/**
 * Original Animal Jam cache path.
 * @constant
 */
const ANIMAL_JAM_CLASSIC_CACHE_PATH = process.platform === 'win32'
  ? path.join(os.homedir(), 'AppData', 'Roaming', 'AJ Classic', 'Cache')
  : process.platform === 'darwin'
    ? path.join(os.homedir(), 'Library', 'Application Support', 'AJ Classic', 'Cache')
    : undefined

/**
 * Strawberry Jam Classic base path (for the copied installation).
 * @constant
 */
const STRAWBERRY_JAM_CLASSIC_BASE_PATH = process.platform === 'win32'
  ? path.join(os.homedir(), 'AppData', 'Local', 'Programs', 'strawberry-jam-classic')
  : process.platform === 'darwin'
    ? path.join('/', 'Applications', 'Strawberry Jam Classic.app', 'Contents')
    : undefined

/**
 * Strawberry Jam Classic cache path (for the copied installation).
 * @constant
 */
const STRAWBERRY_JAM_CLASSIC_CACHE_PATH = process.platform === 'win32'
  ? path.join(os.homedir(), 'AppData', 'Roaming', 'Strawberry Jam Classic', 'Cache')
  : process.platform === 'darwin'
    ? path.join(os.homedir(), 'Library', 'Application Support', 'Strawberry Jam Classic', 'Cache')
    : undefined

/**
 * Path to the app.asar file in the copied installation.
 * @constant
 */
const APP_ASAR_PATH = path.join(STRAWBERRY_JAM_CLASSIC_BASE_PATH, 'resources', 'app.asar')

/**
 * Path to the backup of the original app.asar file (deprecated, kept for reference).
 * @constant
 */
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
      // Ensure the Strawberry Jam version exists before patching
      await this.ensureStrawberryJamVersionExists()
      
      // Clear the cache for the standalone installation
      if (existsSync(STRAWBERRY_JAM_CLASSIC_CACHE_PATH)) {
        await rm(STRAWBERRY_JAM_CLASSIC_CACHE_PATH, { recursive: true })
        await mkdir(STRAWBERRY_JAM_CLASSIC_CACHE_PATH, { recursive: true })
      }
      
      // Patch the application (no need to mention ASAR patching)
      await this.patchApplication()

      // Request the main process to launch the game client
      ipcRenderer.send('launch-game-client');

      // No need for restoration on quit since we're using a separate installation
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

          // Use platform-specific copy commands for better performance
          if (process.platform === 'win32') {
            const { exec } = require('child_process')
            await new Promise((resolve, reject) => {
              exec(`xcopy "${ANIMAL_JAM_CLASSIC_BASE_PATH}" "${STRAWBERRY_JAM_CLASSIC_BASE_PATH}" /E /I /H /Y`,
                (error) => error ? reject(error) : resolve())
            })
          } else if (process.platform === 'darwin') {
            const { exec } = require('child_process')
            await new Promise((resolve, reject) => {
              exec(`cp -R "${ANIMAL_JAM_CLASSIC_BASE_PATH}/"* "${STRAWBERRY_JAM_CLASSIC_BASE_PATH}/"`,
                (error) => error ? reject(error) : resolve())
            })
          } else {
            // Fallback to Node.js fs.cp for other platforms
            await cp(ANIMAL_JAM_CLASSIC_BASE_PATH, STRAWBERRY_JAM_CLASSIC_BASE_PATH, {
              recursive: true,
              force: true,
              preserveTimestamps: true
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

    const customAsarPath = process.platform === 'win32'
      ? path.join(this.assetsPath, 'winapp.asar')
      : process.platform === 'darwin'
        ? path.join(this.assetsPath, 'osxapp.asar')
        : undefined

    try {
      process.noAsar = true

      // Create resources directory if it doesn't exist
      if (!existsSync(resourcesDir)) {
        await mkdir(resourcesDir, { recursive: true })
      }

      // Verify custom asar exists
      if (!existsSync(customAsarPath)) {
        throw new Error(`Custom asar file not found at: ${customAsarPath}`)
      }

      // Remove existing asar files if they exist
      if (existsSync(asarPath)) {
        await rm(asarPath).catch(err => {
          if (err.code === 'EBUSY') {
            throw new Error('AJ Classic is running in the background. Check Task Manager and end the "AJ Classic.exe" processes, then try again. You can also use the "end" command to close AJ Classic processes.')
          } else if (err.code === 'EPERM') {
            throw new Error('It seems like you installed Strawberry Jam in C:\\Program Files instead of C:\\Users\\User\\AppData\\Local\\Programs\\. Rerun the setup and change the installation location.')
          }
        })
      }
      if (existsSync(asarUnpackedPath)) {
        await rm(asarUnpackedPath, { recursive: true }).catch(err => {
          if (err.code === 'EBUSY') {
            throw new Error('AJ Classic is running in the background. Check Task Manager and end the "AJ Classic.exe" processes, then try again. You can also use the "end" command to close AJ Classic processes.')
          } else if (err.code === 'EPERM') {
            throw new Error('It seems like you installed Strawberry Jam in C:\\Program Files instead of C:\\Users\\User\\AppData\\Local\\Programs\\. Rerun the setup and change the installation location.')
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

      // Copy the custom asar to the target location
      await copyFile(customAsarPath, asarPath)

      // Verify the executable exists
      const exePath = process.platform === 'win32'
        ? path.join(STRAWBERRY_JAM_CLASSIC_BASE_PATH, 'AJ Classic.exe')
        : process.platform === 'darwin'
          ? path.join(STRAWBERRY_JAM_CLASSIC_BASE_PATH, 'MacOS', 'AJ Classic')
          : undefined

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
    // Note: We no longer need to log ASAR patching messages, as this is already done in a standalone version.
    // This method is kept for compatibility, but we minimize its output to be more user-friendly.

    try {
      process.noAsar = true

      // Silently handle the patching operation
      const customAsarPath = process.platform === 'win32'
        ? path.join(this.assetsPath, 'winapp.asar')
        : process.platform === 'darwin'
          ? path.join(this.assetsPath, 'osxapp.asar')
          : undefined
      const resourcesDir = path.join(STRAWBERRY_JAM_CLASSIC_BASE_PATH, 'resources')
      const asarPath = path.join(resourcesDir, 'app.asar')
      const asarUnpackedPath = `${asarPath}.unpacked`

      // Create resources directory if it doesn't exist
      if (!existsSync(resourcesDir)) {
        await mkdir(resourcesDir, { recursive: true })
      }

      // Verify custom ASAR exists
      if (!existsSync(customAsarPath)) {
        throw new Error(`Custom ASAR file not found at: ${customAsarPath}`)
      }

      // Remove existing ASAR files if they exist
      if (existsSync(asarPath)) {
        await rm(asarPath).catch(err => {
          if (err.code === 'EBUSY') {
            throw new Error('AJ Classic is running in the background. Check Task Manager and end the "AJ Classic.exe" processes, then try again. You can also use the "end" command to close AJ Classic processes.')
          } else if (err.code === 'EPERM') {
            throw new Error('It seems like you installed Strawberry Jam in C:\\Program Files instead of C:\\Users\\User\\AppData\\Local\\Programs\\. Rerun the setup and change the installation location.')
          } else {
            throw new Error(`Error removing existing ASAR: ${err.message}`)
          }
        })
      }
      if (existsSync(asarUnpackedPath)) {
        await rm(asarUnpackedPath, { recursive: true }).catch(err => {
          if (err.code === 'EBUSY') {
            throw new Error('AJ Classic is running in the background. Check Task Manager and end the "AJ Classic.exe" processes, then try again. You can also use the "end" command to close AJ Classic processes.')
          } else if (err.code === 'EPERM') {
            throw new Error('It seems like you installed Strawberry Jam in C:\\Program Files instead of C:\\Users\\User\\AppData\\Local\\Programs\\. Rerun the setup and change the installation location.')
          } else {
            throw new Error(`Error removing existing ASAR.unpacked: ${err.message}`)
          }
        })
      }

      // Copy the custom ASAR to the target location
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
