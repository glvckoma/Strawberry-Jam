const { dispatch } = jam

const tab = ' '.repeat(2)

let runner
let runnerType
let runnerRow
let activeRow = null
let packetHistory = []

const MAX_HISTORY_ITEMS = 20

class Spammer {
  constructor () {
    // DOM Elements
    this.input = document.getElementById('inputTxt')
    this.inputType = document.getElementById('inputType')
    this.inputDelay = document.getElementById('inputDelay')
    this.inputRunType = document.getElementById('inputRunType')
    this.targetAccount = document.getElementById('targetAccount')
    this.stopButton = document.getElementById('stopButton')
    this.runButton = document.getElementById('runButton')
    this.table = document.getElementById('table')
    this.historyTable = document.getElementById('historyTable')
    this.templatesTable = document.getElementById('templatesTable')

    this.tabs = document.querySelectorAll('.tab-btn')
    this.tabContents = document.querySelectorAll('.tab-content')

    this.saveTemplateModal = document.getElementById('saveTemplateModal')
    this.templateNameInput = document.getElementById('templateNameInput')
    this.confirmSaveTemplate = document.getElementById('confirmSaveTemplate')
    this.cancelSaveTemplate = document.getElementById('cancelSaveTemplate')

    this.stopButton.disabled = true

    this.loadHistory()
    this.renderHistory()
    this.initSortable()
    this.loadTemplates()
    this.loadAccountSelection()
    this.updateAccountDropdown()

    this.setupModalListeners()
    
    // Update account dropdown periodically
    setInterval(() => this.updateAccountDropdown(), 5000)
    /**
     * Handles input events for tab support in textarea
     */
    this.input.onkeydown = e => {
      const keyCode = e.which

      if (keyCode === 9) {
        e.preventDefault()

        const s = this.input.selectionStart
        this.input.value = this.input.value.substring(0, this.input.selectionStart) + tab + this.input.value.substring(this.input.selectionEnd)
        this.input.selectionEnd = s + tab.length
      }
    }

    this.input.onkeyup = () => {
      // Highlighting removed due to performance issues
    }
  }

