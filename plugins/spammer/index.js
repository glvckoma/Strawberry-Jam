const { dispatch } = jam

/**
 * Elements
 */
const input = document.getElementById('inputTxt')
const inputType = document.getElementById('inputType')
const inputDelay = document.getElementById('inputDelay')
const inputRunType = document.getElementById('inputRunType')
const stopButton = document.getElementById('stopButton')
const runButton = document.getElementById('runButton')
const table = document.getElementById('table')

stopButton.disabled = true

const tab = ' '.repeat(2)

let runner
let runnerType
let runnerRow
let activeRow = null

class Spammer {
  constructor () {
    /**
     * Handles input events for tab support in textarea
     */
    input.onkeydown = e => {
      const keyCode = e.which

      if (keyCode === 9) {
        e.preventDefault()

        const s = input.selectionStart
        input.value = input.value.substring(0, input.selectionStart) + tab + input.value.substring(input.selectionEnd)
        input.selectionEnd = s + tab.length
      }
    }
  }

  /**
   * Sends a packet
   * @param {string|string[]} content - The packet content
   * @param {string} type - The packet type (aj or connection)
   */
  async sendPacket (content, type) {
    if (!content) return

    content = content || input.value

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
      if (type === 'aj') dispatch.sendRemoteMessage(content)
      else dispatch.sendConnectionMessage(content)
    } catch (error) {
      console.error('Error sending packet:', error)
    }
  }

  /**
   * Adds a packet to the queue
   */
  addClick () {
    if (!input.value) return

    const type = inputType.value
    const content = input.value
    const delay = inputDelay.value

    const row = table.insertRow(-1)
    row.className = 'hover:bg-tertiary-bg/20 transition'

    const typeCell = row.insertCell(0)
    const contentCell = row.insertCell(1)
    const delayCell = row.insertCell(2)
    const actionCell = row.insertCell(3)

    typeCell.className = 'py-2 px-3 text-xs'
    contentCell.className = 'py-2 px-3 text-xs truncate max-w-[300px]'
    delayCell.className = 'py-2 px-3 text-xs'
    actionCell.className = 'py-2 px-3 text-xs'

    typeCell.innerText = type
    contentCell.innerText = content
    delayCell.innerText = delay

    contentCell.title = content

    actionCell.innerHTML = `
      <button type="button" class="px-2 py-1 bg-tertiary-bg hover:bg-sidebar-hover text-text-primary rounded-md transition text-xs" onclick="spammer.deleteRow(this)">
        <i class="fas fa-trash-alt"></i>
      </button>
    `
  }

  /**
   * Deletes a row from the queue
   */
  deleteRow (btn) {
    const row = btn.closest('tr')
    row.parentNode.removeChild(row)
  }

  /**
   * Sends the current packet
   */
  sendClick () {
    const content = input.value
    if (!content) return

    const type = inputType.value

    try {
      const packets = content.match(/[^\r\n]+/g)
      if (packets && packets.length > 1) {
        this.sendPacket(packets, type)
      } else {
        this.sendPacket(content, type)
      }
    } catch (error) {
      console.error('Error sending packet:', error)
    }
  }

  /**
   * Starts running the queue
   */
  runClick () {
    if (table.rows.length <= 1) {
      return
    }

    stopButton.disabled = false
    runButton.disabled = true
    runnerRow = 0
    runnerType = inputRunType.value

    this.runNext()
  }

  /**
   * Processes the next packet in the queue
   */
  runNext () {
    if (activeRow) {
      activeRow.classList.remove('bg-tertiary-bg/40')
    }

    const row = table.rows[runnerRow++]

    if (!row) {
      if (runnerType === 'loop') {
        runnerRow = 0
        this.runNext()
      } else {
        this.stopClick()
      }
      return
    }

    const type = row.cells[0].innerText
    const content = row.cells[1].innerText
    const delay = parseFloat(row.cells[2].innerText)

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
    runButton.disabled = false
    stopButton.disabled = true

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
    for (let i = 1; i < table.rows.length; i++) {
      const row = table.rows[i]
      const type = row.cells[0].innerText
      const content = row.cells[1].innerText
      const delay = row.cells[2].innerText
      packets.push({ type, content, delay })
    }

    const data = {
      input: input.value,
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

        input.value = data.input || ''

        while (table.rows.length > 1) {
          table.deleteRow(1)
        }

        if (data.packets && Array.isArray(data.packets)) {
          data.packets.forEach(packet => {
            const row = table.insertRow(-1)
            row.className = 'hover:bg-tertiary-bg/20 transition'

            const typeCell = row.insertCell(0)
            const contentCell = row.insertCell(1)
            const delayCell = row.insertCell(2)
            const actionCell = row.insertCell(3)

            typeCell.className = 'py-2 px-3 text-xs'
            contentCell.className = 'py-2 px-3 text-xs truncate max-w-[300px]'
            delayCell.className = 'py-2 px-3 text-xs'
            actionCell.className = 'py-2 px-3 text-xs'

            typeCell.innerText = packet.type
            contentCell.innerText = packet.content
            delayCell.innerText = packet.delay

            contentCell.title = packet.content

            actionCell.innerHTML = `
              <button type="button" class="px-2 py-1 bg-tertiary-bg hover:bg-sidebar-hover text-text-primary rounded-md transition text-xs" onclick="spammer.deleteRow(this)">
                <i class="fas fa-trash-alt"></i>
              </button>
            `
          })
        }
      } catch (error) {
        console.error('Error loading file:', error)
      }
    }

    inputElement.click()
  }
}

const spammer = new Spammer()
