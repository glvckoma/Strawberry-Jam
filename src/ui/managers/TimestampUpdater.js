class TimestampUpdater {
  constructor(ipcRenderer) {
    this.ipcRenderer = ipcRenderer
  }

  async updateTimestamp(sessionStartTime) {
    const timestampDisplay = document.getElementById('timestamp-display')
    if (timestampDisplay && sessionStartTime) {
      const now = new Date()
      const sessionDuration = now - sessionStartTime
      
      const totalUptime = await this.ipcRenderer.invoke('get-total-uptime')
      const combinedUptime = totalUptime * 1000 + sessionDuration

      const hours = Math.floor(combinedUptime / (1000 * 60 * 60))
      const minutes = Math.floor((combinedUptime % (1000 * 60 * 60)) / (1000 * 60))
      const seconds = Math.floor((combinedUptime % (1000 * 60)) / 1000)

      const formattedUptime = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`

      try {
        const totalGameTime = await this.ipcRenderer.invoke('get-total-game-time')
        const gameTimeHours = Math.floor(totalGameTime / 3600)
        const gameTimeMinutes = Math.floor((totalGameTime % 3600) / 60)
        const formattedGameTime = `${gameTimeHours}h ${gameTimeMinutes}m`

        timestampDisplay.textContent = `Uptime: ${formattedUptime} | Game Time: ${formattedGameTime}`
      } catch (error) {
        timestampDisplay.textContent = `Uptime: ${formattedUptime}`
      }
    }
  }
}

module.exports = TimestampUpdater

