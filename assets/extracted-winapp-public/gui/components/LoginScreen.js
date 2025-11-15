"use strict";

(() => {
  customElements.define("ajd-login-screen", class extends HTMLElement {
    // Class-level variables to make them accessible across methods
    _fruitImages = [];
    _currentFruitIndex = 0;
    _fruitThemes = {};

    static get observedAttributes() {
      return [];
    }

    constructor() {
      super();
      // this._accountsLoaded = false; // Flag will be managed by AccountManagementPanel or not needed here

            this.attachShadow({mode: "open"}).innerHTML = window.LoginScreenTemplate();


      // --- Core Login State ---
      this._authToken = null;
      this._refreshToken = null;
      this._otp = null;
      this._isFakePassword = false;
      this._version = "";

      // --- Core Login Element References ---
      this.loginSpinnerElem = this.shadowRoot.getElementById("spinner");
      this.versionElem = this.shadowRoot.getElementById("version");
      this.versionLinkElem = this.shadowRoot.getElementById("version-link");
      this.versionStatusIconElem = this.shadowRoot.getElementById("version-status-icon");
      this.usernameInputElem = this.shadowRoot.getElementById("username-input");
      this.passwordInputElem = this.shadowRoot.getElementById("password-input");
      this.rememberMeElem = this.shadowRoot.getElementById("remember-me-cb");
      this.forgotPasswordLinkElem = this.shadowRoot.getElementById("forgot-password-link");
      this.needAccountElem = this.shadowRoot.getElementById("need-account");
      this.createAnAnimalTextElem = this.shadowRoot.getElementById("create-an-animal"); // Note: Element ID seems incorrect in original HTML?
      this.playerLoginTextElem = this.shadowRoot.getElementById("player-login-text");
      this.createAccountElem = this.shadowRoot.getElementById("create-account-btn");
      this.logInButtonElem = this.shadowRoot.getElementById("log-in-btn");
      this.expandButtonElement = this.shadowRoot.getElementById("expand-button");
      this.closeButtonElement = this.shadowRoot.getElementById("close-button");
      this.loginAppIconElem = this.shadowRoot.getElementById("login-app-icon"); // Get reference to the icon
      this.accountPanelInstance = this.shadowRoot.getElementById("account-panel-instance"); // Reference to the new panel
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

      // --- Settings Element References ---
      this.settingsBtn = this.shadowRoot.getElementById("settings-btn");
      this.reportProblemBtn = this.shadowRoot.getElementById("report-problem-btn"); // Get report button
      this.settingsPanel = this.shadowRoot.getElementById("settings-panel");
      this.uuidSpooferToggle = this.shadowRoot.getElementById("uuid-spoofer-toggle");
      this.backgroundProcessingToggle = this.shadowRoot.getElementById("background-processing-toggle");
      this.darkModeToggle = this.shadowRoot.getElementById("dark-mode-toggle");
      this.showImportAccountsToggle = this.shadowRoot.getElementById("show-import-accounts-toggle");
      this.showWheelAutomationToggle = this.shadowRoot.getElementById("show-wheel-automation-toggle");
      
      // Track UI visibility state for hotkey toggle
      this._uiElementsHidden = false;

      // Listener for 'set-main-log-path' is removed as we are saving to Desktop.
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

      setTimeout(() => {
        this.settingsInitializer._initializeAsyncSettings();
        this.settingsInitializer.initializeSettings();
      }, 100);

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