  /**
   * Sends a packet
   * @param {string|string[]} content - The packet content
   * @param {string} type - The packet type (aj or connection)
   */
  async sendPacket (content, type) {
    if (!content) return

    content = content || this.input.value

    if (window.IS_DEV) {
      console.log(`[DEBUG] Spammer sendPacket: Received type: "${type}"`);
      console.log(`[DEBUG] Spammer sendPacket: Received content (raw): "${JSON.stringify(content)}"`);
    }

    // Get current room identifiers
    const textualRoomId = await dispatch.getState('room');
    let internalRoomIdValue = await dispatch.getState('internalRoomId');
    let parsedInternalRoomId = null;

    if (internalRoomIdValue !== null && internalRoomIdValue !== undefined) {
        parsedInternalRoomId = parseInt(internalRoomIdValue, 10);
        if (isNaN(parsedInternalRoomId)) {
            console.warn(`Spammer Plugin: internalRoomId '${internalRoomIdValue}' could not be parsed to a number.`);
            parsedInternalRoomId = null; // Ensure it's null if parsing failed
        }
    }

    let roomIdToUseForXt = null; // For %xt% packets
    let roomIdToUseForXml = null; // For XML r="" attribute

    if (parsedInternalRoomId !== null) {
        roomIdToUseForXt = parsedInternalRoomId;
        roomIdToUseForXml = parsedInternalRoomId; // XML pubMsg also uses numerical internalRoomId
        console.log(`Spammer Plugin: Using parsed internalRoomId: ${parsedInternalRoomId}`);
    } else if (textualRoomId) {
        roomIdToUseForXt = textualRoomId;
        roomIdToUseForXml = textualRoomId; // Fallback for XML as well
        console.warn(`Spammer Plugin: Parsed internalRoomId not available (original value: ${internalRoomIdValue}). Falling back to textualRoomId: ${textualRoomId}. Packets may not work as expected.`);
    }

    if (Array.isArray(content)) {
      if (content.some(msg => msg.includes('{room}')) && !roomIdToUseForXt && !roomIdToUseForXml) {
        console.error('Spammer Plugin: Cannot send packets, no room ID (textual or internal) is available.')
        dispatch.showToast('Spammer: Cannot send, not in a room.', 'error')
        return
      }

      const processedMessages = content.map(msg => {
        let currentMsg = msg;
        if (currentMsg.includes('{room}')) {
          // Prioritize numerical for XT, fallback to textual. For XML, it depends on the packet.
          // For now, we'll assume {room} in XT means the primary room identifier.
          // For XML, if it's a pubMsg, it should be numerical.
          if (type === 'aj' && currentMsg.startsWith('%xt%')) { // XT packet
            console.log(`Spammer Plugin (Array - XT): Replacing {room} with ${roomIdToUseForXt}`);
            currentMsg = roomIdToUseForXt ? currentMsg.replaceAll('{room}', roomIdToUseForXt) : currentMsg;
          } else if (type === 'connection' && currentMsg.includes('action="pubMsg"') && currentMsg.includes('r="{room}"')) { // XML pubMsg specifically targeting r="{room}"
            console.log(`Spammer Plugin (Array - XML pubMsg): Condition MET. Attempting to replace r="{room}" with r="${roomIdToUseForXml}" in message: ${currentMsg}`);
            currentMsg = roomIdToUseForXml ? currentMsg.replace('r="{room}"', `r="${roomIdToUseForXml}"`) : currentMsg;
            console.log(`Spammer Plugin (Array - XML pubMsg): Message after replace: ${currentMsg}`);
          } else if (currentMsg.includes('{room}')) { // General fallback for {room} if not caught by specific handlers
            // Log why the specific XML pubMsg condition might have failed
            if (type === 'connection' && currentMsg.includes('action="pubMsg"')) {
              console.log(`Spammer Plugin (Array - XML pubMsg Condition DEBUG): type === 'connection': ${type === 'connection'}, currentMsg.includes('action="pubMsg"'): ${currentMsg.includes('action="pubMsg"')}, currentMsg.includes('r="{room}"'): ${currentMsg.includes('r="{room}"')}`);
            }
            const replacementIdArray = roomIdToUseForXt !== null ? roomIdToUseForXt : (textualRoomId || '');
            console.log(`Spammer Plugin (Array - General Fallback for {room}): Replacing {room} with ${replacementIdArray}`);
            currentMsg = currentMsg.replaceAll('{room}', replacementIdArray);
          } else { // No {room} placeholder
            console.log(`Spammer Plugin (Array - No {room} placeholder): No replacement needed for ${currentMsg}`);
            currentMsg = textualRoomId ? currentMsg.replaceAll('{room}', textualRoomId) : currentMsg;
          }
        }
        return currentMsg;
      })

      return dispatch.sendMultipleMessages({
        type,
        messages: processedMessages
      })
    }

    // Single message processing
    if (content.includes('{room}')) {
      if (!roomIdToUseForXt && !roomIdToUseForXml) {
        console.error('Spammer Plugin: Cannot send packet, no room ID (textual or internal) is available.')
        dispatch.showToast('Spammer: Cannot send, not in a room.', 'error')
        return
      }
      // Similar logic for single message
      if (type === 'aj' && content.startsWith('%xt%')) { // XT packet
        console.log(`Spammer Plugin (Single - XT): Replacing {room} with ${roomIdToUseForXt}`);
        content = roomIdToUseForXt ? content.replaceAll('{room}', roomIdToUseForXt) : content;
      } else if (type === 'connection' && content.includes('action="pubMsg"') && content.includes('r="{room}"')) { // XML pubMsg specifically targeting r="{room}"
        console.log(`Spammer Plugin (Single - XML pubMsg): Condition MET. Attempting to replace r="{room}" with r="${roomIdToUseForXml}" in message: ${content}`);
        content = roomIdToUseForXml ? content.replace('r="{room}"', `r="${roomIdToUseForXml}"`) : content;
        console.log(`Spammer Plugin (Single - XML pubMsg): Message after replace: ${content}`);
      } else if (content.includes('{room}')) { // General fallback for {room} if not caught by specific handlers
        // Log why the specific XML pubMsg condition might have failed
        if (type === 'connection' && content.includes('action="pubMsg"')) {
            console.log(`Spammer Plugin (Single - XML pubMsg Condition DEBUG): type === 'connection': ${type === 'connection'}, content.includes('action="pubMsg"'): ${content.includes('action="pubMsg"')}, content.includes('r="{room}"'): ${content.includes('r="{room}"')}`);
        }
        const replacementIdSingle = roomIdToUseForXt !== null ? roomIdToUseForXt : (textualRoomId || '');
        console.log(`Spammer Plugin (Single - General Fallback for {room}): Replacing {room} with ${replacementIdSingle}`);
        content = content.replaceAll('{room}', replacementIdSingle);
      } else { // No {room} placeholder
        console.log(`Spammer Plugin (Single - No {room} placeholder): No replacement needed for ${content}`);
      }
    }

    try {
      const options = {}
      const selectedAccount = this.targetAccount.value
      if (selectedAccount && selectedAccount !== '') {
        options.targetUsername = selectedAccount
      }
      
      if (type === 'aj') {
        dispatch.sendRemoteMessage(content, options)
      } else {
        dispatch.sendConnectionMessage(content)
      }

      this.addToHistory(content, type)
    } catch (error) {
      console.error('Error sending packet:', error)
    }
  }

