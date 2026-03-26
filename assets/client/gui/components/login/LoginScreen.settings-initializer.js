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

      if (this.loginScreen.modMenuBtnToggle) {
        this.loginScreen.modMenuBtnToggle.checked = localStorage.getItem('showModMenuButton') === 'true';
      }

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

    async initializeSettings() {
      try {
        const [customThemeColor, customThemeEnabled, savedFruitTheme] = await Promise.all([
          window.ipc.invoke('get-setting', 'ui.customThemeColor').catch(() => null),
          window.ipc.invoke('get-setting', 'ui.customThemeEnabled').catch(() => false),
          window.ipc.invoke('get-setting', 'fruitTheme').catch(() => null)
        ]);

        const customThemeEnabledToggle = this.loginScreen.shadowRoot.getElementById('custom-theme-enabled-toggle');
        const customThemeColorPicker = this.loginScreen.shadowRoot.getElementById('custom-theme-color-picker');
        const customThemeColorInput = this.loginScreen.shadowRoot.getElementById('custom-theme-color-input');

        if (customThemeEnabledToggle) {
          customThemeEnabledToggle.checked = customThemeEnabled === true;
        }
        if (customThemeColorPicker && customThemeColor) {
          customThemeColorPicker.value = customThemeColor;
        }
        if (customThemeColorInput && customThemeColor) {
          customThemeColorInput.value = customThemeColor;
        }

        if (customThemeEnabled === true && customThemeColor) {
          const applied = await this.themeManager.applyCustomColorTheme(customThemeColor);
          if (applied) {
            this._setupCustomColorHandlers();
            return;
          }
        }

        let fruitFilename = savedFruitTheme;
        if (savedFruitTheme && savedFruitTheme.includes('/')) {
          fruitFilename = savedFruitTheme.split('/').pop();
        }
        
        if (fruitFilename && this.loginScreen._fruitImages.includes(fruitFilename)) {
          if (this.loginScreen.loginAppIconElem) {
            this.loginScreen.loginAppIconElem.src = `images/${fruitFilename}`;
            this.loginScreen.loginAppIconElem.style.filter = 'none';
            this.loginScreen._currentFruitIndex = this.loginScreen._fruitImages.indexOf(fruitFilename);
            this.themeManager.applyTheme(fruitFilename);
          }
        } else {
          this.themeManager.applyTheme(this.loginScreen._defaultFruit);
        }
        
        this._setupCustomColorHandlers();
      } catch (err) {
        this.themeManager.applyTheme(this.loginScreen._defaultFruit);
        this._setupCustomColorHandlers();
      }
      
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
        let darkMode = false;
        try {
          darkMode = await window.ipc.invoke('get-setting', 'darkMode');
          darkMode = darkMode === true;
        } catch (err) {
          darkMode = false;
        }

        if (this.loginScreen.darkModeToggle) {
          this.loginScreen.darkModeToggle.checked = darkMode;
        }
        
        const shadowHost = this.loginScreen.shadowRoot.host;
        if (darkMode) {
          this.loginScreen.classList.add('dark-mode');
          shadowHost.style.setProperty('--theme-box-background', 'rgba(45, 45, 45, 0.95)');
        } else {
          this.loginScreen.classList.remove('dark-mode');
          shadowHost.style.setProperty('--theme-box-background', 'rgba(255, 245, 230, 0.95)');
        }
        
        this.uiManager.toggleDarkMode(darkMode);

        const [
          uuidSpoofingEnabled,
          locale,
          backgroundProcessing,
          showImportAccounts,
          showWheelAutomation,
          fruitTheme,
          uuidSpooferEnabledAlt,
          hideDevToolsBadge
        ] = await Promise.all([
          window.ipc.invoke('get-setting', 'uuidSpoofingEnabled').catch(() => false),
          window.ipc.invoke('get-setting', 'debug.locale').catch(() => ''),
          window.ipc.invoke('get-setting', 'backgroundProcessing').catch(() => true),
          window.ipc.invoke('get-setting', 'ui.showImportAccounts').catch(() => false),
          window.ipc.invoke('get-setting', 'ui.showWheelAutomation').catch(() => false),
          window.ipc.invoke('get-setting', 'fruitTheme').catch(() => null),
          window.ipc.invoke('get-setting', 'uuid_spoofer_enabled').catch(() => false),
          window.ipc.invoke('get-setting', 'ui.hideDevToolsBadge').catch(() => false)
        ]);

        const effectiveUuidSpoofing = uuidSpoofingEnabled || uuidSpooferEnabledAlt;

        if (this.loginScreen.uuidSpooferToggle) {
          this.loginScreen.uuidSpooferToggle.checked = effectiveUuidSpoofing;
          if (effectiveUuidSpoofing && this.loginScreen.uuidSpoofingWarning) {
            this.loginScreen.uuidSpoofingWarning.classList.add('show');
          }
        }

        if (this.loginScreen.serverSwapSelect) {
          this.loginScreen.serverSwapSelect.value = locale || '';
        }

        if (this.loginScreen.backgroundProcessingToggle) {
          this.loginScreen.backgroundProcessingToggle.checked = backgroundProcessing !== false;
        }

        if (this.loginScreen.showImportAccountsToggle) {
          this.loginScreen.showImportAccountsToggle.checked = showImportAccounts === true;
        }
        if (this.loginScreen.showWheelAutomationToggle) {
          this.loginScreen.showWheelAutomationToggle.checked = showWheelAutomation === true;
        }
        this.uiManager._updateComponentVisibility();

        if (this.loginScreen.hideDevToolsBadgeToggle) {
          this.loginScreen.hideDevToolsBadgeToggle.checked = hideDevToolsBadge === true;
          this.loginScreen._hideDevToolsBadge = hideDevToolsBadge === true;
        }

        const [customThemeColor, customThemeEnabled, customThemeName, customThemeFruit] = await Promise.all([
          window.ipc.invoke('get-setting', 'ui.customThemeColor').catch(() => null),
          window.ipc.invoke('get-setting', 'ui.customThemeEnabled').catch(() => false),
          window.ipc.invoke('get-setting', 'ui.customThemeName').catch(() => null),
          window.ipc.invoke('get-setting', 'ui.customThemeFruit').catch(() => null)
        ]);

        const customThemeEnabledToggle = this.loginScreen.shadowRoot.getElementById('custom-theme-enabled-toggle');
        const customThemeNameInput = this.loginScreen.shadowRoot.getElementById('custom-theme-name-input');
        const customThemeFruitSelect = this.loginScreen.shadowRoot.getElementById('custom-theme-fruit-select');
        const customThemeColorPicker = this.loginScreen.shadowRoot.getElementById('custom-theme-color-picker');
        const customThemeColorInput = this.loginScreen.shadowRoot.getElementById('custom-theme-color-input');

        if (customThemeEnabledToggle) {
          customThemeEnabledToggle.checked = customThemeEnabled === true;
        }
        if (customThemeNameInput && customThemeName) {
          customThemeNameInput.value = customThemeName;
        }
        if (customThemeFruitSelect && customThemeFruit) {
          customThemeFruitSelect.value = customThemeFruit;
        }
        if (customThemeColorPicker && customThemeColor) {
          customThemeColorPicker.value = customThemeColor;
        }
        if (customThemeColorInput && customThemeColor) {
          customThemeColorInput.value = customThemeColor;
        }

        if (customThemeEnabled === true && customThemeColor) {
          const applied = await this.themeManager.applyCustomColorTheme(customThemeColor, customThemeName, customThemeFruit);
          if (applied) {
            this._setupCustomColorHandlers();
            return;
          }
        }

        let fruitFilename = fruitTheme;
        if (fruitTheme && fruitTheme.includes('/')) {
          fruitFilename = fruitTheme.split('/').pop();
        }

        if (fruitFilename && this.loginScreen._fruitImages.includes(fruitFilename)) {
          if (this.loginScreen.loginAppIconElem) {
            this.loginScreen.loginAppIconElem.src = `images/${fruitFilename}`;
            this.loginScreen.loginAppIconElem.style.filter = 'none';
            this.loginScreen._currentFruitIndex = this.loginScreen._fruitImages.indexOf(fruitFilename);
            this.themeManager.applyTheme(fruitFilename);
          }
        } else {
          this.themeManager.applyTheme(this.loginScreen._defaultFruit);
        }
        
        this._setupCustomColorHandlers();

      } catch (err) {
        console.warn('[Settings] Error loading settings:', err);
        this.themeManager.applyTheme(this.loginScreen._defaultFruit);
        this.uiManager._updateComponentVisibility();
      }
    }

    _setupCustomColorHandlers() {
      const { hexToCssFilter, normalizeHexColor } = window.LoginScreenUtilities || {};
      if (!hexToCssFilter || !normalizeHexColor) return;

      const customThemeEnabledToggle = this.loginScreen.shadowRoot.getElementById('custom-theme-enabled-toggle');
      const customThemeColorPicker = this.loginScreen.shadowRoot.getElementById('custom-theme-color-picker');
      const customThemeColorInput = this.loginScreen.shadowRoot.getElementById('custom-theme-color-input');
      const customThemeNameInput = this.loginScreen.shadowRoot.getElementById('custom-theme-name-input');
      const customThemeFruitSelect = this.loginScreen.shadowRoot.getElementById('custom-theme-fruit-select');
      const customThemeColorContainer = this.loginScreen.shadowRoot.getElementById('custom-theme-color-container');
      const customThemeColorPreview = this.loginScreen.shadowRoot.getElementById('custom-theme-color-preview');
      const resetCustomThemeColorBtn = this.loginScreen.shadowRoot.getElementById('reset-custom-theme-color-btn');

      if (!customThemeEnabledToggle || !customThemeColorContainer) return;

      const updateColorPreview = (color, fruit) => {
        const normalizedColor = normalizeHexColor(color);
        if (normalizedColor && customThemeColorPreview) {
          const filter = hexToCssFilter(normalizedColor);
          customThemeColorPreview.style.filter = filter;
          if (fruit) {
            customThemeColorPreview.src = `images/${fruit}`;
          }
        }
      };

      const syncColorInputs = (color, fruit) => {
        const normalizedColor = normalizeHexColor(color);
        if (normalizedColor) {
          if (customThemeColorPicker) customThemeColorPicker.value = normalizedColor;
          if (customThemeColorInput) customThemeColorInput.value = normalizedColor;
          updateColorPreview(normalizedColor, fruit || (customThemeFruitSelect ? customThemeFruitSelect.value : null));
        }
      };

      const toggleCustomThemeVisibility = () => {
        const isEnabled = customThemeEnabledToggle.checked;
        if (isEnabled) {
          customThemeColorContainer.style.opacity = '1';
          customThemeColorContainer.style.pointerEvents = 'auto';
          if (customThemeColorPicker) customThemeColorPicker.disabled = false;
          if (customThemeColorInput) customThemeColorInput.disabled = false;
          if (resetCustomThemeColorBtn) resetCustomThemeColorBtn.disabled = false;
          const currentColor = (customThemeColorPicker && customThemeColorPicker.value) || 
                              (customThemeColorInput && customThemeColorInput.value) || '#e83d52';
          const currentFruit = (customThemeFruitSelect && customThemeFruitSelect.value) || 'strawberry.png';
          updateColorPreview(currentColor, currentFruit);
        } else {
          customThemeColorContainer.style.opacity = '0.5';
          customThemeColorContainer.style.pointerEvents = 'none';
          if (customThemeColorPicker) customThemeColorPicker.disabled = true;
          if (customThemeColorInput) customThemeColorInput.disabled = true;
          if (resetCustomThemeColorBtn) resetCustomThemeColorBtn.disabled = true;
          if (customThemeColorPreview) customThemeColorPreview.style.filter = 'none';
        }
      };

      if (customThemeFruitSelect) {
        customThemeFruitSelect.addEventListener('change', () => {
          const selectedFruit = customThemeFruitSelect.value;
          const currentColor = (customThemeColorPicker && customThemeColorPicker.value) || 
                              (customThemeColorInput && customThemeColorInput.value) || '#e83d52';
          updateColorPreview(currentColor, selectedFruit);
          if (window.ipc && customThemeEnabledToggle && customThemeEnabledToggle.checked) {
            window.ipc.invoke('set-setting', 'ui.customThemeFruit', selectedFruit).catch(() => {});
            const currentName = (customThemeNameInput && customThemeNameInput.value) || 'Custom Jam';
            this.themeManager.applyCustomColorTheme(currentColor, currentName, selectedFruit);
          }
        });
      }

      if (customThemeNameInput) {
        customThemeNameInput.addEventListener('input', () => {
          if (window.ipc && customThemeEnabledToggle && customThemeEnabledToggle.checked) {
            const currentName = customThemeNameInput.value.trim() || 'Custom Jam';
            window.ipc.invoke('set-setting', 'ui.customThemeName', currentName).catch(() => {});
            const currentColor = (customThemeColorPicker && customThemeColorPicker.value) || 
                                (customThemeColorInput && customThemeColorInput.value) || '#e83d52';
            const currentFruit = (customThemeFruitSelect && customThemeFruitSelect.value) || 'strawberry.png';
            this.themeManager.applyCustomColorTheme(currentColor, currentName, currentFruit);
          }
        });
      }

      if (customThemeEnabledToggle) {
        customThemeEnabledToggle.addEventListener('change', async () => {
          toggleCustomThemeVisibility();
          const enabled = customThemeEnabledToggle.checked;
          if (window.ipc) {
            await window.ipc.invoke('set-setting', 'ui.customThemeEnabled', enabled).catch(() => {});
            if (enabled && customThemeColorPicker) {
              const color = customThemeColorPicker.value;
              const name = (customThemeNameInput && customThemeNameInput.value) || 'Custom Jam';
              const fruit = (customThemeFruitSelect && customThemeFruitSelect.value) || 'strawberry.png';
              await window.ipc.invoke('set-setting', 'ui.customThemeColor', color).catch(() => {});
              await window.ipc.invoke('set-setting', 'ui.customThemeName', name).catch(() => {});
              await window.ipc.invoke('set-setting', 'ui.customThemeFruit', fruit).catch(() => {});
              await this.themeManager.applyCustomColorTheme(color, name, fruit);
            } else {
              const fruitTheme = await window.ipc.invoke('get-setting', 'fruitTheme').catch(() => null);
              let fruitFilename = fruitTheme;
              if (fruitTheme && fruitTheme.includes('/')) {
                fruitFilename = fruitTheme.split('/').pop();
              }
              if (fruitFilename && this.loginScreen._fruitImages.includes(fruitFilename)) {
                if (this.loginScreen.loginAppIconElem) {
                  this.loginScreen.loginAppIconElem.src = `images/${fruitFilename}`;
                  this.loginScreen.loginAppIconElem.style.filter = 'none';
                  this.loginScreen._currentFruitIndex = this.loginScreen._fruitImages.indexOf(fruitFilename);
                }
                this.themeManager.applyTheme(fruitFilename);
              } else {
                if (this.loginScreen.loginAppIconElem) {
                  this.loginScreen.loginAppIconElem.src = `images/${this.loginScreen._defaultFruit}`;
                  this.loginScreen.loginAppIconElem.style.filter = 'none';
                }
                this.themeManager.applyTheme(this.loginScreen._defaultFruit);
              }
            }
          }
        });
      }

      if (customThemeColorPicker) {
        customThemeColorPicker.addEventListener('input', async () => {
          const color = customThemeColorPicker.value;
          syncColorInputs(color);
          if (window.ipc && customThemeEnabledToggle && customThemeEnabledToggle.checked) {
            await window.ipc.invoke('set-setting', 'ui.customThemeColor', color).catch(() => {});
            await this.themeManager.applyCustomColorTheme(color);
          }
        });
      }

      if (customThemeColorInput) {
        customThemeColorInput.addEventListener('input', () => {
          const color = customThemeColorInput.value;
          const normalizedColor = normalizeHexColor(color);
          if (normalizedColor && customThemeColorPicker) {
            customThemeColorPicker.value = normalizedColor;
            updateColorPreview(normalizedColor);
          }
        });

        customThemeColorInput.addEventListener('blur', async () => {
          const color = customThemeColorInput.value;
          const normalizedColor = normalizeHexColor(color);
          if (normalizedColor) {
            customThemeColorInput.value = normalizedColor;
            if (customThemeColorPicker) customThemeColorPicker.value = normalizedColor;
            if (window.ipc && customThemeEnabledToggle && customThemeEnabledToggle.checked) {
              await window.ipc.invoke('set-setting', 'ui.customThemeColor', normalizedColor).catch(() => {});
              await this.themeManager.applyCustomColorTheme(normalizedColor);
            }
          } else if (color.trim() !== '') {
            customThemeColorInput.value = '#e83d52';
            syncColorInputs('#e83d52');
          }
        });
      }

      if (resetCustomThemeColorBtn) {
        resetCustomThemeColorBtn.addEventListener('click', async () => {
          const currentFruit = (customThemeFruitSelect && customThemeFruitSelect.value) || 'strawberry.png';
          syncColorInputs('#e83d52', currentFruit);
          if (customThemeNameInput) customThemeNameInput.value = 'Custom Jam';
          if (customThemeFruitSelect) customThemeFruitSelect.value = 'strawberry.png';
          if (window.ipc && customThemeEnabledToggle && customThemeEnabledToggle.checked) {
            await window.ipc.invoke('set-setting', 'ui.customThemeColor', '#e83d52').catch(() => {});
            await window.ipc.invoke('set-setting', 'ui.customThemeName', 'Custom Jam').catch(() => {});
            await window.ipc.invoke('set-setting', 'ui.customThemeFruit', 'strawberry.png').catch(() => {});
            await this.themeManager.applyCustomColorTheme('#e83d52', 'Custom Jam', 'strawberry.png');
          }
        });
      }

      if (customThemeEnabledToggle) {
        const initialEnabled = customThemeEnabledToggle.checked;
        if (initialEnabled) {
          toggleCustomThemeVisibility();
        } else {
          customThemeColorContainer.style.opacity = '0.5';
          customThemeColorContainer.style.pointerEvents = 'none';
        }
      }

      if (customThemeColorPicker && customThemeColorInput) {
        const initialColor = customThemeColorPicker.value || customThemeColorInput.value || '#e83d52';
        const initialFruit = (customThemeFruitSelect && customThemeFruitSelect.value) || 'strawberry.png';
        syncColorInputs(initialColor, initialFruit);
      }
    }
  };
})();

