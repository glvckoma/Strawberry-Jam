/**
 * @file leak-check-service.js - Service for checking usernames against leak databases
 * @author glvckoma
 */

const { DEFAULT_BATCH_SIZE, DEFAULT_RATE_LIMIT_DELAY } = require('../constants/constants');
const { getFilePaths } = require('../utils/path-utils');

/**
 * Service for handling leak checking operations
 */
class LeakCheckService {
  /**
   * Creates a new leak check service
   * @param {Object} options - Service options
   * @param {Object} options.application - The application object for logging
   * @param {Object} options.fileService - The file service for file operations
   * @param {Object} options.apiService - The API service for API operations
   * @param {Object} options.configModel - The config model for accessing configuration
   * @param {Object} options.stateModel - The state model for managing state
   * @param {string} options.dataPath - The application data path
   */
  constructor({ application, fileService, apiService, configModel, stateModel, dataPath }) {
    this.application = application;
    this.fileService = fileService;
    this.apiService = apiService;
    this.configModel = configModel;
    this.stateModel = stateModel;
    this.dataPath = dataPath;
  }

  /**
   * Detect whether we're in development mode - more reliable than process.env.NODE_ENV
   * @returns {boolean} true if in development mode
   * @private
   */
  _isDevMode() {
    try {
      // In packaged apps, app.asar will be in the path
      return !window.location.href.includes('app.asar');
    } catch (e) {
      return false;
    }
  }

