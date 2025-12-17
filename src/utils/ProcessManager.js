const { app } = require('electron');
const treeKill = require('tree-kill');
const logManager = require('./LogManager'); // Use our logger

class ProcessManager {
  constructor() {
    this.childProcesses = new Set();
    this.processPids = new Set();
    this.servers = new Set();
    this.intervals = new Set();
    this.isQuitting = false;
    this.cleanupExecuted = false;
    app.on('will-quit', this.killAll.bind(this));
    
    process.on('exit', () => {
      if (!this.cleanupExecuted) {
        this._emergencyCleanup();
      }
    });
  }

  add(process) {
    if (!process || !process.pid) {
      logManager.warn('[ProcessManager] Attempted to add invalid process');
      return;
    }
    logManager.log(`[ProcessManager] Tracking new process with PID: ${process.pid}`, 'main');
    this.childProcesses.add(process);
    this.processPids.add(process.pid);
    process.on('exit', (code) => {
      logManager.log(`[ProcessManager] Process with PID: ${process.pid} has exited with code ${code}.`, 'main');
      this.childProcesses.delete(process);
      this.processPids.delete(process.pid);
    });
  }

  addServer(server) {
    logManager.log(`[ProcessManager] Tracking new server`, 'main');
    this.servers.add(server);
  }

  removeServer(server) {
    this.servers.delete(server);
  }

  addInterval(interval) {
    this.intervals.add(interval);
  }

  removeInterval(interval) {
    this.intervals.delete(interval);
  }

  clearAllIntervals() {
    for (const interval of this.intervals) {
      clearInterval(interval);
    }
    this.intervals.clear();
  }

  async killAll(event) {
    if (this.isQuitting) {
      return;
    }
    this.isQuitting = true;
    this.cleanupExecuted = true;

    if (event) {
      logManager.log('[ProcessManager] "will-quit" event triggered. Starting killAll sequence.', 'main');
      logManager.log('[ProcessManager] Preventing default quit behavior to manage resources.', 'main');
      event.preventDefault();
    } else {
      logManager.log('[ProcessManager] killAll called directly (signal handler or manual cleanup). Starting cleanup sequence.', 'main');
    }

    const promises = [];

    this.clearAllIntervals();

    if (this.servers.size > 0) {
      logManager.log(`[ProcessManager] Closing ${this.servers.size} servers.`, 'main');
      for (const server of this.servers) {
        if (server && typeof server.close === 'function') {
          promises.push(
            Promise.resolve(server.close()).catch(err => {
              logManager.error(`[ProcessManager] Error closing server: ${err.message}`);
            })
          );
        }
      }
    }

    if (this.childProcesses.size === 0) {
      logManager.log('[ProcessManager] No child processes to kill.', 'main');
    } else {
      logManager.log(`[ProcessManager] Attempting to kill ${this.childProcesses.size} child processes.`, 'main');
    }

    const handledPids = new Set();
    
    for (const process of this.childProcesses) {
      if (!process || !process.pid) continue;
      
      const pid = process.pid;
      if (handledPids.has(pid)) continue;
      handledPids.add(pid);
      
      logManager.log(`[ProcessManager] Creating kill promise for PID: ${pid}`, 'main');
      
      promises.push(new Promise((resolve) => {
        const killProcess = () => {
          if (!this.processPids.has(pid)) {
            logManager.log(`[ProcessManager] Process ${pid} already exited, skipping kill`, 'main');
            resolve();
            return;
          }
          
          treeKill(pid, 'SIGKILL', (err) => {
            this.processPids.delete(pid);
            if (err) {
              if (err.message && err.message.includes('not found')) {
                logManager.log(`[ProcessManager] Process ${pid} already exited`, 'main');
              } else {
                logManager.error(`[ProcessManager] Failed to kill process tree for PID ${pid}: ${err.message}`);
              }
            } else {
              logManager.log(`[ProcessManager] Successfully killed process tree for PID: ${pid}`, 'main');
            }
            resolve();
          });
        };

        if (process.send && typeof process.send === 'function' && !process.killed) {
          try {
            process.send({ type: 'shutdown' });
            setTimeout(() => {
              if (this.processPids.has(pid)) {
                killProcess();
              } else {
                logManager.log(`[ProcessManager] Process ${pid} exited gracefully after shutdown signal`, 'main');
                resolve();
              }
            }, 1000);
          } catch (err) {
            killProcess();
          }
        } else {
          killProcess();
        }
      }));
    }

    for (const pid of this.processPids) {
      if (handledPids.has(pid)) continue;
      
      logManager.log(`[ProcessManager] Killing untracked process PID: ${pid}`, 'main');
      promises.push(new Promise((resolve) => {
        treeKill(pid, 'SIGKILL', (err) => {
          this.processPids.delete(pid);
          if (err) {
            if (err.message && err.message.includes('not found')) {
              logManager.log(`[ProcessManager] Process ${pid} already exited (untracked)`, 'main');
            } else {
              logManager.error(`[ProcessManager] Failed to kill process tree for PID ${pid} (untracked): ${err.message}`);
            }
          } else {
            logManager.log(`[ProcessManager] Successfully killed process tree for PID: ${pid} (untracked)`, 'main');
          }
          resolve();
        });
      }));
    }

    try {
      await Promise.all(promises);
      logManager.log('[ProcessManager] All cleanup promises have resolved.', 'main');
      
      await this._cleanupOrphanedNodeProcesses();
      
      if (event) {
        logManager.log('[ProcessManager] Proceeding to call app.quit().', 'main');
        app.quit();
      } else {
        logManager.log('[ProcessManager] No event object, skipping final app.quit().', 'main');
      }
    } catch (error) {
      logManager.error(`[ProcessManager] Error in Promise.all: ${error.message}`);
      await this._cleanupOrphanedNodeProcesses();
      if (event) {
        logManager.log('[ProcessManager] Calling app.quit() despite error in Promise.all.', 'main');
        app.quit();
      }
    }
  }

