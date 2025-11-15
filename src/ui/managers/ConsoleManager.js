const { ipcRenderer } = require('electron')

/**
 * ConsoleManager - Manages console message display and logging
 * 
 * @module ConsoleManager
 */
class ConsoleManager {
  constructor(application, messageIcons) {
    this.application = application
    this.messageIcons = messageIcons
    
    this._packetLogCount = 0
    this._appMessageCount = 0
    this._consoleLogLimit = 1000
    this._networkLogLimit = 1000
    this._maxLogEntries = 1000
    this._cleanPercentage = 0.4
  }

  /**
   * Displays a new console message.
   * @param {Object} params - Message parameters
   * @param {string} params.message - Message text
   * @param {string} [params.type='success'] - Message type
   * @param {boolean} [params.withStatus=true] - Show status icon
   * @param {boolean} [params.time=true] - Show timestamp
   * @param {boolean} [params.isPacket=false] - Is packet log
   * @param {boolean} [params.isIncoming=false] - Is incoming packet
   * @param {Object} [params.details=null] - Additional details
   * @param {string} [params.style=''] - Custom styles
   * @public
   */
  message({ message, type = 'success', withStatus = true, time = true, isPacket = false, isIncoming = false, details = null, style = '' } = {}) {
    const baseTypeClasses = {
      success: 'bg-highlight-green/10 border-l-4 border-highlight-green text-highlight-green',
      error: 'bg-error-red/10 border-l-4 border-error-red text-error-red',
      wait: 'bg-tertiary-bg/30 border-l-4 border-tertiary-bg text-gray-300',
      celebrate: 'bg-purple-500/10 border-l-4 border-purple-500 text-purple-400',
      warn: 'bg-highlight-yellow/10 border-l-4 border-highlight-yellow text-highlight-yellow',
      notify: 'bg-blue-500/10 border-l-4 border-blue-500 text-blue-400',
      welcome: 'bg-red-600/10 border-l-4 border-red-500 text-white',
      speech: 'bg-primary-bg/10 border-l-4 border-primary-bg text-text-primary',
      logger: 'bg-gray-700/30 border-l-4 border-gray-600 text-gray-300',
      action: 'bg-teal-500/10 border-l-4 border-teal-500 text-teal-400'
    }

    const packetTypeClasses = {
      incoming: 'bg-tertiary-bg/20 border-l-4 border-highlight-green text-text-primary',
      outgoing: 'bg-highlight-green/5 border-l-4 border-highlight-yellow text-text-primary'
    }

    const createElement = (tag, classes = '', content = '') => {
      return $('<' + tag + '>').addClass(classes + ' message-animate-in').html(content)
    }

    const getTime = () => {
      const now = new Date()
      const hour = String(now.getHours()).padStart(2, '0')
      const minute = String(now.getMinutes()).padStart(2, '0')
      const second = String(now.getSeconds()).padStart(2, '0')
      return `${hour}:${minute}:${second}`
    }

    const status = (type, message) => {
      const icon = this.messageIcons[type]
      if (!icon) throw new Error('Invalid Status Type.')
      return `
        <div class="flex items-center space-x-2 w-full">
          <div class="flex">
            <i class="fas ${icon} mr-2"></i>
          </div>
          <span>${message || ''}</span>
        </div>
      `
    }

    const $container = createElement(
      'div',
      'flex items-start p-3 rounded-md mb-2 shadow-sm max-w-full w-full transition-colors duration-150 hover:bg-opacity-20'
    )

    if (isPacket) {
      $container.addClass(packetTypeClasses[isIncoming ? 'incoming' : 'outgoing'])
    } else {
      $container.addClass(baseTypeClasses[type] || 'bg-tertiary-bg/10 border-l-4 border-tertiary-bg text-text-primary')
    }

    if (isPacket) {
      const iconClass = isIncoming ? 'fa-arrow-down text-highlight-green' : 'fa-arrow-up text-highlight-yellow'
      const $iconContainer = createElement('div', 'flex items-center mr-3 text-base', `<i class="fas ${iconClass}"></i>`)
      $container.append($iconContainer)
    } else if (time) {
      const $timeContainer = createElement('div', 'text-xs text-gray-500 mr-3 whitespace-nowrap font-mono', getTime())
      $container.append($timeContainer)
    }

    const $messageContainer = createElement(
      'div',
      isPacket
        ? 'text-xs flex-1 break-all leading-relaxed'
        : 'flex-1 text-xs flex items-center space-x-2 leading-relaxed'
    )

    if (withStatus && !isPacket) {
      $messageContainer.html(status(type, message))
    } else {
      $messageContainer.text(message)
      if (isPacket) {
        $messageContainer.addClass('font-mono')
      }
    }

    if (style) {
      $messageContainer.attr('style', style)
    }

    $messageContainer.css({
      overflow: 'hidden',
      'text-overflow': 'ellipsis',
      'white-space': 'normal',
      'word-break': 'break-word'
    })

    $container.append($messageContainer)
    
    if (details && details.messageId) {
      $container.attr('data-message-id', details.messageId)
    }

    if (isPacket && details) {
      const $actionsContainer = createElement('div', 'flex ml-2 items-center')

      const $detailsButton = createElement(
        'button',
        'text-xs text-gray-400 hover:text-text-primary transition-colors px-2 py-1 rounded hover:bg-tertiary-bg/20',
        '<i class="fas fa-code mr-1"></i> Details'
      )

      const $copyButton = createElement(
        'button',
        'text-xs text-gray-400 hover:text-text-primary transition-colors ml-1 px-2 py-1 rounded hover:bg-tertiary-bg/20',
        '<i class="fas fa-copy mr-1"></i> Copy'
      )

      $copyButton.on('click', (e) => {
        e.stopPropagation()
        navigator.clipboard.writeText(message)

        const originalHtml = $copyButton.html()
        $copyButton.html('<i class="fas fa-check mr-1"></i> Copied!')
        $copyButton.addClass('text-highlight-green')

        setTimeout(() => {
          $copyButton.html(originalHtml)
          $copyButton.removeClass('text-highlight-green')
        }, 1500)
      })

      $actionsContainer.append($detailsButton, $copyButton)
      $container.append($actionsContainer)

      const $detailsContainer = createElement(
        'div',
        'bg-tertiary-bg/50 rounded-md p-3 mt-2 hidden w-full',
        `<pre class="text-xs text-text-primary overflow-auto max-h-[300px] font-mono">${JSON.stringify(details, null, 2)}</pre>`
      )

      $detailsButton.on('click', (e) => {
        e.stopPropagation()
        $detailsContainer.toggleClass('hidden')
        const isHidden = $detailsContainer.hasClass('hidden')
        
        if (isHidden) {
          $detailsButton.html('<i class="fas fa-chevron-down mr-1 smooth-chevron"></i> Details')
          $detailsButton.find('i').css('transform', 'rotate(0deg)')
        } else {
          $detailsButton.html('<i class="fas fa-chevron-down mr-1 smooth-chevron"></i> Hide')
          $detailsButton.find('i').css('transform', 'rotate(180deg)')
        }
      })

      $container.after($detailsContainer)

      $container.css('cursor', 'pointer')
      $container.on('click', function (e) {
        if (!$(e.target).closest('button').length) {
          $detailsButton.click()
        }
      })
    }

    const $targetContainer = isPacket ? $('#message-log') : $('#messages')
    
    if (isPacket) {
      const $totalCount = $('#totalCount')
      const $incomingCount = $('#incomingCount')
      const $outgoingCount = $('#outgoingCount')

      const totalCount = parseInt($totalCount.text() || '0', 10) + 1
      $totalCount.text(totalCount)

      if (isIncoming) {
        const incomingCount = parseInt($incomingCount.text() || '0', 10) + 1
        $incomingCount.text(incomingCount)
      } else {
        const outgoingCount = parseInt($outgoingCount.text() || '0', 10) + 1
        $outgoingCount.text(outgoingCount)
      }
      
      this._packetLogCount++
      if (this._packetLogCount > this._networkLogLimit) {
        this.cleanOldLogs($targetContainer, true)
      }
    } else {
      this._appMessageCount++
      if (this._appMessageCount > this._consoleLogLimit) {
        this.cleanOldLogs($targetContainer, false)
      }
    }

    $targetContainer.append($container)

    const isAtBottom = $targetContainer.scrollTop() + $targetContainer.innerHeight() >= $targetContainer[0].scrollHeight - 30
    if (isAtBottom) {
      $targetContainer.scrollTop($targetContainer[0].scrollHeight)
    }

    if (window.applyFilter) window.applyFilter()
  }