  /**
   * Runs a leak check on collected usernames
   * @param {Object} options - Options for the leak check
   * @param {number} [options.limit=Infinity] - Maximum number of usernames to process
   * @param {number} [options.startIndex] - The index to start processing from
   * @param {Function} [options.onProgress] - Progress callback
   * @returns {Promise<Object>} Results summary
   */
  async runLeakCheck(options = {}) {
    try {
      // Use a more reliable way to check for development mode
      const isDevMode = this._isDevMode();
      
      // Default options
      const limit = options.limit || Infinity;
      const startIndex = options.startIndex || (this.configModel.getLeakCheckIndex() + 1);
      const onProgress = options.onProgress || null;
      
      // For debugging
      if (isDevMode) {
        this.application.consoleMessage({
          type: 'logger',
          message: `[Username Logger] runLeakCheck called with options: ${JSON.stringify(options)}`
        });
      }

      // Prevent multiple instances from running
      if (!this.stateModel.startLeakCheck()) {
        this.application.consoleMessage({
          type: 'warn',
          message: `Username check is already running. Use !leakcheckstop to stop.`
        });
        return { success: false, error: 'Already running' };
      }

      try {
        // Get API key
        const apiKey = await this.apiService.getApiKey();

        // Log the retrieved key type and value (masked) in dev mode BEFORE the check
        if (isDevMode) {
          this.application.consoleMessage({
            type: 'logger',
            message: `[Username Logger] API key retrieved in runLeakCheck: Type=${typeof apiKey}, Value=${apiKey === null ? 'null' : (typeof apiKey === 'string' ? (apiKey.length > 8 ? apiKey.substring(0, 4) + '...' + apiKey.substring(apiKey.length - 4) : '********') : '[Non-string/null]')}`
          });
        }

        // Explicitly check for null, undefined, non-string, or empty/blank string
        // Note: The check `typeof apiKey !== 'string'` implicitly covers objects.
        if (!apiKey || typeof apiKey !== 'string' || apiKey.trim() === '') {
            // Log the single, user-friendly error message
            this.application.consoleMessage({
                type: 'error',
                message: `[Username Logger] Cannot start leak check: API key is missing or blank. Please set your LeakCheck.io API key in the plugin settings or use the command: !setapikey YOUR_API_KEY`
            });
            // Ensure state is reset and return immediately
            this.stateModel.resetLeakCheckState();
            return { success: false, error: 'API key missing or blank', needsApiKey: true };
        }

        // --- START API Key Validation ---
        if (isDevMode) {
          this.application.consoleMessage({ type: 'logger', message: '[Username Logger] Performing pre-check API key validation...' });
        }
        const validationResult = await this.apiService.validateApiKey(apiKey);

        if (!validationResult.valid) {
          let userMessage = '[Username Logger] Leak check aborted due to an API key issue.';
          if (validationResult.reason === 'invalid_key') {
            userMessage = '[Username Logger] API Key is invalid or requires a Pro subscription. Please verify your key in settings. Leak check aborted.';
          } else if (validationResult.reason === 'api_error') {
            userMessage = '[Username Logger] Could not validate API key due to an API error. Please try again later. Leak check aborted.';
            // Log the specific error in dev mode
            if (isDevMode && validationResult.error) {
              this.application.consoleMessage({ type: 'error', message: `[Username Logger] API validation error details: ${validationResult.error.message}` });
            }
          }

          this.application.consoleMessage({ type: 'error', message: userMessage });
          this.stateModel.resetLeakCheckState();
          return { success: false, error: 'API key validation failed', validationReason: validationResult.reason };
        }

        if (isDevMode) {
           this.application.consoleMessage({ type: 'logger', message: '[Username Logger] API key validation successful.' });
        }
        // --- END API Key Validation ---

        // Debug log the API key (partly masked) - This is now slightly redundant but harmless
        if (apiKey.length > 8 && isDevMode) {
          const masked = apiKey.substring(0, 4) + '...' + apiKey.substring(apiKey.length - 4);
          this.application.consoleMessage({
            type: 'logger',
            message: `[Username Logger] Using API key: ${masked}`
          });
        }

        // Get file paths using the utility and stored dataPath
        const mainAppSettings = this.application.settings || { get: () => undefined }; // Graceful fallback
        const customOutputDir = mainAppSettings.get('leakCheckOutputDir');
        const paths = getFilePaths(this.dataPath, customOutputDir);

        // Read logged usernames from the collected usernames file
        const allUsernames = await this.fileService.readUsernamesFromLog(paths.collectedUsernamesPath);

        if (allUsernames.length === 0) {
          this.application.consoleMessage({
            type: 'notify',
            message: `[Username Logger] No usernames found in the collected usernames file.`
          });
          this.stateModel.resetLeakCheckState();
          return { success: false, error: 'No usernames found' };
        }

        // Determine usernames to process in this run
        const usernamesToCheckThisRun = allUsernames.slice(startIndex);
        const limitedUsernamesToCheck = usernamesToCheckThisRun.slice(0, limit);

        if (limitedUsernamesToCheck.length === 0) {
          this.application.consoleMessage({
            type: 'notify',
            message: `[Username Logger] No new usernames to process from the starting index.`
          });
          this.stateModel.resetLeakCheckState();
          return { success: false, error: 'No new usernames' };
        }

        // More user-friendly message in production
        if (isDevMode) {
          this.application.consoleMessage({
            type: 'notify',
            message: `[Username Logger] Starting check from index ${startIndex}. Processing up to ${limitedUsernamesToCheck.length} usernames (limit: ${limit === Infinity ? 'All' : limit})...`
          });
        } else {
          // Cleaner message for end users
          if (startIndex <= 1) {
            this.application.consoleMessage({
              type: 'notify',
              message: `[Username Logger] Starting leak check on ${limitedUsernamesToCheck.length} usernames...`
            });
          } else {
            this.application.consoleMessage({
              type: 'notify',
              message: `[Username Logger] Continuing leak check from where you left off (${limitedUsernamesToCheck.length} usernames remaining)...`
            });
          }
        }

        // Read already checked usernames (for duplicate output prevention)
        const processedUsernames = await this.fileService.readLinesFromFile(paths.processedUsernamesPath);
        const processedUsernamesSet = new Set(processedUsernames.map(u => u.toLowerCase()));

        // Processing loop & Batching Setup
        let processedInThisRun = 0;
        let foundCount = 0;
        let notFoundCount = 0;
        let errorCount = 0;
        let invalidCharCount = 0;
        let currentOverallIndex = startIndex - 1; // Initialize to startIndex - 1 since we increment at start of loop
        
        // Batching variables
        let processedBatch = [];
        let foundGeneralBatch = [];
        let foundAjcBatch = [];
        let potentialBatch = []; // For invalid char usernames

        // Main processing loop
        for (const username of limitedUsernamesToCheck) {
          currentOverallIndex++; // Increment index at start of loop
          processedInThisRun++;

          // Check if we should stop or pause
          if (this.stateModel.getLeakCheckState().isStopped || this.stateModel.getLeakCheckState().isPaused) {
            const action = this.stateModel.getLeakCheckState().isStopped ? 'stopped' : 'paused';
            if (isDevMode) {
              this.application.consoleMessage({
                type: 'logger',
                message: `[Username Logger] Leak check ${action} at index ${currentOverallIndex}. Writing pending batches...`
              });
            }
            
            // Write batches
            await this._writeBatches(paths, processedBatch, foundGeneralBatch, foundAjcBatch, potentialBatch);
            
            // Update the index to the last successfully completed item
            const lastCompletedIndex = currentOverallIndex - 1;
            this.configModel.setLeakCheckIndex(lastCompletedIndex);
            // Removed redundant dev log before saveConfig
            // if (isDevMode) {
            //   this.application.consoleMessage({
            //     type: 'logger',
            //     message: `[Username Logger] Saving config with index: ${lastCompletedIndex}` // Adjusted log message if kept
            // }
            try {
            const saveSuccess = await this.configModel.saveConfig();
            if (!saveSuccess) {
              this.application.consoleMessage({
                type: 'error',
                message: `[Username Logger] CRITICAL: Failed to save config after stopping/pausing at index ${lastCompletedIndex}. Index may not persist.`
                });
              }
            } catch (saveError) {
              this.application.consoleMessage({
                type: 'error',
                message: `[Username Logger] Error in leak check: Failed to save config - ${saveError.message}`
              });
            }

            // Reset state
            this.stateModel.resetLeakCheckState();
            
            // Log summary on stop/pause
            const summary = {
              processed: processedInThisRun -1, // Don't count the one currently being processed when stopped
              found: foundCount,
              notFound: notFoundCount,
              errors: errorCount,
              invalidChar: invalidCharCount,
              startIndex: startIndex,
              lastIndexProcessed: lastCompletedIndex
            };
            
            this.application.consoleMessage({
                type: 'warn', // Use 'warn' for orange styling
                message: `[Username Logger] Leak check ${action}. Processed: ${summary.processed}, Found: ${summary.found}, Not Found: ${summary.notFound}, Errors: ${summary.errors}, Invalid: ${summary.invalidChar}`
            });
            
            return { 
              success: true, 
              status: action,
              processed: processedInThisRun,
              found: foundCount,
              notFound: notFoundCount,
              errors: errorCount,
              invalidChar: invalidCharCount,
              lastIndexProcessed: currentOverallIndex
            };
          }

          // Skip if already in the processed list (skip duplicate processing)
          if (processedUsernamesSet.has(username.toLowerCase())) {
            if (isDevMode) {
              this.application.consoleMessage({
                type: 'logger',
                message: `[Username Logger] Skipping ${username} (already in processed list).`
              });
            }
            continue;
          }
          
          try {
            // Check username
            const result = await this.apiService.checkUsername(username, apiKey, DEFAULT_RATE_LIMIT_DELAY);
            let addedToProcessedList = false;

            if (result.status === 200 && result.data?.success) {
              // Handle successful response
              if (result.data.found > 0) {
                foundCount++;
                addedToProcessedList = true;
                if (isDevMode) {
                  this.application.consoleMessage({
                    type: 'logger',
                    message: `[Username Logger] Found ${result.data.found} results for: ${username}`
                  });
                } else {
                  // Simpler message for production
                  this.application.consoleMessage({
                    type: 'notify',
                    message: `[Username Logger] Found results for: ${username}`
                  });
                }

                // Extract passwords
                const passwords = this.apiService.extractPasswordsFromResult(result);
                
                let passwordsFoundGeneral = 0;
                let passwordsFoundAjc = 0;

                for (const { password, isAjc } of passwords) {
                  const accountEntry = `${username}:${password}`;
                  
                  if (isAjc) {
                    foundAjcBatch.push(accountEntry);
                    passwordsFoundAjc++;
                  } else {
                    foundGeneralBatch.push(accountEntry);
                    passwordsFoundGeneral++;
                  }
                }

                // Log summary of found passwords
                if (passwordsFoundAjc > 0 || passwordsFoundGeneral > 0) {
                  if (isDevMode) {
                    this.application.consoleMessage({
                      type: 'logger',
                      message: `[Username Logger] Found ${passwordsFoundAjc} password(s) to save to ajc_accounts.txt and ${passwordsFoundGeneral} password(s) to save to found_accounts.txt.`
                    });
                  }
                } else {
                  if (isDevMode) {
                    this.application.consoleMessage({
                      type: 'logger',
                      message: `[Username Logger] No passwords found in results for ${username}, but breach exists.`
                    });
                  }
                }
              } else {
                notFoundCount++;
                addedToProcessedList = true;
                if (isDevMode) {
                  this.application.consoleMessage({
                    type: 'logger',
                    message: `[Username Logger] Not Found: ${username}`
                  });
                }
              }
            } else if (this.apiService.isInvalidCharactersError(result)) {
              invalidCharCount++;
              addedToProcessedList = false;
              this.application.consoleMessage({
                type: 'warn',
                message: `[Username Logger] Invalid Characters for API: ${username}. Saving for manual check.`
              });

              if (!processedUsernamesSet.has(username.toLowerCase())) {
                potentialBatch.push(username);
                processedUsernamesSet.add(username.toLowerCase());
              }
            } else {
              errorCount++;
              addedToProcessedList = false;
              this.application.consoleMessage({
                type: 'error',
                message: `[Username Logger] Unexpected API Response for ${username}: Status ${result.status} - ${JSON.stringify(result.data)}`
              });
            }

            // Add to processed batch if needed
            if (addedToProcessedList && !processedUsernamesSet.has(username.toLowerCase())) {
              if (isDevMode) {
                this.application.consoleMessage({
                  type: 'logger',
                  message: `[Username Logger] Adding ${username} to processed list.`
                });
              }
              processedBatch.push(username);
              processedUsernamesSet.add(username.toLowerCase());
              this.stateModel.addIgnoredUsername(username);
            }

            // Update progress if callback provided
            if (onProgress) {
              onProgress({
                currentIndex: currentOverallIndex,
                processedInThisRun,
                totalToProcess: limitedUsernamesToCheck.length,
                found: foundCount,
                notFound: notFoundCount,
                errors: errorCount,
                invalidChar: invalidCharCount
              });
            }

            // Write batches periodically
            if (processedInThisRun % DEFAULT_BATCH_SIZE === 0) {
              if (isDevMode) {
                this.application.consoleMessage({ 
                  type: 'logger', 
                  message: `[Username Logger] Performing periodic batch write.` 
                });
              }
              await this._writeBatches(paths, processedBatch, foundGeneralBatch, foundAjcBatch, potentialBatch);
              
              // Clear the batches
              processedBatch = [];
              foundGeneralBatch = [];
              foundAjcBatch = [];
              potentialBatch = [];
            }
          } catch (requestError) {
            errorCount++;
            this.application.consoleMessage({
              type: 'error',
              message: `[Username Logger] Request Error for ${username}: ${requestError.message}`
            });

            // Check if the error is specifically about the missing API key from the api-service check
            if (requestError.message.includes('API key is missing or blank')) {
              this.application.consoleMessage({
                type: 'error',
                message: `[Username Logger] Stopping leak check: API key is missing or blank. Please set your LeakCheck.io API key in the plugin settings or use the command: !setapikey YOUR_API_KEY`
              });
              // Trigger the stop mechanism to cleanly exit the loop
              this.stateModel.stopLeakCheck(); // Use the model's method to signal stop
              break; // Exit the loop immediately
            }
          }
        }

        // Write any remaining data in batches after the loop finishes
        if (isDevMode) {
          this.application.consoleMessage({ 
            type: 'logger', 
            message: `[Username Logger] Writing final batches...` 
          });
        }
        await this._writeBatches(paths, processedBatch, foundGeneralBatch, foundAjcBatch, potentialBatch);

        // Update the last processed index
        this.configModel.setLeakCheckIndex(currentOverallIndex);
        if (isDevMode) {
           // Log saving index
           this.application.consoleMessage({
              type: 'logger',
              message: `[Username Logger] Saving config with index: ${currentOverallIndex}`
           });
           try {
               const saveSuccess = await this.configModel.saveConfig();
               if (!saveSuccess) {
                   this.application.consoleMessage({
                       type: 'error',
                       message: `[Username Logger] CRITICAL: Failed to save config after completing run at index ${currentOverallIndex}. Index may not persist.`
                   });
               }
           } catch (saveError) {
               this.application.consoleMessage({
                   type: 'error',
                   message: `[Username Logger] Error in leak check: Failed to save config - ${saveError.message}`
               });
           }
           // Verify saved index
           const verifiedIndex = this.configModel.getLeakCheckIndex();
           this.application.consoleMessage({
             type: 'logger',
              message: `[Username Logger] Verified saved index in config: ${verifiedIndex}`
            });
         } else {
             try {
             const saveSuccess = await this.configModel.saveConfig(); // Save without logging steps
             if (!saveSuccess) {
               this.application.consoleMessage({
                 type: 'error',
                 message: `[Username Logger] CRITICAL: Failed to save config after completing run at index ${currentOverallIndex}. Index may not persist.`
                     });
                 }
             } catch (saveError) {
                 this.application.consoleMessage({
                     type: 'error',
                     message: `[Username Logger] Error in leak check: Failed to save config - ${saveError.message}`
               });
             }
         }

         const summary = {
          success: true,
          status: 'completed',
          processed: processedInThisRun,
          found: foundCount,
          notFound: notFoundCount,
          invalidChar: invalidCharCount,
          errors: errorCount,
          startIndex: startIndex,
          lastIndexProcessed: currentOverallIndex
        };

        this.application.consoleMessage({
          type: 'success',
          message: `[Username Logger] Leak check complete. Processed: ${processedInThisRun}, Found: ${foundCount}, Not Found: ${notFoundCount}, Errors: ${errorCount}, Invalid: ${invalidCharCount}`
        });

        // --- START AUTO-TRIM LOGIC ---
        if (summary.status === 'completed') {
          try {
            this.application.consoleMessage({
              type: 'notify',
              message: `[Username Logger] Attempting to automatically clear processed usernames...`
            });
            
            // Configure options for large files
            const trimOptions = {
              chunkSize: 5000,
              safeMode: true
            };
            
            if (isDevMode) {
              this.application.consoleMessage({
                type: 'logger',
                message: `[Username Logger] Auto-trim using chunked processing for ${currentOverallIndex + 1} usernames`
              });
            }
            
            // Use our optimized trimming with proper options for large files
            const trimSuccess = await this.fileService.trimProcessedUsernames(
              paths.collectedUsernamesPath,
              currentOverallIndex, // Trim up to the last processed index
              trimOptions
            );

            if (trimSuccess) {
              this.application.consoleMessage({
                type: 'success',
                message: `[Username Logger] Processed usernames automatically cleared from collected list.`
              });
              
              // Reset index to -1 for next run to start from beginning
              this.configModel.setLeakCheckIndex(-1);
              try {
              const resetSaveSuccess = await this.configModel.saveConfig();
              if (!resetSaveSuccess) {
                this.application.consoleMessage({
                  type: 'error',
                  message: `[Username Logger] CRITICAL: Failed to save config after resetting index for auto-trim. Index may not persist.`
                });
              } else if (isDevMode) {
                 this.application.consoleMessage({
                   type: 'logger',
                   message: `[Username Logger] Index successfully reset to -1 after auto-trim.`
                      });
                  }
              } catch (saveError) {
                  this.application.consoleMessage({
                      type: 'error',
                      message: `[Username Logger] Error in leak check: Failed to save config after auto-trim - ${saveError.message}`
                 });
              }
            } else {
              // Handle the failure case more explicitly
               this.application.consoleMessage({
                 type: 'warn',
                message: `[Username Logger] Auto-clearing failed. This can happen with very large files. You may need to run !trimprocessed manually.`
               });
              
              // For large datasets, suggest using the manual command
              if (currentOverallIndex > 5000) {
                this.application.consoleMessage({
                  type: 'notify',
                  message: `[Username Logger] TIP: For large datasets (${currentOverallIndex} usernames), try the manual command: !trimprocessed`
                });
              }
            }
          } catch (trimError) {
             // More detailed error logging
             this.application.consoleMessage({
               type: 'error',
               message: `[Username Logger] Error during automatic trimming: ${trimError.message}`
             });
             
             if (isDevMode) {
               this.application.consoleMessage({
                 type: 'error',
                 message: `[Username Logger] Auto-trim stack trace: ${trimError.stack}`
               });
             }
          }
        }
        // --- END AUTO-TRIM LOGIC ---

        return summary;
      } catch (innerError) {
        this.application.consoleMessage({
          type: 'error',
          message: `[Username Logger] Error in leak check: ${innerError.message}`
        });
        return { 
          success: false, 
          error: innerError.message,
          status: 'error'
        };
      } finally {
        this.stateModel.resetLeakCheckState();
      }
    } catch (outerError) {
      // Silently fail at the outermost level to prevent breaking the app
      try {
        this.stateModel.resetLeakCheckState();
        this.application.consoleMessage({
          type: 'error',
          message: `[Username Logger] Fatal plugin error: ${outerError.message}`
        });
      } catch (e) {
        // Do nothing - absolute fallback
      }
      
      return { 
        success: false, 
        error: 'Plugin error',
        status: 'error'
      };
    }
  }

