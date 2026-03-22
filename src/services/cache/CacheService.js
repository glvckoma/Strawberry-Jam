const fsPromises = require('fs').promises;
const path = require('path');
const { app } = require('electron');
const { existsSync } = require('fs');

class CacheService {
  constructor() {
    this.cachePaths = null;
  }

  getCachePaths() {
    if (this.cachePaths) {
      return this.cachePaths;
    }

    const cachePaths = [];

    const appDataPath = app.getPath('appData');
    cachePaths.push(path.join(appDataPath, 'strawberry-jam'));
    cachePaths.push(path.join(appDataPath, 'strawberry-jam-classic'));

    this.cachePaths = cachePaths;
    return cachePaths;
  }

  getStrawberryJamPath() {
    return path.join(app.getPath('appData'), 'strawberry-jam');
  }

  getAJClassicPath() {
    return path.join(app.getPath('appData'), 'strawberry-jam-classic');
  }

  async clearGameSessionCache() {
    const ajClassicPath = this.getAJClassicPath();
    const errors = [];

    if (!ajClassicPath) {
      return { success: false, error: 'Platform not supported' };
    }

    const cachePath = path.join(ajClassicPath, 'Cache');
    
    try {
      if (existsSync(cachePath)) {
        await fsPromises.rm(cachePath, { recursive: true, force: true });
        await fsPromises.mkdir(cachePath, { recursive: true });
      }
      return { success: true };
    } catch (error) {
      if (error.code === 'ENOENT') {
        return { success: true };
      } else {
        console.error(`[CacheService] Failed to clear game session cache:`, error);
        errors.push(`Failed to clear game session cache: ${error.message}`);
        return { success: false, error: error.message, errors };
      }
    }
  }

  async clearAuthCache() {
    const strawberryJamPath = this.getStrawberryJamPath();
    const errors = [];

    if (!strawberryJamPath) {
      return { success: false, error: 'Platform not supported' };
    }

    try {
      const pathsToClear = [
        path.join(strawberryJamPath, 'accounts'),
        path.join(strawberryJamPath, 'auth'),
        path.join(strawberryJamPath, 'tokens')
      ];

      for (const clearPath of pathsToClear) {
        try {
          if (existsSync(clearPath)) {
            await fsPromises.rm(clearPath, { recursive: true, force: true });
          }
        } catch (error) {
          if (error.code !== 'ENOENT') {
            errors.push(`Failed to clear ${path.basename(clearPath)}: ${error.message}`);
          }
        }
      }


      if (errors.length > 0) {
        return { success: false, errors };
      }
      return { success: true };
    } catch (error) {
      console.error(`[CacheService] Failed to clear auth cache:`, error);
      return { success: false, error: error.message, errors };
    }
  }

  async clearPluginCache() {
    const strawberryJamPath = this.getStrawberryJamPath();
    const userDataPath = app.getPath('userData');
    const errors = [];

    if (!strawberryJamPath) {
      return { success: false, error: 'Platform not supported' };
    }

    try {
      const pathsToClear = [
        path.join(strawberryJamPath, 'plugins'),
        path.join(userDataPath, 'plugins')
      ];

      for (const clearPath of pathsToClear) {
        try {
          if (existsSync(clearPath)) {
            const entries = await fsPromises.readdir(clearPath, { withFileTypes: true });
            for (const entry of entries) {
              const entryPath = path.join(clearPath, entry.name);
              if (entry.isDirectory()) {
                const pluginConfigPath = path.join(entryPath, 'plugin.json');
                if (existsSync(pluginConfigPath)) {
                  await fsPromises.rm(entryPath, { recursive: true, force: true });
                }
              }
            }
          }
        } catch (error) {
          if (error.code !== 'ENOENT') {
            errors.push(`Failed to clear plugin cache: ${error.message}`);
          }
        }
      }

      if (errors.length > 0) {
        return { success: false, errors };
      }
      return { success: true };
    } catch (error) {
      console.error(`[CacheService] Failed to clear plugin cache:`, error);
      return { success: false, error: error.message, errors };
    }
  }

