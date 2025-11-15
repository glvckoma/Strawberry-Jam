const { spawn } = require('child_process');
const path = require('path');
const os = require('os');
const fs = require('fs');
const { dialog, BrowserWindow, app } = require('electron');
const processManager = require('../../utils/ProcessManager');
const logManager = require('../../utils/LogManager');
const { getDataPath } = require('../../Constants');

const isDevelopment = process.env.NODE_ENV === 'development';

const STRAWBERRY_JAM_CLASSIC_BASE_PATH = process.platform === 'win32'
  ? path.join(os.homedir(), 'AppData', 'Local', 'Programs', 'strawberry-jam-classic')
  : process.platform === 'darwin'
    ? path.join('/', 'Applications', 'Strawberry Jam Classic.app', 'Contents')
    : undefined;

class GameProcessManager {
  constructor(electronInstance, gameTimeTracker, gameStartTimeRef, isGameTimeBeingTrackedRef) {
    this.electronInstance = electronInstance;
    this.gameTimeTracker = gameTimeTracker;
    this.gameStartTimeRef = gameStartTimeRef;
    this.isGameTimeBeingTrackedRef = isGameTimeBeingTrackedRef;
  }

  launchGameClient() {
    const exePath = process.platform === 'win32'
      ? path.join(STRAWBERRY_JAM_CLASSIC_BASE_PATH, 'AJ Classic.exe')
      : process.platform === 'darwin'
        ? path.join(STRAWBERRY_JAM_CLASSIC_BASE_PATH, 'MacOS', 'AJ Classic')
        : undefined;

    if (!exePath || !fs.existsSync(exePath)) {
      logManager.error(`[GameProcessManager] Game client executable not found at: ${exePath}`);
      dialog.showErrorBox('Launch Error', `Could not find the game client executable. Please ensure it is installed correctly at:\n${exePath}`);
      return;
    }

    const dataPath = getDataPath(app);
    const spawnEnv = {
      ...process.env,
      STRAWBERRY_JAM_DATA_PATH: dataPath
    };

    try {
      const gameProcess = spawn(exePath, [], {
        detached: false,
        stdio: 'ignore',
        env: spawnEnv
      });

      processManager.add(gameProcess);

      if (!this.isGameTimeBeingTrackedRef.value) {
        this.gameStartTimeRef.value = Date.now();
        this.isGameTimeBeingTrackedRef.value = true;
        logManager.log('[GameProcessManager] Starting game time tracking for first instance', 'main', logManager.logLevels.INFO);
      } else {
        logManager.log('[GameProcessManager] Additional game instance launched - not tracking game time', 'main', logManager.logLevels.INFO);
      }

      gameProcess.on('close', async (code) => {
        logManager.log(`[GameProcessManager] Game client process exited with code: ${code}`, 'main', logManager.logLevels.INFO);

        if (this.isGameTimeBeingTrackedRef.value && this.gameStartTimeRef.value) {
          const endTime = Date.now();
          const durationInSeconds = Math.round((endTime - this.gameStartTimeRef.value) / 1000);

          await this.gameTimeTracker.updateGameTimeOnExit(durationInSeconds);

          this.gameStartTimeRef.value = null;
          this.isGameTimeBeingTrackedRef.value = false;
        }

        const allWindows = BrowserWindow.getAllWindows();
        allWindows.forEach(window => {
          if (window.webContents) {
            window.webContents.send('game-process-exit');
          }
        });
      });

      gameProcess.on('error', (err) => {
        logManager.error(`[GameProcessManager] Error with game client process: ${err.message}`);

        if (this.isGameTimeBeingTrackedRef.value && this.gameStartTimeRef.value) {
          this.gameStartTimeRef.value = null;
          this.isGameTimeBeingTrackedRef.value = false;
        }

        const allWindows = BrowserWindow.getAllWindows();
        allWindows.forEach(window => {
          if (window.webContents) {
            window.webContents.send('game-process-exit');
          }
        });
      });
    } catch (error) {
      logManager.error(`[GameProcessManager] Failed to spawn game client process: ${error.message}`);
      dialog.showErrorBox('Launch Error', `Failed to start the game client process:\n${error.message}`);
    }
  }

