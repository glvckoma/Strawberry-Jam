const path = require('path')
const os = require('os')
const { rename, copyFile, rm, mkdir } = require('fs/promises')
const { existsSync } = require('fs')
const { spawn } = require('child_process')
const treeKill = require('tree-kill')
const { promisify } = require('util')

/**
 * Animal Jam Classic base path.
 * @constant
 */
const ANIMAL_JAM_CLASSIC_BASE_PATH = process.platform === 'win32'
  ? path.join(os.homedir(), 'AppData', 'Local', 'Programs', 'aj-classic')
  : process.platform === 'darwin'
    ? path.join('/', 'Applications', 'AJ Classic.app', 'Contents')
    : undefined

/**
 * Animal Jam cache path.
 * @constant
 */
const ANIMAL_JAM_CLASSIC_CACHE_PATH = process.platform === 'win32'
  ? path.join(os.homedir(), 'AppData', 'Roaming', 'AJ Classic', 'Cache')
  : process.platform === 'darwin'
    ? path.join(os.homedir(), 'Library', 'Application Support', 'AJ Classic', 'Cache')
    : undefined

module.exports = class Patcher {
  /**
   * Creates an instance of the Patcher class.
   * @param {Settings} application - The application that instantiated this patcher.
   */
  constructor (application) {
    this._application = application
    this._animalJamProcess = null
  }

  /**
   * Starts Animal Jam Classic process after patching it, if necessary.
   * @returns {Promise<void>}
   */
  async killProcessAndPatch () {
    try {
      await this.patchApplication()

      const exePath = process.platform === 'win32'
        ? path.join(ANIMAL_JAM_CLASSIC_BASE_PATH, 'AJ Classic.exe')
        : process.platform === 'darwin'
          ? path.join(ANIMAL_JAM_CLASSIC_BASE_PATH, 'MacOS', 'AJ Classic')
          : undefined

      // Launch the game process using spawn for robust process tracking
      this._animalJamProcess = spawn(exePath, [], { detached: false, stdio: 'ignore' })

      // Removed ASAR restoration logic on game/Jam exit
    } catch (error) {
      console.error(`Failed to start Animal Jam Classic process: ${error.message}`)
    }
  }

  /**
   * Patches Animal Jam Classic application.
   * @returns {Promise<void>}
   */
  async patchApplication () {
    const asarPath = path.join(ANIMAL_JAM_CLASSIC_BASE_PATH, 'resources', 'app.asar')
    // Removed backupAsarPath definition
    const customAsarPath = process.platform === 'win32'
      ? path.join('assets', 'winapp.asar')
      : process.platform === 'darwin'
        ? path.join(__dirname, '..', '..', '..', '..', '..', '..', '..', 'assets', 'osxapp.asar')
        : undefined

    try {
      process.noAsar = true

      // Removed backup logic (rename)
      // Directly copy the custom ASAR over the original
      await copyFile(customAsarPath, asarPath)
      console.log('Custom ASAR copied directly over original app.asar.');

      if (existsSync(ANIMAL_JAM_CLASSIC_CACHE_PATH)) {
        await rm(ANIMAL_JAM_CLASSIC_CACHE_PATH, { recursive: true })
        await mkdir(ANIMAL_JAM_CLASSIC_CACHE_PATH, { recursive: true })
      }
    } catch (error) {
      console.error(`Failed to patch Animal Jam Classic: ${error.message}`)
    } finally {
      process.noAsar = false
    }
  }

  /**
   * Removed restoreOriginalAsar method as backup is no longer created.
   */
  // async restoreOriginalAsar () { ... } // Method removed
}