  /**
   * Adds a packet to the queue
   */
  addClick () {
    if (!this.input.value) return

    const type = this.inputType.value
    const content = this.input.value
    let delay = parseFloat(this.inputDelay.value)

    if (isNaN(delay) || delay < 0) {
      delay = 1
    }

    this.createRow(type, content, delay.toString())
  }

  /**
   * Creates a row in the table
   * @param {string} type - The packet type
   * @param {string} content - The packet content
   * @param {string} delay - The delay
   */
  createRow (type, content, delay) {
    const row = this.table.insertRow(-1)
    row.className = 'hover:bg-tertiary-bg/20 transition'

    const typeCell = row.insertCell(0)
    const contentCell = row.insertCell(1)
    const delayCell = row.insertCell(2)
    const actionCell = row.insertCell(3)

    typeCell.className = 'py-2 px-3 text-xs'
    contentCell.className = 'py-2 px-3 text-xs'
    delayCell.className = 'py-2 px-3 text-xs'
    actionCell.className = 'py-2 px-3 text-xs'

    typeCell.innerHTML = `<select class="bg-tertiary-bg text-text-primary p-1 rounded-md focus:outline-none text-xs"><option value="connection" ${type === 'connection' ? 'selected' : ''}>Client</option><option value="aj" ${type === 'aj' ? 'selected' : ''}>Animal Jam</option></select>`
    contentCell.innerText = content
    delayCell.innerText = delay

    contentCell.contentEditable = true
    delayCell.contentEditable = true

    contentCell.title = content

    actionCell.innerHTML = `
      <button type="button" class="px-2 py-1 bg-tertiary-bg hover:bg-sidebar-hover text-text-primary rounded-md transition text-xs drag-handle">
        <i class="fas fa-arrows-alt"></i>
      </button>
      <button type="button" class="px-2 py-1 bg-tertiary-bg hover:bg-sidebar-hover text-text-primary rounded-md transition text-xs" onclick="spammer.deleteRow(this)">
        <i class="fas fa-trash-alt"></i>
      </button>
    `
  }

  /**
   * Deletes a row from the queue
   */
  sendFromInput () {
    const content = this.input.value
    if (!content) return

    const type = this.inputType.value

    try {
      const packets = content.match(/[^\r\n]+/g)
      if (packets && packets.length > 1) {
        this.sendPacket(packets, type)
      } else {
        this.sendPacket(content, type)
      }
      this.addToHistory(content, type)
    } catch (error) {
      console.error('Error sending packet:', error)
    }
  }

