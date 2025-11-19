/**
 * @file migration-service.js - Handles data migration for the Username Logger plugin
 * @author glvckoma
 */

const fs = require('fs').promises;
const path = require('path');
const { getFilePaths } = require('../utils/path-utils');
const {
  COLLECTED_USERNAMES_FILE,
  PROCESSED_FILE,
  FOUND_GENERAL_FILE,
  FOUND_AJC_FILE,
  POTENTIAL_ACCOUNTS_FILE
} = require('../constants/constants');

/**
 * Service for handling data migration to the centralized file structure.
 */
class MigrationService {
  /**
   * Creates a new migration service.
   * @param {Object} options - Service options.
   * @param {Object} options.application - The application object for logging.
   * @param {Object} options.fileService - The file service for file operations.
   * @param {Object} options.configModel - The config model for accessing configuration.
   * @param {string} options.originalDataPath - The original application data path (e.g., .../strawberry-jam/data).
   * @param {string} options.pluginStoragePath - The new dedicated storage path for the plugin (e.g., .../strawberry-jam/UsernameLogger).
   */
  constructor({ application, fileService, configModel, originalDataPath, pluginStoragePath }) {
    this.application = application;
    this.fileService = fileService;
    this.configModel = configModel;
    this.originalDataPath = originalDataPath;
    this.pluginStoragePath = pluginStoragePath;
    this.isDevMode = process.env.NODE_ENV === 'development';
  }

  /**
   * Runs the entire migration process.
   * This is the main entry point for migration.
   * @returns {Promise<void>}
   */
  async runMigration() {
    // Check if migration to the new centralized path has already been done.
    if (this.configModel.getMigrationV2Status()) {
      if (this.isDevMode) {
        this.application.consoleMessage({ type: 'logger', message: '[Username Logger] Centralized file migration already completed. Skipping.' });
      }
      return;
    }

    this.application.consoleMessage({ type: 'notify', message: '[Username Logger] Checking for files to migrate to new centralized location...' });

    let filesMigrated = 0;
    let filesDeleted = 0;

    // 1. Migrate config.json
    const oldConfigPath = path.join(this.originalDataPath, 'UsernameLogger', 'config.json');
    const newConfigPath = path.join(this.pluginStoragePath, 'config.json');
    if (await this._moveFile(oldConfigPath, newConfigPath)) {
      filesMigrated++;
    }

    // 2. Define old file locations (in root /data and potentially a custom output dir)
    const fileNamesToMigrate = [
      COLLECTED_USERNAMES_FILE,
      PROCESSED_FILE,
      FOUND_GENERAL_FILE,
      FOUND_AJC_FILE,
      POTENTIAL_ACCOUNTS_FILE
    ];

    const customOutputDir = this.application.settings.get('plugins.usernameLogger.outputDir');

    // 3. Migrate .txt files from the root /data folder
    for (const fileName of fileNamesToMigrate) {
      const oldPath = path.join(this.originalDataPath, fileName);
      const newPath = path.join(this.pluginStoragePath, fileName);
      if (await this._moveFile(oldPath, newPath)) {
        filesMigrated++;
      }
    }

    // 4. Migrate .txt files from a custom output directory if it was set
    if (customOutputDir && customOutputDir.trim() !== '' && customOutputDir !== this.pluginStoragePath) {
      for (const fileName of fileNamesToMigrate) {
        const oldPath = path.join(customOutputDir, fileName);
        const newPath = path.join(this.pluginStoragePath, fileName);
        if (await this._moveFile(oldPath, newPath)) {
          filesMigrated++;
        }
      }
    }

    // 5. Delete deprecated working_accounts.txt from all possible old locations
    const deprecatedFile = 'working_accounts.txt';
    const oldPathInData = path.join(this.originalDataPath, deprecatedFile);
    if (await this._deleteFile(oldPathInData)) {
      filesDeleted++;
    }
    if (customOutputDir && customOutputDir.trim() !== '') {
      const oldPathInCustom = path.join(customOutputDir, deprecatedFile);
      if (await this._deleteFile(oldPathInCustom)) {
        filesDeleted++;
      }
    }

    // 6. Clean up old empty directory
    const oldPluginDir = path.join(this.originalDataPath, 'UsernameLogger');
    await this._cleanupDirectory(oldPluginDir);

    // 7. Clean up the root /data directory if it's now empty
    await this._cleanupDirectory(this.originalDataPath);

    if (filesMigrated > 0) {
      this.application.consoleMessage({ type: 'success', message: `[Username Logger] Successfully migrated ${filesMigrated} file(s) to the new centralized directory.` });
    }
    if (filesDeleted > 0) {
      this.application.consoleMessage({ type: 'warn', message: `[Username Logger] Deleted ${filesDeleted} deprecated file(s).` });
    }

    // 8. Mark migration as complete in the config
    this.configModel.setMigrationV2Status(true);
    await this.configModel.saveConfig();
  }

