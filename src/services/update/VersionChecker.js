const { ipcRenderer } = require('electron')
const path = require('path')

/**
 * VersionChecker - Checks for version updates and manages update modals
 * 
 * @module VersionChecker
 */
class VersionChecker {
  constructor(application) {
    this.application = application
  }

  /**
   * Checks for version updates and shows the updates modal if needed
   * @returns {Promise<void>}
   * @public
   */
  async checkAndShow() {
    try {
      const lastSeenVersion = await ipcRenderer.invoke('get-setting', 'lastSeenVersion')
      
      const dataPath = path.join(__dirname, '../../data/updates-data.json')
      const rawData = await ipcRenderer.invoke('read-file', dataPath)
      const updatesData = JSON.parse(rawData)
      
      const latestVersion = Object.keys(updatesData).find(v => updatesData[v].isLatest)
      
      const shouldShow = latestVersion && 
                        latestVersion !== lastSeenVersion && 
                        this.isNewerVersion(latestVersion, lastSeenVersion || '0.0.0')
      
      if (shouldShow) {
        setTimeout(() => {
          this.application.modals.show('updatesModal', '#modalContainer', { 
            version: latestVersion 
          })
        }, 1000)
      }
    } catch (error) {
      console.error('Error checking for version updates:', error)
    }
  }

  /**
   * Compares two version strings to determine if first is newer than second
   * @param {string} version1 - Version to compare (e.g., "3.3.2")
   * @param {string} version2 - Version to compare against (e.g., "3.3.1")
   * @returns {boolean} True if version1 is newer than version2
   * @public
   */
  isNewerVersion(version1, version2) {
    const v1Parts = version1.split('.').map(Number)
    const v2Parts = version2.split('.').map(Number)
    
    for (let i = 0; i < Math.max(v1Parts.length, v2Parts.length); i++) {
      const v1Part = v1Parts[i] || 0
      const v2Part = v2Parts[i] || 0
      
      if (v1Part > v2Part) return true
      if (v1Part < v2Part) return false
    }
    
    return false
  }

  /**
   * Opens the Updates modal manually
   * @param {string} [version=null] - Version to show, or null to use latest
   * @returns {Promise<void>}
   * @public
   */
  async openUpdatesModal(version = null) {
    if (!version) {
      try {
        const dataPath = path.join(__dirname, '../../data/updates-data.json')
        const rawData = await ipcRenderer.invoke('read-file', dataPath)
        const updatesData = JSON.parse(rawData)
        const dataKeys = Object.keys(updatesData)
        const latestVersion = dataKeys.find(v => updatesData[v].isLatest)
        const fallbackVersion = dataKeys[0]
        version = latestVersion || fallbackVersion
      } catch (error) {
        console.error('Failed to load version for manual open:', error)
        version = '3.4.0'
      }
    }
    
    this.application.modals.show('updatesModal', '#modalContainer', { 
      version: version 
    })
  }
}

module.exports = VersionChecker