  /**
   * Updates an existing console message by its data-message-id.
   * @param {string} messageId - The identifier used when the message was created
   * @param {Object} params - Update parameters
   * @param {string} params.message - New message text
   * @param {string} [params.type='success'] - New message type
   * @returns {boolean} True if updated, false if not found
   * @public
   */
  updateMessage(messageId, { message, type = 'success' } = {}) {
    try {
      if (!messageId) return false
      const $existing = $(`[data-message-id='${messageId}']`)
      if (!$existing || $existing.length === 0) return false

      const $textSpan = $existing.find('span').last()
      if ($textSpan && $textSpan.length) {
        $textSpan.text(message || '')
      }

      const icon = this.messageIcons[type]
      if (icon) {
        const $icon = $existing.find('i.fas').first()
        if ($icon && $icon.length) {
          $icon.attr('class', `fas ${icon} mr-2`)
        }
      }

      return true
    } catch (_) {
      return false
    }
  }

  /**
   * Cleans old log entries from the specified container.
   * @param {JQuery<HTMLElement>} $logContainer - The jQuery object for the log container
   * @param {boolean} isPacketLog - Whether the container is for packet logs
   * @private
   */
  cleanOldLogs($logContainer, isPacketLog) {
    const maxEntries = isPacketLog ? this._networkLogLimit : this._consoleLogLimit
    
    const entriesToRemove = Math.floor(maxEntries * this._cleanPercentage)
    const $entries = $logContainer.children('div')
    const currentTotal = $entries.length

    if (currentTotal <= maxEntries) {
      return
    }

    const numberToRemove = Math.min(entriesToRemove, currentTotal - (maxEntries * (1 - this._cleanPercentage)))
    const logsToRemove = $entries.slice(0, numberToRemove)

    let removedIncoming = 0
    let removedOutgoing = 0

    if (isPacketLog) {
      logsToRemove.each(function() {
        if ($(this).hasClass('bg-tertiary-bg/20')) {
          removedIncoming++
        } else if ($(this).hasClass('bg-highlight-green/5')) {
          removedOutgoing++
        }
      })
    }

    logsToRemove.remove()

    const newCount = $logContainer.children('div').length

    if (isPacketLog) {
      this._packetLogCount = newCount

      const $totalCount = $('#totalCount')
      const $incomingCount = $('#incomingCount')
      const $outgoingCount = $('#outgoingCount')

      const currentTotalCount = parseInt($totalCount.text() || '0', 10)
      const currentIncomingCount = parseInt($incomingCount.text() || '0', 10)
      const currentOutgoingCount = parseInt($outgoingCount.text() || '0', 10)

      $totalCount.text(Math.max(0, currentTotalCount - numberToRemove))
      $incomingCount.text(Math.max(0, currentIncomingCount - removedIncoming))
      $outgoingCount.text(Math.max(0, currentOutgoingCount - removedOutgoing))
    } else {
      this._appMessageCount = newCount
    }
  }

