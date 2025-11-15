class WindowControlsManager {
  constructor(application, ipcRenderer) {
    this.application = application
    this.ipcRenderer = ipcRenderer
  }

  setupWindowControls() {
    const minimizeButton = document.getElementById('minimizeButton')
    if (minimizeButton) {
      minimizeButton.addEventListener('click', () => {
        this.application.minimize()
      })
    }
    
    const fullscreenButton = document.getElementById('fullscreenButton')
    if (fullscreenButton) {
      fullscreenButton.addEventListener('click', () => {
        this.application.toggleMaximize()
      })
      
      const icon = fullscreenButton.querySelector('i')
      if (icon) {
        icon.classList.remove('fa-expand')
        icon.classList.remove('fas')
        icon.classList.add('fa-regular')
        icon.classList.add('fa-window-maximize')
      }
      
      this.ipcRenderer.on('maximize-changed', (event, isMaximized) => {
        const icon = fullscreenButton.querySelector('i')
        if (icon) {
          if (isMaximized) {
            icon.classList.remove('fa-window-maximize')
            icon.classList.add('fa-window-restore')
          } else {
            icon.classList.remove('fa-window-restore')
            icon.classList.add('fa-window-maximize')
          }
        }
      })
    }
    
    const closeButton = document.getElementById('mainCloseButton')
    if (closeButton) {
      closeButton.addEventListener('click', () => {
        this.application.close()
      })
    }

    const clearConsoleButton = document.getElementById('clearConsoleButton')
    if (clearConsoleButton) {
      clearConsoleButton.addEventListener('click', () => {
        this.clearConsole()
      })
    }
    
    const clearPacketLogButton = document.getElementById('clearPacketLogButton')
    if (clearPacketLogButton) {
      clearPacketLogButton.addEventListener('click', () => {
        this.clearPacketLog()
      })
    }
  }

  clearConsole() {
    const $mainLogContainer = $('#messages')
    const $packetLogContainer = $('#packetMessages')
    
    if ($mainLogContainer.length) {
      $mainLogContainer.empty()
    }
    
    if ($packetLogContainer.length) {
      $packetLogContainer.empty()
    }
    
    if (this.application) {
      this.application._packetLogCount = 0
      this.application._appMessageCount = 0
      
      this.application.consoleMessage({
        type: 'notify',
        message: 'Console logs cleared'
      })
    }
  }

  clearPacketLog() {
    const $messageLog = $('#message-log')
    if ($messageLog.length) {
      $messageLog.empty()
    }
    
    $('#incomingCount, #outgoingCount, #totalCount').text('0')
    
    if (this.application) {
      this.application.consoleMessage({
        type: 'notify',
        message: 'Packet logs cleared'
      })
    }
  }
}

module.exports = WindowControlsManager

