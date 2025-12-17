const fs = require('fs').promises;
const path = require('path');
const { existsSync } = require('fs');
const FileLockChecker = require('./FileLockChecker');

class CacheCleaner {
  constructor() {
    this.fileLockChecker = new FileLockChecker();
    this.maxRetries = 3;
    this.retryDelays = [100, 200, 400];
  }

  async clearSafeCacheFiles(cachePath) {
    const result = {
      success: true,
      deleted: [],
      failed: [],
      skipped: [],
      errors: []
    };

    if (!existsSync(cachePath)) {
      return result;
    }

    try {
      const filesToDelete = await this.identifySafeToDeleteFiles(cachePath);
      
      for (const filePath of filesToDelete) {
        const isLocked = await this.fileLockChecker.isFileLocked(filePath);
        
        if (isLocked) {
          result.skipped.push(filePath);
          continue;
        }

        const deleteResult = await this.deleteFileWithRetry(filePath, this.maxRetries);
        
        if (deleteResult.success) {
          result.deleted.push(filePath);
        } else {
          result.failed.push(filePath);
          result.errors.push({
            file: filePath,
            error: deleteResult.error
          });
        }
      }

      if (result.failed.length > 0) {
        result.success = false;
      }
    } catch (error) {
      result.success = false;
      result.errors.push({
        file: cachePath,
        error: error.message
      });
    }

    return result;
  }

  async identifySafeToDeleteFiles(cachePath) {
    const filesToDelete = [];

    try {
      const entries = await fs.readdir(cachePath, { withFileTypes: true });

      for (const entry of entries) {
        const fullPath = path.join(cachePath, entry.name);

        if (entry.isFile()) {
          filesToDelete.push(fullPath);
        } else if (entry.isDirectory()) {
          const subFiles = await this.identifySafeToDeleteFiles(fullPath);
          filesToDelete.push(...subFiles);
        }
      }
    } catch (error) {
      if (error.code !== 'ENOENT') {
        throw error;
      }
    }

    return filesToDelete;
  }

  async deleteFileWithRetry(filePath, maxRetries) {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        const stats = await fs.stat(filePath).catch(() => null);
        if (!stats) {
          return { success: true, skipped: true };
        }

        await fs.unlink(filePath);
        return { success: true };
      } catch (error) {
        if (error.code === 'ENOENT') {
          return { success: true, skipped: true };
        }

        if (error.code === 'EBUSY' || error.code === 'EPERM' || error.code === 'EACCES') {
          if (attempt < maxRetries) {
            const delay = this.retryDelays[attempt - 1] || 100;
            await new Promise(resolve => setTimeout(resolve, delay));
            continue;
          }
        }

        if (attempt === maxRetries) {
          return {
            success: false,
            error: error.message,
            code: error.code
          };
        }

        const delay = this.retryDelays[attempt - 1] || 100;
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }

    return { success: false, error: 'Max retries exceeded' };
  }

  async deleteDirectoryWithRetry(dirPath, maxRetries) {
    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        const stats = await fs.stat(dirPath).catch(() => null);
        if (!stats) {
          return { success: true, skipped: true };
        }

        await fs.rm(dirPath, { recursive: true, force: true });
        return { success: true };
      } catch (error) {
        if (error.code === 'ENOENT') {
          return { success: true, skipped: true };
        }

        if (error.code === 'EBUSY' || error.code === 'EPERM' || error.code === 'EACCES') {
          if (attempt < maxRetries) {
            const delay = this.retryDelays[attempt - 1] || 100;
            await new Promise(resolve => setTimeout(resolve, delay));
            continue;
          }
        }

        if (attempt === maxRetries) {
          return {
            success: false,
            error: error.message,
            code: error.code
          };
        }

        const delay = this.retryDelays[attempt - 1] || 100;
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }

    return { success: false, error: 'Max retries exceeded' };
  }
}

module.exports = CacheCleaner;


