const $ = require('jquery')

const PLUGIN_GUIDES = {
  'UsernameLogger': {
    icon: 'fa-users',
    usage: `
      <div class="space-y-2">
        <div class="bg-tertiary-bg/50 p-3 rounded-lg">
          <p class="text-sm text-text-primary leading-relaxed">
            Automatically collects usernames of players you encounter and saves them to a file.
            Logging is configured in the main application settings under the LeakCheck tab.
          </p>
        </div>
      </div>`
  },
  'Packet Spammer': {
    icon: 'fa-bolt',
    usage: `
      <div class="space-y-2">
        <div class="bg-tertiary-bg/50 p-3 rounded-lg">
          <p class="text-sm text-text-primary leading-relaxed mb-2">Send game packets manually or on a timer. Useful for automating repetitive actions.</p>
          <ul class="text-sm text-text-primary space-y-1.5 pl-4 list-disc">
            <li><span class="font-medium" style="color: var(--theme-primary);">Send to:</span> Client (game) or Server (AJ servers)</li>
            <li><span class="font-medium" style="color: var(--theme-primary);">Delay:</span> Milliseconds between each send</li>
            <li><span class="font-medium" style="color: var(--theme-primary);">Queue:</span> Add multiple packets to run in sequence</li>
            <li><span class="font-medium" style="color: var(--theme-primary);">Templates:</span> Save and load packet setups</li>
          </ul>
        </div>
      </div>`
  },
  'Advertising': {
    icon: 'fa-bullhorn',
    usage: `
      <div class="space-y-2">
        <div class="bg-tertiary-bg/50 p-3 rounded-lg">
          <p class="text-sm text-text-primary leading-relaxed mb-2">Automatically sends chat messages at regular intervals for advertising your den or trades.</p>
          <ol class="text-sm text-text-primary space-y-1.5 pl-4 list-decimal">
            <li>Add your messages using the input field</li>
            <li>Set the interval (seconds between messages)</li>
            <li>Choose sequential or random order</li>
            <li>Click Start to begin</li>
          </ol>
        </div>
      </div>`
  },
  'Bot Detector': {
    icon: 'fa-shield-alt',
    usage: `
      <div class="bg-tertiary-bg/50 p-3 rounded-lg">
        <p class="text-sm text-text-primary leading-relaxed">
          Monitors the room for invisible or hidden players. Alerts you with a sound and console message
          when activity is detected from a user who has no visible avatar.
        </p>
      </div>`
  },
  'Pairs': {
    icon: 'fa-th',
    usage: `
      <div class="bg-tertiary-bg/50 p-3 rounded-lg">
        <p class="text-sm text-text-primary leading-relaxed">
          Reveals all card positions when playing the Pairs minigame. Join a Pairs game and the plugin
          will automatically show where each matching pair is located.
        </p>
      </div>`
  },
  'Private Chat Emojis': {
    icon: 'fa-smile',
    usage: `
      <div class="bg-tertiary-bg/50 p-3 rounded-lg">
        <p class="text-sm text-text-primary leading-relaxed">
          Displays a searchable grid of private chat emojis. Click any emoji to send it in the game.
        </p>
      </div>`
  },
  'Price Checker': {
    icon: 'fa-dollar-sign',
    usage: `
      <div class="bg-tertiary-bg/50 p-3 rounded-lg">
        <p class="text-sm text-text-primary leading-relaxed">
          Look up item values to check fair trade prices. Search by item name to see current worth estimates.
        </p>
      </div>`
  },
  'Glow': {
    icon: 'fa-sun',
    usage: `
      <div class="bg-tertiary-bg/50 p-3 rounded-lg">
        <p class="text-sm text-text-primary leading-relaxed">
          Makes your avatar glow with rapidly changing rainbow colors. Only other players can see the effect.
        </p>
      </div>`
  },
  'InvisibleToggle': {
    icon: 'fa-eye-slash',
    usage: `
      <div class="bg-tertiary-bg/50 p-3 rounded-lg">
        <p class="text-sm text-text-primary leading-relaxed">
          Toggles your character's visibility using mod commands.
        </p>
      </div>`
  },
  'Membership': {
    icon: 'fa-crown',
    usage: `
      <div class="bg-tertiary-bg/50 p-3 rounded-lg">
        <p class="text-sm text-text-primary leading-relaxed">
          Displays membership status information. Runs in the background automatically.
        </p>
      </div>`
  },
  'No Eyes': {
    icon: 'fa-eye',
    usage: `
      <div class="bg-tertiary-bg/50 p-3 rounded-lg">
        <p class="text-sm text-text-primary leading-relaxed">
          Removes the eyes from your animal's avatar. The effect is visible to other players.
        </p>
      </div>`
  },
  'Den Log': {
    icon: 'fa-home',
    usage: `
      <div class="bg-tertiary-bg/50 p-3 rounded-lg">
        <p class="text-sm text-text-primary leading-relaxed">
          Logs den visits and tracks activity in dens you visit. Check the console for logged events.
        </p>
      </div>`
  },
  'Chat Commands': {
    icon: 'fa-comments',
    usage: `
      <div class="bg-tertiary-bg/50 p-3 rounded-lg">
        <p class="text-sm text-text-primary leading-relaxed">
          Adds custom chat commands that can be triggered from the in-game chat. Type commands starting with / in the game chat.
        </p>
      </div>`
  },
  'Achievements': {
    icon: 'fa-trophy',
    usage: `
      <div class="bg-tertiary-bg/50 p-3 rounded-lg">
        <p class="text-sm text-text-primary leading-relaxed">
          Automates achievement completion by sending the required packets. Use the command to trigger specific achievements.
        </p>
      </div>`
  }
}

