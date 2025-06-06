# Background Processing for Plugins

This document provides information on how to create plugins that continue running even when the application is minimized or running in the background.

## Overview

Strawberry Jam now supports background processing for plugins, allowing critical operations to continue even when the application window is minimized, in the background, or the screen is locked. This is particularly useful for:

- Advertising and messaging plugins
- Data collection plugins
- Automation plugins that need to run continuously
- Network monitoring plugins

## How to Enable Background Processing

### 1. Add the Background Processing Flag

To enable background processing for your plugin, add the `runInBackground` flag to your `plugin.json` file:

```json
{
  "name": "YourPluginName",
  "main": "index.js",
  "description": "Your plugin description",
  "author": "Your Name",
  "type": "game",
  "dependencies": {},
  "runInBackground": true
}
```

The `runInBackground` flag tells the Strawberry Jam application that your plugin should continue running at full capacity even when the application is minimized.

### 2. Listen for Background Mode Events

Your plugin can detect when the application is running in the background by:

1. Checking the `window.jam.isAppMinimized` flag
2. Listening for background mode events

```javascript
// Listen for background mode
window.addEventListener('jam-background-tick', (event) => {
  // This event fires approximately once per second when the app is minimized
  // event.detail.timestamp contains the current timestamp
  console.log('App is running in background mode:', event.detail.timestamp);
  
  // Perform background tasks here
});

// Listen for when the app returns to the foreground
window.addEventListener('jam-foreground', (event) => {
  console.log('App has returned to foreground:', event.detail.timestamp);
  
  // Update UI or perform foreground-specific tasks
});
```

### 3. Optimize for Background Mode

When running in background mode, you should:

- Minimize UI updates (they're not visible anyway)
- Focus on the core functionality needed while in background
- Consider reducing the frequency of non-critical operations

```javascript
function performOperation() {
  // Get minimized state
  const isMinimized = window.jam && window.jam.isAppMinimized;
  
  if (isMinimized) {
    // In background mode, only do critical operations
    performCriticalTasks();
  } else {
    // In foreground mode, do everything including UI updates
    performCriticalTasks();
    updateUserInterface();
  }
  
  // Schedule next operation with appropriate frequency
  const delay = isMinimized ? 5000 : 1000; // Less frequent in background
  setTimeout(performOperation, delay);
}

// Start the operation loop
performOperation();
```

## Example: Background Advertising Plugin

Here's a complete example of a plugin that continues sending advertisements while in the background:

```javascript
// Wait for the dispatch system to be ready
waitForDispatch(function(dispatch) {
  
  // Plugin configuration
  const config = {
    enabled: true,
    interval: 30000, // 30 seconds between ads
    messages: [
      "Join my den for a party!",
      "Trading rare items at my den!",
      "Free items at my den!",
      "Come check out my den!"
    ]
  };
  
  let currentIndex = 0;
  let advertisingInterval = null;
  
  // Function to send an advertisement
  function sendAdvertisement() {
    if (!config.enabled) return;
    
    // Only log if we're not minimized to reduce console spam
    if (!(window.jam && window.jam.isAppMinimized)) {
      console.log("Sending advertisement...");
    }
    
    const message = config.messages[currentIndex];
    
    // Send the message using the dispatch system
    dispatch.sendRemoteMessage(`<message>${message}</message>`);
    
    // Move to the next message
    currentIndex = (currentIndex + 1) % config.messages.length;
  }
  
  // Start the advertising interval
  function startAdvertising() {
    if (advertisingInterval) {
      clearInterval(advertisingInterval);
    }
    
    advertisingInterval = setInterval(sendAdvertisement, config.interval);
    console.log("Advertising started");
  }
  
  // Stop the advertising interval
  function stopAdvertising() {
    if (advertisingInterval) {
      clearInterval(advertisingInterval);
      advertisingInterval = null;
      console.log("Advertising stopped");
    }
  }
  
  // Set up UI
  const enableButton = document.getElementById("enable-advertising");
  if (enableButton) {
    enableButton.addEventListener("click", function() {
      config.enabled = !config.enabled;
      
      if (config.enabled) {
        startAdvertising();
        enableButton.textContent = "Disable Advertising";
      } else {
        stopAdvertising();
        enableButton.textContent = "Enable Advertising";
      }
    });
  }
  
  // Start advertising automatically if enabled
  if (config.enabled) {
    startAdvertising();
  }
  
  // Listen for background mode events
  window.addEventListener('jam-background-tick', (event) => {
    // Every 10 seconds, log that we're still running (to reduce spam)
    if (event.detail.timestamp % 10000 < 1000) {
      console.log('Advertiser running in background mode');
    }
  });
  
  // When the plugin window closes, clean up
  window.addEventListener('unload', function() {
    stopAdvertising();
  });
});

// Note on Logging:
// Strawberry Jam 3.0.0 features an improved logging system.
// When developing plugins, especially those with background tasks,
// you can use `window.jam.logManager.debug('Your log message')`, 
// `window.jam.logManager.warn(...)`, or `window.jam.logManager.error(...)` 
// for consistent logging. These logs can be helpful for debugging 
// and are included in the "Report a Problem" feature.
```

## Technical Details

When a plugin with `runInBackground: true` is loaded:

1. The Electron window is created with `backgroundThrottling: false`
2. When the main app window is minimized:
   - All plugin windows are notified with the `window.jam.isAppMinimized = true` flag
   - Background plugins receive additional optimizations to ensure they continue running
   - A 1000ms interval is established to keep the JavaScript engine active
3. When the main app window is restored:
   - All plugin windows are updated with `window.jam.isAppMinimized = false`
   - The 'jam-foreground' event is dispatched

## Limitations

- Background processing still consumes system resources
- The operating system may still impose some limitations on background applications
- Very intensive operations may be throttled by the operating system regardless of these settings
- On some systems, screen locking or sleep mode may still affect background processing
