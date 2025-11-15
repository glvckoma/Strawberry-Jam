"use strict";

(() => {
  const { forgotPassword, getConsoleLogs } = window.LoginScreenUtilities || window;

  window.LoginScreenEventHandler = class {
    constructor(loginScreenInstance, authManager, themeManager, uiManager) {
      this.loginScreen = loginScreenInstance;
      this.authManager = authManager;
      this.themeManager = themeManager;
      this.uiManager = uiManager;
    }

    setupEventListeners() {
      this.loginScreen.loginSpinnerElem.addEventListener("click", event => {
        if (globals.userAbortController) globals.userAbortController.abort();
      });
      this.loginScreen.versionElem.addEventListener("click", () => {
        window.ipc.send("about");
      });
      this.loginScreen.usernameInputElem.addEventListener("keydown", event => event.key === "Enter" ? this.authManager.logIn() : "");
      this.loginScreen.usernameInputElem.addEventListener("input", event => {
        if (this.loginScreen.authToken) this.loginScreen.clearAuthToken();
        if (this.loginScreen.refreshToken) this.loginScreen.clearRefreshToken();
      });
      this.loginScreen.passwordInputElem.addEventListener("keydown", event => event.key === "Enter" ? this.authManager.logIn() : "");
      this.loginScreen.passwordInputElem.addEventListener("input", event => {
        if (this.loginScreen.isFakePassword) this.loginScreen.isFakePassword = false;
        if (this.loginScreen.authToken) this.loginScreen.clearAuthToken();
        if (this.loginScreen.refreshToken) this.loginScreen.clearRefreshToken();
      });
      this.loginScreen.rememberMeElem.addEventListener("click", event => {
        window.ipc.send("rememberMeStateUpdated", {newValue: this.loginScreen.rememberMeElem.value});
      });
      this.loginScreen.forgotPasswordLinkElem.addEventListener("click", () => {
        if (this.loginScreen.loginBlocked) return;
        forgotPassword();
      });
      this.loginScreen.createAccountElem.addEventListener("click", async () => {
        console.log(`[CREATE ACCOUNT] ============= Starting create account process =============`);
        if (this.loginScreen.loginBlocked) {
          console.log(`[CREATE ACCOUNT] Create account blocked, returning early`);
          return;
        }
        this.loginScreen.loginBlocked = true;
        try {
          console.log(`[CREATE ACCOUNT] Requesting FlashVars for account creation`);
          const flashVars = await globals.getFlashVarsFromWeb();
          
          const apiPort = await window.ipc.invoke('get-api-port').catch(() => '8080');
          
          console.log(`[CREATE ACCOUNT] Configuring FlashVars for local proxy - API Port: ${apiPort}`);
          
          flashVars.content = `http://localhost:${apiPort}/`;
          if (flashVars.deploy_version) {
            flashVars.clientURL = `http://localhost:${apiPort}/${flashVars.deploy_version}/ajclient.swf`;
          }
          flashVars.smartfoxServer = 'localhost';
          flashVars.blueboxServer = 'localhost';
          
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
          this.loginScreen.dispatchEvent(new CustomEvent("loggedIn", {detail: {flashVars}}));
        } catch (err) {
          console.error(`[CREATE ACCOUNT] Error during account creation:`, err);
          globals.reportError("webClient", `Error creating account: ${err.stack || err.message}`);
          if (err.name != "Aborted") window.alert("Something went wrong :(");
          this.loginScreen.loginBlocked = false;
        }
      });
      this.loginScreen.logInButtonElem.addEventListener("click", () => {
        globals.currentAbortController = new AbortController();
        this.authManager.logIn();
      });
      this.loginScreen.expandButtonElement.addEventListener("click", event => {
        window.ipc.send("systemCommand", {command: "toggleFullScreen"});
      });
      this.loginScreen.closeButtonElement.addEventListener("click", event => {
        window.ipc.send("systemCommand", {command: "exit"});
      });

      window.ipc.on("autoUpdateStatus", (event, data) => {
        for (const state of ["check", "download", "restart", "error"]) {
          this.loginScreen.versionStatusIconElem.classList.remove(state);
          if (state == data.state) this.loginScreen.versionStatusIconElem.classList.add(data.state);
        }
        this.loginScreen.setProgress(data.progress || null);
      });
      window.ipc.on("screenChange", (event, state) => {
        const buttonTray = this.loginScreen.shadowRoot.getElementById("button-tray");
        const hostElement = this.loginScreen.shadowRoot.host;
        if (state === "fullScreen" && globals.systemData.platform === "win32") {
          buttonTray.classList.remove("hidden");
          hostElement.classList.add("fullscreen-active");
        } else {
          buttonTray.classList.add("hidden");
          hostElement.classList.remove("fullscreen-active");
        }
      });

      this.loginScreen.settingsBtn.addEventListener('click', (event) => {
        event.stopPropagation();
        this.loginScreen.settingsPanel.classList.toggle('show');
      });

      if (this.loginScreen.reportProblemBtn) {
        this.loginScreen.reportProblemBtn.addEventListener('click', () => {
          const logsToReport = [...getConsoleLogs()];
          
          if (window.ipc && window.ipc.electronOs && window.ipc.electronOs.homedir &&
              window.ipc.electronPath && window.ipc.electronPath.join &&
              window.ipc.electronFs && window.ipc.electronFs.writeFileSync) {
            try {
              const fsOps = window.ipc.electronFs;
              const pathOps = window.ipc.electronPath;
              const osOps = window.ipc.electronOs;

              if (!osOps || typeof osOps.homedir !== 'function') {
                throw new Error("osOps or osOps.homedir is not available via preload.");
              }

              const homeDir = osOps.homedir();
              if (!homeDir) {
                throw new Error("Could not determine user's home directory via osOps.homedir().");
              }
              const desktopPath = pathOps.join(homeDir, 'Desktop');
              
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

              if (window.gameClientConsoleLogs && window.gameClientConsoleLogs.length > 0) {
                logContent += `\n\n## Game Client Logs\n`;
                window.gameClientConsoleLogs.forEach(log => {
                  logContent += `[${log.timestamp}] [${log.level}] ${log.message}\n`;
                });
              }
              
              fsOps.writeFileSync(filePath, logContent, 'utf8');
              alert(`Logs saved to your Desktop: ${filename}\nSubmit the logs in #tickets channel to recieve help`);
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
        if (!this.loginScreen.settingsPanel || !this.loginScreen.settingsBtn) return;

        const path = event.composedPath ? event.composedPath() : event.path;
        if (path && !path.includes(this.loginScreen.settingsPanel) && !path.includes(this.loginScreen.settingsBtn)) {
          if (this.loginScreen.settingsPanel.classList.contains('show')) {
            this.loginScreen.settingsPanel.classList.remove('show');
          }
        }
      });
      
      if (this.loginScreen.uuidSpooferToggle) {
        this.loginScreen.uuidSpooferToggle.addEventListener('change', async () => {
          if (this.loginScreen.uuidSpooferToggle.checked) {
            try {
              const result = await window.ipc.invoke('toggle-uuid-spoofing', true);
              if (!result || !result.success) {
                this.loginScreen.uuidSpooferToggle.checked = false;
                return;
              }
              this.loginScreen.uuidSpoofingWarning.classList.add('show');
            } catch (err) {
              this.loginScreen.uuidSpooferToggle.checked = false;
              return;
            }
          } else {
            await window.ipc.invoke('toggle-uuid-spoofing', false);
            this.loginScreen.uuidSpoofingWarning.classList.remove('show');
            globals.df = null;
          }
        });
      }

      if (this.loginScreen.backgroundProcessingToggle) {
        this.loginScreen.backgroundProcessingToggle.addEventListener('change', async () => {
          try {
            await window.ipc.invoke('set-setting', 'backgroundProcessing', this.loginScreen.backgroundProcessingToggle.checked);
          } catch (err) {
            console.error('Failed to save background processing setting:', err);
          }
        });
      }

      if (this.loginScreen.darkModeToggle) {
        this.loginScreen.darkModeToggle.addEventListener('change', async () => {
          try {
            const isDarkMode = this.loginScreen.darkModeToggle.checked;
            await window.ipc.invoke('set-setting', 'darkMode', isDarkMode);
            this.uiManager.toggleDarkMode(isDarkMode);
          } catch (err) {
            console.error('Failed to save dark mode setting:', err);
          }
        });
      }
      
      if (this.loginScreen.serverSwapSelect) {
        this.loginScreen.serverSwapSelect.addEventListener('change', (e) => {
          const newLanguage = e.target.value;
          window.ipc.invoke('set-setting', 'login.language', newLanguage);
          if (globals && globals.setLanguage) {
            globals.setLanguage(newLanguage);
          }
        });
      }

      if (this.loginScreen.showImportAccountsToggle) {
        this.loginScreen.showImportAccountsToggle.addEventListener('change', async () => {
          try {
            await window.ipc.invoke('set-setting', 'ui.showImportAccounts', this.loginScreen.showImportAccountsToggle.checked);
            this.uiManager._updateComponentVisibility();
          } catch (err) {
            console.error('Failed to save show import accounts setting:', err);
          }
        });
      }

      if (this.loginScreen.showWheelAutomationToggle) {
        this.loginScreen.showWheelAutomationToggle.addEventListener('change', async () => {
          try {
            await window.ipc.invoke('set-setting', 'ui.showWheelAutomation', this.loginScreen.showWheelAutomationToggle.checked);
            this.uiManager._updateComponentVisibility();
          } catch (err) {
            console.error('Failed to save show wheel automation setting:', err);
          }
        });
      }

      document.addEventListener('keydown', (event) => {
        if (event.ctrlKey && event.shiftKey && event.key === 'H') {
          event.preventDefault();
          this.uiManager.toggleUIElements();
        }
      });
    }

    async connectedCallback() {
      await this.loginScreen.localize();

      if (this.loginScreen.accountPanelInstance) {
        this.loginScreen.accountPanelInstance.addEventListener('account-selected', (e) => {
          if (e.detail && e.detail.username) {
            this.loginScreen.clearAuthToken();
            this.loginScreen.clearRefreshToken();
            this.loginScreen.isFakePassword = false;
            this.loginScreen.usernameInputElem.value = e.detail.username;
            this.loginScreen.passwordInputElem.value = e.detail.password || "";
            this.loginScreen.passwordInputElem.focus();
          }
        });

        this.loginScreen.accountPanelInstance.addEventListener('request-credentials-for-add', async () => {
          const username = this.loginScreen.usernameInputElem.value.trim();
          const password = this.loginScreen.passwordInputElem.value;
          if (!username || !password) {
            if (!username) this.loginScreen.usernameInputElem.error = await globals.translate("usernameRequired");
            if (!password) this.loginScreen.passwordInputElem.error = await globals.translate("emptyPassword");
            if (typeof this.loginScreen.accountPanelInstance.handleAddAccountFailed === 'function') {
              this.loginScreen.accountPanelInstance.handleAddAccountFailed("Username and password are required.");
            }
            return;
          }
          this.loginScreen.usernameInputElem.error = "";
          this.loginScreen.passwordInputElem.error = "";
          
          if (typeof this.loginScreen.accountPanelInstance.saveAccountWithCredentials === 'function') {
            this.loginScreen.accountPanelInstance.saveAccountWithCredentials({ username, password });
          }
        });
        
        this.loginScreen.accountPanelInstance.addEventListener('account-operation-error', (e) => {
          if (e.detail && e.detail.message) {
            console.error(`[LoginScreen] Account operation error from panel: ${e.detail.message}`);
            this.loginScreen.usernameInputElem.error = e.detail.message;
          }
        });
      }

      document.addEventListener('accounts-updated', async (event) => {
        console.log('[LoginScreen] Accounts updated, refreshing auto wheel');
        if (this.loginScreen.autoWheelButtonInstance) {
          try {
            const savedAccounts = await window.ipc.invoke('get-saved-accounts');
            if (savedAccounts) {
              this.loginScreen.autoWheelButtonInstance.setAccounts(savedAccounts);
            }
          } catch (error) {
            console.error('[LoginScreen] Failed to refresh auto wheel accounts:', error);
          }
        }
      });

      if (this.loginScreen.importButtonInstance) {
        this.loginScreen.importButtonInstance.addEventListener('accounts-imported', async (event) => {
          console.log('[LoginScreen] Accounts imported:', event.detail);
          if (this.loginScreen.accountPanelInstance) {
            await this.loginScreen.accountPanelInstance.loadAndDisplaySavedAccounts();
          }
          if (this.loginScreen.autoWheelButtonInstance) {
            this.loginScreen.autoWheelButtonInstance.setAccounts(event.detail.accounts);
          }
        });

        this.loginScreen.importButtonInstance.addEventListener('import-error', (event) => {
          console.error('[LoginScreen] Import error:', event.detail.message);
          if (this.loginScreen.passwordInputElem) {
            this.loginScreen.passwordInputElem.error = `Import failed: ${event.detail.message}`;
          }
        });

        this.loginScreen.importButtonInstance.addEventListener('accounts-deleted', async () => {
          try {
            if (this.loginScreen.accountPanelInstance) {
              await this.loginScreen.accountPanelInstance.loadAndDisplaySavedAccounts();
            }
            if (this.loginScreen.autoWheelButtonInstance) {
              const savedAccounts = await window.ipc.invoke('get-saved-accounts');
              if (savedAccounts) {
                this.loginScreen.autoWheelButtonInstance.setAccounts(savedAccounts);
              }
            }
            document.dispatchEvent(new CustomEvent('accounts-updated', {
              detail: { accounts: [] },
              bubbles: true,
              composed: true
            }));
          } catch (error) {
            console.error('[LoginScreen] Error refreshing after accounts-deleted:', error);
          }
        });

        this.loginScreen.importButtonInstance.addEventListener('delete-error', (event) => {
          const message = event?.detail?.message || 'Failed to delete accounts';
          console.error('[LoginScreen] Delete-all error:', message);
          if (this.loginScreen.passwordInputElem) {
            this.loginScreen.passwordInputElem.error = `Delete failed: ${message}`;
          }
        });
      }

      if (this.loginScreen.autoWheelButtonInstance) {
        this.loginScreen.autoWheelButtonInstance.addEventListener('auto-wheel-login', async (event) => {
          const account = event.detail.account;
          console.log('[LoginScreen] Auto wheel login:', account.username);
          
          try {
            console.log('[LoginScreen] DEBUG: Clearing auth tokens before switching accounts');
            this.loginScreen.clearAuthToken();
            this.loginScreen.clearRefreshToken();
            
            console.log(`[LoginScreen] DEBUG: Setting credentials - Username: "${account.username}", Password: "${account.password}"`);
            this.loginScreen.username = account.username;
            this.loginScreen.password = account.password;
            this.loginScreen.isFakePassword = false;
            
            console.log(`[LoginScreen] DEBUG: About to call logIn() for "${account.username}"`);
            await this.authManager.logIn();
            console.log(`[LoginScreen] DEBUG: logIn() completed for "${account.username}"`);
          } catch (error) {
            console.error('[LoginScreen] Auto wheel login failed:', error);
          }
        });

        this.loginScreen.autoWheelButtonInstance.addEventListener('auto-wheel-logout', (event) => {
          const account = event.detail.account;
          console.log('[LoginScreen] Auto wheel logout:', account.username);
          document.dispatchEvent(new CustomEvent("logout-requested"));
        });

        this.loginScreen.autoWheelButtonInstance.addEventListener('auto-wheel-stopped', () => {
          console.log('[LoginScreen] Auto wheel stopped');
        });

        try {
          const savedAccounts = await window.ipc.invoke('get-saved-accounts');
          if (savedAccounts) {
            this.loginScreen.autoWheelButtonInstance.setAccounts(savedAccounts);
          }
        } catch (error) {
          console.error('[LoginScreen] Failed to load saved accounts for auto wheel:', error);
        }
      }
    }
  };
})();

