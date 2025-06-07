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
exports.render = function (app, data = {}) {
  const $modal = $(`
    <style>
      .sr-only {
        position: absolute;
        width: 1px;
        height: 1px;
        padding: 0;
        margin: -1px;
        overflow: hidden;
        clip: rect(0, 0, 0, 0);
        white-space: nowrap;
        border-width: 0;
      }
      .peer:checked ~ .peer-checked-bg {
        background-color: var(--theme-primary);
        border-color: var(--theme-primary);
      }
      .peer:checked ~ .peer-checked-translate {
        transform: translateX(1rem);
      }
      .toggle-text-on, .toggle-text-off {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        font-size: 0.6rem;
        font-weight: 600;
        color: white;
        pointer-events: none;
        transition: opacity 0.2s ease-in-out;
      }
      .toggle-text-on {
        right: 0.35rem;
        opacity: 0;
      }
      .toggle-text-off {
        left: 0.35rem;
        opacity: 1;
      }
      .peer:checked ~ .peer-checked-bg .toggle-text-on {
        opacity: 1;
      }
      .peer:checked ~ .peer-checked-bg .toggle-text-off {
        opacity: 0;
      }
    </style>
    <div class="flex items-center justify-center min-h-screen">
      <!-- Modal Backdrop -->
      <div class="fixed inset-0 bg-black bg-opacity-70 backdrop-blur-sm transition-opacity"></div>
      
      <div class="relative bg-secondary-bg rounded-lg shadow-xl max-w-md w-full flex flex-col max-h-[85vh] overflow-hidden">
        <!-- Modal Header -->
        <div class="flex items-center p-4 border-b border-sidebar-border flex-shrink-0">
          <h3 class="text-lg font-semibold text-text-primary">
            <i class="fas fa-cog text-highlight-yellow mr-2"></i>
            Settings
          </h3>
          <button type="button" class="modal-close-button-std text-gray-400 transition-colors duration-200 transform rounded-full p-1 ml-auto flex-shrink-0 flex items-center justify-center" id="closeSettingsBtn">
            <i class="fas fa-times"></i>
          </button>
        </div>

        <!-- Tab Bar -->
        <div class="flex border-b border-sidebar-border flex-shrink-0 px-2 pt-2">
          <button type="button" class="settings-tab active-tab relative px-4 py-2 text-sm font-medium text-text-primary focus:ring-2 focus:ring-offset-2 focus:ring-theme-primary focus:ring-offset-secondary-bg" data-tab="general">
            General
            <span class="tab-underline absolute bottom-0 left-0 w-full h-[2px]" style="background-color: var(--theme-primary); box-shadow: 0 0 6px 0 var(--theme-primary);"></span>
          </button>
          <button type="button" class="settings-tab relative px-4 py-2 text-sm font-medium text-sidebar-text hover:text-text-primary focus:ring-2 focus:ring-offset-2 focus:ring-theme-primary focus:ring-offset-secondary-bg" data-tab="plugins">
            Plugins
            <span class="tab-underline absolute bottom-0 left-0 w-full h-[2px]" style="background-color: transparent; box-shadow: none;"></span>
          </button>
          <button type="button" class="settings-tab relative px-4 py-2 text-sm font-medium text-sidebar-text hover:text-text-primary focus:ring-2 focus:ring-offset-2 focus:ring-theme-primary focus:ring-offset-secondary-bg" data-tab="leakcheck">
            LeakCheck
            <span class="tab-underline absolute bottom-0 left-0 w-full h-[2px]" style="background-color: transparent; box-shadow: none;"></span>
          </button>
          <button type="button" class="settings-tab relative px-4 py-2 text-sm font-medium text-sidebar-text hover:text-text-primary focus:ring-2 focus:ring-offset-2 focus:ring-theme-primary focus:ring-offset-secondary-bg" data-tab="advanced">
            Advanced
            <span class="tab-underline absolute bottom-0 left-0 w-full h-[2px]" style="background-color: transparent; box-shadow: none;"></span>
          </button>
        </div>

        <!-- Tab Content Area -->
        <div class="p-5 overflow-y-auto flex-grow">

          <!-- General Tab Content -->
          <div id="generalTabContent" class="settings-tab-content space-y-4">
            <!-- Update Section -->
            <div class="space-y-4">
              <h4 class="text-md font-semibold text-text-primary border-b border-sidebar-border pb-2">
                <i class="fas fa-sync-alt mr-2 text-highlight-yellow"></i>Application Updates
              </h4>
              <div>
                <button type="button" id="checkForUpdatesBtn" class="w-full bg-sidebar-hover text-text-primary px-4 py-2 rounded hover:bg-sidebar-hover/70 transition">
                  <i class="fas fa-search mr-2"></i>Check for Updates
                </button>
                <p class="mt-1 text-xs text-gray-400">Manually check for new versions of Strawberry Jam.</p>
                <p id="manualUpdateStatusText" class="mt-2 text-xs text-gray-400"></p>
              </div>
              <!-- Auto Update Toggle -->
              <div class="flex items-center justify-between bg-tertiary-bg/30 p-3 rounded mt-4">
                <label for="enableAutoUpdatesToggle" class="text-sm text-text-primary">Enable Automatic Updates</label>
                <label class="relative inline-flex items-center cursor-pointer">
                  <input type="checkbox" id="enableAutoUpdatesToggle" class="sr-only peer">
                  <div class="w-11 h-6 bg-gray-600 rounded-full transition-colors peer-checked-bg border border-gray-400 relative">
                    <span class="toggle-text-off">OFF</span>
                    <span class="toggle-text-on">ON</span>
                  </div>
                  <div class="absolute left-1 top-1 w-5 h-5 bg-white rounded-full transition-transform peer-checked-translate shadow"></div>
                </label>
              </div>
              <p class="mt-1 text-xs text-gray-400 -mt-3">If enabled, the application will automatically download and prompt to install updates when available.</p>
            </div>
            <!-- End Update Section -->

            <!-- Startup Behavior Section -->
            <div class="space-y-4 pt-4">
              <h4 class="text-md font-semibold text-text-primary border-b border-sidebar-border pb-2">
                <i class="fas fa-rocket mr-2 text-highlight-yellow"></i>Startup Behavior
              </h4>
              <div class="flex items-center justify-between bg-tertiary-bg/30 p-3 rounded">
                <label for="performServerCheckOnLaunchToggle" class="text-sm text-text-primary">Enable Server Check on Launch</label>
                <label class="relative inline-flex items-center cursor-pointer">
                  <input type="checkbox" id="performServerCheckOnLaunchToggle" class="sr-only peer">
                  <div class="w-11 h-6 bg-gray-600 rounded-full transition-colors peer-checked-bg border border-gray-400 relative">
                    <span class="toggle-text-off">OFF</span>
                    <span class="toggle-text-on">ON</span>
                  </div>
                  <div class="absolute left-1 top-1 w-5 h-5 bg-white rounded-full transition-transform peer-checked-translate shadow"></div>
                </label>
              </div>
              <p class="mt-1 text-xs text-gray-400 -mt-3">If unchecked, the app won't verify server status or check for updates at startup.</p>
            </div>
            <!-- End Startup Behavior Section -->

            <!-- Log Management Section -->
            <div class="space-y-4 pt-4">
              <h4 class="text-md font-semibold text-text-primary border-b border-sidebar-border pb-2">
                <i class="fas fa-chart-line mr-2 text-highlight-yellow"></i>Log Management
              </h4>
              
              <!-- Console Log Limit -->
              <div>
                <label for="consoleLogLimit" class="block mb-2 text-sm font-medium text-text-primary">Console Log Limit</label>
                <input id="consoleLogLimit" type="number" min="100" max="10000" step="100" class="bg-tertiary-bg text-text-primary placeholder-text-primary focus:outline-none rounded px-3 py-2 w-full" placeholder="1000">
                <p class="mt-1 text-xs text-gray-400">Maximum number of console log entries (default: 1000).</p>
              </div>

              <!-- Network Log Limit -->
              <div>
                <label for="networkLogLimit" class="block mb-2 text-sm font-medium text-text-primary">Network Log Limit</label>
                <input id="networkLogLimit" type="number" min="100" max="10000" step="100" class="bg-tertiary-bg text-text-primary placeholder-text-primary focus:outline-none rounded px-3 py-2 w-full" placeholder="1000">
                <p class="mt-1 text-xs text-gray-400">Maximum number of network log entries (default: 1000).</p>
              </div>

              <!-- Log Cleanup Info Box -->
              <div class="bg-tertiary-bg/30 p-3 rounded">
                <div class="flex items-start">
                  <i class="fas fa-info-circle text-highlight-yellow mt-0.5 mr-2"></i>
                  <div>
                    <p class="text-sm text-text-primary mb-2">When logs reach the limit, older entries (about 40%) are automatically removed.</p>
                    <p class="text-xs text-gray-400">This prevents performance issues from excessive memory usage.</p>
                  </div>
                </div>
              </div>
            </div>
            <!-- End Log Management Section -->
          </div>
          <!-- End General Tab Content -->

          <!-- Plugins Tab Content -->
          <div id="pluginsTabContent" class="settings-tab-content space-y-4 hidden">
            <!-- Hide Game-Specific Plugins -->
            <div class="flex items-center justify-between bg-tertiary-bg/30 p-3 rounded">
              <label for="hideGamePlugins" class="text-sm text-text-primary">Hide game-specific plugins in the UI</label>
              <label class="relative inline-flex items-center cursor-pointer">
                <input type="checkbox" id="hideGamePlugins" class="sr-only peer">
                <div class="w-11 h-6 bg-gray-600 rounded-full transition-colors peer-checked-bg border border-gray-400 relative">
                  <span class="toggle-text-off">OFF</span>
                  <span class="toggle-text-on">ON</span>
                </div>
                <div class="absolute left-1 top-1 w-5 h-5 bg-white rounded-full transition-transform peer-checked-translate shadow"></div>
              </label>
            </div>
            <p class="mt-1 text-xs text-gray-400">If checked, game-specific plugins will not be shown in the sidebar or plugin lists.</p>
          </div>
          <!-- End Plugins Tab Content -->

          <!-- LeakCheck Tab Content -->
          <div id="leakcheckTabContent" class="settings-tab-content space-y-6 hidden">
            <!-- LeakCheck Service Section -->
            <div class="space-y-4">
              <h4 class="text-md font-semibold text-text-primary border-b border-sidebar-border pb-2">
                <i class="fas fa-shield-alt mr-2 text-highlight-yellow"></i>LeakCheck Service
              </h4>
              <!-- API Key -->
              <div>
                <label for="leakCheckApiKey" class="block mb-2 text-sm font-medium text-text-primary">API Key</label>
                <input id="leakCheckApiKey" type="password" class="bg-tertiary-bg text-text-primary placeholder-text-primary focus:outline-none rounded px-3 py-2 w-full" placeholder="Enter LeakCheck API Key">
                <p class="mt-1 text-xs text-gray-400">Requires a <a href="https://leakcheck.io/" target="_blank" class="text-highlight-yellow hover:underline">LeakCheck.io</a> Pro subscription.</p>
              </div>
              <!-- Auto Leak Check Section -->
              <div class="bg-tertiary-bg/30 p-4 rounded-lg space-y-3">
                <div class="flex items-center justify-between">
                  <label for="leakCheckAutoCheck" class="text-sm font-medium text-text-primary">Auto-check for leaks</label>
                  <label class="relative inline-flex items-center cursor-pointer">
                    <input type="checkbox" id="leakCheckAutoCheck" class="sr-only peer">
                    <div class="w-11 h-6 bg-gray-600 rounded-full transition-colors peer-checked-bg border border-gray-400 relative">
                      <span class="toggle-text-off">OFF</span>
                      <span class="toggle-text-on">ON</span>
                    </div>
                    <div class="absolute left-1 top-1 w-5 h-5 bg-white rounded-full transition-transform peer-checked-translate shadow"></div>
                  </label>
                </div>
                <div id="leakCheckThresholdContainer" class="transition-opacity duration-300">
                  <label for="leakCheckThreshold" class="block mb-2 text-xs font-medium text-gray-400">Trigger after new usernames are collected:</label>
                  <div class="flex items-center space-x-2">
                    <input id="leakCheckThreshold" type="number" min="1" step="1" class="bg-tertiary-bg text-text-primary placeholder-text-primary focus:outline-none rounded px-3 py-2 w-24 text-center" placeholder="100">
                    <span class="text-xs text-gray-400">usernames</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Username Collection Section -->
            <div class="space-y-4 pt-4">
              <h4 class="text-md font-semibold text-text-primary border-b border-sidebar-border pb-2">
                <i class="fas fa-users mr-2 text-highlight-yellow"></i>Username Collection
              </h4>
              <!-- Master Toggle -->
              <div class="flex items-center justify-between bg-tertiary-bg/30 p-3 rounded">
                <label for="leakCheckEnableLogging" class="text-sm text-text-primary">Enable Username Logging</label>
                <label class="relative inline-flex items-center cursor-pointer">
                  <input type="checkbox" id="leakCheckEnableLogging" class="sr-only peer">
                  <div class="w-11 h-6 bg-gray-600 rounded-full transition-colors peer-checked-bg border border-gray-400 relative">
                    <span class="toggle-text-off">OFF</span>
                    <span class="toggle-text-on">ON</span>
                  </div>
                  <div class="absolute left-1 top-1 w-5 h-5 bg-white rounded-full transition-transform peer-checked-translate shadow"></div>
                </label>
              </div>
              <p class="mt-1 text-xs text-gray-400 -mt-3">Master toggle for the Username Logger plugin functionality.</p>
              <!-- Collection Scopes -->
              <div class="flex items-center justify-between bg-tertiary-bg/30 p-3 rounded">
                <label for="leakCheckCollectNearby" class="text-sm text-text-primary">Collect Usernames from Nearby Players</label>
                <label class="relative inline-flex items-center cursor-pointer">
                  <input type="checkbox" id="leakCheckCollectNearby" class="sr-only peer">
                  <div class="w-11 h-6 bg-gray-600 rounded-full transition-colors peer-checked-bg border border-gray-400 relative">
                    <span class="toggle-text-off">OFF</span>
                    <span class="toggle-text-on">ON</span>
                  </div>
                  <div class="absolute left-1 top-1 w-5 h-5 bg-white rounded-full transition-transform peer-checked-translate shadow"></div>
                </label>
              </div>
              <p class="mt-1 text-xs text-gray-400 -mt-3">Log usernames of players in the same room.</p>
              <div class="flex items-center justify-between bg-tertiary-bg/30 p-3 rounded">
                <label for="leakCheckCollectBuddies" class="text-sm text-text-primary">Collect Usernames from Buddy List</label>
                <label class="relative inline-flex items-center cursor-pointer">
                  <input type="checkbox" id="leakCheckCollectBuddies" class="sr-only peer">
                  <div class="w-11 h-6 bg-gray-600 rounded-full transition-colors peer-checked-bg border border-gray-400 relative">
                    <span class="toggle-text-off">OFF</span>
                    <span class="toggle-text-on">ON</span>
                  </div>
                  <div class="absolute left-1 top-1 w-5 h-5 bg-white rounded-full transition-transform peer-checked-translate shadow"></div>
                </label>
              </div>
              <p class="mt-1 text-xs text-gray-400 -mt-3">Log usernames from your buddy list updates.</p>
            </div>

            <!-- File Management Section -->
            <div class="space-y-4 pt-4">
              <h4 class="text-md font-semibold text-text-primary border-b border-sidebar-border pb-2">
                <i class="fas fa-folder-open mr-2 text-highlight-yellow"></i>File Management
              </h4>
              <!-- Output Directory -->
              <div>
                <label for="leakCheckOutputDirInput" class="block mb-2 text-sm font-medium text-text-primary">Output Directory (Optional)</label>
                <input id="leakCheckOutputDirInput" type="text" class="bg-tertiary-bg text-text-primary placeholder-text-primary focus:outline-none rounded px-3 py-2 w-full" placeholder="Default: [App Data]/UsernameLogger/">
                <p class="mt-1 text-xs text-gray-400">Custom folder for leak check results. Leave blank for default.</p>
              </div>
              <!-- Open Directory Button -->
              <div>
                <button type="button" id="openOutputDirBtn" class="w-full bg-sidebar-hover text-text-primary px-4 py-2 rounded hover:bg-sidebar-hover/70 transition">
                  <i class="fas fa-folder-open mr-2"></i>Open Output Directory
                </button>
                <p class="mt-1 text-xs text-gray-400">Opens the directory where results and logs are saved.</p>
              </div>
            </div>
          </div>
          <!-- End LeakCheck Tab Content -->

          <!-- Advanced Tab Content (Danger Zone) -->
          <div id="advancedTabContent" class="settings-tab-content space-y-4 hidden">
            <!-- Server Connection Settings -->
            <h4 class="text-md font-semibold text-text-primary mb-3">
              <i class="fas fa-server mr-2"></i>Server Connection
            </h4>

            <!-- Server IP -->
            <div>
              <label for="smartfoxServer" class="block mb-2 text-sm font-medium text-text-primary">
                Server IP
              </label>
              <input id="advancedSmartfoxServer" type="text"
                class="bg-tertiary-bg text-text-primary placeholder-text-primary focus:outline-none rounded px-3 py-2 w-full"
                placeholder="lb-iss02-classic-prod.animaljam.com">
              <p class="mt-1 text-xs text-gray-400">Animal Jam server address</p>
            </div>

            <!-- Secure Connection -->
            <div class="flex items-center mt-4 bg-tertiary-bg/30 p-3 rounded">
              <input id="advancedSecureConnection" type="checkbox"
                class="w-4 h-4 bg-tertiary-bg rounded focus:ring-custom-pink">
              <label for="advancedSecureConnection" class="ml-2 text-sm text-text-primary">
                Use secure connection (SSL/TLS)
              </label>
            </div>

            <h4 class="text-md font-semibold text-red-500 mt-6 mb-3">
              <i class="fas fa-exclamation-triangle mr-2"></i>Danger Zone
            </h4>

            <!-- Cache Size Display -->
            <div class="mb-4 py-2 px-3 bg-tertiary-bg/30 rounded">
              <div class="flex items-center justify-between mb-1">
                <span class="text-sm font-medium text-text-primary">Current Cache Size:</span>
                <span id="cacheSizeValue" class="text-sm text-highlight-yellow">Calculating...</span>
              </div>              <div class="text-xs text-gray-400 flex items-center">
                <i class="fas fa-info-circle mr-1"></i>
                <span>Cache includes AJ Classic and Strawberry Jam data directories.</span>
              </div>
              <div id="cacheSizeDetails" class="mt-2 text-xs text-gray-400 hidden">
                <!-- Will be populated with cache details -->
              </div>
            </div>

            <!-- Clear Cache Button -->
            <div>              <button type="button" id="clearCacheBtn" class="w-full bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition">
                Clear Cache Now
              </button>
              <p class="mt-1 text-xs text-gray-400">Deletes all cache data including AJ Classic and Strawberry Jam directories. Requires app restart.</p>
            </div>

            <!-- Uninstall Button -->
            <div class="mt-4">
              <button type="button" id="uninstallBtn" class="w-full bg-red-800 text-white px-4 py-2 rounded hover:bg-red-900 transition">
                Uninstall Strawberry Jam
              </button>
              <p class="mt-1 text-xs text-gray-400">Removes Strawberry Jam from your computer. This action is irreversible.</p>
            </div>
          </div>
          <!-- End Advanced Tab Content -->

        </div>

        <!-- Modal Footer -->
        <div class="flex items-center justify-end p-4 border-t border-sidebar-border flex-shrink-0">
          <button type="button" class="bg-tertiary-bg text-text-primary px-5 py-2.5 mr-3 rounded-lg hover:bg-sidebar-hover transition-all duration-200 border border-sidebar-border" id="cancelSettingsBtn">
            <i class="fas fa-times mr-1.5"></i> Cancel
          </button>
          <button type="button" class="bg-tertiary-bg text-white rounded-lg px-5 py-2.5 shadow-lg transition-all duration-200 transform hover:scale-[1.02] active:scale-100 focus:ring-2 focus:ring-offset-2 focus:ring-offset-primary-bg font-medium" id="saveSettingsBtn">
            <i class="fas fa-save mr-1.5"></i> Save Changes
          </button>
        </div>
      </div>
    </div>
  `)

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

  const $checkForUpdatesBtn = $modal.find('#checkForUpdatesBtn');
  const $manualUpdateStatusText = $modal.find('#manualUpdateStatusText');

  $checkForUpdatesBtn.on('click', () => {
    ipcRenderer.send('check-for-updates');
    // Initial state when button is clicked
    $manualUpdateStatusText.text('Checking for updates...').removeClass('text-green-400 text-red-400').addClass('text-yellow-400');
    $checkForUpdatesBtn.html('<i class="fas fa-spinner fa-spin mr-2"></i>Checking...').prop('disabled', true);
  });

  ipcRenderer.on('manual-update-check-status', (event, { status, message, version }) => {
    switch (status) {
      case 'checking':
        $manualUpdateStatusText.text(message || 'Checking for updates...').removeClass('text-green-400 text-red-400').addClass('text-yellow-400');
        $checkForUpdatesBtn.html('<i class="fas fa-spinner fa-spin mr-2"></i>Checking...').prop('disabled', true);
        break;
      case 'no-update':
        $manualUpdateStatusText.text(message || 'No new updates available.').removeClass('text-yellow-400 text-red-400').addClass('text-green-400');
        $checkForUpdatesBtn.html('<i class="fas fa-search mr-2"></i>Check for Updates').prop('disabled', false);
        break;
      case 'available':
        const availableMessage = version ? `${message} (v${version})` : message;
        $manualUpdateStatusText.text(availableMessage).removeClass('text-yellow-400 text-red-400').addClass('text-blue-400');
        // Potentially change button to "Download Update" or similar if auto-download is off
        // For now, just re-enable the check button. If auto-download is on, main process handles it.
        // If auto-download is off, user might need to click again or we add a download button.
        // For this iteration, we'll just re-enable the check button.
        // A more advanced flow would involve an "Update Now" button appearing.
        $checkForUpdatesBtn.html('<i class="fas fa-cloud-download-alt mr-2"></i>Update Available').prop('disabled', false);
        break;
      case 'downloaded':
        $manualUpdateStatusText.text(message || 'Update downloaded. Restart to install.').removeClass('text-yellow-400 text-red-400').addClass('text-purple-400');
        // Change button to prompt restart
        $checkForUpdatesBtn.html('<i class="fas fa-power-off mr-2"></i>Restart to Install')
          .prop('disabled', false)
          .off('click') // Remove previous click listener
          .on('click', () => { // Add new listener to restart
            ipcRenderer.send('app-restart');
          });
        break;
      case 'error':
        $manualUpdateStatusText.text(message || 'Error checking for updates.').removeClass('text-yellow-400 text-green-400').addClass('text-red-400');
        $checkForUpdatesBtn.html('<i class="fas fa-search mr-2"></i>Check for Updates').prop('disabled', false);
        break;
      default:
        $manualUpdateStatusText.text('').removeClass('text-yellow-400 text-green-400 text-red-400');
        $checkForUpdatesBtn.html('<i class="fas fa-search mr-2"></i>Check for Updates').prop('disabled', false);
    }
  });

  // --- End Button Click Handlers ---


  // --- REMOVED Call Initial State Load ---

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

    // Populate form fields (moved server settings to advanced tab)
    $modal.find('#advancedSmartfoxServer').val(smartfoxServer || '');
    $modal.find('#advancedSecureConnection').prop('checked', secureConnection === true); // Default to false if undefined

    // Populate Plugin settings
    $modal.find('#hideGamePlugins').prop('checked', hideGamePlugins === true); // Default to false if undefined

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
async function saveSettings ($modal, app) { // Made async
  // console.log('[Settings] Attempting to save settings...'); // Log removed
  if (typeof ipcRenderer === 'undefined' || !ipcRenderer) {
    console.error('[Settings Save] ipcRenderer not available.');
    showToast('Error: Cannot save settings, IPC unavailable.', 'error');
    return;
  }

  try {
    // Log the actual values from the inputs before processing
    const consoleLogLimitRaw = $modal.find('#consoleLogLimit').val();
    const networkLogLimitRaw = $modal.find('#networkLogLimit').val();
    logManager.debug(`[Settings Save] Raw input values - Console: ${consoleLogLimitRaw}, Network: ${networkLogLimitRaw}`);
    
    const consoleLogLimit = Math.max(100, Math.min(10000, parseInt(consoleLogLimitRaw) || 1000));
    const networkLogLimit = Math.max(100, Math.min(10000, parseInt(networkLogLimitRaw) || 1000));
    logManager.debug(`[Settings Save] Processed values - Console: ${consoleLogLimit}, Network: ${networkLogLimit}`);
    
    const settingsToSave = [
      { key: 'network.smartfoxServer', value: $modal.find('#advancedSmartfoxServer').val() },
      { key: 'network.secureConnection', value: $modal.find('#advancedSecureConnection').is(':checked') },
      { key: 'ui.hideGamePlugins', value: $modal.find('#hideGamePlugins').is(':checked') },
      // Using 'plugins.usernameLogger.apiKey' to align with main process Keytar storage
      { key: 'plugins.usernameLogger.apiKey', value: $modal.find('#leakCheckApiKey').val() },
      { key: 'plugins.usernameLogger.autoCheck.enabled', value: $modal.find('#leakCheckAutoCheck').is(':checked') }, // Corrected key
      { key: 'plugins.usernameLogger.autoCheck.threshold', value: parseInt($modal.find('#leakCheckThreshold').val()) || 100 }, // Corrected key
      { key: 'plugins.usernameLogger.collection.enabled', value: $modal.find('#leakCheckEnableLogging').is(':checked') }, // Corrected key
      { key: 'plugins.usernameLogger.collection.collectNearby', value: $modal.find('#leakCheckCollectNearby').is(':checked') }, // Corrected key
      { key: 'plugins.usernameLogger.collection.collectBuddies', value: $modal.find('#leakCheckCollectBuddies').is(':checked') }, // Corrected key
      { key: 'plugins.usernameLogger.outputDir', value: $modal.find('#leakCheckOutputDirInput').val().trim() }, // Corrected key
      // REMOVED: { key: 'leakCheck.autoClearResults', value: $modal.find('#autoClearResults').is(':checked') }
      
      // Log limiting settings
      { key: 'logs.consoleLimit', value: consoleLogLimit },
      { key: 'logs.networkLimit', value: networkLogLimit },

      // Startup Behavior settings
      { key: 'ui.performServerCheckOnLaunch', value: $modal.find('#performServerCheckOnLaunchToggle').is(':checked') },
      { key: 'dev-log.performServerCheckOnLaunch', value: $modal.find('#performServerCheckOnLaunchToggle').is(':checked') },

      // Auto Update setting
      { key: 'updates.enableAutoUpdates', value: $modal.find('#enableAutoUpdatesToggle').is(':checked') }
    ];

    // Step 1: Update the app.settings renderer cache for each setting.
    // This ensures the cache is current before flushing.
    for (const setting of settingsToSave) {
      if (app && app.settings && typeof app.settings.update === 'function') {
        await app.settings.update(setting.key, setting.value);
      } else {
        console.error(`[Settings Save] app.settings.update is not available. Cannot update renderer cache for ${setting.key}.`);
        showToast('Critical error: Settings cache cannot be updated.', 'error');
        return; // Abort save if cache update isn't possible
      }
    }

    // Step 2: Notify plugins. This will trigger app.settings.flush()
    // which saves the now up-to-date renderer cache to the main store.
    if (app && app.dispatch && typeof app.dispatch.notifyPluginsOfSettingsUpdate === 'function') {
      await app.dispatch.notifyPluginsOfSettingsUpdate(); // Ensure this is awaited
      showToast('Settings saved successfully!', 'success');
      app.modals.close();
    } else {
      console.warn('[Settings Save] Could not notify plugins of settings update: app.dispatch.notifyPluginsOfSettingsUpdate is not a function. Settings are cached locally and will attempt to save via debounce.');
      // If dispatch is not available, the settings are in the renderer cache and will be saved by the debouncer from app.settings.update.
      // This might not be ideal for immediate plugin reaction but prevents data loss.
      showToast('Settings cached. Plugin updates may be delayed.', 'warning');
      app.modals.close(); // Still close the modal
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
