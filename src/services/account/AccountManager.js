const logManager = require('../../utils/LogManager');

const isDevelopment = process.env.NODE_ENV === 'development';

const STORE_KEY_SAVED_ACCOUNTS = 'savedAccounts';

class AccountManager {
  constructor(store) {
    this.store = store;
  }

  async getSavedAccounts() {
    try {
      const accountsFromStore = this.store.get(STORE_KEY_SAVED_ACCOUNTS, []);
      const accountsWithPasswords = [];

      for (const acc of accountsFromStore) {
        const storedPassword = this.store.get(`savedAccountPasswords.${acc.username}`);
        accountsWithPasswords.push({
          ...acc,
          password: storedPassword || null
        });
      }

      return accountsWithPasswords;
    } catch (error) {
      if (isDevelopment) {
        console.error('[AccountManager] Error getting saved accounts:', error);
      }
      logManager.error(`[AccountManager] Error getting saved accounts: ${error.message}`);
      return [];
    }
  }

  async saveAccount(accountData) {
    if (!accountData || !accountData.username || !accountData.password) {
      return { success: false, error: 'Invalid account data' };
    }

    try {
      let savedAccountsMetadata = this.store.get(STORE_KEY_SAVED_ACCOUNTS, []);
      const accountMetadata = { username: accountData.username };

      const existingAccountIndex = savedAccountsMetadata.findIndex(
        acc => acc.username.toLowerCase() === accountData.username.toLowerCase()
      );

      if (existingAccountIndex !== -1) {
        savedAccountsMetadata[existingAccountIndex] = accountMetadata;
      } else {
        savedAccountsMetadata.push(accountMetadata);
      }

      this.store.set(`savedAccountPasswords.${accountData.username}`, accountData.password);
      this.store.set(STORE_KEY_SAVED_ACCOUNTS, savedAccountsMetadata);

      const updatedAccountsWithPasswords = await this.getSavedAccounts();
      return { success: true, accounts: updatedAccountsWithPasswords };
    } catch (error) {
      logManager.error(`[AccountManager] Error saving account: ${error.message}`);
      return { success: false, error: error.message };
    }
  }

  async deleteAccount(username) {
    if (!username) {
      return { success: false, error: 'Invalid username' };
    }

    try {
      let savedAccountsMetadata = this.store.get(STORE_KEY_SAVED_ACCOUNTS, []);
      const initialLength = savedAccountsMetadata.length;

      savedAccountsMetadata = savedAccountsMetadata.filter(
        acc => acc.username.toLowerCase() !== username.toLowerCase()
      );

      if (savedAccountsMetadata.length < initialLength) {
        this.store.set(STORE_KEY_SAVED_ACCOUNTS, savedAccountsMetadata);
        this.store.delete(`savedAccountPasswords.${username}`);
        const updatedAccountsWithPasswords = await this.getSavedAccounts();
        return { success: true, accounts: updatedAccountsWithPasswords };
      } else {
        this.store.delete(`savedAccountPasswords.${username}`);
        const updatedAccountsWithPasswords = await this.getSavedAccounts();
        return { success: false, error: 'Account not found', accounts: updatedAccountsWithPasswords };
      }
    } catch (error) {
      logManager.error(`[AccountManager] Error deleting account: ${error.message}`);
      return { success: false, error: error.message };
    }
  }

  async deleteAllAccounts() {
    try {
      const savedAccountsMetadata = this.store.get(STORE_KEY_SAVED_ACCOUNTS, []);

      if (!Array.isArray(savedAccountsMetadata)) {
        this.store.set(STORE_KEY_SAVED_ACCOUNTS, []);
        return { success: true, deleted: 0 };
      }

      const nonPinned = savedAccountsMetadata.filter(acc => !acc?.pinned);
      const pinned = savedAccountsMetadata.filter(acc => acc?.pinned);
      const deletedCount = nonPinned.length;

      for (const account of nonPinned) {
        if (account && account.username) {
          this.store.delete(`savedAccountPasswords.${account.username}`);
        }
      }

      this.store.set(STORE_KEY_SAVED_ACCOUNTS, pinned);

      return { success: true, deleted: deletedCount, kept: pinned.length };
    } catch (error) {
      logManager.error(`[AccountManager] Error deleting non-pinned accounts: ${error.message}`);
      return { success: false, error: error.message };
    }
  }

  async togglePinAccount(username) {
    if (!username) {
      return { success: false, error: 'Invalid username' };
    }

    try {
      let savedAccountsMetadata = this.store.get(STORE_KEY_SAVED_ACCOUNTS, []);
      const accountIndex = savedAccountsMetadata.findIndex(
        acc => acc.username.toLowerCase() === username.toLowerCase()
      );

      if (accountIndex === -1) {
        return { success: false, error: 'Account not found' };
      }

      savedAccountsMetadata[accountIndex].pinned = !savedAccountsMetadata[accountIndex].pinned;
      this.store.set(STORE_KEY_SAVED_ACCOUNTS, savedAccountsMetadata);

      const updatedAccountsWithPasswords = await this.getSavedAccounts();
      return { success: true, accounts: updatedAccountsWithPasswords };
    } catch (error) {
      logManager.error(`[AccountManager] Error toggling pin status: ${error.message}`);
      return { success: false, error: error.message };
    }
  }

  async importAccounts(accounts) {
    if (!Array.isArray(accounts) || accounts.length === 0) {
      return { success: false, error: 'Invalid accounts array' };
    }

    try {
      let savedAccountsMetadata = this.store.get(STORE_KEY_SAVED_ACCOUNTS, []);
      let importedCount = 0;

      for (const account of accounts) {
        if (!account.username || !account.password) {
          continue;
        }

        const accountMetadata = { username: account.username };
        const existingAccountIndex = savedAccountsMetadata.findIndex(
          acc => acc.username.toLowerCase() === account.username.toLowerCase()
        );

        if (existingAccountIndex !== -1) {
          savedAccountsMetadata[existingAccountIndex] = accountMetadata;
        } else {
          savedAccountsMetadata.push(accountMetadata);
        }

        this.store.set(`savedAccountPasswords.${account.username}`, account.password);
        importedCount++;
      }

      this.store.set(STORE_KEY_SAVED_ACCOUNTS, savedAccountsMetadata);

      const updatedAccountsWithPasswords = await this.getSavedAccounts();
      return {
        success: true,
        imported: importedCount,
        total: accounts.length,
        accounts: updatedAccountsWithPasswords
      };
    } catch (error) {
      logManager.error(`[AccountManager] Error importing accounts: ${error.message}`);
      return { success: false, error: error.message };
    }
  }
}

module.exports = AccountManager;

