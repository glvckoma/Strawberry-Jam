const fsPromises = require('fs').promises;
const path = require('path');
const { app } = require('electron');
const os = require('os');

class CacheService {
  constructor() {
    this.cachePaths = null;
  }

  getCachePaths() {
    if (this.cachePaths) {
      return this.cachePaths;
    }

    const cachePaths = [];

    if (process.platform === 'win32') {
      const appDataPath = app.getPath('appData');
      cachePaths.push(path.join(appDataPath, 'strawberry-jam'));
      cachePaths.push(path.join(appDataPath, 'AJ Classic'));
    } else if (process.platform === 'darwin') {
      const homeDir = app.getPath('home');
      const libraryPath = path.join(homeDir, 'Library', 'Application Support');
      cachePaths.push(path.join(libraryPath, 'strawberry-jam'));
      cachePaths.push(path.join(libraryPath, 'AJ Classic'));
    }

    this.cachePaths = cachePaths;
    return cachePaths;
  }

  async clearAppCache() {
    const cachePaths = this.getCachePaths();
    const errors = [];

    for (const cachePath of cachePaths) {
      try {
        await fsPromises.rm(cachePath, { recursive: true, force: true });
      } catch (error) {
        if (error.code === 'ENOENT') {
        } else {
          console.error(`[Cache Clear Method] Failed to delete ${cachePath}:`, error);
          errors.push(`Failed to delete ${path.basename(cachePath)}: ${error.message}`);
        }
      }
    }

    if (errors.length > 0) {
      console.error('[Cache Clear Method] Finished with errors:', errors.join('; '));
    }
  }

  getUninstallerPath() {
    if (process.platform === 'win32') {
      const localAppData = app.getPath('localAppData');
      return path.join(localAppData, 'Programs', 'strawberry-jam', 'Uninstall strawberry-jam.exe');
    } else if (process.platform === 'darwin') {
      return null;
    } else {
      return null;
    }
  }
}

module.exports = CacheService;

