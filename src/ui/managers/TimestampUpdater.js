class TimestampUpdater {
  constructor(ipcRenderer) {
    this.ipcRenderer = ipcRenderer
  }

  formatUptime(ms) {
    const days = Math.floor(ms / (1000 * 60 * 60 * 24))
    const hours = Math.floor((ms % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
    const minutes = Math.floor((ms % (1000 * 60 * 60)) / (1000 * 60))
    const seconds = Math.floor((ms % (1000 * 60)) / 1000)
    const hms = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
    return days > 0 ? `${days}D ${hms}` : hms
  }

  formatGameTime(totalSeconds) {
    const days = Math.floor(totalSeconds / 86400)
    const hours = Math.floor((totalSeconds % 86400) / 3600)
    const minutes = Math.floor((totalSeconds % 3600) / 60)
    const hm = `${hours}h ${minutes}m`
    return days > 0 ? `${days}D ${hm}` : hm
  }

  async updateTimestamp(sessionStartTime) {
    const timestampDisplay = document.getElementById('timestamp-display')
    if (!timestampDisplay || !sessionStartTime) return

    const now = new Date()
    const sessionDuration = now - sessionStartTime

    try {
      const { totalUptime, totalGameTime } = await this.ipcRenderer.invoke('get-time-stats')
      const combinedUptime = totalUptime * 1000 + sessionDuration

      const formattedUptime = this.formatUptime(combinedUptime)
      const formattedGameTime = this.formatGameTime(totalGameTime)

      timestampDisplay.textContent = `Uptime: ${formattedUptime} | Game Time: ${formattedGameTime}`
    } catch (error) {
      const formattedUptime = this.formatUptime(sessionDuration)
      timestampDisplay.textContent = `Uptime: ${formattedUptime}`
    }
  }
}

module.exports = TimestampUpdater
