const { ipcRenderer } = require('electron');
const $ = require('jquery');
const { formatBytes } = require('../../utils/FormatUtils');

class SettingsLoader {
  constructor(toastService) {
    this.toastService = toastService;
  }

  async loadSettings($modal, app, uiManager) {
    const $leakCheckAutoCheck = $modal.find('#leakCheckAutoCheck');
    const $leakCheckThresholdContainer = $modal.find('#leakCheckThresholdContainer');

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
      const leakCheckAutoCheck = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.autoCheck.enabled');
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

      const allowMultipleInstances = await ipcRenderer.invoke('get-setting', 'ui.allowMultipleInstances');

      $modal.data('initialSwfFile', selectedSwfFile || 'ajclient-prod.swf');

      $modal.find('#advancedSmartfoxServer').val(smartfoxServer || '');
      $modal.find('#advancedSecureConnection').prop('checked', secureConnection === true);

      await uiManager.loadSwfFileSettings($modal, selectedSwfFile || 'ajclient-prod.swf');

      $modal.find('#hideGamePlugins').prop('checked', hideGamePlugins === true);
      $modal.find('#pluginRefreshBehavior').val(pluginRefreshBehavior || 'ask');

      $modal.find('#leakCheckApiKey').val(leakCheckApiKey || '');
      $modal.find('#leakCheckAutoCheck').prop('checked', leakCheckAutoCheck === true);
      $modal.find('#leakCheckThreshold').val(leakCheckThreshold || 100);
      $modal.find('#leakCheckEnableLogging').prop('checked', leakCheckEnableLogging === true);
      $modal.find('#leakCheckCollectNearby').prop('checked', usernameLoggerCollectNearby === true);
      $modal.find('#leakCheckCollectBuddies').prop('checked', usernameLoggerCollectBuddies === true);
      $modal.find('#leakCheckOutputDirInput').val(leakCheckOutputDir || '');
      $modal.find('#leakCheckMaxPasswords').val(leakCheckMaxPasswords || 0);

      $modal.find('#consoleLogLimit').val(consoleLogLimit || 1000);
      $modal.find('#networkLogLimit').val(networkLogLimit || 1000);

      $modal.find('#performServerCheckOnLaunchToggle').prop('checked', performServerCheckOnLaunch === true);

      $modal.find('#enableAutoUpdatesToggle').prop('checked', enableAutoUpdates === true);

      $modal.find('#allowMultipleInstancesToggle').prop('checked', allowMultipleInstances === true);

      if ($leakCheckAutoCheck.length) {
        if ($leakCheckAutoCheck.is(':checked')) {
          $leakCheckThresholdContainer.css('opacity', '1').find('input').prop('disabled', false);
        } else {
          $leakCheckThresholdContainer.css('opacity', '0.5').find('input').prop('disabled', true);
        }
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