  async _cleanupOrphanedNodeProcesses() {
    if (process.platform !== 'win32') {
      return;
    }

    try {
      const { exec } = require('child_process');
      const { promisify } = require('util');
      const execAsync = promisify(exec);

      const mainPid = process.pid;
      const trackedPids = Array.from(this.processPids);

      if (trackedPids.length === 0) {
        return;
      }

      const { stdout } = await execAsync('tasklist /FI "IMAGENAME eq node.exe" /FO CSV /NH');
      
      if (!stdout || !stdout.includes('node.exe')) {
        return;
      }

      const lines = stdout.split('\n').filter(line => line.includes('node.exe'));
      const orphanedPids = [];

      for (const line of lines) {
        const match = line.match(/"node\.exe","([^"]+)"/);
        if (match) {
          const pid = parseInt(match[1], 10);
          if (pid && pid !== mainPid && !trackedPids.includes(pid)) {
            try {
              const { stdout: parentInfo } = await execAsync(`wmic process where processid=${pid} get parentprocessid /format:value`);
              const parentMatch = parentInfo.match(/ParentProcessId=(\d+)/);
              if (parentMatch) {
                const parentPid = parseInt(parentMatch[1], 10);
                if (parentPid === mainPid || trackedPids.includes(parentPid)) {
                  orphanedPids.push(pid);
                }
              }
            } catch {
            }
          } else if (pid && trackedPids.includes(pid)) {
            orphanedPids.push(pid);
          }
        }
      }

      if (orphanedPids.length > 0) {
        logManager.log(`[ProcessManager] Found ${orphanedPids.length} potentially orphaned node.exe processes, cleaning up...`, 'main');
        for (const pid of orphanedPids) {
          try {
            await execAsync(`taskkill /PID ${pid} /T /F`);
            logManager.log(`[ProcessManager] Killed orphaned node.exe process: ${pid}`, 'main');
          } catch (err) {
            if (!err.message.includes('not found')) {
              logManager.warn(`[ProcessManager] Failed to kill orphaned process ${pid}: ${err.message}`);
            }
          }
        }
      }
    } catch (error) {
      logManager.warn(`[ProcessManager] Error during orphaned process cleanup: ${error.message}`);
    }
  }

  _emergencyCleanup() {
    try {
      this.clearAllIntervals();
      
      const pidsToKill = Array.from(this.processPids);
      
      for (const pid of pidsToKill) {
        try {
          if (process.platform === 'win32') {
            const { execSync } = require('child_process');
            try {
              execSync(`taskkill /PID ${pid} /T /F 2>nul`, { timeout: 1000, stdio: 'ignore' });
            } catch {
            }
          } else {
            const { execSync } = require('child_process');
            try {
              execSync(`kill -9 ${pid} 2>/dev/null`, { timeout: 1000, stdio: 'ignore' });
            } catch {
            }
          }
        } catch {
        }
      }
      
      if (process.platform === 'win32') {
        setTimeout(() => {
          this._cleanupOrphanedNodeProcesses().catch(() => {});
        }, 500);
      }
    } catch {
    }
  }
}

module.exports = new ProcessManager();
