(() => {
  const TEMPLATE = `

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

          #glockoma-credit {
            position: absolute;
            bottom: 10px;
            left: 50%;
            transform: translateX(-50%);
            font-family: CCDigitalDelivery;
            font-size: 12px;
            color: #6E4B37;
          }

          #glockoma-credit a {
            color: var(--theme-primary);
            text-decoration: none;
            font-weight: bold;
          }

          #glockoma-credit a:hover {
            text-decoration: underline;
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
        <div id="glockoma-credit">
          Made with 🤎 by <a href="https://github.com/glvckoma" target="_blank">Glockoma</a>
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
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Shift + W: WASD movement mode</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Shift + D: Den on Login</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Shift + Equals / Numpad Add: Zoom In</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Shift + Minus / Numpad Subtract: Zoom Out</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Shift + Enter: Private message system</div>
            <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Shift + U: Private message Toggle</div>
            <div class="settings-item" style="font-size: 10px; padding: 4px 8px; margin-top: -6px; background-color: rgba(0,0,0,0.4); border-radius: 4px; color: white; display: inline-block; margin-left: 10px;">Credits to&nbsp;<span style="color:purple; font-weight:bold;">Doc</span>&nbsp;and&nbsp;<span style="color:pink; font-weight:bold;"></span></div>

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
  window.LoginScreenTemplate = () => TEMPLATE;
})();
