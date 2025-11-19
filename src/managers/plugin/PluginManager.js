const path = require('path')
const fs = require('fs').promises
const Ajv = new (require('ajv'))({ useDefaults: true })
const { PluginTypes } = require('../../Constants')

const isDevelopment = process.env.NODE_ENV === 'development'

const ConfigurationSchema = {
  type: 'object',
  properties: {
    name: { type: 'string' },
    main: { type: 'string', default: 'index.js' },
    description: { type: 'string', default: '' },
    author: { type: 'string', default: 'Sxip' },
    type: { type: 'string', default: 'game' },
    dependencies: { type: 'object', default: {} }
  },
  required: [
    'name',
    'main',
    'description',
    'author',
    'type',
    'dependencies'
  ]
}

class PluginManager {
  constructor(options) {
    this.plugins = options.plugins
    this._application = options.application
    this.dependencyManager = options.dependencyManager
    this.dataPath = options.dataPath
    this._consoleMessage = options.consoleMessage
    this.BASE_PATH = options.BASE_PATH
    this.clearAllCallback = options.clearAllCallback
    this.initializeDefaultStateHandlersCallback = options.initializeDefaultStateHandlersCallback
    this.shouldHideGamePluginsCallback = options.shouldHideGamePluginsCallback
    this.refreshPluginVisibilityCallback = options.refreshPluginVisibilityCallback
  }

  static async readdirRecursive(directory) {
    const result = []

    const read = async (dir) => {
      const entries = await fs.readdir(dir, { withFileTypes: true })

      const promises = entries.map(async (entry) => {
        const filepath = path.join(dir, entry.name)

        if (entry.isDirectory()) {
          await read(filepath)
        } else {
          result.push(filepath)
        }
      })

      await Promise.all(promises)
    }

    await read(directory)
    return result
  }

  async installDependencies(configuration) {
    const { dependencies } = configuration

    if (!dependencies || Object.keys(dependencies).length === 0) {
      return
    }

    const installPromises = Object.entries(dependencies).map(
      ([module, version]) => this.dependencyManager.install(module, version)
    )

    await Promise.all(installPromises)
  }

  require(name) {
    return this.dependencyManager.require(name)
  }

  waitForJQuery(window, callback) {
    return new Promise((resolve, reject) => {
      const checkInterval = 100
      const maxRetries = 100
      let retries = 0

      const intervalId = setInterval(() => {
        if (typeof window.$ !== 'undefined') {
          clearInterval(intervalId)
          try {
            callback()
            resolve()
          } catch (error) {
            reject(error)
          }
        } else if (retries >= maxRetries) {
          clearInterval(intervalId)
          reject(new Error('jQuery was not found within the expected time.'))
        } else {
          retries++
        }
      }, checkInterval)
    })
  }

  async _validateAndPrepareConfig(filepath, configuration) {
    const validate = Ajv.compile(ConfigurationSchema)
    if (!validate(configuration)) {
      this._consoleMessage({
        type: 'error',
        message: `Failed validating configuration for plugin in ${filepath}. ${validate.errors[0].message}.`
      })
      return null
    }

    if (this.plugins.has(configuration.name)) {
      this._consoleMessage({
        type: 'warn',
        message: `Duplicate plugin name found during validation: ${configuration.name}`
      })
    }

    try {
      await this.installDependencies(configuration)
      return { filepath, configuration }
    } catch (error) {
      this._consoleMessage({
        type: 'error',
        message: `Error installing dependencies for plugin in ${filepath}: ${error.message}`
      })
      return null
    }
  }

  async _processAndRenderPlugin(configData) {
    const { filepath, configuration } = configData

    if (this.plugins.has(configuration.name)) {
      this._consoleMessage({
        type: 'error',
        message: `Plugin with the name ${configuration.name} already exists. Skipping.`
      })
      return
    }

    try {
      let pluginInstance = null
      if (configuration.type === 'game') {
        const PluginClass = require(path.join(filepath, configuration.main))
        pluginInstance = new PluginClass({
          application: this._application,
          dispatch: this._application.dispatch,
          dataPath: this.dataPath
        })
      }

      this.plugins.set(configuration.name, {
        configuration,
        filepath,
        plugin: pluginInstance
      })

      const $pluginElement = this._application.renderPluginItems(configuration)

      this._application.$pluginList.append($pluginElement)

    } catch (error) {
      this._consoleMessage({
        type: 'error',
        message: `Error processing/rendering plugin ${configuration.name}: ${error.message}`
      })
    }
  }

