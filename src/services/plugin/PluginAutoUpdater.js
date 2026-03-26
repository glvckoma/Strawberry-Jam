const fs = require('fs')
const path = require('path')
const { ipcRenderer } = require('electron')
const { downloadPluginFiles } = require('../../utils/PluginDownloader')

const UPDATE_CHECK_INTERVAL = 3600000
const SJ_PLUGINS_API = 'https://api.github.com/repos/glvckoma/strawberry-jam/contents/plugins'

class PluginAutoUpdater {
  constructor(application) {
    this.application = application
  }

  async checkAndUpdateAll() {
    const lastCheck = await ipcRenderer.invoke('get-setting', 'lastPluginUpdateCheck')
    if (lastCheck && (Date.now() - lastCheck) < UPDATE_CHECK_INTERVAL) return []

    const userPluginsPath = await ipcRenderer.invoke('get-user-plugins-path')
    if (!userPluginsPath || !fs.existsSync(userPluginsPath)) return []

    const pluginDirs = fs.readdirSync(userPluginsPath, { withFileTypes: true })
      .filter(d => d.isDirectory())
      .filter(d => fs.existsSync(path.join(userPluginsPath, d.name, '.sj-source')))

    const updated = []

    for (const dir of pluginDirs) {
      try {
        const result = await this._checkAndUpdate(dir.name, userPluginsPath)
        if (result) updated.push(dir.name)
      } catch (error) {
        if (this._isRateLimited(error)) {
          this.application.consoleMessage({
            message: 'Plugin update check stopped: GitHub rate limit reached.',
            type: 'warn'
          })
          break
        }
      }
    }

    ipcRenderer.send('set-setting', { key: 'lastPluginUpdateCheck', value: Date.now() })
    return updated
  }

  async _checkAndUpdate(pluginName, userPluginsPath) {
    const pluginDir = path.join(userPluginsPath, pluginName)
    const localConfigPath = path.join(pluginDir, 'plugin.json')
    if (!fs.existsSync(localConfigPath)) return false

    let localVersion
    try {
      const localConfig = JSON.parse(fs.readFileSync(localConfigPath, 'utf8'))
      localVersion = localConfig.version || '0.0.0'
    } catch (_) {
      return false
    }

    const githubVersion = await this._fetchGitHubVersion(pluginName)
    if (!githubVersion) return false

    if (!this._isNewerVersion(githubVersion, localVersion)) return false

    const contentsUrl = `${SJ_PLUGINS_API}/${pluginName}`
    await downloadPluginFiles(contentsUrl, pluginDir)

    if (!fs.existsSync(path.join(pluginDir, '.sj-source'))) {
      fs.writeFileSync(path.join(pluginDir, '.sj-source'), '')
    }

    return true
  }

  async _fetchGitHubVersion(pluginName) {
    const url = `${SJ_PLUGINS_API}/${pluginName}/plugin.json`
    const response = await fetch(url)

    if (response.status === 403) {
      const remaining = response.headers.get('X-RateLimit-Remaining')
      if (remaining === '0') {
        const error = new Error('GitHub rate limit exceeded')
        error.rateLimited = true
        throw error
      }
    }

    if (!response.ok) return null

    const data = await response.json()
    const content = JSON.parse(atob(data.content))
    return content.version || null
  }

  _isNewerVersion(v1, v2) {
    const v1Parts = v1.split('.').map(Number)
    const v2Parts = v2.split('.').map(Number)
    for (let i = 0; i < Math.max(v1Parts.length, v2Parts.length); i++) {
      const p1 = v1Parts[i] || 0
      const p2 = v2Parts[i] || 0
      if (p1 > p2) return true
      if (p1 < p2) return false
    }
    return false
  }

  _isRateLimited(error) {
    return error && error.rateLimited === true
  }
}

module.exports = PluginAutoUpdater
