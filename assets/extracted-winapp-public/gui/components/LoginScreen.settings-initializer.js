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

    async _initializeAllSettings() {
      try {
        // CRITICAL: Load dark mode FIRST and apply immediately to prevent FOUC
        // This must happen before the component becomes visible
        let darkMode = false;
        try {
          darkMode = await window.ipc.invoke('get-setting', 'darkMode');
          darkMode = darkMode === true;
        } catch (err) {
          darkMode = false;
        }

        // Apply dark mode IMMEDIATELY before loading other settings
        // This must happen synchronously to prevent any visual flash
        if (this.loginScreen.darkModeToggle) {
          this.loginScreen.darkModeToggle.checked = darkMode;
        }
        
        // CRITICAL: Set CSS variable on shadow root host IMMEDIATELY
        // CSS defaults to dark mode, so we only need to switch if light mode
        const shadowHost = this.loginScreen.shadowRoot.host;
        if (darkMode) {
          // Dark mode - ensure it's set (already default, but be explicit)
          this.loginScreen.classList.add('dark-mode');
          shadowHost.style.setProperty('--theme-box-background', 'rgba(45, 45, 45, 0.95)');
        } else {
          // Light mode - switch from dark default to light immediately
          this.loginScreen.classList.remove('dark-mode');
          shadowHost.style.setProperty('--theme-box-background', 'rgba(255, 245, 230, 0.95)');
        }
        
        // Call toggleDarkMode to ensure all dark mode styles are applied
        // This sets CSS variables on document.documentElement which shadow DOM can access
        this.uiManager.toggleDarkMode(darkMode);

        // Now load all other settings in parallel
        const [
          uuidSpoofingEnabled,
          locale,
          backgroundProcessing,
          showImportAccounts,
          showWheelAutomation,
          fruitTheme,
          uuidSpooferEnabledAlt // Handle both setting keys
        ] = await Promise.all([
          window.ipc.invoke('get-setting', 'uuidSpoofingEnabled').catch(() => false),
          window.ipc.invoke('get-setting', 'debug.locale').catch(() => ''),
          window.ipc.invoke('get-setting', 'backgroundProcessing').catch(() => true),
          window.ipc.invoke('get-setting', 'ui.showImportAccounts').catch(() => false),
          window.ipc.invoke('get-setting', 'ui.showWheelAutomation').catch(() => false),
          window.ipc.invoke('get-setting', 'fruitTheme').catch(() => null),
          window.ipc.invoke('get-setting', 'uuid_spoofer_enabled').catch(() => false)
        ]);

        // Apply all settings at once instead of individual async operations
        const effectiveUuidSpoofing = uuidSpoofingEnabled || uuidSpooferEnabledAlt;

        // UUID Spoofing settings
        if (this.loginScreen.uuidSpooferToggle) {
          this.loginScreen.uuidSpooferToggle.checked = effectiveUuidSpoofing;
          if (effectiveUuidSpoofing && this.loginScreen.uuidSpoofingWarning) {
            this.loginScreen.uuidSpoofingWarning.classList.add('show');
          }
        }

        // Locale/Server swap settings
        if (this.loginScreen.serverSwapSelect) {
          this.loginScreen.serverSwapSelect.value = locale || '';
        }

        // Background processing settings
        if (this.loginScreen.backgroundProcessingToggle) {
          this.loginScreen.backgroundProcessingToggle.checked = backgroundProcessing !== false;
        }

        // UI component visibility settings
        if (this.loginScreen.showImportAccountsToggle) {
          this.loginScreen.showImportAccountsToggle.checked = showImportAccounts === true;
        }
        if (this.loginScreen.showWheelAutomationToggle) {
          this.loginScreen.showWheelAutomationToggle.checked = showWheelAutomation === true;
        }
        this.uiManager._updateComponentVisibility();

        // Fruit theme settings (moved last as it involves DOM manipulation)
        let fruitFilename = fruitTheme;
        if (fruitTheme && fruitTheme.includes('/')) {
          fruitFilename = fruitTheme.split('/').pop();
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

      } catch (err) {
        console.warn('[Settings] Error loading settings:', err);
        // Apply defaults on error
        this.themeManager.applyTheme(this.loginScreen._defaultFruit);
        this.uiManager._updateComponentVisibility();
      }
    }
  };
})();

