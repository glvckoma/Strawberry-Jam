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

      // On game process exit, restore the original ASAR
      this._animalJamProcess.on('exit', async (code, signal) => {
        try {
          await this.restoreOriginalAsar()
          console.log('Original app.asar restored after game process exit.')
        } catch (err) {
          console.error(`Failed to restore original app.asar after game exit: ${err.message}`)
        }
      })

      // Handle Jam process exit (SIGINT, etc.) to ensure cleanup
      const cleanup = async () => {
        if (this._animalJamProcess && this._animalJamProcess.pid) {
          // Use tree-kill to terminate the entire process tree
          treeKill(this._animalJamProcess.pid, 'SIGKILL', async (err) => {
            if (err) {
              console.error(`Failed to kill game process tree: ${err.message}`)
            }
            try {
              await this.restoreOriginalAsar()
              console.log('Original app.asar restored on Jam exit.')
            } catch (restoreErr) {
              console.error(`Failed to restore original app.asar on Jam exit: ${restoreErr.message}`)
            }
            process.exit()
          })
        } else {
          try {
            await this.restoreOriginalAsar()
          } catch (err) {
            console.error(`Failed to restore original app.asar on Jam exit: ${err.message}`)
          }
          process.exit()
        }
      }

      process.on('SIGINT', cleanup)
      process.on('SIGTERM', cleanup)
      process.on('exit', cleanup)
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
    const backupAsarPath = `${asarPath}.unpatched`
    const customAsarPath = process.platform === 'win32'
      ? path.join('assets', 'winapp.asar')
      : process.platform === 'darwin'
        ? path.join(__dirname, '..', '..', '..', '..', '..', '..', '..', 'assets', 'osxapp.asar')
        : undefined

    try {
      process.noAsar = true

      if (!existsSync(backupAsarPath) && existsSync(asarPath)) {
        await rename(asarPath, backupAsarPath)
      }

      await copyFile(customAsarPath, asarPath)

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
   * Restores the original app.asar file.
   * @returns {Promise<void>}
   */
  async restoreOriginalAsar () {
    const asarPath = path.join(ANIMAL_JAM_CLASSIC_BASE_PATH, 'resources', 'app.asar')
    const backupAsarPath = `${asarPath}.unpatched`

    try {
      if (existsSync(backupAsarPath)) {
        await rename(backupAsarPath, asarPath)
      }
    } catch (error) {
      console.error(`Failed to restore original app.asar: ${error.message}`)
    }
  }
}
