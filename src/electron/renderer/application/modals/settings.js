// Require ipcRenderer directly as contextIsolation is false
const ipcRenderer = require('electron').ipcRenderer;

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
exports.render = function (app, data = {}) {
  const $modal = $(`
    <div class="flex items-center justify-center min-h-screen p-4">
      <!-- Modal Backdrop -->
      <div class="fixed inset-0 bg-black/50 transition-opacity"></div>
      
      <!-- Modal Content -->
      <div class="relative bg-secondary-bg rounded-lg shadow-xl max-w-md w-full">
        <!-- Modal Header -->
        <div class="flex items-center justify-between p-4 border-b border-sidebar-border">
          <h3 class="text-lg font-semibold text-text-primary">
            <i class="fas fa-cog text-highlight-yellow mr-2"></i>
            Settings
          </h3>
          <button type="button" class="text-sidebar-text hover:text-text-primary" id="closeSettingsBtn">
            <i class="fas fa-times"></i>
          </button>
        </div>
        
        <!-- Modal Body -->
        <div class="p-5">
          <!-- Network Settings Content -->
          <div class="space-y-4">
            <!-- Server IP -->
            <div>
              <label for="smartfoxServer" class="block mb-2 text-sm font-medium text-text-primary">
                Server IP
              </label>
              <input id="smartfoxServer" type="text"
                class="bg-tertiary-bg text-text-primary placeholder-text-primary focus:outline-none rounded px-3 py-2 w-full"
                placeholder="lb-iss02-classic-prod.animaljam.com">
              <p class="mt-1 text-xs text-gray-400">Animal Jam server address</p>
            </div>

            <!-- Secure Connection -->
            <div class="flex items-center mt-4 bg-tertiary-bg/30 p-3 rounded mb-6">
              <input id="secureConnection" type="checkbox"
                class="w-4 h-4 bg-tertiary-bg rounded focus:ring-custom-pink">
              <label for="secureConnection" class="ml-2 text-sm text-text-primary">
                Use secure connection (SSL/TLS)
              </label>
            </div>

            <!-- LeakCheck Settings Section -->
            <div class="mt-6 pt-4 border-t border-sidebar-border space-y-4">
               <h4 class="text-md font-semibold text-text-primary mb-3">LeakCheck Settings</h4>
               <!-- LeakCheck API Key -->
               <div>
                 <label for="leakCheckApiKey" class="block mb-2 text-sm font-medium text-text-primary">
                   LeakCheck API Key
                 </label>
                 <input id="leakCheckApiKey" type="password"
                   class="bg-tertiary-bg text-text-primary placeholder-text-primary focus:outline-none rounded px-3 py-2 w-full"
                   placeholder="Enter your LeakCheck API Key">
                 <p class="mt-1 text-xs text-gray-400">Required for the leak check feature.</p>
               </div>
               <!-- Output Directory -->
               <div>
                <label for="leakCheckOutputDir" class="block mb-1 text-sm font-medium text-text-primary">
                  Output Directory
                </label>
                <div class="flex items-center space-x-2">
                  <input id="leakCheckOutputDir" type="text" readonly
                    class="flex-grow bg-tertiary-bg text-text-primary placeholder-text-primary focus:outline-none rounded px-3 py-2"
                    placeholder="Default: (Jam Project)/data/">
                  <button type="button" class="bg-sidebar-hover text-text-primary px-3 py-2 rounded hover:bg-sidebar-hover/70 transition" id="browseOutputDirBtn">
                    Browse...
                  </button>
                </div>
                 <p class="mt-1 text-xs text-gray-400">Where Leak Check result files are saved. Default is the 'data' folder in Jam's directory.</p>
               </div>
            </div>
            <!-- End LeakCheck Settings Section -->

          </div>
        </div>

        <!-- Modal Footer -->
        <div class="flex items-center justify-end p-4 border-t border-sidebar-border">
          <button type="button" class="bg-sidebar-hover text-text-primary px-4 py-2 mr-2 rounded hover:bg-sidebar-hover/70 transition" id="cancelSettingsBtn">
            Cancel
          </button>
          <button type="button" class="bg-custom-pink text-white px-4 py-2 rounded hover:bg-custom-pink/90 transition" id="saveSettingsBtn">
            Save Changes
          </button>
        </div>
      </div>
    </div>
  `)

  setupEventHandlers($modal, app)
  loadSettings($modal, app)
  return $modal
}