  deleteRow (btn) {
    const row = btn.closest('tr')
    row.parentNode.removeChild(row)
  }

  /**
   * Switches between UI tabs
   * @param {string} tabName - The name of the tab to switch to
   */
  switchTab (tabName) {
    this.tabs.forEach(tab => {
      tab.classList.toggle('active-tab', tab.textContent.toLowerCase() === tabName)
    })

    this.tabContents.forEach(content => {
      content.classList.toggle('hidden', content.id !== `${tabName}-tab`)
    })
  }

  /**
   * Initializes SortableJS
   */
  initSortable () {
    Sortable.create(this.table, {
      animation: 150,
      handle: '.drag-handle',
      onEnd: () => {
        // The onEnd event is where you would save the new order if needed
      }
    })
  }

  /**
   * Adds a packet to the history
   * @param {string} content - The packet content
   * @param {string} type - The packet type
   */
  addToHistory (content, type) {
    // Avoid adding duplicates
    const exists = packetHistory.some(item => item.content === content && item.type === type)
    if (exists) return

    packetHistory.unshift({ content, type })

    if (packetHistory.length > MAX_HISTORY_ITEMS) {
      packetHistory.pop()
    }

    this.saveHistory()
    this.renderHistory()
  }

  /**
   * Renders the history table
   */
  renderHistory () {
    this.historyTable.innerHTML = ''

    if (packetHistory.length === 0) {
      const row = this.historyTable.insertRow(-1)
      const cell = row.insertCell(0)
      cell.colSpan = 3
      cell.className = 'py-4 px-4 text-center text-gray-400'
      cell.innerText = 'No history yet. Sent packets will appear here.'
      return
    }

    packetHistory.forEach(item => {
      const row = this.historyTable.insertRow(-1)
      row.className = 'hover:bg-tertiary-bg/20 transition'

      const typeCell = row.insertCell(0)
      const contentCell = row.insertCell(1)
      const actionCell = row.insertCell(2)

      typeCell.className = 'py-2 px-3 text-xs'
      contentCell.className = 'py-2 px-3 text-xs truncate max-w-[300px]'
      actionCell.className = 'py-2 px-3 text-xs'

      typeCell.innerText = item.type
      contentCell.innerText = item.content
      contentCell.title = item.content

      actionCell.innerHTML = `
        <button type="button" class="px-2 py-1 bg-tertiary-bg hover:bg-sidebar-hover text-text-primary rounded-md transition text-xs" onclick="spammer.useHistoryItem('${btoa(JSON.stringify(item))}')">
          <i class="fas fa-redo-alt"></i> Use
        </button>
      `
    })
  }

  /**
   * Uses a history item
   * @param {string} itemString - The base64 encoded history item
   */
  useHistoryItem (itemString) {
    try {
      const item = JSON.parse(atob(itemString))
      this.input.value = item.content
      this.inputType.value = item.type
      this.switchTab('queue')
    } catch (error) {
      console.error('Error using history item:', error)
    }
  }

  /**
   * Saves the history to local storage
   */
  saveHistory () {
    localStorage.setItem('spammer_history', JSON.stringify(packetHistory))
  }

  /**
   * Loads the history from local storage
   */
  loadHistory () {
    const history = localStorage.getItem('spammer_history')
    if (history) {
      packetHistory = JSON.parse(history)
    }
  }

  /**
   * Clears the history
   */
  clearHistory () {
    packetHistory = []
    this.saveHistory()
    this.renderHistory()
  }

  /**
   * Starts running the queue
   */
  runClick () {
    if (this.table.rows.length === 0) {
      return
    }

    this.stopButton.disabled = false
    this.runButton.disabled = true
    runnerRow = 0
    runnerType = this.inputRunType.value

    this.runNext()
  }


