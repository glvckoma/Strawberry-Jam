/**
 * @file state-model.js - Manages plugin state for Username Logger
 * @author glvckoma
 */

/**
 * Manages the runtime state of the plugin, particularly for leak checking
 */
class StateModel {
  /**
   * Creates a new state model
   * @param {Object} options - State options
   * @param {Object} options.application - The application object for logging
   */
  constructor({ application }) {
    this.application = application;
    
    // Leak Check State
    this.isLeakCheckRunning = false;  // Whether a leak check is currently running
    this.isLeakCheckPaused = false;   // Whether the leak check is paused
    this.isLeakCheckStopped = false;  // Whether the leak check should stop
    this.leakCheckTotalProcessed = 0; // Number of usernames processed in current run
    
    // Storage
    this.ignoredUsernames = new Set();        // Usernames to ignore
    this.loggedUsernamesThisSession = new Set(); // All usernames logged in this session
    
    // Cache for HTTP client
    this._cachedAxios = null;
  }
  
  /**
   * Resets leak check state after completion, stop, or error
   */
  resetLeakCheckState() {
    this.isLeakCheckRunning = false;
    this.isLeakCheckPaused = false;
    this.isLeakCheckStopped = false;
    this.leakCheckTotalProcessed = 0;
    this._cachedAxios = null; // Clear cached axios instance
  }
  
  /**
   * Pauses the leak check process
   * @returns {boolean} True if state changed, false if already paused or not running
   */
  pauseLeakCheck() {
    if (!this.isLeakCheckRunning) {
      return false;
    }
    
    this.isLeakCheckPaused = true;
    return true;
  }
  
  /**
   * Stops the leak check process
   * @returns {boolean} True if state changed, false if already stopped or not running
   */
  stopLeakCheck() {
    if (!this.isLeakCheckRunning) {
      return false;
    }
    
    this.isLeakCheckStopped = true;
    return true;
  }
  
  /**
   * Starts the leak check process
   * @returns {boolean} True if state changed, false if already running
   */
  startLeakCheck() {
    if (this.isLeakCheckRunning) {
      return false;
    }
    
    this.isLeakCheckRunning = true;
    this.isLeakCheckPaused = false;
    this.isLeakCheckStopped = false;
    this.leakCheckTotalProcessed = 0;
    return true;
  }
  
  /**
   * Gets the current leak check state
   * @returns {Object} The current leak check state
   */
  getLeakCheckState() {
    return {
      isRunning: this.isLeakCheckRunning,
      isPaused: this.isLeakCheckPaused,
      isStopped: this.isLeakCheckStopped,
      totalProcessed: this.leakCheckTotalProcessed
    };
  }
  
  /**
   * Adds a username to the ignore list
   * @param {string} username - Username to add
   * @returns {boolean} True if username was added, false if already exists
   */
  addIgnoredUsername(username) {
    if (!username) return false;
    
    const usernameLower = username.toLowerCase();
    if (this.ignoredUsernames.has(usernameLower)) {
      return false;
    }
    
    this.ignoredUsernames.add(usernameLower);
    return true;
  }
  
  /**
   * Marks a username as logged this session
   * @param {string} username - Username to mark
   * @returns {boolean} True if username was added, false if already exists
   */
  markUsernameLogged(username) {
    if (!username) return false;
    
    const usernameLower = username.toLowerCase();
    if (this.loggedUsernamesThisSession.has(usernameLower)) {
      return false;
    }
    
    this.loggedUsernamesThisSession.add(usernameLower);
    return true;
  }
  
  /**
   * Checks if a username is ignored
   * @param {string} username - Username to check
   * @returns {boolean} True if username is ignored
   */
  isUsernameIgnored(username) {
    if (!username) return false;
    return this.ignoredUsernames.has(username.toLowerCase());
  }
  
  /**
   * Checks if a username has been logged this session
   * @param {string} username - Username to check
   * @returns {boolean} True if username has been logged
   */
  isUsernameLoggedThisSession(username) {
    if (!username) return false;
    return this.loggedUsernamesThisSession.has(username.toLowerCase());
  }
  
  /**
   * Gets the current ignored usernames count
   * @returns {number} Number of ignored usernames
   */
  getIgnoredUsernamesCount() {
    return this.ignoredUsernames.size;
  }
  
  /**
   * Gets the current logged usernames count for this session
   * @returns {number} Number of usernames logged this session
   */
  getLoggedUsernamesCount() {
    return this.loggedUsernamesThisSession.size;
  }
  
  /**
   * Clears all logged usernames for this session
   */
  clearLoggedUsernames() {
    this.loggedUsernamesThisSession.clear();
  }
  
  /**
   * Loads ignored usernames from an array
   * @param {Array<string>} usernames - Array of usernames to add to ignore list
   */
  loadIgnoredUsernames(usernames) {
    if (!Array.isArray(usernames)) return;
    
    usernames.forEach(username => {
      if (username && typeof username === 'string') {
        this.ignoredUsernames.add(username.toLowerCase());
      }
    });
  }
  
  /**
   * Sets HTTP client for API requests
   * @param {Object} client - The HTTP client instance 
   */
  setHttpClient(client) {
    this._cachedAxios = client;
  }
  
  /**
   * Gets the cached HTTP client
   * @returns {Object|null} The HTTP client or null if not set
   */
  getHttpClient() {
    return this._cachedAxios;
  }
}

module.exports = StateModel;
