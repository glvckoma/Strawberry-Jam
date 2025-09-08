const { dispatch } = jam
const { ipcRenderer } = require('electron')

class PacketEditor {
  constructor() {
    // DOM Elements
    this.packetEditorToggle = document.getElementById('packetEditorToggle')
    this.saveSettingsBtn = document.getElementById('saveSettings')
    this.resetSettingsBtn = document.getElementById('resetSettings')
    this.loadFromPacketBtn = document.getElementById('loadFromPacket')
    
    // Custom variables elements
    this.customVariablesList = document.getElementById('customVariablesList')
    this.customVarName = document.getElementById('customVarName')
    this.customVarValue = document.getElementById('customVarValue')
    this.addCustomVarBtn = document.getElementById('addCustomVar')
    
    // Form elements for all packet variables
    this.formElements = {
      // Basic User Info
      userName: document.getElementById('userName'),
      userId: document.getElementById('userId'),
      dbUserId: document.getElementById('dbUserId'),
      email: document.getElementById('email'),
      avName: document.getElementById('avName'),
      uuid: document.getElementById('uuid'),
      
      // Account Settings
      accountType: document.getElementById('accountType'),
      isModerator: document.getElementById('isModerator'),
      isGuide: document.getElementById('isGuide'),
      sessionId: document.getElementById('sessionId'),
      numLogins: document.getElementById('numLogins'),
      jamaaDate: document.getElementById('jamaaDate'),
      
      // Currency & Items
      gemsCount: document.getElementById('gemsCount'),
      diamondsCount: document.getElementById('diamondsCount'),
      goldCount: document.getElementById('goldCount'),
      silverCount: document.getElementById('silverCount'),
      strawCount: document.getElementById('strawCount'),
      stoneCount: document.getElementById('stoneCount'),
      bambooCount: document.getElementById('bambooCount'),
      orbsCount: document.getElementById('orbsCount'),
      ticketsCount: document.getElementById('ticketsCount'),
      ecoCredits: document.getElementById('ecoCredits'),
      
      // Advanced Settings
      activePetInvId: document.getElementById('activePetInvId'),
      activeDenRoomInvId: document.getElementById('activeDenRoomInvId'),
      perUserAvId: document.getElementById('perUserAvId'),
      interactions: document.getElementById('interactions'),
      pendingFlags: document.getElementById('pendingFlags'),
      dailyGiftIndex: document.getElementById('dailyGiftIndex'),
      recyclePercentage: document.getElementById('recyclePercentage'),
      createdAt: document.getElementById('createdAt'),
      
      // Privacy & Chat Settings
      denPrivacySettings: document.getElementById('denPrivacySettings'),
      eCardPrivacySettings: document.getElementById('eCardPrivacySettings'),
      sgChatType: document.getElementById('sgChatType'),
      webWallStatus: document.getElementById('webWallStatus'),
      playerWallSettings: document.getElementById('playerWallSettings'),
      hasOnlineBuddies: document.getElementById('hasOnlineBuddies'),
      
      // Subscription Settings
      subscriptionSourceType: document.getElementById('subscriptionSourceType'),
      numDaysLeftOnSubscription: document.getElementById('numDaysLeftOnSubscription'),
      numAJHQGiftCards: document.getElementById('numAJHQGiftCards'),
      numAJHQBulkGiftCards: document.getElementById('numAJHQBulkGiftCards'),
      numRedemptionCards: document.getElementById('numRedemptionCards'),
      numUnreadECards: document.getElementById('numUnreadECards'),
      
      // Message Settings
      lastBroadcastMessage: document.getElementById('lastBroadcastMessage'),
      userNameModerated: document.getElementById('userNameModerated')
    }

    // No default values - form starts empty
    this.defaultValues = {}

    this.currentModifications = {}
    this.customVariables = {}
    this.isActive = false
    this.lastLoginPacket = null

    this.init()
  }

  /**
   * Initialize the plugin
   */
  async init() {
    this.setupEventListeners()
    await this.loadSettings()
    this.updateUI()
    console.log('[Packet Editor] Initialized')
  }

  /**
   * Set up event listeners
   */
  setupEventListeners() {
    // Toggle switch
    this.packetEditorToggle.addEventListener('change', (e) => {
      this.isActive = e.target.checked
      this.saveSettings()
      this.updateToggleStatus()
      
      // Show toast notification when user manually toggles
      if (this.isActive) {
        jam.showToast('Packet Editor enabled! Modifications will be applied on next login.', 'success')
      } else {
        jam.showToast('Packet Editor disabled.', 'info')
      }
    })

    // Action buttons
    this.saveSettingsBtn.addEventListener('click', () => this.saveCurrentSettings())
    this.resetSettingsBtn.addEventListener('click', () => this.resetToDefault())
    this.loadFromPacketBtn.addEventListener('click', () => this.loadFromLastPacket())
    
    // Custom variables
    this.addCustomVarBtn.addEventListener('click', () => this.addCustomVariable())

    // Form change listeners
    Object.keys(this.formElements).forEach(key => {
      const element = this.formElements[key]
      if (element) {
        element.addEventListener('change', () => this.markAsModified())
        element.addEventListener('input', () => this.markAsModified())
      }
    })
  }