  /**
   * Processes the next packet in the queue
   */
  runNext () {
    if (activeRow) {
      activeRow.classList.remove('bg-tertiary-bg/40')
    }

    const row = this.table.rows[runnerRow++]

    if (!row) {
      if (runnerType === 'loop') {
        runnerRow = 0
        this.runNext()
      } else {
        this.stopClick()
      }
      return
    }

    const type = row.cells[0].querySelector('select').value
    const content = row.cells[1].innerText
    let delay = parseFloat(row.cells[2].innerText)

    if (isNaN(delay) || delay < 0) {
      delay = 1
    }

    activeRow = row
    row.classList.add('bg-tertiary-bg/40')

    try {
      this.sendPacket(content, type)
    } catch (error) {
      console.error('Error in packet execution:', error)
    }

    runner = setTimeout(() => {
      this.runNext()
    }, delay * 1000)
  }

  /**
   * Stops the queue execution
   */
  stopClick () {
    this.runButton.disabled = false
    this.stopButton.disabled = true

    if (runner) clearTimeout(runner)

    if (activeRow) {
      activeRow.classList.remove('bg-tertiary-bg/40')
      activeRow = null
    }
  }

  /**
   * Saves the current queue to a file
   */
  saveToFile () {
    const packets = []
    for (let i = 1; i < this.table.rows.length; i++) {
      const row = this.table.rows[i]
      const type = row.cells[0].innerText
      const content = row.cells[1].innerText
      const delay = row.cells[2].innerText
      packets.push({ type, content, delay })
    }

    const data = {
      input: this.input.value,
      packets: packets
    }

    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
    const a = document.createElement('a')
    a.href = URL.createObjectURL(blob)
    a.download = 'packet-queue.json'
    a.click()
    URL.revokeObjectURL(a.href)
  }

  /**
   * Loads a queue from a file
   */
  loadFromFile () {
    const inputElement = document.createElement('input')
    inputElement.type = 'file'
    inputElement.accept = '.json,.txt'

    inputElement.onchange = async (event) => {
      try {
        const file = event.target.files[0]
        if (!file) return

        const text = await file.text()
        const data = JSON.parse(text)

        this.input.value = data.input || ''

        while (this.table.rows.length > 0) {
          this.table.deleteRow(0)
        }

        if (data.packets && Array.isArray(data.packets)) {
          data.packets.forEach(packet => {
            this.createRow(packet.type, packet.content, packet.delay)
          })
        }
      } catch (error) {
        console.error('Error loading file:', error)
      }
    }

    inputElement.click()
  }

  /**
   * Sets up listeners for the save template modal
   */
  setupModalListeners () {
    this.confirmSaveTemplate.onclick = async () => {
      const name = this.templateNameInput.value
      await this._saveTemplateInternal(name)
      this.saveTemplateModal.classList.add('hidden')
      this.templateNameInput.value = ''
    }

    this.cancelSaveTemplate.onclick = () => {
      this.saveTemplateModal.classList.add('hidden')
      this.templateNameInput.value = ''
    }
  }

  /**
   * Shows the modal to save the current queue as a template
   */
  saveTemplate () {
    this.saveTemplateModal.classList.remove('hidden')
    this.templateNameInput.focus()
  }

  /**
   * Saves the current queue as a template
   * @param {string} name - The name of the template
   */
  async _saveTemplateInternal (name) {
    if (!name) return

    const packets = []
    for (let i = 0; i < this.table.rows.length; i++) {
      const row = this.table.rows[i]
      const type = row.cells[0].querySelector('select').value
      const content = row.cells[1].innerText
      const delay = row.cells[2].innerText
      packets.push({ type, content, delay })
    }

    const template = { name, packets }

    try {
      let templates = await jam.readJsonFile('spammer-templates.json', [])
      templates.push(template)
      await jam.writeJsonFile('spammer-templates.json', templates)
      this.loadTemplates()
      jam.showToast('Template saved successfully.', 'success')
    } catch (error) {
      console.error('Error saving template:', error)
      jam.showToast('Error saving template.', 'error')
    }
  }

