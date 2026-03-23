const path = require('path')
const { ipcRenderer } = require('electron')
const ToastService = require('../../../../ui/services/ToastService')

exports.name = 'updatesModal'

exports.render = async function (app, data = {}) {
  const { version = null } = data

  let updatesData
  try {
    const dataPath = path.join(__dirname, '../../../../data/updates-data.json')
    const rawData = await ipcRenderer.invoke('read-file', dataPath)
    updatesData = JSON.parse(rawData)
  } catch (error) {
    console.error('Failed to load updates data:', error)
    updatesData = {}
  }

  const targetVersion = version || Object.keys(updatesData).find(v => updatesData[v].isLatest) || Object.keys(updatesData)[0]
  const versionData = updatesData[targetVersion]

  if (!versionData) return null

  const availableVersions = Object.keys(updatesData).sort((a, b) => {
    const aV = a.split('.').map(Number)
    const bV = b.split('.').map(Number)
    for (let i = 0; i < Math.max(aV.length, bV.length); i++) {
      if ((aV[i] || 0) !== (bV[i] || 0)) return (bV[i] || 0) - (aV[i] || 0)
    }
    return 0
  })

  const visibleCategories = Object.entries(versionData.categories)
    .filter(([, items]) => items && items.length > 0)

  const tabsHtml = visibleCategories.map(([key, items], idx) => {
    const info = getTabInfo(key)
    return `
      <button type="button" class="updates-tab modal-tab ${idx === 0 ? 'active' : ''}" data-tab="${key}">
        <span class="mr-1">${info.icon}</span>${info.label}
        <span class="ml-1.5 text-xs bg-tertiary-bg px-1.5 py-0.5 rounded-full text-gray-400">${items.length}</span>
        <span class="tab-underline"></span>
      </button>`
  }).join('')

  const firstCategory = visibleCategories.length > 0 ? visibleCategories[0][0] : 'features'

  const dropdownVersions = availableVersions.slice(0, 5)
  if (!dropdownVersions.includes(targetVersion)) dropdownVersions.push(targetVersion)

  const versionSelectorHtml = availableVersions.length > 1
    ? `<select id="versionSelector" class="modal-input text-sm py-1 px-2 themed-scrollbar" style="width: auto;">
        ${dropdownVersions.map(v => `<option value="${v}" ${v === targetVersion ? 'selected' : ''}>${v}</option>`).join('')}
       </select>`
    : ''

  const $modal = $(`
    <div class="flex items-center justify-center min-h-screen" id="updatesModalOverlay">
      <div class="modal-backdrop"></div>
      <div class="modal-container max-w-3xl w-full mx-4">
        <div class="modal-header">
          <div>
            <h3 class="modal-header-title">
              <i class="fas fa-gift modal-section-icon"></i>
              What's New
            </h3>
            <p class="text-xs text-gray-400 mt-0.5">Version ${versionData.version} ${versionData.releaseDate ? '| ' + versionData.releaseDate : ''}</p>
          </div>
          <div class="flex items-center space-x-2 ml-auto">
            ${versionSelectorHtml}
            <button type="button" class="modal-close-btn" id="closeUpdatesModalHeaderBtn" aria-label="Close">
              <i class="fas fa-times"></i>
            </button>
          </div>
        </div>

        <div class="modal-tab-bar">${tabsHtml}</div>

        <div class="modal-body themed-scrollbar">
          <div id="updatesTabContent">
            ${generateCategoryContent(firstCategory, versionData.categories[firstCategory])}
          </div>
        </div>

        <div class="modal-footer justify-between">
          <div class="text-xs text-gray-400 flex items-center">
            <i class="fas fa-info-circle mr-1.5"></i>
            Access via Settings > Application Updates > View Updates
          </div>
          <button id="markAsRead" class="modal-btn-primary text-sm">
            <i class="fas fa-check mr-1.5"></i>Mark as Read
          </button>
        </div>
      </div>
    </div>
  `)

  let activeTab = firstCategory

  function switchTab(tabName) {
    activeTab = tabName
    $modal.find('.updates-tab').removeClass('active')
    $modal.find(`[data-tab="${tabName}"]`).addClass('active')

    const $content = $modal.find('#updatesTabContent')
    $content.css({ opacity: 0, transition: 'opacity 0.15s ease-out' })

    setTimeout(() => {
      $content.html(generateCategoryContent(tabName, versionData.categories[tabName]))
      $content.css({ opacity: 1, transition: 'opacity 0.2s ease-in' })

      $content.find('.update-item').each(function (index) {
        const $item = $(this)
        $item.css({ opacity: 0, transform: 'translateY(8px)', transition: 'opacity 0.25s ease-out, transform 0.25s ease-out' })
        setTimeout(() => {
          $item.css({ opacity: 1, transform: 'translateY(0)' })
        }, index * 50)
      })
    }, 150)
  }

  $modal.find('.updates-tab').on('click', function () {
    switchTab($(this).data('tab'))
  })

  $modal.find('#versionSelector').on('change', function () {
    app.modals.show('updatesModal', '#modalContainer', { version: $(this).val() })
  })

  const closeModal = () => {
    $modal.find('.modal-container').addClass('modal-exit')
    $modal.find('.modal-backdrop').css({ opacity: 0, transition: 'opacity 0.15s ease-out' })
    setTimeout(() => app.modals.close(), 150)
  }

  $modal.find('#closeUpdatesModalHeaderBtn').on('click', closeModal)
  $modal.find('.modal-backdrop').on('click', closeModal)

  $modal.find('#markAsRead').on('click', async function () {
    try {
      await ipcRenderer.invoke('set-setting', 'lastSeenVersion', targetVersion)
      ToastService.showInModal($modal, 'Updates marked as read!', 'success', 3000, true)
      setTimeout(closeModal, 1500)
    } catch (error) {
      console.error('Failed to mark as read:', error)
      ToastService.showInModal($modal, 'Failed to mark as read', 'error', 3000, true)
    }
  })

  $modal.find('.update-item').css({ opacity: 0, transform: 'translateY(8px)' })

  $(document).one('modal:opened', function (e, data) {
    if (data.name !== 'updatesModal') return
    requestAnimationFrame(() => {
      $modal.find('.update-item').each(function (index) {
        const $item = $(this)
        $item.css({ transition: 'opacity 0.25s ease-out, transform 0.25s ease-out' })
        setTimeout(() => {
          $item.css({ opacity: 1, transform: 'translateY(0)' })
        }, index * 50)
      })
    })
  })

  return $modal
}

