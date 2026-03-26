"use strict";

(() => {
  customElements.define("ajd-login-screen", class extends HTMLElement {
    _fruitImages = [];
    _currentFruitIndex = 0;
    _fruitThemes = {};

    static get observedAttributes() {
      return [];
    }

    constructor() {
      super();
            this.attachShadow({mode: "open"}).innerHTML = window.LoginScreenTemplate();

      this._authToken = null;
      this._refreshToken = null;
      this._otp = null;
      this._isFakePassword = false;
      this._version = "";

      this.loginSpinnerElem = this.shadowRoot.getElementById("spinner");
      this.versionElem = this.shadowRoot.getElementById("version");
      this.versionLinkElem = this.shadowRoot.getElementById("version-link");
      this.versionStatusIconElem = this.shadowRoot.getElementById("version-status-icon");
      this.usernameInputElem = this.shadowRoot.getElementById("username-input");
      this.passwordInputElem = this.shadowRoot.getElementById("password-input");
      this.rememberMeElem = this.shadowRoot.getElementById("remember-me-cb");
      this.forgotPasswordLinkElem = this.shadowRoot.getElementById("forgot-password-link");
      this.needAccountElem = this.shadowRoot.getElementById("need-account");
      this.createAnAnimalTextElem = this.shadowRoot.getElementById("create-an-animal");
      this.playerLoginTextElem = this.shadowRoot.getElementById("player-login-text");
      this.createAccountElem = this.shadowRoot.getElementById("create-account-btn");
      this.logInButtonElem = this.shadowRoot.getElementById("log-in-btn");
      this.expandButtonElement = this.shadowRoot.getElementById("expand-button");
      this.closeButtonElement = this.shadowRoot.getElementById("close-button");
      this.loginAppIconElem = this.shadowRoot.getElementById("login-app-icon");
      this.accountPanelInstance = this.shadowRoot.getElementById("account-panel-instance");
      this.importButtonInstance = this.shadowRoot.getElementById("import-button-instance");
      this.autoWheelButtonInstance = this.shadowRoot.getElementById("auto-wheel-button-instance");
      this.userTray = null;



      const themeConfig = window.LoginScreenThemes;
      this._fruitThemes = themeConfig.getThemes();
      this._fruitImages = themeConfig.getFruitImages();
      const defaultFruit = themeConfig.getDefaultFruit();
      this._defaultFruit = defaultFruit;

      if (this.loginAppIconElem) {
        this._currentFruitIndex = this._fruitImages.findIndex(src => this.loginAppIconElem.src.endsWith(src));
        if (this._currentFruitIndex === -1) {
          this._currentFruitIndex = this._fruitImages.indexOf(this._defaultFruit);
        }
        if (this._currentFruitIndex === -1 && this._fruitImages.length > 0) {
          this._currentFruitIndex = 0; 
        }
      } else {
        this._currentFruitIndex = 0;
      }

      this.settingsBtn = this.shadowRoot.getElementById("settings-btn");
      this.devtoolsBtn = this.shadowRoot.getElementById("devtools-btn");
      this.devtoolsErrorBadge = this.shadowRoot.getElementById("devtools-error-badge");
      this.settingsPanel = this.shadowRoot.getElementById("settings-panel");
      this._loginHelpPrompt = this.shadowRoot.getElementById("login-help-prompt");

      this.errorCount = 0;
      this.setupErrorTracking();
      this._setupLoginHelpPrompt();
      
      this.uuidSpooferToggle = this.shadowRoot.getElementById("uuid-spoofer-toggle");
      this.backgroundProcessingToggle = this.shadowRoot.getElementById("background-processing-toggle");
      this.modMenuBtnToggle = this.shadowRoot.getElementById("mod-menu-btn-toggle");
      this.darkModeToggle = this.shadowRoot.getElementById("dark-mode-toggle");
      this.showImportAccountsToggle = this.shadowRoot.getElementById("show-import-accounts-toggle");
      this.showWheelAutomationToggle = this.shadowRoot.getElementById("show-wheel-automation-toggle");
      this.hideDevToolsBadgeToggle = this.shadowRoot.getElementById("hide-devtools-badge-toggle");
      
      this._uiElementsHidden = false;
      this._hideDevToolsBadge = false;

      this.uuidSpoofingWarning = this.shadowRoot.getElementById("uuid-spoofing-warning");
      this.serverSwapSelect = this.shadowRoot.getElementById("server-swap-select");
      
      this.countryOverrideInput = this.shadowRoot.getElementById("country-override");
      this.localeOverrideInput = this.shadowRoot.getElementById("locale-override");
      this.saveDebugSettingsBtn = this.shadowRoot.getElementById("save-debug-settings");
      
      if (this.saveDebugSettingsBtn) {
        this.saveDebugSettingsBtn.addEventListener('click', async () => {
          if (this.countryOverrideInput) {
            const country = this.countryOverrideInput.value.trim();
            await window.ipc.invoke('set-setting', 'debug.country', country);
          }
          if (this.localeOverrideInput) {
            const locale = this.localeOverrideInput.value.trim();
            await window.ipc.invoke('set-setting', 'debug.locale', locale);
          }
          window.alert('Debug settings saved. Changes will apply on next login.');
          if (this.settingsPanel) {
            this.settingsPanel.classList.remove('show');
          }
        });
      }

      if (this.serverSwapSelect) {
        this.serverSwapSelect.addEventListener('change', async (e) => {
          const locale = e.target.value;
          await window.ipc.invoke('set-setting', 'login.language', locale);
          await window.ipc.invoke('set-setting', 'debug.locale', locale);
          await window.ipc.invoke('set-setting', 'debug.country', '');
          if (globals && globals.setLanguage && locale) {
            globals.setLanguage(locale);
          }
          window.alert(`Server swap set to ${locale || 'Default'}. Changes will apply on next login.`);
          if (this.settingsPanel) {
            this.settingsPanel.classList.remove('show');
          }
        });
      }

      this.themeManager = new window.LoginScreenThemeManager(this);
      this.uiManager = new window.LoginScreenUIManager(this);
      this.authManager = new window.LoginScreenAuthManager(this);
      this.settingsInitializer = new window.LoginScreenSettingsInitializer(this, this.themeManager, this.uiManager);
      this.eventHandler = new window.LoginScreenEventHandler(this, this.authManager, this.themeManager, this.uiManager);

      this.themeManager.setupFruitRotation();
      this.eventHandler.setupEventListeners();

      this.settingsInitializer._initializeAllSettings().then(() => {
        this.classList.add('theme-ready');
      }).catch(() => {
        this.classList.add('theme-ready');
      });

      setTimeout(() => {
        if (!this.classList.contains('theme-ready')) {
          console.warn('[LoginScreen] Settings loading timeout - showing with default theme');
          this.classList.add('theme-ready');
        }
      }, 5000);

    }

    applyTheme(fruitKey) {
      this.themeManager.applyTheme(fruitKey);
    }

    toggleDarkMode(isDarkMode) {
      this.uiManager.toggleDarkMode(isDarkMode);
    }

    toggleUIElements() {
      this.uiManager.toggleUIElements();
    }

    _updateComponentVisibility() {
      this.uiManager._updateComponentVisibility();
    }

    async logIn() {
      await this.authManager.logIn();
    }

    canRetry() {
      return this.authManager.canRetry();
    }

    get loginBlocked() {
      const loginButtonDisabled = this.logInButtonElem ? this.logInButtonElem.disabled : true;
      const createAccountDisabled = this.createAccountElem ? this.createAccountElem.disabled : true;
      return loginButtonDisabled || createAccountDisabled;
    }

    set loginBlocked(val) {
      if (this.logInButtonElem) this.logInButtonElem.disabled = val;
      if (this.createAccountElem) this.createAccountElem.disabled = val;
      if (this.loginSpinnerElem) {
          if (val) {
              this.loginSpinnerElem.classList.add("show");
          } else {
              setTimeout(() => {
                  if (this.loginSpinnerElem) this.loginSpinnerElem.classList.remove("show");
              }, 250);
          }
      }
      if (!val && globals.currentAbortController) {
          globals.currentAbortController = null;
      }
    }

    get username() { return this.usernameInputElem.value; }
    set username(val) { this.usernameInputElem.value = val; }
    get password() { return this.passwordInputElem.value; }
    set password(val) { this.passwordInputElem.value = val; }
    get isFakePassword() { return this._isFakePassword; }
    set isFakePassword(val) {
      this._isFakePassword = val;
      if (val) this.password = "FAKE_PASSWORD";
    }
    get rememberMe() { return this.rememberMeElem.value; }
    set rememberMe(val) { this.rememberMeElem.value = val; }
    get version() { return this._version; }
    set version(val) {
      this._version = val;
      this.versionLinkElem.innerHTML = `v${val}`;
    }
    setProgress(progress) {
      if (progress === null) {
        this.versionStatusIconElem.setAttribute("progress", 0);
        this.version = this._version;
      } else {
        this.versionStatusIconElem.setAttribute("progress", progress);
        this.versionLinkElem.innerHTML = `${progress}%`;
      }
    }
    get otp() { return this._otp; }
    set otp(val) { this._otp = val; }
    get authToken() { return this._authToken; }
    set authToken(val) { this._authToken = val; }
    clearAuthToken() {
      this.authToken = null;
      window.ipc.send("clearAuthToken");
    }
    get refreshToken() { return this._refreshToken; }
    set refreshToken(val) { this._refreshToken = val; }
    clearRefreshToken() {
      this.refreshToken = null;
      window.ipc.send("clearRefreshToken");
    }

    setupErrorTracking() {
      const originalLog = console.log;
      const originalInfo = console.info;
      const originalError = console.error;
      const originalWarn = console.warn;
      const self = this;
      const capture = window.LoginScreenUtilities ? window.LoginScreenUtilities.captureLog : null;

      console.log = function(...args) {
        if (capture) capture('log', ...args);
        originalLog.apply(console, args);
      };

      console.info = function(...args) {
        if (capture) capture('info', ...args);
        originalInfo.apply(console, args);
      };

      console.error = function(...args) {
        if (capture) capture('error', ...args);
        self.errorCount++;
        self.updateErrorBadge();
        originalError.apply(console, args);
      };

      console.warn = function(...args) {
        if (capture) capture('warn', ...args);
        self.errorCount++;
        self.updateErrorBadge();
        originalWarn.apply(console, args);
      };
      
      window.addEventListener('error', (event) => {
        self.errorCount++;
        self.updateErrorBadge();
      });
      
      window.addEventListener('unhandledrejection', (event) => {
        self.errorCount++;
        self.updateErrorBadge();
      });
      
      if (window.ipc && window.ipc.on) {
        console.log('[LoginScreen] Setting up game-webview-console-error listener');
        window.ipc.on('game-webview-console-error', () => {
          console.log('[LoginScreen] Received game-webview-console-error, incrementing badge');
          self.errorCount++;
          self.updateErrorBadge();
        });
      } else {
        console.warn('[LoginScreen] window.ipc.on not available for error tracking');
      }
    }
    
    updateErrorBadge() {
      if (this.devtoolsErrorBadge) {
        this.devtoolsErrorBadge.textContent = this.errorCount;
        if (this.errorCount > 0 && !this._hideDevToolsBadge) {
          this.devtoolsErrorBadge.classList.add('show');
          this.devtoolsBtn.setAttribute('title', `View Debug Logs (${this.errorCount} error${this.errorCount !== 1 ? 's' : ''} detected)`);
        } else {
          this.devtoolsErrorBadge.classList.remove('show');
          if (this.errorCount > 0 && this._hideDevToolsBadge) {
            this.devtoolsBtn.setAttribute('title', `View Debug Logs (${this.errorCount} error${this.errorCount !== 1 ? 's' : ''} detected, badge hidden)`);
          } else {
            this.devtoolsBtn.setAttribute('title', 'View Debug Logs');
          }
        }
      }
    }

    _setupLoginHelpPrompt() {
      const viewLogsBtn = this.shadowRoot.getElementById("help-prompt-view-logs");
      const dismissBtn = this.shadowRoot.getElementById("help-prompt-dismiss");

      if (viewLogsBtn) {
        viewLogsBtn.addEventListener("click", () => {
          this.hideLoginHelpPrompt();
          this.openDebugLogModal(true);
        });
      }

      if (dismissBtn) {
        dismissBtn.addEventListener("click", () => {
          this.hideLoginHelpPrompt();
        });
      }
    }

    showLoginHelpPrompt() {
      if (this._loginHelpPrompt) {
        this._loginHelpPrompt.classList.add("show");
      }
    }

    hideLoginHelpPrompt() {
      if (this._loginHelpPrompt) {
        this._loginHelpPrompt.classList.remove("show");
      }
    }

    openDebugLogModal(showHelpBanner = false) {
      const modalLayer = document.getElementById('modal-layer');
      if (!modalLayer) return;

      const existing = modalLayer.querySelector('ajd-debug-log-modal');
      if (existing) return;

      const modal = document.createElement('ajd-debug-log-modal');
      modal.errorCount = this.errorCount;
      modal.showHelpBanner = showHelpBanner;
      modal.addEventListener('close', () => {
        modalLayer.removeChild(modal);
        this.errorCount = 0;
        this.updateErrorBadge();
      });
      modalLayer.appendChild(modal);
    }

    async localize() {
      this.usernameInputElem.placeholder = await globals.translate("username");
      this.passwordInputElem.placeholder = await globals.translate("password");
      this.rememberMeElem.text = await globals.translate("rememberMeText");
      this.logInButtonElem.text = await globals.translate("login");
      this.forgotPasswordLinkElem.innerText = await globals.translate("forgotPassword");
      this.needAccountElem.innerText = await globals.translate("needAccount");
      this.createAccountElem.text = await globals.translate("createAccount");
    }

    async connectedCallback() {
      await this.eventHandler.connectedCallback();
    }

  });
})();