  /**
   * Loads templates from file
   */
  async loadTemplates () {
    try {
      const templates = await jam.readJsonFile('spammer-templates.json', [])
      this.renderTemplates(templates)
    } catch (error) {
      console.error('Error loading templates:', error)
      this.renderTemplates([])
    }
  }

  /**
   * Renders the templates table
   * @param {Array} templates - The templates to render
   */
  renderTemplates (templates) {
    this.templatesTable.innerHTML = ''

    if (templates.length === 0) {
      const row = this.templatesTable.insertRow(-1)
      const cell = row.insertCell(0)
      cell.colSpan = 2
      cell.className = 'py-4 px-4 text-center text-gray-400'
      cell.innerText = 'No templates yet. Save a queue as a template to get started.'
      return
    }

    templates.forEach((template, index) => {
      const row = this.templatesTable.insertRow(-1)
      row.className = 'hover:bg-tertiary-bg/20 transition'

      const nameCell = row.insertCell(0)
      const actionCell = row.insertCell(1)

      nameCell.className = 'py-2 px-3 text-xs'
      actionCell.className = 'py-2 px-3 text-xs'

      nameCell.innerText = template.name

      actionCell.innerHTML = `
        <button type="button" class="px-2 py-1 bg-tertiary-bg hover:bg-sidebar-hover text-text-primary rounded-md transition text-xs" onclick="spammer.loadTemplate(${index})">
          <i class="fas fa-download"></i> Load
        </button>
        <button type="button" class="px-2 py-1 bg-error-red/20 hover:bg-error-red/30 text-error-red rounded-md transition text-xs" onclick="spammer.deleteTemplate(${index})">
          <i class="fas fa-trash-alt"></i>
        </button>
      `
    })
  }

  /**
   * Loads a template into the queue
   * @param {number} index - The index of the template to load
   */
  async loadTemplate (index) {
    try {
      const templates = await jam.readJsonFile('spammer-templates.json', [])
      const template = templates[index]

      while (this.table.rows.length > 0) {
        this.table.deleteRow(0)
      }

      if (template.packets && Array.isArray(template.packets)) {
        template.packets.forEach(packet => {
          this.createRow(packet.type, packet.content, packet.delay)
        })
      }
      
      this.switchTab('queue')
    } catch (error) {
      console.error('Error loading template:', error)
      jam.showToast('Error loading template.', 'error')
    }
  }

  /**
   * Deletes a template
   * @param {number} index - The index of the template to delete
   */
  async deleteTemplate (index) {
    if (!confirm('Are you sure you want to delete this template?')) return

    try {
      let templates = await jam.readJsonFile('spammer-templates.json', [])
      templates.splice(index, 1)
      await jam.writeJsonFile('spammer-templates.json', templates)
      this.loadTemplates()
      jam.showToast('Template deleted successfully.', 'success')
    } catch (error) {
      console.error('Error deleting template:', error)
      jam.showToast('Error deleting template.', 'error')
    }
  }

  /**
   * Exports all templates to a JSON file
   */
  async exportTemplates () {
    try {
      const templates = await jam.readJsonFile('spammer-templates.json', [])
      if (templates.length === 0) {
        jam.showToast('No templates to export.', 'info')
        return
      }

      const blob = new Blob([JSON.stringify(templates, null, 2)], { type: 'application/json' })
      const a = document.createElement('a')
      a.href = URL.createObjectURL(blob)
      a.download = 'spammer-templates-export.json'
      a.click()
      URL.revokeObjectURL(a.href)
    } catch (error) {
      console.error('Error exporting templates:', error)
      jam.showToast('Error exporting templates.', 'error')
    }
  }

