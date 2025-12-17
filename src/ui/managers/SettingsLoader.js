const { ipcRenderer } = require('electron');
const $ = require('jquery');
const { formatBytes } = require('../../utils/FormatUtils');

class SettingsLoader {
  constructor(toastService) {
    this.toastService = toastService;
  }

  async loadSettings($modal, app, uiManager) {

    if (typeof ipcRenderer === 'undefined' || !ipcRenderer) {
      console.error('[Settings Load] ipcRenderer not available.');
      this.toastService.showInModal($modal, 'Error: Cannot load settings, IPC unavailable.', 'error');
      return;
    }

    try {
      const smartfoxServer = await ipcRenderer.invoke('get-setting', 'network.smartfoxServer');
      const secureConnection = await ipcRenderer.invoke('get-setting', 'network.secureConnection');

      const hideGamePlugins = await ipcRenderer.invoke('get-setting', 'ui.hideGamePlugins');
      const pluginRefreshBehavior = await ipcRenderer.invoke('get-setting', 'plugins.refreshBehavior');

      const leakCheckApiKey = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.apiKey');
      const leakCheckThreshold = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.autoCheck.threshold');
      const leakCheckEnableLogging = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.collection.enabled');
      const leakCheckOutputDir = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.outputDir');
      const usernameLoggerCollectNearby = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.collection.collectNearby');
      const usernameLoggerCollectBuddies = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.collection.collectBuddies');
      const leakCheckMaxPasswords = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.maxPasswordsPerAccount');

      const consoleLogLimit = await ipcRenderer.invoke('get-setting', 'logs.consoleLimit');
      const networkLogLimit = await ipcRenderer.invoke('get-setting', 'logs.networkLimit');

      const performServerCheckOnLaunch = await ipcRenderer.invoke('get-setting', 'ui.performServerCheckOnLaunch');

      const enableAutoUpdates = await ipcRenderer.invoke('get-setting', 'updates.enableAutoUpdates');

      const selectedSwfFile = await ipcRenderer.invoke('get-setting', 'game.selectedSwfFile');
      const autoReapplySwf = await ipcRenderer.invoke('get-setting', 'game.autoReapplySwf');

      const allowMultipleInstances = await ipcRenderer.invoke('get-setting', 'ui.allowMultipleInstances');

      const customThemeColor = await ipcRenderer.invoke('get-setting', 'ui.customThemeColor');
      const customThemeEnabled = await ipcRenderer.invoke('get-setting', 'ui.customThemeEnabled');
      const customThemeName = await ipcRenderer.invoke('get-setting', 'ui.customThemeName');
      const customThemeFruit = await ipcRenderer.invoke('get-setting', 'ui.customThemeFruit');

      $modal.data('initialSwfFile', selectedSwfFile || 'ajclient-prod.swf');

      $modal.find('#advancedSmartfoxServer').val(smartfoxServer || '');
      $modal.find('#advancedSecureConnection').prop('checked', secureConnection === true);

      await uiManager.loadSwfFileSettings($modal, selectedSwfFile || 'ajclient-prod.swf');

      $modal.find('#autoReapplySwfToggle').prop('checked', autoReapplySwf === true);

      $modal.find('#hideGamePlugins').prop('checked', hideGamePlugins === true);
      $modal.find('#pluginRefreshBehavior').val(pluginRefreshBehavior || 'ask');

      $modal.find('#leakCheckApiKey').val(leakCheckApiKey || '');
      const thresholdValue = leakCheckThreshold !== undefined && leakCheckThreshold !== null ? leakCheckThreshold : 0;
      $modal.find('#leakCheckThreshold').val(thresholdValue);
      const $leakCheckThresholdContainer = $modal.find('#leakCheckThresholdContainer');
      if ($leakCheckThresholdContainer.length) {
        $leakCheckThresholdContainer.css('opacity', '1').find('input').prop('disabled', false);
      }
      $modal.find('#leakCheckEnableLogging').prop('checked', leakCheckEnableLogging === true);
      $modal.find('#leakCheckEnableLogging').trigger('change');
      $modal.find('#leakCheckCollectNearby').prop('checked', usernameLoggerCollectNearby === true);
      $modal.find('#leakCheckCollectBuddies').prop('checked', usernameLoggerCollectBuddies === true);
      $modal.find('#leakCheckOutputDirInput').val(leakCheckOutputDir || '');
      $modal.find('#leakCheckMaxPasswords').val(leakCheckMaxPasswords || 0);

      $modal.find('#consoleLogLimit').val(consoleLogLimit || 500);
      $modal.find('#networkLogLimit').val(networkLogLimit || 500);

      $modal.find('#performServerCheckOnLaunchToggle').prop('checked', performServerCheckOnLaunch === true);

      $modal.find('#enableAutoUpdatesToggle').prop('checked', enableAutoUpdates === true);

      $modal.find('#allowMultipleInstancesToggle').prop('checked', allowMultipleInstances === true);

      $modal.find('#customThemeColorPicker').val(customThemeColor || '#e83d52');
      $modal.find('#customThemeColorInput').val(customThemeColor || '#e83d52');
      $modal.find('#customThemeNameInput').val(customThemeName || 'Custom Jam');
      $modal.find('#customThemeFruitSelect').val(customThemeFruit || 'strawberry.png');
      $modal.find('#customThemeEnabledToggle').prop('checked', customThemeEnabled === true);
      
      const selectedFruit = customThemeFruit || 'strawberry.png';
      const fruitPath = selectedFruit === 'strawberry-jam.png' ? 'app://assets/images/strawberry-jam.png' : `app://assets/images/${selectedFruit}`;
      $modal.find('#customThemeColorPreview').attr('src', fruitPath);
      
      if (customThemeEnabled === true && customThemeColor) {
        const { hexToCssFilter, normalizeHexColor } = require('../../utils/ColorUtils');
        const normalizedColor = normalizeHexColor(customThemeColor);
        if (normalizedColor) {
          const filter = hexToCssFilter(normalizedColor);
          $modal.find('#customThemeColorPreview').css('filter', filter);
        }
      }

      const $customThemeColorContainer = $modal.find('#customThemeColorContainer');
      if ($modal.find('#customThemeEnabledToggle').is(':checked')) {
        $customThemeColorContainer.css('opacity', '1').find('input').prop('disabled', false);
      } else {
        $customThemeColorContainer.css('opacity', '0.5').find('input').prop('disabled', true);
      }


      if ($modal.find('#advancedTabContent').is(':visible')) {
        const $cacheSizeValue = $modal.find('#cacheSizeValue');
        const $cacheSizeDetails = $modal.find('#cacheSizeDetails');
        
        try {
          const sizes = await ipcRenderer.invoke('get-cache-size');
          
          if (sizes && sizes.total >= 0) {
            $cacheSizeValue.text(formatBytes(sizes.total));
            
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

            if (sizes.byType) {
              const updateCacheTypeSize = (checkboxId, size) => {
                const $checkbox = $modal.find(`#${checkboxId}`);
                const $label = $checkbox.next('label') || $checkbox.closest('div').find('label');
                const $container = $checkbox.closest('div.flex');
                if ($container.length) {
                  const existingSize = $container.find('.cache-size-badge');
                  if (existingSize.length) {
                    existingSize.text(formatBytes(size));
                  } else {
                    const $sizeBadge = $(`<span class="cache-size-badge text-xs text-highlight-yellow ml-2">${formatBytes(size)}</span>`);
                    $label.after($sizeBadge);
                  }
                }
              };

              if (sizes.byType.gameSession !== undefined) {
                updateCacheTypeSize('cacheGameSession', sizes.byType.gameSession);
              }
              if (sizes.byType.auth !== undefined) {
                updateCacheTypeSize('cacheAuth', sizes.byType.auth);
              }
              if (sizes.byType.plugins !== undefined) {
                updateCacheTypeSize('cachePlugins', sizes.byType.plugins);
              }
              if (sizes.byType.logs !== undefined) {
                updateCacheTypeSize('cacheLogs', sizes.byType.logs);
              }
              if (sizes.byType.temp !== undefined) {
                updateCacheTypeSize('cacheTemp', sizes.byType.temp);
              }
            }
          } else {
            $cacheSizeValue.text('Not available');
          }
        } catch (error) {
          console.error('Error loading cache size:', error);
          $cacheSizeValue.text('Error calculating');
        }
      }

    } catch (error) {
      console.error('Error loading settings:', error);
      this.toastService.showInModal($modal, `Failed to load settings: ${error.message || 'Unknown error'}`, 'error');
    }
  }
}

module.exports = SettingsLoader;

