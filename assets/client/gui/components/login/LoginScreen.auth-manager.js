"use strict";

(() => {
  window.LoginScreenAuthManager = class {
    constructor(loginScreenInstance) {
      this.loginScreen = loginScreenInstance;
    }

    _isTokenExpired(token) {
      return !token
    }

    async logIn() {
      if (this.loginScreen.loginBlocked) {
        return;
      }
      this.loginScreen.loginBlocked = true;
      if (this.loginScreen.logInButtonElem) {
        this.loginScreen.logInButtonElem.disabled = true;
        this.loginScreen.logInButtonElem.classList.add("loading");
      }

      try {
        if (globals.df === null || (this.loginScreen.uuidSpooferToggle && this.loginScreen.uuidSpooferToggle.checked)) {
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
        }

        let authResult;

        console.log("[AUTH] Starting authentication");

        let authTokenFailed = false;
        let authTokenOtpNeeded = false;
        let refreshTokenOtpNeeded = false;
        
        if (this.loginScreen.refreshToken) {
          if (this._isTokenExpired(this.loginScreen.refreshToken)) {
            console.warn("[AUTH] Refresh token has expired (client-side check). Clearing all tokens.");
            this.loginScreen.clearAuthToken();
            this.loginScreen.clearRefreshToken();
            this.loginScreen.isFakePassword = false;
          } else {
            try {
              authResult = await globals.authenticateWithRefreshToken(this.loginScreen.refreshToken, this.loginScreen.otp);
            } catch (err) {
              if (err.message === "REFRESH_TOKEN_EXPIRED") {
                console.warn("[AUTH] Refresh token has expired (server-side check). Clearing all tokens.");
                this.loginScreen.clearAuthToken();
                this.loginScreen.clearRefreshToken();
                this.loginScreen.isFakePassword = false;
              } else if (err.message === "OTP_NEEDED") {
                refreshTokenOtpNeeded = true;
              } else {
                console.warn("[AUTH] Refresh token authentication failed:", err.message);
                this.loginScreen.clearRefreshToken();
              }
            }
          }
        }

        if (refreshTokenOtpNeeded && !this.loginScreen.otp) {
          throw new Error("OTP_NEEDED");
        }

        if (!authResult && this.loginScreen.authToken && !this._isTokenExpired(this.loginScreen.authToken) && !refreshTokenOtpNeeded) {
          try {
            authResult = await globals.authenticateWithAuthToken(this.loginScreen.authToken);
          } catch (err) {
            if (err.message === "OTP_NEEDED") {
              authTokenFailed = true;
              authTokenOtpNeeded = true;
            } else if (err.message === "LOGIN_ERROR" || err.message === "WRONG_CREDENTIALS") {
              console.warn("[AUTH] Auth token failed server validation (likely expired). Clearing token.");
              this.loginScreen.clearAuthToken();
              authTokenFailed = true;
            } else {
              console.warn("[AUTH] Auth token authentication failed:", err.message);
              this.loginScreen.clearAuthToken();
              authTokenFailed = true;
            }
          }
        }
        if (!authResult && ((!this.loginScreen.refreshToken || refreshTokenOtpNeeded) && (!this.loginScreen.authToken || this._isTokenExpired(this.loginScreen.authToken) || authTokenFailed))) {
          if ((authTokenOtpNeeded || refreshTokenOtpNeeded) && !this.loginScreen.otp) {
            throw new Error("OTP_NEEDED");
          }
          
          if (!this.loginScreen.username.length) throw new Error("EMPTY_USERNAME");
          if (!this.loginScreen.password.length) throw new Error("EMPTY_PASSWORD");
          authResult = await globals.authenticateWithPassword(this.loginScreen.username, this.loginScreen.password, this.loginScreen.otp, null);
        }

        this.loginScreen.otp = null;
        
        if (!authResult || !authResult.userData) {
          throw new Error("Invalid authentication result - missing user data");
        }
        
        const { userData, flashVars } = authResult;
        
        if (userData.authToken) {
          this.loginScreen.authToken = userData.authToken;
        }
        if (userData.refreshToken) {
          this.loginScreen.refreshToken = userData.refreshToken;
        }

        this.loginScreen.usernameInputElem.error = "";
        this.loginScreen.passwordInputElem.error = "";

        console.log("[AUTH] Authentication successful");
        
        const loginData = {
          username: userData.username,
          language: userData.language || 'en',
          rememberMe: this.loginScreen.rememberMeElem.value,
          authToken: userData.authToken,
          refreshToken: userData.refreshToken,
        };
        window.ipc.send("loginSucceeded", loginData);

        const theme = this.loginScreen._fruitThemes[this.loginScreen._fruitImages[this.loginScreen._currentFruitIndex]];
        theme.boxBackground = getComputedStyle(this.loginScreen.shadowRoot.host).getPropertyValue('--theme-box-background');
        
        this.loginScreen.dispatchEvent(new CustomEvent("loggedIn", { detail: { flashVars, theme } }));

      } catch (err) {
        let userMessage = "Servers are down or Your IP is blocked. Please try again later.";

        if (err.message) {
          switch (err.message) {
            case "USER_RENAME_NEEDED":
            case "OTP_NEEDED":
              this.loginScreen.loginBlocked = false;
              if (this.loginScreen.logInButtonElem) {
                this.loginScreen.logInButtonElem.disabled = false;
                this.loginScreen.logInButtonElem.classList.remove("loading");
              }
              return;
            case "SUSPENDED": userMessage = await globals.translate("userSuspended"); break;
            case "BANNED": userMessage = await globals.translate("userBanned"); break;
            case "LOGIN_ERROR": userMessage = await globals.translate("loginError"); break;
            case "WRONG_CREDENTIALS": userMessage = await globals.translate("wrongCredentials"); break;
            case "EMPTY_USERNAME": userMessage = await globals.translate("usernameRequired"); break;
            case "EMPTY_PASSWORD": userMessage = await globals.translate("emptyPassword"); break;
            case "RATE_LIMITED": userMessage = "Rate limited. Please try again in a few moments."; break;
            case "REFRESH_TOKEN_EXPIRED": userMessage = "Your session has expired. Please log in again."; break;
            case "AUTH_TOKEN_EXPIRED":
              console.warn("[LoginScreen] Caught AUTH_TOKEN_EXPIRED. Forcing re-login.");
              this.loginScreen.clearAuthToken();
              userMessage = "Your session has expired. Please log in again.";
              break;
            default:
              if (err.message && err.message.includes('API server is not running')) {
                userMessage = err.message;
              } else {
                globals.reportError("webClient", `Unhandled login error: ${err.stack || err.message}`);
              }
              break;
          }
          if (err.message !== "OTP_NEEDED" && err.message !== "USER_RENAME_NEEDED") {
            console.error(`[LoginScreen] Login failed: ${err.message}`, err);
          }
        } else {
          globals.reportError("webClient", `Unknown login error: ${err}`);
        }
        
        this.loginScreen.passwordInputElem.error = userMessage;

        this.loginScreen.loginBlocked = false;
        if (this.loginScreen.logInButtonElem) {
          this.loginScreen.logInButtonElem.disabled = false;
          this.loginScreen.logInButtonElem.classList.remove("loading");
        }
      }
    }

    canRetry() {
      return (this.loginScreen.authToken !== null || this.loginScreen.refreshToken !== null ||
        (this.loginScreen.username && this.loginScreen.password && !this.loginScreen.isFakePassword));
    }
  };
})();

