// Require ipcRenderer directly as contextIsolation is false
const ipcRenderer = require('electron').ipcRenderer;
const logManager = require('../../../../utils/LogManagerPreload');

/**
 * Module name
 * @type {string}
 */
exports.name = 'settings'

/**
 * Render the settings modal
 * @param {Application} app - The application instance
 * @param {Object} data - Additional data passed to the modal
 * @returns {JQuery<HTMLElement>} The rendered modal element
 */
exports.render = async function (app, data = {}) {
  const html = await ipcRenderer.invoke('get-modal-html', 'settings');
  const $modal = $(html);

  setupEventHandlers($modal, app)
  loadSettings($modal, app)
  
  // Add fade-in animation
  $modal.css({
    'opacity': '0',
    'transform': 'scale(0.95)'
  });

  setTimeout(() => {
    $modal.css({
      'opacity': '1',
      'transform': 'scale(1)',
      'transition': 'opacity 0.2s ease-out, transform 0.2s ease-out'
    });
  }, 10);
  
  return $modal
}

/**
 * Close handler for the settings modal
 * @param {Application} app - The application instance
 */
exports.close = function (app) {
  // Cleanup IPC listeners when modal closes
  if (typeof ipcRenderer !== 'undefined' && ipcRenderer) {
    // Remove the specific listener for manual update checks when the modal is closed
    // to prevent multiple listeners if the modal is reopened.
    // Note: This is a simplified cleanup. A more robust solution might involve
    // storing the listener function and using ipcRenderer.removeListener().
    // For now, we rely on the fact that this modal's JS is re-evaluated on each open.
    // However, to be safe, explicitly remove all listeners for this channel.
    ipcRenderer.removeAllListeners('manual-update-check-status');
  } else {
    console.warn('[Settings Close] ipcRenderer not available for cleanup.');
  }
}

/**
 * Sets the active tab, styles its underline, and manages content visibility.
 * @param {string} tabDataId - The data-tab attribute of the tab to activate.
 * @param {JQuery<HTMLElement>} $modalContext - The jQuery object context of the modal.
 */
function setActiveTab(tabDataId, $modalContext) {
  const $allTabs = $modalContext.find('.settings-tab');
  const $allContentPanes = $modalContext.find('.settings-tab-content');

  $allTabs.each(function() {
    const $tab = $(this);
    const $underline = $tab.find('.tab-underline');
    const currentTabDataId = $tab.data('tab');

    if (currentTabDataId === tabDataId) {
      // Style active tab button
      $tab.addClass('active-tab text-text-primary').removeClass('text-sidebar-text');
      // Style active tab underline with smooth transition
      $underline.css({
        'background-color': 'var(--theme-primary)',
        'box-shadow': '0 0 6px 0 var(--theme-primary)',
        'transition': 'background-color 0.3s ease, box-shadow 0.3s ease'
      });
    } else {
      // Style inactive tab button
      $tab.removeClass('active-tab text-text-primary').addClass('text-sidebar-text');
      // Style inactive tab underline with smooth transition
      $underline.css({
        'background-color': 'transparent',
        'box-shadow': 'none',
        'transition': 'background-color 0.3s ease, box-shadow 0.3s ease'
      });
    }
  });

  // Get the current active content pane
  const $currentActive = $modalContext.find('.settings-tab-content:not(.hidden)');
  const $newActive = $modalContext.find('#' + tabDataId + 'TabContent');
  
  // Don't animate if it's already active
  if ($currentActive.attr('id') === $newActive.attr('id')) {
    return;
  }

  // Fade out current content
  if ($currentActive.length) {
    $currentActive.css({
      'opacity': '1',
      'transform': 'translateY(0)',
      'transition': 'opacity 0.2s ease-out, transform 0.2s ease-out'
    });
    
    setTimeout(() => {
      $currentActive.css({
        'opacity': '0',
        'transform': 'translateY(-10px)'
      });
      
      // Hide current content after fade out and prep new content for fade in
      setTimeout(() => {
        $currentActive.addClass('hidden');
        
        // Show and fade in new content
        $newActive.removeClass('hidden').css({
          'opacity': '0',
          'transform': 'translateY(10px)',
          'transition': 'opacity 0.2s ease-out, transform 0.2s ease-out'
        });
        
        // Start animation after a tiny delay to ensure CSS is applied
        setTimeout(() => {
          $newActive.css({
            'opacity': '1',
            'transform': 'translateY(0)'
          });
        }, 10);
      }, 200);
    }, 10);
  } else {
    // If no current active pane, just show the new one
    $newActive.removeClass('hidden');
  }
}

/**
 * Setup event handlers for the settings modal
 * @param {JQuery<HTMLElement>} $modal - The modal element
 * @param {Application} app - The application instance
 */
