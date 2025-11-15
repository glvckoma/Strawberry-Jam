const fsPromises = require('fs').promises;
const path = require('path');
const { getDataPath } = require('../../Constants');
const logManager = require('../../utils/LogManager');

const isDevelopment = process.env.NODE_ENV === 'development';

class GameTimeTracker {
  constructor(app, gameStartTimeRef, lastKnownGoodGameTimeRef) {
    this.app = app;
    this.gameStartTimeRef = gameStartTimeRef;
    this.lastKnownGoodGameTimeRef = lastKnownGoodGameTimeRef;
  }

  getGameTimeFilePath() {
    const dataDir = getDataPath(this.app);
    return path.join(dataDir, 'gametime.json');
  }

  async getTotalGameTime() {
    const gameTimeFilePath = this.getGameTimeFilePath();
    let totalGameTime = 0;
    try {
      await fsPromises.access(gameTimeFilePath);
      const fileContent = await fsPromises.readFile(gameTimeFilePath, 'utf-8');
      const data = JSON.parse(fileContent);
      totalGameTime = data.totalGameTime || 0;

      if (totalGameTime > Date.now() / 1000) {
        logManager.warn(`[GameTimeTracker] Detected abnormally high game time (${totalGameTime}), reverting to last known value: ${this.lastKnownGoodGameTimeRef.value}.`);
        totalGameTime = this.lastKnownGoodGameTimeRef.value;
      } else {
        this.lastKnownGoodGameTimeRef.value = totalGameTime;
      }
    } catch (error) {
    }

    if (this.gameStartTimeRef.value) {
      const now = Date.now();
      const sessionDuration = Math.round((now - this.gameStartTimeRef.value) / 1000);
      totalGameTime += sessionDuration;
    }

    return totalGameTime;
  }

  async getTotalUptime() {
    const gameTimeFilePath = this.getGameTimeFilePath();
    try {
      await fsPromises.access(gameTimeFilePath);
      const fileContent = await fsPromises.readFile(gameTimeFilePath, 'utf-8');
      const data = JSON.parse(fileContent);
      return data.totalUptime || 0;
    } catch (error) {
      return 0;
    }
  }

  async updateTotalUptime(uptime) {
    const gameTimeFilePath = this.getGameTimeFilePath();
    let gameTimeData = { totalGameTime: 0, totalUptime: 0 };

    try {
      await fsPromises.access(gameTimeFilePath);
      const fileContent = await fsPromises.readFile(gameTimeFilePath, 'utf-8');
      gameTimeData = JSON.parse(fileContent);
    } catch (error) {
    }

    gameTimeData.totalUptime = uptime;

    try {
      await fsPromises.mkdir(path.dirname(gameTimeFilePath), { recursive: true });
      await fsPromises.writeFile(gameTimeFilePath, JSON.stringify(gameTimeData, null, 2), 'utf-8');
    } catch (error) {
      logManager.error(`[GameTimeTracker] Failed to write total uptime: ${error.message}`);
    }
  }

  async resetGameTime() {
    const gameTimeFilePath = this.getGameTimeFilePath();
    const initialData = { totalGameTime: 0, totalUptime: 0 };

    try {
      await fsPromises.mkdir(path.dirname(gameTimeFilePath), { recursive: true });
      await fsPromises.writeFile(gameTimeFilePath, JSON.stringify(initialData, null, 2), 'utf-8');
      this.lastKnownGoodGameTimeRef.value = 0;
      return { success: true };
    } catch (error) {
      logManager.error(`[GameTimeTracker] Failed to reset game time file: ${error.message}`);
      return { success: false, error: error.message };
    }
  }

  async updateGameTimeOnExit(durationInSeconds) {
    const gameTimeFilePath = this.getGameTimeFilePath();
    let gameTimeData = { totalGameTime: 0, totalUptime: 0 };

    try {
      await fsPromises.access(gameTimeFilePath);
      const fileContent = await fsPromises.readFile(gameTimeFilePath, 'utf-8');
      gameTimeData = JSON.parse(fileContent);

      if (gameTimeData.totalGameTime > Date.now() / 1000) {
        logManager.warn(`[GameTimeTracker] Detected abnormally high game time (${gameTimeData.totalGameTime}), reverting to last known value: ${this.lastKnownGoodGameTimeRef.value}.`);
        gameTimeData.totalGameTime = this.lastKnownGoodGameTimeRef.value;
      } else {
        this.lastKnownGoodGameTimeRef.value = gameTimeData.totalGameTime;
      }
    } catch (error) {
    }

    gameTimeData.totalGameTime += durationInSeconds;

    try {
      await fsPromises.mkdir(path.dirname(gameTimeFilePath), { recursive: true });
      await fsPromises.writeFile(gameTimeFilePath, JSON.stringify(gameTimeData, null, 2), 'utf-8');
      logManager.log(`[GameTimeTracker] Updated game time: +${durationInSeconds}s (Total: ${gameTimeData.totalGameTime}s)`, 'main', logManager.logLevels.INFO);
    } catch (error) {
      logManager.error(`[GameTimeTracker] Failed to write total game time: ${error.message}`);
    }
  }
}

module.exports = GameTimeTracker;

