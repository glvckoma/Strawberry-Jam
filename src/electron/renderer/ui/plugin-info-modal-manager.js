/* eslint-disable camelcase */
const $ = require('jquery');

module.exports = class PluginInfoModalManager {
  /**
   * Constructor.
   * @param {object} dispatch - The application's dispatch instance.
   * @constructor
   */
  constructor (dispatch) {
    /**
     * The reference to the dispatch.
     * @type {object}
     * @public
     */
    this.dispatch = dispatch;
  }

  /**
   * Opens the plugin directory.
   * @param name
   * @public
   */
  directory (name) {
    const plugin = this.dispatch.plugins.get(name)

    if (plugin) {
      const { filepath } = plugin
      const { ipcRenderer } = require('electron');
      ipcRenderer.send('open-directory', filepath)
    }
  }

  /**
   * Shows the plugin info modal.
   * @param {string} name - Plugin name
   * @private
   */
  show (name) {
    // Get plugin commands and other metadata if available
    const pluginMetadata = this.dispatch.plugins.get(name);
    if (!pluginMetadata) return;

    const { type, description, author = 'Sxip' } = pluginMetadata.configuration;
    let commands = [];
    let version = '';
    let filepath = '';
    let tags = [];
    
    if (pluginMetadata.configuration) {
      version = pluginMetadata.configuration.version || '';
      commands = pluginMetadata.configuration.commands || [];
      tags = pluginMetadata.configuration.tags || [];
    }
    filepath = pluginMetadata.filepath || '';
    
    // Create modal container
    const $modal = $('<div>', {
      class: 'fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-70 backdrop-blur-sm',
      id: 'pluginInfoModal'
    });
    
    // Create the modal content with kid-friendly styling - removed white border
    const $content = $('<div>', {
      class: 'bg-primary-bg rounded-xl shadow-2xl max-w-lg w-full mx-4 overflow-hidden transform transition-all duration-200 scale-100 hover:scale-[1.01]'
    });
    
    // Modal header with fun styling
    const $header = $('<div>', {
      class: 'px-6 py-4 bg-gradient-to-r from-highlight-blue/20 to-highlight-blue/5 border-b border-highlight-blue/50 flex items-center justify-between'
    });
    
    // Title with bouncy animation on hover - Now uses the actual name
    const $title = $('<h3>', {
      class: 'text-lg font-bold text-highlight-blue flex items-center transition-transform duration-200',
      // Use the actual name passed as argument
      html: `<i class="fas ${type === 'ui' ? 'fa-window-restore' : 'fa-code'} mr-2 transform transition-all duration-300"></i> ${name}` 
    });
    
    // Add bounce effect on hover
    $title.hover(
      function() {
        $(this).find('i').addClass('animate-bounce');
      },
      function() {
        $(this).find('i').removeClass('animate-bounce');
      }
    );
    
    $header.append($title);
    
    // Modal body with colorful sections for kids
    const $body = $('<div>', {
      class: 'px-6 py-5 max-h-[65vh] overflow-y-auto custom-scrollbar'
    });
    
    // Version and tags display if available
    if (version || (tags && tags.length > 0)) {
      const $versionTagsContainer = $('<div>', {
        class: 'flex flex-wrap items-center gap-2 mb-4'
      });
      
      if (version) {
        $versionTagsContainer.append(
          $('<span>', {
            class: 'px-2 py-1 text-xs font-semibold rounded-full bg-tertiary-bg text-text-secondary',
            text: `v${version}`
          })
        );
      }
      
      if (tags && tags.length > 0) {
        tags.forEach(tag => {
          let tagColorClass = '';
          switch(tag.toLowerCase()) {
            case 'beta':
              tagColorClass = 'bg-highlight-yellow/20 text-highlight-yellow';
              break;
            case 'new':
              tagColorClass = 'bg-highlight-green/20 text-highlight-green';
              break;
            case 'networking':
              tagColorClass = 'bg-highlight-blue/20 text-highlight-blue';
              break;
            case 'account':
              tagColorClass = 'bg-highlight-purple/20 text-highlight-purple';
              break;
            default:
              tagColorClass = 'bg-gray-600/20 text-gray-400';
          }
          
          $versionTagsContainer.append(
            $('<span>', {
              class: `px-2 py-1 text-xs font-semibold rounded-full ${tagColorClass}`,
              text: tag
            })
          );
        });
      }
      
      $body.append($versionTagsContainer);
    }
    
    // What is this plugin? - with hover effects
    const $whatIsSection = $('<div>', {
      class: 'mb-5 bg-highlight-green/10 p-4 rounded-lg border border-highlight-green/30 transform transition-all duration-200 hover:border-highlight-green/60 hover:bg-highlight-green/15 hover:shadow-md'
    });
    
    $whatIsSection.append(
      $('<h4>', {
        class: 'text-highlight-green text-base font-bold mb-2 flex items-center',
        html: '<i class="fas fa-puzzle-piece mr-2"></i> What is this plugin?'
      }),
      $('<p>', {
        class: 'text-text-primary text-sm leading-relaxed',
        text: description || `A ${type} plugin for Animal Jam`
      })
    );
    
    $body.append($whatIsSection);
    
    // Who made it? - with hover effects
    const $whoMadeSection = $('<div>', {
      class: 'mb-5 bg-highlight-yellow/10 p-4 rounded-lg border border-highlight-yellow/30 transform transition-all duration-200 hover:border-highlight-yellow/60 hover:bg-highlight-yellow/15 hover:shadow-md'
    });
    
    $whoMadeSection.append(
      $('<h4>', {
        class: 'text-highlight-yellow text-base font-bold mb-2 flex items-center',
        html: '<i class="fas fa-user-edit mr-2"></i> Who made it?'
      }),
      $('<p>', {
        class: 'text-text-primary text-sm leading-relaxed flex items-center',
        html: `<i class="fas fa-user mr-2"></i> ${author}${version ? ` <span class="ml-2 text-gray-400">(v${version})</span>` : ''}`
      })
    );
    
    $body.append($whoMadeSection);
    
    // How do I use it? - detailed instructions based on plugin type
    const $howToSection = $('<div>', {
      class: 'mb-5 bg-highlight-blue/10 p-4 rounded-lg border border-highlight-blue/30 transform transition-all duration-200 hover:border-highlight-blue/60 hover:bg-highlight-blue/15 hover:shadow-md'
    });
    
    $howToSection.append(
      $('<h4>', {
        class: 'text-highlight-blue text-base font-bold mb-2 flex items-center',
        html: '<i class="fas fa-lightbulb mr-2"></i> How do I use it?'
      })
    );
    
    // Customize the instructions based on plugin name
    let howToUseHtml = '';
    
    if (name === 'UsernameLogger') {
      howToUseHtml = `
        <div class="space-y-3 mt-3">
          <div class="bg-secondary-bg/30 p-3 rounded-lg">
            <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
              <i class="fas fa-users mr-2"></i> What does this plugin do?
            </p>
            <p class="text-text-primary text-sm leading-relaxed">
              This plugin automatically collects usernames of jammers you see in the game and saves them to a file for you.
            </p>
          </div>
          <div class="bg-secondary-bg/30 p-3 rounded-lg">
            <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
              <i class="fas fa-cogs mr-2"></i> How to use it:
            </p>
            <p class="text-text-primary text-sm leading-relaxed">
              Logging is enabled and configured in the main application settings (the gear icon <i class="fas fa-cog"></i>). You can use the commands below to manage the collected usernames.
            </p>
          </div>
        </div>
      `;
    } else if (name === 'Spammer') {
      howToUseHtml = `
        <div class="space-y-3 mt-3">
          <div class="bg-secondary-bg/30 p-3 rounded-lg">
            <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
              <i class="fas fa-bolt mr-2"></i> What is Spammer?
            </p>
            <p class="text-text-primary text-sm leading-relaxed">
              This tool lets you send packets (game messages) repeatedly. This can be used to automate certain actions in the game.
            </p>
          </div>
          <div class="bg-secondary-bg/30 p-3 rounded-lg">
            <p class="text-text-primary text-sm font-medium mb-2 flex items-center">
              <i class="fas fa-gamepad mr-2"></i> Using the buttons:
            </p>
            <ul class="text-text-primary text-sm space-y-2 list-disc pl-5">
              <li><span class="text-highlight-blue font-medium">Packet Type:</span> Choose whether to send the packet to the game (client) or to Animal Jam's servers.</li>
              <li><span class="text-highlight-blue font-medium">Packet Content:</span> Type or paste the packet message you want to send.</li>
              <li><span class="text-highlight-blue font-medium">Delay (ms):</span> How long to wait between sending each packet (in milliseconds).</li>
              <li><span class="text-highlight-blue font-medium">Count:</span> How many packets to send (leave empty to send continuously).</li>
              <li><span class="text-highlight-blue font-medium">Start/Stop:</span> Begin or end sending the packets.</li>
              <li><span class="text-highlight-blue font-medium">Save/Load:</span> Save your favorite packet setups to use them again later.</li>
            </ul>
          </div>
          <div class="bg-highlight-yellow/10 p-3 rounded-lg">
            <p class="text-highlight-yellow text-sm font-medium flex items-center mb-1"><i class="fas fa-exclamation-triangle mr-2"></i> Friendly reminder:</p>
            <p class="text-text-primary text-sm leading-relaxed">Be careful! Sending too many packets too quickly can cause lag or get you disconnected.</p>
          </div>
        </div>
      `;
    } else if (name === 'Advertising') {
      howToUseHtml = `
        <div class="space-y-3 mt-3">
          <div class="bg-secondary-bg/30 p-3 rounded-lg">
            <p class="text-text-primary text-sm font-medium mb-2 flex items-center"><i class="fas fa-bullhorn mr-2"></i> What it does</p>
            <p class="text-text-primary text-sm leading-relaxed">This plugin helps you automatically send chat messages at regular intervals—perfect for advertising your den or items for trade!</p>
          </div>
          <div class="bg-secondary-bg/30 p-3 rounded-lg">
            <p class="text-text-primary text-sm font-medium mb-2 flex items-center"><i class="fas fa-gamepad mr-2"></i> Step-by-step</p>
            <ol class="text-text-primary text-sm space-y-2 list-decimal pl-5">
              <li><span class="text-highlight-blue font-medium">Add messages:</span> Click "Add Message" and type your message.</li>
              <li><span class="text-highlight-blue font-medium">Set interval:</span> Enter how many seconds to wait between messages.</li>
              <li><span class="text-highlight-blue font-medium">Choose order:</span> Pick "Sequential" or "Random".</li>
              <li><span class="text-highlight-blue font-medium">Start/Stop:</span> Click the buttons to begin or end advertising.</li>
            </ol>
          </div>
          <div class="bg-secondary-bg/30 p-3 rounded-lg">
            <p class="text-text-primary text-sm font-medium mb-2 flex items-center"><i class="fas fa-save mr-2"></i> Saving</p>
            <p class="text-text-primary text-sm leading-relaxed">Use the "Save" and "Load" buttons to keep your message lists for later.</p>
          </div>
        </div>
      `;
    } else if (type === 'ui') {
      // Generic instructions for other UI plugins
      howToUseHtml = `
        <p class="text-text-primary text-sm leading-relaxed">
          This is a UI plugin. Click on it in the sidebar to open its window and see what it does!
        </p>
      `;
    } else {
      // Generic instructions for Game plugins
      howToUseHtml = `
        <p class="text-text-primary text-sm leading-relaxed">
          This is a Game plugin. It runs in the background to add new features or change game behavior. Check the "Commands" section below to see how you can interact with it.
        </p>
      `;
    }
    
    $howToSection.append(howToUseHtml);
    $body.append($howToSection);
    
    // Special handling for InvisibleToggle plugin
    if (name === 'InvisibleToggle') {
      // Add commands section for InvisibleToggle
      const $invisibleCommandsSection = $('<div>', {
        class: 'mb-5 bg-highlight-purple/10 p-4 rounded-lg border border-highlight-purple/30 transform transition-all duration-200 hover:border-highlight-purple/60 hover:bg-highlight-purple/15 hover:shadow-md'
      });
      
      $invisibleCommandsSection.append(
        $('<h4>', {
          class: 'text-highlight-purple text-base font-bold mb-3 flex items-center',
          html: '<i class="fas fa-terminal mr-2"></i> Commands you can use:'
        })
      );
      
      const $commandsList = $('<ul>', {
        class: 'space-y-3'
      });
      
      const $cmdItem = $('<li>', {
        class: 'text-text-primary text-sm bg-secondary-bg/50 p-3 rounded-lg border border-sidebar-border/30 transform transition-all duration-200 hover:border-highlight-purple/30 hover:bg-secondary-bg'
      });
      
      const $cmdName = $('<div>', {
        class: 'font-mono bg-highlight-purple/20 px-2 py-1 rounded text-highlight-purple inline-block mb-1.5',
        text: 'invis'
      });
      
      const $cmdDesc = $('<div>', {
        class: 'text-text-primary leading-relaxed',
        text: 'Toggles your character\'s visibility in the game.'
      });
      
      $cmdItem.append($cmdName, $cmdDesc);
      $commandsList.append($cmdItem);
      
      $invisibleCommandsSection.append($commandsList);
      $body.append($invisibleCommandsSection);
    }
    
    // Display commands if available with interactive styling
    if (commands && commands.length > 0) {
      const $commandsSection = $('<div>', {
        class: 'mb-5 bg-highlight-purple/10 p-4 rounded-lg border border-highlight-purple/30 transform transition-all duration-200 hover:border-highlight-purple/60 hover:bg-highlight-purple/15 hover:shadow-md'
      });
      
      $commandsSection.append(
        $('<h4>', {
          class: 'text-highlight-purple text-base font-bold mb-3 flex items-center',
          html: '<i class="fas fa-terminal mr-2"></i> Commands you can use:'
        })
      );
      
      const $commandsList = $('<ul>', {
        class: 'space-y-3'
      });
      
      commands.forEach(cmd => {
        const $cmdItem = $('<li>', {
          class: 'text-text-primary text-sm bg-secondary-bg/50 p-3 rounded-lg border border-sidebar-border/30 transform transition-all duration-200 hover:border-highlight-purple/30 hover:bg-secondary-bg'
        });
        
        const $cmdName = $('<div>', {
          class: 'font-mono bg-highlight-purple/20 px-2 py-1 rounded text-highlight-purple inline-block mb-1.5',
          text: cmd.name
        });
        
        const $cmdDesc = $('<div>', {
          class: 'text-text-primary leading-relaxed',
          text: cmd.description || ''
        });
        
        $cmdItem.append($cmdName, $cmdDesc);
        $commandsList.append($cmdItem);
      });
      
      $commandsSection.append($commandsList);
      $body.append($commandsSection);
    }
    
    // Add a fun footer with bouncy button
    const $footer = $('<div>', {
      class: 'px-6 py-4 bg-gradient-to-r from-tertiary-bg to-tertiary-bg/70 border-t border-sidebar-border/50 flex justify-end items-center'
    });
    
    // Add directory button if available
    if (filepath) {
      const $dirButton = $('<button>', {
        class: 'mr-auto bg-tertiary-bg hover:bg-tertiary-bg/80 text-text-secondary hover:text-text-primary px-3 py-1.5 rounded-lg transition-colors text-xs flex items-center',
        html: '<i class="fas fa-folder mr-1.5"></i> Open folder'
      }).on('click', () => {
        this.directory(name);
      });
      
      $footer.append($dirButton);
    }
    
    const themeColor = getComputedStyle(document.documentElement).getPropertyValue('--theme-primary').trim() || '#e83d52'
    
    const $gotItButton = $('<button>', {
      class: 'text-white rounded-lg px-5 py-2.5 shadow-lg transition-all duration-200 transform hover:scale-[1.02] active:scale-100 focus:ring-2 focus:ring-offset-2 focus:ring-offset-primary-bg font-medium',
      id: 'pluginInfoGotItButton',
      html: '<i class="fas fa-check mr-1.5"></i> Got it!',
      css: {
        'background-color': themeColor,
        'border-color': themeColor
      }
    }).on('click', () => {
      $modal.css({
        'opacity': '0',
        'transform': 'scale(0.95)',
        'transition': 'opacity 0.2s ease-in-out, transform 0.2s ease-in-out'
      });
      
      setTimeout(() => $modal.remove(), 200);
    }).on('mouseenter', function() {
      $(this).css('filter', 'brightness(1.1)')
    }).on('mouseleave', function() {
      $(this).css('filter', '')
    }).on('focus', function() {
      $(this).css('--tw-ring-color', themeColor)
    });
    
    $footer.append($gotItButton);
    
    // Assemble and add to DOM
    $content.append($header, $body, $footer);
    $modal.append($content);
    $('body').append($modal);
    
    // Fade in animation
    $modal.css({
      'opacity': '0',
      'transform': 'scale(0.95)'
    });
    
    setTimeout(() => {
      $modal.css({
        'opacity': '1',
        'transform': 'scale(1)',
        'transition': 'opacity 0.3s ease-out, transform 0.3s ease-out'
      });
    }, 10);
  }
}