  /**
   * Pauses a running leak check
   * @returns {boolean} True if state changed, false if already paused or not running
   */
  pauseLeakCheck() {
    try {
      if (this.stateModel.pauseLeakCheck()) {
        this.application.consoleMessage({
          type: 'notify',
          message: `[Username Logger] Leak check will pause after the current username is processed.`
        });
        return true;
      } else {
        this.application.consoleMessage({
          type: 'warn',
          message: `[Username Logger] No leak check is currently running.`
        });
        return false;
      }
    } catch (error) {
      // Silent fail to prevent breaking the app
      return false;
    }
  }

  /**
   * Stops a running leak check
   * @returns {boolean} True if state changed, false if already stopped or not running
   */
  stopLeakCheck() {
    try {
      if (this.stateModel.stopLeakCheck()) {
        this.application.consoleMessage({
          type: 'notify',
          message: `[Username Logger] Leak check will stop after current operation completes.`
        });
        return true;
      } else {
        this.application.consoleMessage({
          type: 'warn',
          message: `[Username Logger] No leak check is currently running.`
        });
        return false;
      }
    } catch (error) {
      // Silent fail to prevent breaking the app
      return false;
    }
  }

  /**
   * Write batches of data to respective files
   * @param {Object} paths - File paths object
   * @param {Array<string>} processedBatch - Processed usernames batch
   * @param {Array<string>} foundGeneralBatch - General found accounts batch
   * @param {Array<string>} foundAjcBatch - AJC-specific found accounts batch
   * @param {Array<string>} potentialBatch - Potential accounts batch 
   * @private
   */
  async _writeBatches(paths, processedBatch, foundGeneralBatch, foundAjcBatch, potentialBatch) {
    try {
      const writePromises = [];
      
      if (processedBatch.length > 0) {
        const isDevMode = this._isDevMode();
        if (isDevMode) {
          this.application.consoleMessage({
            type: 'logger',
            message: `[Username Logger] Writing ${processedBatch.length} usernames to processed_usernames.txt`
          });
        }
        writePromises.push(this.fileService.writeLinesToFile(
          paths.processedUsernamesPath, 
          processedBatch, 
          true
        ));
      }
      
      if (foundGeneralBatch.length > 0) {
        writePromises.push(this.fileService.writeLinesToFile(
          paths.foundAccountsPath, 
          foundGeneralBatch, 
          true
        ));
      }
      
      if (foundAjcBatch.length > 0) {
        writePromises.push(this.fileService.writeLinesToFile(
          paths.ajcAccountsPath, 
          foundAjcBatch, 
          true
        ));
      }
      
      if (potentialBatch.length > 0) {
        writePromises.push(this.fileService.writeLinesToFile(
          paths.potentialAccountsPath, 
          potentialBatch, 
          true
        ));
      }
      
      await Promise.all(writePromises);
    } catch (writeError) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Batch File Write Error: ${writeError.message}`
      });
    }
  }
}

module.exports = LeakCheckService;