  /**
   * Loads log limit settings from user settings.
   * @returns {Promise<void>}
   * @public
   */
  async loadLogLimitSettings() {
    try {
      let consoleLogLimit, networkLogLimit
      
      try {
        consoleLogLimit = await ipcRenderer.invoke('get-setting', 'logs.consoleLimit')
        networkLogLimit = await ipcRenderer.invoke('get-setting', 'logs.networkLimit')
      } catch (error) {
        console.error('Error with direct IPC call:', error)
        consoleLogLimit = this.application.settings.get('logs.consoleLimit')
        networkLogLimit = this.application.settings.get('logs.networkLimit')
      }

      this._consoleLogLimit = consoleLogLimit !== undefined && consoleLogLimit !== null 
        ? Math.max(100, Math.min(10000, parseInt(consoleLogLimit) || 1000))
        : 1000
      
      this._networkLogLimit = networkLogLimit !== undefined && networkLogLimit !== null
        ? Math.max(100, Math.min(10000, parseInt(networkLogLimit) || 1000))
        : 1000
      
      this._maxLogEntries = Math.max(this._consoleLogLimit, this._networkLogLimit)
      
    } catch (error) {
      this._consoleLogLimit = 1000
      this._networkLogLimit = 1000
      this._maxLogEntries = 1000
    }
  }

  /**
   * Clears all console log messages.
   * @private
   */
  clearMessages() {
    const $messages = $('#messages')
    $messages.empty()
    this._appMessageCount = 0
  }
  
  /**
   * Removes all messages with a specific ID.
   * @param {string} messageId - The ID of the message(s) to remove
   * @private
   */
  removeMessageById(messageId) {
    if (!messageId) return
    
    const messageElements = document.querySelectorAll(`[data-message-id='${messageId}']`)
    
    if (messageElements && messageElements.length > 0) {
      messageElements.forEach(element => {
        $(element).fadeOut(200, function() {
          $(this).remove()
        })
      })
    }
  }

  /**
   * Gets packet log count
   * @returns {number}
   */
  getPacketLogCount() {
    return this._packetLogCount
  }

  /**
   * Gets app message count
   * @returns {number}
   */
  getAppMessageCount() {
    return this._appMessageCount
  }

  /**
   * Sets packet log count
   * @param {number} count
   */
  setPacketLogCount(count) {
    this._packetLogCount = count
  }

  /**
   * Sets app message count
   * @param {number} count
   */
  setAppMessageCount(count) {
    this._appMessageCount = count
  }
}

module.exports = ConsoleManager

