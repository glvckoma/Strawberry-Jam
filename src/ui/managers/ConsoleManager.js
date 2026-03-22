const { ipcRenderer } = require('electron')

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

    this._suppressedTypes = new Set()
    this._suppressedPatterns = []
    this._quietMode = false
    this._deduplicationCategories = {
      reapplied: 'data-log-category-reapplied',
      closed: 'data-log-category-closed',
      started: 'data-log-category-started'
    }
  }

  message({ message, type = 'success', withStatus = true, time = true, isPacket = false, isIncoming = false, details = null, style = '' } = {}) {
    if (this._shouldSuppressMessage(message, type)) {
      return
    }

    if (isPacket && this.application.packetFilterManager) {
      if (!this.application.packetFilterManager.shouldShow(message, isIncoming)) return
    }

    const logCategory = this._getLogCategory(message)
    if (logCategory) {
      this._removePreviousLogByCategory(logCategory)
    }

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
      incoming: 'bg-tertiary-bg/20 border-l-4 text-text-primary',
      outgoing: 'bg-tertiary-bg/10 border-l-4 text-text-primary'
    }

    const packetBorderColors = {
      incoming: 'var(--packet-incoming-color, #10b981)',
      outgoing: 'var(--packet-outgoing-color, #eab308)'
    }

    const createElement = (tag, classes = '', content = '') => {
      return $('<' + tag + '>').addClass(classes + ' message-animate-in').html(content)
    }

    const getTime = () => {
      const now = new Date()
      const useMilitary = this.application && this.application.settings
        ? this.application.settings.get('ui.militaryTime', false)
        : false
      const minute = String(now.getMinutes()).padStart(2, '0')
      const second = String(now.getSeconds()).padStart(2, '0')
      if (useMilitary) {
        const hour = String(now.getHours()).padStart(2, '0')
        return `${hour}:${minute}:${second}`
      }
      let hour = now.getHours()
      const period = hour >= 12 ? 'PM' : 'AM'
      hour = hour % 12 || 12
      return `${hour}:${minute}:${second} ${period}`
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
      'flex items-start p-3 rounded-md mb-2 shadow-sm max-w-full w-full'
    )

    if (isPacket) {
      const packetDir = isIncoming ? 'incoming' : 'outgoing'
      $container.addClass(packetTypeClasses[packetDir])
      $container.css('border-left-color', packetBorderColors[packetDir])
    } else {
      $container.addClass(baseTypeClasses[type] || 'bg-tertiary-bg/10 border-l-4 border-tertiary-bg text-text-primary')
    }

    if (isPacket) {
      $container.attr('data-packet', 'true').attr('data-message', message)
      const iconClass = isIncoming ? 'fa-arrow-down' : 'fa-arrow-up'
      const iconColor = isIncoming
        ? 'var(--packet-incoming-color, #10b981)'
        : 'var(--packet-outgoing-color, #eab308)'
      const $iconContainer = createElement('div', 'flex items-center mr-3 text-base', `<i class="fas ${iconClass}" style="color: ${iconColor};"></i>`)
      $container.append($iconContainer)
    } else if (time) {
      const $timeContainer = createElement('div', 'text-xs text-gray-500 mr-3 whitespace-nowrap font-mono', getTime())
      $container.append($timeContainer)
    }

    const $messageContainer = createElement(
      'div',
      isPacket
        ? 'flex-1 break-all leading-relaxed'
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
      'white-space': 'normal',
      'word-break': 'break-all'
    })


    $container.append($messageContainer)

    if (details && details.messageId) {
      $container.attr('data-message-id', details.messageId)
    }

    if (logCategory) {
      $container.attr(this._deduplicationCategories[logCategory], 'true')
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

    if (isPacket && this.application.packetFilterManager) {
      if (!this.application.packetFilterManager.shouldShow(message, isIncoming)) {
        $container.hide()
      }
    }

    $targetContainer.append($container)

    const isAtBottom = $targetContainer.scrollTop() + $targetContainer.innerHeight() >= $targetContainer[0].scrollHeight - 30
    if (isAtBottom) {
      $targetContainer.scrollTop($targetContainer[0].scrollHeight)
    }

    if (!isPacket && this.application.consoleDrawerManager && !this.application.consoleDrawerManager.isOpen) {
      this.application.consoleDrawerManager.incrementUnread()
    }
  }

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

  clearMessages() {
    const $messages = $('#messages')
    $messages.empty()
    this._appMessageCount = 0
  }

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

  getPacketLogCount() {
    return this._packetLogCount
  }

  getAppMessageCount() {
    return this._appMessageCount
  }

  setPacketLogCount(count) {
    this._packetLogCount = count
  }

  setAppMessageCount(count) {
    this._appMessageCount = count
  }

  _shouldSuppressMessage(message, type) {
    if (type === 'error' || type === 'warn') {
      return false
    }

    if (this._suppressedTypes.has(type)) {
      return true
    }

    for (const pattern of this._suppressedPatterns) {
      if (pattern.test(message)) {
        return true
      }
    }

    if (this._quietMode) {
      if (type === 'notify' && (message.includes('reapplied') || message.includes('closed') || message.includes('Console logs cleared'))) {
        return true
      }
      if (type === 'success' && message.includes('Successfully launched Strawberry Jam Classic')) {
        return true
      }
    }

    return false
  }

  suppressMessageType(type) {
    this._suppressedTypes.add(type)
  }

  allowMessageType(type) {
    this._suppressedTypes.delete(type)
  }

  suppressMessagePattern(pattern) {
    if (pattern instanceof RegExp) {
      this._suppressedPatterns.push(pattern)
    } else if (typeof pattern === 'string') {
      this._suppressedPatterns.push(new RegExp(pattern, 'i'))
    }
  }

  setQuietMode(enabled) {
    this._quietMode = enabled
    if (this.application && this.application.settings) {
      this.application.settings.update('ui.quietMode', enabled).catch(() => {})
    }
  }

  getQuietMode() {
    return this._quietMode
  }

  clearFilters() {
    this._suppressedTypes.clear()
    this._suppressedPatterns = []
    this._quietMode = false
  }

  _getLogCategory(message) {
    if (!message || typeof message !== 'string') {
      return null
    }

    const lowerMessage = message.toLowerCase()

    if (lowerMessage.includes('was reapplied') || lowerMessage.includes('reapplied')) {
      return 'reapplied'
    }

    if (lowerMessage.includes('has closed') || lowerMessage.includes('closed')) {
      return 'closed'
    }

    if (lowerMessage.includes('successfully launched') || lowerMessage.includes('started')) {
      return 'started'
    }

    return null
  }

  _removePreviousLogByCategory(category) {
    if (!category || !this._deduplicationCategories[category]) {
      return
    }

    const $targetContainer = $('#messages')
    const selector = `[${this._deduplicationCategories[category]}="true"]`
    const $existingLogs = $targetContainer.find(selector)

    if ($existingLogs.length > 0) {
      const self = this
      $existingLogs.each(function() {
        const $log = $(this)
        const wasIncoming = $log.hasClass('bg-tertiary-bg/20')
        const wasOutgoing = $log.hasClass('bg-highlight-green/5')

        $log.remove()

        if (wasIncoming || wasOutgoing) {
          const $totalCount = $('#totalCount')
          const $incomingCount = $('#incomingCount')
          const $outgoingCount = $('#outgoingCount')

          if ($totalCount.length) {
            const currentTotal = parseInt($totalCount.text() || '0', 10)
            $totalCount.text(Math.max(0, currentTotal - 1))
          }

          if (wasIncoming && $incomingCount.length) {
            const currentIncoming = parseInt($incomingCount.text() || '0', 10)
            $incomingCount.text(Math.max(0, currentIncoming - 1))
          } else if (wasOutgoing && $outgoingCount.length) {
            const currentOutgoing = parseInt($outgoingCount.text() || '0', 10)
            $outgoingCount.text(Math.max(0, currentOutgoing - 1))
          }

          const currentPacketCount = self.getPacketLogCount()
          self.setPacketLogCount(Math.max(0, currentPacketCount - 1))
        } else {
          const currentAppCount = self.getAppMessageCount()
          self.setAppMessageCount(Math.max(0, currentAppCount - 1))
        }
      })
    }
  }
}

module.exports = ConsoleManager