function setupEventHandlers ($modal, app) {
  // Ensure any existing listeners for manual update status are removed before adding a new one.
  // This is a safeguard, as `exports.close` also handles this.
  if (typeof ipcRenderer !== 'undefined' && ipcRenderer) {
    ipcRenderer.removeAllListeners('manual-update-check-status');
  }

  // --- Define Helper Functions First ---
  // REMOVED const $leakCheckStatus = $modal.find('#leakCheckStatus');
  // REMOVED const $startButton = $modal.find('#startLeakCheckBtn');
  // REMOVED const $pauseButton = $modal.find('#pauseLeakCheckBtn');
  // REMOVED const $stopButton = $modal.find('#stopLeakCheckBtn');
  // REMOVED const $outputDirInput = $modal.find('#leakCheckOutputDir'); // This ID was never used for an input
  // REMOVED const $browseButton = $modal.find('#browseOutputDirBtn');
  const $openOutputDirButton = $modal.find('#openOutputDirBtn');
  const $leakCheckOutputDirInput = $modal.find('#leakCheckOutputDirInput'); // New input field
  const $clearCacheButton = $modal.find('#clearCacheBtn');
  const $uninstallButton = $modal.find('#uninstallBtn');
  const $cacheSizeValue = $modal.find('#cacheSizeValue');
  const $cacheSizeDetails = $modal.find('#cacheSizeDetails');
  const $leakCheckAutoCheck = $modal.find('#leakCheckAutoCheck');
  const $leakCheckThresholdContainer = $modal.find('#leakCheckThresholdContainer');
  // REMOVED $autoClearCheckbox

  // Helper function to format bytes to human-readable size
  const formatBytes = (bytes, decimals = 2) => {
    if (bytes === 0) return '0 Bytes';
    
    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
  };

  // Function to load cache size
  const loadCacheSize = async () => {
    try {
      $cacheSizeValue.text('Calculating...');
      $cacheSizeDetails.addClass('hidden').empty();
      
      const sizes = await ipcRenderer.invoke('get-cache-size');
      
      if (sizes && sizes.total >= 0) {
        $cacheSizeValue.text(formatBytes(sizes.total));
        
        // Add detailed breakdown
        if (Object.keys(sizes.directories).length > 0) {
          const $detailsList = $('<ul class="space-y-1"></ul>');
          
          Object.entries(sizes.directories).forEach(([dir, size]) => {
            $detailsList.append(
              $(`<li class="flex justify-between">
                <span>${dir}:</span>
                <span>${formatBytes(size)}</span>
              </li>`)
            );
          });
          
          $cacheSizeDetails.html('<p class="font-medium mb-1">Cache breakdown:</p>').append($detailsList).removeClass('hidden');
        }
      } else {
        $cacheSizeValue.text('Not available');
      }
    } catch (error) {
      console.error('Error loading cache size:', error);
      $cacheSizeValue.text('Error calculating');
    }
  };

  // --- Attach Core Modal Handlers ---
  $modal.find('#closeSettingsBtn, #cancelSettingsBtn').on('click', () => {
    // console.log('[Settings Modal] Close/Cancel button clicked.'); // Log removed
    app.modals.close();
  });

  $modal.find('#saveSettingsBtn').on('click', () => {
    saveSettings($modal, app)
  })
  // --- End Core Modal Handlers ---

  // --- Tab Switching Logic ---
  $modal.find('.settings-tab').on('click', function () {
    const tabId = $(this).data('tab');
    setActiveTab(tabId, $modal);
    
    if (tabId === 'advanced') {
      loadCacheSize();
    }
  });
  // --- End Tab Switching Logic ---

  // --- SWF File Selection Handlers ---
  $modal.find('#selectedSwfFile').on('change', function() {
    const selectedFile = $(this).val();
    const $currentName = $modal.find('#currentSwfName');
    const $currentSize = $modal.find('#currentSwfSize');
    
    // Update current file display
    $currentName.text(selectedFile);
    $currentSize.text('Updating...');
    
    // Update file size info
    updateSwfFileInfo($modal, selectedFile);
  });

  $modal.find('#refreshSwfListBtn').on('click', async function() {
    const $button = $(this);
    const originalText = $button.html();
    
    // Show loading state
    $button.html('<i class="fas fa-spinner fa-spin mr-2"></i>Refreshing...').prop('disabled', true);
    
    try {
      const currentSelection = $modal.find('#selectedSwfFile').val();
      await loadSwfFileSettings($modal, currentSelection);
      showToast('SWF file list refreshed successfully!', 'success');
    } catch (error) {
      console.error('Error refreshing SWF files:', error);
      showToast('Error refreshing SWF files', 'error');
    } finally {
      // Restore button state
      $button.html(originalText).prop('disabled', false);
    }
  });

  $modal.find('#reapplySwfBtn').on('click', async function() {
    const $button = $(this);
    const originalText = $button.html();
    
    $button.html('<i class="fas fa-spinner fa-spin mr-2"></i>Reapplying...').prop('disabled', true);
    
    try {
      const selectedFile = $modal.find('#selectedSwfFile').val();
      if (!selectedFile) {
        showToast('No SWF file selected.', 'error');
        return;
      }
      
      // This will be a new IPC call to the main process
      const result = await ipcRenderer.invoke('reapply-swf-file', selectedFile);

      if (result.success) {
        showToast('SWF file reapplied successfully!', 'success');
        if (app && app.consoleMessage) {
            app.consoleMessage({
              type: 'notify',
              message: `Game client file '${selectedFile}' was reapplied. Changes will apply on next game launch.`
            });
        }
      } else {
        showToast(`Failed to reapply SWF: ${result.error}`, 'error');
      }
    } catch (error) {
      console.error('Error reapplying SWF file:', error);
      showToast('Error reapplying SWF file', 'error');
    } finally {
      $button.html(originalText).prop('disabled', false);
    }
  });
  // --- End SWF File Selection Handlers ---

  // --- LeakCheck Threshold Visibility ---
  const toggleThresholdVisibility = () => {
   if ($leakCheckAutoCheck.is(':checked')) {
     $leakCheckThresholdContainer.css('opacity', '1').find('input').prop('disabled', false);
   } else {
     $leakCheckThresholdContainer.css('opacity', '0.5').find('input').prop('disabled', true);
   }
  };

  $leakCheckAutoCheck.on('change', toggleThresholdVisibility);
  // --- End LeakCheck Threshold Visibility ---


  // --- REMOVED IPC Listeners for leak-check-progress and leak-check-result ---


  // --- Attach Button Click Handlers ---
  $openOutputDirButton.on('click', async () => {
    try {
      const customOutputDir = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.outputDir'); // Corrected key
      const dirToOpen = (customOutputDir && customOutputDir.trim() !== '') ? customOutputDir : app.dataPath; // Behavior for empty custom path might need review later
      
      if (dirToOpen) {
        if (typeof ipcRenderer !== 'undefined' && ipcRenderer) {
          ipcRenderer.send('open-directory', dirToOpen);
        } else {
           console.error('ipcRenderer not available for opening directory');
           showToast('IPC Error: Cannot open directory', 'error');
        }
      } else {
        console.error('Target directory path not available to open.');
        showToast('Error: Target directory path not loaded', 'error');
      }
    } catch (error) {
      console.error('Error getting output directory setting for open:', error);
      showToast('Error opening directory', 'error');
      // Fallback to app.dataPath if settings call fails
      if (app.dataPath && typeof ipcRenderer !== 'undefined' && ipcRenderer) {
        ipcRenderer.send('open-directory', app.dataPath);
      }
    }
  });

  // REMOVED $startButton click handler
  // REMOVED $pauseButton click handler
  // REMOVED $stopButton click handler

  // --- Danger Zone Handlers ---
  $clearCacheButton.on('click', async () => {    const confirmed = await showConfirmationModal(
      'Clear Cache Confirmation',
      'Are you sure you want to clear all application cache? This will delete both the AJ Classic and Strawberry Jam data directories from your AppData folder. Your saved usernames and settings may be preserved, but all other cache data will be removed. Strawberry Jam will close to complete the process.',
      'Close App & Clear Cache',
      'Cancel'
    );

    if (confirmed) {
      showToast('Attempting to clear cache...', 'warning');
      try {
        const result = await ipcRenderer.invoke('danger-zone:clear-cache');
        if (!result.success) {
          showToast(`Failed to clear cache: ${result.error || result.message || 'Unknown error'}`, 'error');
        }
        // No success toast needed as the app should quit if successful.
      } catch (error) {
        console.error('Error invoking clear cache:', error);
        showToast(`Error clearing cache: ${error.message}`, 'error');
      }
    }
  });

  $uninstallButton.on('click', async () => {
    const confirmed = await showConfirmationModal(
      'Uninstall Confirmation',
      'Are you absolutely sure you want to uninstall Strawberry Jam? This will remove the application and cannot be undone. Strawberry Jam will close to start the uninstaller.',
      'Close App & Uninstall',
      'Cancel'
    );

    if (confirmed) {
      showToast('Attempting to uninstall...', 'warning');
      try {
        const result = await ipcRenderer.invoke('danger-zone:uninstall');
        if (!result.success) {
          // Show error if uninstall failed to start (e.g., uninstaller not found)
           showToast(`Failed to start uninstall: ${result.error || result.message || 'Unknown error'}`, 'error');
        }
         // No success toast needed as the app should quit if successful.
      } catch (error) {
        console.error('Error invoking uninstall:', error);
        showToast(`Error starting uninstall: ${error.message}`, 'error');
      }
    }
  });

  // No handler needed for checkbox change, state is saved with "Save Changes"

  // --- End Danger Zone Handlers ---

  $modal.find('#resetGameTimeBtn').on('click', async () => {
    const confirmed = await showConfirmationModal(
      'Reset Time Counters',
      'Are you sure you want to reset all game time and uptime counters to zero? This action cannot be undone.',
      'Reset Counters',
      'Cancel'
    );

    if (confirmed) {
      try {
        await ipcRenderer.invoke('reset-game-time');
        showToast('Game time and uptime have been reset.', 'success');
      } catch (error) {
        console.error('Error resetting game time:', error);
        showToast(`Failed to reset time counters: ${error.message}`, 'error');
      }
    }
  });

  const $checkForUpdatesBtn = $modal.find('#checkForUpdatesBtn');
  const $downloadUpdateBtn = $modal.find('#downloadUpdateBtn');
  const $manualUpdateStatusText = $modal.find('#manualUpdateStatusText');
  const $downloadProgressContainer = $modal.find('#downloadProgressContainer');
  const $downloadProgressBar = $modal.find('#downloadProgressBar');

  $checkForUpdatesBtn.on('click', () => {
    ipcRenderer.send('check-for-updates');
    // Initial state when button is clicked
    $manualUpdateStatusText.text('Checking for updates...').removeClass('text-green-400 text-red-400').addClass('text-yellow-400');
    $checkForUpdatesBtn.html('<i class="fas fa-spinner fa-spin mr-2"></i>Checking...').prop('disabled', true);
  });

  $downloadUpdateBtn.on('click', () => {
    ipcRenderer.send('download-update');
    $manualUpdateStatusText.text('Downloading update...').removeClass('text-yellow-400 text-red-400').addClass('text-blue-400');
    $downloadUpdateBtn.html('<i class="fas fa-spinner fa-spin mr-2"></i>Downloading...').prop('disabled', true);
    $downloadProgressContainer.removeClass('hidden');
  });

  ipcRenderer.on('manual-update-check-status', async (event, { status, message, version }) => {
    const autoUpdatesEnabled = await ipcRenderer.invoke('get-setting', 'updates.enableAutoUpdates');

    switch (status) {
      case 'checking':
        $manualUpdateStatusText.text(message || 'Checking for updates...').removeClass('text-yellow-400 text-red-400').addClass('text-green-400');
        $checkForUpdatesBtn.html('<i class="fas fa-spinner fa-spin mr-2"></i>Checking...').prop('disabled', true);
        $downloadUpdateBtn.addClass('hidden');
        break;
      case 'no-update':
        $manualUpdateStatusText.text(message || 'No new updates available.').removeClass('text-green-400 text-red-400').addClass('text-yellow-400');
        $checkForUpdatesBtn.html('<i class="fas fa-search mr-2"></i>Check for Updates').prop('disabled', false);
        $downloadUpdateBtn.addClass('hidden');
        break;
      case 'available':
        const availableMessage = version ? `Update v${version} is available.` : message;
        $manualUpdateStatusText.text(availableMessage).removeClass('text-yellow-400 text-red-400').addClass('text-blue-400');
        
        if (autoUpdatesEnabled) {
          $checkForUpdatesBtn.html('<i class="fas fa-cloud-download-alt mr-2"></i>Downloading...').prop('disabled', true);
          $downloadUpdateBtn.addClass('hidden');
        } else {
          $manualUpdateStatusText.text(`${availableMessage} Click "Download Now" to get it.`);
          $checkForUpdatesBtn.addClass('hidden');
          $downloadUpdateBtn.removeClass('hidden').prop('disabled', false);
        }
        break;
      case 'downloading':
        const progress = version; // In this case, version is used for progress percentage
        $manualUpdateStatusText.text(`Downloading update... ${progress.toFixed(1)}%`).removeClass('text-yellow-400 text-red-400').addClass('text-blue-400');
        $downloadProgressBar.css('width', `${progress}%`);
        $downloadUpdateBtn.html('<i class="fas fa-spinner fa-spin mr-2"></i>Downloading...').prop('disabled', true);
        $downloadProgressContainer.removeClass('hidden');
        break;
      case 'downloaded':
        $manualUpdateStatusText.text(message || 'Update downloaded. Restart to install.').removeClass('text-yellow-400 text-red-400').addClass('text-purple-400');
        $downloadProgressContainer.addClass('hidden');
        $downloadUpdateBtn.addClass('hidden');
        $checkForUpdatesBtn.removeClass('hidden').html('<i class="fas fa-power-off mr-2"></i>Restart to Install')
          .prop('disabled', false)
          .off('click')
          .on('click', () => {
            ipcRenderer.send('app-restart');
          });
        break;
      case 'error':
        $manualUpdateStatusText.text(message || 'Error checking for updates.').removeClass('text-yellow-400 text-green-400').addClass('text-red-400');
        $checkForUpdatesBtn.html('<i class="fas fa-search mr-2"></i>Check for Updates').prop('disabled', false).removeClass('hidden');
        $downloadUpdateBtn.addClass('hidden');
        $downloadProgressContainer.addClass('hidden');
        break;
      default:
        $manualUpdateStatusText.text('').removeClass('text-yellow-400 text-green-400 text-red-400');
        $checkForUpdatesBtn.html('<i class="fas fa-search mr-2"></i>Check for Updates').prop('disabled', false).removeClass('hidden');
        $downloadUpdateBtn.addClass('hidden');
        $downloadProgressContainer.addClass('hidden');
    }
  });

  // --- End Button Click Handlers ---


  // --- REMOVED Call Initial State Load ---

}


