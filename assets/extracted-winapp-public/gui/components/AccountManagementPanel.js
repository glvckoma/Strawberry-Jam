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
        <link rel="stylesheet" href="components/AccountManagementPanel.css">
        <div id="panel-container">
          <div class="account-add-button" title="Add Account">
            <span>+</span>
          </div>
          <div id="saved-accounts-list">
            <!-- Saved account slots will be dynamically added here -->
          </div>
        </div>
      `;
      this._currentThemeKey = null; // To store the current theme
    }

    connectedCallback() {
      this.addAccountButtonElem = this.shadowRoot.querySelector(".account-add-button");
      this.savedAccountsListElem = this.shadowRoot.getElementById("saved-accounts-list");

      if (this.addAccountButtonElem) {
        this.addAccountButtonElem.addEventListener('click', () => this._handleAddAccountClick());
      }
      // Initial data loading
      this.loadAndDisplaySavedAccounts();

      // Context menu listener for the panel
      this.shadowRoot.addEventListener('contextmenu', (event) => this._handlePanelContextMenu(event));
      document.addEventListener('click', () => this._removeContextMenu()); // Remove on click outside
    }

    disconnectedCallback() {
      // Cleanup logic if needed
    }

    // --- Public methods / Attribute handling ---
    updateTheme(themeKey) {
      this._currentThemeKey = themeKey;
      // Re-apply styles to existing slots if necessary
      this._applyThemeToSlots();
    }

    setDarkMode(isDarkMode) {
      // Apply dark mode class to host element
      if (isDarkMode) {
        this.classList.add('dark-mode');
      } else {
        this.classList.remove('dark-mode');
      }
    }

    saveAccountWithCredentials(credentials) {
      this._saveAccount(credentials.username, credentials.password);
    }
    
    handleAddAccountFailed(errorMessage) {
        // Placeholder for showing an error, e.g., by dispatching an event
        console.error(`[AccountManagementPanel] Add account failed: ${errorMessage}`);
        this.dispatchEvent(new CustomEvent('account-operation-error', {
            detail: { message: errorMessage },
            bubbles: true,
            composed: true
        }));
    }


    // --- Internal Account Management Methods ---
    _handleAddAccountClick() {
      // Request credentials from LoginScreen
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
          // Dispatch accounts-updated event for auto wheel component
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
        this._displaySavedAccounts([]); // Display empty slots on error
         this.dispatchEvent(new CustomEvent('account-operation-error', { 
            detail: { message: "Error loading saved accounts." },
            bubbles: true,
            composed: true
          }));
      }
    }

    _displaySavedAccounts(accounts) {
      if (!this.savedAccountsListElem) return;
      this.savedAccountsListElem.innerHTML = ''; // Clear existing slots

      // Sort accounts: pinned accounts first, then regular accounts
      const sortedAccounts = accounts.sort((a, b) => {
        if (a.pinned && !b.pinned) return -1;
        if (!a.pinned && b.pinned) return 1;
        return 0; // Maintain relative order for accounts with same pin status
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
          
          // Add pinned indicator
          if (account.pinned) {
            slot.classList.add('pinned');
            const pinIcon = document.createElement('div');
            pinIcon.classList.add('pin-indicator');
            pinIcon.innerHTML = '📌'; // Pin emoji as indicator
            slot.appendChild(pinIcon);
          }
          
          slot.addEventListener('click', () => this._handleAccountSelect(account));
          slot.addEventListener('contextmenu', (event) => this._handleAccountContextMenu(event, account));
          // this._applyThemeToSlot(slot); // Apply theme - This will be handled by the _applyThemeToSlots call below
        } else {
          slot.classList.add('empty');
          slot.innerHTML = `&nbsp;`;
        }
        this.savedAccountsListElem.appendChild(slot);
      }
      this._applyThemeToSlots(); // Ensure all elements (slots and add button) reflect current theme
    }
    
    _applyThemeToSlot(slotElement) {
        if (!slotElement) {
            return;
        }

        if (this._currentThemeKey === 'banana.png' || this._currentThemeKey === 'pineapple.png') {
            slotElement.style.setProperty('color', '#4A4A4A', 'important'); // Dark gray for better contrast
        } else {
            slotElement.style.setProperty('color', '', ''); // Revert to CSS var (which should be --theme-primary)
        }
    }

    _applyThemeToSlots() {
        // Apply to saved account slots
        if (this.savedAccountsListElem) {
            const slots = this.savedAccountsListElem.querySelectorAll('.saved-account-slot:not(.empty)');
            slots.forEach(slot => this._applyThemeToSlot(slot));
        }

        // Apply to the add account button
        if (!this.addAccountButtonElem && this.shadowRoot) {
            this.addAccountButtonElem = this.shadowRoot.querySelector(".account-add-button");
        }

        if (this.addAccountButtonElem) {
            if (this._currentThemeKey === 'banana.png' || this._currentThemeKey === 'pineapple.png') {
                this.addAccountButtonElem.style.setProperty('color', '#4A4A4A', 'important'); // Dark gray for '+'
                this.addAccountButtonElem.style.setProperty('borderColor', '#4A4A4A', 'important'); // Dark gray for border
            } else {
                this.addAccountButtonElem.style.setProperty('color', ''); // Revert to CSS var (--theme-primary)
                this.addAccountButtonElem.style.setProperty('borderColor', ''); // Revert to CSS var (--theme-primary)
            }
        }
    }

    _handleAccountSelect(account) {
      this.dispatchEvent(new CustomEvent('account-selected', {
        // Password is no longer sent from here as it's not securely stored by this client part.
        // The LoginScreen will need to handle password input.
        detail: { username: account.username, password: account.password },
        bubbles: true,
        composed: true
      }));
    }

    _handlePanelContextMenu(event) {
      // This context menu is for the panel background or add button
      if (event.target === this.shadowRoot.getElementById('panel-container') || event.target.classList.contains('account-add-button') || event.target.classList.contains('empty')) {
        event.preventDefault();
        this._removeContextMenu(); // Remove any existing menu

        const menu = this._createContextMenuBase(event.clientX, event.clientY);
        const ul = menu.querySelector('ul');

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
      // If the event target is a saved-account-slot, its own contextmenu listener (_handleAccountContextMenu) will handle it.
    }
    
    _handleAccountContextMenu(event, account) {
      event.preventDefault();
      event.stopPropagation(); // Prevent panel's context menu from firing
      this._removeContextMenu(); // Remove any existing menu

      if (!account || !account.username) return;

      const menu = this._createContextMenuBase(event.clientX, event.clientY);
      const ul = menu.querySelector('ul');

      // Pin/Unpin option
      const pinItem = document.createElement('li');
      pinItem.textContent = account.pinned ? `Unpin "${account.username}"` : `Pin "${account.username}" to Top`;
      pinItem.addEventListener('click', async () => {
        try {
          const result = await window.ipc.invoke('toggle-pin-account', account.username);
          if (result.success) {
            this._displaySavedAccounts(result.accounts);
            // Dispatch accounts-updated event for auto wheel component
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
              // Dispatch accounts-updated event for auto wheel component
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
      ul.appendChild(document.createElement('li')).classList.add('separator'); // Visually a separator
      ul.appendChild(openCacheItem);

      this.shadowRoot.appendChild(menu);
      this._activeContextMenu = menu;
    }

    _createContextMenuBase(x, y) {
      const menu = document.createElement('div');
      menu.classList.add('custom-context-menu');
      // Position relative to viewport initially.
      // TODO: Adjust positioning if menu goes off-screen.
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
