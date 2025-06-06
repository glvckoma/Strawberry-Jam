/**
 * @file batch-logger.js - Handles batched logging to the console
 * @author glvckoma
 */

const { DEFAULT_LOG_BATCH_INTERVAL } = require('../constants/constants');

/**
 * BatchLogger class for handling batched log messages
 */
class BatchLogger {
  /**
   * Creates a new BatchLogger instance
   * @param {Object} options - Logger options
   * @param {Object} options.application - The application object for logging
   * @param {number} [options.batchInterval=5000] - Interval in ms to flush logs
   */
  constructor({ application, batchInterval = DEFAULT_LOG_BATCH_INTERVAL }) {
    this.application = application;
    this.batchInterval = batchInterval;
    
    // Storage for pending log messages
    this._pendingBuddyLog = [];
    this._pendingNearbyLog = [];
    this._logBatchTimerId = null;
    
    // Bind methods
    this.logUsername = this.logUsername.bind(this);
    this._flushLogBatches = this._flushLogBatches.bind(this);
    this.forceFlush = this.forceFlush.bind(this);
  }
  
  /**
   * Adds a username to the appropriate batch log
   * @param {string} username - The username to log
   * @param {string} source - The source ('buddy' or 'nearby')
   */
  logUsername(username, source) {
    // Add to pending batch for the appropriate source
    if (source === 'buddy') {
      this._pendingBuddyLog.push(username);
    } else if (source === 'nearby') {
      this._pendingNearbyLog.push(username);
    }
    
    // Set up batch timer if not already running
    if (!this._logBatchTimerId) {
      this._logBatchTimerId = setTimeout(() => this._flushLogBatches(), this.batchInterval);
    }
  }
  
  /**
   * Flushes batched log messages to the console
   * @private
   */
  _flushLogBatches() {
    // Clear the timer
    this._logBatchTimerId = null;
    
    // Log buddy batches if any
    if (this._pendingBuddyLog.length > 0) {
      const buddyCount = this._pendingBuddyLog.length;
      let message;
      
      // Show individual names only if there are 5 or fewer
      if (buddyCount <= 5) {
        message = `[Username Logger] Logged ${buddyCount} buddy${buddyCount > 1 ? 's' : ''}: ${this._pendingBuddyLog.join(', ')}`;
      } else {
        message = `[Username Logger] Logged ${buddyCount} buddies`;
      }
      
      this.application.consoleMessage({
        type: 'success',
        message
      });
      
      // Clear the batch
      this._pendingBuddyLog = [];
    }
    
    // Log nearby batches if any
    if (this._pendingNearbyLog.length > 0) {
      const nearbyCount = this._pendingNearbyLog.length;
      let message;
      
      // Show individual names only if there are 5 or fewer
      if (nearbyCount <= 5) {
        message = `[Username Logger] Logged ${nearbyCount} nearby player${nearbyCount > 1 ? 's' : ''}: ${this._pendingNearbyLog.join(', ')}`;
      } else {
        message = `[Username Logger] Logged ${nearbyCount} nearby players`;
      }
      
      this.application.consoleMessage({
        type: 'success',
        message
      });
      
      // Clear the batch
      this._pendingNearbyLog = [];
    }
  }
  
  /**
   * Forces an immediate flush of all batched logs
   */
  forceFlush() {
    if (this._logBatchTimerId) {
      clearTimeout(this._logBatchTimerId);
      this._flushLogBatches();
    }
  }
  
  /**
   * Clean up resources when unloading
   */
  unload() {
    if (this._logBatchTimerId) {
      clearTimeout(this._logBatchTimerId);
      this._flushLogBatches();
    }
  }
}

module.exports = BatchLogger;
