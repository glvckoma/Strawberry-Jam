const fs = require('fs');
const fsPromises = fs.promises;
const path = require('path');
const { dialog } = require('electron');
const { getDataPath } = require('../../Constants');

const isDevelopment = process.env.NODE_ENV === 'development';

class FileIOHandler {
  constructor(app, window) {
    this.app = app;
    this.window = window;
  }

  async readJsonFile(filePath, defaultValue) {
    const dataDir = getDataPath(this.app);
    const fullPath = path.join(dataDir, filePath);
    try {
      await fsPromises.access(fullPath);
      const fileContent = await fsPromises.readFile(fullPath, 'utf-8');
      return JSON.parse(fileContent);
    } catch (error) {
      return defaultValue;
    }
  }

  async writeJsonFile(filePath, data) {
    const dataDir = getDataPath(this.app);
    const fullPath = path.join(dataDir, filePath);
    try {
      await fsPromises.mkdir(path.dirname(fullPath), { recursive: true });
      await fsPromises.writeFile(fullPath, JSON.stringify(data, null, 2), 'utf-8');
      return true;
    } catch (error) {
      if (isDevelopment) {
        console.error(`[FileIOHandler] Error writing JSON file '${fullPath}':`, error);
      }
      return false;
    }
  }

  async readFile(filePath) {
    try {
      return await fsPromises.readFile(filePath, 'utf-8');
    } catch (error) {
      if (isDevelopment) {
        console.error(`[FileIOHandler] Error reading file '${filePath}':`, error);
      }
      throw error;
    }
  }

  async saveTextFile(options) {
    if (!this.window) {
      return { success: false, canceled: true };
    }

    try {
      const result = await dialog.showSaveDialog(this.window, {
        title: 'Save Report',
        defaultPath: options.suggestedFilename,
        filters: [
          { name: 'Text Files', extensions: ['txt'] },
          { name: 'All Files', extensions: ['*'] }
        ]
      });

      if (result.canceled || !result.filePath) {
        return { success: false, canceled: true };
      }

      await fsPromises.writeFile(result.filePath, options.content, 'utf-8');

      return { success: true, filePath: result.filePath };
    } catch (error) {
      if (isDevelopment) {
        console.error(`[FileIOHandler] Error saving text file:`, error);
      }
      return { success: false, error: error.message };
    }
  }

  getDataDirectory() {
    return getDataPath(this.app);
  }

  async ensureDataDirectory() {
    const dataDir = getDataPath(this.app);
    try {
      await fsPromises.mkdir(dataDir, { recursive: true });
      return dataDir;
    } catch (error) {
      if (isDevelopment) {
        console.error(`[FileIOHandler] Error creating data directory '${dataDir}':`, error);
      }
      throw error;
    }
  }
}

module.exports = FileIOHandler;