  /**
   * Populates the target account dropdown with connected clients
   */
  async updateAccountDropdown () {
    try {
      let clients = []
      
      if (dispatch && typeof dispatch.getConnectedClients === 'function') {
        const result = dispatch.getConnectedClients()
        if (result && typeof result.then === 'function') {
          clients = await result
        } else {
          clients = result
        }
      }
      
      if (!Array.isArray(clients)) {
        clients = []
      }
      
      const currentValue = this.targetAccount.value
      
      this.targetAccount.innerHTML = '<option value="">All Accounts</option>'
      
      const uniqueUsernames = new Set()
      clients.forEach(client => {
        if (client && client.username && client.connected && !uniqueUsernames.has(client.username)) {
          uniqueUsernames.add(client.username)
          const option = document.createElement('option')
          option.value = client.username
          option.textContent = client.username
          this.targetAccount.appendChild(option)
        }
      })
      
      if (currentValue) {
        const optionExists = Array.from(this.targetAccount.options).some(
          opt => opt.value === currentValue
        )
        if (optionExists) {
          this.targetAccount.value = currentValue
        } else {
          this.targetAccount.value = ''
        }
      }
    } catch (error) {
      console.error('Error updating account dropdown:', error)
    }
  }

  /**
   * Loads the selected account from localStorage
   */
  loadAccountSelection () {
    try {
      const saved = localStorage.getItem('spammer-targetAccount')
      if (saved) {
        this.targetAccount.value = saved
      }
    } catch (error) {
      console.error('Error loading account selection:', error)
    }
    
    // Save selection when changed
    this.targetAccount.addEventListener('change', () => {
      try {
        localStorage.setItem('spammer-targetAccount', this.targetAccount.value)
      } catch (error) {
        console.error('Error saving account selection:', error)
      }
    })
  }

  /**
   * Imports templates from a JSON file
   */
  importTemplates () {
    const inputElement = document.createElement('input')
    inputElement.type = 'file'
    inputElement.accept = '.json,.txt'

    inputElement.onchange = async (event) => {
      try {
        const file = event.target.files[0]
        if (!file) return

        const text = await file.text()
        const importedData = JSON.parse(text)

        let existingTemplates = await jam.readJsonFile('spammer-templates.json', [])
        const existingTemplateNames = new Set(existingTemplates.map(t => t.name))
        let newTemplates = []

        if (Array.isArray(importedData)) {
          // It's an array of templates (standard export)
          newTemplates = importedData.filter(t => t.name && t.packets && !existingTemplateNames.has(t.name))
        } else if (typeof importedData === 'object' && importedData !== null && importedData.packets) {
          // It's a single queue object, ask for a name using the modal
          this.saveTemplateModal.classList.remove('hidden')
          this.templateNameInput.focus()

          this.confirmSaveTemplate.onclick = async () => {
            const name = this.templateNameInput.value
            if (name && !existingTemplateNames.has(name)) {
              const newTemplate = { name, packets: importedData.packets }
              const updatedTemplates = [...existingTemplates, newTemplate]
              await jam.writeJsonFile('spammer-templates.json', updatedTemplates)
              this.loadTemplates()
              jam.showToast(`Template '${name}' imported successfully.`, 'success')
            } else if (name) {
              jam.showToast('A template with that name already exists.', 'error')
            }
            this.saveTemplateModal.classList.add('hidden')
            this.templateNameInput.value = ''
            // Restore original save listener
            this.setupModalListeners()
          }

          this.cancelSaveTemplate.onclick = () => {
            this.saveTemplateModal.classList.add('hidden')
            this.templateNameInput.value = ''
            // Restore original save listener
            this.setupModalListeners()
          }
          return // Return here to not proceed with the normal flow
        } else {
          throw new Error('Imported file has an invalid format.')
        }

        if (newTemplates.length === 0) {
          jam.showToast('No new templates to import.', 'info')
          return
        }

        const updatedTemplates = [...existingTemplates, ...newTemplates]
        await jam.writeJsonFile('spammer-templates.json', updatedTemplates)
        
        this.loadTemplates()
        jam.showToast(`${newTemplates.length} new template(s) imported successfully.`, 'success')

      } catch (error) {
        console.error('Error importing templates:', error)
        jam.showToast(`Error importing templates: ${error.message}`, 'error')
      }
    }

    inputElement.click()
  }
}

document.addEventListener('DOMContentLoaded', () => {
  window.spammer = new Spammer()
})
