const { ipcRenderer } = require('electron')

class GameLauncher {
  constructor(application) {
    this.application = application
    this._isLaunching = false
  }

  async openAnimalJam() {
    if (this._isLaunching) return

    const btn = this.application.$playGameBtn
    if (!btn) {
      this.application.$playGameBtn = document.getElementById('playGameBtn')
      if (!this.application.$playGameBtn) return
    }

    const $btn = this.application.$playGameBtn

    if (this.application._isGameRunning) {
      try {
        const allowMultipleInstances = await ipcRenderer.invoke('get-setting', 'ui.allowMultipleInstances')

        if (!allowMultipleInstances) {
          this.application.consoleMessage({
            message: 'Strawberry Jam Classic is already running!',
            type: 'warning'
          })
          return
        }

        this.application.consoleMessage({
          message: 'Multiple instance mode enabled - launching additional instance.',
          type: 'notify'
        })
      } catch (error) {
        this.application.consoleMessage({
          message: 'Strawberry Jam Classic is already running!',
          type: 'warning'
        })
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
            if (allowMultipleInstances) {
              this.application._removeGameRunningTooltip()
            } else {
              $btn.classList.add('opacity-100')
              this.application._addGameRunningTooltip()
            }
          } catch (error) {
            $btn.classList.add('opacity-100')
            this.application._addGameRunningTooltip()
          }
        } else {
          this.application._removeGameRunningTooltip()
        }
      }
    }
  }

  handleGameProcessExit() {
    this.application._isGameRunning = false

    if (this.application.$playGameBtn) {
      this.application.$playGameBtn.classList.remove('opacity-100')
      this.application._removeGameRunningTooltip()
    }

    this.application.consoleMessage({
      message: 'Strawberry Jam Classic has closed. All plugins have been closed.',
      type: 'notify'
    })
  }
}

module.exports = GameLauncher
