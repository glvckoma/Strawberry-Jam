"use strict";

(() => {
  window.LoginScreenAuthManager = class {
    constructor(loginScreenInstance) {
      this.loginScreen = loginScreenInstance;
    }

    _isTokenExpired(token) {
      if (typeof window !== 'undefined' && window.AuthService) {
        const authService = new window.AuthService();
        return authService.isTokenExpired(token);
      }
      if (!token) return true;
      const tokenParts = token.split('.');
      if (tokenParts.length !== 3) {
        console.log("Token does not have JWT format (3 parts):", tokenParts.length, "- treating as non-expiring refresh token");
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
        return decoded.exp < (nowInSeconds + 5);
      } catch (e) {
        console.error("Failed to decode or parse token:", e);
        return true;
      }
    }

    async logIn() {
      console.log(`[LOGIN PROCESS] ============= Starting login process =============`);
      console.log(`[LOGIN PROCESS] Username: ${this.loginScreen.username ? '[SET]' : '[NOT SET]'}`);
      console.log(`[LOGIN PROCESS] Has Auth Token: ${!!this.loginScreen.authToken}`);
      console.log(`[LOGIN PROCESS] Has Refresh Token: ${!!this.loginScreen.refreshToken}`);
      console.log(`[LOGIN PROCESS] Remember Me: ${this.loginScreen.rememberMeElem ? this.loginScreen.rememberMeElem.value : 'unknown'}`);
      console.log(`[LOGIN PROCESS] Has OTP: ${!!this.loginScreen.otp}`);
      console.log(`[LOGIN PROCESS] Login blocked state: ${this.loginScreen.loginBlocked}`);
      
      if (this.loginScreen.loginBlocked) {
        console.log(`[LOGIN PROCESS] Login blocked, returning early`);
        return;
      }
      this.loginScreen.loginBlocked = true;
      if (this.loginScreen.logInButtonElem) {
        this.loginScreen.logInButtonElem.disabled = true;
        this.loginScreen.logInButtonElem.classList.add("loading");
      }

      try {
        console.log(`[DEFPACKS] Current DF state: ${globals.df ? 'SET' : 'NULL'}`);
        console.log(`[DEFPACKS] UUID spoofer active: ${this.loginScreen.uuidSpooferToggle && this.loginScreen.uuidSpooferToggle.checked ? 'YES' : 'NO'}`);
        
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
        } else {
          console.log(`[DEFPACKS] Using existing DF: ${globals.df.substr(0, 8)}...`);
        }

        let authResult;

        console.log("[ANIMAL JAM AUTH] ============= Starting authentication flow =============");
        console.log("[ANIMAL JAM AUTH] Auth token present:", !!this.loginScreen.authToken);
        console.log("[ANIMAL JAM AUTH] Refresh token present:", !!this.loginScreen.refreshToken);
        console.log("[ANIMAL JAM AUTH] OTP present:", !!this.loginScreen.otp);

        let authTokenFailed = false;
        let authTokenOtpNeeded = false;
        let refreshTokenOtpNeeded = false;
        
        if (this.loginScreen.refreshToken) {
          console.log("[ANIMAL JAM AUTH] Attempting refresh token authentication");
          console.log("[ANIMAL JAM AUTH] Refresh token format check:", this.loginScreen.refreshToken ? this.loginScreen.refreshToken.split('.').length + ' parts' : 'null');
          
          if (this._isTokenExpired(this.loginScreen.refreshToken)) {
            console.warn("[ANIMAL JAM AUTH] Refresh token has expired (client-side check). Clearing all tokens.");
            this.loginScreen.clearAuthToken();
            this.loginScreen.clearRefreshToken();
            this.loginScreen.isFakePassword = false;
            throw new Error("REFRESH_TOKEN_EXPIRED");
          }

          if (this.loginScreen.authToken) {
            console.log("[ANIMAL JAM AUTH] Refresh token available. Prioritizing refresh token over auth token.");
          } else {
            console.log("[ANIMAL JAM AUTH] No auth token found. Attempting to use refresh token.");
          }
          try {
            console.log("[ANIMAL JAM AUTH] OTP for refresh token auth:", this.loginScreen.otp ? '[SET]' : '[NOT SET]');
            authResult = await globals.authenticateWithRefreshToken(this.loginScreen.refreshToken, this.loginScreen.otp);
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
              this.loginScreen.clearAuthToken();
              this.loginScreen.clearRefreshToken();
              this.loginScreen.isFakePassword = false;
            } else if (err.message === "OTP_NEEDED") {
              console.log("[ANIMAL JAM AUTH] OTP needed for refresh token, will fall back to auth token or password login");
              refreshTokenOtpNeeded = true;
            } else {
              throw err;
            }
          }
        }
        
        if (!authResult && this.loginScreen.authToken && !this._isTokenExpired(this.loginScreen.authToken) && !refreshTokenOtpNeeded) {
          console.log("[ANIMAL JAM AUTH] Refresh token not available or failed. Attempting authentication with auth token.");
          try {
            authResult = await globals.authenticateWithAuthToken(this.loginScreen.authToken);
            console.log("[ANIMAL JAM AUTH] Auth token authentication successful");
          } catch (err) {
            console.log("[ANIMAL JAM AUTH] Auth token authentication failed:", err.message);
            
            if (err.message === "OTP_NEEDED") {
              console.log("[ANIMAL JAM AUTH] OTP needed for auth token");
              authTokenFailed = true;
              authTokenOtpNeeded = true;
            } else {
              authTokenFailed = true;
            }
          }
        }
        if (authResult) {
          console.log("[ANIMAL JAM AUTH] Using successful token authentication result");
        } else if ((!this.loginScreen.refreshToken || refreshTokenOtpNeeded) && (!this.loginScreen.authToken || this._isTokenExpired(this.loginScreen.authToken) || authTokenFailed)) {
          console.log("[ANIMAL JAM AUTH] No valid tokens or OTP needed. Proceeding with password authentication.");
          console.log("[ANIMAL JAM AUTH] OTP for password auth:", this.loginScreen.otp ? '[SET]' : '[NOT SET]');
          
          if ((authTokenOtpNeeded || refreshTokenOtpNeeded) && !this.loginScreen.otp) {
            console.log("[ANIMAL JAM AUTH] Both tokens need OTP but no OTP provided, throwing OTP_NEEDED");
            throw new Error("OTP_NEEDED");
          }
          
          if (!this.loginScreen.username.length) throw new Error("EMPTY_USERNAME");
          if (!this.loginScreen.password.length) throw new Error("EMPTY_PASSWORD");
          authResult = await globals.authenticateWithPassword(this.loginScreen.username, this.loginScreen.password, this.loginScreen.otp, null);
        }

        console.log("[LOGIN PROCESS] Clearing OTP after successful authentication");
        this.loginScreen.otp = null;
        
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
        
        if (userData.authToken) {
          console.log("[LOGIN PROCESS] Setting auth token:", {
            length: userData.authToken.length,
            parts: userData.authToken.split('.').length
          });
          this.loginScreen.authToken = userData.authToken;
        }
        if (userData.refreshToken) {
          console.log("[LOGIN PROCESS] Setting refresh token:", {
            token: userData.refreshToken,
            length: userData.refreshToken.length,
            parts: userData.refreshToken.split('.').length
          });
          this.loginScreen.refreshToken = userData.refreshToken;
        } else {
          console.log("[LOGIN PROCESS] No refresh token in userData");
        }

        this.loginScreen.usernameInputElem.error = "";
        this.loginScreen.passwordInputElem.error = "";

        console.log('[LOGIN PROCESS] Login successful. Preparing to dispatch events.');
        console.log(`[LOGIN PROCESS] User data:`, {
          username: userData.username,
          accountType: userData.accountType,
          language: userData.language,
          hasAuthToken: !!userData.authToken,
          hasRefreshToken: !!userData.refreshToken
        });
        
        const loginData = {
          username: userData.username,
          language: userData.language || 'en',
          rememberMe: this.loginScreen.rememberMeElem.value,
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

        const theme = this.loginScreen._fruitThemes[this.loginScreen._fruitImages[this.loginScreen._currentFruitIndex]];
        theme.boxBackground = getComputedStyle(this.loginScreen.shadowRoot.host).getPropertyValue('--theme-box-background');
        
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
        this.loginScreen.dispatchEvent(new CustomEvent("loggedIn", { detail: { flashVars, theme } }));

      } catch (err) {
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
              console.warn("[LoginScreen] Caught AUTH_TOKEN_EXPIRED. Forcing re-login.");
              this.loginScreen.clearAuthToken();
              userMessage = "Your session has expired. Please log in again.";
              break;
            case "USER_RENAME_NEEDED":
            case "OTP_NEEDED":
              console.log("[LOGIN PROCESS] OTP_NEEDED or USER_RENAME_NEEDED - keeping UI blocked for modal");
              console.log("[LOGIN PROCESS] UI will be unblocked when OTP modal is submitted");
              return;
            default:
              globals.reportError("webClient", `Unhandled login error: ${err.stack || err.message}`);
              break;
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