/**
 * Close handler for the settings modal
 * @param {Application} app - The application instance
 */
exports.close = function (app) {
  // Cleanup IPC listeners when modal closes (REMOVED leak-check listeners)
  // Check if ipcRenderer exists before using it
  if (typeof ipcRenderer !== 'undefined' && ipcRenderer) {
    // No leak-check specific listeners to remove anymore
  } else {
    console.warn('[Settings Close] ipcRenderer not available for cleanup.');
  }
}

/**
 * Setup event handlers for the settings modal
 * @param {JQuery<HTMLElement>} $modal - The modal element
 * @param {Application} app - The application instance
 */
function setupEventHandlers ($modal, app) {

  // --- Define Helper Functions First ---
  // REMOVED const $leakCheckStatus = $modal.find('#leakCheckStatus');
  // REMOVED const $startButton = $modal.find('#startLeakCheckBtn');
  // REMOVED const $pauseButton = $modal.find('#pauseLeakCheckBtn');
  // REMOVED const $stopButton = $modal.find('#stopLeakCheckBtn');
  const $outputDirInput = $modal.find('#leakCheckOutputDir');
  const $browseButton = $modal.find('#browseOutputDirBtn');

  // REMOVED updateButtonStates function
  // REMOVED loadInitialState function definition

  // --- Attach Core Modal Handlers ---
  $modal.find('#closeSettingsBtn, #cancelSettingsBtn').on('click', () => {
    app.modals.close()
  })

  $modal.find('#saveSettingsBtn').on('click', () => {
    saveSettings($modal, app)
  })
  // --- End Core Modal Handlers ---


  // --- REMOVED IPC Listeners for leak-check-progress and leak-check-result ---


  // --- Attach Button Click Handlers ---
   $browseButton.on('click', async () => {
    // Check if ipcRenderer exists before using it
    if (typeof ipcRenderer !== 'undefined' && ipcRenderer) {
      try {
        const result = await ipcRenderer.invoke('select-output-directory'); // Use direct ipcRenderer
        if (!result.canceled && result.path) {
          $outputDirInput.val(result.path);
        }
      } catch (error) {
        console.error('Error selecting output directory:', error);
        showToast('Failed to select directory', 'error');
      }
    } else {
      console.error('ipcRenderer not available for browsing directory');
      showToast('IPC Error: Cannot browse directory', 'error');
    }
  });

  // REMOVED $startButton click handler
  // REMOVED $pauseButton click handler
  // REMOVED $stopButton click handler


  // --- End Button Click Handlers ---


  // --- REMOVED Call Initial State Load ---
}


/**
 * Load settings into the form
 * @param {JQuery<HTMLElement>} $modal - The modal element
 * @param {Application} app - The application instance
 */
async function loadSettings ($modal, app) { // Made async
  // Check if ipcRenderer exists before using it
  const hasIpc = typeof ipcRenderer !== 'undefined' && ipcRenderer;

  try {
    // Load general settings using the existing app.settings if available
    const generalSettings = {};
    if (app.settings && typeof app.settings.getAll === 'function') {
      Object.assign(generalSettings, app.settings.getAll());
    }
    $modal.find('#smartfoxServer').val(generalSettings.smartfoxServer || 'lb-iss02-classic-prod.animaljam.com');
    $modal.find('#secureConnection').prop('checked', generalSettings.secureConnection === true);

    // Load LeakCheck API Key via IPC invoke
    if (hasIpc) {
      try {
        const apiKey = await ipcRenderer.invoke('get-setting', 'leakCheckApiKey'); // Use direct ipcRenderer
        $modal.find('#leakCheckApiKey').val(apiKey || '');

        // Load LeakCheck Output Directory via IPC invoke
        const outputDir = await ipcRenderer.invoke('get-setting', 'leakCheckOutputDir'); // Use direct ipcRenderer
        $modal.find('#leakCheckOutputDir').val(outputDir || ''); // Set value or empty string

      } catch (ipcError) {
        console.error('IPC Error loading settings:', ipcError);
        showToast('Error loading LeakCheck settings', 'error'); // Changed toast message
      }
    } else {
      console.error('ipcRenderer not available for loading settings');
      showToast('IPC Error: Cannot load settings', 'error');
    }

  } catch (error) {
    console.error('Error loading settings:', error);
    showToast('Error loading settings', 'error')
  }
}

