const fsPromises = require('fs').promises;
const path = require('path');

class AppStateService {
  constructor(app, defaultState) {
    this.app = app;
    this.defaultState = defaultState;
    this.userDataPath = app.getPath('userData');
    this.stateFilePath = path.join(this.userDataPath, 'jam_state.json');
  }

  async getAppState() {
    try {
      await fsPromises.access(this.stateFilePath);
      const data = await fsPromises.readFile(this.stateFilePath, 'utf-8');
      const currentState = JSON.parse(data);
      const mergedState = {
        ...this.defaultState,
        ...currentState,
        leakCheck: { ...this.defaultState.leakCheck, ...(currentState.leakCheck || {}) }
      };
      return mergedState;
    } catch (error) {
      if (error.code === 'ENOENT') {
        return JSON.parse(JSON.stringify(this.defaultState));
      }
      return JSON.parse(JSON.stringify(this.defaultState));
    }
  }

  async setAppState(newState) {
    try {
      await fsPromises.mkdir(this.userDataPath, { recursive: true });
      await fsPromises.writeFile(this.stateFilePath, JSON.stringify(newState, null, 2), 'utf-8');
      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
}

module.exports = AppStateService;

