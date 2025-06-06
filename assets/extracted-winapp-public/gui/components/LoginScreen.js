"use strict";

// are now called directly in the constructor. They are expected to be globally available

(() => {
  let forgotBlocked = false;
  const _winappConsoleLogs = []; // Array to store captured logs
  // _mainLogPath is no longer used for this component's report button.

  // Capture console logs from this scope
  const originalConsoleLog = console.log;
  const originalConsoleWarn = console.warn;
  const originalConsoleError = console.error;
  const originalConsoleInfo = console.info;
  const originalConsoleDebug = console.debug;

  const captureLog = (level, ...args) => {
    const timestamp = new Date().toISOString();
    const message = args.map(arg => typeof arg === 'object' ? JSON.stringify(arg) : String(arg)).join(' ');
    _winappConsoleLogs.push({ timestamp, level, message });
    if (_winappConsoleLogs.length > 500) { // Limit stored logs
      _winappConsoleLogs.splice(0, _winappConsoleLogs.length - 400); // Keep last 400
    }
  };

  console.log = (...args) => {
    captureLog('LOG', ...args);
    originalConsoleLog.apply(console, args);
  };
  console.warn = (...args) => {
    captureLog('WARN', ...args);
    originalConsoleWarn.apply(console, args);
  };
  console.error = (...args) => {
    captureLog('ERROR', ...args);
    originalConsoleError.apply(console, args);
  };
  console.info = (...args) => {
    captureLog('INFO', ...args);
    originalConsoleInfo.apply(console, args);
  };
  console.debug = (...args) => {
    captureLog('DEBUG', ...args);
    originalConsoleDebug.apply(console, args);
  };


  const forgotPassword = () => {
    if (forgotBlocked) {
      return;
    }
    forgotBlocked = true;

    const modal = document.createElement("ajd-forgot-password-modal");
    modal.addEventListener("close", event => {
      document.getElementById("modal-layer").removeChild(modal);
      forgotBlocked = false;
    });
    document.getElementById("modal-layer").appendChild(modal);
  };

  // Helper function to darken a hex color by a percentage (moved outside class)
  const darkenColor = (hex, percent) => {
    if (!hex || hex.length < 7) return hex;
    
    // Convert hex to RGB
    let r = parseInt(hex.slice(1, 3), 16);
    let g = parseInt(hex.slice(3, 5), 16);
    let b = parseInt(hex.slice(5, 7), 16);
    
    // Darken
    r = Math.max(0, Math.floor(r * (100 - percent) / 100));
    g = Math.max(0, Math.floor(g * (100 - percent) / 100));
    b = Math.max(0, Math.floor(b * (100 - percent) / 100));
    
    // Convert back to hex
    return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`;
  };

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

      this.attachShadow({mode: "open"}).innerHTML = `
        <style>
          
          /* Define CSS variables for theming */
          :host {
            --theme-primary: #e83d52; /* Default: Strawberry Red */
            --theme-secondary: rgba(232, 61, 82, 0.3);
            --theme-highlight: rgba(255, 220, 220, 0.3);
            --theme-shadow: rgba(252, 93, 93, 0.1);
            --theme-gradient-start: rgba(255, 220, 220, 0.3);
            --theme-gradient-end: rgba(255, 245, 230, 0.6);
            --theme-hover-border: rgba(232, 61, 82, 0.5);
            --theme-radial-1: rgba(255, 180, 180, 0.05);
            --theme-radial-2: rgba(255, 200, 200, 0.07);
            --theme-settings-hover: rgba(232, 61, 82, 0.05);
            --theme-settings-border: rgba(232, 61, 82, 0.2);
            --theme-box-background: rgba(255, 245, 230, 0.95); /* Default box background */
            --theme-button-bg: var(--theme-primary); /* Default button background */
            --theme-button-border: var(--theme-secondary); /* Default button border */
            --theme-button-text: #FFFFFF; /* Default button text */
            
            width: 100vw;
            height: calc(100vh - 2px);
            display: grid;
            /* Modified grid to make space for settings button and account panel */
            grid-template: 1fr 590px 1fr / 1fr 70px 936px 1fr; /* Increased panel column from 60px to 70px */
            grid-template-areas: ". . . button-tray" /* Adjusted button-tray to new column structure */
                                 ". panel box ."    /* Added 'panel' area */
                                 ". . . .";        /* Adjusted for new column */
            background-color: rgba(239, 234, 221, 0);
            transition: background-color 0.2s;
          }
          
          /* Settings button and panel styles */
          .icon-button-top-left { /* Common style for top-left icon buttons */
            position: absolute;
            top: 10px;
            width: 32px;
            height: 32px;
            font-size: 18px; /* Adjusted for potentially smaller icons */
            border: 2px solid var(--theme-secondary);
            border-radius: 8px;
            background-color: rgba(255, 245, 230, 0.95); /* Keep neutral */
            cursor: pointer;
            opacity: 0.8;
            transition: all 0.3s ease;
            z-index: 1000;
            display: flex;
            align-items: center;
            justify-content: center;
          }

          .icon-button-top-left:hover {
            opacity: 1;
            border-color: var(--theme-hover-border);
            transform: scale(1.05);
          }

          #settings-btn {
            left: 10px;
            /* Inherits from .icon-button-top-left */
          }

          #report-problem-btn {
            left: 52px; /* Position next to settings button (10px left + 32px width + 10px gap) */
            /* Inherits from .icon-button-top-left */
            font-size: 16px; /* Slightly smaller for bug icon if needed */
          }
          
          #settings-panel {
            position: absolute;
            top: 50px; /* Below the buttons */
            left: 10px;
            width: 32px;
            font-size: 20px;
            border: 2px solid var(--theme-secondary);
            border-radius: 8px;
            background-color: rgba(255, 245, 230, 0.95); /* Keep neutral */
            cursor: pointer;
            opacity: 0.8;
            transition: all 0.3s ease;
            z-index: 1000;
            align-items: center;
            justify-content: center;
          }
          
          #settings-btn:hover {
            opacity: 1;
            border-color: var(--theme-hover-border);
            transform: scale(1.05);
          }
          
          #settings-panel {
            position: absolute;
            top: 50px;
            left: 10px;
            width: 250px;
            background-color: rgba(255, 245, 230, 0.95); /* Keep neutral */
            border: 2px solid var(--theme-secondary);
            border-radius: 12px;
            padding: 15px;
            /* display: none; */ /* Handled by animation */
            z-index: 1000;
            box-shadow: 0 8px 32px var(--theme-shadow);
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
          }
          
          #settings-panel h3 {
            margin-top: 0;
            color: var(--theme-primary);
            font-family: Tiki-Island;
            font-size: 18px;
            text-align: center;
            margin-bottom: 10px;
            text-shadow: 1px 1px 0px var(--theme-shadow);
            transition: color 0.3s ease, text-shadow 0.3s ease;
          }
          
          .settings-group {
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--theme-settings-border);
            transition: border-bottom-color 0.3s ease;
          }
          
          .settings-group:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
          }
          
          .settings-item {
            display: flex;
            align-items: center;
            margin-bottom: 10px;
            font-size: 12px;
            color: #6E4B37;
            font-family: CCDigitalDelivery;
            padding: 4px;
            transition: background-color 0.2s;
            border-radius: 6px;
          }
          
          .settings-item:hover {
            background-color: var(--theme-settings-hover);
          }
          
          .settings-item input[type="checkbox"] {
            margin-right: 8px;
          }

          .hidden {
            display: none !important;
          }

          #box-background {
            /* Original grid area */
            grid-area: box;
            background-color: var(--theme-box-background); /* Use theme variable */
            border-radius: 20px;
            box-shadow: 0 8px 32px var(--theme-shadow);
            border: 1px solid var(--theme-secondary);
            opacity: 1;
            transition: opacity 0.2s, box-shadow 0.3s ease, border-color 0.3s ease, background-color 0.3s ease; /* Added background-color transition */
          }

          @media (max-width: 950px), (max-height: 590px) {
            #box-background {
              z-index: -1;
              opacity: 0;
            }

            :host {
              background-color: rgba(255, 240, 245, 1); /* Keep neutral */
              background-image: linear-gradient(to bottom right, var(--theme-gradient-start), var(--theme-gradient-end));
              transition: background-image 0.3s ease;
            }
          }

          #box {
            grid-area: box;
            display: flex;
            justify-content: center;
            align-items: center; /* Added for vertical centering */
            /* Removed border-image, handled by #box-background */
            padding: 50px 70px 50px;
            /* position: relative; */ /* REMOVED */
            /* z-index: 1; */         /* REMOVED */
            
            /* Themed radial accents */
            background-image: 
              radial-gradient(circle at 10% 20%, var(--theme-radial-1) 0%, transparent 50%),
              radial-gradient(circle at 90% 80%, var(--theme-radial-2) 0%, transparent 50%);
            transition: background-image 0.3s ease;
          }

          #login-container {
            display: flex;
            flex-direction: column;
            align-items: center;
          }

          #login-container > * {
            margin-bottom: 9px;
          }

          #login-image {
            user-select: none;
            pointer-events: none;
            grid-area: left;
          }

          #need-account {
            user-select: none;
            pointer-events: none;
            font-size: 12px;
            line-height: 18px;
            letter-spacing: -0.25px;
            color: #6E4B37;
            font-family: CCDigitalDelivery;
            font-weight: bold;
          }

          #player-login-text {
            color: var(--theme-primary);
            font-family: Tiki-Island;
            font-size: 36px;
            text-shadow: 1px 2px 0px var(--theme-shadow);
            margin-bottom: 10px;
            letter-spacing: 0.5px;
            transition: color 0.3s ease, text-shadow 0.3s ease;
          }

          #login-btn-container {
            display: grid;
            grid-template: 1fr / 1fr fit-content(100%) 1fr;
            grid-template-areas: "left mid right";
            align-items: center;
          }

          #log-in-btn {
            grid-area: mid;
            padding: 6px 24px;
            /* Apply theme variables to bubble buttons */
            --ajd-bubble-button-background-color: var(--theme-button-bg);
            --ajd-bubble-button-border-color: var(--theme-button-border);
            --ajd-bubble-button-text-color: var(--theme-button-text);
            transition: background-color 0.3s ease, border-color 0.3s ease, color 0.3s ease;
          }

          @keyframes fade {
            0%,100% { opacity: 0 }
            50% { opacity: 1 }
          }

           @keyframes spin {
             from {
               transform: rotate(0deg);
             }
             to {
               transform: rotate(-360deg);
             }
           }

           /* --- Fruit Rotation Animation (Simple Pop) --- */
           @keyframes fruit-pop {
             0%   { transform: scale(1); } /* Start normal */
             50%  { transform: scale(1.25); } /* Pop bigger */
             100% { transform: scale(1); } /* Settle to normal size */
           }

           .fruit-animate {
             /* Apply the animation */
             animation: fruit-pop 0.3s ease-out; /* Quick pop */
             /* Ensure the image flips back correctly if starting flipped */
             transform-style: preserve-3d;
           }
           /* --- End Fruit Rotation Animation --- */

          #spinner {
            margin-left: 10px;
            grid-area: left;
            height: 90%;
            opacity: 0;
            transition: opacity .5s;
            animation: spin 1500ms linear infinite;
          }

          /* --- Fruit Rotation Animation (Simple Pop) --- */
          @keyframes fruit-pop {
            0%   { transform: scale(1); } /* Start normal */
            50%  { transform: scale(1.25); } /* Pop bigger */
            100% { transform: scale(1); } /* Settle to normal size */
          }

          .fruit-animate {
            /* Apply the animation */
            animation: fruit-pop 0.3s ease-out; /* Quick pop */
            /* Ensure the image flips back correctly if starting flipped */
            transform-style: preserve-3d; 
          }
          /* --- End Fruit Rotation Animation --- */

          #spinner.show {
            opacity: 1;
          }

          ajd-text-input {
            width: 100%;
            border-radius: 25px;
            border: var(--theme-secondary) 2px solid;
            transition: border-color 0.3s ease;
            margin-bottom: 12px;
          }

          ajd-text-input:hover {
            border-color: var(--theme-hover-border);
          }

          #remember-me-cb {
            font-size: 15px;
            letter-spacing: -1px;
            font-weight: bold;
          }

          #forgot-password-link {
            font-size: 12px;
            line-height: 14px;
            letter-spacing: .25px;
            color: #CC6C2B;
            text-decoration: none;
            user-select: none;
            cursor: pointer;
            font-family: CCDigitalDelivery;
          }

          .vertical-spacer {
            height: 2px;
            width: 75%;
            border-bottom: var(--theme-secondary) 2px solid;
            margin: 10px 0;
            transition: border-bottom-color 0.3s ease;
          }

          #forgot-password-link {
            letter-spacing: -0.5px;
          }

          #forgot-password-link:hover {
            text-decoration: underline;
          }

          #create-account-btn {
            font-size: 24px;
            padding: 4px 12px;
            /* Apply theme variables to bubble buttons */
            --ajd-bubble-button-background-color: var(--theme-button-bg);
            --ajd-bubble-button-border-color: var(--theme-button-border);
            --ajd-bubble-button-text-color: var(--theme-button-text);
            transition: background-color 0.3s ease, border-color 0.3s ease, color 0.3s ease;
          }

          #version {
            position: absolute;
            right: 10px;
            bottom: 10px;
            display: grid;
            grid-template-columns: 1fr 24px;
          }

          #version:hover {
            text-decoration: underline;
          }

          #version-link {
            font-size: 16px;
            line-height: 24px;
            letter-spacing: -0.5px;
            color: #684A26;
            text-decoration: none;
            user-select: none;
            cursor: pointer;
            font-family: CCDigitalDelivery;
          }

          #version-status-icon {
            background: url(images/core/core_form_input_status_icn_sprite.svg);
            background-repeat: no-repeat;
            background-size: 80px;
            width: 20px;
            height: 20px;
            opacity: 0.0;
          }

          #version-status-icon.check {
            background-position: -20px 0px;
            animation: spin 1500ms linear infinite;
            opacity: 1.0;
            transition-property: opacity;
            transition-duration: 0.5s;
          }

          #version-status-icon.download {
            opacity: 1.0;
          }

          #version-status-icon.restart {
            background-position: -40px 0px;
            opacity: 0.0;
            animation: fade 1.5s ease-out infinite;
          }

          #version-status-icon.error {
            background-position: -60px 0px;
            opacity: 0.0;
            animation: fade 1.5s ease-out infinite;
          }

          #button-tray {
            grid-area: button-tray;
            display: flex;
            flex-direction: row;
            justify-content: flex-end;
          }
          #button-tray ajd-button {
            width: 54px;
            height: 54px;
          }

          /* Account Management Panel Styling MOVED to AccountManagementPanel.css */
          /* Context Menu Styling MOVED to AccountManagementPanel.css */

          /* Settings Panel Animation */
          @keyframes slideDown {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
          }
          
          #settings-panel {
            max-height: 0;
            overflow: hidden;
            opacity: 0;
            padding: 15px; /* Keep padding defined here, will be hidden by max-height: 0 */
            transition: max-height 0.3s cubic-bezier(0.34, 1.56, 0.64, 1), 
                        opacity 0.3s ease; /* Removed padding from transition */
            transform-origin: top center;
            /* width: 250px; is already defined above, ensure it's not overridden */
          }
          
          #settings-panel.show {
            max-height: 500px; /* Adjust as needed to fit content */
            opacity: 1;
            /* animation: slideDown 0.3s ease forwards; */ /* slideDown can be kept or rely on transition */
            /* If slideDown is used, ensure it primarily handles transform/opacity if max-height handles size */
          }
          
          /* Show/hide warning for UUID spoofing */
          #uuid-spoofing-warning {
            max-height: 0;
            overflow: hidden;
            opacity: 0;
            transition: max-height 0.2s ease, opacity 0.2s ease, margin 0.2s ease;
          }
          
          #uuid-spoofing-warning.show {
            max-height: 100px; /* Adjust as needed */
            opacity: 1;
            margin-top: 5px;
          }
          
        </style>
        <div id="box-background"></div>
        <account-management-panel id="account-panel-instance" style="grid-area: panel; align-self: center;"></account-management-panel>
        <div id="button-tray" class="hidden">
          <ajd-button graphic="UI_fullScreen" id="expand-button">
          </ajd-button>
          <ajd-button graphic="UI_power" id="close-button">
          </ajd-button>
        </div>
        <div id="box">