  /**
   * Load settings from file
   */
  async loadSettings() {
    try {
      const settings = await ipcRenderer.invoke('read-json-file', 'packet-editor-settings.json', {
        active: false,
        modifications: {},
        customVariables: {}
      })
      
      this.isActive = settings.active
      this.currentModifications = settings.modifications || {}
      this.customVariables = settings.customVariables || {}
      
      // Load last packet if available
      const lastPacket = await ipcRenderer.invoke('read-json-file', 'packet-editor-last-packet.json', null)
      if (lastPacket) {
        this.lastLoginPacket = lastPacket
      }
    } catch (error) {
      console.error('[Packet Editor] Error loading settings:', error)
      this.isActive = false
      this.currentModifications = {}
    }
  }

  /**
   * Save settings to file
   */
  async saveSettings() {
    try {
      await ipcRenderer.invoke('write-json-file', 'packet-editor-settings.json', {
        active: this.isActive,
        modifications: this.currentModifications,
        customVariables: this.customVariables
      })
    } catch (error) {
      console.error('[Packet Editor] Error saving settings:', error)
    }
  }

  /**
   * Update UI based on current state
   */
  updateUI() {
    this.packetEditorToggle.checked = this.isActive
    this.updateToggleStatus()
    this.populateForm()
    this.renderCustomVariables()
  }

  /**
   * Update toggle status display
   */
  updateToggleStatus() {
    const statusText = this.isActive ? 'enabled' : 'disabled'
    console.log(`[Packet Editor] Packet modification ${statusText}`)
  }

  /**
   * Populate form with current modifications or default values
   */
  populateForm() {
    Object.keys(this.formElements).forEach(key => {
      const element = this.formElements[key]
      if (!element) return

      // Use current modifications if available, otherwise leave empty
      const value = this.currentModifications[key] !== undefined 
        ? this.currentModifications[key] 
        : null

      if (element.type === 'checkbox') {
        element.checked = Boolean(value)
      } else if (element.tagName === 'SELECT') {
        element.value = value ? String(value) : ''
      } else if (element.type === 'number') {
        element.value = value || ''
      } else {
        element.value = value ? String(value) : ''
      }
    })
  }

  /**
   * Mark form as modified
   */
  markAsModified() {
    // Visual indicator could be added here
  }

  /**
   * Set button state with smooth transitions
   * @param {HTMLElement} button - The button element
   * @param {string} text - The text to display
   * @param {boolean} loading - Whether to show loading state
   * @param {string} state - The state type ('success', 'error', etc.)
   */
  setButtonState(button, text, loading = false, state = '') {
    if (!button) return

    // Update button text
    button.textContent = text
    
    // Remove existing state classes
    button.classList.remove('opacity-50', 'cursor-not-allowed', 'bg-green-500', 'bg-red-500', 'bg-blue-500')
    
    if (loading) {
      // Loading state
      button.classList.add('opacity-50', 'cursor-not-allowed')
      button.disabled = true
    } else {
      // Reset disabled state
      button.disabled = false
      
      // Apply state-specific styling
      if (state === 'success') {
        button.classList.add('bg-green-500', 'hover:bg-green-600')
      } else if (state === 'error') {
        button.classList.add('bg-red-500', 'hover:bg-red-600')
      } else if (state === 'info') {
        button.classList.add('bg-blue-500', 'hover:bg-blue-600')
      }
    }
  }

  /**
   * Save current form values as modifications
   */
  async saveCurrentSettings() {
    // Show loading state
    this.setButtonState(this.saveSettingsBtn, 'Saving...', true)
    
    const modifications = {}
    
    Object.keys(this.formElements).forEach(key => {
      const element = this.formElements[key]
      if (!element) return

      let value = element.value
      
      // Convert value to appropriate type
      if (element.type === 'checkbox') {
        value = element.checked
      } else if (element.type === 'number') {
        value = value === '' ? null : Number(value)
      } else if (element.tagName === 'SELECT') {
        // Keep as string for select elements
        value = value
      } else {
        value = value || null
      }

      // Save any non-empty values
      if (value !== null && value !== '') {
        modifications[key] = value
      }
    })

    this.currentModifications = modifications
    await this.saveSettings()
    
    // Show success state
    this.setButtonState(this.saveSettingsBtn, 'Saved!', false, 'success')
    
    jam.showToast('Packet modifications saved! Changes will take effect on your next login.', 'success')
    console.log('[Packet Editor] Settings saved:', modifications)
    console.log('[Packet Editor] Custom variables:', this.customVariables)
    
    // Reset to original state after 2 seconds
    setTimeout(() => {
      this.setButtonState(this.saveSettingsBtn, 'Save Settings', false)
    }, 2000)
  }

