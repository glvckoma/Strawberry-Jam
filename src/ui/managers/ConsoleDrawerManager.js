class ConsoleDrawerManager {
  constructor(application) {
    this.application = application
    this._isOpen = false
    this._unreadCount = 0
    this._$drawer = null
    this._$badge = null
    this._$messages = null
    this._$toggleBar = null
    this._isResizing = false
    this._didDrag = false
    this._startY = 0
    this._startHeight = 0
  }

  initialize() {
    this._$drawer = $('#consoleDrawer')
    this._$badge = $('#consoleBadge')
    this._$messages = $('#messages')
    this._$toggleBar = $('#consoleToggleBar')

    this._loadSavedHeight()
    this._bindToggle()
    this._initDragResize()
  }

  get isOpen() {
    return this._isOpen
  }

  toggle() {
    this._isOpen = !this._isOpen
    if (this._isOpen) {
      this._$drawer.slideDown(200, () => this._scrollToBottom())
      this._$toggleBar.css('cursor', 'ns-resize')
      this.resetUnread()
    } else {
      this._$drawer.slideUp(200)
      this._$toggleBar.css('cursor', 'pointer')
    }
  }

  incrementUnread() {
    this._unreadCount++
    this._updateBadge()
  }

  resetUnread() {
    this._unreadCount = 0
    this._updateBadge()
  }

  _updateBadge() {
    if (!this._$badge) return
    if (this._unreadCount > 0) {
      this._$badge.text(this._unreadCount > 99 ? '99+' : this._unreadCount)
      this._$badge.css('display', 'flex')
    } else {
      this._$badge.css('display', 'none')
      this._$badge.text('0')
    }
  }

  _scrollToBottom() {
    if (this._$messages && this._$messages.length) {
      this._$messages.scrollTop(this._$messages[0].scrollHeight)
    }
  }

  _bindToggle() {
    this._$toggleBar.on('click', () => {
      if (this._didDrag) {
        this._didDrag = false
        return
      }
      this.toggle()
    })
  }

  _initDragResize() {
    this._$toggleBar.on('mousedown', (e) => {
      if (!this._isOpen) return
      this._isResizing = true
      this._startY = e.clientY
      this._startHeight = this._$messages.height()
      e.preventDefault()
    })

    $(document).on('mousemove', (e) => {
      if (!this._isResizing) return
      this._didDrag = true
      const delta = this._startY - e.clientY
      const newHeight = Math.max(80, Math.min(window.innerHeight * 0.6, this._startHeight + delta))
      this._$messages.css('height', newHeight + 'px')
    })

    $(document).on('mouseup', () => {
      if (!this._isResizing) return
      this._isResizing = false
      this._saveHeight()
    })
  }

  _loadSavedHeight() {
    try {
      const settings = this.application.settings
      if (settings && settings.get) {
        const savedHeight = settings.get('ui.consoleDrawerHeight', 200)
        if (savedHeight && this._$messages) {
          this._$messages.css('height', savedHeight + 'px')
        }
      }
    } catch (_) {}
  }

  _saveHeight() {
    try {
      const settings = this.application.settings
      if (settings && settings.update) {
        const currentHeight = this._$messages.height()
        settings.update('ui.consoleDrawerHeight', currentHeight)
      }
    } catch (_) {}
  }
}

module.exports = ConsoleDrawerManager