<div id="login-container">
  <img src="images/strawberry.png" alt="App Icon" id="login-app-icon" style="width:90px;display:block;margin-bottom:8px;margin-left:auto;margin-right:auto;"> <!-- Changed default src -->
  <div id="player-login-text">playerLogin</div>
  <ajd-text-input id="username-input" placeholder="username" type="text"></ajd-text-input>
            <ajd-text-input id="password-input" placeholder="password" type="password"></ajd-text-input>
            <ajd-checkbox id="remember-me-cb" text="rememberMeText"></ajd-checkbox>
            <div id="login-btn-container">
              <ajd-bubble-button id="log-in-btn" text="login"></ajd-bubble-button>
              <img id="spinner" src="images/electron_login/log_spinner.svg"></img>
            </div>
            <a id="forgot-password-link">forgotPassword</a>
            <div class="vertical-spacer"></div>
            <div id="need-account">needAccount?</div>
            <ajd-bubble-button id="create-account-btn" text="createAnimal"></ajd-bubble-button>
          </div>
        </div>

        <!-- Settings Button and Panel -->
        <button id="settings-btn" title="Settings" class="icon-button-top-left">⚙️</button>
        <button id="report-problem-btn" title="Report a Problem" class="icon-button-top-left">🐛</button> <!-- Bug icon: 🐛 -->
        <div id="settings-panel">
          <h3>Settings</h3>
          <div class="settings-group">
            <div class="settings-item">
              <input type="checkbox" id="uuid-spoofer-toggle" style="vertical-align: middle;">
              <label for="uuid-spoofer-toggle" style="vertical-align: middle;">Enable UUID Spoofing</label>
              <div id="uuid-spoofing-warning" class="hidden" style="margin-top: 5px; padding: 6px; background-color: rgba(255, 217, 0, 0.1); border-left: 3px solid rgba(255, 176, 0, 0.6); border-radius: 4px; font-size: 11px; line-height: 1.4;">
                ⚠️ Warning: UUID spoofing will not work with accounts that have 2FA enabled.
              </div>
            </div>
            <div class="settings-item">
              <label for="server-swap-select" style="vertical-align: middle; margin-right: 8px;">Server Swap:</label>
              <select id="server-swap-select" style="vertical-align: middle; padding: 2px 4px; border-radius: 4px; border: 1px solid var(--theme-settings-border); background-color: white; color: #333; font-family: CCDigitalDelivery; font-size: 11px;">
                <option value="">Default (US)</option>
                <option value="en">English (US)</option>
                <option value="fr">French</option>
                <option value="de">German</option>
                <option value="es">Spanish</option>
                <option value="pt">Portuguese</option>
              </select>
            </div>
          </div>
          <div class="settings-group">
            <h4 style="font-family: CCDigitalDelivery; color: #6E4B37; font-size: 13px; margin-top: 10px; margin-bottom: 5px; text-align: left;">Shortcuts</h4>
            <div class="settings-item" style="font-size: 11px;">Cmd/Ctrl + Shift + I: Toggle Developer Tools</div>
            <div class="settings-item" style="font-size: 11px;">Cmd/Ctrl + R: Reload</div>
            <div class="settings-item" style="font-size: 11px;">Alt + Enter / F11 (Win): Toggle Fullscreen</div>
            <div class="settings-item" style="font-size: 11px;">Ctrl+Cmd+F (Mac): Toggle Fullscreen</div>
            <div class="settings-item" style="font-size: 11px;">Ctrl + Q / Alt + F4 (Win): Quit Application</div>
            <div class="settings-item" style="font-size: 11px;">Cmd + Q (Mac): Quit Application</div>
          </div>
        </div>

        <div id="version">
          <a id="version-link">0.0.0</a>
          <ajd-progress-ring id="version-status-icon" stroke-color="#64cc4d" stroke-width="3" radius="11"></ajd-progress-ring>
        </div>
      `;

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

      // --- Fruit Rotation & Theming Setup (CLASS LEVEL) ---
      this._fruitThemes = {
        'strawberry.png': { primary: '#e83d52', secondary: 'rgba(232, 61, 82, 0.3)', highlight: 'rgba(255, 220, 220, 0.3)', shadow: 'rgba(252, 93, 93, 0.1)', gradientStart: 'rgba(255, 220, 220, 0.3)', gradientEnd: 'rgba(255, 245, 230, 0.6)', hoverBorder: 'rgba(232, 61, 82, 0.5)', radial1: 'rgba(255, 180, 180, 0.05)', radial2: 'rgba(255, 200, 200, 0.07)', settingsHover: 'rgba(232, 61, 82, 0.05)', settingsBorder: 'rgba(232, 61, 82, 0.2)' },
        'banana.png': { primary: '#FFDA03', secondary: 'rgba(255, 218, 3, 0.3)', highlight: 'rgba(255, 248, 220, 0.3)', shadow: 'rgba(255, 218, 3, 0.1)', gradientStart: 'rgba(255, 248, 220, 0.3)', gradientEnd: 'rgba(255, 250, 235, 0.6)', hoverBorder: 'rgba(255, 218, 3, 0.5)', radial1: 'rgba(255, 230, 100, 0.05)', radial2: 'rgba(255, 240, 150, 0.07)', settingsHover: 'rgba(255, 218, 3, 0.05)', settingsBorder: 'rgba(255, 218, 3, 0.2)' },
        'blueberries.png': { primary: '#4682B4', secondary: 'rgba(70, 130, 180, 0.3)', highlight: 'rgba(173, 216, 230, 0.3)', shadow: 'rgba(70, 130, 180, 0.1)', gradientStart: 'rgba(173, 216, 230, 0.3)', gradientEnd: 'rgba(220, 235, 245, 0.6)', hoverBorder: 'rgba(70, 130, 180, 0.5)', radial1: 'rgba(100, 150, 200, 0.05)', radial2: 'rgba(120, 170, 220, 0.07)', settingsHover: 'rgba(70, 130, 180, 0.05)', settingsBorder: 'rgba(70, 130, 180, 0.2)' },
        'cantaloupe.png': { primary: '#FFA07A', secondary: 'rgba(255, 160, 122, 0.3)', highlight: 'rgba(255, 228, 196, 0.3)', shadow: 'rgba(255, 160, 122, 0.1)', gradientStart: 'rgba(255, 228, 196, 0.3)', gradientEnd: 'rgba(255, 245, 230, 0.6)', hoverBorder: 'rgba(255, 160, 122, 0.5)', radial1: 'rgba(255, 180, 150, 0.05)', radial2: 'rgba(255, 200, 170, 0.07)', settingsHover: 'rgba(255, 160, 122, 0.05)', settingsBorder: 'rgba(255, 160, 122, 0.2)' },
        'coconut.png': { primary: '#A0522D', secondary: 'rgba(160, 82, 45, 0.3)', highlight: 'rgba(210, 180, 140, 0.3)', shadow: 'rgba(160, 82, 45, 0.1)', gradientStart: 'rgba(210, 180, 140, 0.3)', gradientEnd: 'rgba(245, 222, 179, 0.6)', hoverBorder: 'rgba(160, 82, 45, 0.5)', radial1: 'rgba(180, 120, 80, 0.05)', radial2: 'rgba(200, 140, 100, 0.07)', settingsHover: 'rgba(160, 82, 45, 0.05)', settingsBorder: 'rgba(160, 82, 45, 0.2)' },
        'pineapple.png': { primary: '#FFEC8B', secondary: 'rgba(255, 236, 139, 0.3)', highlight: 'rgba(255, 250, 205, 0.3)', shadow: 'rgba(255, 236, 139, 0.1)', gradientStart: 'rgba(255, 250, 205, 0.3)', gradientEnd: 'rgba(255, 255, 224, 0.6)', hoverBorder: 'rgba(255, 236, 139, 0.5)', radial1: 'rgba(255, 240, 160, 0.05)', radial2: 'rgba(255, 245, 180, 0.07)', settingsHover: 'rgba(255, 236, 139, 0.05)', settingsBorder: 'rgba(255, 236, 139, 0.2)' },
      };
      this._fruitImages = Object.keys(this._fruitThemes);
      
      // Determine initial _currentFruitIndex based on loginAppIconElem.src
      // This ensures _currentFruitIndex is set before initializeSettings might try to use it via applyTheme
      if (this.loginAppIconElem) {
        this._currentFruitIndex = this._fruitImages.findIndex(src => this.loginAppIconElem.src.endsWith(src));
        if (this._currentFruitIndex === -1) {
            this._currentFruitIndex = this._fruitImages.indexOf('strawberry.png'); // Default to strawberry
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
          console.log(`[LoginScreen] Fruit icon clicked. New _currentFruitIndex: ${this._currentFruitIndex}, nextFruitKey: '${nextFruitKey}'`);
          
          this.loginAppIconElem.src = `images/${nextFruitKey}`;
          console.log(`[LoginScreen] Fruit icon click: Calling applyTheme with '${nextFruitKey}'`);
          this.applyTheme(nextFruitKey);

          if (window.ipc) {
            console.log('[LoginScreen] Saving fruit theme preference via IPC:', nextFruitKey);
            window.ipc.invoke('set-setting', 'fruitTheme', nextFruitKey)
              .catch(err => console.warn('[LoginScreen] Error saving fruit theme preference:', err));
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
            console.log('[Settings] Country override set to:', country || 'none');
          }
          if (this.localeOverrideInput) {
            const locale = this.localeOverrideInput.value.trim();
            await window.ipc.invoke('set-setting', 'debug.locale', locale);
            console.log('[Settings] Locale override set to:', locale || 'none');
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
          console.log(`[Settings] Server Swap set to: ${locale || 'Default'}`);
          if (globals && globals.setLanguage && locale) {
            globals.setLanguage(locale);
          }
          window.alert(`Server swap set to ${locale || 'Default'}. Changes will apply on next login.`);
          if (this.settingsPanel) {
            this.settingsPanel.classList.remove('show');
          }
        });
      }

      // --- REMOVED DUPLICATE/SCOPED FRUIT ROTATION & THEMING LOGIC ---
      // The block that was here defining local fruitThemes, fruitImages, applyTheme, etc.
      // and adding a second event listener has been removed.

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
        if (this.loginBlocked) return;
        this.loginBlocked = true;
        try {
          const flashVars = await globals.getFlashVarsFromWeb();
          Object.assign(
            flashVars,
            globals.getClientData(),
            { locale: globals.language, webRefPath: "create_account" },
            globals.affiliateCode ? { affiliate_code: globals.affiliateCode } : {}
          );
          this.dispatchEvent(new CustomEvent("loggedIn", {detail: {flashVars}}));
        } catch (err) {
          globals.reportError("webClient", `Error creating account: ${err.stack || err.message}`);
          if (err.name != "Aborted") window.alert("Something went wrong :(");
          this.loginBlocked = false;
        }
      });
      this.logInButtonElem.addEventListener("click", () => {
          globals.currentAbortController = new AbortController();
          console.log('[LoginScreen] Created AbortController for login attempt.');
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
        if (state === "fullScreen" && globals.systemData.platform === "win32") {
          buttonTray.classList.remove("hidden");
        } else {
          buttonTray.classList.add("hidden");
        }
      });

      // --- Settings Initialization ---
      this.settingsBtn.addEventListener('click', (event) => {
        event.stopPropagation(); // Prevent click from immediately closing panel via document listener
        this.settingsPanel.classList.toggle('show');
        // console.log('Settings button clicked, panel classList:', this.settingsPanel.classList);
      });

      if (this.reportProblemBtn) {
        this.reportProblemBtn.addEventListener('click', () => { // Reverted from async
          // console.log('[LoginScreen] Report Problem button clicked.');
          
          const logsToReport = [..._winappConsoleLogs];
          
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
              
              fsOps.writeFileSync(filePath, logContent, 'utf8');
              console.log(`[LoginScreen] Successfully saved logs to Desktop: ${filePath}`);
              alert(`Logs saved to your Desktop: ${filename}`);

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
                console.log('[Settings] UUID spoofing canceled by user or failed:', result?.message);
                return;
              }
              this.uuidSpoofingWarning.classList.add('show');
              console.log('[Settings] UUID spoofing set to:', this.uuidSpooferToggle.checked);
            } catch (err) {
              console.error('[Settings] Error toggling UUID spoofing:', err);
              this.uuidSpooferToggle.checked = false;
              return;
            }
          } else {
            await window.ipc.invoke('toggle-uuid-spoofing', false);
            this.uuidSpoofingWarning.classList.remove('show');
            console.log('[Settings] UUID spoofing set to:', this.uuidSpooferToggle.checked);
            globals.df = null;
            console.log('[Settings] Cleared cached DF value to force refresh on next login');
          }
        });
      }
      
      if (this.serverSwapSelect) {
        this.serverSwapSelect.addEventListener('change', (e) => {
          const newLanguage = e.target.value;
          window.ipc.invoke('set-setting', 'login.language', newLanguage);
          console.log(`[Settings] Language changed to: ${newLanguage}`);
          if (globals && globals.setLanguage) {
            globals.setLanguage(newLanguage);
          }
        });
      }

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
      console.log(`[LoginScreen] applyTheme: Called with fruitKey: '${fruitKey}'`);
      const theme = this._fruitThemes[fruitKey]; // Uses class _fruitThemes
      if (!theme) {
        console.warn(`[LoginScreen] applyTheme: No theme found for fruitKey: '${fruitKey}'`);
        return;
      }
      const root = this.shadowRoot.host; 
      
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
        console.log(`[LoginScreen] applyTheme: Calling accountPanelInstance.updateTheme with fruitKey: '${fruitKey}'`);
        this.accountPanelInstance.updateTheme(fruitKey);
      } else {
        console.warn(`[LoginScreen] applyTheme: accountPanelInstance not found or updateTheme is not a function when trying to update with fruitKey: '${fruitKey}'`);
      }
    }

    _initializeAsyncSettings() {
      console.log('[LoginScreen] Running async settings initialization');
      
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
          console.warn("Error getting uuidSpoofingEnabled setting:", err);
        });
        
      window.ipc.invoke('get-setting', 'debug.locale')
        .then(locale => {
          if (this.serverSwapSelect) {
            this.serverSwapSelect.value = locale || '';
            console.log('[LoginScreen] Server swap set to:', locale || 'Default');
          }
        })
        .catch(err => {
          console.warn("Error getting server swap setting:", err);
        });
    }    initializeSettings() {
      console.log('[LoginScreen] Initializing settings...');
      
      window.ipc.invoke('get-setting', 'fruitTheme')
        .then(savedFruitTheme => {
          console.log(`[LoginScreen] initializeSettings: Loaded savedFruitTheme: '${savedFruitTheme}'`);
          
          // Handle different path formats - extract just the filename
          let fruitFilename = savedFruitTheme;
          if (savedFruitTheme && savedFruitTheme.includes('/')) {
            fruitFilename = savedFruitTheme.split('/').pop();
          }
          
          if (fruitFilename && this._fruitImages.includes(fruitFilename)) {
            if (this.loginAppIconElem) {
              this.loginAppIconElem.src = `images/${fruitFilename}`;
              this._currentFruitIndex = this._fruitImages.indexOf(fruitFilename);
              console.log(`[LoginScreen] initializeSettings: Applying saved theme: '${fruitFilename}' (currentFruitIndex: ${this._currentFruitIndex})`);
              this.applyTheme(fruitFilename);
            }
          } else {
            console.log(`[LoginScreen] initializeSettings: No valid saved theme or theme not in _fruitImages. Defaulting to 'strawberry.png'. Saved was: '${savedFruitTheme}'`);
            this.applyTheme('strawberry.png');
          }
        })
        .catch(err => {
          console.warn('[LoginScreen] initializeSettings: Error getting fruitTheme setting, defaulting to strawberry:', err);
          this.applyTheme('strawberry.png');
        });
      
      window.ipc.invoke('get-setting', 'uuid_spoofer_enabled')
        .then(uuidSpoofingEnabled => {
          console.log('[LoginScreen] UUID spoofing enabled:', uuidSpoofingEnabled);
          if (this.uuidSpooferToggle) {
            this.uuidSpooferToggle.checked = uuidSpoofingEnabled;
            if (uuidSpoofingEnabled && this.uuidSpoofingWarning) {
              this.uuidSpoofingWarning.classList.add('show');
            }
          }
        })
        .catch(err => {
          console.warn('[LoginScreen] Error getting uuidSpoofingEnabled setting:', err);
        });

      window.ipc.invoke('get-setting', 'debug.locale')
        .then(locale => {
          console.log('[LoginScreen] Server swap setting:', locale || 'Default');
          if (this.serverSwapSelect) {
            this.serverSwapSelect.value = locale || '';
          }
        })
        .catch(err => {
          console.warn('[LoginScreen] Error initializing server swap setting:', err);
        });
    }

    async logIn() {
      if (this.loginBlocked) return;
      this.loginBlocked = true;
      this.logInButtonElem.disabled = true;
      this.logInButtonElem.classList.add("loading");
      
      try {
        if (globals.df === null) {
          console.log('[LoginScreen] No valid DF found, requesting fresh one before login');
          try {
            const freshDf = await window.ipc.getDf();
            if (freshDf) {
              globals.df = freshDf;
              console.log(`[LoginScreen] Retrieved fresh DF: ${freshDf.substr(0, 8)}...`);
            } else {
              console.warn('[LoginScreen] Failed to get fresh DF, login may fail');
            }
          } catch (dfErr) {
            console.error('[LoginScreen] Error getting fresh DF:', dfErr);
          }
        }
        
        if (this.uuidSpooferToggle && this.uuidSpooferToggle.checked) {
          console.log('[LoginScreen] UUID spoofing enabled, refreshing DF before login');
          try {
            const newUuid = await window.ipc.refreshDf();
            if (newUuid) {
              console.log(`[LoginScreen] Successfully refreshed DF. New UUID: ${newUuid.substr(0, 8)}...`);
              globals.df = newUuid;
              console.log(`[LoginScreen] Updated globals.df with new UUID: ${globals.df.substr(0, 8)}...`);
            } else {
              console.warn('[LoginScreen] Failed to refresh DF - no new UUID returned');
            }
          } catch (dfErr) {
            console.error('[LoginScreen] Error refreshing DF:', dfErr);
          }
        }
        
        let authResult;
        if (this.authToken) {
          try {
            authResult = await globals.authenticateWithAuthToken(this.authToken);
          } catch (err) {
            if (err.message === "Missing authentication methods in globals") {
              console.error("[LoginScreen] Authentication methods not available, trying to recover");
              const freshDf = await window.ipc.getDf();
              if (freshDf) {
                globals.df = freshDf;
                console.log(`[LoginScreen] Retrieved fresh DF for recovery: ${freshDf.substr(0, 8)}...`);
                authResult = await globals.authenticateWithAuthToken(this.authToken);
              } else {
                throw err; 
              }
            } else {
              throw err;
            }
          }
        } else if (this.refreshToken) {
          authResult = await globals.authenticateWithRefreshToken(this.refreshToken, this.otp);
        } else {
          if (!this.username.length) throw new Error("EMPTY_USERNAME");
          if (!this.password.length) throw new Error("EMPTY_PASSWORD");
          authResult = await globals.authenticateWithPassword(this.username, this.password, this.otp, null); 
        }
        
        this.otp = null;
        const {userData, flashVars} = authResult;
        let selectedLanguage = 'en'; 
        try {
          const langSettingResult = await window.ipc.invoke('get-setting', 'login.language');
          if (langSettingResult) {
            selectedLanguage = langSettingResult;
          }
        } catch (langErr) {
          console.warn("[LoginScreen] Error getting language setting:", langErr);
        }

        const data = {
          username: userData.username,
          authToken: userData.authToken,
          refreshToken: userData.refreshToken,
          accountType: userData.accountType,
          language: selectedLanguage, 
          rememberMe: this.rememberMeElem.value,
        };
        if (userData.authToken) this.authToken = userData.authToken;
        if (userData.refreshToken) this.refreshToken = userData.refreshToken;
        console.log('[LoginScreen] Login successful, sending loginSucceeded IPC with data:', data); 
        window.ipc.send("loginSucceeded", data);
        this.dispatchEvent(new CustomEvent("loggedIn", {detail: {flashVars}}));
      } catch (err) {
        if (err.message) {
          switch (err.message) {
            case "SUSPENDED": this.usernameInputElem.error = await globals.translate("userSuspended"); break;
            case "BANNED": this.usernameInputElem.error = await globals.translate("userBanned"); break;
            case "LOGIN_ERROR": this.usernameInputElem.error = await globals.translate("loginError"); break;
            case "WRONG_CREDENTIALS": this.passwordInputElem.error = await globals.translate("wrongCredentials"); break;
            case "EMPTY_USERNAME": this.usernameInputElem.error = await globals.translate("usernameRequired"); break;
            case "EMPTY_PASSWORD": this.passwordInputElem.error = await globals.translate("emptyPassword"); break;
            case "USER_RENAME_NEEDED": /* handled by modal */ break;
            case "OTP_NEEDED": /* handled by modal */ break;
            case "RATE_LIMITED": this.passwordInputElem.error = "Rate limited. Try again later."; break; 
            case "AUTH_TOKEN_EXPIRED":
              this.clearAuthToken();
              if (this.canRetry()) setTimeout(() => this.logIn(true), 1000);
              else { this.isFakePassword = false; this.password = ""; }
              break;
            case "REFRESH_TOKEN_EXPIRED":
              this.clearRefreshToken();
              if (this.canRetry()) setTimeout(() => this.logIn(true), 1000);
              else { this.isFakePassword = false; this.password = ""; }
              break;
            default:
              globals.reportError("webClient", `Error logging in: ${err.stack || err.message}`);
              if (err.name != "Aborted") window.alert("Something went wrong :(");
              break;
          }
        } else {
          globals.reportError("webClient", `Error logging in: ${err}`);
          if (err.name != "Aborted") window.alert("Something went wrong :(");
        }
        if (err?.message !== "OTP_NEEDED") {
             this.loginBlocked = false;
             this.logInButtonElem.classList.remove("loading");
        }
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
          console.log('[LoginScreen] Clearing AbortController in loginBlocked setter.');
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
      this.playerLoginTextElem.innerText = await globals.translate("playerLogin");
      this.playerLoginTextElem.style.fontSize = `${Math.min(646 / this.playerLoginTextElem.innerText.length, 36)}px`;
    }

    async connectedCallback() {
      console.log('[LoginScreen] connectedCallback: Starting.');
      await this.localize();
      console.log('[LoginScreen] connectedCallback: Localization complete.');
      
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
            console.log(`[LoginScreen] Account selected from panel: ${e.detail.username}. Password field populated. Tokens cleared. "Remember Me" state preserved.`);
          }
        });

        this.accountPanelInstance.addEventListener('request-credentials-for-add', async () => {
          console.log('[LoginScreen] Panel requested credentials for add.');
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
    }

  });
})();
