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
        
        /* Application theme colors for consistency */
        --primary-bg: #121212;
        --secondary-bg: #121212;
        --tertiary-bg: #3A3D4D;
        --sidebar-border: #3A3D4D;
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

      /* New User Tray Styling - adjust as needed */
      ajd-user-tray {
        position: absolute; /* Positioned relative to flash-game-container */
        top: 350px;
        right: 10px;
        z-index: 100; /* Ensure it's above the webview */
      }
      ajd-user-tray.hidden {
        display: none !important;
      }


      /* Enhanced game frame container with modern styling */
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
        background: linear-gradient(45deg, 
          transparent 0%, 
          rgba(232, 61, 82, 0.03) 25%, 
          transparent 50%, 
          rgba(56, 176, 0, 0.03) 75%, 
          transparent 100%);
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

      /* Enhanced border backgrounds with modern gradients */
      .border-spiral-background {
        width: 100%;
        height: 100%;
        background-image: url(images/frame/spiralTile.svg);
        object-fit: cover;
        pointer-events: none;
        filter: brightness(0.8) contrast(1.1);
        transition: filter 0.3s ease;
      }

      #border-top {
        grid-area: top;
        object-position: 0 100%;
        opacity: 0.9;
        transition: opacity 0.3s ease;
      }

      #border-top:hover {
        opacity: 1;
      }

      /* Enhanced border backgrounds with modern styling */
      #border-top-background {
        grid-area: top;
        width: calc(100% + 2px);
        height: calc(100% + 1px);
        background: linear-gradient(270deg, 
          var(--tertiary-bg) 0%, 
          var(--sidebar-border) 50%, 
          var(--tertiary-bg) 100%);
        margin-left: -1px;
        margin-top: -1px;
        position: relative;
        overflow: hidden;
      }

      #border-top-background::before {
        content: '';
        position: absolute;
        inset: 0;
        background: linear-gradient(270deg,
          transparent 0%,
          rgba(232, 61, 82, 0.1) 50%,
          transparent 100%);
        opacity: 0;
        transition: opacity 0.4s ease;
      }

      #border-top-background:hover::before {
        opacity: 1;
      }

      #border-right {
        object-fit: cover;
        object-position: 0 0;
        width: 100%;
        height: 100%;
        opacity: 0.9;
        transition: opacity 0.3s ease;
      }

      #border-right:hover {
        opacity: 1;
      }

      #border-right-background {
        grid-area: right;
        width: calc(100% + 1px);
        height: calc(100% + 2px);
        background: linear-gradient(0deg, 
          var(--tertiary-bg) 0%, 
          var(--sidebar-border) 50%, 
          var(--tertiary-bg) 100%);
        margin-top: -1px;
        position: relative;
        overflow: hidden;
      }

      #border-right-background::before {
        content: '';
        position: absolute;
        inset: 0;
        background: linear-gradient(0deg,
          transparent 0%,
          rgba(56, 176, 0, 0.1) 50%,
          transparent 100%);
        opacity: 0;
        transition: opacity 0.4s ease;
      }

      #border-right-background:hover::before {
        opacity: 1;
      }

      #docked-button-tray {
        background: linear-gradient(135deg, var(--tertiary-bg) 0%, var(--sidebar-border) 100%);
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
        background: linear-gradient(135deg, var(--sidebar-border) 0%, var(--tertiary-bg) 100%);
      }

      #border-right-container {
        position: relative;
        grid-area: right;
      }

      #border-bottom {
        grid-area: bottom;
        object-position: 0 0;
        opacity: 0.9;
        transition: opacity 0.3s ease;
      }

      #border-bottom:hover {
        opacity: 1;
      }

      #border-bottom-background {
        grid-area: bottom;
        border: none;
        width: calc(100% + 2px);
        height: calc(100% + 2px);
        margin-left: -1px;
        margin-top: -1px;
        background: linear-gradient(270deg, 
          var(--tertiary-bg) 0%, 
          var(--sidebar-border) 50%, 
          var(--tertiary-bg) 100%);
        position: relative;
        overflow: hidden;
      }

      #border-bottom-background::before {
        content: '';
        position: absolute;
        inset: 0;
        background: linear-gradient(270deg,
          transparent 0%,
          rgba(240, 180, 41, 0.1) 50%,
          transparent 100%);
        opacity: 0;
        transition: opacity 0.4s ease;
      }

      #border-bottom-background:hover::before {
        opacity: 1;
      }

      #border-left { 
        grid-area: left;
        /* object-position: 100% 0; */ /* Removed as src is gone */
        opacity: 0.9;
        transition: opacity 0.3s ease;
      }

      #border-left:hover { 
        opacity: 1;
      }

      #border-left-background {
        grid-area: left;
        width: calc(100% + 1px);
        height: calc(100% + 2px);
        background: linear-gradient(0deg, 
          var(--tertiary-bg) 0%, 
          var(--sidebar-border) 50%, 
          var(--tertiary-bg) 100%);
        margin-left: -1px;
        margin-top: -1px;
        position: relative;
        overflow: hidden;
      }

      #border-left-background::before {
        content: '';
        position: absolute;
        inset: 0;
        background: linear-gradient(0deg,
          transparent 0%,
          rgba(195, 195, 195, 0.05) 50%,
          transparent 100%);
        opacity: 0;
        transition: opacity 0.4s ease;
      }

      #border-left-background:hover::before {
        opacity: 1;
      }

      /* Enhanced flash game container */
      #flash-game-container {
        grid-area: game;
        width: 100%;
        height: 100%;
        background: linear-gradient(135deg, var(--primary-bg) 0%, rgba(18, 18, 18, 0.9) 100%);
        border-radius: 4px;
        box-shadow: inset 0 0 20px rgba(0, 0, 0, 0.5);
        position: relative;
        overflow: hidden;
        transition: all 0.3s ease;
      }

      #flash-game-container::before {
        content: '';
        position: absolute;
        inset: 2px;
        border-radius: 2px;
        background: transparent;
        border: 1px solid rgba(58, 61, 77, 0.2);
        pointer-events: none;
        transition: border-color 0.3s ease;
      }

      webview {
        transition: opacity 0.75s cubic-bezier(0.4, 0, 0.2, 1);
        border-radius: 4px;
      }

      webview.hidden {
        opacity: 0;
        transform: scale(0.98);
      }

      /* Responsive enhancements */
      @media (max-width: 1024px) {
        #game-frame-container {
        }
        
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
      <div id="game-background"></div>
      <img id="border-top-background" class="border-spiral-background"></img>
       <img id="border-top" src="images/frame/standAlone_woodTop.svg" class="border-spiral-background"></img> 
      <img id="border-bottom-background" class="border-spiral-background"></img>
       <img id="border-bottom" src="images/frame/standAlone_woodBtm.svg" class="border-spiral-background"></img> 
      <img id="border-left-background" class="border-spiral-background"></img>
       <img id="border-left" src="images/frame/standAlone_woodLeft.svg" class="border-spiral-background"></img> 
      <img id="border-right-background" class="border-spiral-background"></img>
      <div id="border-right-container">
         <img id="border-right" src="images/frame/standAlone_woodRight.svg" class="border-spiral-background"></img>
      </div>
      <div id="flash-game-container">
        <webview id="flash-game-webview" plugins preload="gamePreload.js" style="height: 100%; width: 100%;"></webview>
        <ajd-user-tray id="user-tray-element" class="hidden"></ajd-user-tray> <!-- New Tray Added -->
      </div>
    </div>
      `;
      
      this.webViewElem = this.shadowRoot.querySelector("webview");

      this.gameFrameElem = this.shadowRoot.getElementById("game-frame-container");

      this.webViewElem.addEventListener("dragover", event => {
        event.preventDefault();
        return false;
      }, false);
      this.webViewElem.addEventListener("drop", event => {
        event.preventDefault();
        return false;
      }, false);

      // redirect all navigation to desktop client
      this.webViewElem.addEventListener("will-navigate", event => {
        this.closeGame();
      });

      this.webViewElem.addEventListener("did-get-redirect-request", event => {
        this.closeGame();
      });

      // open new windows in native browser
      this.webViewElem.addEventListener("new-window", event => {
        event.preventDefault();
        window.ipc.send("openExternal", {url: event.url});
      });

      // Listener for the new specific request from main process
      window.ipc.on("request-toggle-game-client-devtools", () => {
        console.log('[GameScreen] Received request-toggle-game-client-devtools');
        if (this.webViewElem && this.webViewElem.getWebContents && this.webViewElem.getWebContents() && !this.webViewElem.getWebContents().isDestroyed()) {
          // The main process already confirmed game client is active.
          // We just need to ensure the webview element and its webContents are available.
          if (this.webViewElem.isDevToolsOpened()) {
            this.webViewElem.closeDevTools();
            console.log('[GameScreen] Closed game client DevTools via request.');
          } else {
            this.webViewElem.openDevTools();
            console.log('[GameScreen] Opened game client DevTools via request.');
          }
        } else {
          console.warn('[GameScreen] Game webview or its webContents not available for DevTools toggle via request.');
        }
      });

      // Existing listener (might be for a different purpose or an old mechanism)
      window.ipc.on("toggleDevTools", () => {
        console.log('[GameScreen] Received "toggleDevTools" IPC message.');
        // Simplified condition: Main process already checks if user is logged in.
        // Here, we primarily ensure the webview and its webContents are available.
        if (this.webViewElem && 
            this.webViewElem.getWebContents &&
            this.webViewElem.getWebContents() &&
            !this.webViewElem.getWebContents().isDestroyed()) {

          if (this.webViewElem.isDevToolsOpened()) {
            this.webViewElem.closeDevTools();
            console.log('[GameScreen] Closed game webview DevTools.');
          } else {
            this.webViewElem.openDevTools();
            console.log('[GameScreen] Opened game webview DevTools.');
          }
        } else {
          console.warn('[GameScreen] Game webview or its webContents not available for DevTools toggle.');
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
              globals.genericError(`Failed to log in after account creation: ${err}`);
            }
            break;
          }
          case "initialized": {
            setTimeout(() => {
              this.classList.add("no-transition-delays");
            }, 1000);
            this.gameFrameElem.classList.remove("logged-out");
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

      // Removed dockedContainerElem and floatingContainerElem references for old tray
      // Removed IntersectionObserver logic

      this.userTray = this.shadowRoot.getElementById("user-tray-element");
      if (this.userTray) {
        this.userTray.addEventListener("logout-requested", () => {
          this.closeGame();
        });
      } else {
        console.error("[GameScreen] ajd-user-tray element not found!");
      }
    }

    // Renamed from setScreenState to align with new tray's method name for clarity
    updateTrayAppearance(windowState) {
      // console.log(`[GameScreen] updateTrayAppearance called with: ${windowState}`);
      if (this.userTray && typeof this.userTray.setAppearance === 'function') {
        this.userTray.setAppearance(windowState);
      } else {
        console.warn("[GameScreen] User tray or its setAppearance method not available.");
      }
    }

    loadGame(flashVars) {
      console.log(flashVars)
      // prevent race condition with reloads
      if (this.closeGameTimeout) {
        clearTimeout(this.closeGameTimeout);
        this.closeGameTimeout = null;
        this.resetWebView();
      }

      this.webViewElem.classList.remove("hidden");
      this.webViewElem.src = globals.config.gameWebClient;
      this.webViewElem.addEventListener("dom-ready", () => {
        if (globals.config.showTools) {
          this.webViewElem.openDevTools();
        }
        // Use the flashVars as-is without forcing locale to 'en'
        console.log('[GameScreen] Using original flashVars with locale:', flashVars.locale); // Log the selected locale
        this.webViewElem.send("flashVarsReady", flashVars);

        // Notify main process that game screen is ready for devtools shortcut
        window.ipc.send('game-screen-ready-for-devtools');
        console.log('[GameScreen] Sent game-screen-ready-for-devtools to main process.');
        
        if (this.userTray) {
          if (flashVars.webRefPath !== "create_account") {
            this.userTray.show(); // Make tray visible
            // Determine initial appearance based on current window state (main process will send screenChange)
            // For now, default to windowed appearance, screenChange event will correct it.
            this.userTray.setAppearance('windowed'); 
          } else {
            this.userTray.hide(); // Hide tray on account creation screen
          }
        }
      }, {once: true});

      // Sometimes loading the URL just fails, retry once then display an oops
      this.webViewElem.addEventListener("did-fail-load", event => {
        if (this.retrying) {
          if (!event.validatedURL.includes("/welcome")) {
            this.dispatchEvent(new CustomEvent("loadFailed"));
            globals.genericError(`Web view failed to load url: ${globals.config.gameWebClient}`);
          }
        }
        else {
          this.retrying = true;
          setTimeout(() => {
            this.loadGame(flashVars);
          }, 50);
        }
      }, {once: true});
    }

    reloadGame() {
      this.closeGame();
      globals.reloadGame();
    }

    // TODO: make this transition better
    closeGame() {
      this.webViewElem.classList.add("hidden");
      this.retrying = false;
      this.closeGameTimeout = setTimeout(this.resetWebView.bind(this), 1000);
      if (this.userTray) {
        this.userTray.hide(); // Hide tray when game closes
      }
      this.classList.remove("no-transition-delays");
      this.classList.remove("show");
    }

    resetWebView() {
      if (this.webViewElem) {
        this.webViewElem.src = this.blankPageString;
      }
      if (this.gameFrameElem) {
        this.gameFrameElem.classList.add("logged-out");
      }
      if (this.userTray) {
         this.userTray.hide(); // Ensure tray is hidden
      }
      this.closeGameTimeout = null;
    }

    localize() {
      // this.floatingContainerElem.localize(); // Old tray
      if (this.userTray && typeof this.userTray.localize === 'function') {
        this.userTray.localize();
      }
    }
  });
})();
