const { ipcRenderer } = require('electron')

class GameLauncher {
  constructor(application) {
    this.application = application
    this._isLaunching = false
    this._portConflictWarningShown = false
  }

  async openAnimalJam() {
    if (this._isLaunching) return

    const btn = this.application.$playGameBtn
    if (!btn) {
      this.application.$playGameBtn = document.getElementById('playGameBtn')
      if (!this.application.$playGameBtn) return
    }

    const $btn = this.application.$playGameBtn

    if (!this._portConflictWarningShown && this.application.hasPortConflicts()) {
      this._portConflictWarningShown = true
      this._showHeaderNotification('Ports occupied, check console!', 'warning')
      return
    }

    if (this.application._isGameRunning) {
      try {
        const allowMultipleInstances = await ipcRenderer.invoke('get-setting', 'ui.allowMultipleInstances')

        if (!allowMultipleInstances) {
          this._showHeaderNotification('Strawberry Jam is already running', 'error')
          return
        }

        this.application.consoleMessage({
          message: 'Multiple instance mode enabled - launching additional instance.',
          type: 'notify'
        })
      } catch (error) {
        this._showHeaderNotification('Strawberry Jam is already running', 'error')
        return
      }
    }

    this._isLaunching = true
    $btn.classList.add('opacity-50', 'pointer-events-none')

    const startMessageId = `start-aj-${Date.now()}`
    let launchSuccessful = false

    try {
      this.application.consoleMessage({
        message: 'Starting Strawberry Jam Classic...',
        type: 'wait',
        details: { messageId: startMessageId }
      })

      await this.application.patcher.killProcessAndPatch()

      launchSuccessful = true
      this.application._isGameRunning = true

    } catch (error) {
      this.application.consoleMessage({
        message: `Error launching Animal Jam Classic: ${error.message}`,
        type: 'error'
      })
    } finally {
      this._isLaunching = false

      if (launchSuccessful) {
        await new Promise(resolve => setTimeout(resolve, 1000))
        this.application._removeMessageById(startMessageId)
        this.application.consoleMessage({
          message: 'Successfully launched Strawberry Jam Classic!',
          type: 'success'
        })
      }

      if ($btn) {
        $btn.classList.remove('opacity-50', 'pointer-events-none')

        if (this.application._isGameRunning) {
          try {
            const allowMultipleInstances = await ipcRenderer.invoke('get-setting', 'ui.allowMultipleInstances')
            if (!allowMultipleInstances) {
              $btn.classList.add('opacity-100')
              this._showHeaderNotification('Strawberry Jam is already running', 'error')
            }
          } catch (error) {
            $btn.classList.add('opacity-100')
            this._showHeaderNotification('Strawberry Jam is already running', 'error')
          }
        }
      }
    }
  }

  handleGameProcessExit() {
    this.application._isGameRunning = false

    if (this.application.$playGameBtn) {
      this.application.$playGameBtn.classList.remove('opacity-100')
    }

    this.application.consoleMessage({
      message: 'Strawberry Jam Classic has closed. All plugins have been closed.',
      type: 'notify'
    })
  }
  _showHeaderNotification(text, type = 'warning') {
    const el = document.getElementById('headerNotification')
    if (!el) return

    const colors = {
      error: { bg: 'rgba(220, 38, 38, 0.15)', border: 'rgba(220, 38, 38, 0.3)', text: '#ef4444', icon: 'fa-circle-xmark' },
      warning: { bg: 'rgba(234, 179, 8, 0.12)', border: 'rgba(234, 179, 8, 0.25)', text: '#eab308', icon: 'fa-triangle-exclamation' }
    }
    const c = colors[type] || colors.warning

    el.style.background = c.bg
    el.style.border = `1px solid ${c.border}`
    el.style.color = c.text
    el.style.display = 'flex'
    el.style.animation = 'none'
    void el.offsetWidth
    el.style.animation = 'fadeInLeft 0.2s ease-out forwards'
    el.innerHTML = `<i class="fas ${c.icon}" style="font-size: 10px;"></i>${text}`

    if (this._headerNotificationTimer) clearTimeout(this._headerNotificationTimer)
    this._headerNotificationTimer = setTimeout(() => {
      el.style.animation = 'fadeOutRight 0.25s ease-in forwards'
      setTimeout(() => { el.style.display = 'none' }, 250)
    }, 4000)
  }
}

module.exports = GameLauncher