  async clearLogs() {
    const strawberryJamPath = this.getStrawberryJamPath();
    const userDataPath = app.getPath('userData');
    const errors = [];

    if (!strawberryJamPath) {
      return { success: false, error: 'Platform not supported' };
    }

    try {
      const pathsToClear = [
        path.join(strawberryJamPath, 'logs'),
        path.join(userDataPath, 'logs')
      ];

      for (const clearPath of pathsToClear) {
        try {
          if (existsSync(clearPath)) {
            const entries = await fsPromises.readdir(clearPath, { withFileTypes: true });
            for (const entry of entries) {
              if (entry.isFile() && entry.name.endsWith('.log')) {
                await fsPromises.unlink(path.join(clearPath, entry.name));
              } else if (entry.isDirectory()) {
                await fsPromises.rm(path.join(clearPath, entry.name), { recursive: true, force: true });
              }
            }
          }
        } catch (error) {
          if (error.code !== 'ENOENT') {
            errors.push(`Failed to clear logs: ${error.message}`);
          }
        }
      }

      if (errors.length > 0) {
        return { success: false, errors };
      }
      return { success: true };
    } catch (error) {
      console.error(`[CacheService] Failed to clear logs:`, error);
      return { success: false, error: error.message, errors };
    }
  }

  async clearTempFiles() {
    const strawberryJamPath = this.getStrawberryJamPath();
    const ajClassicPath = this.getAJClassicPath();
    const errors = [];

    if (!strawberryJamPath || !ajClassicPath) {
      return { success: false, error: 'Platform not supported' };
    }

    try {
      const pathsToCheck = [strawberryJamPath, ajClassicPath];
      const tempPatterns = ['temp', 'tmp', 'cache', 'downloads'];

      for (const basePath of pathsToCheck) {
        if (!existsSync(basePath)) continue;

        try {
          const entries = await fsPromises.readdir(basePath, { withFileTypes: true });
          for (const entry of entries) {
            const entryName = entry.name.toLowerCase();
            const entryPath = path.join(basePath, entry.name);

            if (tempPatterns.some(pattern => entryName.includes(pattern))) {
              try {
                if (entry.isDirectory()) {
                  await fsPromises.rm(entryPath, { recursive: true, force: true });
                } else {
                  await fsPromises.unlink(entryPath);
                }
              } catch (error) {
                if (error.code !== 'ENOENT') {
                  errors.push(`Failed to clear temp file ${entry.name}: ${error.message}`);
                }
              }
            }
          }
        } catch (error) {
          if (error.code !== 'ENOENT') {
            errors.push(`Failed to scan ${path.basename(basePath)}: ${error.message}`);
          }
        }
      }

      if (errors.length > 0) {
        return { success: false, errors };
      }
      return { success: true };
    } catch (error) {
      console.error(`[CacheService] Failed to clear temp files:`, error);
      return { success: false, error: error.message, errors };
    }
  }

  async clearAppCache(options = {}) {
    const results = {
      gameSession: null,
      auth: null,
      plugins: null,
      logs: null,
      temp: null,
      all: null,
      errors: []
    };

    if (options.all || (!options.gameSession && !options.auth && !options.plugins && !options.logs && !options.temp)) {
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
        results.all = { success: false, errors };
      } else {
        results.all = { success: true };
      }
      return results;
    }

    if (options.gameSession) {
      results.gameSession = await this.clearGameSessionCache();
      if (!results.gameSession.success) {
        results.errors.push('Game session cache');
      }
    }

    if (options.auth) {
      results.auth = await this.clearAuthCache();
      if (!results.auth.success) {
        results.errors.push('Auth cache');
      }
    }

    if (options.plugins) {
      results.plugins = await this.clearPluginCache();
      if (!results.plugins.success) {
        results.errors.push('Plugin cache');
      }
    }

    if (options.logs) {
      results.logs = await this.clearLogs();
      if (!results.logs.success) {
        results.errors.push('Logs');
      }
    }

    if (options.temp) {
      results.temp = await this.clearTempFiles();
      if (!results.temp.success) {
        results.errors.push('Temp files');
      }
    }

    return results;
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

