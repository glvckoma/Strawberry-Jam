const isDevelopment = process.env.NODE_ENV === 'development'

const KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY = 'leak_checker_api_key'

class SettingsService {
  constructor(store, keytar, keytarServiceName) {
    this.store = store
    this.keytar = keytar
    this.keytarServiceName = keytarServiceName
  }

  async getSetting(key) {
    try {
      if (key === 'plugins.usernameLogger.apiKey') {
        const apiKey = await this.keytar.getPassword(this.keytarServiceName, KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY)
        return apiKey || ''
      }
      const valueFromStore = this.store.get(key)
      return valueFromStore
    } catch (error) {
      if (isDevelopment) {
        console.error(`[SettingsService] Error getting setting ${key}:`, error)
      }
      return key === 'plugins.usernameLogger.apiKey' ? '' : undefined
    }
  }

  async setSetting(key, value) {
    try {
      if (key === 'plugins.usernameLogger.apiKey') {
        if (typeof value === 'string' && value.trim() !== '') {
          await this.keytar.setPassword(this.keytarServiceName, KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY, value)
        } else {
          await this.keytar.deletePassword(this.keytarServiceName, KEYTAR_ACCOUNT_LEAK_CHECK_API_KEY)
        }
        return { success: true }
      }
      this.store.set(key, value)
      
      return { success: true }
    } catch (error) {
      if (isDevelopment) {
        console.error(`[SettingsService] Error setting setting ${key}:`, error)
      }
      return { success: false, error: error.message }
    }
  }
}

module.exports = SettingsService

