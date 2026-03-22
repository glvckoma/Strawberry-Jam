"use strict";

(() => {
  customElements.define("ajd-user-tray", class extends HTMLElement {
    constructor() {
      super();
      this.attachShadow({ mode: "open" });
      this._expanded = false;
      this._expandable = true;

      this.loadExternalFiles();
    }

    async loadExternalFiles() {
      try {
        const cssResponse = await fetch('components/screens/UserTray.css');
        const cssText = await cssResponse.text();

        const htmlResponse = await fetch('components/screens/UserTray.html');
        const htmlText = await htmlResponse.text();

        this.shadowRoot.innerHTML = `<style>${cssText}</style>${htmlText}`;

        this.initializeElements();
        this.attachListeners();
        this._updateVisibility();
      } catch (error) {
        console.error('Failed to load UserTray external files:', error);
        this.renderFallback();
      }
    }

    renderFallback() {
      this.shadowRoot.innerHTML = `
        <style>
          :host {
            position: fixed;
            bottom: 4px;
            right: 4px;
            z-index: 10000;
          }
          #tray-container {
            background: rgba(255, 245, 230, 0.95);
            border: 2px solid rgba(232, 61, 82, 0.3);
            border-radius: 8px;
            padding: 8px;
          }
          button {
            background: #e83d52;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 4px;
            cursor: pointer;
            margin: 2px 0;
            display: block;
          }
        </style>
        <div id="tray-container">
          <button id="fullscreen-button">Fullscreen</button>
          <button id="logout-button">Logout</button>
        </div>
      `;
      
      this.initializeElements();
      this.attachListeners();
    }

    initializeElements() {
      this.trayContainer = this.shadowRoot.getElementById("tray-container");
      this.arrowContainer = this.shadowRoot.getElementById("arrow-container");
      this.arrowIcon = this.shadowRoot.getElementById("arrow-icon-svg");
      this.trayContent = this.shadowRoot.getElementById("tray-content");
      this.fullscreenButton = this.shadowRoot.getElementById("fullscreen-button");
      this.logoutButton = this.shadowRoot.getElementById("logout-button");
    }

    attachListeners() {
      if (this.arrowContainer) {
        this.arrowContainer.addEventListener("click", () => this.toggleExpand());
      }
      
      if (this.fullscreenButton) {
        this.fullscreenButton.addEventListener("click", () => {
          window.ipc.send("systemCommand", { command: "toggleFullScreen" });
        });
      }

      if (this.logoutButton) {
        this.logoutButton.addEventListener("click", () => {
          if (window.ipc) {
            window.ipc.send("logout");
          }
          this.dispatchEvent(new CustomEvent("logout-requested", { bubbles: true, composed: true }));
        });
      }
    }

    toggleExpand() {
      if (!this._expandable) return;
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
          this.trayContent.classList.add("expanded");
          this.arrowIcon.style.transform = "rotate(180deg)";
        } else {
          this.trayContent.classList.remove("expanded");
          this.arrowIcon.style.transform = "rotate(0deg)";
        }
      } else {
        this.arrowContainer.classList.add("hidden");
        this.trayContent.classList.add("expanded");
        if (this.arrowIcon) this.arrowIcon.style.transform = "rotate(0deg)";
      }
    }

    show() {
      this.style.display = 'flex';
    }

    hide() {
      this.style.display = 'none';
    }

    setAppearance(mode) {
      if (mode === 'maximized' || mode === 'fullscreen') {
        this.expandable = false;
        this.expanded = true;
      } else {
        this.expandable = true;
        this.expanded = false;
      }
    }

    updateTheme(theme) {
      if (!theme) return;
      this.style.setProperty('--theme-primary', theme.primary);
      this.style.setProperty('--theme-secondary', theme.secondary);
      this.style.setProperty('--theme-hover-border', theme.hoverBorder);
      this.style.setProperty('--theme-shadow', theme.shadow);
      this.style.setProperty('--theme-box-background', theme.boxBackground);
      this.style.setProperty('--theme-settings-hover', theme.settingsHover);
    }
  });

  window.UserTrayManager = {
    instance: null,
    
    create(theme) {
      if (this.instance) {
        this.destroy();
      }
      
      this.instance = document.createElement('ajd-user-tray');
      if (theme) {
        this.instance.updateTheme(theme);
      }
      document.body.appendChild(this.instance);
      
      return this.instance;
    },
    
    destroy() {
      if (this.instance && this.instance.parentNode) {
        this.instance.parentNode.removeChild(this.instance);
        this.instance = null;
      }
    },
    
    show() {
      if (this.instance) {
        this.instance.show();
      }
    },
    
    hide() {
      if (this.instance) {
        this.instance.hide();
      }
    },
    
    setAppearance(mode) {
      if (this.instance) {
        this.instance.setAppearance(mode);
      }
    }
  };
})();
