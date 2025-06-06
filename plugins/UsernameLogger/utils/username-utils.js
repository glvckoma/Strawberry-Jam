/**
 * @file username-utils.js - Username processing utilities
 * @author glvckoma
 */

/**
 * Creates a promise that resolves after a specified delay
 * @param {number} ms - The number of milliseconds to wait
 * @returns {Promise<void>} A promise that resolves after the specified delay
 */
function wait(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Checks if a username should be ignored based on ignore list
 * @param {string} username - The username to check
 * @param {Set<string>} ignoredUsernames - Set of usernames to ignore
 * @param {Set<string>} loggedUsernamesThisSession - Set of usernames already logged this session
 * @returns {boolean} True if the username should be ignored, false otherwise
 */
function shouldIgnoreUsername(username, ignoredUsernames, loggedUsernamesThisSession) {
  if (!username) return true;
  
  const usernameLower = username.toLowerCase();
  return ignoredUsernames.has(usernameLower) || loggedUsernamesThisSession.has(usernameLower);
}

/**
 * Extracts timestamp from a log entry
 * @param {string} line - The log line
 * @returns {string|null} The timestamp or null if not found
 */
function extractTimestampFromLogLine(line) {
  const match = line.match(/^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z) - .+$/);
  return match ? match[1] : null;
}

/**
 * Extracts username from a log entry
 * @param {string} line - The log line
 * @returns {string|null} The username or null if not found
 */
function extractUsernameFromLogLine(line) {
  const match = line.match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z - (.+)$/);
  
  if (match && match[1]) {
    return match[1].trim();
  } else if (line.trim() && !line.trim().startsWith('---')) {
    return line.trim();
  }
  
  return null;
}

/**
 * Creates a log entry with timestamp for a username
 * @param {string} username - The username to log
 * @returns {string} A formatted log entry with timestamp
 */
function createLogEntry(username) {
  const timestamp = new Date().toISOString();
  return `${timestamp} - ${username}\n`;
}

/**
 * Validates whether a username is in proper format for API queries
 * @param {string} username - The username to validate
 * @returns {boolean} True if the username is valid
 */
function isValidUsername(username) {
  // Check for basic requirements
  if (!username || typeof username !== 'string' || username.trim() === '') {
    return false;
  }
  
  // Check for invalid characters (simplified check)
  const invalidCharRegex = /[^\w\d_\-. ]/;
  return !invalidCharRegex.test(username);
}

module.exports = {
  wait,
  shouldIgnoreUsername,
  extractTimestampFromLogLine,
  extractUsernameFromLogLine,
  createLogEntry,
  isValidUsername
};
