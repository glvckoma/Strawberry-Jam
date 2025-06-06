/**
 * @file constants.js - Shared constants for the Username Logger plugin
 * @author glvckoma
 */

// API Constants
const LEAK_CHECK_API_URL = 'https://leakcheck.io/api/v2/query';
const DEFAULT_RATE_LIMIT_DELAY = 400; // Milliseconds

// File names
const COLLECTED_USERNAMES_FILE = 'collected_usernames.txt';
const POTENTIAL_ACCOUNTS_FILE = 'potential_accounts.txt';
const PROCESSED_FILE = 'processed_usernames.txt';
const FOUND_GENERAL_FILE = 'found_accounts.txt';
const FOUND_AJC_FILE = 'ajc_accounts.txt';
const WORKING_ACCOUNTS_FILE = 'working_accounts.txt';

// Batch logging settings
const DEFAULT_LOG_BATCH_INTERVAL = 5000; // How often to display batched logs (5 seconds)
const DEFAULT_BATCH_SIZE = 100; // Write to files every 100 processed usernames

// Default configuration
const DEFAULT_CONFIG = {
  // All settings formerly here (isLoggingEnabled, collectNearbyPlayers,
  // collectBuddies, autoLeakCheck, autoLeakCheckThreshold)
  // are now managed by the main application's settings store.
  // This object is kept for potential future plugin-specific, non-UI-driven defaults.
};

module.exports = {
  // API Constants
  LEAK_CHECK_API_URL,
  DEFAULT_RATE_LIMIT_DELAY,
  
  // File names
  COLLECTED_USERNAMES_FILE,
  POTENTIAL_ACCOUNTS_FILE,
  PROCESSED_FILE,
  FOUND_GENERAL_FILE,
  FOUND_AJC_FILE,
  WORKING_ACCOUNTS_FILE,
  
  // Logging settings
  DEFAULT_LOG_BATCH_INTERVAL,
  DEFAULT_BATCH_SIZE,
  
  // Default configuration
  DEFAULT_CONFIG
};