/**
 * Load SWF file settings and populate the dropdown
 * @param {JQuery<HTMLElement>} $modal - The modal element
 * @param {string} selectedFile - The currently selected SWF file from settings
 */
async function loadSwfFileSettings($modal, selectedFile) {
  const $dropdown = $modal.find('#selectedSwfFile');
  const $currentName = $modal.find('#currentSwfName');
  const $currentSize = $modal.find('#currentSwfSize');

  try {
    // Get available SWF files via IPC
    const swfFiles = await ipcRenderer.invoke('get-swf-files');

    // Clear existing options
    $dropdown.empty();

    // Populate dropdown with available files
    swfFiles.forEach(file => {
      const option = new Option(file.displayName, file.filename);
      // Set the 'selected' property based on the file from settings
      option.selected = file.filename === selectedFile;
      $dropdown.append(option);
    });

    // Ensure the dropdown's value is explicitly set to the saved setting
    $dropdown.val(selectedFile);

    // Update the info display to match the selected setting
    const currentFile = swfFiles.find(f => f.filename === selectedFile);
    if (currentFile) {
      $currentName.text(currentFile.filename);
      $currentSize.text(formatBytes(currentFile.size));
    } else {
      // Fallback if the saved file is not in the list (e.g., it was deleted)
      $currentName.text(selectedFile || 'N/A');
      $currentSize.text('Unknown');
    }
  } catch (error) {
    console.error('Error loading SWF files:', error);
    // Fallback to default options
    $dropdown.html(`
      <option value="ajclient-prod.swf">Production Client</option>
    `);
    $dropdown.val(selectedFile);
    $currentName.text(selectedFile);
    $currentSize.text('Error loading');
  }
}

