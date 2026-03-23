const { spawn, execSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const { dialog, BrowserWindow, app } = require('electron');
const processManager = require('../../utils/ProcessManager');
const logManager = require('../../utils/LogManager');
const { getDataPath } = require('../../Constants');
const PlatformPaths = require('../../PlatformPaths');

const isDevelopment = process.env.NODE_ENV === 'development';

const resolveCompatLayer = (setting) => {
  if (PlatformPaths.platform !== 'linux') return null

  if (setting === 'none') return null
  if (setting === 'wine' || setting === 'bottles') return setting

  const detected = PlatformPaths.detectCompatibilityLayer()
  return detected[0] || null
}

const getWineBinary = (compatLayer) => {
  if (compatLayer === 'bottles') {
    try {
      execSync('which flatpak', { stdio: 'ignore' })
      return null
    } catch (e) {}
  }
  return 'wine'
}

class GameProcessManager {
  constructor(electronInstance, gameTimeTracker, gameStartTimeRef, isGameTimeBeingTrackedRef, settingsService) {
    this.electronInstance = electronInstance;
    this.gameTimeTracker = gameTimeTracker;
    this.gameStartTimeRef = gameStartTimeRef;
    this.isGameTimeBeingTrackedRef = isGameTimeBeingTrackedRef;
    this.settingsService = settingsService;
  }

  _getLinuxSettings() {
    let compatLayer = 'auto'
    let winePrefix = ''
    try {
      if (this.settingsService) {
        compatLayer = this.settingsService.getSetting('linux.compatibilityLayer') || 'auto'
        winePrefix = this.settingsService.getSetting('linux.winePrefix') || ''
      }
    } catch (e) {}
    return { compatLayer, winePrefix }
  }

  launchGameClient() {
    const { compatLayer: compatSetting, winePrefix } = this._getLinuxSettings();
    const resolvedCompat = resolveCompatLayer(compatSetting);

    const basePath = PlatformPaths.getStrawberryJamClassicBasePath(resolvedCompat, winePrefix);
    const exePath = PlatformPaths.getGameExecutablePath(basePath, resolvedCompat);

    if (!exePath || !fs.existsSync(exePath)) {
      logManager.error(`[GameProcessManager] Game client executable not found at: ${exePath}`);

      let errorDetail = `Could not find the game client executable. Please ensure it is installed correctly at:\n${exePath}`;
      if (PlatformPaths.platform === 'linux' && !resolvedCompat) {
        errorDetail += '\n\nOn Linux, AJ Classic requires Wine or Bottles. Install Wine and configure it in Settings > Advanced > Linux Compatibility Layer.';
      }

      dialog.showErrorBox('Launch Error', errorDetail);
      return;
    }

    const dataPath = getDataPath(app);
    const spawnEnv = {
      ...process.env,
      STRAWBERRY_JAM_DATA_PATH: dataPath
    };

    if (resolvedCompat) {
      spawnEnv.WINEPREFIX = winePrefix || PlatformPaths.detectWinePrefix(winePrefix);
    }

    try {
      let spawnCmd, spawnArgs;

      if (resolvedCompat === 'bottles') {
        try {
          execSync('which flatpak', { stdio: 'ignore' });
          spawnCmd = 'flatpak';
          spawnArgs = ['run', '--command=bottles-cli', 'com.usebottles.bottles', 'run', '-e', exePath];
          logManager.log('[GameProcessManager] Launching via Bottles (flatpak)', 'main', logManager.logLevels.INFO);
        } catch (e) {
          spawnCmd = 'wine';
          spawnArgs = [exePath];
          logManager.log('[GameProcessManager] Bottles flatpak not found, falling back to Wine', 'main', logManager.logLevels.WARN);
        }
      } else if (resolvedCompat === 'wine') {
        spawnCmd = 'wine';
        spawnArgs = [exePath];
        logManager.log('[GameProcessManager] Launching via Wine', 'main', logManager.logLevels.INFO);
      } else {
        spawnCmd = exePath;
        spawnArgs = [];
      }

      const gameProcess = spawn(spawnCmd, spawnArgs, {
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
    const { compatLayer: compatSetting, winePrefix } = this._getLinuxSettings();
    const resolvedCompat = resolveCompatLayer(compatSetting);

    const ajClassicBasePath = PlatformPaths.getAnimalJamClassicBasePath(resolvedCompat, winePrefix);
    const exePath = PlatformPaths.getGameExecutablePath(ajClassicBasePath, resolvedCompat);

    if (!fs.existsSync(exePath)) {
      logManager.error(`[GameProcessManager] AJ Classic executable not found at: ${exePath}`);
      let errorMsg = `Could not find AJ Classic installation.\n\nLooked for:\n${exePath}\n\nPlease ensure AJ Classic is installed correctly.`;
      if (PlatformPaths.platform === 'linux' && !resolvedCompat) {
        errorMsg += '\n\nOn Linux, install AJ Classic via Wine and configure the compatibility layer in Settings.';
      }
      dialog.showErrorBox('AJ Classic Launch Error', errorMsg);
      return;
    }

    const spawnEnv = { ...process.env };
    if (resolvedCompat) {
      spawnEnv.WINEPREFIX = winePrefix || PlatformPaths.detectWinePrefix(winePrefix);
    }

    try {
      let spawnCmd, spawnArgs;

      if (resolvedCompat === 'bottles') {
        try {
          execSync('which flatpak', { stdio: 'ignore' });
          spawnCmd = 'flatpak';
          spawnArgs = ['run', '--command=bottles-cli', 'com.usebottles.bottles', 'run', '-e', exePath];
        } catch (e) {
          spawnCmd = 'wine';
          spawnArgs = [exePath];
        }
      } else if (resolvedCompat === 'wine') {
        spawnCmd = 'wine';
        spawnArgs = [exePath];
      } else {
        spawnCmd = exePath;
        spawnArgs = [];
      }

      const classicProcess = spawn(spawnCmd, spawnArgs, {
        detached: true,
        stdio: 'ignore',
        env: spawnEnv
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

      const processNames = PlatformPaths.getProcessNames();

      if (PlatformPaths.platform === 'win32') {
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
      } else {
        for (const processName of processNames) {
          try {
            await execAsync(`pkill -f "${processName}"`);

            const { stdout: countOutput } = await execAsync(`pgrep -f "${processName}" | wc -l`);
            const count = parseInt(countOutput.trim(), 10);

            if (count > 0) {
              processCount += count;
            }

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

