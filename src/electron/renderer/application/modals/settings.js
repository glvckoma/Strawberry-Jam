const $ = require('jquery');
const ipcRenderer = require('electron').ipcRenderer;
const ToastService = require('../../../../ui/services/ToastService');
const SettingsUIManager = require('../../../../ui/managers/SettingsUIManager');
const SettingsLoader = require('../../../../ui/managers/SettingsLoader');
const SettingsSaver = require('../../../../ui/managers/SettingsSaver');
const SettingsEventHandler = require('../../../../ui/managers/SettingsEventHandler');

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

  const uiManager = new SettingsUIManager(app, ToastService);
  const settingsLoader = new SettingsLoader(ToastService);
  const settingsSaver = new SettingsSaver(ToastService);
  const eventHandler = new SettingsEventHandler(ToastService, settingsSaver);
  
  eventHandler.setupEventHandlers($modal, app, uiManager);
  await settingsLoader.loadSettings($modal, app, uiManager);
  
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
  
  return $modal;
}

exports.close = function (app) {
  if (typeof ipcRenderer !== 'undefined' && ipcRenderer) {
    ipcRenderer.removeAllListeners('manual-update-check-status');
  } else {
    console.warn('[Settings Close] ipcRenderer not available for cleanup.');
  }
}
