"use strict";

(() => {
  window.LoginScreenUIManager = class {
    constructor(loginScreenInstance) {
      this.loginScreen = loginScreenInstance;
    }

    toggleDarkMode(isDarkMode) {
      if (isDarkMode) {
        this.loginScreen.classList.add('dark-mode');
      } else {
        this.loginScreen.classList.remove('dark-mode');
      }

      const root = document.documentElement;
      if (isDarkMode) {
        root.style.setProperty('--theme-box-background', 'var(--theme-box-background-dark)');
      } else {
        root.style.setProperty('--theme-box-background', 'rgba(255, 245, 230, 0.95)');
      }

      this._syncDarkModeToChildComponents(isDarkMode);
    }

    _syncDarkModeToChildComponents(isDarkMode) {
      if (this.loginScreen.accountPanelInstance && typeof this.loginScreen.accountPanelInstance.setDarkMode === 'function') {
        try {
          this.loginScreen.accountPanelInstance.setDarkMode(isDarkMode);
        } catch (error) {
          console.warn('[LoginScreenUIManager] Failed to set dark mode on accountPanelInstance:', error);
        }
      } else {
        setTimeout(() => {
          if (this.loginScreen.accountPanelInstance && typeof this.loginScreen.accountPanelInstance.setDarkMode === 'function') {
            try {
              this.loginScreen.accountPanelInstance.setDarkMode(isDarkMode);
            } catch (error) {
              console.warn('[LoginScreenUIManager] Failed to set dark mode on accountPanelInstance (retry):', error);
            }
          }
        }, 100);
      }

      if (this.loginScreen.autoWheelButtonInstance && typeof this.loginScreen.autoWheelButtonInstance.setDarkMode === 'function') {
        try {
          this.loginScreen.autoWheelButtonInstance.setDarkMode(isDarkMode);
        } catch (error) {
          console.warn('[LoginScreenUIManager] Failed to set dark mode on autoWheelButtonInstance:', error);
        }
      }
    }

    toggleUIElements() {
      this.loginScreen._uiElementsHidden = !this.loginScreen._uiElementsHidden;
      
      if (this.loginScreen.settingsBtn) {
        this.loginScreen.settingsBtn.style.display = this.loginScreen._uiElementsHidden ? 'none' : 'flex';
      }
      if (this.loginScreen.devtoolsBtn) {
        this.loginScreen.devtoolsBtn.style.display = this.loginScreen._uiElementsHidden ? 'none' : 'flex';
      }
      
      if (window.UserTrayManager && window.UserTrayManager.instance) {
        if (this.loginScreen._uiElementsHidden) {
          window.UserTrayManager.hide();
        } else {
          window.UserTrayManager.show();
        }
      }
      
      if (this.loginScreen._uiElementsHidden && this.loginScreen.settingsPanel) {
        this.loginScreen.settingsPanel.classList.remove('show');
      }
    }

    _updateComponentVisibility() {
      const importSection = this.loginScreen.shadowRoot.getElementById('import-section');
      const autoWheelSection = this.loginScreen.shadowRoot.getElementById('auto-wheel-section');

      if (importSection) {
        if (this.loginScreen.showImportAccountsToggle && this.loginScreen.showImportAccountsToggle.checked) {
          importSection.classList.add('visible');
        } else {
          importSection.classList.remove('visible');
        }
      }

      if (autoWheelSection) {
        if (this.loginScreen.showWheelAutomationToggle && this.loginScreen.showWheelAutomationToggle.checked) {
          autoWheelSection.classList.add('visible');
        } else {
          autoWheelSection.classList.remove('visible');
        }
      }
    }
  };
})();

