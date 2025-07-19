"use strict";

(() => {
  const COMPONENT_TAG_NAME = 'import-button';

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
            display: inline-block;
          }

          .import-button, .delete-button {
            padding: 8px 16px;
            background-color: var(--theme-button-bg, var(--theme-primary, #e83d52));
            color: var(--theme-button-text, white);
            border: 2px solid var(--theme-button-border, var(--theme-secondary, rgba(232, 61, 82, 0.3)));
            border-radius: 8px;
            cursor: pointer;
            font-family: CCDigitalDelivery;
            font-size: 12px;
            font-weight: bold;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 6px;
            user-select: none;
            text-shadow: var(--theme-text-shadow, none);
          }

          .delete-button {
            background-color: #dc3545;
            border-color: rgba(220, 53, 69, 0.3);
          }

          .import-button:hover, .delete-button:hover {
            background-color: var(--theme-hover-border, rgba(232, 61, 82, 0.8));
            transform: translateY(-1px);
            box-shadow: 0 4px 12px var(--theme-shadow, rgba(252, 93, 93, 0.3));
          }
          
          .delete-button:hover {
            background-color: #c82333;
          }
          
          :host(.light-theme) .import-button {
            background-color: var(--light-theme-bg) !important;
            border-color: rgba(0, 0, 0, 0.3) !important;
            color: #333333 !important;
            box-shadow: 0 0 0 1px rgba(0, 0, 0, 0.3) !important;
            text-shadow: 0 1px 1px rgba(0, 0, 0, 0.5) !important;
          }
          
          :host(.light-theme) .import-button:hover {
            background-color: var(--light-theme-hover-bg) !important;
          }

          .import-button:active {
            transform: translateY(0);
          }

          .import-button.disabled {
            opacity: 0.6;
            cursor: not-allowed;
            pointer-events: none;
          }

          .import-icon {
            font-size: 14px;
          }

          .hidden-file-input {
            display: none;
          }

          .status-text {
            font-size: 10px;
            margin-top: 4px;
            color: var(--theme-primary, #e83d52);
            font-family: CCDigitalDelivery;
            text-align: center;
            min-height: 12px;
          }

          .status-text.success {
            color: #28a745;
          }

          .status-text.error {
            color: #dc3545;
          }
        </style>
        <div style="display: flex; gap: 10px;">
          <div class="import-button" title="Import accounts from .txt file (username:password format)">
            <span class="import-icon">📁</span>
            <span>Import Accounts</span>
          </div>
          <div class="delete-button" title="Delete all imported accounts">
            <span class="import-icon">🗑️</span>
            <span>Delete Accounts</span>
          </div>
          <div class="status-text"></div>
          <input type="file" class="hidden-file-input" accept=".txt" />
        </div>
      `;
      
      this._importing = false;
    }

    connectedCallback() {
      this.importButtonElem = this.shadowRoot.querySelector('.import-button');
      this.deleteButtonElem = this.shadowRoot.querySelector('.delete-button');
      this.fileInputElem = this.shadowRoot.querySelector('.hidden-file-input');
      this.statusTextElem = this.shadowRoot.querySelector('.status-text');

      if (this.importButtonElem) {
        this.importButtonElem.addEventListener('click', () => this._handleImportClick());
      }

      if (this.deleteButtonElem) {
        this.deleteButtonElem.addEventListener('click', () => this._handleDeleteClick());
      }

      if (this.fileInputElem) {
        this.fileInputElem.addEventListener('change', (event) => this._handleFileSelected(event));
      }

      // Apply theme on connect
      if (this._currentThemeKey) {
        this._applyTheme(this._currentThemeKey);
      }
    }

    disconnectedCallback() {
      // Cleanup logic if needed
    }

    updateTheme(themeKey) {
      this._currentThemeKey = themeKey;
      this._applyTheme(themeKey);
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
          
          // Set CSS custom properties on the shadow root host
          this.style.setProperty('--light-theme-bg', darkenedBg);
          this.style.setProperty('--light-theme-hover-bg', hoverBg);
          this.classList.add('light-theme');
        } else {
          this.classList.remove('light-theme');
          this.style.removeProperty('--light-theme-bg');
          this.style.removeProperty('--light-theme-hover-bg');
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

    _handleImportClick() {
      if (this._importing) return;
      
      this.fileInputElem.click();
    }

    async _handleDeleteClick() {
      if (this._importing) return;

      const confirmation = confirm('Are you sure you want to delete all imported accounts? This action cannot be undone.');
      if (!confirmation) return;

      this._importing = true;
      this.deleteButtonElem.classList.add('disabled');
      this.statusTextElem.textContent = 'Deleting accounts...';
      this.statusTextElem.className = 'status-text';

      try {
        const result = await window.ipc.invoke('delete-all-accounts');
        
        if (result.success) {
          this.statusTextElem.textContent = `✓ ${result.deleted} accounts deleted`;
          this.statusTextElem.className = 'status-text success';
          
          this.dispatchEvent(new CustomEvent('accounts-deleted', {
            bubbles: true,
            composed: true
          }));
        } else {
          throw new Error(result.error || 'Deletion failed');
        }
      } catch (error) {
        console.error('[ImportButton] Deletion error:', error);
        this.statusTextElem.textContent = `✗ ${error.message}`;
        this.statusTextElem.className = 'status-text error';
        
        this.dispatchEvent(new CustomEvent('delete-error', {
          detail: { message: error.message },
          bubbles: true,
          composed: true
        }));
      } finally {
        this._importing = false;
        this.deleteButtonElem.classList.remove('disabled');
        
        setTimeout(() => {
          if (this.statusTextElem) {
            this.statusTextElem.textContent = '';
            this.statusTextElem.className = 'status-text';
          }
        }, 3000);
      }
    }

    async _handleFileSelected(event) {
      const file = event.target.files[0];
      if (!file) return;

      this._importing = true;
      this.importButtonElem.classList.add('disabled');
      this.statusTextElem.textContent = 'Reading file...';
      this.statusTextElem.className = 'status-text';

      try {
        const fileContent = await this._readFile(file);
        const accounts = this._parseAccountsFromText(fileContent);
        
        if (accounts.length === 0) {
          throw new Error('No valid accounts found in file');
        }

        this.statusTextElem.textContent = `Importing ${accounts.length} accounts...`;
        
        const result = await this._importAccounts(accounts);
        
        if (result.success) {
          this.statusTextElem.textContent = `✓ Imported ${result.imported} accounts`;
          this.statusTextElem.className = 'status-text success';
          
          // Dispatch event to refresh account list
          this.dispatchEvent(new CustomEvent('accounts-imported', {
            detail: { 
              imported: result.imported,
              total: accounts.length,
              accounts: result.accounts
            },
            bubbles: true,
            composed: true
          }));
        } else {
          throw new Error(result.error || 'Import failed');
        }
      } catch (error) {
        console.error('[ImportButton] Import error:', error);
        this.statusTextElem.textContent = `✗ ${error.message}`;
        this.statusTextElem.className = 'status-text error';
        
        this.dispatchEvent(new CustomEvent('import-error', {
          detail: { message: error.message },
          bubbles: true,
          composed: true
        }));
      } finally {
        this._importing = false;
        this.importButtonElem.classList.remove('disabled');
        
        // Clear file input
        this.fileInputElem.value = '';
        
        // Clear status after 3 seconds
        setTimeout(() => {
          if (this.statusTextElem) {
            this.statusTextElem.textContent = '';
            this.statusTextElem.className = 'status-text';
          }
        }, 3000);
      }
    }

    _readFile(file) {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = (e) => resolve(e.target.result);
        reader.onerror = () => reject(new Error('Failed to read file'));
        reader.readAsText(file);
      });
    }

    _parseAccountsFromText(content) {
      const lines = content.split('\n').map(line => line.trim()).filter(line => line.length > 0);
      const accounts = [];
      
      for (const line of lines) {
        // Support both username:password and username password formats
        const colonMatch = line.match(/^([^:]+):(.+)$/);
        const spaceMatch = line.match(/^(\S+)\s+(.+)$/);
        
        if (colonMatch) {
          const [, username, password] = colonMatch;
          if (username && password) {
            accounts.push({
              username: username.trim(),
              password: password.trim()
            });
          }
        } else if (spaceMatch) {
          const [, username, password] = spaceMatch;
          if (username && password) {
            accounts.push({
              username: username.trim(),
              password: password.trim()
            });
          }
        }
      }
      
      return accounts;
    }

    async _importAccounts(accounts) {
      try {
        const result = await window.ipc.invoke('import-accounts', accounts);
        return result;
      } catch (error) {
        console.error('[ImportButton] IPC Error importing accounts:', error);
        return { success: false, error: 'IPC Error importing accounts' };
      }
    }
  });
})();
