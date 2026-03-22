"use strict";

(() => {
  const COMPONENT_TAG_NAME = 'account-management-panel';

  if (customElements.get(COMPONENT_TAG_NAME)) {
    console.warn(`Custom element ${COMPONENT_TAG_NAME} is already defined.`);
    return;
  }

  customElements.define(COMPONENT_TAG_NAME, class extends HTMLElement {
    constructor() {
      super();
      this.attachShadow({ mode: 'open' }).innerHTML = `
        <link rel="stylesheet" href="components/screens/AccountManagementPanel.css">
        <div id="panel-container">
          <div class="account-add-button" title="Add Account">
            <span>+</span>
          </div>
          <div id="saved-accounts-list">
          </div>
        </div>
      `;
      this._currentThemeKey = null;
      this._boundRemoveContextMenu = () => this._removeContextMenu();
    }

    connectedCallback() {
      this.addAccountButtonElem = this.shadowRoot.querySelector(".account-add-button");
      this.savedAccountsListElem = this.shadowRoot.getElementById("saved-accounts-list");

      if (this.addAccountButtonElem) {
        this.addAccountButtonElem.addEventListener('click', () => this._handleAddAccountClick());
      }
      
      this._syncDarkModeFromParent();
      this._setupDarkModeObserver();
      
      this.loadAndDisplaySavedAccounts();

      this.shadowRoot.addEventListener('contextmenu', (event) => this._handlePanelContextMenu(event));
      document.addEventListener('click', this._boundRemoveContextMenu);
    }

    disconnectedCallback() {
      if (this._darkModeObserver) {
        this._darkModeObserver.disconnect();
        this._darkModeObserver = null;
      }
      document.removeEventListener('click', this._boundRemoveContextMenu);
    }

    updateTheme(themeKey) {
      this._currentThemeKey = themeKey;
      this._applyThemeToSlots();
    }

    setDarkMode(isDarkMode) {
      if (isDarkMode) {
        this.classList.add('dark-mode');
      } else {
        this.classList.remove('dark-mode');
      }
    }

    _findParentLoginScreen() {
      const rootNode = this.getRootNode();
      if (rootNode instanceof ShadowRoot && rootNode.host) {
        if (rootNode.host.tagName === 'AJD-LOGIN-SCREEN') {
          return rootNode.host;
        }
      }
      
      let current = this.parentNode;
      while (current) {
        if (current.tagName === 'AJD-LOGIN-SCREEN') {
          return current;
        }
        if (current.getRootNode) {
          const currentRoot = current.getRootNode();
          if (currentRoot instanceof ShadowRoot && currentRoot.host && currentRoot.host.tagName === 'AJD-LOGIN-SCREEN') {
            return currentRoot.host;
          }
        }
        if (current === document || current === document.body || current === document.documentElement) {
          break;
        }
        current = current.parentNode;
      }
      
      return null;
    }

    _syncDarkModeFromParent() {
      const loginScreen = this._findParentLoginScreen();
      if (loginScreen) {
        const isDarkMode = loginScreen.classList.contains('dark-mode');
        this.setDarkMode(isDarkMode);
      }
    }

    _setupDarkModeObserver() {
      const loginScreen = this._findParentLoginScreen();
      if (!loginScreen) {
        return;
      }

      if (this._darkModeObserver) {
        this._darkModeObserver.disconnect();
      }

      this._darkModeObserver = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
          if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
            const isDarkMode = loginScreen.classList.contains('dark-mode');
            this.setDarkMode(isDarkMode);
          }
        });
      });

      this._darkModeObserver.observe(loginScreen, {
        attributes: true,
        attributeFilter: ['class']
      });
    }

    saveAccountWithCredentials(credentials) {
      this._saveAccount(credentials.username, credentials.password);
    }
    
    handleAddAccountFailed(errorMessage) {
        console.error(`[AccountManagementPanel] Add account failed: ${errorMessage}`);
        this.dispatchEvent(new CustomEvent('account-operation-error', {
            detail: { message: errorMessage },
            bubbles: true,
            composed: true
        }));
    }


    _handleAddAccountClick() {
      this.dispatchEvent(new CustomEvent('request-credentials-for-add', {
        bubbles: true,
        composed: true
      }));
    }

    async _saveAccount(username, password) {
      try {
        const result = await window.ipc.invoke('save-account', { username, password });
        if (result.success) {
          this._displaySavedAccounts(result.accounts);
          document.dispatchEvent(new CustomEvent('accounts-updated', {
            detail: { accounts: result.accounts },
            bubbles: true,
            composed: true
          }));
        } else {
          console.error('[AccountManagementPanel] Error saving account:', result.error);
          this.dispatchEvent(new CustomEvent('account-operation-error', {
            detail: { message: result.error || "Failed to save account." },
            bubbles: true,
            composed: true
          }));
        }
      } catch (error) {
        console.error('[AccountManagementPanel] IPC Error saving account:', error);
        this.dispatchEvent(new CustomEvent('account-operation-error', {
          detail: { message: "IPC Error saving account." },
          bubbles: true,
          composed: true
        }));
      }
    }

    async loadAndDisplaySavedAccounts() {
      try {
        const accounts = await window.ipc.invoke('get-saved-accounts');
        this._displaySavedAccounts(accounts || []);
      } catch (error) {
        console.error('[AccountManagementPanel] Error loading saved accounts:', error);
        this._displaySavedAccounts([]);
         this.dispatchEvent(new CustomEvent('account-operation-error', { 
            detail: { message: "Error loading saved accounts." },
            bubbles: true,
            composed: true
          }));
      }
    }

    _displaySavedAccounts(accounts) {
      if (!this.savedAccountsListElem) return;
      this.savedAccountsListElem.innerHTML = '';

      const sortedAccounts = accounts.sort((a, b) => {
        if (a.pinned && !b.pinned) return -1;
        if (!a.pinned && b.pinned) return 1;
        return 0;
      });

      const MIN_DISPLAY_SLOTS = 7;
      const totalSlots = Math.max(MIN_DISPLAY_SLOTS, sortedAccounts.length);

      for (let i = 0; i < totalSlots; i++) {
        const slot = document.createElement('div');
        slot.classList.add('saved-account-slot');
        if (sortedAccounts[i]) {
          const account = sortedAccounts[i];
          slot.textContent = account.username.substring(0, 2).toUpperCase();
          slot.title = `${account.username}${account.pinned ? ' (Pinned)' : ''}`;
          slot.dataset.username = account.username;
          
          if (account.pinned) {
            slot.classList.add('pinned');
            const pinIcon = document.createElement('div');
            pinIcon.classList.add('pin-indicator');
            pinIcon.textContent = '\u{1F4CC}';
            slot.appendChild(pinIcon);
          }
          
          slot.addEventListener('click', () => this._handleAccountSelect(account));
          slot.addEventListener('contextmenu', (event) => this._handleAccountContextMenu(event, account));
        } else {
          slot.classList.add('empty');
          slot.innerHTML = `&nbsp;`;
        }
        this.savedAccountsListElem.appendChild(slot);
      }
      this._applyThemeToSlots();
    }
    
    _applyThemeToSlot(slotElement) {
        if (!slotElement) {
            return;
        }

        if (this._currentThemeKey === 'banana.png' || this._currentThemeKey === 'pineapple.png') {
            slotElement.style.setProperty('color', '#4A4A4A', 'important');
        } else {
            slotElement.style.setProperty('color', '', '');
        }
    }

    _applyThemeToSlots() {
        if (this.savedAccountsListElem) {
            const slots = this.savedAccountsListElem.querySelectorAll('.saved-account-slot:not(.empty)');
            slots.forEach(slot => this._applyThemeToSlot(slot));
        }

        if (!this.addAccountButtonElem && this.shadowRoot) {
            this.addAccountButtonElem = this.shadowRoot.querySelector(".account-add-button");
        }

        if (this.addAccountButtonElem) {
            if (this._currentThemeKey === 'banana.png' || this._currentThemeKey === 'pineapple.png') {
                this.addAccountButtonElem.style.setProperty('color', '#4A4A4A', 'important');
                this.addAccountButtonElem.style.setProperty('borderColor', '#4A4A4A', 'important');
            } else {
                this.addAccountButtonElem.style.setProperty('color', '');
                this.addAccountButtonElem.style.setProperty('borderColor', '');
            }
        }
    }

    _handleAccountSelect(account) {
      this.dispatchEvent(new CustomEvent('account-selected', {
        detail: { username: account.username, password: account.password },
        bubbles: true,
        composed: true
      }));
    }

    _handlePanelContextMenu(event) {
      if (event.target === this.shadowRoot.getElementById('panel-container') || event.target.classList.contains('account-add-button') || event.target.classList.contains('empty')) {
        event.preventDefault();
        this._removeContextMenu();

        const menu = this._createContextMenuBase(event.clientX, event.clientY);
        const ul = menu.querySelector('ul');

        const importItem = document.createElement('li');
        importItem.textContent = 'Import Accounts';
        importItem.addEventListener('click', () => {
          this._removeContextMenu();
          this._triggerImportAccounts();
        });
        ul.appendChild(importItem);

        const deleteNonPinnedItem = document.createElement('li');
        deleteNonPinnedItem.textContent = 'Delete Non-Pinned';
        deleteNonPinnedItem.addEventListener('click', async () => {
          this._removeContextMenu();
          const confirmed = window.confirm('Delete all NON-pinned accounts? Pinned accounts will be kept.');
          if (!confirmed) return;
          try {
            const result = await window.ipc.invoke('delete-all-accounts');
            if (result.success) {
              this._displaySavedAccounts(result.accounts || []);
              document.dispatchEvent(new CustomEvent('accounts-updated', {
                detail: { accounts: result.accounts || [] },
                bubbles: true,
                composed: true
              }));
            }
          } catch (e) {}
        });
        ul.appendChild(deleteNonPinnedItem);

        ul.appendChild(document.createElement('li')).classList.add('separator');

        const openCacheItem = document.createElement('li');
        openCacheItem.textContent = 'Open User Cache File';
        openCacheItem.addEventListener('click', async () => {
            await window.ipc.invoke('open-user-cache-file');
            this._removeContextMenu();
        });
        ul.appendChild(openCacheItem);

        this.shadowRoot.appendChild(menu);
        this._activeContextMenu = menu;
      }
    }

    _triggerImportAccounts() {
      const fileInput = document.createElement('input');
      fileInput.type = 'file';
      fileInput.accept = '.txt';
      fileInput.style.display = 'none';
      fileInput.addEventListener('change', async (e) => {
        const file = e.target.files[0];
        if (!file) return;
        try {
          const text = await file.text();
          const lines = text.split('\n').filter(l => l.trim());
          const accounts = [];
          for (const line of lines) {
            const trimmed = line.trim();
            if (!trimmed) continue;
            let username, password;
            if (trimmed.includes(':')) {
              [username, password] = trimmed.split(':').map(s => s.trim());
            } else {
              const parts = trimmed.split(/\s+/);
              if (parts.length >= 2) {
                username = parts[0];
                password = parts.slice(1).join(' ');
              }
            }
            if (username && password) {
              accounts.push({ username, password });
            }
          }
          if (accounts.length === 0) return;
          const result = await window.ipc.invoke('import-accounts', accounts);
          if (result.success) {
            this.loadAndDisplaySavedAccounts();
            document.dispatchEvent(new CustomEvent('accounts-updated', {
              detail: { accounts: result.accounts || [] },
              bubbles: true,
              composed: true
            }));
          }
        } catch (e) {}
        fileInput.remove();
      });
      document.body.appendChild(fileInput);
      fileInput.click();
    }
    
    _handleAccountContextMenu(event, account) {
      event.preventDefault();
      event.stopPropagation();
      this._removeContextMenu();

      if (!account || !account.username) return;

      const menu = this._createContextMenuBase(event.clientX, event.clientY);
      const ul = menu.querySelector('ul');

      const pinItem = document.createElement('li');
      pinItem.textContent = account.pinned ? `Unpin "${account.username}"` : `Pin "${account.username}" to Top`;
      pinItem.addEventListener('click', async () => {
        try {
          const result = await window.ipc.invoke('toggle-pin-account', account.username);
          if (result.success) {
            this._displaySavedAccounts(result.accounts);
            document.dispatchEvent(new CustomEvent('accounts-updated', {
              detail: { accounts: result.accounts },
              bubbles: true,
              composed: true
            }));
          } else {
            console.error('[AccountManagementPanel] Error toggling pin status:', result.error);
            this.dispatchEvent(new CustomEvent('account-operation-error', { 
              detail: { message: result.error || "Failed to toggle pin status." },
              bubbles: true,
              composed: true
            }));
          }
        } catch (error) {
          console.error('[AccountManagementPanel] IPC Error toggling pin status:', error);
          this.dispatchEvent(new CustomEvent('account-operation-error', { 
              detail: { message: "IPC Error toggling pin status." },
              bubbles: true,
              composed: true
          }));
        }
        this._removeContextMenu();
      });

      const deleteItem = document.createElement('li');
      deleteItem.textContent = `Delete "${account.username}"`;
      deleteItem.addEventListener('click', async () => {
        const confirmDelete = window.confirm(`Are you sure you want to delete the saved account "${account.username}"?`);
        if (confirmDelete) {
          try {
            const result = await window.ipc.invoke('delete-account', account.username);
            if (result.success) {
              this._displaySavedAccounts(result.accounts);
              document.dispatchEvent(new CustomEvent('accounts-updated', {
                detail: { accounts: result.accounts },
                bubbles: true,
                composed: true
              }));
            } else {
              console.error('[AccountManagementPanel] Error deleting account:', result.error);
              this.dispatchEvent(new CustomEvent('account-operation-error', { 
                detail: { message: result.error || "Failed to delete account." },
                bubbles: true,
                composed: true
              }));
            }
          } catch (error) {
            console.error('[AccountManagementPanel] IPC Error deleting account:', error);
            this.dispatchEvent(new CustomEvent('account-operation-error', { 
                detail: { message: "IPC Error deleting account." },
                bubbles: true,
                composed: true
            }));
          }
        }
        this._removeContextMenu();
      });

      const openCacheItem = document.createElement('li');
      openCacheItem.textContent = 'Open User Cache File';
      openCacheItem.addEventListener('click', async () => {
        await window.ipc.invoke('open-user-cache-file');
        this._removeContextMenu();
      });
      
      ul.appendChild(pinItem);
      ul.appendChild(document.createElement('li')).classList.add('separator');
      ul.appendChild(deleteItem);
      ul.appendChild(document.createElement('li')).classList.add('separator');
      ul.appendChild(openCacheItem);

      this.shadowRoot.appendChild(menu);
      this._activeContextMenu = menu;
    }

    _createContextMenuBase(x, y) {
      const menu = document.createElement('div');
      menu.classList.add('custom-context-menu');
      menu.style.left = `${x}px`;
      menu.style.top = `${y}px`;
      
      const ul = document.createElement('ul');
      menu.appendChild(ul);
      return menu;
    }

    _removeContextMenu() {
      if (this._activeContextMenu && this._activeContextMenu.parentNode) {
        this._activeContextMenu.remove();
      }
      this._activeContextMenu = null;
    }
  });
})();