/**
 * Update SWF file info display
 * @param {JQuery<HTMLElement>} $modal - The modal element
 * @param {string} filename - The selected filename
 */
async function updateSwfFileInfo($modal, filename) {
  const $currentSize = $modal.find('#currentSwfSize');
  
  try {
    const swfFiles = await ipcRenderer.invoke('get-swf-files');
    const fileInfo = swfFiles.find(f => f.filename === filename);
    
    if (fileInfo) {
      $currentSize.text(formatBytes(fileInfo.size));
    } else {
      $currentSize.text('Unknown');
    }
  } catch (error) {
    console.error('Error updating SWF file info:', error);
    $currentSize.text('Error loading');
  }
}

/**
 * Format bytes to human readable format
 * @param {number} bytes - The number of bytes
 * @param {number} decimals - Number of decimal places
 * @returns {string} Formatted string
 */
function formatBytes(bytes, decimals = 2) {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const dm = decimals < 0 ? 0 : decimals;
  const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
  
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
}

/**
 * Load settings into the UI
 * @param {JQuery<HTMLElement>} $modal - The modal element
 * @param {Application} app - The application instance
 */
async function loadSettings ($modal, app) { // Made async
  const $leakCheckAutoCheck = $modal.find('#leakCheckAutoCheck');
  const $leakCheckThresholdContainer = $modal.find('#leakCheckThresholdContainer');

  if (typeof ipcRenderer === 'undefined' || !ipcRenderer) {
    console.error('[Settings Load] ipcRenderer not available.');
    showToast('Error: Cannot load settings, IPC unavailable.', 'error');
    return;
  }

  try {
    // console.log('Loading settings...'); // Log removed

    // Connection settings
    const smartfoxServer = await ipcRenderer.invoke('get-setting', 'network.smartfoxServer');
    const secureConnection = await ipcRenderer.invoke('get-setting', 'network.secureConnection');

    // Plugin settings
    const hideGamePlugins = await ipcRenderer.invoke('get-setting', 'ui.hideGamePlugins');
    const pluginRefreshBehavior = await ipcRenderer.invoke('get-setting', 'plugins.refreshBehavior');

    // LeakCheck settings
    // Using 'plugins.usernameLogger.apiKey' to align with main process Keytar storage
    const leakCheckApiKey = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.apiKey');
    const leakCheckAutoCheck = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.autoCheck.enabled'); // Corrected key
    const leakCheckThreshold = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.autoCheck.threshold'); // Corrected key
    const leakCheckEnableLogging = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.collection.enabled'); // Corrected key
    const leakCheckOutputDir = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.outputDir'); // Corrected key
    const usernameLoggerCollectNearby = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.collection.collectNearby'); // Corrected key
    const usernameLoggerCollectBuddies = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.collection.collectBuddies'); // Corrected key
    // REMOVED: const autoClearResults = await ipcRenderer.invoke('get-setting', 'leakCheck.autoClearResults');

    // Log limiting settings
    const consoleLogLimit = await ipcRenderer.invoke('get-setting', 'logs.consoleLimit');
    const networkLogLimit = await ipcRenderer.invoke('get-setting', 'logs.networkLimit');

    // Startup Behavior settings
    const performServerCheckOnLaunch = await ipcRenderer.invoke('get-setting', 'ui.performServerCheckOnLaunch');

    // Auto Update setting
    const enableAutoUpdates = await ipcRenderer.invoke('get-setting', 'updates.enableAutoUpdates');

    // Game client settings
    const selectedSwfFile = await ipcRenderer.invoke('get-setting', 'game.selectedSwfFile');
    const autoReapplySwfOnLaunch = await ipcRenderer.invoke('get-setting', 'game.autoReapplySwfOnLaunch');

    // Store the initial SWF file to check for changes on save
    $modal.data('initialSwfFile', selectedSwfFile || 'ajclient-prod.swf');

    // Populate form fields (moved server settings to advanced tab)
    $modal.find('#advancedSmartfoxServer').val(smartfoxServer || '');
    $modal.find('#advancedSecureConnection').prop('checked', secureConnection === true); // Default to false if undefined

    // Populate SWF file settings
    await loadSwfFileSettings($modal, selectedSwfFile || 'ajclient-prod.swf');

    // Populate Plugin settings
    $modal.find('#hideGamePlugins').prop('checked', hideGamePlugins === true); // Default to false if undefined
    $modal.find('#pluginRefreshBehavior').val(pluginRefreshBehavior || 'ask'); // Default to 'ask' if undefined

    // Populate LeakCheck settings
    $modal.find('#leakCheckApiKey').val(leakCheckApiKey || '');
    $modal.find('#leakCheckAutoCheck').prop('checked', leakCheckAutoCheck === true);
    $modal.find('#leakCheckThreshold').val(leakCheckThreshold || 100); // Default from main settings if undefined
    $modal.find('#leakCheckEnableLogging').prop('checked', leakCheckEnableLogging === true); // Default from main settings
    $modal.find('#leakCheckCollectNearby').prop('checked', usernameLoggerCollectNearby === true); // Default from main settings
    $modal.find('#leakCheckCollectBuddies').prop('checked', usernameLoggerCollectBuddies === true); // Default from main settings
    $modal.find('#leakCheckOutputDirInput').val(leakCheckOutputDir || '');
    // REMOVED: $modal.find('#autoClearResults').prop('checked', autoClearResults === true);

    // Populate log limiting settings
    $modal.find('#consoleLogLimit').val(consoleLogLimit || 1000);
    $modal.find('#networkLogLimit').val(networkLogLimit || 1000);

    // Populate Startup Behavior settings
    $modal.find('#performServerCheckOnLaunchToggle').prop('checked', performServerCheckOnLaunch === true);

    // Populate Auto Update setting
    $modal.find('#enableAutoUpdatesToggle').prop('checked', enableAutoUpdates === true);

    // Populate Auto Reapply SWF on Launch setting
    $modal.find('#autoReapplySwfOnLaunchToggle').prop('checked', autoReapplySwfOnLaunch === true);

    // Set initial state for LeakCheck threshold
    if ($leakCheckAutoCheck.length) {
      if ($leakCheckAutoCheck.is(':checked')) {
        $leakCheckThresholdContainer.css('opacity', '1').find('input').prop('disabled', false);
      } else {
        $leakCheckThresholdContainer.css('opacity', '0.5').find('input').prop('disabled', true);
      }
    }

    // Load cache size if advanced tab is initially active
    if ($modal.find('#advancedTabContent').is(':visible')) {
      const $cacheSizeValue = $modal.find('#cacheSizeValue');
      const $cacheSizeDetails = $modal.find('#cacheSizeDetails');
      
      // Use same helper function defined in setupEventHandlers
      const formatBytes = (bytes, decimals = 2) => {
        if (bytes === 0) return '0 Bytes';
        
        const k = 1024;
        const dm = decimals < 0 ? 0 : decimals;
        const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
        
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
      };
      
      try {
        const sizes = await ipcRenderer.invoke('get-cache-size');
        
        if (sizes && sizes.total >= 0) {
          $cacheSizeValue.text(formatBytes(sizes.total));
          
          // Add detailed breakdown
          if (Object.keys(sizes.directories).length > 0) {
            const $detailsList = $('<ul class="space-y-1"></ul>');
            
            Object.entries(sizes.directories).forEach(([dir, size]) => {
              $detailsList.append(
                $(`<li class="flex justify-between">
                  <span>${dir}:</span>
                  <span>${formatBytes(size)}</span>
                </li>`)
              );
            });
            
            $cacheSizeDetails.html('<p class="font-medium mb-1">Cache breakdown:</p>').append($detailsList).removeClass('hidden');
          }
        } else {
          $cacheSizeValue.text('Not available');
        }
      } catch (error) {
        console.error('Error loading cache size:', error);
        $cacheSizeValue.text('Error calculating');
      }
    }

    // console.log('Settings loaded successfully.'); // Log removed

    // REMOVED: Call loadInitialState for LeakCheck
    // if (typeof loadInitialState === 'function') {
    //   loadInitialState(); // For LeakCheck status
    // } else {
    //   console.warn('loadInitialState is not defined when trying to load settings.');
    // }

  } catch (error) {
    console.error('Error loading settings:', error);
    showToast(`Failed to load settings: ${error.message || 'Unknown error'}`, 'error');
  }
}

