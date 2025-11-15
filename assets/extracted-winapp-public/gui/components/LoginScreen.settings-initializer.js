"use strict";

(() => {
  window.LoginScreenSettingsInitializer = class {
    constructor(loginScreenInstance, themeManager, uiManager) {
      this.loginScreen = loginScreenInstance;
      this.themeManager = themeManager;
      this.uiManager = uiManager;
    }

    _initializeAsyncSettings() {
      window.ipc.invoke('get-setting', 'uuidSpoofingEnabled')
        .then(uuidSpoofingEnabled => {
          if (this.loginScreen.uuidSpooferToggle) {
            this.loginScreen.uuidSpooferToggle.checked = uuidSpoofingEnabled;
            if (uuidSpoofingEnabled && this.loginScreen.uuidSpoofingWarning) {
              this.loginScreen.uuidSpoofingWarning.classList.add('show');
            }
          }
        })
        .catch(err => {
        });
        
      window.ipc.invoke('get-setting', 'debug.locale')
        .then(locale => {
          if (this.loginScreen.serverSwapSelect) {
            this.loginScreen.serverSwapSelect.value = locale || '';
          }
        })
        .catch(err => {
        });

      window.ipc.invoke('get-setting', 'backgroundProcessing')
        .then(backgroundProcessing => {
          if (this.loginScreen.backgroundProcessingToggle) {
            this.loginScreen.backgroundProcessingToggle.checked = backgroundProcessing !== false;
          }
        })
        .catch(err => {
          if (this.loginScreen.backgroundProcessingToggle) {
            this.loginScreen.backgroundProcessingToggle.checked = true;
          }
        });

      window.ipc.invoke('get-setting', 'darkMode')
        .then(darkMode => {
          if (this.loginScreen.darkModeToggle) {
            this.loginScreen.darkModeToggle.checked = darkMode === true;
            this.uiManager.toggleDarkMode(darkMode === true);
          }
        })
        .catch(err => {
          if (this.loginScreen.darkModeToggle) {
            this.loginScreen.darkModeToggle.checked = false;
            this.uiManager.toggleDarkMode(false);
          }
        });

      window.ipc.invoke('get-setting', 'ui.showImportAccounts')
        .then(showImportAccounts => {
          if (this.loginScreen.showImportAccountsToggle) {
            this.loginScreen.showImportAccountsToggle.checked = showImportAccounts === true;
          }
          this.uiManager._updateComponentVisibility();
        })
        .catch(err => {
          if (this.loginScreen.showImportAccountsToggle) {
            this.loginScreen.showImportAccountsToggle.checked = false;
          }
          this.uiManager._updateComponentVisibility();
        });

      window.ipc.invoke('get-setting', 'ui.showWheelAutomation')
        .then(showWheelAutomation => {
          if (this.loginScreen.showWheelAutomationToggle) {
            this.loginScreen.showWheelAutomationToggle.checked = showWheelAutomation === true;
          }
          this.uiManager._updateComponentVisibility();
        })
        .catch(err => {
          if (this.loginScreen.showWheelAutomationToggle) {
            this.loginScreen.showWheelAutomationToggle.checked = false;
          }
          this.uiManager._updateComponentVisibility();
        });
    }

    initializeSettings() {
      window.ipc.invoke('get-setting', 'fruitTheme')
        .then(savedFruitTheme => {
          let fruitFilename = savedFruitTheme;
          if (savedFruitTheme && savedFruitTheme.includes('/')) {
            fruitFilename = savedFruitTheme.split('/').pop();
          }
          
          if (fruitFilename && this.loginScreen._fruitImages.includes(fruitFilename)) {
            if (this.loginScreen.loginAppIconElem) {
              this.loginScreen.loginAppIconElem.src = `images/${fruitFilename}`;
              this.loginScreen._currentFruitIndex = this.loginScreen._fruitImages.indexOf(fruitFilename);
              this.themeManager.applyTheme(fruitFilename);
            }
          } else {
            this.themeManager.applyTheme(this.loginScreen._defaultFruit);
          }
        })
        .catch(err => {
          this.themeManager.applyTheme(this.loginScreen._defaultFruit);
        });
      
      window.ipc.invoke('get-setting', 'uuid_spoofer_enabled')
        .then(uuidSpoofingEnabled => {
          if (this.loginScreen.uuidSpooferToggle) {
            this.loginScreen.uuidSpooferToggle.checked = uuidSpoofingEnabled;
            if (uuidSpoofingEnabled && this.loginScreen.uuidSpoofingWarning) {
              this.loginScreen.uuidSpoofingWarning.classList.add('show');
            }
          }
        })
        .catch(err => {
        });

      window.ipc.invoke('get-setting', 'debug.locale')
        .then(locale => {
          if (this.loginScreen.serverSwapSelect) {
            this.loginScreen.serverSwapSelect.value = locale || '';
          }
        })
        .catch(err => {
        });

      window.ipc.invoke('get-setting', 'backgroundProcessing')
        .then(backgroundProcessing => {
          if (this.loginScreen.backgroundProcessingToggle) {
            this.loginScreen.backgroundProcessingToggle.checked = backgroundProcessing !== false;
          }
        })
        .catch(err => {
          if (this.loginScreen.backgroundProcessingToggle) {
            this.loginScreen.backgroundProcessingToggle.checked = true;
          }
        });

      window.ipc.invoke('get-setting', 'ui.showImportAccounts')
        .then(showImportAccounts => {
          if (this.loginScreen.showImportAccountsToggle) {
            this.loginScreen.showImportAccountsToggle.checked = showImportAccounts === true;
          }
          this.uiManager._updateComponentVisibility();
        })
        .catch(err => {
          if (this.loginScreen.showImportAccountsToggle) {
            this.loginScreen.showImportAccountsToggle.checked = false;
          }
          this.uiManager._updateComponentVisibility();
        });

      window.ipc.invoke('get-setting', 'ui.showWheelAutomation')
        .then(showWheelAutomation => {
          if (this.loginScreen.showWheelAutomationToggle) {
            this.loginScreen.showWheelAutomationToggle.checked = showWheelAutomation === true;
          }
          this.uiManager._updateComponentVisibility();
        })
        .catch(err => {
          if (this.loginScreen.showWheelAutomationToggle) {
            this.loginScreen.showWheelAutomationToggle.checked = false;
          }
          this.uiManager._updateComponentVisibility();
        });
    }
  };
})();

