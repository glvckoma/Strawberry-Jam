const net = require('net')
const path = require('path')

class PortChecker {
  static async isPortBusy(port, host = '127.0.0.1') {
    return new Promise((resolve) => {
      const server = net.createServer()
      
      server.once('error', (err) => {
        if (err.code === 'EADDRINUSE') {
          resolve(true)
        } else {
          resolve(false)
        }
      })
      
      server.once('listening', () => {
        server.once('close', () => {
          resolve(false)
        })
        server.close()
      })
      
      server.listen(port, host, () => {
        server.close()
        resolve(false)
      })
    })
  }

  static async checkPorts(ports) {
    const results = {}
    for (const port of ports) {
      results[port] = await this.isPortBusy(port)
    }
    return results
  }

  static async findProcessUsingPort(port) {
    const { exec } = require('child_process')
    const { promisify } = require('util')
    const execAsync = promisify(exec)
    
    const platform = process.platform
    
    try {
      if (platform === 'win32') {
        const { stdout } = await execAsync(`netstat -ano | findstr :${port}`)
        const lines = stdout.trim().split('\n')
        if (lines.length > 0) {
          const parts = lines[0].trim().split(/\s+/)
          const pid = parts[parts.length - 1]
          if (pid && !isNaN(pid)) {
            try {
              const { stdout: taskOutput } = await execAsync(`tasklist /FI "PID eq ${pid}" /FO CSV /NH`)
              if (taskOutput && taskOutput.trim()) {
                const taskParts = taskOutput.split(',')
                if (taskParts.length > 0) {
                  const processName = taskParts[0].replace(/"/g, '')
                  return { pid, processName }
                }
              }
            } catch {
              return { pid }
            }
          }
        }
      } else if (platform === 'darwin' || platform === 'linux') {
        const { stdout } = await execAsync(`lsof -ti:${port}`)
        const pid = stdout.trim()
        if (pid) {
          try {
            const { stdout: psOutput } = await execAsync(`ps -p ${pid} -o comm=`)
            const processName = psOutput.trim()
            return { pid, processName }
          } catch {
            return { pid }
          }
        }
      }
    } catch (error) {
      return null
    }
    
    return null
  }

  /**
   * Checks if a process name matches the current application's process.
   * Handles both development (electron.exe) and production (strawberry-jam.exe) builds.
   * @param {string} processName - The process name to check
   * @returns {boolean} True if the process name matches the current application
   */
  static isOwnProcess(processName) {
    if (!processName) return false
    
    const detectedProcess = processName.toLowerCase()
    
    // Get current executable filename
    const currentProcess = path.basename(process.execPath).toLowerCase()
    
    // Check if detected process matches current process
    // Also check for common names (electron.exe for dev, strawberry-jam.exe for prod)
    return detectedProcess === currentProcess || 
           detectedProcess === 'electron.exe' || 
           detectedProcess === 'strawberry-jam.exe'
  }
}

module.exports = PortChecker