  async load(filter = file => path.basename(file) === 'plugin.json') {
    this.clearAllCallback()
    this._application.$pluginList.empty()

    if (!this.BASE_PATH) {
      this._consoleMessage({ type: 'error', message: 'Plugin base path (BASE_PATH) could not be determined. Cannot load plugins.' })
      this._application._updateEmptyPluginMessage()
      return
    }

    try {
      try {
        await fs.access(this.BASE_PATH)
      } catch (accessError) {
        this._consoleMessage({ type: 'error', message: `Plugins directory not found at ${this.BASE_PATH}. Cannot load plugins.` })
        this._application._updateEmptyPluginMessage()
        return
      }

      const files = await PluginManager.readdirRecursive(this.BASE_PATH)

      const configFiles = files.filter(filter)

      if (configFiles.length === 0) {
        this._consoleMessage({ type: 'notify', message: 'No plugins found in the plugins directory.' })
        this._application._updateEmptyPluginMessage()
        return
      }

      const pluginPromises = configFiles.map(async configFile => {
        try {
          const configuration = JSON.parse(await fs.readFile(configFile, 'utf8'))
          const filepath = path.dirname(configFile)
          return this._validateAndPrepareConfig(filepath, configuration.default || configuration)
        } catch (error) {
          this._consoleMessage({ type: 'error', message: `Error reading or parsing plugin config ${path.basename(configFile)}: ${error.message}` })
          return null
        }
      })

      let loadedPluginConfigs = (await Promise.all(pluginPromises)).filter(r => r !== null)

      loadedPluginConfigs.sort((a, b) => {
        const aType = a.configuration.type
        const bType = b.configuration.type

        if (aType === 'ui' && bType === 'game') return -1
        if (aType === 'game' && bType === 'ui') return 1

        return a.configuration.name.localeCompare(b.configuration.name)
      })

      for (const configData of loadedPluginConfigs) {
        await this._processAndRenderPlugin(configData)
      }

      const hideGamePlugins = await this.shouldHideGamePluginsCallback()
      if (hideGamePlugins) {
        this._application.$pluginList.find('[data-plugin-type="game"]').hide()
      } else {
        this._application.$pluginList.find('[data-plugin-type="game"]').show()
      }

    } catch (error) {
      this._consoleMessage({ type: 'error', message: `Error loading plugins: ${error.message}` })
      if (isDevelopment) {
        console.error('[PluginManager] Detailed error loading plugins:', error)
      }
    } finally {
      this._application._updateEmptyPluginMessage()
      this._application.refreshAutoComplete()
      this.initializeDefaultStateHandlersCallback()
    }
  }

  async _getOpenPluginWindows() {
    if (typeof require === "function") {
      try {
        const { ipcRenderer } = require('electron')
        return await ipcRenderer.invoke('get-open-plugin-windows')
      } catch (e) {
        console.warn('[PluginManager] Could not get open plugin windows:', e)
        return []
      }
    }
    return []
  }

