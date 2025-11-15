const { ipcRenderer } = require('electron')

/**
 * GameLauncher - Manages game launching and process handling
 * 
 * @module GameLauncher
 */
class GameLauncher {
  constructor(application) {
    this.application = application
  }

  /**
   * Opens Animal Jam Classic, disabling the button during patching
   * @returns {Promise<void>}
   * @public
   */
  async openAnimalJam() {
    if (!this.application.$playButton) {
      console.error("Play button element not found!")
      this.application.$playButton = document.getElementById('playButton')
      if (!this.application.$playButton) return
    }

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

    this.application.$playButton.classList.add('opacity-50', 'pointer-events-none')
    this.application.$playButton.onclick = () => false
    
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
      if (launchSuccessful) {
        await new Promise(resolve => setTimeout(resolve, 1000))
        this.application._removeMessageById(startMessageId)
        this.application.consoleMessage({
          message: 'Successfully launched Strawberry Jam Classic!',
          type: 'success'
        })
      }
      
      if (this.application.$playButton) {
        if (this.application._isGameRunning) {
          try {
            const allowMultipleInstances = await ipcRenderer.invoke('get-setting', 'ui.allowMultipleInstances')
            
            if (allowMultipleInstances) {
              this.application.$playButton.classList.remove('opacity-50', 'pointer-events-none')
              this.application.$playButton.onclick = () => jam.application.openAnimalJam()
              this.application._removeGameRunningTooltip()
            } else {
              this.application.$playButton.classList.remove('opacity-50', 'pointer-events-none')
              this.application.$playButton.classList.add('opacity-100')
              this.application.$playButton.onclick = () => jam.application.openAnimalJam()
              this.application._addGameRunningTooltip()
            }
          } catch (error) {
            this.application.$playButton.classList.remove('opacity-50', 'pointer-events-none')
            this.application.$playButton.classList.add('opacity-100')
            this.application.$playButton.onclick = () => jam.application.openAnimalJam()
            this.application._addGameRunningTooltip()
          }
        } else {
          this.application.$playButton.classList.remove('opacity-50', 'pointer-events-none')
          this.application.$playButton.onclick = () => jam.application.openAnimalJam()
          this.application._removeGameRunningTooltip()
        }
      }
    }
  }

  /**
   * Opens AJ Classic external installation
   * @returns {Promise<void>}
   * @public
   */
  async openAJClassic() {
    const ajClassicButton = document.getElementById('ajClassicButton')
    if (!ajClassicButton) {
      console.error("AJ Classic button element not found!")
      return
    }

    ajClassicButton.classList.add('opacity-50', 'pointer-events-none')
    ajClassicButton.onclick = () => false
    
    const startMessageId = `start-aj-classic-${Date.now()}`

    try {
      this.application.consoleMessage({ 
        message: 'Launching AJ Classic...', 
        type: 'wait',
        details: { messageId: startMessageId }
      })
      
      ipcRenderer.send('launch-aj-classic')
      
      await new Promise(resolve => setTimeout(resolve, 1000))
      
      const startingMessageElement = document.querySelector(`[data-message-id='${startMessageId}']`)
      if (startingMessageElement) {
        $(startingMessageElement).remove()
      }
      
      this.application.consoleMessage({
        message: 'AJ Classic launched successfully!',
        type: 'success'
      })
      
    } catch (error) {
      this.application.consoleMessage({
        message: `Error launching AJ Classic: ${error.message}`,
        type: 'error'
      })
    } finally {
      if (ajClassicButton) {
        ajClassicButton.classList.remove('opacity-50', 'pointer-events-none')
        ajClassicButton.onclick = () => jam.application.openAJClassic()
      }
    }
  }

  /**
   * Handles when the game process exits
   * @public
   */
  handleGameProcessExit() {
    this.application._isGameRunning = false
    
    if (this.application.$playButton) {
      this.application.$playButton.classList.remove('opacity-100')
      this.application.$playButton.onclick = () => jam.application.openAnimalJam()
      this.application._removeGameRunningTooltip()
    }

    this.application.consoleMessage({
      message: 'Strawberry Jam Classic has closed. All plugins have been closed.',
      type: 'notify'
    })
  }
}

module.exports = GameLauncher

