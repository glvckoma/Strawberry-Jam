class PluginCard {
  static SOURCE_CONFIG = {
    'strawberry-jam': {
      icon: '<img src="app://assets/images/strawberry.png" alt="SJ" style="width:16px;height:16px;display:inline-block;vertical-align:middle;">',
      badge: 'bg-highlight-green/20 text-highlight-green',
      badgeLabel: 'Strawberry Jam',
      warning: ''
    },
    'github': {
      icon: '<i class="fab fa-github text-gray-400" style="font-size:15px;"></i>',
      badge: 'bg-gray-500/20 text-gray-400',
      badgeLabel: 'GitHub',
      warning: ''
    },
    'unknown': {
      icon: '<i class="fas fa-puzzle-piece text-gray-400" style="font-size:15px;"></i>',
      badge: 'bg-gray-500/20 text-gray-400',
      badgeLabel: 'Unknown',
      warning: ''
    }
  }

  static render({ metadata, installed, source, plugin, isBundled = false, actions = {} }) {
    const sourceConfig = PluginCard.SOURCE_CONFIG[source] || PluginCard.SOURCE_CONFIG['unknown']

    const sourceBadge = sourceConfig.badgeStyle
      ? `<span class="plugin-source-badge" style="${sourceConfig.badgeStyle}">${sourceConfig.badgeLabel}</span>`
      : `<span class="plugin-source-badge ${sourceConfig.badge}">${sourceConfig.badgeLabel}</span>`

    const warningHtml = sourceConfig.warning
      ? `<div class="text-xs mt-1.5 text-error-red flex items-center"><i class="fas fa-exclamation-circle mr-1"></i>${sourceConfig.warning}</div>`
      : ''

    let actionButtons = ''
    if (actions.viewRepo) {
      actionButtons += `<button type="button" data-repo-url="${actions.viewRepo}" class="view-repo-btn plugin-card-btn plugin-card-btn-link"><i class="fab fa-github mr-1"></i>View Repository</button>`
    }
    if (actions.install && !installed) {
      actionButtons += `<button data-plugin="${encodeURIComponent(JSON.stringify(plugin))}" class="${actions.install.className || 'install-plugin-btn'} plugin-card-btn plugin-card-btn-install"><i class="fas fa-download mr-1"></i>Install</button>`
    }
    if (installed && !isBundled && actions.uninstall !== false) {
      actionButtons += `<button data-plugin-name="${metadata.name || (plugin && plugin.name)}" class="uninstall-plugin-btn plugin-card-btn plugin-card-btn-uninstall"><i class="fas fa-trash-alt mr-1"></i>Uninstall</button>`
    }

    const pluginName = plugin ? plugin.name : (metadata.name || 'unknown')
    const description = metadata.description || 'No description available'

    return `
      <div class="plugin-card" data-plugin-name="${pluginName.toLowerCase()}">
        <div class="plugin-card-header">
          <div class="flex items-center gap-1.5 min-w-0 flex-wrap flex-1">
            ${sourceConfig.icon}
            <span class="plugin-card-name">${metadata.name || pluginName}</span>
            <span class="plugin-card-version">v${metadata.version || '1.0.0'}</span>
            ${sourceBadge}
          </div>
        </div>
        <div class="plugin-card-body">
          <div class="plugin-card-author mb-1.5">
            <i class="fas fa-user mr-1" style="font-size:10px;"></i>${metadata.author || 'Unknown'}
          </div>
          <p class="plugin-card-description">${description}</p>
          ${warningHtml}
        </div>
        <div class="plugin-card-footer">
          ${actionButtons}
        </div>
      </div>
    `
  }
}

module.exports = PluginCard
