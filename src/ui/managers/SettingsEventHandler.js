const { ipcRenderer } = require('electron');
const $ = require('jquery');
const { hexToCssFilter, normalizeHexColor, isValidHexColor } = require('../../utils/ColorUtils');

class SettingsEventHandler {
  constructor(toastService, settingsSaver) {
    this.toastService = toastService;
    this.settingsSaver = settingsSaver;
  }

  setupEventHandlers($modal, app, uiManager) {
    if (typeof ipcRenderer !== 'undefined' && ipcRenderer) {
      ipcRenderer.removeAllListeners('manual-update-check-status');
    }

    const self = this;
    const $openOutputDirButton = $modal.find('#openOutputDirBtn');
    const $openUserPluginsDirButton = $modal.find('#openUserPluginsDirBtn');
    const $leakCheckOutputDirInput = $modal.find('#leakCheckOutputDirInput');
    const $clearCacheButton = $modal.find('#clearCacheBtn');
    const $uninstallButton = $modal.find('#uninstallBtn');
    const $cacheSizeValue = $modal.find('#cacheSizeValue');
    const $cacheSizeDetails = $modal.find('#cacheSizeDetails');
    const $leakCheckAutoCheck = $modal.find('#leakCheckAutoCheck');
    const $leakCheckThresholdContainer = $modal.find('#leakCheckThresholdContainer');
    const $leakCheckApiKey = $modal.find('#leakCheckApiKey');
    const $leakCheckApiKeyToggle = $modal.find('#leakCheckApiKeyToggle');

    $leakCheckApiKeyToggle.on('click', function() {
      const $input = $leakCheckApiKey;
      const $icon = $(this).find('i');
      const isPassword = $input.attr('type') === 'password';
      
      if (isPassword) {
        $input.attr('type', 'text');
        $icon.removeClass('fa-eye').addClass('fa-eye-slash');
      } else {
        $input.attr('type', 'password');
        $icon.removeClass('fa-eye-slash').addClass('fa-eye');
      }
    });

    $modal.find('#closeSettingsBtn, #cancelSettingsBtn').on('click', () => {
      app.modals.close();
    });

    $modal.find('#saveSettingsBtn').on('click', () => {
      this.settingsSaver.saveSettings($modal, app);
    });

    $modal.find('.settings-tab').on('click', function () {
      const tabId = $(this).data('tab');
      uiManager.setActiveTab(tabId, $modal);
      
      if (tabId === 'advanced') {
        uiManager.loadCacheSize($modal);
      }
    });

    $modal.find('#selectedSwfFile').on('change', function() {
      const selectedFile = $(this).val();
      const $currentName = $modal.find('#currentSwfName');
      const $currentSize = $modal.find('#currentSwfSize');
      
      $currentName.text(selectedFile);
      $currentSize.text('Updating...');
      
      uiManager.updateSwfFileInfo($modal, selectedFile);
    });

    $modal.find('#refreshSwfListBtn').on('click', async function() {
      const $button = $(this);
      const originalText = $button.html();
      
      $button.html('Refreshing...').prop('disabled', true);
      
      await new Promise(resolve => setTimeout(resolve, 500));
      
      try {
        const currentSelection = $modal.find('#selectedSwfFile').val();
        
        await uiManager.loadSwfFileSettings($modal, currentSelection);
        
        self.toastService.showInModal($modal, 'SWF file list refreshed successfully!', 'success');
        
        $button.removeClass('bg-sidebar-hover').addClass('bg-green-500 text-white transition-all duration-300');
        
        setTimeout(() => {
          $button.removeClass('bg-green-500 text-white').addClass('bg-sidebar-hover');
        }, 1000);
        
      } catch (error) {
        console.error('Error refreshing SWF files:', error);
        self.toastService.showInModal($modal, 'Error refreshing SWF files', 'error');
      } finally {
        $button.html(originalText).prop('disabled', false);
      }
    });

    $modal.find('#reapplySwfBtn').on('click', async function() {
      const $button = $(this);
      const originalText = $button.html();
      
      $button.html('Reapplying...').prop('disabled', true);
      
      await new Promise(resolve => setTimeout(resolve, 500));
      
      try {
        const selectedFile = $modal.find('#selectedSwfFile').val();
        
        if (!selectedFile) {
          self.toastService.showInModal($modal, 'No SWF file selected.', 'error');
          $button.html(originalText).prop('disabled', false);
          return;
        }
        
        const result = await ipcRenderer.invoke('reapply-swf-file', selectedFile);

        if (result.success) {
          await uiManager.refreshActiveSwfInfo($modal);
          
          self.toastService.showInModal($modal, 'SWF file reapplied successfully!', 'success');
          if (app && app.consoleMessage && app.consoleManager && !app.consoleManager.getQuietMode()) {
              app.consoleMessage({
                type: 'notify',
                message: `Game client file '${selectedFile}' was reapplied. Changes will apply on next game launch.`
              });
          }
          
          $button.removeClass('bg-sidebar-hover').addClass('bg-green-500 text-white transition-all duration-300');
          
          setTimeout(() => {
            $button.removeClass('bg-green-500 text-white').addClass('bg-sidebar-hover');
          }, 1000);
          
        } else {
          self.toastService.showInModal($modal, `Failed to reapply SWF: ${result.error}`, 'error');
        }
      } catch (error) {
        console.error('Error reapplying SWF file:', error);
        self.toastService.showInModal($modal, 'Error reapplying SWF file', 'error');
      } finally {
        $button.html(originalText).prop('disabled', false);
      }
    });

    $modal.find('#autoReapplySwfToggle').on('change', async function() {
      const isEnabled = $(this).is(':checked');
      
      try {
        await ipcRenderer.invoke('set-setting', 'game.autoReapplySwf', isEnabled);
        
        if (app && app.settings && typeof app.settings.update === 'function') {
          await app.settings.update('game.autoReapplySwf', isEnabled);
        }
        
        const statusText = isEnabled ? 'enabled' : 'disabled';
        self.toastService.showInModal($modal, `Auto-reapply SWF ${statusText}`, 'success');
      } catch (error) {
        console.error('Error saving auto-reapply setting:', error);
        self.toastService.showInModal($modal, 'Error saving auto-reapply setting', 'error');
        $(this).prop('checked', !isEnabled);
      }
    });

    const toggleThresholdVisibility = () => {
     if ($leakCheckAutoCheck.is(':checked')) {
       $leakCheckThresholdContainer.css('opacity', '1').find('input').prop('disabled', false);
     } else {
       $leakCheckThresholdContainer.css('opacity', '0.5').find('input').prop('disabled', true);
     }
    };

    $leakCheckAutoCheck.on('change', toggleThresholdVisibility);

    const $customThemeEnabledToggle = $modal.find('#customThemeEnabledToggle');
    const $customThemeColorPicker = $modal.find('#customThemeColorPicker');
    const $customThemeColorInput = $modal.find('#customThemeColorInput');
    const $customThemeNameInput = $modal.find('#customThemeNameInput');
    const $customThemeFruitSelect = $modal.find('#customThemeFruitSelect');
    const $customThemeColorContainer = $modal.find('#customThemeColorContainer');
    const $customThemeColorPreview = $modal.find('#customThemeColorPreview');
    const $resetCustomThemeColorBtn = $modal.find('#resetCustomThemeColorBtn');

    const updateColorPreview = (color) => {
      const normalizedColor = normalizeHexColor(color);
      if (normalizedColor) {
        const filter = hexToCssFilter(normalizedColor);
        $customThemeColorPreview.css('filter', filter);
      }
    };

    const syncColorInputs = (color) => {
      const normalizedColor = normalizeHexColor(color);
      if (normalizedColor) {
        $customThemeColorPicker.val(normalizedColor);
        $customThemeColorInput.val(normalizedColor);
        updateColorPreview(normalizedColor);
      }
    };

    const toggleCustomThemeVisibility = () => {
      if ($customThemeEnabledToggle.is(':checked')) {
        $customThemeColorContainer.css('opacity', '1').find('input').prop('disabled', false);
        const currentColor = $customThemeColorPicker.val() || $customThemeColorInput.val() || '#e83d52';
        updateColorPreview(currentColor);
      } else {
        $customThemeColorContainer.css('opacity', '0.5').find('input').prop('disabled', true);
        $customThemeColorPreview.css('filter', 'none');
      }
    };

    $customThemeEnabledToggle.on('change', async function() {
      toggleCustomThemeVisibility();
      
      if (window.jam && window.jam.ipcRenderer && app && app.settings) {
        const isEnabled = $(this).is(':checked');
        const currentColor = $customThemeColorPicker.val() || $customThemeColorInput.val() || '#e83d52';
        const currentName = $modal.find('#customThemeNameInput').val().trim() || 'Custom Jam';
        const currentFruit = $modal.find('#customThemeFruitSelect').val() || 'strawberry.png';
        
        await app.settings.update('ui.customThemeEnabled', isEnabled);
        if (isEnabled) {
          await app.settings.update('ui.customThemeColor', currentColor);
          await app.settings.update('ui.customThemeName', currentName);
          await app.settings.update('ui.customThemeFruit', currentFruit);
        }
        
        if (window.applyCustomColorTheme && window.restoreFruitTheme) {
          if (isEnabled) {
            window.applyCustomColorTheme(currentColor, currentName, currentFruit);
          } else {
            setTimeout(() => {
              if (window.restoreFruitTheme) {
                window.restoreFruitTheme();
              }
            }, 0);
          }
        }
      }
    });
    
    $customThemeFruitSelect.on('change', function() {
      const selectedFruit = $(this).val();
      const fruitPath = selectedFruit === 'strawberry-jam.png' ? 'app://assets/images/strawberry-jam.png' : `app://assets/images/${selectedFruit}`;
      $customThemeColorPreview.attr('src', fruitPath);
      const currentColor = $customThemeColorPicker.val() || $customThemeColorInput.val() || '#e83d52';
      updateColorPreview(currentColor);
      
      if (window.jam && window.jam.ipcRenderer && app && app.settings && $customThemeEnabledToggle.is(':checked')) {
        app.settings.update('ui.customThemeFruit', selectedFruit);
        const currentName = $customThemeNameInput.val().trim() || 'Custom Jam';
        if (window.applyCustomColorTheme) {
          window.applyCustomColorTheme(currentColor, currentName, selectedFruit);
        }
      }
    });
    
    $customThemeNameInput.on('input', function() {
      if (window.jam && window.jam.ipcRenderer && app && app.settings && $customThemeEnabledToggle.is(':checked')) {
        const currentName = $(this).val().trim() || 'Custom Jam';
        app.settings.update('ui.customThemeName', currentName);
        const currentColor = $customThemeColorPicker.val() || $customThemeColorInput.val() || '#e83d52';
        const currentFruit = $customThemeFruitSelect.val() || 'strawberry.png';
        if (window.applyCustomColorTheme) {
          window.applyCustomColorTheme(currentColor, currentName, currentFruit);
        }
      }
    });
    
    $customThemeColorPicker.on('input', function() {
      const color = $(this).val();
      syncColorInputs(color);
    });

    $customThemeColorInput.on('input', function() {
      const color = $(this).val();
      const normalizedColor = normalizeHexColor(color);
      if (normalizedColor) {
        $customThemeColorPicker.val(normalizedColor);
        updateColorPreview(normalizedColor);
      }
    });

    $customThemeColorInput.on('blur', function() {
      const color = $(this).val();
      const normalizedColor = normalizeHexColor(color);
      if (normalizedColor) {
        $(this).val(normalizedColor);
      } else if (color.trim() !== '') {
        $(this).val('#e83d52');
        syncColorInputs('#e83d52');
      }
    });

    $resetCustomThemeColorBtn.on('click', function() {
      syncColorInputs('#e83d52');
      $customThemeNameInput.val('Custom Jam');
      $customThemeFruitSelect.val('strawberry.png');
      const fruitPath = 'app://assets/images/strawberry.png';
      $customThemeColorPreview.attr('src', fruitPath);
      updateColorPreview('#e83d52');
    });

    toggleCustomThemeVisibility();

    $openOutputDirButton.on('click', async () => {
      try {
        const customOutputDir = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.outputDir');
        const defaultUsernameLoggerPath = await ipcRenderer.invoke('get-username-logger-path');
        const dirToOpen = (customOutputDir && customOutputDir.trim() !== '') ? customOutputDir : defaultUsernameLoggerPath;
        
        if (dirToOpen) {
          if (typeof ipcRenderer !== 'undefined' && ipcRenderer) {
            ipcRenderer.send('open-directory', dirToOpen);
          } else {
             console.error('ipcRenderer not available for opening directory');
             this.toastService.showInModal($modal, 'IPC Error: Cannot open directory', 'error');
          }
        } else {
          console.error('Target directory path not available to open.');
          this.toastService.showInModal($modal, 'Error: Target directory path not loaded', 'error');
        }
      } catch (error) {
        console.error('Error getting output directory setting for open:', error);
        this.toastService.showInModal($modal, 'Error opening directory', 'error');
        try {
          const fallbackPath = await ipcRenderer.invoke('get-username-logger-path');
          if (fallbackPath && typeof ipcRenderer !== 'undefined' && ipcRenderer) {
            ipcRenderer.send('open-directory', fallbackPath);
          }
        } catch (fallbackError) {
          console.error('Error getting fallback path:', fallbackError);
        }
      }
    });

    $openUserPluginsDirButton.on('click', async () => {
      try {
        const userPluginsPath = await ipcRenderer.invoke('get-user-plugins-path');
        
        if (userPluginsPath) {
          if (typeof ipcRenderer !== 'undefined' && ipcRenderer) {
            ipcRenderer.send('open-directory', userPluginsPath);
          } else {
            console.error('ipcRenderer not available for opening directory');
            this.toastService.showInModal($modal, 'IPC Error: Cannot open directory', 'error');
          }
        } else {
          console.error('User plugins directory path not available.');
          this.toastService.showInModal($modal, 'Error: User plugins directory path not loaded', 'error');
        }
      } catch (error) {
        console.error('Error getting user plugins directory path:', error);
        this.toastService.showInModal($modal, 'Error opening user plugins directory', 'error');
      }
    });

    const $cacheSelectAll = $modal.find('#cacheSelectAll');
    const $cacheGameSession = $modal.find('#cacheGameSession');
    const $cacheAuth = $modal.find('#cacheAuth');
    const $cachePlugins = $modal.find('#cachePlugins');
    const $cacheLogs = $modal.find('#cacheLogs');
    const $cacheTemp = $modal.find('#cacheTemp');
    const $cacheTypeCheckboxes = $modal.find('input[name="cacheType"]');

    const updateSelectAllState = () => {
      const allChecked = $cacheTypeCheckboxes.length === $cacheTypeCheckboxes.filter(':checked').length;
      $cacheSelectAll.prop('checked', allChecked);
    };

    $cacheSelectAll.on('change', function() {
      const isChecked = $(this).is(':checked');
      $cacheTypeCheckboxes.prop('checked', isChecked);
    });

    $cacheTypeCheckboxes.on('change', updateSelectAllState);

    $clearCacheButton.on('click', async () => {
      const options = {
        gameSession: $cacheGameSession.is(':checked'),
        auth: $cacheAuth.is(':checked'),
        plugins: $cachePlugins.is(':checked'),
        logs: $cacheLogs.is(':checked'),
        temp: $cacheTemp.is(':checked'),
        all: $cacheSelectAll.is(':checked') && $cacheTypeCheckboxes.filter(':checked').length === $cacheTypeCheckboxes.length
      };

      if (!options.gameSession && !options.auth && !options.plugins && !options.logs && !options.temp) {
        this.toastService.showInModal($modal, 'Please select at least one cache type to clear.', 'warning');
        return;
      }

      let totalSize = 0;
      try {
        const sizes = await ipcRenderer.invoke('get-cache-size');
        if (sizes && sizes.byType) {
          if (options.all || (!options.gameSession && !options.auth && !options.plugins && !options.logs && !options.temp)) {
            totalSize = sizes.total || 0;
          } else {
            if (options.gameSession && sizes.byType.gameSession !== undefined) {
              totalSize += sizes.byType.gameSession;
            }
            if (options.auth && sizes.byType.auth !== undefined) {
              totalSize += sizes.byType.auth;
            }
            if (options.plugins && sizes.byType.plugins !== undefined) {
              totalSize += sizes.byType.plugins;
            }
            if (options.logs && sizes.byType.logs !== undefined) {
              totalSize += sizes.byType.logs;
            }
            if (options.temp && sizes.byType.temp !== undefined) {
              totalSize += sizes.byType.temp;
            }
          }
        }
      } catch (error) {
        console.error('Error getting cache sizes:', error);
      }

      const message = 'Are you sure you want to clear the selected cache types? Strawberry Jam will close to complete the process.';

      const confirmed = await uiManager.showConfirmationModal(
        'Clear Cache Confirmation',
        message,
        'Close App & Clear Cache',
        'Cancel',
        {
          totalSize: totalSize
        }
      );

      if (confirmed) {
        this.toastService.showInModal($modal, 'Attempting to clear cache...', 'warning');
        try {
          const result = await ipcRenderer.invoke('danger-zone:clear-cache', options);
          if (!result.success) {
            this.toastService.showInModal($modal, `Failed to clear cache: ${result.error || result.message || 'Unknown error'}`, 'error');
          }
        } catch (error) {
          console.error('Error invoking clear cache:', error);
          this.toastService.showInModal($modal, `Error clearing cache: ${error.message}`, 'error');
        }
      }
    });

    $uninstallButton.on('click', async () => {
      const confirmed = await uiManager.showConfirmationModal(
        'Uninstall Confirmation',
        'Are you absolutely sure you want to uninstall Strawberry Jam? This will remove the application and cannot be undone. Strawberry Jam will close to start the uninstaller.',
        'Close App & Uninstall',
        'Cancel'
      );

      if (confirmed) {
        this.toastService.showInModal($modal, 'Attempting to uninstall...', 'warning');
        try {
          const result = await ipcRenderer.invoke('danger-zone:uninstall');
          if (!result.success) {
             this.toastService.showInModal($modal, `Failed to start uninstall: ${result.error || result.message || 'Unknown error'}`, 'error');
          }
        } catch (error) {
          console.error('Error invoking uninstall:', error);
          this.toastService.showInModal($modal, `Error starting uninstall: ${error.message}`, 'error');
        }
      }
    });

    $modal.find('#restartTutorialBtn').on('click', async () => {
      if (app) {
        try {
          const TutorialManager = require('./TutorialManager')
          let tutorialManager = app.tutorialManager
          
          if (!tutorialManager) {
            tutorialManager = new TutorialManager(app)
            await tutorialManager.initialize()
            app.tutorialManager = tutorialManager
          }
          
          await tutorialManager.resetTutorial()
          app.modals.close()
          setTimeout(() => {
            if (tutorialManager) {
              tutorialManager.startTutorial()
            }
          }, 300)
        } catch (error) {
          console.error('Error restarting tutorial:', error)
          this.toastService.showInModal($modal, `Failed to restart tutorial: ${error.message}`, 'error')
        }
      }
    })

    $modal.find('#resetGameTimeBtn').on('click', async () => {
      const confirmed = await uiManager.showConfirmationModal(
        'Reset Time Counters',
        'Are you sure you want to reset all game time and uptime counters to zero? This action cannot be undone.',
        'Reset Counters',
        'Cancel'
      );

      if (confirmed) {
        try {
          await ipcRenderer.invoke('reset-game-time');
          this.toastService.showInModal($modal, 'Game time and uptime have been reset.', 'success');
        } catch (error) {
          console.error('Error resetting game time:', error);
          this.toastService.showInModal($modal, `Failed to reset time counters: ${error.message}`, 'error');
        }
      }
    });

    const $checkForUpdatesBtn = $modal.find('#checkForUpdatesBtn');
    const $downloadUpdateBtn = $modal.find('#downloadUpdateBtn');
    const $manualUpdateStatusText = $modal.find('#manualUpdateStatusText');
    const $downloadProgressContainer = $modal.find('#downloadProgressContainer');
    const $downloadProgressBar = $modal.find('#downloadProgressBar');

    const $autoUpdateDiagnosticsText = $('<p id="autoUpdateDiagnosticsText" class="mt-1 text-xs text-gray-400"></p>');
    $manualUpdateStatusText.after($autoUpdateDiagnosticsText);

    const refreshAutoUpdateDiagnostics = async () => {
      try {
        const enableAutoUpdates = await ipcRenderer.invoke('get-setting', 'updates.enableAutoUpdates');
        const lastAutoCheckAt = await ipcRenderer.invoke('get-setting', 'updates.lastAutoCheckAt');
        const lastAutoCheckStatus = await ipcRenderer.invoke('get-setting', 'updates.lastAutoCheckStatus');

        const parts = [];
        parts.push(enableAutoUpdates === false ? 'Automatic updates are disabled.' : 'Automatic updates are enabled.');

        if (lastAutoCheckAt) {
          parts.push(`Last background check: ${lastAutoCheckAt}.`);
        } else {
          parts.push('No background check has been recorded yet.');
        }

        if (lastAutoCheckStatus) {
          parts.push(`Last check result: ${lastAutoCheckStatus}.`);
        }

        $autoUpdateDiagnosticsText.text(parts.join(' '));
      } catch (error) {
        $autoUpdateDiagnosticsText.text('Unable to load auto-update diagnostics.');
      }
    };

    refreshAutoUpdateDiagnostics();

    const $viewUpdatesBtn = $modal.find('#viewUpdatesBtn');
    $viewUpdatesBtn.on('click', async () => {
      app.modals.close();
      
      setTimeout(async () => {
        await app.openUpdatesModal();
      }, 100);
    });

    $checkForUpdatesBtn.on('click', () => {
      ipcRenderer.send('check-for-updates');
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
          const progress = version;
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

      try {
        refreshAutoUpdateDiagnostics();
      } catch (e) {
      }
    });
  }
}

module.exports = SettingsEventHandler;