/**
 * Save settings from the modal
 * @param {JQuery<HTMLElement>} $modal - The modal element
 * @param {Application} app - The application instance
 */
async function saveSettings ($modal, app) {
  if (typeof ipcRenderer === 'undefined' || !ipcRenderer) {
    console.error('[Settings Save] ipcRenderer not available.');
    showToast('Error: Cannot save settings, IPC unavailable.', 'error');
    return;
  }

  try {
    const consoleLogLimit = Math.max(100, Math.min(10000, parseInt($modal.find('#consoleLogLimit').val()) || 1000));
    const networkLogLimit = Math.max(100, Math.min(10000, parseInt($modal.find('#networkLogLimit').val()) || 1000));

    const initialSwfFile = $modal.data('initialSwfFile');
    const selectedSwfFile = $modal.find('#selectedSwfFile').val();
    const swfFileChanged = initialSwfFile !== selectedSwfFile;

    const settingsToSave = [
      { key: 'network.smartfoxServer', value: $modal.find('#advancedSmartfoxServer').val() },
      { key: 'network.secureConnection', value: $modal.find('#advancedSecureConnection').is(':checked') },
      { key: 'ui.hideGamePlugins', value: $modal.find('#hideGamePlugins').is(':checked') },
      { key: 'plugins.refreshBehavior', value: $modal.find('#pluginRefreshBehavior').val() },
      { key: 'plugins.usernameLogger.apiKey', value: $modal.find('#leakCheckApiKey').val() },
      { key: 'plugins.usernameLogger.autoCheck.enabled', value: $modal.find('#leakCheckAutoCheck').is(':checked') },
      { key: 'plugins.usernameLogger.autoCheck.threshold', value: parseInt($modal.find('#leakCheckThreshold').val()) || 100 },
      { key: 'plugins.usernameLogger.collection.enabled', value: $modal.find('#leakCheckEnableLogging').is(':checked') },
      { key: 'plugins.usernameLogger.collection.collectNearby', value: $modal.find('#leakCheckCollectNearby').is(':checked') },
      { key: 'plugins.usernameLogger.collection.collectBuddies', value: $modal.find('#leakCheckCollectBuddies').is(':checked') },
      { key: 'plugins.usernameLogger.outputDir', value: $modal.find('#leakCheckOutputDirInput').val().trim() },
      { key: 'logs.consoleLimit', value: consoleLogLimit },
      { key: 'logs.networkLimit', value: networkLogLimit },
      { key: 'ui.performServerCheckOnLaunch', value: $modal.find('#performServerCheckOnLaunchToggle').is(':checked') },
      { key: 'dev-log.performServerCheckOnLaunch', value: $modal.find('#performServerCheckOnLaunchToggle').is(':checked') },
      { key: 'updates.enableAutoUpdates', value: $modal.find('#enableAutoUpdatesToggle').is(':checked') },
      { key: 'game.selectedSwfFile', value: selectedSwfFile },
      { key: 'game.autoReapplySwfOnLaunch', value: $modal.find('#autoReapplySwfOnLaunchToggle').is(':checked') }
    ];

    for (const setting of settingsToSave) {
      if (app && app.settings && typeof app.settings.update === 'function') {
        await app.settings.update(setting.key, setting.value);
      } else {
        console.error(`[Settings Save] app.settings.update is not available. Cannot update renderer cache for ${setting.key}.`);
        showToast('Critical error: Settings cache cannot be updated.', 'error');
        return;
      }
    }

    if (app && app.dispatch && typeof app.dispatch.notifyPluginsOfSettingsUpdate === 'function') {
      await app.dispatch.notifyPluginsOfSettingsUpdate();

      let swfSwitchFailed = false;
      let swfErrorMessage = '';

      if (swfFileChanged) {
        try {
          const result = await ipcRenderer.invoke('replace-swf-file', selectedSwfFile);
          if (result.success) {
            // Use app.consoleMessage to log to the user-facing console
            let clientType = 'Custom';
            if (selectedSwfFile === 'ajclient.swf') clientType = 'Production';
            if (selectedSwfFile === 'ajclientdev.swf') clientType = 'Development';
            
            app.consoleMessage({
              type: 'notify',
              message: `Game client set to ${clientType}: ${selectedSwfFile}. Changes will apply on next game launch.`
            });
          } else {
            swfSwitchFailed = true;
            swfErrorMessage = result.error;
          }
        } catch (error) {
          console.error('Error switching SWF file:', error);
          swfSwitchFailed = true;
          swfErrorMessage = 'An unexpected error occurred during the file switch.';
        }
      }

      if (swfSwitchFailed) {
        showToast(`Settings saved, but SWF switch failed: ${swfErrorMessage}`, 'warning');
      } else {
        showToast('Settings saved successfully!', 'success');
      }
      
      app.modals.close();
    } else {
      console.warn('[Settings Save] Could not notify plugins of settings update. Settings are cached locally and will attempt to save via debounce.');
      showToast('Settings cached. Plugin updates may be delayed.', 'warning');
      app.modals.close();
    }

  } catch (error) {
    console.error('Error saving settings:', error);
    showToast(`Failed to save settings: ${error.message || 'Unknown error'}`, 'error');
  }
}