  /**
   * Moves a file from an old path to a new path. If the new path already exists, it appends the content.
   * @param {string} oldPath - The source file path.
   * @param {string} newPath - The destination file path.
   * @returns {Promise<boolean>} True if a file was moved or merged.
   * @private
   */
  async _moveFile(oldPath, newPath) {
    try {
      if (await this.fileService.fileExists(oldPath)) {
        const oldContent = await fs.readFile(oldPath, 'utf8');
        // Append to the new file if it exists, otherwise create it.
        await fs.appendFile(newPath, oldContent);
        await fs.unlink(oldPath); // Delete the old file
        if (this.isDevMode) {
          this.application.consoleMessage({ type: 'logger', message: `[Username Logger] Migrated and removed: ${oldPath}` });
        }
        return true;
      }
    } catch (error) {
      this.application.consoleMessage({ type: 'error', message: `[Username Logger] Could not migrate ${path.basename(oldPath)}: ${error.message}` });
    }
    return false;
  }

  /**
   * Deletes a file if it exists.
   * @param {string} filePath - The path to the file to delete.
   * @returns {Promise<boolean>} True if a file was deleted.
   * @private
   */
  async _deleteFile(filePath) {
    try {
      if (await this.fileService.fileExists(filePath)) {
        await fs.unlink(filePath);
        if (this.isDevMode) {
          this.application.consoleMessage({ type: 'logger', message: `[Username Logger] Deleted deprecated file: ${filePath}` });
        }
        return true;
      }
    } catch (error) {
      this.application.consoleMessage({ type: 'error', message: `[Username Logger] Could not delete ${path.basename(filePath)}: ${error.message}` });
    }
    return false;
  }

  /**
   * Deletes a directory if it is empty.
   * @param {string} dirPath - The path to the directory to clean up.
   * @private
   */
  async _cleanupDirectory(dirPath) {
    try {
      if (await this.fileService.fileExists(dirPath)) {
        const files = await fs.readdir(dirPath);
        if (files.length === 0) {
          await fs.rmdir(dirPath);
          if (this.isDevMode) {
            this.application.consoleMessage({ type: 'logger', message: `[Username Logger] Removed empty directory: ${dirPath}` });
          }
        }
      }
    } catch (error) {
      // It's okay if this fails, not critical.
      if (this.isDevMode) {
        this.application.consoleMessage({ type: 'warn', message: `[Username Logger] Could not clean up directory ${dirPath}: ${error.message}` });
      }
    }
  }

  /**
   * Loads the ignore list from processed usernames file and collected usernames.
   * This now uses the centralized plugin storage path.
   * @param {Object} stateModel - The state model to populate.
   * @returns {Promise<boolean>} True if successful.
   */
  async loadIgnoreList(stateModel) {
    try {
      const paths = getFilePaths(this.pluginStoragePath);
      let loadedCount = 0;
      let collectedCount = 0;
      let addedFromAccounts = 0;

      // Load from processed_usernames.txt
      if (await this.fileService.fileExists(paths.processedUsernamesPath)) {
        const processedUsernames = await this.fileService.readLinesFromFile(paths.processedUsernamesPath);
        for (const username of processedUsernames) {
          if (username && stateModel.addIgnoredUsername(username)) {
            loadedCount++;
          }
        }
      }

      // Load from collected_usernames.txt
      if (await this.fileService.fileExists(paths.collectedUsernamesPath)) {
        const collectedUsernames = await this.fileService.readUsernamesFromLog(paths.collectedUsernamesPath);
        for (const username of collectedUsernames) {
          if (username && stateModel.addIgnoredUsername(username)) {
            collectedCount++;
          }
        }
      }

      // Load from potential_accounts.txt
      if (await this.fileService.fileExists(paths.potentialAccountsPath)) {
        const potentialAccounts = await this.fileService.readLinesFromFile(paths.potentialAccountsPath);
        for (const username of potentialAccounts) {
          if (username && stateModel.addIgnoredUsername(username)) {
            addedFromAccounts++;
          }
        }
      }

      const totalIgnored = loadedCount + collectedCount + addedFromAccounts;
      return true;
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Error loading ignore list: ${error.message}`
      });
      return false;
    }
  }
}

module.exports = MigrationService;
