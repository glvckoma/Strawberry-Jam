// State variables for the Account Tester
"use strict";

// Encapsulate state in an object to be imported by other modules
const testerState = {
  accounts: [],
  currentIndex: -1,
  isTesting: false, // Indicates if the main test loop is actively running/paused
  shouldStop: false, // Flag to signal the loop to stop gracefully
  pausedState: 'none', // 'none', 'otp', 'ratelimit', 'forbidden', 'generic-error'
  lastFilePath: null, // Path to the last loaded accounts file
  saveFilePath: null, // Path to the user-selected save file for 'works' accounts
  interTestDelay: 1000, // Delay between testing individual accounts (ms)
  retryDelay: 10000, // Delay before retrying after a 503 error (ms)
  retryAttempts: new Map(), // Map<index, count> to track retry attempts per account index for 503s
  MAX_RETRY_ATTEMPTS: 3, // Maximum retry attempts for 503 errors
  ESTIMATED_ITEM_HEIGHT: 29, // Estimated height for list virtualization
  renderRequestId: null, // ID for debouncing scroll rendering via requestAnimationFrame
  messageClearTimeoutId: null, // Timeout ID for auto-clearing the tester status message
  debugLoggingEnabled: false, // Flag to enable/disable detailed console logging
  actualLoginEnabled: false, // Flag to enable full login instead of just credential check
  disableDevToolsEnabled: false, // Flag to disable dev console on start
  saveScrollTimeoutId: null, // Timeout ID for debouncing scroll position saving
  saveFilterTimeoutId: null, // Timeout ID for debouncing filter query saving
  currentFilterQuery: '', // Current filter string applied to the account list
  // REMOVED: isTestingActualLogin: false, // Flag is no longer needed

  // --- Potentially add methods here later if needed for complex state updates ---
  // e.g., resetRetryAttempts()
};

// Make the state object available for import
// Note: Direct export allows modification from importing modules.
// Consider using functions for controlled updates if needed later.
export { testerState };