  /**
   * Reset all values to default
   */
  async resetToDefault() {
    if (!confirm('Are you sure you want to reset all values to default? This will clear all your modifications.')) {
      return
    }

    // Show loading state
    this.setButtonState(this.resetSettingsBtn, 'Resetting...', true)

    this.currentModifications = {}
    await this.saveSettings()
    this.populateForm()
    
    // Show success state
    this.setButtonState(this.resetSettingsBtn, 'Reset!', false, 'success')
    
    jam.showToast('All values reset to default.', 'success')
    console.log('[Packet Editor] Reset to default values')
    
    // Reset to original state after 2 seconds
    setTimeout(() => {
      this.setButtonState(this.resetSettingsBtn, 'Reset to Default', false)
    }, 2000)
  }

  /**
   * Load values from last received login packet
   */
  async loadFromLastPacket() {
    if (!this.lastLoginPacket?.b?.o?.params) {
      jam.showToast('No login packet received yet. Please login first to capture packet data.', 'warning')
      return
    }

    // Show loading state
    this.setButtonState(this.loadFromPacketBtn, 'Loading...', true)

    const params = this.lastLoginPacket.b.o.params
    const modifications = {}

    // Map packet parameters to form fields
    Object.keys(this.formElements).forEach(key => {
      if (params[key] !== undefined) {
        modifications[key] = params[key]
      }
    })

    this.currentModifications = modifications
    await this.saveSettings()
    this.populateForm()
    
    // Show success state
    this.setButtonState(this.loadFromPacketBtn, 'Loaded!', false, 'success')
    
    jam.showToast('Loaded values from last login packet. You can now modify them as needed.', 'success')
    console.log('[Packet Editor] Loaded from last packet:', modifications)
    
    // Reset to original state after 2 seconds
    setTimeout(() => {
      this.setButtonState(this.loadFromPacketBtn, 'Load from Last Packet', false)
    }, 2000)
  }

  /**
   * Add a custom variable
   */
  addCustomVariable() {
    const name = this.customVarName.value.trim()
    const value = this.customVarValue.value.trim()
    
    if (!name || !value) {
      jam.showToast('Please enter both variable name and value.', 'warning')
      return
    }
    
    // Check if variable already exists
    if (this.customVariables[name]) {
      jam.showToast('Variable already exists. Use edit to modify it.', 'warning')
      return
    }
    
    // Add to custom variables
    this.customVariables[name] = value
    this.renderCustomVariables()
    
    // Clear form
    this.customVarName.value = ''
    this.customVarValue.value = ''
    
    jam.showToast(`Added custom variable: ${name}`, 'success')
  }

  /**
   * Remove a custom variable
   */
  removeCustomVariable(name) {
    delete this.customVariables[name]
    this.renderCustomVariables()
    jam.showToast(`Removed custom variable: ${name}`, 'info')
  }

  /**
   * Edit a custom variable
   */
  editCustomVariable(name) {
    const newValue = prompt(`Enter new value for ${name}:`, this.customVariables[name])
    if (newValue !== null) {
      this.customVariables[name] = newValue
      this.renderCustomVariables()
      jam.showToast(`Updated custom variable: ${name}`, 'success')
    }
  }

  /**
   * Render custom variables list
   */
  renderCustomVariables() {
    this.customVariablesList.innerHTML = ''
    
    if (Object.keys(this.customVariables).length === 0) {
      const emptyDiv = document.createElement('div')
      emptyDiv.className = 'text-center text-gray-400 py-4'
      emptyDiv.textContent = 'No custom variables added yet.'
      this.customVariablesList.appendChild(emptyDiv)
      return
    }
    
    Object.keys(this.customVariables).forEach(name => {
      const value = this.customVariables[name]
      
      const varDiv = document.createElement('div')
      varDiv.className = 'bg-tertiary-bg/50 p-3 rounded-md border border-sidebar-border flex items-center justify-between'
      
      varDiv.innerHTML = `
        <div class="flex-1">
          <div class="font-medium text-text-primary">${name}</div>
          <div class="text-sm text-gray-400">${value}</div>
        </div>
        <div class="flex space-x-2">
          <button onclick="packetEditor.editCustomVariable('${name}')" class="px-2 py-1 bg-blue-500/20 hover:bg-blue-500/30 text-blue-400 rounded text-sm">
            <i class="fas fa-edit"></i>
          </button>
          <button onclick="packetEditor.removeCustomVariable('${name}')" class="px-2 py-1 bg-red-500/20 hover:bg-red-500/30 text-red-400 rounded text-sm">
            <i class="fas fa-trash"></i>
          </button>
        </div>
      `
      
      this.customVariablesList.appendChild(varDiv)
    })
  }

  /**
   * Get all modifications including custom variables
   */
  getAllModifications() {
    return {
      ...this.currentModifications,
      ...this.customVariables
    }
  }

}

// Initialize the plugin when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  window.packetEditor = new PacketEditor()
})