const TAG_COLORS = {
  beta: 'bg-highlight-yellow/20 text-highlight-yellow',
  new: 'bg-highlight-green/20 text-highlight-green',
  networking: 'bg-highlight-blue/20 text-highlight-blue',
  account: 'bg-highlight-purple/20 text-highlight-purple'
}

module.exports = class PluginInfoModalManager {
  constructor (dispatch) {
    this.dispatch = dispatch
  }

  directory (name) {
    const plugin = this.dispatch.plugins.get(name)
    if (plugin) {
      require('electron').ipcRenderer.send('open-directory', plugin.filepath)
    }
  }

  show (name) {
    const pluginMetadata = this.dispatch.plugins.get(name)
    if (!pluginMetadata) return

    const { type, description, author = 'Unknown' } = pluginMetadata.configuration
    const version = pluginMetadata.configuration.version || ''
    const commands = pluginMetadata.configuration.commands || []
    const tags = pluginMetadata.configuration.tags || []
    const filepath = pluginMetadata.filepath || ''

    const $overlay = $('<div>', {
      class: 'fixed inset-0 z-50 flex items-center justify-center',
      id: 'pluginInfoModal'
    })

    const $backdrop = $('<div>', { class: 'modal-backdrop' })
    $overlay.append($backdrop)

    const $container = $('<div>', { class: 'modal-container max-w-lg w-full mx-4' })

    const typeIcon = type === 'ui' ? 'fa-window-restore' : 'fa-code'
    const $header = $(`
      <div class="modal-header">
        <h3 class="modal-header-title">
          <i class="fas ${typeIcon} modal-section-icon"></i>
          ${name}
        </h3>
        <button type="button" class="modal-close-btn" aria-label="Close">
          <i class="fas fa-times"></i>
        </button>
      </div>
    `)

    $header.find('.modal-close-btn').on('click', () => this._close($overlay))
    $backdrop.on('click', () => this._close($overlay))

    const $body = $('<div>', { class: 'modal-body themed-scrollbar space-y-4' })

    if (version || tags.length > 0) {
      const $badges = $('<div>', { class: 'flex flex-wrap items-center gap-2' })
      if (version) {
        $badges.append(`<span class="px-2 py-0.5 text-xs font-medium rounded-full bg-tertiary-bg text-gray-400">v${version}</span>`)
      }
      if (author) {
        $badges.append(`<span class="px-2 py-0.5 text-xs font-medium rounded-full bg-tertiary-bg text-gray-400"><i class="fas fa-user mr-1" style="font-size:9px;"></i>${author}</span>`)
      }
      tags.forEach(tag => {
        const colorClass = TAG_COLORS[tag.toLowerCase()] || 'bg-gray-600/20 text-gray-400'
        $badges.append(`<span class="px-2 py-0.5 text-xs font-semibold rounded-full ${colorClass}">${tag}</span>`)
      })
      $body.append($badges)
    }

    const descText = description || (type === 'ui' ? 'A UI plugin for Animal Jam Classic.' : 'A game plugin for Animal Jam Classic.')
    $body.append(`
      <div>
        <h4 class="modal-section-title"><i class="fas fa-info-circle modal-section-icon"></i>Description</h4>
        <p class="text-sm text-text-primary leading-relaxed mt-2">${descText}</p>
      </div>
    `)

    const guide = PLUGIN_GUIDES[name]
    const usageHtml = guide
      ? guide.usage
      : type === 'ui'
        ? '<div class="bg-tertiary-bg/50 p-3 rounded-lg"><p class="text-sm text-text-primary leading-relaxed">Opens in a separate panel. Click the plugin tile in the sidebar to launch it.</p></div>'
        : '<div class="bg-tertiary-bg/50 p-3 rounded-lg"><p class="text-sm text-text-primary leading-relaxed">Runs automatically in the background. Use the commands below to control it. Type commands in the game chat starting with /.</p></div>'

    $body.append(`
      <div>
        <h4 class="modal-section-title"><i class="fas fa-lightbulb modal-section-icon"></i>How to Use</h4>
        <div class="mt-2">${usageHtml}</div>
      </div>
    `)

    const allCommands = [...commands]
    if (name === 'InvisibleToggle' && !commands.some(c => c.name === 'invis')) {
      allCommands.push({ name: 'invis', description: 'Toggles your character\'s visibility in the game.' })
    }

    if (allCommands.length > 0) {
      const $cmdsSection = $('<div>')
      $cmdsSection.append('<h4 class="modal-section-title"><i class="fas fa-terminal modal-section-icon"></i>Commands</h4>')
      const $cmdList = $('<div>', { class: 'space-y-2 mt-2' })

      allCommands.forEach(cmd => {
        $cmdList.append(`
          <div class="bg-tertiary-bg/50 p-3 rounded-lg border border-sidebar-border">
            <code class="text-xs font-mono px-1.5 py-0.5 rounded" style="background: rgba(var(--theme-primary-rgb, 232, 61, 82), 0.15); color: var(--theme-primary, #e83d52);">/${cmd.name}</code>
            <span class="text-sm text-gray-400 ml-2">${cmd.description || ''}</span>
          </div>
        `)
      })

      $cmdsSection.append($cmdList)
      $body.append($cmdsSection)
    }

    const $footer = $('<div>', { class: 'modal-footer justify-end' })

    if (filepath) {
      $footer.append(
        $('<button>', {
          class: 'modal-btn-secondary mr-auto text-xs',
          html: '<i class="fas fa-folder-open mr-1.5"></i> Open Folder'
        }).on('click', () => this.directory(name))
      )
    }

    $footer.append(
      $('<button>', {
        class: 'modal-btn-primary',
        html: '<i class="fas fa-check mr-1.5"></i> Got it'
      }).on('click', () => this._close($overlay))
    )

    $container.append($header, $body, $footer)
    $overlay.append($container)
    $('body').append($overlay)
  }

  _close ($overlay) {
    const $container = $overlay.find('.modal-container')
    $container.addClass('modal-exit')
    $overlay.find('.modal-backdrop').css({ opacity: 0, transition: 'opacity 0.15s ease-out' })
    setTimeout(() => $overlay.remove(), 150)
  }
}
