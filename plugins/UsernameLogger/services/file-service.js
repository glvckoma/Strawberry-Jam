/**
 * @file file-service.js - File operations for Username Logger
 * @author glvckoma
 */

const fs = require('fs').promises;
const fsSync = require('fs');
const path = require('path');
const { createLogEntry, extractUsernameFromLogLine } = require('../utils/username-utils');

/**
 * Service for handling file operations
 */
class FileService {
  /**
   * Creates a new file service instance
   * @param {Object} options - Service options
   * @param {Object} options.application - The application object for logging
   */
  constructor({ application }) {
    this.application = application;
  }

  /**
   * Ensures a directory exists
   * @param {string} dirPath - The directory path to check/create
   * @returns {Promise<boolean>} True if successful
   */
  async ensureDirectoryExists(dirPath) {
    try {
      if (!fsSync.existsSync(dirPath)) {
        await fs.mkdir(dirPath, { recursive: true });
      }
      return true;
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error creating directory ${dirPath}: ${error.message}`
      });
      return false;
    }
  }

  /**
   * Appends a username entry to the log file
   * @param {string} filePath - Path to the log file
   * @param {string} username - Username to log
   * @returns {Promise<boolean>} True if successful
   */
  async appendUsernameToLog(filePath, username) {
    try {
      await this.ensureDirectoryExists(path.dirname(filePath));
      const logEntry = createLogEntry(username);
      await fs.appendFile(filePath, logEntry);
      return true;
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error writing to log file: ${error.message}`
      });
      return false;
    }
  }

  /**
   * Reads usernames from a log file
   * @param {string} filePath - Path to the log file
   * @returns {Promise<Array<string>>} Array of unique usernames
   */
  async readUsernamesFromLog(filePath) {
    try {
      if (!fsSync.existsSync(filePath)) {
        return [];
      }

      const content = await fs.readFile(filePath, 'utf8');
      const uniqueUsernames = new Set();

      content.split(/\r?\n/).forEach(line => {
        const username = extractUsernameFromLogLine(line);
        if (username) {
          uniqueUsernames.add(username);
        }
      });

      return [...uniqueUsernames];
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error reading from log file: ${error.message}`
      });
      return [];
    }
  }

  /**
   * Reads usernames with original lines from a log file
   * @param {string} filePath - Path to the log file
   * @returns {Promise<Array<{line: string, username: string}>>} Array of username entries with original lines
   */
  async readUsernameEntriesFromLog(filePath) {
    try {
      if (!fsSync.existsSync(filePath)) {
        return [];
      }

      const content = await fs.readFile(filePath, 'utf8');
      const entries = [];

      content.split(/\r?\n/).forEach(line => {
        const username = extractUsernameFromLogLine(line);
        if (username) {
          entries.push({
            line,
            username
          });
        }
      });

      return entries;
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error reading from log file: ${error.message}`
      });
      return [];
    }
  }

  /**
   * Writes an array of lines to a file
   * @param {string} filePath - Path to the file
   * @param {Array<string>} lines - Lines to write
   * @param {boolean} [append=false] - Whether to append to existing content
   * @returns {Promise<boolean>} True if successful
   */
  async writeLinesToFile(filePath, lines, append = false) {
    try {
      await this.ensureDirectoryExists(path.dirname(filePath));
      const content = lines.join('\n') + (lines.length > 0 ? '\n' : '');
      
      if (append) {
        await fs.appendFile(filePath, content);
      } else {
        await fs.writeFile(filePath, content);
      }
      
      return true;
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error writing to file ${filePath}: ${error.message}`
      });
      return false;
    }
  }

  /**
   * Reads lines from a file
   * @param {string} filePath - Path to the file
   * @returns {Promise<Array<string>>} Array of lines
   */
  async readLinesFromFile(filePath) {
    try {
      if (!fsSync.existsSync(filePath)) {
        return [];
      }

      const content = await fs.readFile(filePath, 'utf8');
      return content.split(/\r?\n/).filter(line => line.trim());
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error reading from file ${filePath}: ${error.message}`
      });
      return [];
    }
  }

  /**
   * Checks if a file exists
   * @param {string} filePath - Path to the file
   * @returns {Promise<boolean>} True if the file exists
   */
  async fileExists(filePath) {
    try {
      return fsSync.existsSync(filePath);
    } catch (error) {
      return false;
    }
  }

  /**
   * Batch appends multiple usernames to the log file
   * @param {string} filePath - Path to the log file
   * @param {Array<string>} usernames - Usernames to log
   * @returns {Promise<boolean>} True if successful
   */
  async batchAppendUsernames(filePath, usernames) {
    if (!usernames || usernames.length === 0) {
      return true;
    }

    try {
      await this.ensureDirectoryExists(path.dirname(filePath));
      const logEntries = usernames.map(username => createLogEntry(username).trim());
      await fs.appendFile(filePath, logEntries.join('\n') + '\n');
      return true;
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error batch writing to log file: ${error.message}`
      });
      return false;
    }
  }

  /**
   * Trims processed usernames from a log file
   * @param {string} logFilePath - Path to the log file
   * @param {number} processedIndex - Index up to which usernames have been processed
   * @param {Object} [options] - Additional options for trimming
   * @param {number} [options.chunkSize=5000] - Number of usernames to process at once
   * @param {boolean} [options.safeMode=true] - Whether to use safe processing mode for large files
   * @returns {Promise<boolean>} True if successful
   */
  async trimProcessedUsernames(logFilePath, processedIndex, options = {}) {
    const chunkSize = options.chunkSize || 5000;
    const safeMode = options.safeMode !== false;
    const isDevMode = process.env.NODE_ENV === 'development';
    let startTime;
    
    if (isDevMode) {
      startTime = Date.now();
      this.application.consoleMessage({
        type: 'logger',
        message: `[Username Logger] Starting trim operation for ${logFilePath} up to index ${processedIndex}`
      });
    }
    
    try {
      // Check if file exists first
      if (!(await this.fileExists(logFilePath))) {
        this.application.consoleMessage({
          type: 'warn',
          message: `[Username Logger] File not found: ${logFilePath}`
        });
        return false;
      }
      
      // For small indexes, use the traditional method
      if (processedIndex < 0) {
        this.application.consoleMessage({
          type: 'warn',
          message: `[Username Logger] No usernames have been processed yet (index = ${processedIndex}).`
        });
        return false;
      }
      
      // Create a backup file first in safe mode
      if (safeMode) {
        const backupFilePath = `${logFilePath}.bak`;
        try {
          const content = await fs.readFile(logFilePath, 'utf8');
          await fs.writeFile(backupFilePath, content);
          if (isDevMode) {
            this.application.consoleMessage({
              type: 'logger',
              message: `[Username Logger] Created backup file: ${backupFilePath}`
            });
          }
        } catch (backupError) {
          this.application.consoleMessage({
            type: 'error',
            message: `[Username Logger] Failed to create backup before trim: ${backupError.message}`
          });
          // Continue anyway, but log the error
        }
      }
      
      // Get file stats to decide on processing method
      const stats = await fs.stat(logFilePath);
      const fileSizeInMB = stats.size / (1024 * 1024);
      
      // For large files, use line-by-line processing
      if (fileSizeInMB > 1 || safeMode) {
        if (isDevMode) {
          this.application.consoleMessage({
            type: 'logger',
            message: `[Username Logger] Using chunked processing for large file (${fileSizeInMB.toFixed(2)}MB)`
          });
        }
        
        return await this._trimLargeFile(logFilePath, processedIndex, chunkSize);
      } else {
        // For small files, use in-memory processing
        if (isDevMode && safeMode) {
          this.application.consoleMessage({
            type: 'logger',
            message: `[Username Logger] Using standard processing for small file (${fileSizeInMB.toFixed(2)}MB)`
          });
        }
        
        const entries = await this.readUsernameEntriesFromLog(logFilePath);
        
        if (entries.length === 0) {
          this.application.consoleMessage({
            type: 'warn',
            message: `[Username Logger] No usernames found in collected file.`
          });
          return false;
        }

        if (processedIndex >= entries.length) {
          // Clear the file completely
          await fs.writeFile(logFilePath, '');
          if (isDevMode) {
            this.application.consoleMessage({
              type: 'logger',
              message: `[Username Logger] Cleared file completely (all ${entries.length} entries processed)`
            });
          }
          return true;
        } else {
          // Keep only the non-processed usernames
          const keepEntries = entries.slice(processedIndex + 1);
          const keepLines = keepEntries.map(entry => entry.line);
          
          await fs.writeFile(logFilePath, keepLines.join('\n') + (keepLines.length > 0 ? '\n' : ''));
          
          if (isDevMode) {
            this.application.consoleMessage({
              type: 'logger',
              message: `[Username Logger] Kept ${keepEntries.length} of ${entries.length} usernames`
            });
          }
          return true;
        }
      }
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error trimming processed usernames: ${error.message}, Stack: ${error.stack}`
      });
      return false;
    } finally {
      if (isDevMode) {
        const duration = (Date.now() - startTime) / 1000;
        this.application.consoleMessage({
          type: 'logger',
          message: `[Username Logger] Trim operation completed in ${duration.toFixed(2)}s`
        });
      }
    }
  }
  
  /**
   * Trims a large file using chunked line-by-line processing
   * @param {string} filePath - Path to the log file
   * @param {number} processedIndex - Index up to which usernames have been processed
   * @param {number} chunkSize - Size of chunks to process at once
   * @returns {Promise<boolean>} True if successful
   * @private
   */
  async _trimLargeFile(filePath, processedIndex, chunkSize) {
    const isDevMode = process.env.NODE_ENV === 'development';
    const outputFilePath = `${filePath}.new`;
    let outputStream;
    let lineCount = 0;
    let keptCount = 0;
    
    try {
      // Create the output file and stream
      outputStream = fsSync.createWriteStream(outputFilePath);
      
      // Process input file in chunks
      const content = await fs.readFile(filePath, 'utf8');
      const lines = content.split(/\r?\n/);
      const totalLines = lines.length;
      
      if (isDevMode) {
        this.application.consoleMessage({
          type: 'logger',
          message: `[Username Logger] Processing ${totalLines} lines in chunks of ${chunkSize}`
        });
      }
      
      // If processedIndex is beyond the total lines, just clear the file
      if (processedIndex >= totalLines) {
        outputStream.end('');
        await new Promise(resolve => outputStream.on('close', resolve));
        
        // Rename the empty file to replace the original
        await fs.rename(outputFilePath, filePath);
        
        if (isDevMode) {
          this.application.consoleMessage({
            type: 'logger',
            message: `[Username Logger] Cleared file completely (all ${totalLines} entries processed)`
          });
        }
        return true;
      }
      
      // Process chunks
      for (let startIdx = 0; startIdx < totalLines; startIdx += chunkSize) {
        const endIdx = Math.min(startIdx + chunkSize, totalLines);
        const chunk = lines.slice(startIdx, endIdx);
        
        for (const line of chunk) {
          // Skip this line if it's within the processed index
          if (lineCount <= processedIndex) {
            lineCount++;
            continue;
          }
          
          // Keep this line
          outputStream.write(line + '\n');
          lineCount++;
          keptCount++;
        }
        
        if (isDevMode && startIdx + chunkSize < totalLines) {
          this.application.consoleMessage({
            type: 'logger',
            message: `[Username Logger] Processed ${endIdx}/${totalLines} lines`
          });
        }
      }
      
      // Close the stream
      outputStream.end();
      await new Promise(resolve => outputStream.on('close', resolve));
      
      // Rename the new file to replace the original
      await fs.rename(outputFilePath, filePath);
      
      if (isDevMode) {
        this.application.consoleMessage({
          type: 'logger',
          message: `[Username Logger] Kept ${keptCount} of ${totalLines} usernames after processing`
        });
      }
      
      return true;
    } catch (error) {
      // Clean up on error
      if (outputStream) {
        outputStream.end();
      }
      
      // Try to remove the temporary file
      try {
        await fs.unlink(outputFilePath);
      } catch (unlinkError) {
        // Ignore errors during cleanup
      }
      
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error during large file trim: ${error.message}, Stack: ${error.stack}`
      });
      return false;
    }
  }
}

module.exports = FileService;
