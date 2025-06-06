exports.name = 'pluginLibraryModal'

/**
 * Render the Plugin Library Modal
 * @param {Application} app - The application instance
 * @returns {JQuery<HTMLElement>} The rendered modal element
 */
exports.render = function (app) {
  const path = require('path')
  const fs = require('fs')

  const CACHE_KEY = 'jam-plugins-cache'
  const CACHE_TIME_KEY = 'jam-plugins-cache-time'
  const CACHE_METADATA_KEY = 'jam-plugins-metadata-cache'
  const CACHE_DURATION = 3600000
  const GITHUB_REPOS_KEY = 'jam-github-repos'

  const GITHUB_API_URLS = [
    {
      url: 'https://api.github.com/repos/glvckoma/strawberry-jam/contents/plugins',
      repo: 'strawberry-jam'
    },
    {
      url: 'https://api.github.com/repos/Sxip/plugins/contents/', // Updated URL for Sxip's plugins repo
      repo: 'original-jam' // Keep internal repo name for logic consistency
    }
  ];
  const LOCAL_PLUGINS_DIR = path.resolve('plugins/')

  // Define tab state
  let activeTab = 'store' // Default active tab: store, installed, github

  const $modal = $(`
    <div class="flex items-center justify-center min-h-screen p-4" style="z-index: 9999;">
      <!-- Modal Backdrop -->
      <div class="fixed inset-0 bg-black bg-opacity-70 backdrop-blur-sm transition-opacity" id="modalBackdrop" style="z-index: 9000;"></div>
      
      <!-- Modal Content -->
      <div class="relative bg-secondary-bg rounded-lg shadow-xl max-w-5xl w-full" style="z-index: 9100;">
        <!-- Modal Header -->
        <div class="flex items-center justify-between p-4 border-b border-sidebar-border">
          <h3 class="text-lg font-semibold text-text-primary">
            <i class="fas fa-puzzle-piece text-highlight-green mr-2"></i>
            Plugin Library
          </h3>
          <button type="button" class="text-gray-400 hover:bg-error-red hover:text-white transition-colors p-1 rounded-md" id="closePluginHubHeaderBtn" aria-label="Close">
            <i class="fas fa-times"></i>
          </button>
        </div>
        
        <!-- Tab Navigation -->
        <div class="px-4 pt-3 border-b border-sidebar-border">
          <div class="flex space-x-2">
            <button class="tab-button px-4 py-2 text-sm font-medium rounded-t-md transition-colors" data-tab="installed">
              <i class="fas fa-box-open mr-1"></i> Installed
            </button>
            <button class="tab-button px-4 py-2 text-sm font-medium rounded-t-md transition-colors active" data-tab="store">
              <i class="fas fa-store mr-1"></i> Store
            </button>
            <button class="tab-button px-4 py-2 text-sm font-medium rounded-t-md transition-colors" data-tab="github">
              <i class="fab fa-github mr-1"></i> GitHub
            </button>
          </div>
        </div>
        
        <!-- Search Bar -->
        <div class="px-4 py-3 border-b border-sidebar-border tab-content" id="search-container">
          <div class="relative">
            <input type="text" id="pluginSearch" placeholder="Search plugins..." 
              class="w-full bg-tertiary-bg text-text-primary placeholder-gray-400 p-2 pl-8 rounded-md focus:outline-none">
            <div class="absolute left-2 top-1/2 transform -translate-y-1/2 text-gray-400">
              <i class="fas fa-search"></i>
            </div>
          </div>
        </div>
        
        <!-- GitHub Repo Input -->
        <div class="px-4 py-3 border-b border-sidebar-border tab-content hidden" id="github-input-container">
          <div class="flex space-x-2">
            <div class="relative flex-grow">
              <input type="text" id="githubRepoInput" placeholder="Enter GitHub repository URL" 
                class="w-full bg-tertiary-bg text-text-primary placeholder-gray-400 p-2 pl-8 rounded-md focus:outline-none">
              <div class="absolute left-2 top-1/2 transform -translate-y-1/2 text-gray-400">
                <i class="fab fa-github"></i>
              </div>
            </div>
            <button id="fetchGithubRepoBtn" class="px-3 py-1 text-sm bg-highlight-green/20 text-highlight-green rounded hover:bg-highlight-green/30 transition">
              <i class="fas fa-search mr-1"></i> Fetch
            </button>
          </div>
          <p class="mt-2 text-xs text-gray-400">
            <i class="fas fa-info-circle mr-1"></i>
            Format: https://github.com/username/repository or https://github.com/username/repository/tree/branch/path/to/plugin
          </p>
          
          <!-- Additional fields for plugin path and name (initially hidden) -->
          <div id="githubPluginDetails" class="mt-3 space-y-3 hidden">
            <div>
              <label for="githubPluginPath" class="block text-xs text-gray-400 mb-1">Path to plugin:</label>
              <input type="text" id="githubPluginPath" placeholder="e.g., plugins/myplugin" 
                class="w-full bg-tertiary-bg text-text-primary placeholder-gray-400 p-2 rounded-md focus:outline-none">
            </div>
            <div>
              <label for="githubPluginName" class="block text-xs text-gray-400 mb-1">Plugin name:</label>
              <input type="text" id="githubPluginName" placeholder="Custom plugin name (optional)" 
                class="w-full bg-tertiary-bg text-text-primary placeholder-gray-400 p-2 rounded-md focus:outline-none">
            </div>
            <div class="flex justify-end">
              <button id="addGithubRepoBtn" class="px-3 py-1 text-sm bg-highlight-green/20 text-highlight-green rounded hover:bg-highlight-green/30 transition">
                <i class="fas fa-plus mr-1"></i> Add Repository
              </button>
            </div>
          </div>
        </div>
        
        <!-- Modal Body -->
        <div class="p-5 h-[400px] overflow-y-auto">
          <!-- Store Tab Content -->
          <div id="store-content" class="tab-panel">
            <div id="pluginsList" class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="col-span-full flex justify-center items-center h-32">
                <i class="fas fa-circle-notch fa-spin text-gray-400 mr-2"></i>
                <span class="text-gray-400">Loading plugins...</span>
              </div>
            </div>
          </div>
          
          <!-- Installed Tab Content -->
          <div id="installed-content" class="tab-panel hidden">
            <div id="installedPluginsList" class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="col-span-full flex justify-center items-center h-32">
                <i class="fas fa-circle-notch fa-spin text-gray-400 mr-2"></i>
                <span class="text-gray-400">Loading installed plugins...</span>
              </div>
            </div>
          </div>
          
          <!-- GitHub Tab Content -->
          <div id="github-content" class="tab-panel hidden">
            <div id="githubReposList" class="space-y-4 mb-4">
              <!-- GitHub repos will be listed here -->
            </div>
            <div id="githubPluginsList" class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <!-- GitHub plugins will be displayed here -->
            </div>
          </div>
        </div>
        
        <!-- Modal Footer -->
        <div class="flex items-center justify-between p-4 border-t border-sidebar-border">
          <div>
            <span class="text-sm text-gray-400 store-tab-info">
              <i class="fas fa-info-circle mr-1"></i>
              Plugins are loaded from the official repository
            </span>
            <span class="text-sm text-gray-400 installed-tab-info hidden">
              <i class="fas fa-info-circle mr-1"></i>
              Manage your installed plugins
            </span>
            <span class="text-sm text-gray-400 github-tab-info hidden">
              <i class="fas fa-info-circle mr-1"></i>
              Add plugins from custom GitHub repositories
            </span>
          </div>
          <div class="flex space-x-2">
            <button type="button" class="text-xs text-gray-400 hover:text-highlight-green transition px-2 py-1 rounded store-tab-btn" id="refreshPluginsBtn">
              <i class="fas fa-sync-alt mr-1"></i> Refresh
            </button>
            <button type="button" class="modal-close-button-std text-gray-400 transition-colors duration-200 transform rounded-full p-1 bg-tertiary-bg px-3 py-1" id="closeModalBtn">
              Close
            </button>
          </div>
        </div>
      </div>
    </div>
  `)

  // Apply tab styling
  const updateTabStyles = () => {
    $modal.find('.tab-button').removeClass('active border-b-2 border-highlight-green text-highlight-green').addClass('text-gray-400');
    $modal.find(`.tab-button[data-tab="${activeTab}"]`).addClass('active border-b-2 border-highlight-green text-highlight-green').removeClass('text-gray-400');
    
    // Get current active panel
    const $currentPanel = $modal.find('.tab-panel:not(.hidden)');
    const $newPanel = $modal.find(`#${activeTab}-content`);
    
    // Don't animate if it's already active
    if ($currentPanel.attr('id') === $newPanel.attr('id')) {
      return;
    }
    
    // Show/hide search or github input based on active tab
    if (activeTab === 'github') {
      $modal.find('#search-container').fadeOut(150, function() {
        $modal.find('#github-input-container').fadeIn(150);
      });
    } else {
      $modal.find('#github-input-container').fadeOut(150, function() {
        $modal.find('#search-container').fadeIn(150);
      });
    }
    
    // Show/hide tab-specific footer elements with fade
    $modal.find('.store-tab-info, .installed-tab-info, .github-tab-info').fadeOut(150);
    setTimeout(() => {
      $modal.find(`.${activeTab}-tab-info`).fadeIn(150);
    }, 150);
    
    $modal.find('.store-tab-btn').fadeOut(150);
    if (activeTab === 'store') {
      setTimeout(() => $modal.find('.store-tab-btn').fadeIn(150), 150);
    }
    
    // Animate tab content panels with smooth transitions
    if ($currentPanel.length) {
      // Fade out current panel
      $currentPanel.css({
        'opacity': '1',
        'transform': 'translateX(0)',
        'transition': 'opacity 0.2s ease-out, transform 0.25s ease-out'
      });
      
      setTimeout(() => {
        $currentPanel.css({
          'opacity': '0',
          'transform': 'translateX(-15px)'
        });
        
        // Hide current panel after fade out and prep new panel for fade in
        setTimeout(() => {
          $currentPanel.addClass('hidden');
          
          // Show and fade in new panel
          $newPanel.removeClass('hidden').css({
            'opacity': '0',
            'transform': 'translateX(15px)',
            'transition': 'opacity 0.25s ease-out, transform 0.25s ease-out'
          });
          
          // Start animation after a tiny delay to ensure CSS is applied
          setTimeout(() => {
            $newPanel.css({
              'opacity': '1',
              'transform': 'translateX(0)'
            });
          }, 10);
        }, 200);
      }, 10);
    } else {
      // If no current panel, just show the new one
      $newPanel.removeClass('hidden');
    }
  }
  
  // Initial tab styling
  updateTabStyles();
  
  // Tab click event
  $modal.find('.tab-button').on('click', function() {
    activeTab = $(this).data('tab');
    updateTabStyles();
    
    // Load content for the selected tab
    if (activeTab === 'store') {
      fetchPlugins();
    } else if (activeTab === 'installed') {
      fetchInstalledPlugins();
    } else if (activeTab === 'github') {
      renderGitHubRepos();
    }
  });

  const closeHandler = () => {
    if (typeof app.modals === 'object' && typeof app.modals.close === 'function') {
      app.modals.close()
    }
  }

  $modal.find('#closeLibraryModalBtn, #closeModalBtn, #closePluginHubHeaderBtn').on('click', closeHandler)

  $modal.find('#modalBackdrop').on('click', function () {
    app.modals.close()
  })

  // Prevent multiple simultaneous refreshes
  let refreshInProgress = false;
  $modal.find('#refreshPluginsBtn').on('click', async function () {
    if (refreshInProgress) return;
    refreshInProgress = true;
    const $btn = $(this);
    $btn.prop('disabled', true).addClass('opacity-50');
    localStorage.removeItem(CACHE_KEY)
    localStorage.removeItem(CACHE_TIME_KEY)
    localStorage.removeItem(CACHE_METADATA_KEY)
    await fetchPlugins(true)
    $btn.prop('disabled', false).removeClass('opacity-50');
    refreshInProgress = false;
  })
  
  /**
   * Get saved GitHub repositories
   * @returns {Array} Array of saved GitHub repository objects
   */
  const getSavedGitHubRepos = () => {
    try {
      const savedRepos = localStorage.getItem(GITHUB_REPOS_KEY);
      return savedRepos ? JSON.parse(savedRepos) : [];
    } catch (error) {
      console.error('Error getting saved GitHub repos:', error);
      return [];
    }
  }

  /**
   * Save a GitHub repository to local storage
   * @param {Object} repo Repository object with url, name, and owner properties
   */
  const saveGitHubRepo = (repo) => {
    try {
      const savedRepos = getSavedGitHubRepos();
      // Check if repo already exists
      const repoExists = savedRepos.some(r => r.url === repo.url);
      
      if (!repoExists) {
        savedRepos.push(repo);
        localStorage.setItem(GITHUB_REPOS_KEY, JSON.stringify(savedRepos));
      }
      
      return !repoExists; // Return true if added, false if already exists
    } catch (error) {
      console.error('Error saving GitHub repo:', error);
      return false;
    }
  }

  /**
   * Remove a GitHub repository from local storage
   * @param {string} repoUrl URL of the repository to remove
   */
  const removeGitHubRepo = (repoUrl) => {
    try {
      let savedRepos = getSavedGitHubRepos();
      savedRepos = savedRepos.filter(r => r.url !== repoUrl);
      localStorage.setItem(GITHUB_REPOS_KEY, JSON.stringify(savedRepos));
      return true;
    } catch (error) {
      console.error('Error removing GitHub repo:', error);
      return false;
    }
  }

  /**
   * Parse GitHub URL to extract owner and repo name
   * @param {string} url GitHub repository URL
   * @returns {Object|null} Object with owner and repo properties, or null if invalid
   */
  const parseGitHubUrl = (url) => {
    try {
      // Basic GitHub URL pattern
      const basicGithubPattern = /^https?:\/\/(?:www\.)?github\.com\/([^\/]+)\/([^\/]+)\/?$/;
      // Extended pattern for URLs with tree paths
      const treePathPattern = /^https?:\/\/(?:www\.)?github\.com\/([^\/]+)\/([^\/]+)\/tree\/[^\/]+\/(.+)$/;
      
      let match = url.match(basicGithubPattern);
      
      if (match && match.length === 3) {
        return {
          owner: match[1],
          repo: match[2],
          path: '',
          url: url.replace(/\/$/, '') // Remove trailing slash if present
        };
      }
      
      // Check for tree path pattern
      match = url.match(treePathPattern);
      if (match && match.length === 4) {
        return {
          owner: match[1],
          repo: match[2],
          path: match[3],
          url: `https://github.com/${match[1]}/${match[2]}`
        };
      }
      
      return null;
    } catch (error) {
      console.error('Error parsing GitHub URL:', error);
      return null;
    }
  }

  /**
   * Fetch plugins from a GitHub repository
   * @param {Object} repoInfo Repository information object
   * @returns {Promise<Array>} Array of plugins found in the repository
   */
  const fetchGitHubRepoPlugins = async (repoInfo) => {
    try {
      // Use the specified path if available, otherwise try standard locations
      let pluginsApiUrl;
      let directPlugin = false;
      
      if (repoInfo.path) {
        // If path is provided, use it directly
        pluginsApiUrl = `https://api.github.com/repos/${repoInfo.owner}/${repoInfo.repo}/contents/${repoInfo.path}`;
        directPlugin = true;
      } else {
        // Try to fetch from 'plugins' directory first
        pluginsApiUrl = `https://api.github.com/repos/${repoInfo.owner}/${repoInfo.repo}/contents/plugins`;
        let response = await fetch(pluginsApiUrl);
        
        // If 'plugins' directory doesn't exist, try root directory
        if (!response.ok && response.status === 404) {
          pluginsApiUrl = `https://api.github.com/repos/${repoInfo.owner}/${repoInfo.repo}/contents`;
          directPlugin = false;
        } else {
          directPlugin = false;
        }
      }
      
      const response = await fetch(pluginsApiUrl);
      
      if (!response.ok) {
        throw new Error(`GitHub API error: ${response.statusText}`);
      }
      
      const contents = await response.json();
      
      // If we're looking at a specific plugin path, treat it as a single plugin
      if (directPlugin) {
        // For direct plugin paths, get the plugin name from the last part of the path
        const pluginName = repoInfo.customName || repoInfo.path.split('/').pop();
        
        return [{
          name: pluginName,
          path: repoInfo.path,
          html_url: `https://github.com/${repoInfo.owner}/${repoInfo.repo}/tree/main/${repoInfo.path}`,
          type: 'dir',
          sourceRepo: 'github',
          repoOwner: repoInfo.owner,
          repoName: repoInfo.repo
        }];
      }
      
      // Filter for directories which are potential plugins
      return contents
        .filter(item => item.type === 'dir')
        .map(item => ({
          ...item,
          sourceRepo: 'github',
          repoOwner: repoInfo.owner,
          repoName: repoInfo.repo
        }));
    } catch (error) {
      console.error(`Error fetching plugins from ${repoInfo.owner}/${repoInfo.repo}:`, error);
      return [];
    }
  }
  
  // Add GitHub repo button handlers
  $modal.find('#fetchGithubRepoBtn').on('click', function() {
    const repoUrl = $modal.find('#githubRepoInput').val().trim();
    if (!repoUrl) {
      alert('Please enter a GitHub repository URL.');
      return;
    }
    
    const parsedRepo = parseGitHubUrl(repoUrl);
    if (!parsedRepo) {
      alert('Invalid GitHub repository URL. Please use the format: https://github.com/username/repository or https://github.com/username/repository/tree/branch/path/to/plugin');
      return;
    }
    
    // Show the additional fields
    const $details = $modal.find('#githubPluginDetails');
    $details.removeClass('hidden');
    
    // Pre-fill the path field if it was included in the URL
    if (parsedRepo.path) {
      $modal.find('#githubPluginPath').val(parsedRepo.path);
    }
    
    // Set focus on the path field
    $modal.find('#githubPluginPath').focus();
  });
  
  $modal.find('#addGithubRepoBtn').on('click', function() {
    const repoUrl = $modal.find('#githubRepoInput').val().trim();
    const pluginPath = $modal.find('#githubPluginPath').val().trim();
    const pluginName = $modal.find('#githubPluginName').val().trim();
    
    if (!repoUrl) {
      alert('Please enter a GitHub repository URL.');
      return;
    }
    
    const parsedRepo = parseGitHubUrl(repoUrl);
    if (!parsedRepo) {
      alert('Invalid GitHub repository URL. Please use the format: https://github.com/username/repository');
      return;
    }
    
    // If a custom path was provided, use it
    if (pluginPath) {
      parsedRepo.path = pluginPath;
    }
    
    // If a custom name was provided, use it
    if (pluginName) {
      parsedRepo.customName = pluginName;
    }
    
    const wasAdded = saveGitHubRepo(parsedRepo);
    if (wasAdded) {
      // Clear the inputs
      $modal.find('#githubRepoInput').val('');
      $modal.find('#githubPluginPath').val('');
      $modal.find('#githubPluginName').val('');
      
      // Hide the details section
      $modal.find('#githubPluginDetails').addClass('hidden');
      
      // Refresh the repos list
      renderGitHubRepos();
    } else {
      alert('This repository is already in your list.');
    }
  });

  // Allow pressing Enter to fetch GitHub repo
  $modal.find('#githubRepoInput').on('keypress', function(e) {
    if (e.which === 13) {
      $modal.find('#fetchGithubRepoBtn').click();
    }
  });
  
  // Allow pressing Enter in path field to add repo
  $modal.find('#githubPluginPath, #githubPluginName').on('keypress', function(e) {
    if (e.which === 13) {
      $modal.find('#addGithubRepoBtn').click();
    }
  });

  /**
   * Check if a plugin is installed locally
   * @param {string} pluginName - Name of the plugin to check
   * @returns {boolean} - True if installed
   */
  const isPluginInstalled = (pluginName) => {
    try {
      const pluginPath = path.join(LOCAL_PLUGINS_DIR, pluginName)
      return fs.existsSync(pluginPath)
    } catch (error) {
      console.error('Error checking if plugin is installed:', error)
      return false
    }
  }

  /**
   * Get metadata for a plugin from cache or GitHub
   * @param {Object} plugin - Plugin object from GitHub API
   * @returns {Promise<Object>} - Plugin metadata
   */
  const fetchPluginMetadata = async (plugin) => {
    try {
      const metadataCache = localStorage.getItem(CACHE_METADATA_KEY)
      if (metadataCache) {
        const parsedCache = JSON.parse(metadataCache)
        if (parsedCache[plugin.sourceRepo] && parsedCache[plugin.sourceRepo][plugin.name]) {
          return parsedCache[plugin.sourceRepo][plugin.name]
        }
      }

      // Choose correct repo for plugin.json
      let pluginJsonUrl;
      if (plugin.sourceRepo === 'strawberry-jam') {
        pluginJsonUrl = `https://api.github.com/repos/glvckoma/strawberry-jam/contents/plugins/${plugin.name}/plugin.json`;
      } else {
        // Use the updated base URL for Sxip's plugins
        pluginJsonUrl = `https://api.github.com/repos/Sxip/plugins/contents/${plugin.name}/plugin.json`;
      }
      
      const response = await fetch(pluginJsonUrl)

      if (response.ok) {
        const data = await response.json()
        const content = atob(data.content)
        const metadata = JSON.parse(content)

        if (!metadata.author) {
          metadata.author = plugin.sourceRepo === 'strawberry-jam' ? 'Strawberry Jam' : 'Sxip'
        }

        cachePluginMetadata(plugin.sourceRepo, plugin.name, metadata)
        return metadata
      }
      
      // If we get a 404, return default metadata without logging an error
      if (response.status === 404) {
        const defaultMetadata = {
          name: plugin.name,
          description: plugin.sourceRepo === 'strawberry-jam' ? 'A plugin for Strawberry Jam' : 'A plugin for Jam',
          author: plugin.sourceRepo === 'strawberry-jam' ? 'Strawberry Jam' : 'Sxip'
        };
        
        // Cache the default metadata to avoid repeated 404s
        cachePluginMetadata(plugin.sourceRepo, plugin.name, defaultMetadata);
        return defaultMetadata;
      }

      // For other error codes, throw an error
      throw new Error(`Failed to fetch plugin metadata: ${response.status} ${response.statusText}`);
      
    } catch (error) {
      // Return default metadata for any errors
      return {
        name: plugin.name,
        description: plugin.sourceRepo === 'strawberry-jam' ? 'A plugin for Strawberry Jam' : 'A plugin for Jam',
        author: plugin.sourceRepo === 'strawberry-jam' ? 'Strawberry Jam' : 'Sxip'
      }
    }
  }

  /**
   * Cache a plugin's metadata
   * @param {string} sourceRepo - Source repo
   * @param {string} pluginName - Name of the plugin
   * @param {Object} metadata - Plugin metadata to cache
   */
  const cachePluginMetadata = (sourceRepo, pluginName, metadata) => {
    try {
      const existingCache = localStorage.getItem(CACHE_METADATA_KEY) || '{}'
      const cacheData = JSON.parse(existingCache)
      if (!cacheData[sourceRepo]) cacheData[sourceRepo] = {};
      cacheData[sourceRepo][pluginName] = metadata
      localStorage.setItem(CACHE_METADATA_KEY, JSON.stringify(cacheData))
    } catch (error) {
      console.error('Error caching plugin metadata:', error)
    }
  }

  /**
   * Uninstall a plugin by removing its directory
   * @param {string} pluginName - Name of the plugin to uninstall
   */
  // Prevent multiple simultaneous uninstalls
  let uninstallInProgress = false;
  const uninstallPlugin = async (pluginName) => {
    if (uninstallInProgress) return;
    uninstallInProgress = true;
    try {
      // Disable all uninstall buttons during operation
      $modal.find('.uninstall-plugin-btn').prop('disabled', true).addClass('opacity-50');
      app.consoleMessage({
        message: `Uninstalling plugin: ${pluginName}...`,
        type: 'wait'
      })

      const pluginDir = path.join(LOCAL_PLUGINS_DIR, pluginName)

      if (!fs.existsSync(pluginDir)) {
        throw new Error(`Plugin "${pluginName}" is not installed`)
      }

      const deleteDirectory = (dirPath) => {
        if (fs.existsSync(dirPath)) {
          try {
            fs.readdirSync(dirPath).forEach((file) => {
              const curPath = path.join(dirPath, file)
              try {
                if (fs.lstatSync(curPath).isDirectory()) {
                  deleteDirectory(curPath)
                } else {
                  fs.unlinkSync(curPath)
                }
              } catch (error) {
                console.warn(`Error removing file/directory ${curPath}: ${error.message}`);
              }
            })
            fs.rmdirSync(dirPath)
          } catch (error) {
            console.warn(`Error cleaning directory ${dirPath}: ${error.message}`);
            // If we can't cleanly remove everything, try force removing the directory
            try {
              fs.rmdirSync(dirPath, { recursive: true, force: true });
            } catch (finalError) {
              throw new Error(`Could not remove plugin directory: ${finalError.message}`);
            }
          }
        }
      }

      deleteDirectory(pluginDir)

      app.consoleMessage({
        message: `Plugin "${pluginName}" has been successfully uninstalled.`,
        type: 'success'
      })

      if (typeof app.dispatch.loadPlugins === 'function') {
        app.dispatch.loadPlugins()
      }

      // Refresh the current tab
      if (activeTab === 'store') {
        await fetchPlugins(true);
      } else if (activeTab === 'installed') {
        fetchInstalledPlugins();
      } else if (activeTab === 'github') {
        renderGitHubRepos();
      }
      
    } catch (error) {
      app.consoleMessage({
        message: `Failed to uninstall plugin "${pluginName}": ${error.message}`,
        type: 'error'
      })
    } finally {
      $modal.find('.uninstall-plugin-btn').prop('disabled', false).removeClass('opacity-50');
      uninstallInProgress = false;
    }
  }

  /**
   * Install a plugin from GitHub
   * @param {Object} plugin - Plugin object from GitHub API
   */
  // Prevent multiple simultaneous installs
  let installInProgress = false;
  const installPlugin = async (plugin) => {
    if (installInProgress) return;
    installInProgress = true;
    try {
      // Disable all install buttons during operation
      $modal.find('.install-plugin-btn').prop('disabled', true).addClass('opacity-50');
      app.consoleMessage({
        message: `Installing plugin: ${plugin.name}...`,
        type: 'wait'
      })

      const pluginDir = path.join(LOCAL_PLUGINS_DIR, plugin.name)
      if (!fs.existsSync(pluginDir)) {
        fs.mkdirSync(pluginDir, { recursive: true })
      }

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

      for (const file of contents) {
        if (file.type === 'file') {
          const fileResponse = await fetch(file.download_url)

          if (!fileResponse.ok) {
            throw new Error(`Failed to download ${file.name}: ${fileResponse.statusText}`)
          }

          const fileContent = await fileResponse.text()
          fs.writeFileSync(path.join(pluginDir, file.name), fileContent)
        }
      }
      
      // Create a source marker file
      if (plugin.sourceRepo === 'strawberry-jam') {
        fs.writeFileSync(path.join(pluginDir, '.sj-source'), '');
      } else if (plugin.sourceRepo === 'original-jam') {
        fs.writeFileSync(path.join(pluginDir, '.jam-source'), '');
      }

      if (activeTab === 'store') {
        app.modals.close();
      }
      
      app.consoleMessage({
        message: `Plugin "${plugin.name}" has been successfully installed.`,
        type: 'success'
      })

      if (typeof app.dispatch.loadPlugins === 'function') {
        app.dispatch.loadPlugins()
      }
      
      // Refresh the current tab if we're staying in the modal
      if (activeTab === 'installed') {
        fetchInstalledPlugins();
      }
      
    } catch (error) {
      app.consoleMessage({
        message: `Failed to install plugin "${plugin.name}": ${error.message}`,
        type: 'error'
      })
    } finally {
      $modal.find('.install-plugin-btn').prop('disabled', false).removeClass('opacity-50');
      installInProgress = false;
    }
  }

  /**
   * Fetch plugins list from cache or GitHub
   * @param {boolean} forceRefresh - Force refresh ignoring cache
   */
  const fetchPlugins = async (forceRefresh = false) => {
    const $pluginsList = $modal.find('#pluginsList')

    try {
      if (!forceRefresh) {
        const cachedData = localStorage.getItem(CACHE_KEY)
        const cacheTime = localStorage.getItem(CACHE_TIME_KEY)
        const cacheAge = cacheTime ? Date.now() - parseInt(cacheTime) : Infinity

        if (cachedData && cacheAge < CACHE_DURATION) {
          const plugins = JSON.parse(cachedData)
          await displayPlugins(plugins)
          return
        }
      }

      $pluginsList.html(`
        <div class="col-span-full flex justify-center items-center h-32">
          <i class="fas fa-circle-notch fa-spin text-gray-400 mr-2"></i>
          <span class="text-gray-400">Loading plugins...</span>
        </div>
      `)

      // Fetch from both repos
      let allPlugins = [];
      for (const repoInfo of GITHUB_API_URLS) {
        const response = await fetch(repoInfo.url);
        if (response.status === 403) {
          const rateLimitRemaining = response.headers.get('X-RateLimit-Remaining')
          if (rateLimitRemaining === '0') {
            const resetTime = response.headers.get('X-RateLimit-Reset')
            const resetDate = new Date(resetTime * 1000)
            $pluginsList.html(`
              <div class="col-span-full text-center text-error-red p-4">
                <i class="fas fa-exclamation-circle mr-2"></i>
                GitHub rate limit exceeded. Try again after ${resetDate.toLocaleTimeString()}.
              </div>
            `)
            return
          }
        }
        if (!response.ok) {
          throw new Error(`GitHub API error: ${response.statusText}`)
        }
        const plugins = await response.json();
        for (const plugin of plugins) {
          if (plugin.type === 'dir') {
            allPlugins.push({
              ...plugin,
              sourceRepo: repoInfo.repo
            });
          }
        }
      }

      // Merge plugins, prioritizing strawberry-jam by name
      const pluginMap = new Map();
      for (const plugin of allPlugins) {
        if (!pluginMap.has(plugin.name) || plugin.sourceRepo === 'strawberry-jam') {
          pluginMap.set(plugin.name, plugin);
        }
      }
      const mergedPlugins = Array.from(pluginMap.values());

      localStorage.setItem(CACHE_KEY, JSON.stringify(mergedPlugins))
      localStorage.setItem(CACHE_TIME_KEY, Date.now().toString())
      await displayPlugins(mergedPlugins)
    } catch (error) {
      $pluginsList.html(`
        <div class="col-span-full text-center text-error-red p-4">
          <i class="fas fa-exclamation-circle mr-2"></i>
          Error fetching plugins: ${error.message}
        </div>
      `)
    }
  }

  /**
   * Display plugins in the UI
   * @param {Array} plugins - List of plugins from GitHub API
   */
  const displayPlugins = async (plugins) => {
    const $pluginsList = $modal.find('#pluginsList')
    $pluginsList.empty()

    if (!plugins || plugins.length === 0) {
      $pluginsList.html('<div class="col-span-full text-center text-gray-400">No plugins found</div>')
      return
    }

    const pluginPromises = plugins
      .filter(plugin => plugin.type === 'dir')
      .map(async plugin => {
        const installed = isPluginInstalled(plugin.name)
        const metadata = await fetchPluginMetadata(plugin)

        return {
          plugin,
          installed,
          metadata
        }
      })

    try {
      const pluginData = await Promise.all(pluginPromises)

      pluginData.forEach(({ plugin, installed, metadata }) => {
        // Icon and badge logic
        let iconHtml, badgeHtml, warningHtml;
        if (plugin.sourceRepo === 'strawberry-jam') {
          iconHtml = `<img src="app://assets/images/strawberry.png" alt="Strawberry Jam" class="w-6 h-6 mr-2" style="display:inline-block;vertical-align:middle;">`;
          // Reduced padding px-1.5 py-0.5
          badgeHtml = `<span class="ml-2 px-1.5 py-0.5 text-xs rounded-full bg-highlight-green/20 text-highlight-green">Strawberry Jam</span>`;
          warningHtml = '';
        } else {
          iconHtml = `<img src="app://assets/images/jam.png" alt="Original Jam" class="w-6 h-6 mr-2" style="display:inline-block;vertical-align:middle;">`;
          // Reduced padding px-1.5 py-0.5
          badgeHtml = `<span class="ml-2 px-1.5 py-0.5 text-xs rounded-full bg-gray-500/20 text-gray-400">Original Jam <i class="fas fa-exclamation-triangle text-error-red ml-1"></i></span>`;
          warningHtml = `<div class="mt-2 text-xs text-error-red flex items-center"><i class="fas fa-exclamation-circle mr-1"></i>May not be fully compatible with Strawberry Jam</div>`;
        }

        // Add Beta tag if present in metadata
        // Reduced padding px-1.5 py-0.5
        const betaTagHtml = metadata.tags && metadata.tags.includes('beta')
          ? `<span class="ml-2 px-1.5 py-0.5 text-xs rounded-full bg-blue-500/20 text-blue-400">Beta</span>`
          : '';

        $pluginsList.append(`
          <div class="bg-tertiary-bg/30 rounded-lg p-4 border border-sidebar-border hover:border-highlight-green transition-colors" data-plugin-name="${plugin.name.toLowerCase()}">
            <div class="flex justify-between items-start mb-3">
              <div>
                <div class="flex items-center">
                  ${iconHtml}
                  <h4 class="text-text-primary font-medium text-sm">${metadata.name || plugin.name}</h4>
                  ${metadata.version ? `<span class="ml-2 text-xs text-gray-400">v${metadata.version}</span>` : ''}
                  ${badgeHtml}
                  ${betaTagHtml}
                </div>
                <div class="mt-1 text-xs text-gray-400">
                  <i class="fas fa-user mr-1"></i> ${metadata.author}
                </div>
              </div>
              <div>
                <span class="px-1.5 py-0.5 text-xs rounded-full ${installed ? 'bg-highlight-green/20 text-highlight-green' : 'bg-error-red/20 text-error-red'}">
                  ${installed ? 'Installed' : 'Not Installed'}
                </span>
              </div>
            </div>
            
            <div class="mt-3 mb-4">
              <p class="text-gray-400 text-sm">
                ${metadata.description || (plugin.sourceRepo === 'strawberry-jam' ? 'A plugin for Strawberry Jam' : 'A plugin for Jam')}
              </p>
              ${warningHtml}
            </div>
            
            <div class="flex justify-end items-center mt-4 pt-2 border-t border-sidebar-border/30">
              <div class="flex gap-2">
                <button type="button" data-repo-url="${plugin.html_url}" class="view-repo-btn text-xs text-gray-400 hover:text-highlight-green transition px-2 py-1 rounded">
                  <i class="fab fa-github mr-1"></i> View Repository
                </button>
                
                ${!installed
                  ? `<button data-plugin="${encodeURIComponent(JSON.stringify(plugin))}" class="install-plugin-btn px-3 py-1 text-xs bg-highlight-green/20 text-highlight-green rounded hover:bg-highlight-green/30 transition">
                    <i class="fas fa-download mr-1"></i> Install
                  </button>`
                  : `<button data-plugin-name="${plugin.name}" class="uninstall-plugin-btn px-3 py-1 text-xs bg-error-red/20 text-error-red rounded hover:bg-error-red/30 transition">
                    <i class="fas fa-trash-alt mr-1"></i> Uninstall
                  </button>`
                }
              </div>
            </div>
          </div>
        `)
      })

      $pluginsList.find('.install-plugin-btn').on('click', function () {
        const plugin = JSON.parse(decodeURIComponent($(this).data('plugin')))
        installPlugin(plugin)
      })

      $pluginsList.find('.uninstall-plugin-btn').on('click', function () {
        const pluginName = $(this).data('plugin-name')

        if (confirm(`Are you sure you want to uninstall the "${pluginName}" plugin?`)) {
          uninstallPlugin(pluginName)
        }
      })

      $pluginsList.find('.view-repo-btn').on('click', function () {
        const repoUrl = $(this).data('repo-url')
        app.open(repoUrl)
      })
    } catch (error) {
      console.error('Error displaying plugins:', error)
      $pluginsList.html(`
        <div class="col-span-full text-center text-error-red p-4">
          <i class="fas fa-exclamation-circle mr-2"></i>
          Error loading plugin details: ${error.message}
        </div>
      `)
    }

    // Add search functionality for store plugins
    $modal.find('#pluginSearch').on('input', function () {
      if (activeTab !== 'store') return;
      
      const searchTerm = $(this).val().toLowerCase()

      $pluginsList.find('[data-plugin-name]').each(function () {
        const pluginName = $(this).data('plugin-name')
        if (pluginName.includes(searchTerm)) {
          $(this).show()
        } else {
          $(this).hide()
        }
      })
    })
  }

  // Initial load depending on the active tab
  if (activeTab === 'store') {
    fetchPlugins();
  } else if (activeTab === 'installed') {
    fetchInstalledPlugins();
  } else if (activeTab === 'github') {
    renderGitHubRepos();
  }
  
  // Add fade-in animation
  $modal.css({
    'opacity': '0',
    'transform': 'scale(0.95)'
  });

  setTimeout(() => {
    $modal.css({
      'opacity': '1',
      'transform': 'scale(1)',
      'transition': 'opacity 0.2s ease-out, transform 0.2s ease-out'
    });
  }, 10);
  
  /**
   * Install a plugin from a GitHub repository
   * @param {Object} plugin Plugin object from GitHub repository
   */
  const installGitHubPlugin = async (plugin) => {
    if (installInProgress) return;
    installInProgress = true;
    try {
      // Disable all install buttons during operation
      $modal.find('.install-github-plugin-btn').prop('disabled', true).addClass('opacity-50');
      app.consoleMessage({
        message: `Installing plugin from GitHub: ${plugin.name}...`,
        type: 'wait'
      });

      const pluginDir = path.join(LOCAL_PLUGINS_DIR, plugin.name);
      if (!fs.existsSync(pluginDir)) {
        fs.mkdirSync(pluginDir, { recursive: true });
      }

      // Get the contents of the plugin directory
      const contentsUrl = `https://api.github.com/repos/${plugin.repoOwner}/${plugin.repoName}/contents/${plugin.path}`;
      const response = await fetch(contentsUrl);

      if (!response.ok) {
        throw new Error(`Failed to fetch plugin contents: ${response.statusText}`);
      }

      const contents = await response.json();

      // Process based on whether contents is an array or single file
      const filesArray = Array.isArray(contents) ? contents : [contents];
      
      for (const file of filesArray) {
        if (file.type === 'file') {
          const fileResponse = await fetch(file.download_url);
          
          if (!fileResponse.ok) {
            throw new Error(`Failed to download ${file.name}: ${fileResponse.statusText}`);
          }

          const fileContent = await fileResponse.text();
          fs.writeFileSync(path.join(pluginDir, file.name), fileContent);
        } else if (file.type === 'dir') {
          // Create the subdirectory
          const subDir = path.join(pluginDir, file.name);
          if (!fs.existsSync(subDir)) {
            fs.mkdirSync(subDir, { recursive: true });
          }
          
          // Fetch and save the subdirectory contents
          const subContentsUrl = file.url;
          const subResponse = await fetch(subContentsUrl);
          
          if (subResponse.ok) {
            const subContents = await subResponse.json();
            
            for (const subFile of subContents) {
              if (subFile.type === 'file') {
                const subFileResponse = await fetch(subFile.download_url);
                
                if (subFileResponse.ok) {
                  const subFileContent = await subFileResponse.text();
                  fs.writeFileSync(path.join(subDir, subFile.name), subFileContent);
                }
              }
            }
          }
        }
      }
      
      // Create a source marker file for GitHub-sourced plugins
      fs.writeFileSync(path.join(pluginDir, '.github-source'), '');

      app.consoleMessage({
        message: `Plugin "${plugin.name}" has been successfully installed.`,
        type: 'success'
      });

      if (typeof app.dispatch.loadPlugins === 'function') {
        app.dispatch.loadPlugins();
      }
      
      // Refresh the current tab
      if (activeTab === 'github') {
        renderGitHubRepos();
      } else if (activeTab === 'installed') {
        fetchInstalledPlugins();
      }
      
    } catch (error) {
      app.consoleMessage({
        message: `Failed to install plugin "${plugin.name}" from GitHub: ${error.message}`,
        type: 'error'
      });
    } finally {
      $modal.find('.install-github-plugin-btn').prop('disabled', false).removeClass('opacity-50');
      installInProgress = false;
    }
  }
  
  /**
   * Display GitHub plugins in the UI
   * @param {Array} plugins List of plugin objects from GitHub repositories
   */
  const displayGitHubPlugins = async (plugins) => {
    const $pluginsList = $modal.find('#githubPluginsList');
    $pluginsList.empty();
    
    const pluginPromises = plugins.map(async plugin => {
      const installed = isPluginInstalled(plugin.name);
      
      // Try to fetch plugin.json for metadata
      let metadata = {
        name: plugin.name,
        description: `A plugin from ${plugin.repoOwner}/${plugin.repoName}`,
        author: plugin.repoOwner
      };
      
      try {
        const metadataUrl = `https://api.github.com/repos/${plugin.repoOwner}/${plugin.repoName}/contents/${plugin.path}/plugin.json`;
        const response = await fetch(metadataUrl);
        
        if (response.ok) {
          const data = await response.json();
          const content = atob(data.content);
          const parsedMetadata = JSON.parse(content);
          
          if (parsedMetadata.name) metadata.name = parsedMetadata.name;
          if (parsedMetadata.description) metadata.description = parsedMetadata.description;
          if (parsedMetadata.author) metadata.author = parsedMetadata.author;
          if (parsedMetadata.version) metadata.version = parsedMetadata.version;
          if (parsedMetadata.tags) metadata.tags = parsedMetadata.tags;
        }
        // If status is 404, we already have default metadata
        // Non-404 errors will be handled by the catch block
        else if (response.status !== 404) {
          console.warn(`Error fetching metadata for ${plugin.name}: ${response.status} ${response.statusText}`);
        }
      } catch (error) {
        // Don't log expected errors, already using default metadata
        if (!error.message.includes('404')) {
          console.warn(`Error parsing metadata for ${plugin.name}: ${error.message}`);
        }
      }
      
      return {
        plugin,
        installed,
        metadata
      };
    });
    
    try {
      const pluginData = await Promise.all(pluginPromises);
      
      pluginData.forEach(({ plugin, installed, metadata }) => {
        // Add Beta tag if present in metadata
        const betaTagHtml = metadata.tags && metadata.tags.includes('beta')
          ? `<span class="ml-2 px-1.5 py-0.5 text-xs rounded-full bg-blue-500/20 text-blue-400">Beta</span>`
          : '';
          
        $pluginsList.append(`
          <div class="bg-tertiary-bg/30 rounded-lg p-4 border border-sidebar-border hover:border-highlight-green transition-colors">
            <div class="flex justify-between items-start mb-3">
              <div>
                <div class="flex items-center">
                  <i class="fab fa-github text-gray-400 mr-2"></i>
                  <h4 class="text-text-primary font-medium text-sm">${metadata.name}</h4>
                  ${metadata.version ? `<span class="ml-2 text-xs text-gray-400">v${metadata.version}</span>` : ''}
                  <span class="ml-2 px-1.5 py-0.5 text-xs rounded-full bg-gray-500/20 text-gray-400">GitHub</span>
                  ${betaTagHtml}
                </div>
                <div class="mt-1 text-xs text-gray-400">
                  <i class="fas fa-user mr-1"></i> ${metadata.author}
                </div>
                <div class="mt-1 text-xs text-gray-400">
                  <i class="fas fa-code-branch mr-1"></i> ${plugin.repoOwner}/${plugin.repoName}
                </div>
              </div>
              <div>
                <span class="px-1.5 py-0.5 text-xs rounded-full ${installed ? 'bg-highlight-green/20 text-highlight-green' : 'bg-error-red/20 text-error-red'}">
                  ${installed ? 'Installed' : 'Not Installed'}
                </span>
              </div>
            </div>
            
            <div class="mt-3 mb-4">
              <p class="text-gray-400 text-sm">${metadata.description}</p>
            </div>
            
            <div class="flex justify-end items-center mt-4 pt-2 border-t border-sidebar-border/30">
              <div class="flex gap-2">
                <button type="button" data-repo-url="https://github.com/${plugin.repoOwner}/${plugin.repoName}/tree/main/${plugin.path}" 
                        class="view-repo-btn text-xs text-gray-400 hover:text-highlight-green transition px-2 py-1 rounded">
                  <i class="fab fa-github mr-1"></i> View Repository
                </button>
                
                ${!installed
                  ? `<button data-plugin="${encodeURIComponent(JSON.stringify(plugin))}" class="install-github-plugin-btn px-3 py-1 text-xs bg-highlight-green/20 text-highlight-green rounded hover:bg-highlight-green/30 transition">
                    <i class="fas fa-download mr-1"></i> Install
                  </button>`
                  : `<button data-plugin-name="${plugin.name}" class="uninstall-plugin-btn px-3 py-1 text-xs bg-error-red/20 text-error-red rounded hover:bg-error-red/30 transition">
                    <i class="fas fa-trash-alt mr-1"></i> Uninstall
                  </button>`
                }
              </div>
            </div>
          </div>
        `);
      });
      
      $pluginsList.find('.view-repo-btn').on('click', function() {
        const repoUrl = $(this).data('repo-url');
        app.open(repoUrl);
      });
      
      $pluginsList.find('.install-github-plugin-btn').on('click', function() {
        const plugin = JSON.parse(decodeURIComponent($(this).data('plugin')));
        installGitHubPlugin(plugin);
      });
      
      $pluginsList.find('.uninstall-plugin-btn').on('click', function() {
        const pluginName = $(this).data('plugin-name');
        if (confirm(`Are you sure you want to uninstall the "${pluginName}" plugin?`)) {
          uninstallPlugin(pluginName);
          // Refresh GitHub tab after uninstall
          setTimeout(() => renderGitHubRepos(), 500);
        }
      });
      
    } catch (error) {
      console.error('Error displaying GitHub plugins:', error);
      $pluginsList.html(`
        <div class="col-span-full text-center text-error-red p-4">
          <i class="fas fa-exclamation-circle mr-2"></i>
          Error loading plugin details: ${error.message}
        </div>
      `);
    }
  }
  
  /**
   * Render the list of saved GitHub repositories
   */
  const renderGitHubRepos = async () => {
    const $reposList = $modal.find('#githubReposList');
    const $pluginsList = $modal.find('#githubPluginsList');
    
    // Clear existing content
    $reposList.empty();
    $pluginsList.empty();
    
    const savedRepos = getSavedGitHubRepos();
    
    if (savedRepos.length === 0) {
      $reposList.html(`
        <div class="bg-tertiary-bg/30 rounded-lg p-4 text-center">
          <p class="text-gray-400">No GitHub repositories added yet.</p>
          <p class="text-xs text-gray-400 mt-2">Add a repository URL above to get started.</p>
        </div>
      `);
      return;
    }
    
    // Show loading indicator
    $pluginsList.html(`
      <div class="col-span-full flex justify-center items-center h-32">
        <i class="fas fa-circle-notch fa-spin text-gray-400 mr-2"></i>
        <span class="text-gray-400">Loading plugins from GitHub...</span>
      </div>
    `);
    
    // Display saved repositories
    for (const repo of savedRepos) {
      $reposList.append(`
        <div class="bg-tertiary-bg/30 rounded-lg p-3 flex justify-between items-center">
          <div class="flex items-center">
            <i class="fab fa-github text-gray-400 mr-2"></i>
            <span class="text-text-primary">${repo.owner}/${repo.repo}</span>
          </div>
          <div class="flex gap-2">
            <button class="text-xs text-gray-400 hover:text-highlight-green transition px-2 py-1 rounded view-github-repo-btn" 
                    data-repo-url="${repo.url}">
              <i class="fas fa-external-link-alt"></i>
            </button>
            <button class="text-xs text-error-red hover:text-error-red/80 transition px-2 py-1 rounded remove-github-repo-btn" 
                    data-repo-url="${repo.url}">
              <i class="fas fa-trash-alt"></i>
            </button>
          </div>
        </div>
      `);
    }
    
    // Handle repository button clicks
    $reposList.find('.view-github-repo-btn').on('click', function() {
      const repoUrl = $(this).data('repo-url');
      app.open(repoUrl);
    });
    
    $reposList.find('.remove-github-repo-btn').on('click', function() {
      const repoUrl = $(this).data('repo-url');
      if (confirm('Are you sure you want to remove this GitHub repository?')) {
        removeGitHubRepo(repoUrl);
        renderGitHubRepos();
      }
    });
    
    // Fetch and display plugins from all repositories
    let allPlugins = [];
    for (const repo of savedRepos) {
      const plugins = await fetchGitHubRepoPlugins(repo);
      allPlugins = allPlugins.concat(plugins);
    }
    
    // Display plugins
    if (allPlugins.length === 0) {
      $pluginsList.html(`
        <div class="col-span-full text-center text-gray-400">
          No plugins found in the added GitHub repositories.
        </div>
      `);
      return;
    }
    
    await displayGitHubPlugins(allPlugins);
  }

  /**
   * Fetch and display installed plugins
   */
  const fetchInstalledPlugins = async () => {
    const $pluginsList = $modal.find('#installedPluginsList');
    
    $pluginsList.html(`
      <div class="col-span-full flex justify-center items-center h-32">
        <i class="fas fa-circle-notch fa-spin text-gray-400 mr-2"></i>
        <span class="text-gray-400">Loading installed plugins...</span>
      </div>
    `);
    
    try {
      // Read the plugins directory
      const pluginsDir = LOCAL_PLUGINS_DIR;
      
      if (!fs.existsSync(pluginsDir)) {
        $pluginsList.html(`
          <div class="col-span-full text-center text-gray-400">
            Plugins directory not found.
          </div>
        `);
        return;
      }
      
      const pluginFolders = fs.readdirSync(pluginsDir, { withFileTypes: true })
        .filter(dirent => dirent.isDirectory())
        .map(dirent => dirent.name);
      
      if (pluginFolders.length === 0) {
        $pluginsList.html(`
          <div class="col-span-full text-center text-gray-400">
            <p>No plugins installed.</p>
            <p class="text-xs mt-2">Go to the Store or GitHub tab to install plugins.</p>
          </div>
        `);
        return;
      }
      
      $pluginsList.empty();
      
      for (const pluginName of pluginFolders) {
        // Try to read plugin.json for metadata
        const pluginJsonPath = path.join(pluginsDir, pluginName, 'plugin.json');
        let metadata = {
          name: pluginName,
          description: 'A plugin for Strawberry Jam',
          author: 'Unknown',
          version: '',
          tags: []
        };
        
        if (fs.existsSync(pluginJsonPath)) {
          try {
            const fileContent = fs.readFileSync(pluginJsonPath, 'utf8');
            const parsedMetadata = JSON.parse(fileContent);
            
            if (parsedMetadata.name) metadata.name = parsedMetadata.name;
            if (parsedMetadata.description) metadata.description = parsedMetadata.description;
            if (parsedMetadata.author) metadata.author = parsedMetadata.author;
            if (parsedMetadata.version) metadata.version = parsedMetadata.version;
            if (parsedMetadata.tags) metadata.tags = parsedMetadata.tags;
          } catch (error) {
            console.error(`Error reading metadata for ${pluginName}:`, error);
          }
        }
        
        // Check for plugin source indicator files
        let sourceType = 'unknown';
        let iconHtml = '';
        let badgeHtml = '';
        
        // Check for plugin icon files or source indicator
        const pluginFiles = fs.readdirSync(path.join(pluginsDir, pluginName));
        
        // Check for icon
        let iconPath = '';
        if (pluginFiles.includes('icon.png')) {
          iconPath = `plugins/${pluginName}/icon.png`;
        }
        
        // Determine source
        if (pluginFiles.includes('.github-source')) {
          sourceType = 'github';
          iconHtml = iconPath ? 
            `<img src="${iconPath}" alt="${metadata.name}" class="w-6 h-6 mr-2" style="display:inline-block;vertical-align:middle;">` : 
            `<i class="fab fa-github text-gray-400 mr-2"></i>`;
          badgeHtml = `<span class="ml-2 px-1.5 py-0.5 text-xs rounded-full bg-gray-500/20 text-gray-400">GitHub</span>`;
        } else if (pluginFiles.includes('.sj-source')) {
          sourceType = 'strawberry-jam';
          iconHtml = iconPath ? 
            `<img src="${iconPath}" alt="${metadata.name}" class="w-6 h-6 mr-2" style="display:inline-block;vertical-align:middle;">` : 
            `<img src="app://assets/images/strawberry.png" alt="Strawberry Jam" class="w-6 h-6 mr-2" style="display:inline-block;vertical-align:middle;">`;
          badgeHtml = `<span class="ml-2 px-1.5 py-0.5 text-xs rounded-full bg-highlight-green/20 text-highlight-green">Strawberry Jam</span>`;
        } else if (pluginFiles.includes('.jam-source')) {
          sourceType = 'original-jam';
          iconHtml = iconPath ? 
            `<img src="${iconPath}" alt="${metadata.name}" class="w-6 h-6 mr-2" style="display:inline-block;vertical-align:middle;">` : 
            `<img src="app://assets/images/jam.png" alt="Original Jam" class="w-6 h-6 mr-2" style="display:inline-block;vertical-align:middle;">`;
          badgeHtml = `<span class="ml-2 px-1.5 py-0.5 text-xs rounded-full bg-gray-500/20 text-gray-400">Original Jam <i class="fas fa-exclamation-triangle text-error-red ml-1"></i></span>`;
        } else {
          // Unknown source
          iconHtml = iconPath ? 
            `<img src="${iconPath}" alt="${metadata.name}" class="w-6 h-6 mr-2" style="display:inline-block;vertical-align:middle;">` : 
            `<i class="fas fa-puzzle-piece text-gray-400 mr-2"></i>`;
          badgeHtml = `<span class="ml-2 px-1.5 py-0.5 text-xs rounded-full bg-gray-500/20 text-gray-400">Unknown</span>`;
        }
        
        // Add Beta tag if present in metadata
        const betaTagHtml = metadata.tags && metadata.tags.includes('beta')
          ? `<span class="ml-2 px-1.5 py-0.5 text-xs rounded-full bg-blue-500/20 text-blue-400">Beta</span>`
          : '';
          
        // Show warning for original jam plugins
        const warningHtml = sourceType === 'original-jam' 
          ? `<div class="mt-2 text-xs text-error-red flex items-center"><i class="fas fa-exclamation-circle mr-1"></i>May not be fully compatible with Strawberry Jam</div>` 
          : '';
        
        $pluginsList.append(`
          <div class="bg-tertiary-bg/30 rounded-lg p-4 border border-sidebar-border hover:border-highlight-green transition-colors" data-plugin-name="${pluginName.toLowerCase()}">
            <div class="flex justify-between items-start mb-3">
              <div>
                <div class="flex items-center">
                  ${iconHtml}
                  <h4 class="text-text-primary font-medium text-sm">${metadata.name}</h4>
                  ${metadata.version ? `<span class="ml-2 text-xs text-gray-400">v${metadata.version}</span>` : ''}
                  ${badgeHtml}
                  ${betaTagHtml}
                </div>
                <div class="mt-1 text-xs text-gray-400">
                  <i class="fas fa-user mr-1"></i> ${metadata.author}
                </div>
              </div>
              <!-- Status indicator - could show enabled/disabled status in the future -->
              <div>
                <span class="px-1.5 py-0.5 text-xs rounded-full bg-highlight-green/20 text-highlight-green">
                  Installed
                </span>
              </div>
            </div>
            
            <div class="mt-3 mb-4">
              <p class="text-gray-400 text-sm">${metadata.description}</p>
              ${warningHtml}
            </div>
            
            <div class="flex justify-end items-center mt-4 pt-2 border-t border-sidebar-border/30">
              <div class="flex gap-2">
                <button type="button" data-plugin-dir="${pluginName}" class="open-plugin-folder-btn text-xs text-gray-400 hover:text-highlight-green transition px-2 py-1 rounded">
                  <i class="fas fa-folder-open mr-1"></i> Open Folder
                </button>
                <button data-plugin-name="${pluginName}" class="uninstall-plugin-btn px-3 py-1 text-xs bg-error-red/20 text-error-red rounded hover:bg-error-red/30 transition">
                  <i class="fas fa-trash-alt mr-1"></i> Uninstall
                </button>
              </div>
            </div>
          </div>
        `);
      }
      
      // Add event handlers for installed plugins
      $pluginsList.find('.open-plugin-folder-btn').on('click', function() {
        const pluginDir = $(this).data('plugin-dir');
        const fullPath = path.join(LOCAL_PLUGINS_DIR, pluginDir);
        app.invoke('open-directory', fullPath);
      });
      
      $pluginsList.find('.uninstall-plugin-btn').on('click', function() {
        const pluginName = $(this).data('plugin-name');
        if (confirm(`Are you sure you want to uninstall the "${pluginName}" plugin?`)) {
          uninstallPlugin(pluginName);
          // Refresh the installed plugins list after uninstall
          setTimeout(() => fetchInstalledPlugins(), 500);
        }
      });
      
      // Add search functionality for installed plugins
      $modal.find('#pluginSearch').on('input', function() {
        if (activeTab !== 'installed') return;
        
        const searchTerm = $(this).val().toLowerCase();
        
        $pluginsList.find('[data-plugin-name]').each(function() {
          const pluginName = $(this).data('plugin-name');
          if (pluginName.includes(searchTerm)) {
            $(this).show();
          } else {
            $(this).hide();
          }
        });
      });
      
    } catch (error) {
      console.error('Error fetching installed plugins:', error);
      $pluginsList.html(`
        <div class="col-span-full text-center text-error-red p-4">
          <i class="fas fa-exclamation-circle mr-2"></i>
          Error loading installed plugins: ${error.message}
        </div>
      `);
    }
  }

  return $modal
}