/**
 * Show a toast notification
 * @param {string} message - The message to show
 * @param {string} type - The type of notification (success, error, warning)
 */
function showToast (message, type = 'success') {
  const colors = {
    success: 'bg-highlight-green text-white',
    error: 'bg-error-red text-white',
    warning: 'bg-custom-blue text-white'
  }

  const toast = $(`<div class="fixed bottom-4 right-4 px-4 py-2 rounded shadow-lg z-50 ${colors[type]}">${message}</div>`)
  $('body').append(toast)

  setTimeout(() => {
    toast.fadeOut(300, function () { $(this).remove() })
  }, 3000)
}

/**
 * Show a custom confirmation modal
 * @param {string} title - The modal title
 * @param {string} message - The confirmation message
 * @param {string} confirmText - Text for the confirm button
 * @param {string} cancelText - Text for the cancel button
 * @returns {Promise<boolean>} - Resolves true if confirmed, false otherwise
 */
function showConfirmationModal(title, message, confirmText = 'Confirm', cancelText = 'Cancel') {
  return new Promise((resolve) => {
    const $confirmModal = $(`
      <div class="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4 confirmation-modal">
        <div class="relative bg-secondary-bg rounded-lg shadow-xl max-w-sm w-full">
          <div class="p-5 text-center">
            <i class="fas fa-exclamation-triangle text-red-500 text-4xl mb-4"></i>
            <h3 class="text-lg font-semibold text-text-primary mb-2">${title}</h3>
            <p class="text-sm text-gray-400 mb-6">${message}</p>
            <div class="flex justify-center gap-4">
              <button type="button" class="bg-gray-600 text-white px-4 py-2 rounded hover:bg-gray-700 transition" id="confirmCancelBtn">${cancelText}</button>
              <button type="button" class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition" id="confirmActionBtn">${confirmText}</button>
            </div>
          </div>
        </div>
      </div>
    `);

    $confirmModal.find('#confirmCancelBtn').on('click', () => {
      $confirmModal.remove();
      resolve(false);
    });

    $confirmModal.find('#confirmActionBtn').on('click', () => {
      $confirmModal.remove();
      resolve(true);
    });

    $('body').append($confirmModal);
  });
}