/**
 * Save settings from the form
 * @param {JQuery<HTMLElement>} $modal - The modal element
 * @param {Application} app - The application instance
 */
async function saveSettings ($modal, app) { // Made async
  // Check if ipcRenderer exists before using it
  const hasIpc = typeof ipcRenderer !== 'undefined' && ipcRenderer;

  try {
    let settingsSaved = true;

    // Save general settings using the existing app.settings if available
    const generalSettingsToSave = {
      smartfoxServer: $modal.find('#smartfoxServer').val().trim() || 'lb-iss02-classic-prod.animaljam.com',
      secureConnection: $modal.find('#secureConnection').prop('checked')
    };
    if (app.settings && typeof app.settings.setAll === 'function') {
      // Preserve other settings potentially managed by app.settings
      const currentGeneralSettings = app.settings.getAll() || {};
      // Filter out leakCheckApiKey and leakCheckOutputDir if they exist in currentGeneralSettings
      delete currentGeneralSettings.leakCheckApiKey;
      delete currentGeneralSettings.leakCheckOutputDir;
      app.settings.setAll({ ...currentGeneralSettings, ...generalSettingsToSave });
    } else {
      console.warn('No app.settings.setAll method available for general settings');
      // Decide if this is critical - maybe show a warning?
    }

    // Save LeakCheck API Key and Output Directory via IPC invoke
    const leakCheckApiKey = $modal.find('#leakCheckApiKey').val().trim();
    const leakCheckOutputDir = $modal.find('#leakCheckOutputDir').val().trim(); // Get output dir value

    if (hasIpc) {
      try {
        // Save API Key
        const apiKeyResult = await ipcRenderer.invoke('set-setting', 'leakCheckApiKey', leakCheckApiKey); // Use direct ipcRenderer
        if (!apiKeyResult || !apiKeyResult.success) {
          settingsSaved = false;
          console.error('IPC Error saving leakCheckApiKey:', apiKeyResult?.error || 'Unknown error');
          showToast(`Error saving LeakCheck API Key: ${apiKeyResult?.error || 'Unknown error'}`, 'error');
        }

        // Save Output Directory (only proceed if API key save was successful or we want to save regardless)
        if (settingsSaved) { // Check if previous save was ok before proceeding
            const outputDirResult = await ipcRenderer.invoke('set-setting', 'leakCheckOutputDir', leakCheckOutputDir); // Use direct ipcRenderer
            if (!outputDirResult || !outputDirResult.success) {
              settingsSaved = false;
              console.error('IPC Error saving leakCheckOutputDir:', outputDirResult?.error || 'Unknown error');
              showToast(`Error saving Output Directory: ${outputDirResult?.error || 'Unknown error'}`, 'error');
            }
        }

      } catch (ipcError) { // Catch errors from invoke calls
        settingsSaved = false;
        console.error('IPC Error saving LeakCheck settings:', ipcError);
        showToast('IPC Error: Failed to save LeakCheck settings', 'error');
      }
    } else {
      settingsSaved = false;
      console.error('ipcRenderer not available for saving settings');
      showToast('IPC Error: Cannot save settings', 'error');
    }

    if (settingsSaved) {
      app.modals.close();
      showToast('Settings saved successfully');
    }
    // If not saved, keep modal open for user to see error/retry

  } catch (error) {
    console.error('Error saving settings:', error);
    showToast('Error saving settings', 'error')
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
