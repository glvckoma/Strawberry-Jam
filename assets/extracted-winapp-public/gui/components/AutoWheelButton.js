"use strict";

(() => {
  const COMPONENT_TAG_NAME = 'auto-wheel-button';

  if (customElements.get(COMPONENT_TAG_NAME)) {
    console.warn(`Custom element ${COMPONENT_TAG_NAME} is already defined.`);
    return;
  }

  customElements.define(COMPONENT_TAG_NAME, class extends HTMLElement {
    constructor() {
      super();
      this.attachShadow({ mode: 'open' }).innerHTML = `
        <style>
          :host {
            display: block;
          }

          .auto-wheel-container {
            background-color: var(--theme-box-background, rgba(255, 245, 230, 0.95));
            border: 2px solid var(--theme-secondary, rgba(232, 61, 82, 0.3));
            border-radius: 12px;
            padding: 15px;
            margin: 10px 0;
            font-family: CCDigitalDelivery;
            transition: all 0.3s ease;
          }

          :host(.dark-mode) .auto-wheel-container {
            background-color: rgba(45, 45, 45, 0.95);
          }

          .auto-wheel-container:hover {
            box-shadow: 0 4px 12px var(--theme-shadow, rgba(252, 93, 93, 0.3));
          }

          .auto-wheel-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 10px;
          }

          .auto-wheel-title {
            color: var(--theme-primary, #e83d52);
            font-size: 14px;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 6px;
            text-shadow: var(--theme-text-shadow, none);
          }

          .wheel-icon {
            font-size: 16px;
            animation: spin 2s linear infinite;
            animation-play-state: paused;
          }

          .wheel-icon.spinning {
            animation-play-state: running;
          }

          @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
          }

          .control-button {
            padding: 6px 12px;
            border: 2px solid var(--theme-button-border, var(--theme-primary, #e83d52));
            border-radius: 6px;
            cursor: pointer;
            font-family: CCDigitalDelivery;
            font-size: 11px;
            font-weight: bold;
            transition: all 0.3s ease;
            user-select: none;
            min-width: 60px;
            text-align: center;
          }

          .start-button {
            background-color: var(--theme-button-bg, var(--theme-primary, #e83d52));
            color: var(--theme-button-text, white);
            text-shadow: var(--theme-text-shadow, none);
          }

          .start-button:hover {
            background-color: var(--theme-hover-border, rgba(232, 61, 82, 0.8));
            transform: translateY(-1px);
          }

          .stop-button {
            background-color: #dc3545;
            color: white;
            border-color: #dc3545;
          }

          .stop-button:hover {
            background-color: #c82333;
            transform: translateY(-1px);
          }

          .control-button.disabled {
            opacity: 0.6;
            cursor: not-allowed;
            pointer-events: none;
          }

          .progress-section {
            margin-top: 10px;
          }

          .progress-bar-container {
            background-color: #f0f0f0;
            border-radius: 8px;
            height: 8px;
            overflow: hidden;
            margin: 8px 0;
          }

          .progress-bar {
            height: 100%;
            background: linear-gradient(90deg, var(--theme-button-bg, var(--theme-primary, #e83d52)), var(--theme-hover-border, rgba(232, 61, 82, 0.8)));
            width: 0%;
            transition: width 0.3s ease;
            border-radius: 8px;
          }

          .progress-text {
            font-size: 11px;
            color: var(--theme-primary, #6E4B37);
            text-align: center;
            margin-bottom: 5px;
            text-shadow: var(--theme-text-shadow, none);
          }

          .status-text {
            font-size: 10px;
            color: var(--theme-primary, #e83d52);
            text-align: center;
            min-height: 12px;
            margin-top: 5px;
            text-shadow: var(--theme-text-shadow, none);
          }

          .status-text.error {
            color: #dc3545;
          }

          .status-text.success {
            color: #28a745;
          }

          .timer-text {
            font-size: 10px;
            color: #666;
            text-align: center;
            font-family: monospace;
          }

          .settings-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin: 8px 0;
            font-size: 11px;
            color: var(--theme-primary, #6E4B37);
            text-shadow: var(--theme-text-shadow, none);
          }

          .settings-input {
            width: 60px;
            padding: 2px 4px;
            border: 1px solid var(--theme-secondary, rgba(232, 61, 82, 0.3));
            border-radius: 4px;
            font-size: 11px;
            text-align: center;
          }

          .settings-select {
            width: 120px;
            padding: 2px 4px;
            border: 1px solid var(--theme-secondary, rgba(232, 61, 82, 0.3));
            border-radius: 4px;
            font-size: 11px;
            background-color: var(--theme-box-background, rgba(255, 245, 230, 0.95));
            color: var(--theme-primary, #6E4B37);
          }

          :host(.dark-mode) .settings-select {
            background-color: rgba(45, 45, 45, 0.95);
          }
          
          :host(.light-theme) .auto-wheel-container {
            background-color: rgba(225, 210, 180, 0.97) !important;
            border: 2px solid rgba(0, 0, 0, 0.3) !important;
          }
          
          :host(.light-theme) .auto-wheel-title {
            color: #333333 !important;
            text-shadow: 0 1px 1px rgba(0, 0, 0, 0.5) !important;
          }
          
          :host(.light-theme) .control-button {
            background-color: var(--light-theme-btn-bg) !important;
            border-color: rgba(0, 0, 0, 0.3) !important;
            color: #333333 !important;
            box-shadow: 0 0 0 1px rgba(0, 0, 0, 0.3) !important;
            text-shadow: 0 1px 1px rgba(0, 0, 0, 0.5) !important;
          }
          
          :host(.light-theme) .control-button:hover {
            background-color: var(--light-theme-btn-hover-bg) !important;
          }
          
          :host(.light-theme) .progress-text {
            color: #333333 !important;
            text-shadow: 0 1px 1px rgba(0, 0, 0, 0.5) !important;
          }
          
          :host(.light-theme) .status-text {
            color: #333333 !important;
            text-shadow: 0 1px 1px rgba(0, 0, 0, 0.5) !important;
          }
          
          :host(.light-theme) .settings-row {
            color: #333333 !important;
            text-shadow: 0 1px 1px rgba(0, 0, 0, 0.5) !important;
          }
          
          :host(.light-theme) .progress-bar {
            background: linear-gradient(90deg, var(--light-theme-progress-bg), var(--light-theme-progress-end)) !important;
          }
          
          :host(.light-theme) .settings-select {
            background-color: rgba(225, 210, 180, 0.97) !important;
            border-color: rgba(0, 0, 0, 0.3) !important;
            color: #333333 !important;
          }
        </style>
        <div class="auto-wheel-container">
          <div class="auto-wheel-header">
            <div class="auto-wheel-title">
              <span class="wheel-icon">🎡</span>
              <span>Auto Wheel</span>
            </div>
            <div class="control-button start-button" data-action="start">Start</div>
          </div>
          
          <div class="settings-row">
            <label>Spin Delay:</label>
            <input type="number" class="settings-input" id="spin-delay" value="30" min="5" max="300" title="Seconds between login and logout">
          </div>
          
          <div class="settings-row">
            <label>Batch Size:</label>
            <input type="number" class="settings-input" id="batch-size" value="10" min="1" max="50" title="Accounts per batch before 5min break">
          </div>
          
          <div class="settings-row">
            <label>Start From:</label>
            <select class="settings-select" id="start-account" title="Select which account to start auto wheel from">
              <option value="0">First Account</option>
            </select>
          </div>
          
          <div class="progress-section">
            <div class="progress-text">Ready to start</div>
            <div class="progress-bar-container">
              <div class="progress-bar"></div>
            </div>
            <div class="timer-text"></div>
            <div class="status-text"></div>
          </div>
        </div>
      `;
      
      this._isRunning = false;
      this._currentAccount = 0;
      this._totalAccounts = 0;
      this._timer = null;
      this._accounts = [];
      this._currentBatch = 0;
      this._accountsInCurrentBatch = 0;
    }

    connectedCallback() {
      this.controlButtonElem = this.shadowRoot.querySelector('.control-button');
      this.wheelIconElem = this.shadowRoot.querySelector('.wheel-icon');
      this.progressBarElem = this.shadowRoot.querySelector('.progress-bar');
      this.progressTextElem = this.shadowRoot.querySelector('.progress-text');
      this.statusTextElem = this.shadowRoot.querySelector('.status-text');
      this.timerTextElem = this.shadowRoot.querySelector('.timer-text');
      this.spinDelayElem = this.shadowRoot.querySelector('#spin-delay');
      this.batchSizeElem = this.shadowRoot.querySelector('#batch-size');
      this.startAccountElem = this.shadowRoot.querySelector('#start-account');

      if (this.controlButtonElem) {
        this.controlButtonElem.addEventListener('click', () => this._handleControlClick());
      }

      // Listen for account list updates
      document.addEventListener('accounts-imported', (event) => {
        this._onAccountsUpdated(event.detail.accounts);
      });

      // Apply theme on connect
      if (this._currentThemeKey) {
        this._applyTheme(this._currentThemeKey);
      }
    }

    disconnectedCallback() {
      this._stopAutoWheel();
    }

    updateTheme(themeKey) {
      this._currentThemeKey = themeKey;
      this._applyTheme(themeKey);
    }

    setDarkMode(isDarkMode) {
      // Apply dark mode class to host element
      if (isDarkMode) {
        this.classList.add('dark-mode');
      } else {
        this.classList.remove('dark-mode');
      }
    }

    _applyTheme(themeKey) {
      const root = document.documentElement;
      const primary = getComputedStyle(root).getPropertyValue('--theme-primary').trim();
      
      if (primary) {
        const primaryIsLight = this._isLightColor(primary);
        const fruitKey = themeKey;
        
        // Apply light theme adaptations for banana and pineapple
        if (primaryIsLight && (fruitKey === 'banana.png' || fruitKey === 'pineapple.png')) {
          const darkenedBg = this._darkenColor(primary, 20);
          const hoverBg = this._darkenColor(darkenedBg, 10);
          
          // Set CSS custom properties on the host element
          this.style.setProperty('--light-theme-btn-bg', darkenedBg);
          this.style.setProperty('--light-theme-btn-hover-bg', hoverBg);
          this.style.setProperty('--light-theme-progress-bg', darkenedBg);
          this.style.setProperty('--light-theme-progress-end', hoverBg);
          this.classList.add('light-theme');
        } else {
          this.classList.remove('light-theme');
          this.style.removeProperty('--light-theme-btn-bg');
          this.style.removeProperty('--light-theme-btn-hover-bg');
          this.style.removeProperty('--light-theme-progress-bg');
          this.style.removeProperty('--light-theme-progress-end');
        }
      }
    }

    _isLightColor(hexColor) {
      if (!hexColor || hexColor.length < 7) return false;
      const r = parseInt(hexColor.slice(1, 3), 16);
      const g = parseInt(hexColor.slice(3, 5), 16);
      const b = parseInt(hexColor.slice(5, 7), 16);
      const luminance = (r * 299 + g * 587 + b * 114) / 1000;
      return luminance > 150;
    }

    _darkenColor(hex, percent) {
      if (!hex || hex.length < 7) return hex;
      let r = parseInt(hex.slice(1, 3), 16);
      let g = parseInt(hex.slice(3, 5), 16);
      let b = parseInt(hex.slice(5, 7), 16);
      
      r = Math.max(0, Math.floor(r * (100 - percent) / 100));
      g = Math.max(0, Math.floor(g * (100 - percent) / 100));
      b = Math.max(0, Math.floor(b * (100 - percent) / 100));
      
      return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`;
    }

    setAccounts(accounts) {
      // Sort accounts so pinned accounts come first
      this._accounts = (accounts || []).sort((a, b) => {
        // Pinned accounts come first (true > false when converted to numbers)
        if (a.pinned && !b.pinned) return -1;
        if (!a.pinned && b.pinned) return 1;
        return 0; // Maintain original order for accounts with same pinned status
      });
      
      this._totalAccounts = this._accounts.length;
      this._updateStartAccountDropdown();
      this._updateProgressDisplay();
      
      // Accounts loaded and sorted - removed verbose logging
    }

    _onAccountsUpdated(accounts) {
      this.setAccounts(accounts);
    }

    _updateStartAccountDropdown() {
      if (!this.startAccountElem) return;
      
      // Store current selection to restore if possible
      const currentValue = this.startAccountElem.value;
      
      // Clear existing options
      this.startAccountElem.innerHTML = '';
      
      // Add "First Account" option
      const firstOption = document.createElement('option');
      firstOption.value = '0';
      firstOption.textContent = 'First Account';
      this.startAccountElem.appendChild(firstOption);
      
      // Add option for each account
      this._accounts.forEach((account, index) => {
        const option = document.createElement('option');
        option.value = index.toString();
        const displayName = account.username.length > 12 ? 
          account.username.substring(0, 12) + '...' : 
          account.username;
        option.textContent = `${index + 1}. ${displayName}${account.pinned ? ' 📌' : ''}`;
        option.title = account.username; // Full username on hover
        this.startAccountElem.appendChild(option);
      });
      
      // Restore previous selection if it's still valid
      if (currentValue && parseInt(currentValue) < this._accounts.length) {
        this.startAccountElem.value = currentValue;
      } else {
        this.startAccountElem.value = '0';
      }
    }

    _handleControlClick() {
      if (this._isRunning) {
        this._stopAutoWheel();
      } else {
        this._startAutoWheel();
      }
    }

    async _startAutoWheel() {
      if (this._accounts.length === 0) {
        this._showStatus('No accounts available. Please import accounts first.', 'error');
        return;
      }

      this._isRunning = true;
      this._currentAccount = parseInt(this.startAccountElem.value) || 0;
      this._currentBatch = 0;
      this._accountsInCurrentBatch = 0;
      
      this.controlButtonElem.textContent = 'Stop';
      this.controlButtonElem.className = 'control-button stop-button';
      this.wheelIconElem.classList.add('spinning');
      this.spinDelayElem.disabled = true;
      this.batchSizeElem.disabled = true;
      this.startAccountElem.disabled = true;
      
      this._showStatus('Starting auto wheel...', '');
      
      try {
        await this._runAutoWheelCycle();
      } catch (error) {
        console.error('[AutoWheel] Error during auto wheel:', error);
        this._showStatus(`Error: ${error.message}`, 'error');
        this._stopAutoWheel();
      }
    }

    _stopAutoWheel() {
      this._isRunning = false;
      
      if (this._timer) {
        clearTimeout(this._timer);
        this._timer = null;
      }
      
      this.controlButtonElem.textContent = 'Start';
      this.controlButtonElem.className = 'control-button start-button';
      this.wheelIconElem.classList.remove('spinning');
      this.spinDelayElem.disabled = false;
      this.batchSizeElem.disabled = false;
      this.startAccountElem.disabled = false;
      
      this._updateProgressDisplay();
      this._showStatus('Auto wheel stopped', '');
      this.timerTextElem.textContent = '';
      
      // Dispatch stop event
      this.dispatchEvent(new CustomEvent('auto-wheel-stopped', {
        bubbles: true,
        composed: true
      }));
    }

    async _runAutoWheelCycle() {
      if (!this._isRunning || this._currentAccount >= this._accounts.length) {
        this._showStatus('Auto wheel completed!', 'success');
        this._stopAutoWheel();
        return;
      }

      const batchSize = parseInt(this.batchSizeElem.value) || 10;
      
      // Check if we need a 5-minute break
      if (this._accountsInCurrentBatch >= batchSize) {
        this._showStatus('Taking 5-minute break after batch...', '');
        await this._waitWithTimer(5 * 60 * 1000); // 5 minutes
        this._currentBatch++;
        this._accountsInCurrentBatch = 0;
        
        if (!this._isRunning) return;
      }

      const account = this._accounts[this._currentAccount];
      this._showStatus(`Logging in: ${account.username}`, '');
      
      try {
        // Starting login for account
        
        // Dispatch account selection event to properly select the account slot
        // Dispatching account-selected event
        document.dispatchEvent(new CustomEvent('account-selected', {
          detail: { username: account.username, password: account.password },
          bubbles: true,
          composed: true
        }));

        // Small delay to let account selection process
        // Waiting for account selection to process
        await this._waitWithTimer(1000);

        // Check what's actually in the login fields now
        const usernameField = document.querySelector('input[type="text"]');
        const passwordField = document.querySelector('input[type="password"]');
        // Account selection processed

        // Now dispatch login event
        // Dispatching auto-wheel-login event
        this.dispatchEvent(new CustomEvent('auto-wheel-login', {
          detail: { account },
          bubbles: true,
          composed: true
        }));

        // Wait a bit for login to process
        // Waiting for login to process
        await this._waitWithTimer(3000);
        
        // Check login status
        // Login attempt completed
        const currentUsername = document.querySelector('input[type="text"]')?.value;
        // Checking login status
        
        if (currentUsername !== account.username) {
          console.warn(`[AutoWheel] WARNING: Expected username "${account.username}" but field shows "${currentUsername}"`);
        }
        
        if (!this._isRunning) return;

        // Wait for spin delay
        const spinDelay = (parseInt(this.spinDelayElem.value) || 30) * 1000;
        this._showStatus(`Spinning wheel for ${account.username}...`, '');
        await this._waitWithTimer(spinDelay);
        
        if (!this._isRunning) return;

        // Dispatch logout event and wait for logout to complete
        this._showStatus(`Logging out: ${account.username}`, '');
        this.dispatchEvent(new CustomEvent('auto-wheel-logout', {
          detail: { account },
          bubbles: true,
          composed: true
        }));

        // Wait for logout to complete
        await this._waitWithTimer(3000);
        
        if (!this._isRunning) return;

        this._currentAccount++;
        this._accountsInCurrentBatch++;
        this._updateProgressDisplay();

        // Small delay before next account
        await this._waitWithTimer(2000);
        
        // Continue with next account
        if (this._isRunning) {
          await this._runAutoWheelCycle();
        }
      } catch (error) {
        throw new Error(`Failed to process ${account.username}: ${error.message}`);
      }
    }

    _waitWithTimer(ms) {
      return new Promise((resolve) => {
        const startTime = Date.now();
        const endTime = startTime + ms;
        
        const updateTimer = () => {
          if (!this._isRunning) {
            resolve();
            return;
          }
          
          const now = Date.now();
          const remaining = endTime - now;
          
          if (remaining <= 0) {
            this.timerTextElem.textContent = '';
            resolve();
            return;
          }
          
          const seconds = Math.ceil(remaining / 1000);
          this.timerTextElem.textContent = `⏱️ ${seconds}s`;
          
          this._timer = setTimeout(updateTimer, 100);
        };
        
        updateTimer();
      });
    }

    _updateProgressDisplay() {
      if (this._totalAccounts === 0) {
        this.progressTextElem.textContent = 'No accounts loaded';
        this.progressBarElem.style.width = '0%';
        return;
      }

      const progress = (this._currentAccount / this._totalAccounts) * 100;
      this.progressBarElem.style.width = `${progress}%`;
      
      // Count pinned accounts for display
      const pinnedCount = this._accounts.filter(acc => acc.pinned).length;
      const pinnedText = pinnedCount > 0 ? ` (📌${pinnedCount})` : '';
      
      if (this._isRunning) {
        const currentAccount = this._accounts[this._currentAccount];
        const currentAccountText = currentAccount ? `${currentAccount.username}${currentAccount.pinned ? ' 📌' : ''}` : 'Unknown';
        const startIndex = parseInt(this.startAccountElem?.value || '0');
        const remaining = this._totalAccounts - this._currentAccount;
        this.progressTextElem.textContent = `${currentAccountText} - ${this._currentAccount + 1}/${this._totalAccounts} (${remaining} remaining)${pinnedText}`;
      } else {
        this.progressTextElem.textContent = `${this._totalAccounts} accounts loaded${pinnedText}`;
      }
    }

    _showStatus(message, type = '') {
      this.statusTextElem.textContent = message;
      this.statusTextElem.className = `status-text ${type}`;
      
      if (type && type !== 'error') {
        setTimeout(() => {
          if (this.statusTextElem && !this._isRunning) {
            this.statusTextElem.textContent = '';
            this.statusTextElem.className = 'status-text';
          }
        }, 3000);
      }
    }
  });
})(); 