  async _handleOpenPluginWindows(openWindows) {
    const refreshBehavior = await this._application.settings.get('plugins.refreshBehavior', 'ask')

    if (refreshBehavior === 'alwaysClose') {
      await this._closePluginWindows(openWindows)
      this._consoleMessage({
        type: 'notify',
        message: `Automatically closed ${openWindows.length} plugin window(s) before refresh (user preference).`
      })
      return true
    }

    return new Promise((resolve) => {
      const pluginNames = openWindows.join(', ')
      const message = `The following plugins are currently open: ${pluginNames}\n\nPlugin windows will be closed before refreshing to prevent instability.\n\nDo you want to continue?`

      const modal = $(`
        <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" style="backdrop-filter: blur(5px);">
          <div class="bg-gray-800 rounded-lg p-6 max-w-md mx-4 shadow-2xl border border-gray-600">
            <div class="flex items-center mb-4">
              <i class="fas fa-exclamation-triangle text-yellow-400 text-xl mr-3"></i>
              <h3 class="text-lg font-semibold text-white">Open Plugin Windows Detected</h3>
            </div>
            <p class="text-gray-300 mb-6">${message.replace(/\n\n/g, '</p><p class="text-gray-300 mb-4">')}</p>
            <div class="flex flex-col gap-2">
              <button id="refresh-proceed" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded transition-colors">
                <i class="fas fa-sync-alt mr-2"></i>Proceed (Close Windows & Refresh)
              </button>
              <button id="refresh-cancel" class="px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white rounded transition-colors">
                <i class="fas fa-times mr-2"></i>Cancel
              </button>
            </div>
            <div class="mt-4 pt-4 border-t border-gray-600">
              <label class="flex items-center text-sm text-gray-400">
                <input type="checkbox" id="rememberChoice" class="mr-2">
                Always close plugin windows without asking
              </label>
            </div>
          </div>
        </div>
      `)

      $('body').append(modal)

      modal.find('#refresh-proceed').on('click', async () => {
        const remember = modal.find('#rememberChoice').is(':checked')
        modal.remove()

        if (remember) {
          await this._application.settings.set('plugins.refreshBehavior', 'alwaysClose')
          this._consoleMessage({
            type: 'notify',
            message: 'Preference saved: Will automatically close plugin windows during future refreshes.'
          })
        }

        await this._closePluginWindows(openWindows)
        resolve(true)
      })

      modal.find('#refresh-cancel').on('click', () => {
        modal.remove()
        resolve(false)
      })

      modal.on('click', (e) => {
        if (e.target === modal[0]) {
          modal.remove()
          resolve(false)
        }
      })
    })
  }

  async _closePluginWindows(pluginNames) {
    if (typeof require === "function") {
      try {
        const { ipcRenderer } = require('electron')
        await ipcRenderer.invoke('close-plugin-windows', pluginNames)
        this._consoleMessage({
          type: 'notify',
          message: `Closed ${pluginNames.length} plugin window(s) before refresh.`
        })
      } catch (e) {
        console.warn('[PluginManager] Could not close plugin windows:', e)
        this._consoleMessage({
          type: 'warning',
          message: 'Could not close some plugin windows. They may become unstable after refresh.'
        })
      }
    }
  }

  _startRefreshAnimation() {
    if (this._application && typeof this._application.emit === "function") {
      this._application.emit("refresh:plugins:start")
    }
  }

  async refresh() {
    const openWindows = await this._getOpenPluginWindows()

    if (openWindows.length > 0) {
      const shouldProceed = await this._handleOpenPluginWindows(openWindows)
      if (!shouldProceed) {
        this._consoleMessage({
          type: 'notify',
          message: 'Plugin refresh cancelled by user.'
        })
        return
      }
    }

    this._startRefreshAnimation()

    this._application.$pluginList.empty()

    const pluginPaths = [...this.plugins.values()].map(({ filepath, configuration: { main } }) => ({
      jsPath: path.resolve(filepath, main),
      jsonPath: path.resolve(filepath, 'plugin.json')
    }))

    for (const { jsPath, jsonPath } of pluginPaths) {
      try {
        await fs.access(jsPath)
        const jsCacheKey = require.resolve(jsPath)
        if (require.cache[jsCacheKey]) delete require.cache[jsCacheKey]
      } catch (e) {
      }

      try {
        await fs.access(jsonPath)
        const jsonCacheKey = require.resolve(jsonPath)
        if (require.cache[jsonCacheKey]) delete require.cache[jsonCacheKey]
      } catch (e) {
      }
    }

    this.clearAllCallback()
    await this.load()

    this._application.emit('refresh:plugins')
    this._consoleMessage({
      type: 'success',
      message: `Successfully refreshed ${this.plugins.size} plugins.`
    })
  }
}

module.exports = PluginManager

