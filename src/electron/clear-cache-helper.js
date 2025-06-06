const fs = require('fs').promises;
const path = require('path');
const { spawn } = require('child_process'); // Added spawn for relaunch

// --- Configuration ---
const initialDelayMs = 2000; // Wait 2 seconds for the main app to close before deleting
const relaunchDelayMs = 7000; // Wait 7 seconds after deletion before relaunching (Increased delay)

// --- Argument Parsing ---
let pathsToDelete = [];
let shouldRelaunch = false;
let appExePath = null;

for (let i = 2; i < process.argv.length; i++) {
  if (process.argv[i] === '--relaunch-after-clear') {
    shouldRelaunch = true;
    // The next argument should be the executable path
    if (i + 1 < process.argv.length) {
      appExePath = process.argv[i + 1];
      i++; // Skip the next argument since we consumed it
    } else {
      console.warn('[Cache Helper] --relaunch-after-clear flag found but no executable path provided.');
    }
  } else {
    // Assume it's a path to delete
    pathsToDelete.push(process.argv[i]);
  }
}

console.log(`[Cache Helper] Started. Initial Wait: ${initialDelayMs}ms. Relaunch: ${shouldRelaunch}. App Path: ${appExePath || 'N/A'}. Paths to delete:`, pathsToDelete);

setTimeout(async () => {
  console.log('[Cache Helper] Attempting cache deletion...');
  let errors = [];

  for (const cachePath of pathsToDelete) {
    if (!cachePath || typeof cachePath !== 'string' || cachePath.trim() === '') {
        console.warn('[Cache Helper] Invalid or empty path received, skipping.');
        continue;
    }
    try {
      console.log(`[Cache Helper] Deleting: ${cachePath}`);
      await fs.rm(cachePath, { recursive: true, force: true, maxRetries: 3, retryDelay: 500 });
      console.log(`[Cache Helper] Successfully deleted: ${cachePath}`);
    } catch (error) {
      if (error.code === 'ENOENT') {
        console.log(`[Cache Helper] Path not found, skipping: ${cachePath}`);
      } else {
        console.error(`[Cache Helper] Failed to delete ${cachePath}:`, error);
        errors.push(`Failed to delete ${path.basename(cachePath)}: ${error.message}`);
      }
    }
  }

  if (errors.length > 0) {
    console.error('[Cache Helper] Finished with errors:', errors.join('; '));
    // In a real scenario, might write to a log file here
    process.exit(1); // Exit with error code
  } else {
    console.log('[Cache Helper] Cache clearing process completed successfully.');

    // --- Relaunch Logic ---
    if (shouldRelaunch && appExePath) {
      console.log(`[Cache Helper] Relaunch requested. Waiting ${relaunchDelayMs}ms before relaunching ${appExePath}...`);
      setTimeout(() => {
        try {
          console.log(`[Cache Helper] Relaunching application: ${appExePath}`);
          const child = spawn(appExePath, [], {
            detached: true,
            stdio: 'ignore'
          });
          child.on('error', (err) => { console.error('[Cache Helper] Failed to relaunch application:', err); });
          child.unref();
          console.log('[Cache Helper] Relaunch process spawned. Exiting helper.');
          process.exit(0); // Exit successfully after spawning relaunch
        } catch (relaunchError) {
          console.error('[Cache Helper] Error during relaunch attempt:', relaunchError);
          process.exit(1); // Exit with error if relaunch spawn fails
        }
      }, relaunchDelayMs);
      // Keep the helper alive until the relaunch timeout completes
    } else {
      if (shouldRelaunch && !appExePath) {
        console.warn('[Cache Helper] Relaunch was requested but executable path was missing. Cannot relaunch.');
      }
      console.log('[Cache Helper] Exiting helper script (no relaunch).');
      process.exit(0); // Exit successfully if no relaunch needed
    }
    // --- End Relaunch Logic ---
  }

}, initialDelayMs);