  launchAJClassic() {
    const getAJClassicPath = () => {
      if (process.platform === 'win32') {
        return path.join(os.homedir(), 'AppData', 'Local', 'Programs', 'aj-classic', 'AJ Classic.exe');
      } else if (process.platform === 'darwin') {
        return path.join('/', 'Applications', 'AJ Classic.app', 'Contents', 'MacOS', 'AJ Classic');
      } else {
        const possiblePaths = [
          path.join(os.homedir(), '.local', 'share', 'aj-classic', 'AJ Classic'),
          path.join('/opt', 'aj-classic', 'AJ Classic'),
          path.join('/usr', 'local', 'bin', 'aj-classic')
        ];
        return possiblePaths.find(p => fs.existsSync(p)) || possiblePaths[0];
      }
    };

    const exePath = getAJClassicPath();

    if (!fs.existsSync(exePath)) {
      logManager.error(`[GameProcessManager] AJ Classic executable not found at: ${exePath}`);
      dialog.showErrorBox('AJ Classic Launch Error',
        `Could not find AJ Classic installation.\n\nLooked for:\n${exePath}\n\nPlease ensure AJ Classic is installed correctly.`);
      return;
    }

    try {
      const classicProcess = spawn(exePath, [], {
        detached: true,
        stdio: 'ignore'
      });

      processManager.add(classicProcess);
      classicProcess.unref();

      logManager.log(`[GameProcessManager] AJ Classic launched from: ${exePath}`, 'main', logManager.logLevels.INFO);

      classicProcess.on('error', (err) => {
        logManager.error(`[GameProcessManager] Error launching AJ Classic: ${err.message}`);
        dialog.showErrorBox('AJ Classic Launch Error', `Failed to start AJ Classic:\n${err.message}`);
      });
    } catch (error) {
      logManager.error(`[GameProcessManager] Failed to spawn AJ Classic process: ${error.message}`);
      dialog.showErrorBox('AJ Classic Launch Error', `Failed to start AJ Classic:\n${error.message}`);
    }
  }

  async endAJClassicProcesses() {
    const { exec } = require('child_process');
    const util = require('util');
    const execAsync = util.promisify(exec);

    try {
      let processCount = 0;

      if (process.platform === 'win32') {
        const processNames = ['AJ Classic.exe'];

        for (const processName of processNames) {
          try {
            const { stdout: listOutput } = await execAsync(`tasklist /FI "IMAGENAME eq ${processName}" /FO CSV | findstr /V "INFO:"`);

            if (listOutput.includes(processName)) {
              await execAsync(`taskkill /F /IM "${processName}"`);

              const lines = listOutput.split('\n').filter(line => line.includes(processName));
              processCount += lines.length - 1;

              logManager.log(`[GameProcessManager] Killed ${processName} processes`, 'main', logManager.logLevels.INFO);
            }
          } catch (killError) {
            if (!killError.message.includes('not found')) {
              logManager.warn(`[GameProcessManager] Failed to kill ${processName}: ${killError.message}`);
            }
          }
        }
      } else if (process.platform === 'darwin') {
        const processNames = ['AJ Classic'];

        for (const processName of processNames) {
          try {
            await execAsync(`pkill -f "${processName}"`);

            const { stdout: countOutput } = await execAsync(`pgrep -f "${processName}" | wc -l`);
            const count = parseInt(countOutput.trim(), 10);

            if (count > 0) {
              processCount += count;
              logManager.log(`[GameProcessManager] Killed ${processName} processes`, 'main', logManager.logLevels.INFO);
            }
          } catch (killError) {
            if (!killError.message.includes('No matching processes')) {
              logManager.warn(`[GameProcessManager] Failed to kill ${processName}: ${killError.message}`);
            }
          }
        }
      } else {
        const processNames = ['aj-classic', 'AJ Classic'];

        for (const processName of processNames) {
          try {
            await execAsync(`pkill -f "${processName}"`);
            processCount++;
            logManager.log(`[GameProcessManager] Killed ${processName} processes`, 'main', logManager.logLevels.INFO);
          } catch (killError) {
            if (!killError.message.includes('No matching processes')) {
              logManager.warn(`[GameProcessManager] Failed to kill ${processName}: ${killError.message}`);
            }
          }
        }
      }

      return {
        success: true,
        processCount: processCount,
        message: processCount > 0 ? `Successfully ended ${processCount} processes` : 'No AJ Classic processes were running'
      };
    } catch (error) {
      logManager.error(`[GameProcessManager] Failed to end AJ Classic processes: ${error.message}`);
      return {
        success: false,
        error: error.message,
        processCount: 0
      };
    }
  }
}

module.exports = GameProcessManager;

