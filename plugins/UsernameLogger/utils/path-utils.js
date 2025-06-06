/**
 * @file path-utils.js - Path management utilities for Username Logger
 * @author glvckoma
 */

const path = require('path');
const os = require('os');
const fs = require('fs');
const { 
  COLLECTED_USERNAMES_FILE,
  POTENTIAL_ACCOUNTS_FILE,
  PROCESSED_FILE,
  FOUND_GENERAL_FILE,
  FOUND_AJC_FILE,
  WORKING_ACCOUNTS_FILE
} = require('../constants/constants');

/**
 * Determines the base path for Username Logger specific files.
 * This should be the application's main data path (already including /data).
 * @param {string} appDataPath - The application's main data path (e.g., .../strawberry-jam/data).
 * @returns {string} The base path for Username Logger files.
 */
function getBasePath(appDataPath) {
  // The provided appDataPath should already point to the desired /data directory.
  if (!appDataPath) {
    console.error("[Username Logger] Error: getBasePath called without appDataPath!");
    return path.resolve('.', 'username_logger_data_error'); 
  }
  // Removed creation of 'UsernameLogger' subdirectory and ensureDirectoryExists call.
  // Files will be created directly in the provided appDataPath.
  return appDataPath;
}

/**
 * Gets file paths based on the provided application data path.
 * @param {string} appDataPath - The application's main data path (e.g., .../strawberry-jam/data).
 * @param {string} [leakCheckOutputDirPath] - Optional custom output directory for leak check results.
 * @returns {Object} An object containing file paths.
 */
function getFilePaths(appDataPath, leakCheckOutputDirPath) {
  const inputFilesBasePath = getBasePath(appDataPath); // For collected/processed files
  
  let outputFilesBasePath = inputFilesBasePath; // Default output to same as input
  if (leakCheckOutputDirPath && typeof leakCheckOutputDirPath === 'string' && leakCheckOutputDirPath.trim() !== '') {
    // If a custom output path is provided and valid, use it.
    // Ensure this directory exists before trying to use it.
    // Note: ensureDirectoryExists is synchronous, consider async if called in async context elsewhere.
    if (ensureDirectoryExists(leakCheckOutputDirPath)) {
      outputFilesBasePath = leakCheckOutputDirPath;
    } else {
      console.warn(`[Username Logger] Custom leak check output directory '${leakCheckOutputDirPath}' could not be ensured. Falling back to default.`);
    }
  }

  const paths = {
    collectedUsernamesPath: path.join(inputFilesBasePath, COLLECTED_USERNAMES_FILE),
    processedUsernamesPath: path.join(inputFilesBasePath, PROCESSED_FILE),
    // Output files use the potentially custom outputFilesBasePath
    potentialAccountsPath: path.join(outputFilesBasePath, POTENTIAL_ACCOUNTS_FILE),
    foundAccountsPath: path.join(outputFilesBasePath, FOUND_GENERAL_FILE),
    ajcAccountsPath: path.join(outputFilesBasePath, FOUND_AJC_FILE),
    workingAccountsPath: path.join(outputFilesBasePath, WORKING_ACCOUNTS_FILE)
  };
  
  return paths;
}

/**
 * Ensures a directory exists, creating it if necessary.
 * @param {string} dirPath - The path to check/create
 * @returns {boolean} True if directory exists or was created, false if creation failed
 */
function ensureDirectoryExists(dirPath) {
  try {
    if (!fs.existsSync(dirPath)) {
      fs.mkdirSync(dirPath, { recursive: true });
    }
    return true;
  } catch (error) {
    console.error(`[Username Logger] Error creating directory ${dirPath}: ${error.message}`);
    return false;
  }
}

module.exports = {
  getBasePath,
  getFilePaths,
  ensureDirectoryExists
};
