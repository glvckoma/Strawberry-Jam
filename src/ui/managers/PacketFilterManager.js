const $ = require('jquery')

class PacketFilterManager {
  constructor (application) {
    this.application = application
    this._filters = []
    this._directionFilter = 'all'
    this._searchQuery = ''
    this._onChangeCallbacks = []
  }

  async load () {
    try {
      const { ipcRenderer } = require('electron')
      const filters = await ipcRenderer.invoke('get-setting', 'logs.packetFilters')
      this._filters = Array.isArray(filters) ? filters.slice() : []
    } catch (_) {
      try {
        const raw = this.application.settings.get('logs.packetFilters', [])
        this._filters = Array.isArray(raw) ? raw.slice() : []
      } catch (_) {
        this._filters = []
      }
    }
  }

  _persist () {
    try {
      if (this.application && this.application.settings && this.application.settings.update) {
        this.application.settings.update('logs.packetFilters', this._filters.slice())
      }
    } catch (_) {}
  }

  get filters () {
    return this._filters
  }

  get directionFilter () {
    return this._directionFilter
  }

  get searchQuery () {
    return this._searchQuery
  }

  addFilter (pattern) {
    if (!pattern || typeof pattern !== 'string') return
    const trimmed = pattern.trim()
    if (!trimmed || this._filters.includes(trimmed)) return
    this._filters.push(trimmed)
    this._persist()
    this.applyToDOM()
    this._notifyChange()
  }

  removeFilter (index) {
    if (index < 0 || index >= this._filters.length) return
    this._filters.splice(index, 1)
    this._persist()
    this.applyToDOM()
    this._notifyChange()
  }

  clearAll () {
    if (this._filters.length === 0) return
    this._filters = []
    this._persist()
    this.applyToDOM()
    this._notifyChange()
  }

  setDirectionFilter (direction) {
    this._directionFilter = direction
    this.applyToDOM()
  }

  setSearchQuery (query) {
    this._searchQuery = (query || '').toLowerCase()
    this.applyToDOM()
  }

  shouldShow (message, isIncoming) {
    const dir = isIncoming ? 'incoming' : 'outgoing'
    if (this._directionFilter !== 'all' && this._directionFilter !== dir) return false
    const lc = (message || '').toLowerCase()
    if (this._searchQuery && !lc.includes(this._searchQuery)) return false
    if (this._filters.length > 0 && this._filters.some(f => lc.includes(f.toLowerCase()))) return false
    return true
  }

  applyToDOM () {
    const self = this
    const $packets = $('#message-log').children('div')
    $packets.each(function () {
      const $el = $(this)
      const isIncoming = $el.find('.fa-arrow-down').length > 0
      const msg = $el.attr('data-message') || $el.text()
      const visible = self.shouldShow(msg, isIncoming)
      const currentlyHidden = $el.css('display') === 'none'
      if (visible && currentlyHidden) {
        $el.show()
      } else if (!visible && !currentlyHidden) {
        $el.hide()
      }
    })
  }

  onChange (callback) {
    if (typeof callback === 'function') {
      this._onChangeCallbacks.push(callback)
    }
  }

  _notifyChange () {
    for (const cb of this._onChangeCallbacks) {
      try { cb(this._filters) } catch (_) {}
    }
  }
}

module.exports = PacketFilterManager
