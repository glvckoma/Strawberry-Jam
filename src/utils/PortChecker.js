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
        const { stdout } = await execAsync(`netstat -ano | findstr LISTENING | findstr :${port}`)
        const lines = stdout.trim().split('\n')
        for (const line of lines) {
          const parts = line.trim().split(/\s+/)
          if (parts.length < 4) continue
          const localAddress = parts[1]
          const portMatch = localAddress.match(/:(\d+)$/)
          if (!portMatch || parseInt(portMatch[1]) !== port) continue
          const pid = parts[parts.length - 1]
          if (!pid || isNaN(pid)) continue
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
      } else if (platform === 'darwin' || platform === 'linux') {
        const { stdout } = await execAsync(`lsof -ti:${port} -sTCP:LISTEN`)
        const pid = stdout.trim().split('\n')[0]
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

    const strip = name => name.toLowerCase().replace(/\.exe$/i, '')
    const detectedProcess = strip(processName)
    const currentProcess = strip(path.basename(process.execPath))

    if (detectedProcess === currentProcess) {
      return true
    }

    if (currentProcess.includes('electron') && detectedProcess === 'electron') {
      return true
    }

    if (currentProcess.includes('strawberry-jam') && detectedProcess === 'strawberry-jam') {
      return true
    }

    return false
  }
}

module.exports = PortChecker

