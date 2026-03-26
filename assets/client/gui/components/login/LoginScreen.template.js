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
            /* CRITICAL: Default to dark mode to prevent light mode flash */
            /* Will be switched to light if user preference is light mode */
            --theme-box-background: rgba(45, 45, 45, 0.95); /* Default to dark */
            --theme-box-background-dark: rgba(45, 45, 45, 0.95); /* Dark mode box background */
            --theme-box-background-light: rgba(255, 245, 230, 0.95); /* Light mode box background */
            --theme-button-bg: var(--theme-primary); /* Default button background */
            --theme-button-border: var(--theme-secondary); /* Default button border */
            --theme-button-text: #FFFFFF; /* Default button text */
            --dark-mode: 0; /* Dark mode flag: 0 = light, 1 = dark */

            width: 100%;
            height: 100%;
            display: grid;
            grid-template: 1fr min(590px, 80%) 1fr / 1fr min(70px, 8%) min(936px, 75%) 1fr;
            grid-template-areas: ". . . button-tray"
                                 ". panel box ."
                                 ". . . .";
            background-color: rgba(239, 234, 221, 0);
            transition: background-color 0.2s;

            /* Hide login screen until theme is loaded to prevent FOUC */
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.3s ease-out;
          }

          :host(.theme-ready) {
            /* Show login screen once theme is loaded */
            opacity: 1;
            visibility: visible;
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

          #devtools-btn svg {
            display: block;
            color: #888;
          }
          
          #devtools-btn-wrapper {
            position: relative;
            display: inline-block;
            contain: layout style;
            overflow: visible;
          }

          #devtools-error-badge {
            position: absolute;
            top: -6px;
            right: -6px;
            background-color: #e74c3c;
            color: white;
            border-radius: 50%;
            min-width: 20px;
            height: 20px;
            display: none;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            font-weight: bold;
            line-height: 1;
            padding: 0;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.4);
            pointer-events: none;
            z-index: 1000;
            will-change: transform;
            animation: badge-pulse 2s ease-in-out infinite;
          }

          #devtools-error-badge.show {
            display: flex;
          }

          @keyframes badge-pulse {
            0%, 100% {
              transform: scale(1);
            }
            50% {
              transform: scale(1.1);
            }
          }

          #settings-btn, #devtools-btn {
            contain: layout style;
            outline: none;
            min-width: 32px;
            max-width: 32px;
            min-height: 32px;
            max-height: 32px;
            line-height: 1;
            vertical-align: baseline;
            cursor: pointer;
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
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 12px;
            color: #6E4B37;
            font-family: CCDigitalDelivery;
            padding: 6px 4px;
            transition: background-color 0.2s;
            border-radius: 6px;
            box-sizing: border-box;
            max-width: 100%;
            flex-wrap: wrap;
          }

          .settings-item:hover {
            background-color: var(--theme-settings-hover);
          }

          .settings-toggle {
            width: 38px;
            height: 20px;
            background: #4b5563;
            border-radius: 10px;
            position: relative;
            cursor: pointer;
            transition: background-color 0.2s ease;
            flex-shrink: 0;
          }
          .settings-toggle::after {
            content: '';
            position: absolute;
            width: 16px;
            height: 16px;
            background: white;
            border-radius: 50%;
            top: 2px;
            left: 2px;
            transition: transform 0.2s ease;
            box-shadow: 0 1px 2px rgba(0,0,0,0.3);
          }
          .settings-peer:checked ~ .settings-toggle {
            background-color: var(--theme-primary, #e83d52);
          }
          .settings-peer:checked ~ .settings-toggle::after {
            transform: translateX(18px);
          }
          .sr-only {
            position: absolute;
            width: 1px;
            height: 1px;
            padding: 0;
            margin: -1px;
            overflow: hidden;
            clip: rect(0,0,0,0);
            border: 0;
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
            /* Ensure dark mode background is applied immediately when class is present */
            will-change: background-color;
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


          :host(.dark-mode) #settings-panel h4 {
            color: #E0E0E0;
          }

          :host(.dark-mode) .settings-item div {
            color: #B0B0B0 !important;
          }

          @media (max-width: 950px), (max-height: 590px) {
            #box-background {
              display: none;
            }

            #panel {
              display: none;
            }

            :host {
              display: flex;
              justify-content: center;
              align-items: center;
              overflow: auto;
              background-color: rgba(30, 27, 28, 0.14);
            }

            #box {
              padding: 30px 40px;
              max-width: 500px;
              width: 100%;
              box-sizing: border-box;
              background-color: var(--theme-box-background);
              border-radius: 20px;
              border: 1px solid var(--theme-secondary);
              box-shadow: 0 8px 32px var(--theme-shadow);
            }

            :host(.dark-mode) #box {
              background-color: var(--theme-box-background-dark);
            }
          }

          #box {
            grid-area: box;
            display: flex;
            justify-content: center;
            align-items: center;
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
            grid-template-columns: 1fr;
            justify-items: center;
            position: relative;
          }

          #log-in-btn {
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
            position: absolute;
            left: calc(50% + 60px);
            top: 50%;
            transform: translateY(-50%);
            height: 24px;
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

          .settings-tabs {
            display: flex;
            gap: 4px;
            margin-bottom: 15px;
            border-bottom: 2px solid var(--theme-settings-border);
          }

          .settings-tab {
            flex: 1;
            padding: 8px 12px;
            background-color: transparent;
            border: none;
            border-bottom: 2px solid transparent;
            color: #6E4B37;
            font-family: CCDigitalDelivery;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.2s ease;
            margin-bottom: -2px;
            outline: none !important;
            box-shadow: none !important;
            -webkit-tap-highlight-color: transparent;
            user-select: none;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
          }

          .settings-tab:focus,
          .settings-tab:focus-visible,
          .settings-tab:active,
          .settings-tab:focus-within {
            outline: none !important;
            box-shadow: none !important;
            -webkit-tap-highlight-color: transparent;
          }

          .settings-tab:hover {
            color: var(--theme-primary);
            background-color: var(--theme-settings-hover);
          }

          .settings-tab.active {
            color: var(--theme-primary);
            border-bottom-color: var(--theme-primary);
            font-weight: bold;
          }

          .settings-tab-content {
            display: none;
          }

          .settings-tab-content.active {
            display: block;
          }

          .settings-subsection {
            margin-bottom: 12px;
            padding-bottom: 8px;
            border-bottom: 1px solid rgba(255,255,255,0.06);
          }
          .settings-subsection:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
          }

          .settings-subsection h5 {
            font-family: CCDigitalDelivery;
            color: #9ca3af;
            font-size: 10px;
            margin-top: 0;
            margin-bottom: 6px;
            letter-spacing: 0.05em;
            font-weight: bold;
          }

          .shortcuts-note {
            font-size: 10px;
            padding: 8px;
            color: #8B6914;
            font-style: italic;
            margin-bottom: 12px;
            text-align: center;
            background-color: rgba(255, 217, 0, 0.1);
            border-radius: 4px;
          }

          :host(.dark-mode) .settings-tab {
            color: #E0E0E0;
          }

          :host(.dark-mode) .settings-tab:hover {
            color: var(--theme-primary);
          }

          :host(.dark-mode) .settings-tab.active {
            color: var(--theme-primary);
          }

          :host(.dark-mode) .settings-subsection h5 {
            color: #E0E0E0;
          }

          :host(.dark-mode) .shortcuts-note {
            color: #E0E0E0;
          }

          #login-help-prompt {
            display: none;
            position: fixed;
            bottom: 16px;
            left: 50%;
            transform: translateX(-50%) translateY(20px);
            background: var(--theme-box-background, rgba(45, 45, 45, 0.95));
            border: 2px solid var(--theme-secondary, rgba(232, 61, 82, 0.3));
            border-radius: 16px;
            padding: 14px 20px;
            font-family: CCDigitalDelivery, sans-serif;
            color: #E0E0E0;
            font-size: 14px;
            z-index: 100;
            box-shadow: 0 8px 32px var(--theme-shadow, rgba(252, 93, 93, 0.1));
            opacity: 0;
            transition: opacity 0.3s ease, transform 0.3s ease;
            max-width: 420px;
            text-align: center;
            background-image:
              radial-gradient(circle at 10% 20%, var(--theme-radial-1, rgba(255, 180, 180, 0.05)) 0%, transparent 50%),
              radial-gradient(circle at 90% 80%, var(--theme-radial-2, rgba(255, 200, 200, 0.07)) 0%, transparent 50%);
          }

          :host(:not(.dark-mode)) #login-help-prompt {
            background: var(--theme-box-background-light, rgba(255, 245, 230, 0.95));
            color: #6E4B37;
          }

          :host(.dark-mode) #login-help-prompt {
            background: var(--theme-box-background-dark, rgba(45, 45, 45, 0.95));
          }

          #login-help-prompt.show {
            display: block;
            opacity: 1;
            transform: translateX(-50%) translateY(0);
          }

          #login-help-prompt p {
            margin: 0 0 12px 0;
            line-height: 1.4;
            font-family: Tiki-Island, sans-serif;
            font-size: 16px;
            color: var(--theme-primary, #e83d52);
            text-shadow: 1px 1px 0px var(--theme-shadow, rgba(252, 93, 93, 0.1));
          }

          .help-prompt-buttons {
            display: flex;
            gap: 8px;
            justify-content: center;
          }

          .help-prompt-btn {
            padding: 7px 18px;
            border-radius: 8px;
            border: 2px solid transparent;
            font-family: CCDigitalDelivery, sans-serif;
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
          }

          .help-prompt-btn:active {
            transform: scale(0.96);
          }

          .help-prompt-btn-primary {
            background: var(--theme-primary, #e83d52);
            border-color: var(--theme-secondary, rgba(232, 61, 82, 0.3));
            color: white;
          }

          .help-prompt-btn-primary:hover {
            opacity: 0.9;
            transform: scale(1.02);
          }

          .help-prompt-btn-dismiss {
            background: transparent;
            border-color: var(--theme-secondary, rgba(232, 61, 82, 0.3));
            color: #B0B0B0;
          }

          :host(:not(.dark-mode)) .help-prompt-btn-dismiss {
            color: #6E4B37;
          }

          .help-prompt-btn-dismiss:hover {
            border-color: var(--theme-hover-border, rgba(232, 61, 82, 0.5));
            color: var(--theme-primary, #e83d52);
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
  <img src="images/strawberry.png" alt="App Icon" id="login-app-icon" style="width:90px;display:block;margin-bottom:8px;margin-left:auto;margin-right:auto;" loading="lazy"> <!-- Changed default src -->
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
          Made with 🤎 by <a href="https://github.com/glvckoma" target="_blank">glvckoma</a>
        </div>

        <div class="button-container-bottom-left">
          <button id="settings-btn" title="Settings" class="icon-button">⚙️</button>
          <div id="devtools-btn-wrapper">
            <button id="devtools-btn" title="View Debug Logs" class="icon-button"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z"/><polyline points="14 2 14 8 20 8"/><line x1="8" y1="13" x2="16" y2="13"/><line x1="8" y1="17" x2="16" y2="17"/></svg></button>
            <span id="devtools-error-badge">0</span>
          </div>
        </div>

        <div id="login-help-prompt">
          <p>Having trouble logging in?</p>
          <div class="help-prompt-buttons">
            <button id="help-prompt-view-logs" class="help-prompt-btn help-prompt-btn-primary">View Logs</button>
            <button id="help-prompt-dismiss" class="help-prompt-btn help-prompt-btn-dismiss">Dismiss</button>
          </div>
        </div>
        <div id="settings-panel">
          <h3>Settings</h3>
          <div class="settings-tabs">
            <button class="settings-tab active" data-tab="general">General</button>
            <button class="settings-tab" data-tab="theme">Theme</button>
            <button class="settings-tab" data-tab="shortcuts">Shortcuts</button>
          </div>

          <div class="settings-tab-content active" id="tab-general">
            <div class="settings-subsection">
              <h5>ENHANCEMENTS</h5>
              <div class="settings-item">
                <span>UUID Spoofing</span>
                <label style="display: inline-flex; align-items: center; cursor: pointer; position: relative;">
                  <input type="checkbox" id="uuid-spoofer-toggle" class="sr-only settings-peer">
                  <div class="settings-toggle"></div>
                </label>
              </div>
              <div id="uuid-spoofing-warning" class="hidden" style="margin: -4px 0 8px; padding: 6px; background-color: rgba(255, 217, 0, 0.1); border-left: 3px solid rgba(255, 176, 0, 0.6); border-radius: 4px; font-size: 10px; line-height: 1.3;">
                Will not work with accounts that have 2FA enabled.
              </div>
              <div class="settings-item">
                <span>Background Processing</span>
                <label style="display: inline-flex; align-items: center; cursor: pointer; position: relative;">
                  <input type="checkbox" id="background-processing-toggle" class="sr-only settings-peer">
                  <div class="settings-toggle"></div>
                </label>
              </div>
              <div class="settings-item">
                <span>Mod Menu Button</span>
                <label style="display: inline-flex; align-items: center; cursor: pointer; position: relative;">
                  <input type="checkbox" id="mod-menu-btn-toggle" class="sr-only settings-peer">
                  <div class="settings-toggle"></div>
                </label>
              </div>
              <div class="settings-item">
                <span>Server Swap</span>
                <select id="server-swap-select" style="padding: 3px 6px; border-radius: 4px; border: 1px solid rgba(255,255,255,0.12); background-color: #1e1f2e; color: #C3C3C3; font-family: CCDigitalDelivery; font-size: 11px; color-scheme: dark;">
                  <option value="">Default (US)</option>
                  <option value="en">English (US)</option>
                  <option value="fr">French</option>
                  <option value="de">German</option>
                  <option value="es">Spanish</option>
                  <option value="pt">Portuguese</option>
                </select>
              </div>
            </div>
            <div class="settings-subsection">
              <h5>INTERFACE</h5>
              <div class="settings-item">
                <span>Dark Mode</span>
                <label style="display: inline-flex; align-items: center; cursor: pointer; position: relative;">
                  <input type="checkbox" id="dark-mode-toggle" class="sr-only settings-peer">
                  <div class="settings-toggle"></div>
                </label>
              </div>
              <div class="settings-item">
                <span>Import Accounts</span>
                <label style="display: inline-flex; align-items: center; cursor: pointer; position: relative;">
                  <input type="checkbox" id="show-import-accounts-toggle" class="sr-only settings-peer">
                  <div class="settings-toggle"></div>
                </label>
              </div>
              <div class="settings-item">
                <span>Wheel Automation</span>
                <label style="display: inline-flex; align-items: center; cursor: pointer; position: relative;">
                  <input type="checkbox" id="show-wheel-automation-toggle" class="sr-only settings-peer">
                  <div class="settings-toggle"></div>
                </label>
              </div>
              <div class="settings-item">
                <span>Hide DevTools Badge</span>
                <label style="display: inline-flex; align-items: center; cursor: pointer; position: relative;">
                  <input type="checkbox" id="hide-devtools-badge-toggle" class="sr-only settings-peer">
                  <div class="settings-toggle"></div>
                </label>
              </div>
            </div>
          </div>

          <div class="settings-tab-content" id="tab-theme">
            <div class="settings-item" id="custom-theme-color-item">
              <span>Custom Theme</span>
              <label style="display: inline-flex; align-items: center; cursor: pointer; position: relative;">
                <input type="checkbox" id="custom-theme-enabled-toggle" class="sr-only settings-peer">
                <div class="settings-toggle"></div>
              </label>
            </div>
            <div id="custom-theme-color-container" style="margin-top: 4px; padding: 8px; background-color: rgba(0,0,0,0.08); border-radius: 6px; opacity: 0.5; pointer-events: none;">
              <div style="margin-bottom: 8px;">
                <label style="display: block; font-size: 11px; margin-bottom: 4px; font-family: CCDigitalDelivery;">Custom Name</label>
                <input type="text" id="custom-theme-name-input" placeholder="Custom Jam" maxlength="50" style="width: 100%; padding: 4px 8px; border: 1px solid rgba(255,255,255,0.12); border-radius: 4px; background-color: #1e1f2e; color: #C3C3C3; font-family: CCDigitalDelivery; font-size: 11px;">
              </div>
              <div style="margin-bottom: 8px;">
                <label style="display: block; font-size: 11px; margin-bottom: 4px; font-family: CCDigitalDelivery;">Fruit Icon</label>
                <select id="custom-theme-fruit-select" style="width: 100%; padding: 4px 8px; border: 1px solid rgba(255,255,255,0.12); border-radius: 4px; background-color: #1e1f2e; color: #C3C3C3; font-family: CCDigitalDelivery; font-size: 11px; color-scheme: dark;">
                  <option value="strawberry.png">Strawberry</option>
                  <option value="banana.png">Banana</option>
                  <option value="blueberry.png">Blueberry</option>
                  <option value="cantaloupe.png">Cantaloupe</option>
                  <option value="coconut.png">Coconut</option>
                  <option value="dragonfruit.png">Dragonfruit</option>
                  <option value="pineapple.png">Pineapple</option>
                  <option value="pumpkin.png">Pumpkin</option>
                </select>
              </div>
              <div style="display: flex; align-items: center; gap: 6px; margin-bottom: 6px;">
                <input type="color" id="custom-theme-color-picker" style="width: 40px; height: 28px; border: 1px solid rgba(255,255,255,0.12); border-radius: 4px; cursor: pointer; min-width: 40px; flex-shrink: 0;" value="#e83d52">
                <input type="text" id="custom-theme-color-input" placeholder="#e83d52" maxlength="7" style="flex: 1; min-width: 0; padding: 4px 6px; border: 1px solid rgba(255,255,255,0.12); border-radius: 4px; background-color: #1e1f2e; color: #C3C3C3; font-family: CCDigitalDelivery; font-size: 11px;">
              </div>
              <div style="display: flex; align-items: center; justify-content: space-between;">
                <div style="display: flex; align-items: center; gap: 6px;">
                  <img id="custom-theme-color-preview" src="images/strawberry.png" alt="Preview" style="width: 24px; height: 24px; border: 1px solid rgba(255,255,255,0.12); border-radius: 4px;">
                  <span style="font-size: 10px; font-style: italic;">Preview</span>
                </div>
                <button id="reset-custom-theme-color-btn" style="padding: 3px 8px; border: 1px solid rgba(255,255,255,0.12); border-radius: 4px; background-color: rgba(255,255,255,0.06); color: #C3C3C3; font-family: CCDigitalDelivery; font-size: 10px; cursor: pointer;">Reset</button>
              </div>
            </div>
          </div>

          <div class="settings-tab-content" id="tab-shortcuts">
            <div class="shortcuts-note">Note: Click on the left or right side panels first to focus the window before using shortcuts</div>
            <div class="settings-subsection">
              <h5>General:</h5>
              <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Shift + I: Toggle Developer Tools</div>
              <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + R: Reload / Logout (Return to Login Screen)</div>
              <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Shift + H: Toggle Hide UI Elements (Settings/Report Buttons & User Tray)</div>
            </div>
            <div class="settings-subsection">
              <h5>In-Game:</h5>
              <div class="settings-item" style="font-size: 11px; padding-left: 10px;">F5: Toggle In-Game HUD</div>
              <div class="settings-item" style="font-size: 11px; padding-left: 10px;">F9: Prepare for Screenshot</div>
              <div class="settings-item" style="font-size: 11px; padding-left: 10px;">F10: Toggle Mod Menu</div>
            </div>
            <div class="settings-subsection">
              <h5>Windows/Linux:</h5>
              <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Alt + Enter / F11: Toggle Fullscreen</div>
              <div class="settings-item" style="font-size: 11px; padding-left: 10px;">Ctrl + Q / Alt + F4: Quit Application</div>
            </div>
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
