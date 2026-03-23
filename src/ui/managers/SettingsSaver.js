const { ipcRenderer } = require('electron');

class SettingsSaver {
  constructor(toastService) {
    this.toastService = toastService;
  }

  async saveSettings($modal, app) {
    if (typeof ipcRenderer === 'undefined' || !ipcRenderer) {
      console.error('[Settings Save] ipcRenderer not available.');
      this.toastService.showInModal($modal, 'Error: Cannot save settings, IPC unavailable.', 'error');
      return;
    }

    try {
      const initialSwfFile = $modal.data('initialSwfFile');
      const selectedSwfFile = $modal.find('#selectedSwfFile').val();
      const swfFileChanged = initialSwfFile !== selectedSwfFile;

      const { normalizeHexColor } = require('../../utils/ColorUtils');
      const customThemeColorInput = $modal.find('#customThemeColorInput').val().trim();
      const normalizedColor = normalizeHexColor(customThemeColorInput) || '#e83d52';
      const customThemeName = $modal.find('#customThemeNameInput').val().trim() || 'Custom Jam';
      const customThemeFruit = $modal.find('#customThemeFruitSelect').val() || 'strawberry.png';

      const settingsToSave = [
        { key: 'network.smartfoxServer', value: $modal.find('#advancedSmartfoxServer').val() },
        { key: 'network.secureConnection', value: $modal.find('#advancedSecureConnection').is(':checked') },
        { key: 'plugins.usernameLogger.apiKey', value: $modal.find('#leakCheckApiKey').val() },
        { key: 'plugins.usernameLogger.autoCheck.enabled', value: (parseInt($modal.find('#leakCheckThreshold').val()) || 0) > 0 },
        { key: 'plugins.usernameLogger.autoCheck.threshold', value: parseInt($modal.find('#leakCheckThreshold').val()) || 0 },
        { key: 'plugins.usernameLogger.collection.enabled', value: $modal.find('#leakCheckEnableLogging').is(':checked') },
        { key: 'plugins.usernameLogger.collection.collectNearby', value: $modal.find('#leakCheckCollectNearby').is(':checked') },
        { key: 'plugins.usernameLogger.collection.collectBuddies', value: $modal.find('#leakCheckCollectBuddies').is(':checked') },
        { key: 'plugins.usernameLogger.outputDir', value: $modal.find('#leakCheckOutputDirInput').val().trim() },
        { key: 'plugins.usernameLogger.maxPasswordsPerAccount', value: parseInt($modal.find('#leakCheckMaxPasswords').val()) || 0 },
        { key: 'ui.performServerCheckOnLaunch', value: $modal.find('#performServerCheckOnLaunchToggle').is(':checked') },
        { key: 'dev-log.performServerCheckOnLaunch', value: $modal.find('#performServerCheckOnLaunchToggle').is(':checked') },
        { key: 'updates.enableAutoUpdates', value: $modal.find('#enableAutoUpdatesToggle').is(':checked') },
        { key: 'game.selectedSwfFile', value: selectedSwfFile },
        { key: 'game.autoReapplySwf', value: $modal.find('#autoReapplySwfToggle').is(':checked') },
        { key: 'ui.militaryTime', value: $modal.find('#militaryTimeToggle').is(':checked') },
        { key: 'ui.allowMultipleInstances', value: $modal.find('#allowMultipleInstancesToggle').is(':checked') },
        { key: 'ui.customThemeColor', value: normalizedColor },
        { key: 'ui.customThemeEnabled', value: $modal.find('#customThemeEnabledToggle').is(':checked') },
        { key: 'ui.customThemeName', value: customThemeName },
        { key: 'ui.customThemeFruit', value: customThemeFruit }
      ];

      if (process.platform === 'linux') {
        settingsToSave.push(
          { key: 'linux.compatibilityLayer', value: $modal.find('#linuxCompatLayer').val() || 'auto' },
          { key: 'linux.winePrefix', value: $modal.find('#linuxWinePrefix').val().trim() }
        );
      }

      for (const setting of settingsToSave) {
        if (app && app.settings && typeof app.settings.update === 'function') {
          await app.settings.update(setting.key, setting.value);
        } else {
          console.error(`[Settings Save] app.settings.update is not available. Cannot update renderer cache for ${setting.key}.`);
          this.toastService.showInModal($modal, 'Critical error: Settings cache cannot be updated.', 'error');
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
          this.toastService.showInModal($modal, `Settings saved, but SWF switch failed: ${swfErrorMessage}`, 'warning');
        } else {
          this.toastService.showInModal($modal, 'Settings saved successfully!', 'success');
        }
        
        const customThemeEnabled = $modal.find('#customThemeEnabledToggle').is(':checked');
        const customThemeColor = normalizeHexColor($modal.find('#customThemeColorInput').val().trim()) || '#e83d52';
        const customThemeName = $modal.find('#customThemeNameInput').val().trim() || 'Custom Jam';
        const customThemeFruit = $modal.find('#customThemeFruitSelect').val() || 'strawberry.png';
        
        if (window.applyCustomColorTheme && window.restoreFruitTheme) {
          if (customThemeEnabled) {
            window.applyCustomColorTheme(customThemeColor, customThemeName, customThemeFruit);
          } else {
            window.restoreFruitTheme();
          }
        }
        
        app.modals.close();
      } else {
        console.warn('[Settings Save] Could not notify plugins of settings update. Settings are cached locally and will attempt to save via debounce.');
        this.toastService.showInModal($modal, 'Settings cached. Plugin updates may be delayed.', 'warning');
        app.modals.close();
      }

    } catch (error) {
      console.error('Error saving settings:', error);
      this.toastService.showInModal($modal, `Failed to save settings: ${error.message || 'Unknown error'}`, 'error');
    }
  }
}

module.exports = SettingsSaver;















