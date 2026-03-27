const $ = require('jquery')

class PacketFilterManager {
  constructor (application) {
    this.application = application
    this._filters = []
    this._directionFilter = 'all'
    this._searchQuery = ''
    this._onChangeCallbacks = []
  }

  _normalizeFilter (entry) {
    if (typeof entry === 'string') return { pattern: entry, mode: 'contains' }
    if (entry && typeof entry.pattern === 'string') {
      return { pattern: entry.pattern, mode: entry.mode === 'exact' ? 'exact' : 'contains' }
    }
    return null
  }

  async load () {
    try {
      const { ipcRenderer } = require('electron')
      const filters = await ipcRenderer.invoke('get-setting', 'logs.packetFilters')
      this._filters = Array.isArray(filters) ? filters.map(f => this._normalizeFilter(f)).filter(Boolean) : []
    } catch (_) {
      try {
        const raw = this.application.settings.get('logs.packetFilters', [])
        this._filters = Array.isArray(raw) ? raw.map(f => this._normalizeFilter(f)).filter(Boolean) : []
      } catch (_) {
        this._filters = []
      }
    }
  }

  _persist () {
    try {
      if (this.application && this.application.settings && this.application.settings.update) {
        this.application.settings.update('logs.packetFilters', this._filters.map(f => ({ pattern: f.pattern, mode: f.mode })))
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

  addFilter (pattern, mode = 'contains') {
    if (!pattern || typeof pattern !== 'string') return
    const trimmed = pattern.trim()
    if (!trimmed || this._filters.some(f => f.pattern === trimmed)) return
    this._filters.push({ pattern: trimmed, mode })
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

  toggleFilterMode (index) {
    if (index < 0 || index >= this._filters.length) return
    this._filters[index].mode = this._filters[index].mode === 'exact' ? 'contains' : 'exact'
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
    if (this._filters.length > 0 && this._filters.some(f => {
      const fp = f.pattern.toLowerCase()
      return f.mode === 'exact' ? lc === fp : lc.includes(fp)
    })) return false
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
