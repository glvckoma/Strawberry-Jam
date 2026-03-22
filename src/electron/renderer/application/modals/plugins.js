exports.name = 'pluginLibraryModal'

exports.render = function (app) {
  const path = require('path')
  const fs = require('fs')
  const PluginCard = require('../../../../ui/components/PluginCard')

  const CACHE_KEY = 'jam-plugins-cache'
  const CACHE_TIME_KEY = 'jam-plugins-cache-time'
  const CACHE_METADATA_KEY = 'jam-plugins-metadata-cache'
  const CACHE_DURATION = 3600000
  const GITHUB_REPOS_KEY = 'jam-github-repos'

  const GITHUB_API_URLS = [
    { url: 'https://api.github.com/repos/glvckoma/strawberry-jam/contents/plugins', repo: 'strawberry-jam' }
  ]
  const LOCAL_PLUGINS_DIR = path.resolve('plugins/')

  const getUserPluginsPath = async () => {
    const electron = require('electron')
    return await electron.ipcRenderer.invoke('get-user-plugins-path')
  }

  const refreshPluginsWithAnimation = async () => {
    if (!app || !app.dispatch || typeof app.dispatch.load !== 'function') return
    if (typeof app.emit === 'function') app.emit('refresh:plugins:start')
    try {
      await app.dispatch.load()
    } finally {
      if (typeof app.emit === 'function') app.emit('refresh:plugins')
    }
  }

  let activeTab = 'store'

  const $modal = $(`
    <div class="flex items-center justify-center min-h-screen p-4" style="z-index: 9999;">
      <div class="modal-backdrop" id="modalBackdrop"></div>
      <div class="modal-container w-full max-w-4xl">
        <div class="modal-header justify-between">
          <div class="flex items-center space-x-2">
            <i class="fas fa-store modal-section-icon"></i>
            <h3 class="modal-header-title">Plugin Store</h3>
          </div>
          <div class="flex items-center space-x-2">
            <button type="button" id="refreshPluginsBtn" class="text-sm text-gray-400 hover:text-highlight-green transition px-2 py-1 rounded hover:bg-tertiary-bg">
              <i class="fas fa-sync-alt mr-1"></i>Refresh
            </button>
            <button type="button" class="modal-close-btn" id="closePluginHubHeaderBtn">
              <i class="fas fa-times text-sm"></i>
            </button>
          </div>
        </div>

        <div class="px-4 py-2 border-b border-sidebar-border flex-shrink-0">
          <div class="flex items-center justify-between">
            <div class="flex space-x-1">
              <button class="store-tab-button px-3 py-1.5 text-sm font-medium rounded-md transition-colors" data-tab="store">
                <i class="fas fa-store mr-1"></i>Browse
              </button>
              <button class="store-tab-button px-3 py-1.5 text-sm font-medium rounded-md transition-colors" data-tab="github">
                <i class="fab fa-github mr-1"></i>Add Repository
              </button>
            </div>
          </div>
        </div>

        <div class="px-4 py-2 border-b border-sidebar-border flex-shrink-0" id="search-container">
          <input type="text" id="pluginSearch" placeholder="Search plugins..." class="modal-input text-sm">
        </div>

        <div id="github-input-container" class="px-4 py-3 border-b border-sidebar-border hidden flex-shrink-0">
          <div class="flex space-x-2">
            <div class="relative flex-grow">
              <i class="fab fa-github absolute left-2.5 top-1/2 transform -translate-y-1/2 text-gray-500"></i>
              <input type="text" id="githubRepoInput" placeholder="Enter GitHub repository URL"
                class="modal-input pl-8 text-sm">
            </div>
            <button id="fetchGithubRepoBtn" class="modal-btn-success text-sm font-medium">
              <i class="fas fa-search mr-1"></i>Fetch
            </button>
          </div>
          <p class="mt-1.5 text-xs text-gray-500">
            <i class="fas fa-info-circle mr-1"></i>
            Format: https://github.com/username/repository or https://github.com/username/repository/tree/branch/path/to/plugin
          </p>
          <div id="githubPluginDetails" class="mt-2 space-y-2 hidden">
            <div>
              <label for="githubPluginPath" class="block text-gray-500 mb-0.5 text-xs">Path to plugin:</label>
              <input type="text" id="githubPluginPath" placeholder="e.g., plugins/myplugin" class="modal-input text-sm p-1.5">
            </div>
            <div>
              <label for="githubPluginName" class="block text-gray-500 mb-0.5 text-xs">Plugin name:</label>
              <input type="text" id="githubPluginName" placeholder="Custom plugin name (optional)" class="modal-input text-sm p-1.5">
            </div>
            <div class="flex justify-end">
              <button id="addGithubRepoBtn" class="modal-btn-success text-sm font-medium px-3 py-1">
                <i class="fas fa-plus mr-1"></i>Add Repository
              </button>
            </div>
          </div>
        </div>

        <div class="flex-1 overflow-y-auto min-h-0 p-4 themed-scrollbar">
          <div id="store-content" class="tab-panel">
            <div id="pluginsList" class="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div class="col-span-full flex justify-center items-center h-32">
                <i class="fas fa-circle-notch fa-spin text-gray-400 mr-2"></i>
                <span class="text-gray-400 text-sm">Loading plugins...</span>
              </div>
            </div>
          </div>
          <div id="github-content" class="tab-panel hidden">
            <div id="githubReposList" class="space-y-2 mb-4"></div>
            <div id="githubPluginsList" class="grid grid-cols-1 md:grid-cols-2 gap-3"></div>
          </div>
        </div>

        <div class="modal-footer justify-between text-xs text-gray-500">
          <span id="pluginCountInfo"></span>
          <span>
            <i class="fas fa-info-circle mr-1"></i>
            <span class="store-tab-info">Browse and install plugins from the repository</span>
            <span class="github-tab-info hidden">Add plugins from custom GitHub repositories</span>
          </span>
        </div>
      </div>
    </div>
  `)

  const updateTabStyles = () => {
    $modal.find('.store-tab-button').removeClass('bg-highlight-green/20 text-highlight-green').addClass('text-gray-400 hover:bg-tertiary-bg')
    $modal.find(`.store-tab-button[data-tab="${activeTab}"]`).addClass('bg-highlight-green/20 text-highlight-green').removeClass('text-gray-400 hover:bg-tertiary-bg')

    const $currentPanel = $modal.find('.tab-panel:not(.hidden)')
    const $newPanel = $modal.find(`#${activeTab}-content`)

    if ($currentPanel.attr('id') === $newPanel.attr('id')) return

    if (activeTab === 'github') {
      $modal.find('#search-container').addClass('hidden')
      $modal.find('#github-input-container').removeClass('hidden')
    } else {
      $modal.find('#github-input-container').addClass('hidden')
      $modal.find('#search-container').removeClass('hidden')
    }

    $modal.find('.store-tab-info, .github-tab-info').addClass('hidden')
    $modal.find(`.${activeTab}-tab-info`).removeClass('hidden')

    if ($currentPanel.length) {
      $currentPanel.css({ opacity: 1, transform: 'translateX(0)', transition: 'opacity 0.15s ease-out, transform 0.15s ease-out' })
      setTimeout(() => {
        $currentPanel.css({ opacity: 0, transform: 'translateX(-10px)' })
        setTimeout(() => {
          $currentPanel.addClass('hidden')
          $newPanel.removeClass('hidden').css({ opacity: 0, transform: 'translateX(10px)', transition: 'opacity 0.15s ease-out, transform 0.15s ease-out' })
          setTimeout(() => $newPanel.css({ opacity: 1, transform: 'translateX(0)' }), 10)
        }, 150)
      }, 10)
    } else {
      $newPanel.removeClass('hidden')
    }
  }

  updateTabStyles()

  $modal.find('.store-tab-button').on('click', function () {
    activeTab = $(this).data('tab')
    updateTabStyles()
    if (activeTab === 'store') fetchPlugins()
    else if (activeTab === 'github') renderGitHubRepos()
  })

  const applyFilters = () => {
    const searchTerm = $modal.find('#pluginSearch').val().toLowerCase()
    const $container = $modal.find('#pluginsList')
    let visible = 0
    let total = 0

    $container.find('.plugin-card').each(function () {
      const name = $(this).data('plugin-name') || ''
      const matchesSearch = !searchTerm || name.includes(searchTerm)
      total++

      if (matchesSearch) {
        $(this).removeClass('hidden')
        visible++
      } else {
        $(this).addClass('hidden')
      }
    })

    $modal.find('#pluginCountInfo').text(`Showing ${visible} of ${total} plugins`)
  }

  $modal.find('#pluginSearch').on('input', applyFilters)

  const closeHandler = () => {
    if (typeof app.modals === 'object' && typeof app.modals.close === 'function') {
      app.modals.close()
    }
  }

  $modal.find('#closePluginHubHeaderBtn').on('click', closeHandler)
  $modal.find('#modalBackdrop').on('click', closeHandler)

  let refreshInProgress = false
  $modal.find('#refreshPluginsBtn').on('click', async function () {
    if (refreshInProgress) return
    refreshInProgress = true
    const $btn = $(this)
    $btn.prop('disabled', true).addClass('opacity-50')
    $btn.find('i').addClass('fa-spin')
    localStorage.removeItem(CACHE_KEY)
    localStorage.removeItem(CACHE_TIME_KEY)
    localStorage.removeItem(CACHE_METADATA_KEY)
    if (activeTab === 'store') await fetchPlugins(true)
    else if (activeTab === 'github') await renderGitHubRepos()
    $btn.prop('disabled', false).removeClass('opacity-50')
    $btn.find('i').removeClass('fa-spin')
    refreshInProgress = false
  })

  const getSavedGitHubRepos = () => {
    try {
      const savedRepos = localStorage.getItem(GITHUB_REPOS_KEY)
      return savedRepos ? JSON.parse(savedRepos) : []
    } catch (_) {
      return []
    }
  }

  const saveGitHubRepo = (repo) => {
    try {
      const savedRepos = getSavedGitHubRepos()
      const repoExists = savedRepos.some(r => r.url === repo.url)
      if (!repoExists) {
        savedRepos.push(repo)
        localStorage.setItem(GITHUB_REPOS_KEY, JSON.stringify(savedRepos))
      }
      return !repoExists
    } catch (_) {
      return false
    }
  }

  const removeGitHubRepo = (repoUrl) => {
    try {
      let savedRepos = getSavedGitHubRepos()
      savedRepos = savedRepos.filter(r => r.url !== repoUrl)
      localStorage.setItem(GITHUB_REPOS_KEY, JSON.stringify(savedRepos))
      return true
    } catch (_) {
      return false
    }
  }

  const parseGitHubUrl = (url) => {
    try {
      const basicPattern = /^https?:\/\/(?:www\.)?github\.com\/([^\/]+)\/([^\/]+)\/?$/
      const treePattern = /^https?:\/\/(?:www\.)?github\.com\/([^\/]+)\/([^\/]+)\/tree\/[^\/]+\/(.+)$/

      let match = url.match(basicPattern)
      if (match && match.length === 3) {
        return { owner: match[1], repo: match[2], path: '', url: url.replace(/\/$/, '') }
      }

      match = url.match(treePattern)
      if (match && match.length === 4) {
        return { owner: match[1], repo: match[2], path: match[3], url: `https://github.com/${match[1]}/${match[2]}` }
      }

      return null
    } catch (_) {
      return null
    }
  }

  const fetchGitHubRepoPlugins = async (repoInfo) => {
    try {
      let pluginsApiUrl
      let directPlugin = false

      if (repoInfo.path) {
        pluginsApiUrl = `https://api.github.com/repos/${repoInfo.owner}/${repoInfo.repo}/contents/${repoInfo.path}`
        directPlugin = true
      } else {
        pluginsApiUrl = `https://api.github.com/repos/${repoInfo.owner}/${repoInfo.repo}/contents/plugins`
        let response = await fetch(pluginsApiUrl)
        if (!response.ok && response.status === 404) {
          pluginsApiUrl = `https://api.github.com/repos/${repoInfo.owner}/${repoInfo.repo}/contents`
        }
      }

      const response = await fetch(pluginsApiUrl)
      if (!response.ok) throw new Error(`GitHub API error: ${response.statusText}`)
      const contents = await response.json()

      if (directPlugin) {
        const pluginName = repoInfo.customName || repoInfo.path.split('/').pop()
        return [{
          name: pluginName, path: repoInfo.path,
          html_url: `https://github.com/${repoInfo.owner}/${repoInfo.repo}/tree/main/${repoInfo.path}`,
          type: 'dir', sourceRepo: 'github', repoOwner: repoInfo.owner, repoName: repoInfo.repo
        }]
      }

      return contents.filter(item => item.type === 'dir').map(item => ({
        ...item, sourceRepo: 'github', repoOwner: repoInfo.owner, repoName: repoInfo.repo
      }))
    } catch (_) {
      return []
    }
  }

  $modal.find('#fetchGithubRepoBtn').on('click', function () {
    const repoUrl = $modal.find('#githubRepoInput').val().trim()
    if (!repoUrl) { alert('Please enter a GitHub repository URL.'); return }
    const parsedRepo = parseGitHubUrl(repoUrl)
    if (!parsedRepo) { alert('Invalid GitHub repository URL.'); return }
    const $details = $modal.find('#githubPluginDetails')
    $details.removeClass('hidden')
    if (parsedRepo.path) $modal.find('#githubPluginPath').val(parsedRepo.path)
    $modal.find('#githubPluginPath').focus()
  })

  $modal.find('#addGithubRepoBtn').on('click', function () {
    const repoUrl = $modal.find('#githubRepoInput').val().trim()
    const pluginPath = $modal.find('#githubPluginPath').val().trim()
    const pluginName = $modal.find('#githubPluginName').val().trim()
    if (!repoUrl) { alert('Please enter a GitHub repository URL.'); return }
    const parsedRepo = parseGitHubUrl(repoUrl)
    if (!parsedRepo) { alert('Invalid GitHub repository URL.'); return }
    if (pluginPath) parsedRepo.path = pluginPath
    if (pluginName) parsedRepo.customName = pluginName
    const wasAdded = saveGitHubRepo(parsedRepo)
    if (wasAdded) {
      $modal.find('#githubRepoInput').val('')
      $modal.find('#githubPluginPath').val('')
      $modal.find('#githubPluginName').val('')
      $modal.find('#githubPluginDetails').addClass('hidden')
      renderGitHubRepos()
    } else {
      alert('This repository is already in your list.')
    }
  })

  $modal.find('#githubRepoInput').on('keypress', function (e) {
    if (e.which === 13) $modal.find('#fetchGithubRepoBtn').click()
  })

  $modal.find('#githubPluginPath, #githubPluginName').on('keypress', function (e) {
    if (e.which === 13) $modal.find('#addGithubRepoBtn').click()
  })

  const isPluginInstalled = async (pluginName) => {
    try {
      const bundledPluginPath = path.join(LOCAL_PLUGINS_DIR, pluginName)
      if (fs.existsSync(bundledPluginPath)) return true
      const userPluginsPath = await getUserPluginsPath()
      const userPluginPath = path.join(userPluginsPath, pluginName)
      return fs.existsSync(userPluginPath)
    } catch (_) {
      return false
    }
  }

  const fetchPluginMetadata = async (plugin) => {
    try {
      const metadataCache = localStorage.getItem(CACHE_METADATA_KEY)
      if (metadataCache) {
        const parsedCache = JSON.parse(metadataCache)
        if (parsedCache[plugin.sourceRepo] && parsedCache[plugin.sourceRepo][plugin.name]) {
          return parsedCache[plugin.sourceRepo][plugin.name]
        }
      }

      let pluginJsonUrl
      if (plugin.sourceRepo === 'strawberry-jam') {
        pluginJsonUrl = `https://api.github.com/repos/glvckoma/strawberry-jam/contents/plugins/${plugin.name}/plugin.json`
      } else if (plugin.sourceRepo === 'original-jam') {
        pluginJsonUrl = `https://api.github.com/repos/Sxip/plugins/contents/${plugin.name}/plugin.json`
      } else {
        pluginJsonUrl = `https://api.github.com/repos/Secretmimi/plugins-jam/contents/plugins/${plugin.name}/plugin.json`
      }

      const response = await fetch(pluginJsonUrl)

      if (response.ok) {
        const data = await response.json()
        const content = atob(data.content)
        const metadata = JSON.parse(content)
        if (!metadata.author) {
          metadata.author = plugin.sourceRepo === 'strawberry-jam' ? 'Strawberry Jam' : (plugin.sourceRepo === 'original-jam' ? 'Sxip' : 'nosmile')
        }
        cachePluginMetadata(plugin.sourceRepo, plugin.name, metadata)
        return metadata
      }

      const defaultAuthor = plugin.sourceRepo === 'strawberry-jam' ? 'Strawberry Jam' : (plugin.sourceRepo === 'original-jam' ? 'Sxip' : 'nosmile')
      const defaultDesc = plugin.sourceRepo === 'strawberry-jam' ? 'A plugin for Strawberry Jam' : (plugin.sourceRepo === 'original-jam' ? 'A plugin for Jam' : 'A plugin from an external contributor')
      const defaultMetadata = { name: plugin.name, description: defaultDesc, author: defaultAuthor }
      if (response.status === 404) cachePluginMetadata(plugin.sourceRepo, plugin.name, defaultMetadata)
      return defaultMetadata
    } catch (_) {
      const defaultAuthor = plugin.sourceRepo === 'strawberry-jam' ? 'Strawberry Jam' : (plugin.sourceRepo === 'original-jam' ? 'Sxip' : 'nosmile')
      return {
        name: plugin.name,
        description: plugin.sourceRepo === 'strawberry-jam' ? 'A plugin for Strawberry Jam' : (plugin.sourceRepo === 'original-jam' ? 'A plugin for Jam' : 'A plugin from an external contributor'),
        author: defaultAuthor
      }
    }
  }

  const cachePluginMetadata = (sourceRepo, pluginName, metadata) => {
    try {
      const existingCache = localStorage.getItem(CACHE_METADATA_KEY) || '{}'
      const cacheData = JSON.parse(existingCache)
      if (!cacheData[sourceRepo]) cacheData[sourceRepo] = {}
      cacheData[sourceRepo][pluginName] = metadata
      localStorage.setItem(CACHE_METADATA_KEY, JSON.stringify(cacheData))
    } catch (_) {}
  }

  let uninstallInProgress = false
  const uninstallPlugin = async (pluginName) => {
    if (uninstallInProgress) return
    uninstallInProgress = true
    try {
      $modal.find('.uninstall-plugin-btn').prop('disabled', true).addClass('opacity-50')
      app.consoleMessage({ message: `Uninstalling plugin: ${pluginName}...`, type: 'wait' })

      const userPluginsPath = await getUserPluginsPath()
      const userPluginDir = path.join(userPluginsPath, pluginName)
      const bundledPluginDir = path.join(LOCAL_PLUGINS_DIR, pluginName)

      let pluginDir = null
      let isBundled = false

      if (fs.existsSync(userPluginDir)) {
        pluginDir = userPluginDir
      } else if (fs.existsSync(bundledPluginDir)) {
        pluginDir = bundledPluginDir
        isBundled = true
      } else {
        throw new Error(`Plugin "${pluginName}" is not installed`)
      }

      if (isBundled) throw new Error(`Plugin "${pluginName}" is a bundled plugin and cannot be uninstalled.`)

      const deleteDirectory = (dirPath) => {
        if (fs.existsSync(dirPath)) {
          try {
            fs.readdirSync(dirPath).forEach((file) => {
              const curPath = path.join(dirPath, file)
              try {
                if (fs.lstatSync(curPath).isDirectory()) deleteDirectory(curPath)
                else fs.unlinkSync(curPath)
              } catch (_) {}
            })
            fs.rmdirSync(dirPath)
          } catch (_) {
            try { fs.rmdirSync(dirPath, { recursive: true, force: true }) } catch (e) {
              throw new Error(`Could not remove plugin directory: ${e.message}`)
            }
          }
        }
      }

      deleteDirectory(pluginDir)
      app.consoleMessage({ message: `Plugin "${pluginName}" has been successfully uninstalled.`, type: 'success' })
      app.modals.close()
      await refreshPluginsWithAnimation()

      if (activeTab === 'store') await fetchPlugins(true)
      else if (activeTab === 'github') renderGitHubRepos()
    } catch (error) {
      app.consoleMessage({ message: `Failed to uninstall plugin "${pluginName}": ${error.message}`, type: 'error' })
    } finally {
      $modal.find('.uninstall-plugin-btn').prop('disabled', false).removeClass('opacity-50')
      uninstallInProgress = false
    }
  }

  let installInProgress = false

  const downloadPluginFiles = async (contentsUrl, pluginDir) => {
    const response = await fetch(contentsUrl)
    if (!response.ok) throw new Error(`Failed to fetch plugin contents: ${response.statusText}`)
    const contents = await response.json()
    const filesArray = Array.isArray(contents) ? contents : [contents]

    for (const file of filesArray) {
      if (file.type === 'file') {
        const fileResponse = await fetch(file.download_url)
        if (!fileResponse.ok) throw new Error(`Failed to download ${file.name}: ${fileResponse.statusText}`)
        const fileContent = await fileResponse.text()
        fs.writeFileSync(path.join(pluginDir, file.name), fileContent)
      } else if (file.type === 'dir') {
        const subDir = path.join(pluginDir, file.name)
        if (!fs.existsSync(subDir)) fs.mkdirSync(subDir, { recursive: true })
        const subResponse = await fetch(file.url)
        if (subResponse.ok) {
          const subContents = await subResponse.json()
          for (const subFile of subContents) {
            if (subFile.type === 'file') {
              const subFileResponse = await fetch(subFile.download_url)
              if (subFileResponse.ok) {
                const subFileContent = await subFileResponse.text()
                fs.writeFileSync(path.join(subDir, subFile.name), subFileContent)
              }
            }
          }
        }
      }
    }
  }

  const installPlugin = async (plugin) => {
    if (installInProgress) return
    installInProgress = true
    try {
      $modal.find('.install-plugin-btn').prop('disabled', true).addClass('opacity-50')
      app.consoleMessage({ message: `Installing plugin: ${plugin.name}...`, type: 'wait' })

      const userPluginsPath = await getUserPluginsPath()
      if (!fs.existsSync(userPluginsPath)) fs.mkdirSync(userPluginsPath, { recursive: true })
      const pluginDir = path.join(userPluginsPath, plugin.name)
      if (!fs.existsSync(pluginDir)) fs.mkdirSync(pluginDir, { recursive: true })

      const response = await fetch(plugin.url)
      if (!response.ok) {
        if (response.status === 403 && response.headers.get('X-RateLimit-Remaining') === '0') {
          const resetTime = response.headers.get('X-RateLimit-Reset')
          const resetDate = new Date(resetTime * 1000)
          throw new Error(`GitHub rate limit exceeded. Try again after ${resetDate.toLocaleTimeString()}.`)
        }
        throw new Error(`Failed to fetch plugin contents: ${response.statusText}`)
      }

      const contents = await response.json()
      const filesArray = Array.isArray(contents) ? contents : [contents]

      for (const file of filesArray) {
        if (file.type === 'file') {
          const fileResponse = await fetch(file.download_url)
          if (!fileResponse.ok) throw new Error(`Failed to download ${file.name}: ${fileResponse.statusText}`)
          fs.writeFileSync(path.join(pluginDir, file.name), await fileResponse.text())
        } else if (file.type === 'dir') {
          const subDir = path.join(pluginDir, file.name)
          if (!fs.existsSync(subDir)) fs.mkdirSync(subDir, { recursive: true })
          const subResponse = await fetch(file.url)
          if (subResponse.ok) {
            const subContents = await subResponse.json()
            for (const subFile of subContents) {
              if (subFile.type === 'file') {
                const subFileResponse = await fetch(subFile.download_url)
                if (subFileResponse.ok) fs.writeFileSync(path.join(subDir, subFile.name), await subFileResponse.text())
              }
            }
          }
        }
      }

      if (plugin.sourceRepo === 'strawberry-jam') fs.writeFileSync(path.join(pluginDir, '.sj-source'), '')
      else if (plugin.sourceRepo === 'original-jam') fs.writeFileSync(path.join(pluginDir, '.jam-source'), '')

      if (activeTab === 'store') app.modals.close()
      app.consoleMessage({ message: `Plugin "${plugin.name}" has been successfully installed.`, type: 'success' })
      await refreshPluginsWithAnimation()
    } catch (error) {
      app.consoleMessage({ message: `Failed to install plugin "${plugin.name}": ${error.message}`, type: 'error' })
    } finally {
      $modal.find('.install-plugin-btn').prop('disabled', false).removeClass('opacity-50')
      installInProgress = false
    }
  }

  const installGitHubPlugin = async (plugin) => {
    if (installInProgress) return
    installInProgress = true
    try {
      $modal.find('.install-github-plugin-btn').prop('disabled', true).addClass('opacity-50')
      app.consoleMessage({ message: `Installing plugin from GitHub: ${plugin.name}...`, type: 'wait' })

      const userPluginsPath = await getUserPluginsPath()
      if (!fs.existsSync(userPluginsPath)) fs.mkdirSync(userPluginsPath, { recursive: true })
      const pluginDir = path.join(userPluginsPath, plugin.name)
      if (!fs.existsSync(pluginDir)) fs.mkdirSync(pluginDir, { recursive: true })

      const contentsUrl = `https://api.github.com/repos/${plugin.repoOwner}/${plugin.repoName}/contents/${plugin.path}`
      await downloadPluginFiles(contentsUrl, pluginDir)
      fs.writeFileSync(path.join(pluginDir, '.github-source'), '')

      app.consoleMessage({ message: `Plugin "${plugin.name}" has been successfully installed.`, type: 'success' })
      await refreshPluginsWithAnimation()
      if (activeTab === 'github') renderGitHubRepos()
    } catch (error) {
      app.consoleMessage({ message: `Failed to install plugin "${plugin.name}" from GitHub: ${error.message}`, type: 'error' })
    } finally {
      $modal.find('.install-github-plugin-btn').prop('disabled', false).removeClass('opacity-50')
      installInProgress = false
    }
  }

  const fetchPlugins = async (forceRefresh = false) => {
    const $pluginsList = $modal.find('#pluginsList')

    try {
      if (!forceRefresh) {
        const cachedData = localStorage.getItem(CACHE_KEY)
        const cacheTime = localStorage.getItem(CACHE_TIME_KEY)
        const cacheAge = cacheTime ? Date.now() - parseInt(cacheTime) : Infinity
        if (cachedData && cacheAge < CACHE_DURATION) {
          await displayPlugins(JSON.parse(cachedData))
          return
        }
      }

      $pluginsList.html('<div class="col-span-full flex justify-center items-center h-32"><i class="fas fa-circle-notch fa-spin text-gray-400 mr-2"></i><span class="text-gray-400 text-sm">Loading plugins...</span></div>')

      let allPlugins = []
      for (const repoInfo of GITHUB_API_URLS) {
        const response = await fetch(repoInfo.url)
        if (response.status === 403) {
          const rateLimitRemaining = response.headers.get('X-RateLimit-Remaining')
          if (rateLimitRemaining === '0') {
            const resetTime = response.headers.get('X-RateLimit-Reset')
            const resetDate = new Date(resetTime * 1000)
            $pluginsList.html(`<div class="col-span-full text-center text-error-red p-4"><i class="fas fa-exclamation-circle mr-2"></i>GitHub rate limit exceeded. Try again after ${resetDate.toLocaleTimeString()}.</div>`)
            return
          }
        }
        if (!response.ok) throw new Error(`GitHub API error: ${response.statusText}`)
        const plugins = await response.json()
        for (const plugin of plugins) {
          if (plugin.type === 'dir') allPlugins.push({ ...plugin, sourceRepo: repoInfo.repo })
        }
      }

      const pluginMap = new Map()
      for (const plugin of allPlugins) {
        if (!pluginMap.has(plugin.name) || plugin.sourceRepo === 'strawberry-jam') {
          pluginMap.set(plugin.name, plugin)
        }
      }
      const mergedPlugins = Array.from(pluginMap.values())

      localStorage.setItem(CACHE_KEY, JSON.stringify(mergedPlugins))
      localStorage.setItem(CACHE_TIME_KEY, Date.now().toString())
      await displayPlugins(mergedPlugins)
    } catch (error) {
      $pluginsList.html(`<div class="col-span-full text-center text-error-red p-4"><i class="fas fa-exclamation-circle mr-2"></i>Error fetching plugins: ${error.message}</div>`)
    }
  }

  const displayPlugins = async (plugins) => {
    const $pluginsList = $modal.find('#pluginsList')
    $pluginsList.empty()

    if (!plugins || plugins.length === 0) {
      $pluginsList.html('<div class="col-span-full text-center text-gray-400 py-8">No plugins found</div>')
      return
    }

    const pluginPromises = plugins
      .filter(plugin => plugin.type === 'dir')
      .map(async plugin => ({
        plugin,
        installed: await isPluginInstalled(plugin.name),
        metadata: await fetchPluginMetadata(plugin)
      }))

    try {
      const pluginData = await Promise.all(pluginPromises)

      pluginData.forEach(({ plugin, installed, metadata }) => {
        if (installed) return
        const cardHtml = PluginCard.render({
          metadata,
          installed: false,
          source: plugin.sourceRepo,
          plugin,
          actions: {
            viewRepo: plugin.html_url,
            install: { className: 'install-plugin-btn' }
          }
        })
        $pluginsList.append(cardHtml)
      })

      $pluginsList.find('.install-plugin-btn').on('click', function () {
        const plugin = JSON.parse(decodeURIComponent($(this).data('plugin')))
        installPlugin(plugin)
      })

      $pluginsList.find('.uninstall-plugin-btn').on('click', function () {
        const pluginName = $(this).data('plugin-name')
        if (confirm(`Are you sure you want to uninstall the "${pluginName}" plugin?`)) uninstallPlugin(pluginName)
      })

      $pluginsList.find('.view-repo-btn').on('click', function () {
        app.open($(this).data('repo-url'))
      })

      applyFilters()
    } catch (error) {
      $pluginsList.html(`<div class="col-span-full text-center text-error-red p-4"><i class="fas fa-exclamation-circle mr-2"></i>Error loading plugin details: ${error.message}</div>`)
    }
  }

  const displayGitHubPlugins = async (plugins) => {
    const $pluginsList = $modal.find('#githubPluginsList')
    $pluginsList.empty()

    const pluginPromises = plugins.map(async plugin => {
      const installed = await isPluginInstalled(plugin.name)
      let metadata = { name: plugin.name, description: `A plugin from ${plugin.repoOwner}/${plugin.repoName}`, author: plugin.repoOwner }

      try {
        const metadataUrl = `https://api.github.com/repos/${plugin.repoOwner}/${plugin.repoName}/contents/${plugin.path}/plugin.json`
        const response = await fetch(metadataUrl)
        if (response.ok) {
          const data = await response.json()
          const parsedMetadata = JSON.parse(atob(data.content))
          if (parsedMetadata.name) metadata.name = parsedMetadata.name
          if (parsedMetadata.description) metadata.description = parsedMetadata.description
          if (parsedMetadata.author) metadata.author = parsedMetadata.author
          if (parsedMetadata.version) metadata.version = parsedMetadata.version
          if (parsedMetadata.tags) metadata.tags = parsedMetadata.tags
        }
      } catch (_) {}

      return { plugin, installed, metadata }
    })

    try {
      const pluginData = await Promise.all(pluginPromises)

      pluginData.forEach(({ plugin, installed, metadata }) => {
        if (installed) return
        const cardHtml = PluginCard.render({
          metadata,
          installed: false,
          source: 'github',
          plugin,
          actions: {
            viewRepo: `https://github.com/${plugin.repoOwner}/${plugin.repoName}/tree/main/${plugin.path}`,
            install: { className: 'install-github-plugin-btn' }
          }
        })
        $pluginsList.append(cardHtml)
      })

      $pluginsList.find('.view-repo-btn').on('click', function () {
        app.open($(this).data('repo-url'))
      })

      $pluginsList.find('.install-github-plugin-btn').on('click', function () {
        const plugin = JSON.parse(decodeURIComponent($(this).data('plugin')))
        installGitHubPlugin(plugin)
      })

      $pluginsList.find('.uninstall-plugin-btn').on('click', function () {
        const pluginName = $(this).data('plugin-name')
        if (confirm(`Are you sure you want to uninstall the "${pluginName}" plugin?`)) {
          uninstallPlugin(pluginName)
          setTimeout(() => renderGitHubRepos(), 500)
        }
      })
    } catch (error) {
      $pluginsList.html(`<div class="col-span-full text-center text-error-red p-4"><i class="fas fa-exclamation-circle mr-2"></i>Error loading plugin details: ${error.message}</div>`)
    }
  }

  const renderGitHubRepos = async () => {
    const $reposList = $modal.find('#githubReposList')
    const $pluginsList = $modal.find('#githubPluginsList')
    $reposList.empty()
    $pluginsList.empty()

    const savedRepos = getSavedGitHubRepos()

    if (savedRepos.length === 0) {
      $reposList.html('<div class="bg-tertiary-bg/30 rounded-lg p-4 text-center"><p class="text-gray-400 text-sm">No GitHub repositories added yet.</p><p class="text-xs text-gray-500 mt-1">Add a repository URL above to get started.</p></div>')
      return
    }

    $pluginsList.html('<div class="col-span-full flex justify-center items-center h-32"><i class="fas fa-circle-notch fa-spin text-gray-400 mr-2"></i><span class="text-gray-400 text-sm">Loading plugins from GitHub...</span></div>')

    for (const repo of savedRepos) {
      $reposList.append(`
        <div class="bg-tertiary-bg/30 rounded-lg px-3 py-2 flex justify-between items-center">
          <div class="flex items-center space-x-2">
            <i class="fab fa-github text-gray-400"></i>
            <span class="text-text-primary text-sm">${repo.owner}/${repo.repo}</span>
          </div>
          <div class="flex gap-1">
            <button class="text-sm text-gray-400 hover:text-highlight-green transition p-1 rounded view-github-repo-btn" data-repo-url="${repo.url}"><i class="fas fa-external-link-alt"></i></button>
            <button class="text-sm text-error-red hover:text-error-red/80 transition p-1 rounded remove-github-repo-btn" data-repo-url="${repo.url}"><i class="fas fa-trash-alt"></i></button>
          </div>
        </div>
      `)
    }

    $reposList.find('.view-github-repo-btn').on('click', function () {
      app.open($(this).data('repo-url'))
    })

    $reposList.find('.remove-github-repo-btn').on('click', function () {
      const repoUrl = $(this).data('repo-url')
      if (confirm('Are you sure you want to remove this GitHub repository?')) {
        removeGitHubRepo(repoUrl)
        renderGitHubRepos()
      }
    })

    let allPlugins = []
    for (const repo of savedRepos) {
      const plugins = await fetchGitHubRepoPlugins(repo)
      allPlugins = allPlugins.concat(plugins)
    }

    if (allPlugins.length === 0) {
      $pluginsList.html('<div class="col-span-full text-center text-gray-400 py-4 text-sm">No plugins found in the added GitHub repositories.</div>')
      return
    }

    await displayGitHubPlugins(allPlugins)
  }

  const fetchInstalledPlugins = async () => {
    const $pluginsList = $modal.find('#installedPluginsList')
    $pluginsList.html('<div class="col-span-full flex justify-center items-center h-32"><i class="fas fa-circle-notch fa-spin text-gray-400 mr-2"></i><span class="text-gray-400 text-sm">Loading installed plugins...</span></div>')

    try {
      const userPluginsPath = await getUserPluginsPath()
      const bundledPluginsPath = LOCAL_PLUGINS_DIR
      const allPlugins = new Map()

      if (fs.existsSync(userPluginsPath)) {
        fs.readdirSync(userPluginsPath, { withFileTypes: true })
          .filter(dirent => dirent.isDirectory())
          .forEach(dirent => allPlugins.set(dirent.name, { path: userPluginsPath, isBundled: false }))
      }

      if (fs.existsSync(bundledPluginsPath)) {
        fs.readdirSync(bundledPluginsPath, { withFileTypes: true })
          .filter(dirent => dirent.isDirectory())
          .forEach(dirent => {
            if (!allPlugins.has(dirent.name)) allPlugins.set(dirent.name, { path: bundledPluginsPath, isBundled: true })
          })
      }

      if (allPlugins.size === 0) {
        $pluginsList.html('<div class="col-span-full text-center text-gray-400 py-8"><p class="text-sm">No plugins installed.</p><p class="text-xs mt-1 text-gray-500">Go to the Store or GitHub tab to install plugins.</p></div>')
        return
      }

      $pluginsList.empty()

      for (const [pluginName, pluginInfo] of allPlugins) {
        const pluginsDir = pluginInfo.path
        const isBundled = pluginInfo.isBundled

        let metadata = { name: pluginName, description: 'A plugin for Strawberry Jam', author: 'Unknown', version: '', tags: [] }

        const pluginJsonPath = path.join(pluginsDir, pluginName, 'plugin.json')
        if (fs.existsSync(pluginJsonPath)) {
          try {
            const parsedMetadata = JSON.parse(fs.readFileSync(pluginJsonPath, 'utf8'))
            if (parsedMetadata.name) metadata.name = parsedMetadata.name
            if (parsedMetadata.description) metadata.description = parsedMetadata.description
            if (parsedMetadata.author) metadata.author = parsedMetadata.author
            if (parsedMetadata.version) metadata.version = parsedMetadata.version
            if (parsedMetadata.tags) metadata.tags = parsedMetadata.tags
            if (parsedMetadata.category) metadata.category = parsedMetadata.category
          } catch (_) {}
        }

        const pluginFiles = fs.readdirSync(path.join(pluginsDir, pluginName))
        let source = 'unknown'
        if (pluginFiles.includes('.github-source')) source = 'github'
        else if (pluginFiles.includes('.sj-source')) source = 'strawberry-jam'
        else if (pluginFiles.includes('.jam-source')) source = 'original-jam'

        const cardHtml = PluginCard.render({
          metadata,
          installed: true,
          source,
          plugin: { name: pluginName },
          isBundled,
          actions: {
            openFolder: { dir: pluginName, path: pluginsDir }
          }
        })
        $pluginsList.append(cardHtml)
      }

      $pluginsList.find('.open-plugin-folder-btn').on('click', function () {
        const pluginDir = $(this).data('plugin-dir')
        const pluginPath = $(this).data('plugin-path')
        app.invoke('open-directory', path.join(pluginPath, pluginDir))
      })

      $pluginsList.find('.uninstall-plugin-btn').on('click', function () {
        const pluginName = $(this).data('plugin-name')
        if (confirm(`Are you sure you want to uninstall the "${pluginName}" plugin?`)) {
          uninstallPlugin(pluginName)
          setTimeout(() => fetchInstalledPlugins(), 500)
        }
      })

      applyFilters()
    } catch (error) {
      $pluginsList.html(`<div class="col-span-full text-center text-error-red p-4"><i class="fas fa-exclamation-circle mr-2"></i>Error loading installed plugins: ${error.message}</div>`)
    }
  }

  if (activeTab === 'store') fetchPlugins()
  else if (activeTab === 'github') renderGitHubRepos()

  $modal.css({ opacity: 0, transform: 'scale(0.95)' })
  setTimeout(() => {
    $modal.css({ opacity: 1, transform: 'scale(1)', transition: 'opacity 0.2s ease-out, transform 0.2s ease-out' })
  }, 10)

  return $modal
}
