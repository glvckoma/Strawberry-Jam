"use strict";

// are now called directly in the constructor. They are expected to be globally available

(() => {
  const { forgotPassword, getConsoleLogs } = window.LoginScreenUtilities;
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



      // --- Fruit Rotation & Theming Setup (CLASS LEVEL) ---
      const themeConfig = window.LoginScreenThemes;
      this._fruitThemes = themeConfig.getThemes();
      this._fruitImages = themeConfig.getFruitImages();
      const defaultFruit = themeConfig.getDefaultFruit();
      this._defaultFruit = defaultFruit;


      
      // Determine initial _currentFruitIndex based on loginAppIconElem.src
      // This ensures _currentFruitIndex is set before initializeSettings might try to use it via applyTheme
      if (this.loginAppIconElem) {
        this._currentFruitIndex = this._fruitImages.findIndex(src => this.loginAppIconElem.src.endsWith(src));
        if (this._currentFruitIndex === -1) {
            this._currentFruitIndex = this._fruitImages.indexOf(this._defaultFruit); // Default to configured fruit
        }
        if (this._currentFruitIndex === -1 && this._fruitImages.length > 0) { // Fallback if strawberry.png isn't in the list for some reason
            this._currentFruitIndex = 0; 
        }
      } else {
        this._currentFruitIndex = 0; // Absolute fallback
      }
      
      if (this.loginAppIconElem) {
        this.loginAppIconElem.style.cursor = 'pointer';
        this.loginAppIconElem.addEventListener('click', () => {
          this._currentFruitIndex = (this._currentFruitIndex + 1) % this._fruitImages.length;
          const nextFruitKey = this._fruitImages[this._currentFruitIndex];
          
          this.loginAppIconElem.src = `images/${nextFruitKey}`;
          this.applyTheme(nextFruitKey);

          if (window.ipc) {
            window.ipc.invoke('set-setting', 'fruitTheme', nextFruitKey)
              .catch(err => {});
          }

          this.loginAppIconElem.classList.remove('fruit-animate'); 
          void this.loginAppIconElem.offsetWidth; 
          this.loginAppIconElem.classList.add('fruit-animate'); 

          setTimeout(() => {
              if (this.loginAppIconElem) { 
                   this.loginAppIconElem.classList.remove('fruit-animate');
              }
          }, 300); 
        });
      }
      // --- End CLASS LEVEL Fruit Rotation Logic ---

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

      // --- Core Login Event Listeners ---
      this.loginSpinnerElem.addEventListener("click", event => {
        if (globals.userAbortController) globals.userAbortController.abort();
      });
      this.versionElem.addEventListener("click", () => {
        window.ipc.send("about");
      });
      this.usernameInputElem.addEventListener("keydown", event => event.key === "Enter" ? this.logIn() : "");
      this.usernameInputElem.addEventListener("input", event => {
        if (this.authToken) this.clearAuthToken();
        if (this.refreshToken) this.clearRefreshToken();
      });
      this.passwordInputElem.addEventListener("keydown", event => event.key === "Enter" ? this.logIn() : "");
      this.passwordInputElem.addEventListener("input", event => {
        if (this.isFakePassword) this.isFakePassword = false;
        if (this.authToken) this.clearAuthToken();
        if (this.refreshToken) this.clearRefreshToken();
      });
      this.rememberMeElem.addEventListener("click", event => {
        window.ipc.send("rememberMeStateUpdated", {newValue: this.rememberMeElem.value});
      });
      this.forgotPasswordLinkElem.addEventListener("click", () => {
        if (this.loginBlocked) return;
        forgotPassword();
      });
      this.createAccountElem.addEventListener("click", async () => {
        console.log(`[CREATE ACCOUNT] ============= Starting create account process =============`);
        if (this.loginBlocked) {
          console.log(`[CREATE ACCOUNT] Create account blocked, returning early`);
          return;
        }
        this.loginBlocked = true;
        try {
          console.log(`[CREATE ACCOUNT] Requesting FlashVars for account creation`);
          const flashVars = await globals.getFlashVarsFromWeb();
          
          // Get the actual API server port, defaulting to 8080 if not available
          const apiPort = await window.ipc.invoke('get-api-port').catch(() => '8080');
          
          console.log(`[CREATE ACCOUNT] Configuring FlashVars for local proxy - API Port: ${apiPort}`);
          
          // Override asset URLs so Create-Account also uses the local proxy instead of the official CDN
          flashVars.content = `http://localhost:${apiPort}/`;
          if (flashVars.deploy_version) {
            flashVars.clientURL = `http://localhost:${apiPort}/${flashVars.deploy_version}/ajclient.swf`;
          }
          flashVars.smartfoxServer = 'localhost';          // or your proxy host
          flashVars.blueboxServer = 'localhost';
          
          // Get the actual server port, defaulting to 443 if not available
          const serverPort = await window.ipc.invoke('get-server-port').catch(() => '443');
          console.log(`[CREATE ACCOUNT] Using server port: ${serverPort}`);
          flashVars.blueboxPort   = serverPort.toString();
          flashVars.smartfoxPort  = serverPort.toString();

          flashVars.playerWallHost   = `http://localhost:${apiPort}/wall/`;
          flashVars.sbStatTrackerIp  = 'localhost';

          flashVars.website = `http://localhost:${apiPort}/`;
          flashVars.mdUrl   = `http://localhost:${apiPort}/game/`;

          console.log(`[CREATE ACCOUNT] Final FlashVars configuration:`, {
            deploy_version: flashVars.deploy_version,
            clientURL: flashVars.clientURL,
            content: flashVars.content,
            smartfoxServer: flashVars.smartfoxServer,
            blueboxServer: flashVars.blueboxServer,
            blueboxPort: flashVars.blueboxPort,
            smartfoxPort: flashVars.smartfoxPort,
            locale: globals.language,
            webRefPath: "create_account",
            affiliate_code: globals.affiliateCode
          });

          Object.assign(
            flashVars,
            globals.getClientData(),
            { locale: globals.language, webRefPath: "create_account" },
            globals.affiliateCode ? { affiliate_code: globals.affiliateCode } : {}
          );
          
          console.log(`[CREATE ACCOUNT] Dispatching loggedIn event for account creation`);
          this.dispatchEvent(new CustomEvent("loggedIn", {detail: {flashVars}}));
        } catch (err) {
          console.error(`[CREATE ACCOUNT] Error during account creation:`, err);
          globals.reportError("webClient", `Error creating account: ${err.stack || err.message}`);
          if (err.name != "Aborted") window.alert("Something went wrong :(");
          this.loginBlocked = false;
        }
      });
      this.logInButtonElem.addEventListener("click", () => {
          globals.currentAbortController = new AbortController();
          this.logIn();
      });
      this.expandButtonElement.addEventListener("click", event => {
        window.ipc.send("systemCommand", {command: "toggleFullScreen"});
      });
      this.closeButtonElement.addEventListener("click", event => {
        window.ipc.send("systemCommand", {command: "exit"});
      });

      // --- Core Login IPC Listeners ---
      window.ipc.on("autoUpdateStatus", (event, data) => {
        for (const state of ["check", "download", "restart", "error"]) {
          this.versionStatusIconElem.classList.remove(state);
          if (state == data.state) this.versionStatusIconElem.classList.add(data.state);
        }
        this.setProgress(data.progress || null);
      });
      window.ipc.on("screenChange", (event, state) => {
        const buttonTray = this.shadowRoot.getElementById("button-tray");
        const hostElement = this.shadowRoot.host;
        if (state === "fullScreen" && globals.systemData.platform === "win32") {
          buttonTray.classList.remove("hidden");
          hostElement.classList.add("fullscreen-active");
        } else {
          buttonTray.classList.add("hidden");
          hostElement.classList.remove("fullscreen-active");
        }
      });

      // --- Settings Initialization ---
      this.settingsBtn.addEventListener('click', (event) => {
        event.stopPropagation(); // Prevent click from immediately closing panel via document listener
        this.settingsPanel.classList.toggle('show');
      });

      if (this.reportProblemBtn) {
        this.reportProblemBtn.addEventListener('click', () => { // Reverted from async
          
          const logsToReport = [...getConsoleLogs()];
          
          if (window.ipc && window.ipc.electronOs && window.ipc.electronOs.homedir &&
              window.ipc.electronPath && window.ipc.electronPath.join &&
              window.ipc.electronFs && window.ipc.electronFs.writeFileSync) {
            try {
              const fsOps = window.ipc.electronFs;
              const pathOps = window.ipc.electronPath;
              const osOps = window.ipc.electronOs; // This should correctly reference window.ipc.electronOs

              // Ensure osOps and osOps.homedir are available before calling
              if (!osOps || typeof osOps.homedir !== 'function') {
                throw new Error("osOps or osOps.homedir is not available via preload.");
              }

              const homeDir = osOps.homedir(); // Correctly using osOps
              if (!homeDir) {
                throw new Error("Could not determine user's home directory via osOps.homedir().");
              }
              const desktopPath = pathOps.join(homeDir, 'Desktop');
              
              // Ensure Desktop directory exists (optional, as writeFileSync might create parent dirs if configured, but good practice)
              // For simplicity, we'll assume Desktop exists or fsOps.writeFileSync can handle it.
              // If not, fsOps.mkdirSync(desktopPath, { recursive: true }) could be added.

              const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
              const filename = `winapp-desktop-report-${timestamp}.log`;
              const filePath = pathOps.join(desktopPath, filename);
              
              let logContent = `## Login Screen UI Logs (Report a Problem - Saved to Desktop)\n`;
              logContent += `Timestamp: ${new Date().toISOString()}\n`;
              logContent += `URL: ${window.location.href}\n`;
              logContent += `User Agent: ${navigator.userAgent}\n\n`;
              
              logsToReport.forEach(log => {
                logContent += `[${log.timestamp}] [${log.level}] ${log.message}\n`;
              });

              // Append game client logs if they exist
              if (window.gameClientConsoleLogs && window.gameClientConsoleLogs.length > 0) {
                logContent += `\n\n## Game Client Logs\n`;
                window.gameClientConsoleLogs.forEach(log => {
                  logContent += `[${log.timestamp}] [${log.level}] ${log.message}\n`;
                });
              }
              
              fsOps.writeFileSync(filePath, logContent, 'utf8');
              alert(`Logs saved to your Desktop: ${filename}\nSubmit the logs in #tickets channel to recieve help`);

              // Log Rotation Logic for Desktop files REMOVED as per user request.
              // Files will now accumulate on the Desktop.

            } catch (err) {
              console.error('[LoginScreen] Error saving logs to Desktop:', err);
              alert(`Error saving logs to Desktop: ${err.message}\nPlease check the console for details.`);
            }
          } else {
            let reason = "Required modules (os, path, or fs) are not properly exposed from the preload script to save logs to Desktop.";
            console.warn(`[LoginScreen] Cannot save logs to Desktop: ${reason}`);
            alert(`Could not save logs to Desktop.\nReason: ${reason}\n\nPlease check the developer console for more detailed error messages.`);
          }
        });
      }
      
      document.addEventListener('click', (event) => {
        // Ensure settingsPanel and settingsBtn are valid before checking composedPath
        if (!this.settingsPanel || !this.settingsBtn) return;

        const path = event.composedPath ? event.composedPath() : event.path;
        if (path && !path.includes(this.settingsPanel) && !path.includes(this.settingsBtn)) {
          if (this.settingsPanel.classList.contains('show')) {
            this.settingsPanel.classList.remove('show');
          }
        }
      });
      
      if (this.uuidSpooferToggle) {
        this.uuidSpooferToggle.addEventListener('change', async () => {
          if (this.uuidSpooferToggle.checked) {
            try {
              const result = await window.ipc.invoke('toggle-uuid-spoofing', true);
              if (!result || !result.success) {
                this.uuidSpooferToggle.checked = false;
                return;
              }
              this.uuidSpoofingWarning.classList.add('show');
            } catch (err) {
              this.uuidSpooferToggle.checked = false;
              return;
            }
          } else {
            await window.ipc.invoke('toggle-uuid-spoofing', false);
            this.uuidSpoofingWarning.classList.remove('show');
            globals.df = null;
          }
        });
      }

      if (this.backgroundProcessingToggle) {
        this.backgroundProcessingToggle.addEventListener('change', async () => {
          try {
            await window.ipc.invoke('set-setting', 'backgroundProcessing', this.backgroundProcessingToggle.checked);
          } catch (err) {
            console.error('Failed to save background processing setting:', err);
          }
        });
      }

      if (this.darkModeToggle) {
        this.darkModeToggle.addEventListener('change', async () => {
          try {
            const isDarkMode = this.darkModeToggle.checked;
            await window.ipc.invoke('set-setting', 'darkMode', isDarkMode);
            this.toggleDarkMode(isDarkMode);
          } catch (err) {
            console.error('Failed to save dark mode setting:', err);
          }
        });
      }
      
      if (this.serverSwapSelect) {
        this.serverSwapSelect.addEventListener('change', (e) => {
          const newLanguage = e.target.value;
          window.ipc.invoke('set-setting', 'login.language', newLanguage);
          if (globals && globals.setLanguage) {
            globals.setLanguage(newLanguage);
          }
        });
      }

      // Add event listeners for UI component toggles
      if (this.showImportAccountsToggle) {
        this.showImportAccountsToggle.addEventListener('change', async () => {
          try {
            await window.ipc.invoke('set-setting', 'ui.showImportAccounts', this.showImportAccountsToggle.checked);
            this._updateComponentVisibility();
          } catch (err) {
            console.error('Failed to save show import accounts setting:', err);
          }
        });
      }

      if (this.showWheelAutomationToggle) {
        this.showWheelAutomationToggle.addEventListener('change', async () => {
          try {
            await window.ipc.invoke('set-setting', 'ui.showWheelAutomation', this.showWheelAutomationToggle.checked);
            this._updateComponentVisibility();
          } catch (err) {
            console.error('Failed to save show wheel automation setting:', err);
          }
        });
      }

      // --- Hotkey Event Listener ---
      document.addEventListener('keydown', (event) => {
        // Ctrl + Shift + H: Toggle UI elements (settings/report buttons and user tray)
        if (event.ctrlKey && event.shiftKey && event.key === 'H') {
          event.preventDefault();
          this.toggleUIElements();
        }
      });

      setTimeout(() => {
        this._initializeAsyncSettings();
        this.initializeSettings();
      }, 100);

    } // End Constructor

    isLightColor(hexColor) {
      if (!hexColor || hexColor.length < 7) return false; 
      const r = parseInt(hexColor.slice(1, 3), 16);
      const g = parseInt(hexColor.slice(3, 5), 16);
      const b = parseInt(hexColor.slice(5, 7), 16);
      const luminance = (r * 299 + g * 587 + b * 114) / 1000;
      return luminance > 150; 
    }

    darkenColor(hex, percent) { // This is the class method
      if (!hex || hex.length < 7) return hex;
      let r = parseInt(hex.slice(1, 3), 16);
      let g = parseInt(hex.slice(3, 5), 16);
      let b = parseInt(hex.slice(5, 7), 16);
      r = Math.max(0, Math.min(255, r - (r * (percent / 100))));
      g = Math.max(0, Math.min(255, g - (g * (percent / 100))));
      b = Math.max(0, Math.min(255, b - (b * (percent / 100))));
      return `#${Math.round(r).toString(16).padStart(2, '0')}${Math.round(g).toString(16).padStart(2, '0')}${Math.round(b).toString(16).padStart(2, '0')}`;
    }

    applyTheme(fruitKey) {
      const theme = this._fruitThemes[fruitKey]; // Uses class _fruitThemes
      if (!theme) {
        return;
      }
      const root = this.shadowRoot.host;

      let fruitName = fruitKey.replace('.png', '');
      if (fruitName === 'blueberries') {
        fruitName = 'blueberry';
      }
      const displayName = fruitName.charAt(0).toUpperCase() + fruitName.slice(1) + ' Jam';

      if (this.playerLoginTextElem) {
        this.playerLoginTextElem.innerText = displayName;
      }
      
      const primaryIsLight = this.isLightColor(theme.primary); // Uses class isLightColor

      root.style.setProperty('--theme-primary', theme.primary);
      root.style.setProperty('--theme-secondary', theme.secondary);
      root.style.setProperty('--theme-highlight', theme.highlight);
      root.style.setProperty('--theme-shadow', theme.shadow);
      root.style.setProperty('--theme-gradient-start', theme.gradientStart);
      root.style.setProperty('--theme-gradient-end', theme.gradientEnd);
      root.style.setProperty('--theme-hover-border', theme.hoverBorder);
      root.style.setProperty('--theme-radial-1', theme.radial1);
      root.style.setProperty('--theme-radial-2', theme.radial2);
      root.style.setProperty('--theme-settings-hover', theme.settingsHover);
      root.style.setProperty('--theme-settings-border', theme.settingsBorder);

      if (primaryIsLight && (fruitKey === 'banana.png' || fruitKey === 'pineapple.png')) {
        root.style.setProperty('--theme-box-background', 'rgba(225, 210, 180, 0.97)');
        root.style.setProperty('--theme-text-shadow', '0 1px 1px rgba(0, 0, 0, 0.5)');
        root.style.setProperty('--theme-border-enhancement', '1px solid rgba(0, 0, 0, 0.2)');
        const playerLoginText = this.shadowRoot.getElementById('player-login-text');
        if (playerLoginText) {
          playerLoginText.style.textShadow = '0 1px 1px rgba(0, 0, 0, 0.5)';
          playerLoginText.style.webkitTextStroke = '0.5px rgba(0, 0, 0, 0.5)';
        }
        const settingsHeadings = this.shadowRoot.querySelectorAll('#settings-panel h3, #tester-info-modal .modal-header h3');
        settingsHeadings.forEach(heading => {
          heading.style.textShadow = '0 1px 1px rgba(0, 0, 0, 0.5)';
          heading.style.webkitTextStroke = '0.5px rgba(0, 0, 0, 0.5)';
        });
        root.style.setProperty('--standard-text-shadow', 'none');
      } else {
        root.style.setProperty('--theme-box-background', 'rgba(255, 245, 230, 0.95)');
        root.style.setProperty('--theme-text-shadow', 'none');
        root.style.setProperty('--theme-border-enhancement', 'none');
        root.style.setProperty('--standard-text-shadow', 'none');
        const playerLoginText = this.shadowRoot.getElementById('player-login-text');
        if (playerLoginText) {
          playerLoginText.style.textShadow = '1px 2px 0px var(--theme-shadow)';
        }
        const settingsHeadings = this.shadowRoot.querySelectorAll('#settings-panel h3, #tester-info-modal .modal-header h3');
        settingsHeadings.forEach(heading => {
          heading.style.textShadow = '1px 1px 0px var(--theme-shadow)';
        });
      }

      const buttonBg = primaryIsLight ? this.darkenColor(theme.primary, 20) : theme.primary; // Uses class darkenColor
      root.style.setProperty('--theme-button-bg', buttonBg);
      root.style.setProperty('--theme-button-border', primaryIsLight ? 'rgba(0, 0, 0, 0.3)' : theme.secondary);
      root.style.setProperty('--theme-button-text', primaryIsLight ? '#333333' : '#FFFFFF');
      
      const loginBtn = this.shadowRoot.getElementById('log-in-btn');
      const createAccountBtn = this.shadowRoot.getElementById('create-account-btn');
      
      if (loginBtn) {
        loginBtn.style.setProperty('--ajd-bubble-button-background-color', buttonBg);
        loginBtn.style.setProperty('--ajd-bubble-button-border-color', primaryIsLight ? 'rgba(0, 0, 0, 0.3)' : theme.secondary);
        loginBtn.style.setProperty('--ajd-bubble-button-text-color', primaryIsLight ? '#333333' : '#FFFFFF');
        loginBtn.style.setProperty('--ajd-bubble-button-background-color-hover', primaryIsLight ? this.darkenColor(buttonBg, 10) : this.darkenColor(buttonBg, -15));
        loginBtn.style.setProperty('--ajd-bubble-button-background-color-active', buttonBg);
        if (primaryIsLight && (fruitKey === 'banana.png' || fruitKey === 'pineapple.png')) {
          loginBtn.style.boxShadow = '0 0 0 1px rgba(0, 0, 0, 0.3)';
        } else {
          loginBtn.style.boxShadow = '';
        }
      }
      
      if (createAccountBtn) {
        createAccountBtn.style.setProperty('--ajd-bubble-button-background-color', buttonBg);
        createAccountBtn.style.setProperty('--ajd-bubble-button-border-color', primaryIsLight ? 'rgba(0, 0, 0, 0.3)' : theme.secondary);
        createAccountBtn.style.setProperty('--ajd-bubble-button-text-color', primaryIsLight ? '#333333' : '#FFFFFF');
        createAccountBtn.style.setProperty('--ajd-bubble-button-background-color-hover', primaryIsLight ? this.darkenColor(buttonBg, 10) : this.darkenColor(buttonBg, -15));
        createAccountBtn.style.setProperty('--ajd-bubble-button-background-color-active', buttonBg);
        if (primaryIsLight && (fruitKey === 'banana.png' || fruitKey === 'pineapple.png')) {
          createAccountBtn.style.boxShadow = '0 0 0 1px rgba(0, 0, 0, 0.3)';
        } else {
          createAccountBtn.style.boxShadow = '';
        }
      }

      if (this.accountPanelInstance && typeof this.accountPanelInstance.updateTheme === 'function') {
        this.accountPanelInstance.updateTheme(fruitKey);
      }
      if (window.UserTrayManager.instance && typeof window.UserTrayManager.instance.updateTheme === 'function') {
        window.UserTrayManager.instance.updateTheme(theme);
      }
      if (this.importButtonInstance && typeof this.importButtonInstance.updateTheme === 'function') {
        this.importButtonInstance.updateTheme(fruitKey);
      }
      if (this.autoWheelButtonInstance && typeof this.autoWheelButtonInstance.updateTheme === 'function') {
        this.autoWheelButtonInstance.updateTheme(fruitKey);
      }
    }

    toggleDarkMode(isDarkMode) {
      // Apply dark mode class to host element
      if (isDarkMode) {
        this.classList.add('dark-mode');
      } else {
        this.classList.remove('dark-mode');
      }

      // Update the theme-box-background CSS custom property
      const root = document.documentElement;
      if (isDarkMode) {
        root.style.setProperty('--theme-box-background', 'var(--theme-box-background-dark)');
      } else {
        root.style.setProperty('--theme-box-background', 'rgba(255, 245, 230, 0.95)');
      }

      // Notify other components about dark mode change
      if (this.accountPanelInstance && typeof this.accountPanelInstance.setDarkMode === 'function') {
        this.accountPanelInstance.setDarkMode(isDarkMode);
      }
      if (this.autoWheelButtonInstance && typeof this.autoWheelButtonInstance.setDarkMode === 'function') {
        this.autoWheelButtonInstance.setDarkMode(isDarkMode);
      }
    }

    toggleUIElements() {
      this._uiElementsHidden = !this._uiElementsHidden;
      
      // Toggle settings and report buttons
      if (this.settingsBtn) {
        this.settingsBtn.style.display = this._uiElementsHidden ? 'none' : 'flex';
      }
      if (this.reportProblemBtn) {
        this.reportProblemBtn.style.display = this._uiElementsHidden ? 'none' : 'flex';
      }
      
      // Toggle user tray (if it exists)
      if (window.UserTrayManager && window.UserTrayManager.instance) {
        if (this._uiElementsHidden) {
          window.UserTrayManager.hide();
        } else {
          window.UserTrayManager.show();
        }
      }
      
      // Also hide the settings panel if it's open
      if (this._uiElementsHidden && this.settingsPanel) {
        this.settingsPanel.classList.remove('show');
      }
    }

    _initializeAsyncSettings() {
      
      window.ipc.invoke('get-setting', 'uuidSpoofingEnabled')
        .then(uuidSpoofingEnabled => {
          if (this.uuidSpooferToggle) {
            this.uuidSpooferToggle.checked = uuidSpoofingEnabled;
            if (uuidSpoofingEnabled && this.uuidSpoofingWarning) {
              this.uuidSpoofingWarning.classList.add('show');
            }
          }
        })
        .catch(err => {
        });
        
      window.ipc.invoke('get-setting', 'debug.locale')
        .then(locale => {
          if (this.serverSwapSelect) {
            this.serverSwapSelect.value = locale || '';
          }
        })
        .catch(err => {
        });

      window.ipc.invoke('get-setting', 'backgroundProcessing')
        .then(backgroundProcessing => {
          if (this.backgroundProcessingToggle) {
            this.backgroundProcessingToggle.checked = backgroundProcessing !== false; // Default to true
          }
        })
        .catch(err => {
          // Default to enabled if setting doesn't exist
          if (this.backgroundProcessingToggle) {
            this.backgroundProcessingToggle.checked = true;
          }
        });

      window.ipc.invoke('get-setting', 'darkMode')
        .then(darkMode => {
          if (this.darkModeToggle) {
            this.darkModeToggle.checked = darkMode === true; // Default to false
            this.toggleDarkMode(darkMode === true);
          }
        })
        .catch(err => {
          // Default to disabled if setting doesn't exist
          if (this.darkModeToggle) {
            this.darkModeToggle.checked = false;
            this.toggleDarkMode(false);
          }
        });

      // Load UI component visibility settings
      window.ipc.invoke('get-setting', 'ui.showImportAccounts')
        .then(showImportAccounts => {
          if (this.showImportAccountsToggle) {
            this.showImportAccountsToggle.checked = showImportAccounts === true; // Default to false
          }
          this._updateComponentVisibility();
        })
        .catch(err => {
          // Default to disabled if setting doesn't exist
          if (this.showImportAccountsToggle) {
            this.showImportAccountsToggle.checked = false;
          }
          this._updateComponentVisibility();
        });

      window.ipc.invoke('get-setting', 'ui.showWheelAutomation')
        .then(showWheelAutomation => {
          if (this.showWheelAutomationToggle) {
            this.showWheelAutomationToggle.checked = showWheelAutomation === true; // Default to false
          }
          this._updateComponentVisibility();
        })
        .catch(err => {
          // Default to disabled if setting doesn't exist
          if (this.showWheelAutomationToggle) {
            this.showWheelAutomationToggle.checked = false;
          }
          this._updateComponentVisibility();
        });
    }    initializeSettings() {
      
      window.ipc.invoke('get-setting', 'fruitTheme')
        .then(savedFruitTheme => {
          
          // Handle different path formats - extract just the filename
          let fruitFilename = savedFruitTheme;
          if (savedFruitTheme && savedFruitTheme.includes('/')) {
            fruitFilename = savedFruitTheme.split('/').pop();
          }
          
          if (fruitFilename && this._fruitImages.includes(fruitFilename)) {
            if (this.loginAppIconElem) {
              this.loginAppIconElem.src = `images/${fruitFilename}`;
              this._currentFruitIndex = this._fruitImages.indexOf(fruitFilename);
              this.applyTheme(fruitFilename);
            }
          } else {
            this.applyTheme(this._defaultFruit);
          }
        })
        .catch(err => {
          this.applyTheme(this._defaultFruit);
        });
      
      window.ipc.invoke('get-setting', 'uuid_spoofer_enabled')
        .then(uuidSpoofingEnabled => {
          if (this.uuidSpooferToggle) {
            this.uuidSpooferToggle.checked = uuidSpoofingEnabled;
            if (uuidSpoofingEnabled && this.uuidSpoofingWarning) {
              this.uuidSpoofingWarning.classList.add('show');
            }
          }
        })
        .catch(err => {
        });

      window.ipc.invoke('get-setting', 'debug.locale')
        .then(locale => {
          if (this.serverSwapSelect) {
            this.serverSwapSelect.value = locale || '';
          }
        })
        .catch(err => {
        });

      window.ipc.invoke('get-setting', 'backgroundProcessing')
        .then(backgroundProcessing => {
          if (this.backgroundProcessingToggle) {
            this.backgroundProcessingToggle.checked = backgroundProcessing !== false; // Default to true
          }
        })
        .catch(err => {
          // Default to enabled if setting doesn't exist
          if (this.backgroundProcessingToggle) {
            this.backgroundProcessingToggle.checked = true;
          }
        });

      // Load UI component visibility settings in initializeSettings too
      window.ipc.invoke('get-setting', 'ui.showImportAccounts')
        .then(showImportAccounts => {
          if (this.showImportAccountsToggle) {
            this.showImportAccountsToggle.checked = showImportAccounts === true; // Default to false
          }
          this._updateComponentVisibility();
        })
        .catch(err => {
          if (this.showImportAccountsToggle) {
            this.showImportAccountsToggle.checked = false;
          }
          this._updateComponentVisibility();
        });

      window.ipc.invoke('get-setting', 'ui.showWheelAutomation')
        .then(showWheelAutomation => {
          if (this.showWheelAutomationToggle) {
            this.showWheelAutomationToggle.checked = showWheelAutomation === true; // Default to false
          }
          this._updateComponentVisibility();
        })
        .catch(err => {
          if (this.showWheelAutomationToggle) {
            this.showWheelAutomationToggle.checked = false;
          }
          this._updateComponentVisibility();
                 });
    }

    _updateComponentVisibility() {
      const importSection = this.shadowRoot.getElementById('import-section');
      const autoWheelSection = this.shadowRoot.getElementById('auto-wheel-section');

      if (importSection) {
        if (this.showImportAccountsToggle && this.showImportAccountsToggle.checked) {
          importSection.classList.add('visible');
        } else {
          importSection.classList.remove('visible');
        }
      }

      if (autoWheelSection) {
        if (this.showWheelAutomationToggle && this.showWheelAutomationToggle.checked) {
          autoWheelSection.classList.add('visible');
        } else {
          autoWheelSection.classList.remove('visible');
        }
      }
    }

    _isTokenExpired(token) {
      if (!token) return true;
      
      // Check if token has the expected JWT format (three parts separated by dots)
      const tokenParts = token.split('.');
      if (tokenParts.length !== 3) {
        console.log("Token does not have JWT format (3 parts):", tokenParts.length, "- treating as non-expiring refresh token");
        // If it's not a JWT (like a simple refresh token), assume it's valid
        // The server will reject it if it's actually expired
        return false;
      }
      
      try {
        const payloadBase64 = tokenParts[1].replace(/-/g, '+').replace(/_/g, '/');
        const decodedJson = atob(payloadBase64);
        const decoded = JSON.parse(decodedJson);
        
        if (typeof decoded.exp !== 'number') {
          console.error("Token expiration ('exp') is not a number:", decoded.exp);
          return true;
        }
        
        const nowInSeconds = (Date.now() / 1000);
        // Check if token is expired, with a 5-second buffer to account for clock skew
        return decoded.exp < (nowInSeconds + 5);

      } catch (e) {
        console.error("Failed to decode or parse token:", e);
        return true;
      }
    }

    async logIn() {
      console.log(`[LOGIN PROCESS] ============= Starting login process =============`);
      console.log(`[LOGIN PROCESS] Username: ${this.username ? '[SET]' : '[NOT SET]'}`);
      console.log(`[LOGIN PROCESS] Has Auth Token: ${!!this.authToken}`);
      console.log(`[LOGIN PROCESS] Has Refresh Token: ${!!this.refreshToken}`);
      console.log(`[LOGIN PROCESS] Remember Me: ${this.rememberMeElem ? this.rememberMeElem.value : 'unknown'}`);
      console.log(`[LOGIN PROCESS] Has OTP: ${this.otp ? '[SET]' : '[NOT SET]'}`);
      console.log(`[LOGIN PROCESS] Login blocked state: ${this.loginBlocked}`);
      
      if (this.loginBlocked) {
        console.log(`[LOGIN PROCESS] Login blocked, returning early`);
        return;
      }
      this.loginBlocked = true;
      this.logInButtonElem.disabled = true;
      this.logInButtonElem.classList.add("loading");

      try {
        // Centralized DF handling
        console.log(`[DEFPACKS] Current DF state: ${globals.df ? 'SET' : 'NULL'}`);
        console.log(`[DEFPACKS] UUID spoofer active: ${this.uuidSpooferToggle && this.uuidSpooferToggle.checked ? 'YES' : 'NO'}`);
        
        if (globals.df === null || (this.uuidSpooferToggle && this.uuidSpooferToggle.checked)) {
          console.log('[DEFPACKS] Refreshing DF before login...');
          try {
            const newDf = await window.ipc.refreshDf();
            if (newDf) {
              globals.df = newDf;
              console.log(`[DEFPACKS] Successfully refreshed DF: ${newDf.substr(0, 8)}...`);
            } else {
              console.warn('[DEFPACKS] Failed to get or refresh DF, login may fail.');
            }
          } catch (dfErr) {
            console.error('[DEFPACKS] Error refreshing DF:', dfErr);
          }
        } else {
          console.log(`[DEFPACKS] Using existing DF: ${globals.df.substr(0, 8)}...`);
        }

        let authResult;

        console.log("[ANIMAL JAM AUTH] ============= Starting authentication flow =============");
        console.log("[ANIMAL JAM AUTH] Auth token present:", !!this.authToken);
        console.log("[ANIMAL JAM AUTH] Refresh token present:", !!this.refreshToken);
        console.log("[ANIMAL JAM AUTH] OTP present:", !!this.otp);

        // 1. Check for a valid, non-expired auth token
        let authTokenFailed = false;
        let authTokenOtpNeeded = false;
        let refreshTokenOtpNeeded = false;
        
        if (this.authToken && !this._isTokenExpired(this.authToken)) {
          console.log("[ANIMAL JAM AUTH] Auth token is valid. Attempting authentication with it.");
          try {
            authResult = await globals.authenticateWithAuthToken(this.authToken);
            console.log("[ANIMAL JAM AUTH] Auth token authentication successful");
          } catch (err) {
            console.log("[ANIMAL JAM AUTH] Auth token authentication failed:", err.message);
            
            // If OTP is needed for auth token, try refresh token instead
            if (err.message === "OTP_NEEDED" && this.refreshToken) {
              console.log("[ANIMAL JAM AUTH] OTP needed for auth token, trying refresh token instead");
              authTokenFailed = true;
              authTokenOtpNeeded = true;
            } else if (err.message === "LOGIN_ERROR" && this.refreshToken) {
              // If auth token fails with LOGIN_ERROR, try refresh token instead
              console.log("[ANIMAL JAM AUTH] Auth token failed with LOGIN_ERROR, trying refresh token instead");
              authTokenFailed = true;
            } else {
              // For other errors, throw immediately
              throw err;
            }
          }
        } 
        // 2. If auth token is expired, missing, or failed with OTP, try using the refresh token
        if ((!this.authToken || this._isTokenExpired(this.authToken) || authTokenFailed) && this.refreshToken) {
          console.log("[ANIMAL JAM AUTH] Attempting refresh token authentication");
          console.log("[ANIMAL JAM AUTH] Refresh token format check:", this.refreshToken ? this.refreshToken.split('.').length + ' parts' : 'null');
          
          // **NEW**: First, check if the refresh token itself is expired client-side
          if (this._isTokenExpired(this.refreshToken)) {
            console.warn("[ANIMAL JAM AUTH] Refresh token has expired (client-side check). Clearing all tokens.");
            this.clearAuthToken();
            this.clearRefreshToken();
            this.isFakePassword = false;
            // Throw the specific error to be handled by the catch block
            throw new Error("REFRESH_TOKEN_EXPIRED");
          }

          if (this.authToken) {
            console.log("[ANIMAL JAM AUTH] Auth token is expired or invalid. Attempting to refresh with a valid refresh token.");
          } else {
            console.log("[ANIMAL JAM AUTH] No auth token found. Attempting to use refresh token.");
          }
          try {
            console.log("[ANIMAL JAM AUTH] OTP for refresh token auth:", this.otp ? '[SET]' : '[NOT SET]');
            authResult = await globals.authenticateWithRefreshToken(this.refreshToken, this.otp);
            console.log("[ANIMAL JAM AUTH] Successfully refreshed token.");
            console.log("[ANIMAL JAM AUTH] Refresh token auth result:", {
              hasResult: !!authResult,
              hasUserData: !!authResult?.userData,
              hasAuthToken: !!authResult?.userData?.authToken,
              hasRefreshToken: !!authResult?.userData?.refreshToken
            });
          } catch (err) {
            if (err.message === "REFRESH_TOKEN_EXPIRED") {
              console.warn("[ANIMAL JAM AUTH] Refresh token has expired (server-side check). Clearing all tokens.");
              this.clearAuthToken();
              this.clearRefreshToken();
              this.isFakePassword = false;
              // Error message is already set in the main catch block, just ensure tokens are cleared.
            } else if (err.message === "OTP_NEEDED") {
              console.log("[ANIMAL JAM AUTH] OTP needed for refresh token, will fall back to password login");
              refreshTokenOtpNeeded = true;
              // Continue to password login below
            } else {
              // Re-throw to be caught by the main catch block
              throw err;
            }
          }
        }
        // 3. If we have a successful auth result from tokens, use it; otherwise fall back to password login
        if (authResult) {
          console.log("[ANIMAL JAM AUTH] Using successful token authentication result");
        } else if (!this.authToken || this._isTokenExpired(this.authToken) || authTokenFailed || refreshTokenOtpNeeded) {
          console.log("[ANIMAL JAM AUTH] No valid tokens or OTP needed. Proceeding with password authentication.");
          console.log("[ANIMAL JAM AUTH] OTP for password auth:", this.otp ? '[SET]' : '[NOT SET]');
          
          // If both tokens failed with OTP and we don't have an OTP, we need to show the OTP modal
          if ((authTokenOtpNeeded || refreshTokenOtpNeeded) && !this.otp) {
            console.log("[ANIMAL JAM AUTH] Both tokens need OTP but no OTP provided, throwing OTP_NEEDED");
            throw new Error("OTP_NEEDED");
          }
          
          if (!this.username.length) throw new Error("EMPTY_USERNAME");
          if (!this.password.length) throw new Error("EMPTY_PASSWORD");
          authResult = await globals.authenticateWithPassword(this.username, this.password, this.otp, null);
        }

        // If we have a result, proceed to login
        console.log("[LOGIN PROCESS] Clearing OTP after successful authentication");
        this.otp = null;
        
        // Ensure we have a valid result
        if (!authResult || !authResult.userData) {
          throw new Error("Invalid authentication result - missing user data");
        }
        
        const { userData, flashVars } = authResult;
        
        console.log(`[FLASHVARS] Raw FlashVars received from authentication:`, {
          deploy_version: flashVars.deploy_version,
          smoke_version: flashVars.smoke_version,
          smartfoxServer: flashVars.smartfoxServer,
          blueboxServer: flashVars.blueboxServer,
          clientURL: flashVars.clientURL,
          content: flashVars.content,
          df: flashVars.df ? flashVars.df.substr(0, 8) + '...' : 'NOT SET',
          locale: flashVars.locale,
          username: flashVars.username
        });
        
        // Persist new tokens
        if (userData.authToken) {
          console.log("[LOGIN PROCESS] Setting auth token:", {
            length: userData.authToken.length,
            parts: userData.authToken.split('.').length
          });
          this.authToken = userData.authToken;
        }
        if (userData.refreshToken) {
          console.log("[LOGIN PROCESS] Setting refresh token:", {
            token: userData.refreshToken,
            length: userData.refreshToken.length,
            parts: userData.refreshToken.split('.').length
          });
          this.refreshToken = userData.refreshToken;
        } else {
          console.log("[LOGIN PROCESS] No refresh token in userData");
        }

        // Clear any previous error messages
        this.usernameInputElem.error = "";
        this.passwordInputElem.error = "";

        console.log('[LOGIN PROCESS] Login successful. Preparing to dispatch events.');
        console.log(`[LOGIN PROCESS] User data:`, {
          username: userData.username,
          accountType: userData.accountType,
          language: userData.language,
          hasAuthToken: !!userData.authToken,
          hasRefreshToken: !!userData.refreshToken
        });
        
        // Send login success data to main process
        const loginData = {
          username: userData.username,
          language: userData.language || 'en',
          rememberMe: this.rememberMeElem.value,
          authToken: userData.authToken,
          refreshToken: userData.refreshToken,
        };
        console.log(`[LOGIN PROCESS] Sending loginSucceeded to main process with data:`, {
          username: loginData.username,
          language: loginData.language,
          rememberMe: loginData.rememberMe,
          hasAuthToken: !!loginData.authToken,
          hasRefreshToken: !!loginData.refreshToken
        });
        window.ipc.send("loginSucceeded", loginData);

        // Dispatch event to switch to the game screen
        const theme = this._fruitThemes[this._fruitImages[this._currentFruitIndex]];
        theme.boxBackground = getComputedStyle(this.shadowRoot.host).getPropertyValue('--theme-box-background');
        
        console.log(`[FLASHVARS] Final FlashVars being sent to game screen:`, {
          deploy_version: flashVars.deploy_version,
          smoke_version: flashVars.smoke_version,
          smartfoxServer: flashVars.smartfoxServer,
          blueboxServer: flashVars.blueboxServer,
          blueboxPort: flashVars.blueboxPort,
          smartfoxPort: flashVars.smartfoxPort,
          clientURL: flashVars.clientURL,
          content: flashVars.content,
          df: flashVars.df ? flashVars.df.substr(0, 8) + '...' : 'NOT SET',
          locale: flashVars.locale,
          username: flashVars.username,
          auth_token: flashVars.auth_token ? '[SET]' : '[NOT SET]'
        });
        
        console.log(`[LOGIN PROCESS] Dispatching loggedIn event to switch to game screen`);
        this.dispatchEvent(new CustomEvent("loggedIn", { detail: { flashVars, theme } }));

      } catch (err) {
        // Centralized error handling
        let userMessage = "Servers are down or Your IP is blocked. Please try again later.";
        
        if (err.message) {
          console.error(`[LoginScreen] Login failed: ${err.message}`, err);
          switch (err.message) {
            case "SUSPENDED": userMessage = await globals.translate("userSuspended"); break;
            case "BANNED": userMessage = await globals.translate("userBanned"); break;
            case "LOGIN_ERROR": userMessage = await globals.translate("loginError"); break;
            case "WRONG_CREDENTIALS": userMessage = await globals.translate("wrongCredentials"); break;
            case "EMPTY_USERNAME": userMessage = await globals.translate("usernameRequired"); break;
            case "EMPTY_PASSWORD": userMessage = await globals.translate("emptyPassword"); break;
            case "RATE_LIMITED": userMessage = "Rate limited. Please try again in a few moments."; break;
            case "REFRESH_TOKEN_EXPIRED": userMessage = "Your session has expired. Please log in again."; break;
            case "AUTH_TOKEN_EXPIRED":
              // This should be handled by the logic above, but as a fallback:
              console.warn("[LoginScreen] Caught AUTH_TOKEN_EXPIRED. Forcing re-login.");
              this.clearAuthToken();
              // Don't recursively call logIn(), just show error.
              userMessage = "Your session has expired. Please log in again.";
              break;
            case "USER_RENAME_NEEDED":
            case "OTP_NEEDED":
              // These open modals, so no user message needed here.
              console.log("[LOGIN PROCESS] OTP_NEEDED or USER_RENAME_NEEDED - keeping UI blocked for modal");
              console.log("[LOGIN PROCESS] UI will be unblocked when OTP modal is submitted");
              return; // Exit without unblocking UI yet
            default:
              globals.reportError("webClient", `Unhandled login error: ${err.stack || err.message}`);
              break;
          }
        } else {
          globals.reportError("webClient", `Unknown login error: ${err}`);
        }
        
        // Display the determined error message
        this.passwordInputElem.error = userMessage;

        // Unblock UI
        this.loginBlocked = false;
        this.logInButtonElem.classList.remove("loading");
      }
    }

    canRetry() {
      return (this.authToken !== null || this.refreshToken !== null ||
        (this.username && this.password && !this.isFakePassword));
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
      await this.localize();

      if (this.accountPanelInstance) {
        this.accountPanelInstance.addEventListener('account-selected', (e) => {
          if (e.detail && e.detail.username) {
            this.clearAuthToken();
            this.clearRefreshToken();
            this.isFakePassword = false; // Ensure any "fake password" state is cleared
            this.usernameInputElem.value = e.detail.username;
            this.passwordInputElem.value = e.detail.password || ""; // Populate password field
            this.passwordInputElem.focus(); // Focus password field for user input
            // this.rememberMeElem.value = true; // Prevent auto-enabling "Remember Me"
            // window.ipc.send("rememberMeStateUpdated", {newValue: true}); // Prevent auto-enabling "Remember Me"
          }
        });

        this.accountPanelInstance.addEventListener('request-credentials-for-add', async () => {
          const username = this.usernameInputElem.value.trim();
          const password = this.passwordInputElem.value;
          if (!username || !password) {
            if (!username) this.usernameInputElem.error = await globals.translate("usernameRequired");
            if (!password) this.passwordInputElem.error = await globals.translate("emptyPassword");
            if (typeof this.accountPanelInstance.handleAddAccountFailed === 'function') {
                 this.accountPanelInstance.handleAddAccountFailed("Username and password are required.");
            }
            return;
          }
          this.usernameInputElem.error = "";
          this.passwordInputElem.error = "";
          
          if (typeof this.accountPanelInstance.saveAccountWithCredentials === 'function') {
            this.accountPanelInstance.saveAccountWithCredentials({ username, password });
          }
        });
        
        this.accountPanelInstance.addEventListener('account-operation-error', (e) => {
          if (e.detail && e.detail.message) {
            console.error(`[LoginScreen] Account operation error from panel: ${e.detail.message}`);
            this.usernameInputElem.error = e.detail.message;
          }
        });
      }

      // Listen for any account changes to update auto wheel component
      document.addEventListener('accounts-updated', async (event) => {
        console.log('[LoginScreen] Accounts updated, refreshing auto wheel');
        if (this.autoWheelButtonInstance) {
          try {
            const savedAccounts = await window.ipc.invoke('get-saved-accounts');
            if (savedAccounts) {
              this.autoWheelButtonInstance.setAccounts(savedAccounts);
            }
          } catch (error) {
            console.error('[LoginScreen] Failed to refresh auto wheel accounts:', error);
          }
        }
      });

      // Setup import button event listeners
      if (this.importButtonInstance) {
        this.importButtonInstance.addEventListener('accounts-imported', async (event) => {
          console.log('[LoginScreen] Accounts imported:', event.detail);
          // Refresh account panel display
          if (this.accountPanelInstance) {
            await this.accountPanelInstance.loadAndDisplaySavedAccounts();
          }
          // Update auto wheel component with new accounts
          if (this.autoWheelButtonInstance) {
            this.autoWheelButtonInstance.setAccounts(event.detail.accounts);
          }
        });

        this.importButtonInstance.addEventListener('import-error', (event) => {
          console.error('[LoginScreen] Import error:', event.detail.message);
          // Show error via password input error (since it's visible)
          if (this.passwordInputElem) {
            this.passwordInputElem.error = `Import failed: ${event.detail.message}`;
          }
        });

        // Handle mass delete success: refresh lists and auto wheel
        this.importButtonInstance.addEventListener('accounts-deleted', async () => {
          try {
            if (this.accountPanelInstance) {
              await this.accountPanelInstance.loadAndDisplaySavedAccounts();
            }
            if (this.autoWheelButtonInstance) {
              const savedAccounts = await window.ipc.invoke('get-saved-accounts');
              if (savedAccounts) {
                this.autoWheelButtonInstance.setAccounts(savedAccounts);
              }
            }
            // Broadcast accounts-updated for any listeners
            document.dispatchEvent(new CustomEvent('accounts-updated', {
              detail: { accounts: [] },
              bubbles: true,
              composed: true
            }));
          } catch (error) {
            console.error('[LoginScreen] Error refreshing after accounts-deleted:', error);
          }
        });

        // Handle mass delete error: surface message
        this.importButtonInstance.addEventListener('delete-error', (event) => {
          const message = event?.detail?.message || 'Failed to delete accounts';
          console.error('[LoginScreen] Delete-all error:', message);
          if (this.passwordInputElem) {
            this.passwordInputElem.error = `Delete failed: ${message}`;
          }
        });
      }

      // Setup auto wheel event listeners
      if (this.autoWheelButtonInstance) {
        this.autoWheelButtonInstance.addEventListener('auto-wheel-login', async (event) => {
          const account = event.detail.account;
          console.log('[LoginScreen] Auto wheel login:', account.username);
          
          try {
            // Clear existing tokens to force password authentication for new account
            console.log('[LoginScreen] DEBUG: Clearing auth tokens before switching accounts');
            this.clearAuthToken();
            this.clearRefreshToken();
            
            // Set credentials and attempt login
            console.log(`[LoginScreen] DEBUG: Setting credentials - Username: "${account.username}", Password: "${account.password}"`);
            this.username = account.username;
            this.password = account.password;
            this.isFakePassword = false;
            
            console.log(`[LoginScreen] DEBUG: About to call logIn() for "${account.username}"`);
            await this.logIn();
            console.log(`[LoginScreen] DEBUG: logIn() completed for "${account.username}"`);
          } catch (error) {
            console.error('[LoginScreen] Auto wheel login failed:', error);
          }
        });

        this.autoWheelButtonInstance.addEventListener('auto-wheel-logout', (event) => {
          const account = event.detail.account;
          console.log('[LoginScreen] Auto wheel logout:', account.username);
          
          // Trigger logout by dispatching the logout-requested event (same as user tray logout)
          document.dispatchEvent(new CustomEvent("logout-requested"));
        });

        this.autoWheelButtonInstance.addEventListener('auto-wheel-stopped', () => {
          console.log('[LoginScreen] Auto wheel stopped');
        });

        // Load saved accounts into auto wheel component
        try {
          const savedAccounts = await window.ipc.invoke('get-saved-accounts');
          if (savedAccounts) {
            this.autoWheelButtonInstance.setAccounts(savedAccounts);
          }
        } catch (error) {
          console.error('[LoginScreen] Failed to load saved accounts for auto wheel:', error);
        }
      }
    }

  });
})();
