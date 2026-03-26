"use strict";

(() => {
  customElements.define("ajd-debug-log-modal", class extends HTMLElement {
    constructor() {
      super();

      this.attachShadow({ mode: "open" }).innerHTML = `
        <style>
          :host {
            display: flex;
            z-index: 10;
            justify-content: center;
            align-items: center;
            height: 100vh;
            width: 100vw;
          }

          #backdrop {
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.5);
          }

          #modal-body {
            position: relative;
            display: flex;
            flex-direction: column;
            width: 680px;
            max-height: 80vh;
            border-radius: 20px;
            background: var(--theme-box-background, rgba(45, 45, 45, 0.95));
            border: 2px solid var(--theme-secondary, rgba(232, 61, 82, 0.3));
            box-shadow: 0 8px 32px var(--theme-shadow, rgba(252, 93, 93, 0.1));
            overflow: hidden;
            z-index: 1;
            background-image:
              radial-gradient(circle at 10% 20%, var(--theme-radial-1, rgba(255, 180, 180, 0.05)) 0%, transparent 50%),
              radial-gradient(circle at 90% 80%, var(--theme-radial-2, rgba(255, 200, 200, 0.07)) 0%, transparent 50%);
          }

          #help-banner {
            display: none;
            padding: 10px 16px;
            background: rgba(245, 158, 11, 0.1);
            border-bottom: 1px solid rgba(245, 158, 11, 0.2);
            color: #fbbf24;
            font-family: CCDigitalDelivery, sans-serif;
            font-size: 13px;
            line-height: 1.4;
            align-items: center;
            gap: 8px;
          }

          :host(.light-mode) #help-banner {
            background: rgba(245, 158, 11, 0.08);
            color: #b45309;
          }

          #help-banner.show {
            display: flex;
          }

          #help-banner-text {
            flex: 1;
          }

          #help-banner a {
            color: var(--theme-primary, #e83d52);
            text-decoration: underline;
            cursor: pointer;
          }

          #help-banner a:hover {
            opacity: 0.8;
          }

          #header-div {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 16px;
            border-bottom: 1px solid var(--theme-settings-border, rgba(232, 61, 82, 0.2));
          }

          #header-title {
            font-family: Tiki-Island, sans-serif;
            font-size: 20px;
            color: var(--theme-primary, #e83d52);
            text-shadow: 1px 1px 0px var(--theme-shadow, rgba(252, 93, 93, 0.1));
            display: flex;
            align-items: center;
            gap: 10px;
          }

          #error-count-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 22px;
            height: 22px;
            padding: 0 6px;
            border-radius: 11px;
            background: var(--theme-primary, #e83d52);
            color: white;
            font-family: CCDigitalDelivery, sans-serif;
            font-size: 11px;
            font-weight: 700;
          }

          #error-count-badge.hidden {
            display: none;
          }

          #close-btn {
            background: none;
            border: 2px solid var(--theme-secondary, rgba(232, 61, 82, 0.3));
            color: #B0B0B0;
            font-size: 16px;
            cursor: pointer;
            width: 28px;
            height: 28px;
            border-radius: 8px;
            transition: all 0.2s ease;
            line-height: 1;
            display: flex;
            align-items: center;
            justify-content: center;
          }

          :host(.light-mode) #close-btn {
            color: #6E4B37;
          }

          #close-btn:hover {
            border-color: var(--theme-hover-border, rgba(232, 61, 82, 0.5));
            color: var(--theme-primary, #e83d52);
            transform: scale(1.05);
          }

          #log-container {
            flex: 1;
            overflow-y: auto;
            padding: 8px 0;
            min-height: 200px;
            max-height: 50vh;
          }

          #log-container::-webkit-scrollbar {
            width: 6px;
          }

          #log-container::-webkit-scrollbar-track {
            background: transparent;
          }

          #log-container::-webkit-scrollbar-thumb {
            background: var(--theme-secondary, rgba(232, 61, 82, 0.3));
            border-radius: 3px;
          }

          #log-container::-webkit-scrollbar-thumb:hover {
            background: var(--theme-hover-border, rgba(232, 61, 82, 0.5));
          }

          .log-entry {
            padding: 3px 16px;
            font-family: "Cascadia Code", "Fira Code", "Consolas", monospace;
            font-size: 12px;
            line-height: 1.5;
            display: flex;
            gap: 8px;
            white-space: pre-wrap;
            word-break: break-word;
            transition: background 0.1s ease;
            border-radius: 4px;
            margin: 0 4px;
          }

          .log-entry:hover {
            background: var(--theme-settings-hover, rgba(232, 61, 82, 0.05));
          }

          .log-timestamp {
            color: #7a7a8a;
            flex-shrink: 0;
          }

          :host(.light-mode) .log-timestamp {
            color: #9a8a7a;
          }

          .log-level {
            flex-shrink: 0;
            min-width: 50px;
            font-weight: 600;
          }

          .log-level.error { color: #ef4444; }
          .log-level.warn { color: #f59e0b; }
          .log-level.info { color: #60a5fa; }
          .log-level.log { color: #9ca3af; }
          .log-level.verbose { color: #6b7280; }

          :host(.light-mode) .log-level.info { color: #2563eb; }
          :host(.light-mode) .log-level.log { color: #6E4B37; }
          :host(.light-mode) .log-level.verbose { color: #9a8a7a; }

          .log-message {
            color: #B0B0B0;
            flex: 1;
          }

          .log-message.error { color: #fca5a5; }

          :host(.light-mode) .log-message {
            color: #6E4B37;
          }

          :host(.light-mode) .log-message.error {
            color: #dc2626;
          }

          #empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 40px;
            color: #7a7a8a;
            font-family: CCDigitalDelivery, sans-serif;
            font-size: 14px;
            gap: 8px;
          }

          :host(.light-mode) #empty-state {
            color: #9a8a7a;
          }

          #footer-div {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 16px;
            border-top: 1px solid var(--theme-settings-border, rgba(232, 61, 82, 0.2));
            gap: 8px;
          }

          #log-count {
            font-family: CCDigitalDelivery, sans-serif;
            font-size: 12px;
            color: #7a7a8a;
          }

          :host(.light-mode) #log-count {
            color: #9a8a7a;
          }

          .footer-buttons {
            display: flex;
            gap: 8px;
          }

          .modal-btn {
            padding: 8px 20px;
            border-radius: 8px;
            border: 2px solid transparent;
            font-family: CCDigitalDelivery, sans-serif;
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
          }

          .modal-btn:active {
            transform: scale(0.96);
          }

          #copy-btn {
            background: var(--theme-primary, #e83d52);
            border-color: var(--theme-secondary, rgba(232, 61, 82, 0.3));
            color: white;
          }

          #copy-btn:hover {
            opacity: 0.9;
            transform: scale(1.02);
          }

          #copy-btn.copied {
            background: #10b981;
            border-color: rgba(16, 185, 129, 0.3);
          }

          #close-footer-btn {
            background: transparent;
            border-color: var(--theme-secondary, rgba(232, 61, 82, 0.3));
            color: #B0B0B0;
          }

          :host(.light-mode) #close-footer-btn {
            color: #6E4B37;
          }

          #close-footer-btn:hover {
            border-color: var(--theme-hover-border, rgba(232, 61, 82, 0.5));
            color: var(--theme-primary, #e83d52);
          }
        </style>

        <div id="backdrop"></div>
        <div id="modal-body">
          <div id="help-banner">
            <span id="help-banner-text">
              Login is taking longer than expected. Copy the logs below and share them in <a id="discord-link">#sj-help on Discord</a> for assistance.
            </span>
          </div>
          <div id="header-div">
            <div id="header-title">
              <span>Debug Logs</span>
              <span id="error-count-badge" class="hidden">0</span>
            </div>
            <button id="close-btn">&times;</button>
          </div>
          <div id="log-container"></div>
          <div id="footer-div">
            <span id="log-count"></span>
            <div class="footer-buttons">
              <button id="copy-btn" class="modal-btn">Copy Logs</button>
              <button id="close-footer-btn" class="modal-btn">Close</button>
            </div>
          </div>
        </div>
      `;

      this._logContainer = this.shadowRoot.getElementById("log-container");
      this._logCount = this.shadowRoot.getElementById("log-count");
      this._errorBadge = this.shadowRoot.getElementById("error-count-badge");
      this._helpBanner = this.shadowRoot.getElementById("help-banner");
      this._copyBtn = this.shadowRoot.getElementById("copy-btn");

      this.shadowRoot.getElementById("close-btn").addEventListener("click", () => {
        this.dispatchEvent(new CustomEvent("close"));
      });

      this.shadowRoot.getElementById("close-footer-btn").addEventListener("click", () => {
        this.dispatchEvent(new CustomEvent("close"));
      });

      this.shadowRoot.getElementById("backdrop").addEventListener("click", () => {
        this.dispatchEvent(new CustomEvent("close"));
      });

      this._copyBtn.addEventListener("click", () => {
        this._copyLogs();
      });

      const discordLink = this.shadowRoot.getElementById("discord-link");
      if (discordLink) {
        discordLink.addEventListener("click", (e) => {
          e.preventDefault();
          if (window.ipc && window.ipc.send) {
            window.ipc.send("openExternal", "https://discord.gg/strawberryjam");
          }
        });
      }
    }

    set showHelpBanner(val) {
      if (this._helpBanner) {
        if (val) {
          this._helpBanner.classList.add("show");
        } else {
          this._helpBanner.classList.remove("show");
        }
      }
    }

    set errorCount(val) {
      if (this._errorBadge) {
        if (val > 0) {
          this._errorBadge.textContent = val;
          this._errorBadge.classList.remove("hidden");
        } else {
          this._errorBadge.classList.add("hidden");
        }
      }
    }

    connectedCallback() {
      this._inheritTheme();
      this._renderLogs();
    }

    _inheritTheme() {
      const loginScreen = document.querySelector('ajd-login-screen');
      if (!loginScreen) return;

      const hostStyle = getComputedStyle(loginScreen);
      const vars = [
        '--theme-primary', '--theme-secondary', '--theme-shadow',
        '--theme-hover-border', '--theme-radial-1', '--theme-radial-2',
        '--theme-settings-hover', '--theme-settings-border',
        '--theme-box-background', '--theme-box-background-dark',
        '--theme-box-background-light'
      ];

      for (const v of vars) {
        const val = hostStyle.getPropertyValue(v);
        if (val) this.style.setProperty(v, val.trim());
      }

      const isDarkMode = loginScreen.classList.contains('dark-mode');
      if (isDarkMode) {
        this.classList.remove('light-mode');
        this.style.setProperty('--theme-box-background', hostStyle.getPropertyValue('--theme-box-background-dark').trim());
      } else {
        this.classList.add('light-mode');
        this.style.setProperty('--theme-box-background', hostStyle.getPropertyValue('--theme-box-background-light').trim());
      }
    }

    _renderLogs() {
      const logs = window.LoginScreenUtilities ? window.LoginScreenUtilities.getConsoleLogs() : [];

      if (logs.length === 0) {
        this._logContainer.innerHTML = `
          <div id="empty-state">
            <span>No logs captured yet.</span>
          </div>
        `;
        this._logCount.textContent = "0 entries";
        return;
      }

      const fragment = document.createDocumentFragment();

      for (const entry of logs) {
        const row = document.createElement("div");
        row.className = "log-entry";

        const time = document.createElement("span");
        time.className = "log-timestamp";
        time.textContent = this._formatTime(entry.timestamp);

        const level = document.createElement("span");
        level.className = `log-level ${entry.level}`;
        level.textContent = entry.level.toUpperCase();

        const msg = document.createElement("span");
        msg.className = `log-message${entry.level === "error" ? " error" : ""}`;
        msg.textContent = entry.message;

        row.appendChild(time);
        row.appendChild(level);
        row.appendChild(msg);
        fragment.appendChild(row);
      }

      this._logContainer.innerHTML = "";
      this._logContainer.appendChild(fragment);
      this._logCount.textContent = `${logs.length} ${logs.length === 1 ? "entry" : "entries"}`;

      requestAnimationFrame(() => {
        this._logContainer.scrollTop = this._logContainer.scrollHeight;
      });
    }

    _formatTime(isoString) {
      try {
        const d = new Date(isoString);
        const h = String(d.getHours()).padStart(2, "0");
        const m = String(d.getMinutes()).padStart(2, "0");
        const s = String(d.getSeconds()).padStart(2, "0");
        return `${h}:${m}:${s}`;
      } catch (_) {
        return isoString;
      }
    }

    async _copyLogs() {
      const logs = window.LoginScreenUtilities ? window.LoginScreenUtilities.getConsoleLogs() : [];

      if (logs.length === 0) {
        this._showCopyFeedback("No logs to copy");
        return;
      }

      const formatted = logs.map(entry => {
        const time = this._formatTime(entry.timestamp);
        const level = entry.level.toUpperCase().padEnd(5);
        return `[${time}] [${level}] ${entry.message}`;
      }).join("\n");

      try {
        await navigator.clipboard.writeText(formatted);
        this._showCopyFeedback("Copied!");
      } catch (_) {
        this._showCopyFeedback("Copy failed");
      }
    }

    _showCopyFeedback(text) {
      const original = this._copyBtn.textContent;
      this._copyBtn.textContent = text;
      this._copyBtn.classList.add("copied");
      setTimeout(() => {
        this._copyBtn.textContent = original;
        this._copyBtn.classList.remove("copied");
      }, 2000);
    }
  });
})();
