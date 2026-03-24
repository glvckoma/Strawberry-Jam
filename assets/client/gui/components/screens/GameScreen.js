"use strict";

(() => {
  customElements.define("ajd-game-screen", class extends HTMLElement {
    constructor() {
      super();

      this.blankPageString = "data:text/plain,";

      this.retrying = false;

      this.attachShadow({mode: "open"}).innerHTML = `
      <style>
      :host {
        --game-width: 900px;
        --game-height: 550px;
        --game-scale: 1;
        --button-tray-scale: 1.25;
        
          --primary-bg: #121212;
        --secondary-bg: #121212;
        --tertiary-bg: #16171f;
        --sidebar-border: #16171f;
        --text-primary: #C3C3C3;
        --highlight-green: #38b000;
        --theme-primary: #e83d52;
      }
      @media (min-aspect-ratio: 900 / 550) {
        :host {
          --game-width: calc(900 / 550 * 100vh);
          --game-height: 100vh;
          --game-scale: calc(550px / 100vh);
        }
      }
      @media (max-aspect-ratio: 900 / 550) {
        :host {
          --game-width: 100vw;
          --game-height: calc(550 / 900 * 100vw);
          --game-scale: calc(900px / 100vw);
        }
      }

      .hidden {
        opacity: 0;
        transition: opacity 0.3s ease-out;
      }

      #floating-button-tray {
        left: 99%;
        top: calc(-12% * var(--button-tray-scale));
        width: calc(var(--game-height) * 0.13 * var(--button-tray-scale));
        height: calc(var(--game-height) * 0.12 * var(--button-tray-scale));
        position: relative;
        z-index: 1;
        transition-property: left, opacity, transform;
        transition-duration: 0.2s, 0.3s, 0.2s;
        transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
      }

      #floating-button-tray.hidden {
        left: 150vw;
        transform: scale(0.95);
      }

      #floating-button-tray.expanded {
        left: calc(91% + (100vw - var(--game-width)) / 2);
        transform: scale(1.02);
      }

      #game-frame-container {
        width: 100%;
        height: 100%;
        display: grid;
        grid-template: 1fr var(--game-height) 1fr/1fr var(--game-width) 1fr;
        grid-template-areas: ". top ."
                            "left game right"
                            ". bottom .";
        background: radial-gradient(ellipse at center, var(--primary-bg) 0%, rgba(18, 18, 18, 0.95) 100%);
        position: relative;
       transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
      }

      #game-frame-container::before {
        content: '';
        position: absolute;
        inset: 0;
        pointer-events: none;
        opacity: 0;
        animation: subtleGlow 8s ease-in-out infinite;
      }

      @keyframes subtleGlow {
        0%, 100% { opacity: 0; }
        50% { opacity: 1; }
      }

      #game-frame-container.logged-out {
        grid-template-areas: "left game right"
                            ". bottom .";
        transform: scale(1.01);
      }

      .border-spiral-background {
        width: 100%;
        height: 100%;
        pointer-events: none;
        visibility: hidden;
      }

      #border-top, #border-right, #border-bottom, #border-left {
        visibility: hidden;
      }
      #border-top-background { grid-area: top; }
      #border-right-background { grid-area: right; }
      #border-bottom-background { grid-area: bottom; }
      #border-left-background { grid-area: left; }

      #docked-button-tray {
        border: 1px solid rgba(58, 61, 77, 0.3);
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        display: flex;
        flex-direction: column;
        position: absolute;
        height: 11vh;
        width: 12vh;
        left: 0vh;
        bottom: 2vh;
        backdrop-filter: blur(10px);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      }

      #docked-button-tray:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0, 0, 0, 0.4);
      }

      #border-right-container {
        grid-area: right;
      }

      #flash-game-container {
        grid-area: game;
        width: 100%;
        height: 100%;
        border-radius: 8px;
        border: 1px solid rgba(255, 255, 255, 0.08);
        box-shadow: 0 0 40px rgba(0, 0, 0, 0.5);
        position: relative;
        overflow: hidden;
        transition: all 0.3s ease;
      }

      webview {
        transition: opacity 0.75s cubic-bezier(0.4, 0, 0.2, 1);
        border-radius: 4px;
      }

      webview.hidden {
        opacity: 0;
        transform: scale(0.98);
      }

      @media (max-width: 1024px) {
        #docked-button-tray {
          height: 10vh;
          width: 11vh;
        }
      }

      @media (prefers-reduced-motion: reduce) {
        * {
          animation-duration: 0.01ms !important;
          animation-iteration-count: 1 !important;
          transition-duration: 0.01ms !important;
        }
      }

    </style>
    <div id="game-frame-container" class="logged-out">
      <div id="border-top-background"></div>
      <div id="border-bottom-background"></div>
      <div id="border-left-background"></div>
      <div id="border-right-container"></div>
      <div id="flash-game-container">
        <webview id="flash-game-webview" plugins preload="gamePreload.js" webpreferences="contextIsolation=false" style="height: 100%; width: 100%;"></webview>
      </div>
    </div>
      `;
      
      this.webViewElem = this.shadowRoot.querySelector("webview");
      const preloadUrl = new URL('gamePreload.js', window.location.href).href;
      this.webViewElem.setAttribute('preload', preloadUrl);

      this._webviewReady = false;
      this._pendingDevToolsToggle = false;

      this.gameFrameElem = this.shadowRoot.getElementById("game-frame-container");

      this._boundLogoutHandler = () => {
        this.closeGame();
        this.dispatchEvent(new CustomEvent("switchToLogin"));
      };
      document.addEventListener("logout-requested", this._boundLogoutHandler);

      this._boundDragoverHandler = (event) => {
        event.preventDefault();
        return false;
      };
      this._boundDropHandler = (event) => {
        event.preventDefault();
        return false;
      };
      this.webViewElem.addEventListener("dragover", this._boundDragoverHandler, false);
      this.webViewElem.addEventListener("drop", this._boundDropHandler, false);

      this._boundWillNavigateHandler = (event) => {
        console.log(`[GAME NAVIGATION] Game webview attempting navigation to: ${event.url}`);
        console.log(`[GAME NAVIGATION] Closing game due to navigation request`);
        this.closeGame();
      };
      this.webViewElem.addEventListener("will-navigate", this._boundWillNavigateHandler);

      this._boundRedirectHandler = (event) => {
        console.log(`[GAME NAVIGATION] Game webview received redirect request:`, {
          oldURL: event.oldURL,
          newURL: event.newURL
        });
        console.log(`[GAME NAVIGATION] Closing game due to redirect request`);
        this.closeGame();
      };
      this.webViewElem.addEventListener("did-get-redirect-request", this._boundRedirectHandler);

      this._boundNewWindowHandler = (event) => {
        console.log(`[GAME NAVIGATION] Game webview requesting new window: ${event.url}`);
        event.preventDefault();
        console.log(`[GAME NAVIGATION] Opening URL in external browser: ${event.url}`);
        window.ipc.send("openExternal", {url: event.url});
      };
      this.webViewElem.addEventListener("new-window", this._boundNewWindowHandler);

      window.ipc.on("toggleDevTools", () => {
        console.log('[GameScreen] Received "toggleDevTools" IPC message.');
        if (!this.webViewElem) {
          console.warn('[GameScreen] Game webview not available or destroyed when trying to toggle DevTools via IPC.');
          return;
        }
        if (!this._webviewReady) {
          console.warn('[GameScreen] Game webview not ready yet, queuing DevTools toggle.');
          this._pendingDevToolsToggle = true;
          return;
        }
        if (this.webViewElem.isDevToolsOpened()) {
          this.webViewElem.closeDevTools();
          console.log('[GameScreen] Closed game webview DevTools via IPC.');
        } else {
          this.webViewElem.openDevTools({ mode: 'detach' });
          console.log('[GameScreen] Opened game webview DevTools via IPC.');
        }
      });

      const sanitizeLogMessage = (message) => {
        let sanitized = message;
        
        const sensitiveJsonKeys = ['authToken', 'refreshToken', 'df', 'username', 'password', 'auth_token', 'gameSessionIdStr'];
        sensitiveJsonKeys.forEach(key => {
          const regex = new RegExp(`(["']?${key}["']?\\s*:\\s*["'])([^"']*)(["'])`, 'gi');
          sanitized = sanitized.replace(regex, `$1[REDACTED]$3`);
        });

        const passwordWarningRegex = /(Retrieved plaintext password for )([^ ]+)( from)/gi;
        sanitized = sanitized.replace(passwordWarningRegex, '$1[REDACTED]$3');

        const tokenRegex = /([a-zA-Z0-9-_]+\.[a-zA-Z0-9-_]+\.[a-zA-Z0-9-_]{20,})/g;
        sanitized = sanitized.replace(tokenRegex, '[REDACTED_TOKEN]');

        const dfRegex = /[a-f0-9]{64}/gi;
        sanitized = sanitized.replace(dfRegex, '[REDACTED_DF]');

        return sanitized;
      };

      this.webViewElem.addEventListener("console-message", (event) => {
        if (!window.gameClientConsoleLogs) {
          window.gameClientConsoleLogs = [];
        }
        if (window.gameClientConsoleLogs.length > 500) {
          window.gameClientConsoleLogs = window.gameClientConsoleLogs.slice(-400);
        }
        const logLevel = event.level === 0 ? 'INFO' : event.level === 1 ? 'WARN' : 'ERROR';
        window.gameClientConsoleLogs.push({
          level: logLevel,
          message: sanitizeLogMessage(event.message),
          timestamp: new Date().toISOString(),
        });
        
        if (event.level >= 1) {
          console.log('[GameScreen] Game webview ' + logLevel + ': ' + sanitizeLogMessage(event.message));
        }
        if (event.level >= 2) {
          if (window.ipc && window.ipc.send) {
            window.ipc.send('game-webview-console-error');
          }
        }
      });

      this.webViewElem.addEventListener("ipc-message", async event => {
        switch (event.channel) {
          case "signupCompleted": {
            const {username, password} = event.args[0];
            this.dispatchEvent(new CustomEvent("accountCreated", {detail: {username, password}}));

            try {
              const {flashVars, userData} = await globals.authenticateWithPassword(username, password);

              const data = {
                username: userData.username,
                authToken: userData.authToken,
                refreshToken: userData.refreshToken,
                accountType: userData.accountType,
                language: userData.language,
                rememberMe: false,
              };

              window.ipc.send("loginSucceeded", data);
              this.loadGame(flashVars);
            }
            catch (err) {
              console.error(`[GAME IPC] Failed to authenticate new account:`, err);
              globals.genericError(`Failed to log in after account creation: ${err}`);
            }
            break;
          }
          case "initialized": {
            console.log(`[GAME] Game initialized successfully`);
            setTimeout(() => {
              this.classList.add("no-transition-delays");
            }, 1000);
            this.gameFrameElem.classList.remove("logged-out");
            window.UserTrayManager.show();
            this.dispatchEvent(new CustomEvent("gameLoaded"));
          } break;
          case "reloadGame": {
            const reloadSwf = event.args[0];
            if (reloadSwf) {
              if (event.args[1] && (event.args[1].ip || event.args[1].sessionId)) {
                const reloadData = event.args[1];
                globals.reloadFlashVars = {};
                if (reloadData.ip) {
                  globals.reloadFlashVars.smartfoxServer = reloadData.ip;
                  globals.reloadFlashVars.blueboxServer = reloadData.ip;
                }
                if (reloadData.sessionId) {
                  globals.reloadFlashVars.gameSessionId = reloadData.sessionId;
                }
              }
              this.reloadGame();
            }
            else {
              this.closeGame();
            }
          } break;
          case "reportError": {
            globals.reportError("gameClient", event.args[0]);
          } break;
          case "printImage": {
            const imageData = event.args[0];
            window.ipc.send("systemCommand", {command: "print", width: imageData.width, height: imageData.height, image: imageData.image});
          } break;
        }
      });

    }

    async loadGame(flashVars, theme) {
      if (!this.userTray) {
        this.userTray = window.UserTrayManager.create(theme);
      }
      if (this.closeGameTimeout) {
        clearTimeout(this.closeGameTimeout);
        this.closeGameTimeout = null;
        this.resetWebView();
      }

      try {
        const wc = this.webViewElem.getWebContents()
        if (wc && wc.session) {
          await wc.session.clearCache()
        }
      } catch (e) {}

      this.webViewElem.classList.remove("hidden");
      this.webViewElem.src = globals.config.gameWebClient;
      this.webViewElem.addEventListener("dom-ready", () => {
        this._webviewReady = true;
        if (this._pendingDevToolsToggle) {
          this._pendingDevToolsToggle = false;
          this.webViewElem.openDevTools({ mode: 'detach' });
        }
        if (globals.config && globals.config.showTools) {
          if (this.webViewElem && !this.webViewElem.isDestroyed() && !this.webViewElem.isDevToolsOpened()) {
            this.webViewElem.openDevTools({ mode: 'detach' });
          }
        }
        console.log('[SWF] FlashVars ready, sending to webview');
        this.webViewElem.send("flashVarsReady", flashVars);

      }, {once: true});

      this.webViewElem.addEventListener("did-fail-load", event => {
        if (!event.isMainFrame) return;
        if (event.errorCode === -3) return;

        console.error(`[SWF] WebView failed to load:`, {
          validatedURL: event.validatedURL,
          errorCode: event.errorCode,
          errorDescription: event.errorDescription,
          isRetrying: this.retrying
        });
        if (this.retrying) {
          if (!event.validatedURL.includes("/welcome")) {
            console.error(`[SWF LOADING] Final load failure, dispatching loadFailed event`);
            this.dispatchEvent(new CustomEvent("loadFailed"));
            globals.genericError(`Web view failed to load url: ${globals.config.gameWebClient}`);
          }
        }
        else {
          this.retrying = true;
          setTimeout(() => {
            this.loadGame(flashVars);
          }, 2000);
        }
      }, {once: true});
    }

    reloadGame() {
      this.closeGame();
      globals.reloadGame();
    }

    closeGame() {
      this.webViewElem.classList.add("hidden");
      this.retrying = false;
      this.closeGameTimeout = setTimeout(this.resetWebView.bind(this), 1000);
      this.classList.remove("no-transition-delays");
      this.classList.remove("show");
      window.UserTrayManager.hide();
    }

    resetWebView() {
      this._webviewReady = false;
      if (this.webViewElem) {
        const loadPromise = this.webViewElem.loadURL ? this.webViewElem.loadURL(this.blankPageString) : null;
        if (loadPromise) loadPromise.catch(() => {});
        else this.webViewElem.src = this.blankPageString;
      }
      if (this.gameFrameElem) {
        this.gameFrameElem.classList.add("logged-out");
      }
      this.closeGameTimeout = null;
    }

    disconnectedCallback() {
      document.removeEventListener("logout-requested", this._boundLogoutHandler);
      if (this.webViewElem) {
        this.webViewElem.removeEventListener("dragover", this._boundDragoverHandler, false);
        this.webViewElem.removeEventListener("drop", this._boundDropHandler, false);
        this.webViewElem.removeEventListener("will-navigate", this._boundWillNavigateHandler);
        this.webViewElem.removeEventListener("did-get-redirect-request", this._boundRedirectHandler);
        this.webViewElem.removeEventListener("new-window", this._boundNewWindowHandler);
      }
      window.UserTrayManager.destroy();
    }
  });
})();
