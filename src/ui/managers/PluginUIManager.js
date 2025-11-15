/**
 * PluginUIManager - Manages plugin UI rendering and status updates
 * 
 * @module PluginUIManager
 */
class PluginUIManager {
  constructor(application) {
    this.application = application
  }

  /**
   * Renders the plugin items within the list
   * @param {Object} plugin - The plugin details
   * @param {string} plugin.name - The name of the plugin
   * @param {string} plugin.type - The type of the plugin ('game' or 'ui')
   * @param {string} plugin.description - The description of the plugin
   * @param {string} [plugin.author='Sxip'] - The author of the plugin
   * @returns {JQuery<HTMLElement>} - The plugin list item
   * @public
   */
  renderItems({ name, type, description, author = 'Sxip' } = {}) {
    let statusColorClass = 'bg-red-500'
    if (type === 'game') {
      statusColorClass = 'bg-yellow-500'
    }

    const $plugin = $(`
      <li class="flex items-center justify-between text-sidebar-text hover:bg-tertiary-bg px-3 py-2 rounded-md transition-all group plugin-list-item" data-plugin-name="${name}" data-plugin-type="${type}">
        <div class="flex items-center flex-grow min-w-0">
          <span class="inline-block w-2 h-2 ${statusColorClass} rounded-full mr-2 flex-shrink-0 plugin-status-indicator"></span>
          <span class="font-medium text-sm truncate mr-2">${name}</span>
        </div>
        <a href="#" 
           class="plugin-info-button text-gray-400 hover:text-theme-primary transition-colors opacity-0 group-hover:opacity-100 ml-auto pl-2 flex-shrink-0" 
           aria-label="Plugin Info">
          <i class="fas fa-info-circle"></i>
        </a>
      </li>
    `)

    $plugin.find('.plugin-info-button').on('click', (e) => {
      e.preventDefault()
      e.stopPropagation()
      this.application.pluginInfoModalManager.show(name)
    })

    if (type === 'ui') {
      $plugin.addClass('cursor-pointer')
      $plugin.on('click', (e) => {
        if (!$(e.target).closest('.plugin-info-button').length) {
          this.application.dispatch.open(name)
        }
      })
    }
    return $plugin
  }

  /**
   * Updates the status indicator for a specific plugin
   * @param {string} pluginName - The name of the plugin
   * @param {boolean} isOpen - Whether the plugin window is open
   * @public
   */
  updatePluginStatusIndicator(pluginName, isOpen) {
    if (!this.application.$pluginList || this.application.$pluginList.length === 0) {
      return
    }
    
    const $listItem = this.application.$pluginList.find(`li[data-plugin-name="${pluginName}"]`)
    if ($listItem.length === 0) {
      return
    }

    const $indicator = $listItem.find('.plugin-status-indicator')
    if ($indicator.length === 0) {
      return
    }

    const pluginType = $listItem.data('plugin-type')
    if (pluginType === 'ui') {
      if (isOpen) {
        $indicator.removeClass('bg-red-500 bg-yellow-500').addClass('bg-green-500')
      } else {
        $indicator.removeClass('bg-green-500 bg-yellow-500').addClass('bg-red-500')
      }
    } else {
      $indicator.removeClass('bg-red-500 bg-green-500').addClass('bg-yellow-500')
    }
  }

  /**
   * Updates the empty plugin message visibility
   * @public
   */
  updateEmptyPluginMessage() {
    const $emptyPluginMessage = $('#emptyPluginMessage')
    if ($emptyPluginMessage.length > 0) {
      const hasPlugins = this.application.$pluginList.children().not(function() {
        return this.nodeType === 3 || $(this).text().trim() === ''
      }).length > 0
      
      $emptyPluginMessage.toggleClass('hidden', hasPlugins)
    }
  }
}

module.exports = PluginUIManager

