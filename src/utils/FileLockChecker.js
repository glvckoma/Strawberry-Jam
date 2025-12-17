const fs = require('fs').promises;
const fsSync = require('fs');
const path = require('path');

class FileLockChecker {
  constructor() {
    this.timeoutMs = 500;
  }

  async isFileLocked(filePath) {
    try {
      const normalizedPath = path.normalize(filePath);
      
      if (process.platform === 'win32') {
        return await this.checkWindowsFileLock(normalizedPath);
      } else {
        return await this.checkUnixFileLock(normalizedPath);
      }
    } catch (error) {
      return false;
    }
  }

  async checkWindowsFileLock(filePath) {
    return new Promise((resolve) => {
      const timeout = setTimeout(() => {
        resolve(false);
      }, this.timeoutMs);

      fsSync.open(filePath, fsSync.constants.O_EXCL | fsSync.constants.O_RDWR, (err, fd) => {
        clearTimeout(timeout);
        
        if (err) {
          if (err.code === 'EACCES' || err.code === 'EPERM' || err.code === 'EBUSY') {
            resolve(true);
          } else if (err.code === 'ENOENT') {
            resolve(false);
          } else {
            resolve(false);
          }
        } else {
          fsSync.close(fd, () => {});
          resolve(false);
        }
      });
    });
  }

  async checkUnixFileLock(filePath) {
    try {
      const stats = await fs.stat(filePath);
      if (!stats.isFile()) {
        return false;
      }

      try {
        const fd = await fs.open(filePath, 'r+');
        await fd.close();
        return false;
      } catch (error) {
        if (error.code === 'EACCES' || error.code === 'EPERM' || error.code === 'EBUSY') {
          return true;
        }
        return false;
      }
    } catch (error) {
      if (error.code === 'ENOENT') {
        return false;
      }
      return false;
    }
  }
}

module.exports = FileLockChecker;


