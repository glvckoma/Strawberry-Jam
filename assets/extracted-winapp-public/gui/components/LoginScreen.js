"use strict";

// are now called directly in the constructor. They are expected to be globally available

(() => {
  let forgotBlocked = false;
  const _winappConsoleLogs = []; // Array to store captured logs
  // _mainLogPath is no longer used for this component's report button.

  // --- [Start] Strawberry Jam Log Sanitization ---
  const sanitizeLogMessage = (message) => {
    let sanitized = message;
    
    // General regex for sensitive keys in JSON-like strings
    const sensitiveJsonKeys = ['authToken', 'refreshToken', 'df', 'username', 'password', 'auth_token', 'gameSessionIdStr'];
    sensitiveJsonKeys.forEach(key => {
      // This regex looks for "key":"value" or key: 'value' and redacts the value.
      const regex = new RegExp(`(["']?${key}["']?\\s*:\\s*["'])([^"']*)(["'])`, 'gi');
      sanitized = sanitized.replace(regex, `$1[REDACTED]$3`);
    });

    // Regex for specific patterns that might not be in JSON
    // Example: "Retrieved plaintext password for someuser from..."
    const passwordWarningRegex = /(Retrieved plaintext password for )([^ ]+)( from)/gi;
    sanitized = sanitized.replace(passwordWarningRegex, '$1[REDACTED]$3');

    // Redact long JWT-like strings
    const tokenRegex = /([a-zA-Z0-9-_]+\.[a-zA-Z0-9-_]+\.[a-zA-Z0-9-_]{20,})/g;
    sanitized = sanitized.replace(tokenRegex, '[REDACTED_TOKEN]');

    // Redact 64-character hex strings (like df)
    const dfRegex = /[a-f0-9]{64}/gi;
    sanitized = sanitized.replace(dfRegex, '[REDACTED_DF]');

    return sanitized;
  };
  // --- [End] Strawberry Jam Log Sanitization ---

  // Simplified console capture - only capture without overriding console methods
  const captureLog = (level, ...args) => {
    const timestamp = new Date().toISOString();
    const message = args.map(arg => typeof arg === 'object' ? JSON.stringify(arg) : String(arg)).join(' ');
    const sanitizedMessage = sanitizeLogMessage(message);
    _winappConsoleLogs.push({ timestamp, level, message: sanitizedMessage });
    if (_winappConsoleLogs.length > 500) {
      _winappConsoleLogs.splice(0, _winappConsoleLogs.length - 400);
    }
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
            --theme-box-background-dark: rgba(45, 45, 45, 0.95); /* Dark mode box background */
            --theme-button-bg: var(--theme-primary); /* Default button background */
            --theme-button-border: var(--theme-secondary); /* Default button border */
            --theme-button-text: #FFFFFF; /* Default button text */
            --dark-mode: 0; /* Dark mode flag: 0 = light, 1 = dark */
            
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
          .button-container-bottom-left {
            position: absolute;
            bottom: 10px; /* Reduced bottom padding */
            left: 10px;
            display: flex;
            flex-direction: column;
            gap: 10px; /* Space between buttons */
            z-index: 1000;
            pointer-events: none; /* Allow clicks to pass through container */
          }

          .icon-button { /* Common style for icon buttons */
            width: 32px;
            height: 32px;
            font-size: 18px;
            border: 2px solid var(--theme-primary, #e83d52);
            border-radius: 8px;
            background-color: var(--theme-box-background);
            cursor: pointer;
            opacity: 0.8;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            pointer-events: auto; /* Re-enable pointer events only for the button itself */
            /* Ensure the button doesn't extend beyond its visual bounds */
            box-sizing: border-box;
            overflow: hidden;
            /* Remove any potential margin/padding that could extend hover area */
            margin: 0;
            padding: 0;
            /* Ensure proper cursor behavior - only show pointer when directly over button */
            cursor: pointer !important;
            /* Limit interaction area to exact button size */
            position: relative;
            flex-shrink: 0;
          }

          .icon-button:hover {
            opacity: 1;
            border-color: var(--theme-hover-border);
            transform: scale(1.05);
            /* Ensure hover effects don't extend beyond button boundaries */
            transform-origin: center;
          }

          #report-problem-btn {
            font-size: 16px; /* Slightly smaller for bug icon if needed */
          }

          /* Ensure precise hover boundaries for both buttons */
          #settings-btn, #report-problem-btn {
            /* Strict containment of hover area */
            contain: layout style;
            /* Prevent any accidental hover area extension */
            outline: none;
            /* Ensure the button interaction area matches visual size exactly */
            min-width: 32px;
            max-width: 32px;
            min-height: 32px;
            max-height: 32px;
            /* Remove any inherited styles that might extend hover area */
            line-height: 1;
            vertical-align: baseline;
            /* Ensure cursor only changes when directly over the button */
            cursor: pointer;
            /* Create a strict boundary for pointer events */
            clip-path: inset(0);
          }

          /* Ensure no cursor interference outside button bounds */
          .button-container-bottom-left::before {
            content: '';
            position: absolute;
            top: -10px;
            left: -10px;
            right: -10px;
            bottom: -10px;
            pointer-events: none;
            cursor: default;
            z-index: -1;
          }

          /* Additional safeguards to prevent cursor interference */
          .icon-button:not(:hover) {
            cursor: default;
          }
          
          .icon-button:hover {
            cursor: pointer;
          }

          /* Ensure the game area maintains proper cursor behavior */
          body:not(.login-screen) .button-container-bottom-left {
            pointer-events: none !important;
          }
          
          body:not(.login-screen) .icon-button {
            pointer-events: none !important;
          }
          
          #settings-panel {
            position: absolute;
            bottom: 52px; /* Adjusted for new button position (10px + 32px button + 10px gap) */
            left: 10px;
            width: 250px;
            background-color: var(--theme-box-background);
            border: 2px solid var(--theme-secondary);
            border-radius: 12px;
            padding: 15px;
            /* display: none; */ /* Handled by animation */
            z-index: 999; /* Below buttons */
            box-shadow: 0 8px 32px var(--theme-shadow);
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
            /* Prevent content from extending beyond panel boundaries */
            box-sizing: border-box;
            overflow: hidden;
            /* Ensure pointer events are contained within panel */
            contain: layout style;
          }

          /* Auto Wheel and Import components positioning */
          #auto-wheel-section {
            position: absolute;
            bottom: 10px;
            right: 10px;
            width: 300px;
            z-index: 1000;
            display: none; /* Hidden by default */
          }

          #import-section {
            position: absolute;
            top: 10px;
            right: 10px;
            z-index: 1000;
            display: none; /* Hidden by default */
          }

          #auto-wheel-section.visible {
            display: block;
          }

          #import-section.visible {
            display: block;
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
            /* Prevent text overflow beyond panel */
            box-sizing: border-box;
            overflow: hidden;
            word-wrap: break-word;
            max-width: 100%;
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
            /* Prevent content from extending beyond panel boundaries */
            box-sizing: border-box;
            overflow: hidden;
            word-wrap: break-word;
            max-width: 100%;
            flex-wrap: wrap;
          }
          
          .settings-item:hover {
            background-color: var(--theme-settings-hover);
          }
          
          .settings-item input[type="checkbox"] {
            margin-right: 8px;
          }

          /* Ensure all settings panel content is properly contained */
          #settings-panel * {
            box-sizing: border-box;
            max-width: 100%;
          }

          #settings-panel h4, #settings-panel h5 {
            overflow: hidden;
            word-wrap: break-word;
            max-width: 100%;
          }

          #settings-panel label, #settings-panel select {
            overflow: hidden;
            word-wrap: break-word;
            max-width: 100%;
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

          :host(.dark-mode) #box-background {
            background-color: var(--theme-box-background-dark);
          }

          :host(.dark-mode) #settings-panel {
            background-color: var(--theme-box-background-dark);
            box-shadow: 0 8px 32px rgba(0,0,0,0.4);
          }

          :host(.dark-mode) .icon-button {
            background-color: var(--theme-box-background-dark);
            border-color: rgba(255, 255, 255, 0.3);
          }

          :host(.dark-mode) .icon-button:hover {
            border-color: rgba(255, 255, 255, 0.5);
          }

          :host(.dark-mode) .settings-item {
            color: #E0E0E0;
          }

          :host(.dark-mode) #settings-panel h3 {
            color: #E0E0E0;
          }

          :host(.dark-mode) #settings-panel h4 {
            color: #E0E0E0;
          }

          :host(.dark-mode) .settings-item div {
            color: #B0B0B0 !important;
          }

          @media (max-width: 950px), (max-height: 590px) {
            #box-background {
              z-index: -1;
              opacity: 0;
            }

            :host {
              background-color: rgba(30, 27, 28, 0.14); /* Keep neutral */
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
            border-radius: 20px;
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
            left: 52px; /* Moved to the right to avoid button overlap */
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
            color: var(--theme-primary, #684A26);
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
            border: 2px solid var(--theme-primary, #e83d52);
            border-radius: 8px;
            transition: border-color 0.3s ease;
          }

          #button-tray ajd-button:hover {
            border-color: var(--theme-hover-border, #e83d52);
          }

          /* Account Management Panel Styling MOVED to AccountManagementPanel.css */
          /* Context Menu Styling MOVED to AccountManagementPanel.css */

          /* Settings Panel Animation */
          @keyframes slideUp {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
          }
          
          #settings-panel {
            max-height: 0;
            overflow: hidden;
            opacity: 0;
            padding: 15px; /* Keep padding defined here, will be hidden by max-height: 0 */
            transition: max-height 0.3s cubic-bezier(0.34, 1.56, 0.64, 1), 
                        opacity 0.3s ease; /* Removed padding from transition */
            transform-origin: bottom left;
            /* width: 250px; is already defined above, ensure it's not overridden */
            overflow-y: auto; /* Enable vertical scrolling */
            padding-right: 5px; /* Add some space for the scrollbar */
            /* Prevent any cursor interference when panel is hidden */
            pointer-events: none;
          }

          /* Custom Scrollbar Styles */
          #settings-panel::-webkit-scrollbar {
            width: 8px;
          }

          #settings-panel::-webkit-scrollbar-track {
            background: rgba(0, 0, 0, 0.1); /* A subtle track background */
            border-radius: 10px;
          }

          #settings-panel::-webkit-scrollbar-thumb {
            background-color: var(--theme-primary); /* Use the primary theme color */
            border-radius: 10px;
          }

          #settings-panel::-webkit-scrollbar-thumb:hover {
            background-color: var(--theme-hover-border); /* Use the theme's hover color */
          }
          
          #settings-panel.show {
            max-height: 500px; /* Adjust as needed to fit content */
            opacity: 1;
            animation: slideUp 0.3s ease forwards;
            /* Re-enable pointer events when panel is shown */
            pointer-events: auto;
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
        <div class="button-container-bottom-left">
          <button id="settings-btn" title="Settings" class="icon-button">⚙️</button>
          <button id="report-problem-btn" title="Report a Problem" class="icon-button">🐛</button>
        </div>
        <div id="settings-panel">
          <h3>Settings</h3>
          <div class="settings-group">
            <h4 style="font-family: CCDigitalDelivery; color: #6E4B37; font-size: 13px; margin-top: 0; margin-bottom: 5px; text-align: left;">General</h4>
            <div class="settings-item">
              <input type="checkbox" id="uuid-spoofer-toggle" style="vertical-align: middle;">
              <label for="uuid-spoofer-toggle" style="vertical-align: middle;">Enable UUID Spoofing</label>
              <div id="uuid-spoofing-warning" class="hidden" style="margin-top: 5px; padding: 6px; background-color: rgba(255, 217, 0, 0.1); border-left: 3px solid rgba(255, 176, 0, 0.6); border-radius: 4px; font-size: 11px; line-height: 1.4;">
                ⚠️ Warning: UUID spoofing will not work with accounts that have 2FA enabled.
              </div>
            </div>
            <div class="settings-item">
              <input type="checkbox" id="background-processing-toggle" style="vertical-align: middle;">
              <label for="background-processing-toggle" style="vertical-align: middle;">Enable background processing</label>
              <div style="margin-top: 2px; padding: 4px; font-size: 10px; line-height: 1.3; color: #6E4B37; font-style: italic;">
                💡 Allows plugins to continue running when the game window is minimized.
              </div>
            </div>
            <div class="settings-item">
              <input type="checkbox" id="dark-mode-toggle" style="vertical-align: middle;">
              <label for="dark-mode-toggle" style="vertical-align: middle;">Dark Mode</label>
              <div style="margin-top: 2px; padding: 4px; font-size: 10px; line-height: 1.3; color: #6E4B37; font-style: italic;">
                🌙 Switches background colors to a darker theme for better nighttime viewing.
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
            <h4 style="font-family: CCDigitalDelivery; color: #6E4B37; font-size: 13px; margin-top: 10px; margin-bottom: 5px; text-align: left;">UI Components</h4>
            <div class="settings-item">
              <input type="checkbox" id="show-import-accounts-toggle" style="vertical-align: middle;">
              <label for="show-import-accounts-toggle" style="vertical-align: middle;">Show Import Accounts</label>
              <div style="margin-top: 2px; padding: 4px; font-size: 10px; line-height: 1.3; color: #6E4B37; font-style: italic;">
                📁 Shows the import button for uploading accounts from .txt files
              </div>
            </div>
            <div class="settings-item">
              <input type="checkbox" id="show-wheel-automation-toggle" style="vertical-align: middle;">
              <label for="show-wheel-automation-toggle" style="vertical-align: middle;">Show Wheel Automation</label>
              <div style="margin-top: 2px; padding: 4px; font-size: 10px; line-height: 1.3; color: #6E4B37; font-style: italic;">
                🎡 Shows the auto wheel component for automated account cycling
              </div>
            </div>
          </div>
          <div class="settings-group">
            <h4 style="font-family: CCDigitalDelivery; color: #6E4B37; font-size: 13px; margin-top: 10px; margin-bottom: 5px; text-align: left;">Shortcuts</h4>
            
            <h5 style="font-family: CCDigitalDelivery; color: #805B47; font-size: 12px; margin-top: 8px; margin-bottom: 4px; font-weight: bold;">General:</h5>
            <div class="settings-item" style="font-size: 10px; padding-left: 10px; color: #8B6914; font-style: italic; margin-bottom: 6px;">ℹ️ Note: Click on the left or right side panels first to focus the window before using shortcuts</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Shift + I: Toggle Developer Tools</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + R: Reload / Logout (Return to Login Screen)</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Shift + H: Toggle Hide UI Elements (Settings/Report Buttons & User Tray)</div>
 
            <h5 style="font-family: CCDigitalDelivery; color: #805B47; font-size: 12px; margin-top: 8px; margin-bottom: 4px; font-weight: bold;">In-Game:</h5>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">F5: Toggle In-Game HUD</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Shift + P: Become a phantom (client side only)</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Shift + C: Clone A Friend</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Shift + T: Teleportation</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Shift + R: Room User Scan</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Shift + M: Trade Marketplace</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Shift + X: Headless mode</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Shift + N: No Clip</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Shift + Equals / Numpad Add: Zoom In</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Shift + Minus / Numpad Subtract: Zoom Out</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Shift + Enter: Private message system</div>
            <div class="settings-item" style="font-size: 10px; padding: 4px 8px; margin-top: -6px; background-color: rgba(0,0,0,0.4); border-radius: 4px; color: white; display: inline-block; margin-left: 10px;">Credits to&nbsp;<span style="color:purple; font-weight:bold;">Doc</span>&nbsp;and&nbsp;<span style="color:pink; font-weight:bold;">Elyxr</span></div>

            <h5 style="font-family: CCDigitalDelivery; color: #805B47; font-size: 12px; margin-top: 8px; margin-bottom: 4px; font-weight: bold;">Windows/Linux:</h5>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Alt + Enter / F11: Toggle Fullscreen</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Q / Alt + F4: Quit Application</div>
 
            <!-- macOS shortcuts removed: application is Windows/Linux only -->
          </div>
        </div>
 
        <div id="version">
          <a id="version-link">0.0.0</a>
          <ajd-progress-ring id="version-status-icon" stroke-color="#64cc4d" stroke-width="3" radius="11"></ajd-progress-ring>
        </div>

        <!-- Import Button Section -->
        <div id="import-section">
          <import-button id="import-button-instance"></import-button>
        </div>

        <!-- Auto Wheel Section -->
        <div id="auto-wheel-section">
          <auto-wheel-button id="auto-wheel-button-instance"></auto-wheel-button>
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
      this.importButtonInstance = this.shadowRoot.getElementById("import-button-instance");
      this.autoWheelButtonInstance = this.shadowRoot.getElementById("auto-wheel-button-instance");
      this.userTray = null;



      // --- Fruit Rotation & Theming Setup (CLASS LEVEL) ---
      this._fruitThemes = {
        'strawberry.png': { primary: '#e83d52', secondary: 'rgba(232, 61, 82, 0.3)', highlight: 'rgba(255, 220, 220, 0.3)', shadow: 'rgba(252, 93, 93, 0.1)', gradientStart: 'rgba(255, 220, 220, 0.3)', gradientEnd: 'rgba(255, 245, 230, 0.6)', hoverBorder: 'rgba(232, 61, 82, 0.5)', radial1: 'rgba(255, 180, 180, 0.05)', radial2: 'rgba(255, 200, 200, 0.07)', settingsHover: 'rgba(232, 61, 82, 0.05)', settingsBorder: 'rgba(232, 61, 82, 0.2)' },
        'banana.png': { primary: '#FFDA03', secondary: 'rgba(255, 218, 3, 0.3)', highlight: 'rgba(255, 248, 220, 0.3)', shadow: 'rgba(255, 218, 3, 0.1)', gradientStart: 'rgba(255, 248, 220, 0.3)', gradientEnd: 'rgba(255, 250, 235, 0.6)', hoverBorder: 'rgba(255, 218, 3, 0.5)', radial1: 'rgba(255, 230, 100, 0.05)', radial2: 'rgba(255, 240, 150, 0.07)', settingsHover: 'rgba(255, 218, 3, 0.05)', settingsBorder: 'rgba(255, 218, 3, 0.2)' },
        'blueberries.png': { primary: '#4682B4', secondary: 'rgba(70, 130, 180, 0.3)', highlight: 'rgba(173, 216, 230, 0.3)', shadow: 'rgba(70, 130, 180, 0.1)', gradientStart: 'rgba(173, 216, 230, 0.3)', gradientEnd: 'rgba(220, 235, 245, 0.6)', hoverBorder: 'rgba(70, 130, 180, 0.5)', radial1: 'rgba(100, 150, 200, 0.05)', radial2: 'rgba(120, 170, 220, 0.07)', settingsHover: 'rgba(70, 130, 180, 0.05)', settingsBorder: 'rgba(70, 130, 180, 0.2)' },
        'cantaloupe.png': { primary: '#FFA07A', secondary: 'rgba(255, 160, 122, 0.3)', highlight: 'rgba(255, 228, 196, 0.3)', shadow: 'rgba(255, 160, 122, 0.1)', gradientStart: 'rgba(255, 228, 196, 0.3)', gradientEnd: 'rgba(255, 245, 230, 0.6)', hoverBorder: 'rgba(255, 160, 122, 0.5)', radial1: 'rgba(255, 180, 150, 0.05)', radial2: 'rgba(255, 200, 170, 0.07)', settingsHover: 'rgba(255, 160, 122, 0.05)', settingsBorder: 'rgba(255, 160, 122, 0.2)' },
        'coconut.png': { primary: '#A0522D', secondary: 'rgba(160, 82, 45, 0.3)', highlight: 'rgba(210, 180, 140, 0.3)', shadow: 'rgba(160, 82, 45, 0.1)', gradientStart: 'rgba(210, 180, 140, 0.3)', gradientEnd: 'rgba(245, 222, 179, 0.6)', hoverBorder: 'rgba(160, 82, 45, 0.5)', radial1: 'rgba(180, 120, 80, 0.05)', radial2: 'rgba(200, 140, 100, 0.07)', settingsHover: 'rgba(160, 82, 45, 0.05)', settingsBorder: 'rgba(160, 82, 45, 0.2)' },
        'dragonfruit.png': { primary: '#E91E63', secondary: 'rgba(233, 30, 99, 0.3)', highlight: 'rgba(248, 187, 208, 0.3)', shadow: 'rgba(233, 30, 99, 0.1)', gradientStart: 'rgba(248, 187, 208, 0.3)', gradientEnd: 'rgba(252, 228, 236, 0.6)', hoverBorder: 'rgba(233, 30, 99, 0.5)', radial1: 'rgba(244, 143, 177, 0.05)', radial2: 'rgba(244, 143, 177, 0.07)', settingsHover: 'rgba(233, 30, 99, 0.05)', settingsBorder: 'rgba(233, 30, 99, 0.2)' },
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
            this.applyTheme('strawberry.png');
          }
        })
        .catch(err => {
          this.applyTheme('strawberry.png');
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
      try {
        const payloadBase64 = token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/');
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

        // 1. Check for a valid, non-expired auth token
        if (this.authToken && !this._isTokenExpired(this.authToken)) {
          console.log("[ANIMAL JAM AUTH] Auth token is valid. Attempting authentication with it.");
          authResult = await globals.authenticateWithAuthToken(this.authToken);
        } 
        // 2. If auth token is expired or missing, try using the refresh token
        else if (this.refreshToken) {
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
            authResult = await globals.authenticateWithRefreshToken(this.refreshToken, this.otp);
            console.log("[ANIMAL JAM AUTH] Successfully refreshed token.");
          } catch (err) {
            if (err.message === "REFRESH_TOKEN_EXPIRED") {
              console.warn("[ANIMAL JAM AUTH] Refresh token has expired (server-side check). Clearing all tokens.");
              this.clearAuthToken();
              this.clearRefreshToken();
              this.isFakePassword = false;
              // Error message is already set in the main catch block, just ensure tokens are cleared.
            }
            // Re-throw to be caught by the main catch block
            throw err;
          }
        }
        // 3. If no tokens are available or valid, fall back to password login
        else {
          console.log("[ANIMAL JAM AUTH] No valid tokens. Proceeding with password authentication.");
          if (!this.username.length) throw new Error("EMPTY_USERNAME");
          if (!this.password.length) throw new Error("EMPTY_PASSWORD");
          authResult = await globals.authenticateWithPassword(this.username, this.password, this.otp, null);
        }

        // If we have a result, proceed to login
        this.otp = null;
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
        if (userData.authToken) this.authToken = userData.authToken;
        if (userData.refreshToken) this.refreshToken = userData.refreshToken;

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
      this.playerLoginTextElem.innerText = await globals.translate("playerLogin");
      this.playerLoginTextElem.style.fontSize = `${Math.min(646 / this.playerLoginTextElem.innerText.length, 36)}px`;
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
