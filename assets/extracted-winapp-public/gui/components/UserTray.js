"use strict";

(() => {
  customElements.define("ajd-user-tray", class extends HTMLElement {
    constructor() {
      super();
      this.attachShadow({ mode: "open" });
      this._expanded = false; // Internal state for content visibility
      this._expandable = true; // Internal state for arrow visibility

      this.render();
      this.attachListeners();
    }

    render() {
      this.shadowRoot.innerHTML = `
        <style>
          :host {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            font-family: Arial, sans-serif; /* Basic font */
          }

          .hidden {
            display: none !important;
          }

          #arrow-container {
            cursor: pointer;
            background-color: rgba(50,50,50,0.85); /* Dark grey background */
            border-radius: 50%; /* Circular */
            margin-bottom: 10px; /* Increased space */
            width: 44px; /* Increased diameter of the circle */
            height: 44px; /* Increased diameter of the circle */
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.3); /* Slightly enhanced shadow */
            transform: scale(1); /* Base scale for smooth transition */
            transition: background-color 0.2s ease, transform 0.1s ease;
          }

          #arrow-container:hover {
            background-color: rgba(70,70,70,0.9);
            transform: scale(1.05); /* Slight pop on hover */
          }
          
          #arrow-container:active {
            background-color: rgba(40,40,40,0.9); /* Darker press effect */
          }

          #arrow-icon-svg { /* ID for the arrow SVG element */
            width: 22px; 
            height: 22px;
            stroke: #e83d52; /* Strawberry red */
            stroke-width: 2.5; /* Slightly thicker for visibility */
            transition: transform 0.3s ease-out;
            /* Initial rotation set by _updateVisibility */
          }

          #tray-content {
            background-color: rgba(50,50,50,0.85); /* Dark grey background */
            padding: 15px;
            border-radius: 8px;
            color: white;
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
            min-width: 180px; /* Minimum width for content */
          }

          #tray-content button {
            display: flex; 
            align-items: center;
            width: 100%;
            margin-top: 10px;
            padding: 10px 15px;
            cursor: pointer;
            background-color: #e83d52; /* Strawberry red */
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 14px;
            text-align: left;
            transition: background-color 0.2s ease;
          }

          #tray-content button:first-child {
            margin-top: 0;
          }

          #tray-content button:hover {
            background-color: #d03040; /* Darker strawberry red on hover */
          }

          #tray-content button svg { /* Style for Lucide SVGs in buttons */
            margin-right: 10px; 
            width: 18px; 
            height: 18px; 
            stroke: white; 
            stroke-width: 2; 
          }
        </style>

        <div id="arrow-container">
          <svg id="arrow-icon-svg" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg>
        </div>
        <div id="tray-content" class="hidden"> 
          <button id="fullscreen-button"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6"/><path d="M9 21H3v-6"/><path d="M21 3l-7 7"/><path d="M3 21l7-7"/></svg>Fullscreen</button>
          <button id="logout-button"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" x2="9" y1="12" y2="12"/></svg>Logout</button>
        </div>
      `;

      this.arrowContainer = this.shadowRoot.getElementById("arrow-container");
      this.arrowIcon = this.shadowRoot.getElementById("arrow-icon-svg"); // Updated ID
      this.trayContent = this.shadowRoot.getElementById("tray-content");
      this.fullscreenButton = this.shadowRoot.getElementById("fullscreen-button");
      this.logoutButton = this.shadowRoot.getElementById("logout-button");

      // Reflect initial states
      this._updateVisibility();
    }

    attachListeners() {
      this.arrowContainer.addEventListener("click", () => this.toggleExpand());
      
      this.fullscreenButton.addEventListener("click", () => {
        window.ipc.send("systemCommand", { command: "toggleFullScreen" });
      });

      this.logoutButton.addEventListener("click", () => {
        this.dispatchEvent(new CustomEvent("logout-requested", { bubbles: true, composed: true }));
      });
    }

    toggleExpand() {
      if (!this._expandable) return; // Don't toggle if not expandable (e.g., maximized)
      this.expanded = !this.expanded;
    }

    get expanded() {
      return this._expanded;
    }

    set expanded(value) {
      const newExpandedState = Boolean(value);
      if (this._expanded === newExpandedState) return;
      this._expanded = newExpandedState;
      this._updateVisibility();
    }

    get expandable() {
      return this._expandable;
    }

    set expandable(value) {
      const newExpandableState = Boolean(value);
      if (this._expandable === newExpandableState) return;
      this._expandable = newExpandableState;
      this._updateVisibility();
    }

    _updateVisibility() {
      if (!this.arrowContainer || !this.trayContent || !this.arrowIcon) return;

      if (this._expandable) {
        this.arrowContainer.classList.remove("hidden");
        if (this._expanded) {
          this.trayContent.classList.remove("hidden");
          this.arrowIcon.style.transform = "rotate(0deg)"; // Expanded (pointing down)
        } else {
          this.trayContent.classList.add("hidden");
          this.arrowIcon.style.transform = "rotate(-90deg)"; // Collapsed (pointing right)
        }
      } else {
        // Not expandable (e.g., maximized mode) - arrow is hidden, content is shown
        this.arrowContainer.classList.add("hidden");
        this.trayContent.classList.remove("hidden"); 
        // Ensure arrow is in a sensible default state if it were to become visible again
        if (this.arrowIcon) this.arrowIcon.style.transform = "rotate(-90deg)";
      }
    }

    // Public methods for GameScreen to control appearance
    show() {
      this.classList.remove("hidden");
      // console.log("[UserTray] show() called");
    }

    hide() {
      this.classList.add("hidden");
      // console.log("[UserTray] hide() called");
    }

    setAppearance(mode) {
      // console.log(`[UserTray] setAppearance(${mode}) called`);
      if (mode === 'maximized' || mode === 'fullscreen') {
        this.expandable = false; // This will hide arrow, show content via _updateVisibility
        this.expanded = true;    // Ensure content is marked as expanded
      } else { // 'windowed'
        this.expandable = true;
        this.expanded = false;   // Default to collapsed when windowed
      }
    }

    async localize() {
      // Placeholder for localization if needed in the future
      // For example:
      // this.fullscreenButton.textContent = await globals.translate("userTray.fullscreen");
      // this.logoutButton.textContent = await globals.translate("userTray.logout");
      // console.log("[UserTray] localize() called");
    }
  });
})();