function getTabInfo(key) {
  const tabMap = {
    features: { icon: '&#x2728;', label: 'Features' },
    improvements: { icon: '&#x26A1;', label: 'Improvements' },
    fixes: { icon: '&#x1F41B;', label: 'Bug Fixes' },
    shortcuts: { icon: '&#x2328;', label: 'Shortcuts' },
    commands: { icon: '&#x1F4BB;', label: 'Commands' },
    messages: { icon: '&#x1F4E2;', label: 'Messages' }
  }
  return tabMap[key] || { icon: '&#x1F4DD;', label: key.charAt(0).toUpperCase() + key.slice(1) }
}

function resolveIcon(icon) {
  if (!icon) return ''
  if (/[\u{1F000}-\u{1FFFF}]|[\u2000-\u3300]|[\u{FE00}-\u{FEFF}]/u.test(icon)) return icon
  const faMap = {
    desktop_windows: 'fa-desktop',
    extension: 'fa-puzzle-piece',
    pets: 'fa-paw',
    camera_alt: 'fa-camera',
    layers: 'fa-layer-group',
    visibility_off: 'fa-eye-slash',
    brush: 'fa-paint-brush',
    mouse: 'fa-mouse-pointer',
    tune: 'fa-sliders-h',
    speed: 'fa-tachometer-alt',
    zoom_in: 'fa-search-plus',
    casino: 'fa-dice',
    bug_report: 'fa-bug',
    memory: 'fa-microchip',
    egg: 'fa-egg',
    shield: 'fa-shield-alt',
    keyboard: 'fa-keyboard',
    terminal: 'fa-terminal',
    save: 'fa-save'
  }
  const faClass = faMap[icon]
  if (faClass) return `<i class="fas ${faClass}" style="font-size: 12px;"></i>`
  return icon
}

function generateCategoryContent(categoryKey, items) {
  if (!items || items.length === 0) {
    return '<div class="text-center py-8 text-gray-400">No items in this category</div>'
  }

  const isShortcuts = categoryKey === 'shortcuts'
  const isCommands = categoryKey === 'commands'

  return `<div class="space-y-3">
    ${items.map(item => `
      <div class="update-item rounded-lg p-4 bg-tertiary-bg/50 border border-sidebar-border hover:border-sidebar-border/80 transition-colors">
        <div class="flex items-start space-x-3">
          <div class="w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0 text-sm" style="background: rgba(var(--theme-primary-rgb, 232, 61, 82), 0.15);">
            ${resolveIcon(item.icon)}
          </div>
          <div class="flex-1 min-w-0">
            <div class="flex items-center justify-between">
              <h3 class="font-semibold text-sm text-text-primary">${item.title}</h3>
              ${item.priority ? `<span class="text-xs px-2 py-0.5 rounded-full ${getPriorityClass(item.priority)}">${item.priority}</span>` : ''}
            </div>
            <p class="text-gray-400 text-sm mt-1">${item.description}</p>
            ${isShortcuts && item.keys ? `
              <div class="mt-2 flex items-center space-x-1">
                ${item.keys.map(key => `<kbd class="px-2 py-0.5 text-xs bg-secondary-bg border border-sidebar-border rounded font-mono text-text-primary">${key}</kbd>`).join(' <span class="text-gray-500 text-xs">+</span> ')}
              </div>` : ''}
            ${isCommands && item.command ? `
              <div class="mt-2">
                <code class="px-2 py-0.5 text-xs border border-sidebar-border rounded font-mono" style="background: rgba(var(--theme-primary-rgb, 232, 61, 82), 0.1); color: var(--theme-primary, #e83d52);">${item.command}</code>
              </div>` : ''}
          </div>
        </div>
      </div>
    `).join('')}
  </div>`
}

function getPriorityClass(priority) {
  switch (priority) {
    case 'major': return 'bg-highlight-green/20 text-highlight-green'
    case 'enhancement': return 'bg-blue-500/20 text-blue-400'
    case 'fix': return 'bg-red-500/20 text-red-400'
    default: return 'bg-gray-500/20 text-gray-400'
  }
}

exports.close = function () {
  $(window).off('resize.updatesModal')
}
