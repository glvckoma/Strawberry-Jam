const { exec } = require('child_process')
const { promisify } = require('util')
const execAsync = promisify(exec)

class PortConflictChecker {
  static async killProcessOnPort(port) {
    const platform = process.platform
    const ownPid = process.pid

    try {
      if (platform === 'win32') {
        return await this._killOnWindows(port, ownPid)
      } else if (platform === 'darwin' || platform === 'linux') {
        return await this._killOnUnix(port, ownPid)
      }

      return { success: false, message: 'Unsupported platform' }
    } catch (error) {
      return { success: false, message: `Error checking port ${port}: ${error.message}` }
    }
  }

  static async _killOnWindows(port, ownPid) {
    const { stdout } = await execAsync(`netstat -ano | findstr LISTENING | findstr :${port}`)
    const lines = stdout.trim().split('\n').filter(line => line.trim())
    const pidsToKill = new Set()

    for (const line of lines) {
      const parts = line.trim().split(/\s+/)
      if (parts.length < 4) continue
      const localAddress = parts[1]
      const portMatch = localAddress.match(/:(\d+)$/)
      if (!portMatch || parseInt(portMatch[1]) !== port) continue
      const pid = parseInt(parts[parts.length - 1], 10)
      if (pid && !isNaN(pid) && pid !== ownPid) {
        pidsToKill.add(pid)
      }
    }

    if (pidsToKill.size === 0) {
      return { success: false, message: `Port ${port} is in use by this application. Restart the app to free it.` }
    }

    for (const pid of pidsToKill) {
      try {
        await execAsync(`taskkill /PID ${pid} /F`)
      } catch (killError) {
        if (killError.message.includes('Access is denied')) {
          return { success: false, message: `Access denied terminating PID ${pid}. Try running as administrator, or close the application manually.` }
        }
        return { success: false, message: `Failed to terminate process ${pid}: ${killError.message}` }
      }
    }

    return { success: true, message: `Terminated ${pidsToKill.size} process(es) using port ${port}` }
  }

  static async _killOnUnix(port, ownPid) {
    const { stdout } = await execAsync(`lsof -ti:${port}`)
    const pids = stdout.trim().split('\n').filter(pid => pid.trim())
    const filteredPids = pids.filter(p => parseInt(p, 10) !== ownPid)

    if (filteredPids.length === 0) {
      if (pids.length > 0) {
        return { success: false, message: `Port ${port} is in use by this application. Restart the app to free it.` }
      }
      return { success: false, message: `No process found using port ${port}` }
    }

    for (const pid of filteredPids) {
      try {
        await execAsync(`kill -9 ${pid}`)
      } catch (killError) {
        return { success: false, message: `Failed to terminate process ${pid}: ${killError.message}` }
      }
    }

    return { success: true, message: `Terminated ${filteredPids.length} process(es) using port ${port}` }
  }
}

module.exports = PortConflictChecker
