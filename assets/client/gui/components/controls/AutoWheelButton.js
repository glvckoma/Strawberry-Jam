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

          .pause-button {
            background-color: #ff9800;
            color: white;
            border-color: #ff9800;
          }

          .pause-button:hover {
            background-color: #e68900;
            transform: translateY(-1px);
          }

          .control-button.disabled {
            opacity: 0.6;
            cursor: not-allowed;
            pointer-events: none;
          }

          .control-button.hidden {
            display: none;
          }

          .button-group {
            display: flex;
            gap: 8px;
            align-items: center;
          }

          .progress-section {
            margin-top: 10px;
          }

          .progress-bar-container {
            background-color: rgba(255,255,255,0.08);
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
            padding: 3px 6px;
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 4px;
            font-size: 11px;
            text-align: center;
            background-color: rgba(255,255,255,0.06);
            color: inherit;
            font-family: CCDigitalDelivery;
            color-scheme: dark;
          }
          .settings-input:focus {
            outline: none;
            border-color: var(--theme-primary, #e83d52);
          }

          .settings-select {
            width: 120px;
            padding: 3px 6px;
            border: 1px solid rgba(255,255,255,0.12);
            border-radius: 4px;
            font-size: 11px;
            background-color: #1e1f2e;
            color: #C3C3C3;
            font-family: CCDigitalDelivery;
            color-scheme: dark;
          }
          .settings-select:focus {
            outline: none;
            border-color: var(--theme-primary, #e83d52);
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

          :host(.light-theme) .pause-button {
            background-color: #ff9800 !important;
            border-color: #ff9800 !important;
            color: white !important;
          }

          :host(.light-theme) .pause-button:hover {
            background-color: #e68900 !important;
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
            <div class="button-group">
              <div class="control-button pause-button hidden" data-action="pause" id="pause-button">Pause</div>
              <div class="control-button start-button" data-action="start" id="start-button">Start</div>
            </div>
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
      this._isPaused = false;
      this._currentAccount = 0;
      this._totalAccounts = 0;
      this._timer = null;
      this._accounts = [];
      this._currentBatch = 0;
      this._accountsInCurrentBatch = 0;
      this._saveDebounceTimer = null;
      this._pauseButtonElem = null;
    }

    connectedCallback() {
      this.startButtonElem = this.shadowRoot.querySelector('#start-button');
      this.pauseButtonElem = this.shadowRoot.querySelector('#pause-button');
      this.controlButtonElem = this.startButtonElem;
      this.wheelIconElem = this.shadowRoot.querySelector('.wheel-icon');
      this.progressBarElem = this.shadowRoot.querySelector('.progress-bar');
      this.progressTextElem = this.shadowRoot.querySelector('.progress-text');
      this.statusTextElem = this.shadowRoot.querySelector('.status-text');
      this.timerTextElem = this.shadowRoot.querySelector('.timer-text');
      this.spinDelayElem = this.shadowRoot.querySelector('#spin-delay');
      this.batchSizeElem = this.shadowRoot.querySelector('#batch-size');
      this.startAccountElem = this.shadowRoot.querySelector('#start-account');

      this._loadSavedSettings();
      this._loadPausedState();

      if (this.startButtonElem) {
        this.startButtonElem.addEventListener('click', () => this._handleControlClick());
      }

      if (this.pauseButtonElem) {
        this.pauseButtonElem.addEventListener('click', () => this._handlePauseClick());
      }

      if (this.spinDelayElem) {
        this.spinDelayElem.addEventListener('input', () => this._debounceSave());
        this.spinDelayElem.addEventListener('change', () => this._saveSettings());
      }

      if (this.batchSizeElem) {
        this.batchSizeElem.addEventListener('input', () => this._debounceSave());
        this.batchSizeElem.addEventListener('change', () => this._saveSettings());
      }

      document.addEventListener('accounts-imported', (event) => {
        this._onAccountsUpdated(event.detail.accounts);
      });

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
        const primaryIsLight = window.ColorUtils.isLightColor(primary);
        const fruitKey = themeKey;

        if (primaryIsLight && (fruitKey === 'banana.png' || fruitKey === 'pineapple.png')) {
          const darkenedBg = window.ColorUtils.darkenColor(primary, 20);
          const hoverBg = window.ColorUtils.darkenColor(darkenedBg, 10);

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

    _loadSavedSettings() {
      try {
        const savedSpinDelay = localStorage.getItem('autoWheel.spinDelay');
        const savedBatchSize = localStorage.getItem('autoWheel.batchSize');
        
        if (savedSpinDelay && this.spinDelayElem) {
          const delay = parseInt(savedSpinDelay, 10);
          if (!isNaN(delay) && delay >= 5 && delay <= 300) {
            this.spinDelayElem.value = delay;
          }
        }
        
        if (savedBatchSize && this.batchSizeElem) {
          const batch = parseInt(savedBatchSize, 10);
          if (!isNaN(batch) && batch >= 1 && batch <= 50) {
            this.batchSizeElem.value = batch;
          }
        }
      } catch (error) {
        console.error('[AutoWheel] Error loading settings:', error);
      }
    }

    _saveSettings() {
      try {
        if (!this.spinDelayElem || !this.batchSizeElem) return;
        
        const spinDelay = parseInt(this.spinDelayElem.value, 10);
        const batchSize = parseInt(this.batchSizeElem.value, 10);
        
        if (!isNaN(spinDelay) && spinDelay >= 5 && spinDelay <= 300) {
          localStorage.setItem('autoWheel.spinDelay', spinDelay.toString());
        }
        
        if (!isNaN(batchSize) && batchSize >= 1 && batchSize <= 50) {
          localStorage.setItem('autoWheel.batchSize', batchSize.toString());
        }
      } catch (error) {
        console.error('[AutoWheel] Error saving settings:', error);
      }
    }

    _debounceSave() {
      if (this._saveDebounceTimer) {
        clearTimeout(this._saveDebounceTimer);
      }
      this._saveDebounceTimer = setTimeout(() => {
        this._saveSettings();
      }, 500);
    }

    _loadPausedState() {
      try {
        if (this._accounts.length === 0) {
          return;
        }
        
        const paused = localStorage.getItem('autoWheel.paused');
        if (paused !== 'true') {
          return;
        }
        
        const savedCurrentAccount = localStorage.getItem('autoWheel.currentAccount');
        const savedCurrentBatch = localStorage.getItem('autoWheel.currentBatch');
        const savedAccountsInCurrentBatch = localStorage.getItem('autoWheel.accountsInCurrentBatch');
        const savedTotalAccounts = localStorage.getItem('autoWheel.totalAccounts');
        
        if (savedCurrentAccount === null || savedCurrentBatch === null || 
            savedAccountsInCurrentBatch === null || savedTotalAccounts === null) {
          this._clearPausedState();
          return;
        }
        
        const currentAccount = parseInt(savedCurrentAccount, 10);
        const currentBatch = parseInt(savedCurrentBatch, 10);
        const accountsInCurrentBatch = parseInt(savedAccountsInCurrentBatch, 10);
        const totalAccounts = parseInt(savedTotalAccounts, 10);
        
        if (isNaN(currentAccount) || isNaN(currentBatch) || 
            isNaN(accountsInCurrentBatch) || isNaN(totalAccounts)) {
          this._clearPausedState();
          return;
        }
        
        if (totalAccounts !== this._accounts.length || 
            currentAccount < 0 || currentAccount >= this._accounts.length) {
          this._clearPausedState();
          return;
        }
        
        this._isPaused = true;
        this._currentAccount = currentAccount;
        this._currentBatch = currentBatch;
        this._accountsInCurrentBatch = accountsInCurrentBatch;
        this._isRunning = true;
        this._updateButtonVisibility();
        if (this.spinDelayElem) this.spinDelayElem.disabled = true;
        if (this.batchSizeElem) this.batchSizeElem.disabled = true;
        if (this.startAccountElem) this.startAccountElem.disabled = true;
        this._updateProgressDisplay();
        this._showStatus('Paused - Click Resume to continue', '');
      } catch (error) {
        console.error('[AutoWheel] Error loading paused state:', error);
        this._clearPausedState();
      }
    }

    _clearPausedState() {
      try {
        localStorage.removeItem('autoWheel.paused');
        localStorage.removeItem('autoWheel.currentAccount');
        localStorage.removeItem('autoWheel.currentBatch');
        localStorage.removeItem('autoWheel.accountsInCurrentBatch');
        localStorage.removeItem('autoWheel.totalAccounts');
      } catch (error) {
        console.error('[AutoWheel] Error clearing paused state:', error);
      }
    }

    setAccounts(accounts) {
      this._accounts = (accounts || []).sort((a, b) => {
        if (a.pinned && !b.pinned) return -1;
        if (!a.pinned && b.pinned) return 1;
        return 0;
      });
      
      this._totalAccounts = this._accounts.length;
      this._updateStartAccountDropdown();
      
      if (this._accounts.length > 0 && !this._isRunning) {
        this._loadPausedState();
      }
      
      this._updateProgressDisplay();
    }

    _onAccountsUpdated(accounts) {
      this.setAccounts(accounts);
    }

    _updateStartAccountDropdown() {
      if (!this.startAccountElem) return;
      
      const currentValue = this.startAccountElem.value;

      this.startAccountElem.innerHTML = '';

      const firstOption = document.createElement('option');
      firstOption.value = '0';
      firstOption.textContent = 'First Account';
      this.startAccountElem.appendChild(firstOption);
      
      this._accounts.forEach((account, index) => {
        const option = document.createElement('option');
        option.value = index.toString();
        const displayName = account.username.length > 12 ? 
          account.username.substring(0, 12) + '...' : 
          account.username;
        option.textContent = `${index + 1}. ${displayName}${account.pinned ? ' 📌' : ''}`;
        option.title = account.username;
        this.startAccountElem.appendChild(option);
      });
      
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

    _handlePauseClick() {
      if (this._isPaused) {
        this._resumeAutoWheel();
      } else if (this._isRunning) {
        this._pauseAutoWheel();
      }
    }

    _updateButtonVisibility() {
      if (!this.startButtonElem || !this.pauseButtonElem) return;
      
      if (this._isRunning) {
        this.startButtonElem.classList.add('stop-button');
        this.startButtonElem.classList.remove('start-button');
        this.startButtonElem.textContent = 'Stop';
        this.pauseButtonElem.classList.remove('hidden');
        if (this._isPaused) {
          this.pauseButtonElem.textContent = 'Resume';
        } else {
          this.pauseButtonElem.textContent = 'Pause';
        }
      } else {
        this.startButtonElem.classList.add('start-button');
        this.startButtonElem.classList.remove('stop-button');
        this.startButtonElem.textContent = 'Start';
        this.pauseButtonElem.classList.add('hidden');
      }
    }

    _pauseAutoWheel() {
      if (!this._isRunning || this._isPaused) return;
      
      this._isPaused = true;
      
      try {
        localStorage.setItem('autoWheel.paused', 'true');
        localStorage.setItem('autoWheel.currentAccount', this._currentAccount.toString());
        localStorage.setItem('autoWheel.currentBatch', this._currentBatch.toString());
        localStorage.setItem('autoWheel.accountsInCurrentBatch', this._accountsInCurrentBatch.toString());
        localStorage.setItem('autoWheel.totalAccounts', this._totalAccounts.toString());
      } catch (error) {
        console.error('[AutoWheel] Error saving paused state:', error);
      }
      
      if (this._timer) {
        clearTimeout(this._timer);
        this._timer = null;
      }
      
      this._updateButtonVisibility();
      this._updateProgressDisplay();
      this._showStatus('Paused - Click Resume to continue', '');
      this.timerTextElem.textContent = '';
    }

    async _resumeAutoWheel() {
      if (!this._isPaused || !this._isRunning) return;
      
      const savedCurrentAccount = localStorage.getItem('autoWheel.currentAccount');
      const savedCurrentBatch = localStorage.getItem('autoWheel.currentBatch');
      const savedAccountsInCurrentBatch = localStorage.getItem('autoWheel.accountsInCurrentBatch');
      const savedTotalAccounts = localStorage.getItem('autoWheel.totalAccounts');
      
      if (savedCurrentAccount !== null && savedCurrentBatch !== null && 
          savedAccountsInCurrentBatch !== null && savedTotalAccounts !== null) {
        const currentAccount = parseInt(savedCurrentAccount, 10);
        const currentBatch = parseInt(savedCurrentBatch, 10);
        const accountsInCurrentBatch = parseInt(savedAccountsInCurrentBatch, 10);
        const totalAccounts = parseInt(savedTotalAccounts, 10);
        
        if (!isNaN(currentAccount) && !isNaN(currentBatch) && 
            !isNaN(accountsInCurrentBatch) && !isNaN(totalAccounts)) {
          
          if (totalAccounts === this._accounts.length && 
              currentAccount >= 0 && currentAccount < this._accounts.length) {
            this._currentAccount = currentAccount;
            this._currentBatch = currentBatch;
            this._accountsInCurrentBatch = accountsInCurrentBatch;
          } else {
            this._showStatus('Account list changed. Resuming from saved position may be invalid.', 'error');
          }
        }
      }
      
      this._clearPausedState();
      this._isPaused = false;
      this._updateButtonVisibility();
      this.wheelIconElem.classList.add('spinning');
      this._updateProgressDisplay();
      this._showStatus('Resuming auto wheel...', '');
      
      try {
        await this._runAutoWheelCycle();
      } catch (error) {
        console.error('[AutoWheel] Error during auto wheel resume:', error);
        this._showStatus(`Error: ${error.message}`, 'error');
        this._stopAutoWheel();
      }
    }

    async _startAutoWheel() {
      if (this._accounts.length === 0) {
        this._showStatus('No accounts available. Please import accounts first.', 'error');
        return;
      }

      if (this._isPaused) {
        await this._resumeAutoWheel();
        return;
      }

      this._clearPausedState();
      this._isPaused = false;
      this._isRunning = true;
      this._currentAccount = parseInt(this.startAccountElem.value) || 0;
      this._currentBatch = 0;
      this._accountsInCurrentBatch = 0;
      
      this._saveSettings();
      this._updateButtonVisibility();
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
      this._isPaused = false;
      
      if (this._timer) {
        clearTimeout(this._timer);
        this._timer = null;
      }
      
      this._clearPausedState();
      this._updateButtonVisibility();
      this.wheelIconElem.classList.remove('spinning');
      this.spinDelayElem.disabled = false;
      this.batchSizeElem.disabled = false;
      this.startAccountElem.disabled = false;
      
      this._updateProgressDisplay();
      this._showStatus('Auto wheel stopped', '');
      this.timerTextElem.textContent = '';
      
      this.dispatchEvent(new CustomEvent('auto-wheel-stopped', {
        bubbles: true,
        composed: true
      }));
    }

    async _runAutoWheelCycle() {
      while (this._isRunning && !this._isPaused && this._currentAccount < this._accounts.length) {
        const batchSize = parseInt(this.batchSizeElem.value) || 10;

        if (this._accountsInCurrentBatch >= batchSize) {
          this._showStatus('Taking 5-minute break after batch...', '');
          await this._waitWithTimer(5 * 60 * 1000);

          if (this._isPaused || !this._isRunning) return;

          this._currentBatch++;
          this._accountsInCurrentBatch = 0;
        }

        if (this._isPaused || !this._isRunning) return;

        const account = this._accounts[this._currentAccount];
        this._showStatus(`Logging in: ${account.username}`, '');

        try {
          document.dispatchEvent(new CustomEvent('account-selected', {
            detail: { username: account.username, password: account.password },
            bubbles: true,
            composed: true
          }));

          await this._waitWithTimer(1000);

          if (this._isPaused || !this._isRunning) return;

          this.dispatchEvent(new CustomEvent('auto-wheel-login', {
            detail: { account },
            bubbles: true,
            composed: true
          }));

          await this._waitWithTimer(3000);

          if (this._isPaused || !this._isRunning) return;

          const currentUsername = document.querySelector('input[type="text"]')?.value;

          if (currentUsername !== account.username) {
            console.warn(`[AutoWheel] WARNING: Expected username "${account.username}" but field shows "${currentUsername}"`);
          }

          if (this._isPaused || !this._isRunning) return;

          const spinDelay = (parseInt(this.spinDelayElem.value) || 30) * 1000;
          this._showStatus(`Spinning wheel for ${account.username}...`, '');
          await this._waitWithTimer(spinDelay);

          if (this._isPaused || !this._isRunning) return;

          this._showStatus(`Logging out: ${account.username}`, '');
          this.dispatchEvent(new CustomEvent('auto-wheel-logout', {
            detail: { account },
            bubbles: true,
            composed: true
          }));

          await this._waitWithTimer(3000);

          if (this._isPaused || !this._isRunning) return;

          this._currentAccount++;
          this._accountsInCurrentBatch++;
          this._updateProgressDisplay();

          await this._waitWithTimer(2000);

          if (this._isPaused || !this._isRunning) return;
        } catch (error) {
          throw new Error(`Failed to process ${account.username}: ${error.message}`);
        }
      }

      if (this._isRunning && !this._isPaused && this._currentAccount >= this._accounts.length) {
        this._showStatus('Auto wheel completed!', 'success');
        this._stopAutoWheel();
      }
    }

    _waitWithTimer(ms) {
      return new Promise((resolve) => {
        const startTime = Date.now();
        const endTime = startTime + ms;
        
        const updateTimer = () => {
          if (!this._isRunning || this._isPaused) {
            this.timerTextElem.textContent = '';
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
      
      const pinnedCount = this._accounts.filter(acc => acc.pinned).length;
      const pinnedText = pinnedCount > 0 ? ` (📌${pinnedCount})` : '';
      
      if (this._isPaused) {
        const currentAccount = this._accounts[this._currentAccount];
        const currentAccountText = currentAccount ? `${currentAccount.username}${currentAccount.pinned ? ' 📌' : ''}` : 'Unknown';
        const remaining = this._totalAccounts - this._currentAccount;
        this.progressTextElem.textContent = `⏸️ PAUSED: ${currentAccountText} - ${this._currentAccount + 1}/${this._totalAccounts} (${remaining} remaining)${pinnedText}`;
      } else if (this._isRunning) {
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