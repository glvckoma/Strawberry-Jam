const $ = require('jquery');
const Tooltip = require('../../electron/renderer/application/components/tooltip');

class TooltipManager {
  constructor(application) {
    this.application = application;
    this.observer = null;
    this.$playGameBtn = null;
  }

  initialize() {
    Tooltip.init(this.application);
    this._removeTitleAttributes();
    this._setupTooltipObserver();
  }

  addTooltip(element, content, options = {}) {
    return Tooltip.create(element, content, options);
  }

  applyTooltips() {
    const refreshPluginsButton = document.getElementById('refreshPluginsSection');
    if (refreshPluginsButton) {
      this.addTooltip(refreshPluginsButton, 'Refresh Plugins');
    }
    
    const togglePluginsButton = document.getElementById('togglePluginsSection');
    if (togglePluginsButton) {
      this.addTooltip(togglePluginsButton, 'Toggle Plugins List');
    }
    
    $('.plugin-info-button').each((index, element) => {
      this.addTooltip(element, 'More Info');
    });
    
    const clearConsoleButton = document.getElementById('clearConsoleButton');
    if (clearConsoleButton) {
      this.addTooltip(clearConsoleButton, 'Clear Console Messages');
    }
    
    const clearPacketLogButton = document.getElementById('clearPacketLogButton');
    if (clearPacketLogButton) {
      this.addTooltip(clearPacketLogButton, 'Clear Network Messages');
    }
    
    const toggleNavButton = document.getElementById('toggleNavSection');
    if (toggleNavButton) {
      this.addTooltip(toggleNavButton, 'Toggle Navigation List');
    }
  }

  addGameRunningTooltip($playGameBtn) {
    this.$playGameBtn = $playGameBtn;
    if (this.$playGameBtn) {
      this.addTooltip(this.$playGameBtn, 'Strawberry Jam is already running', {
        theme: 'error',
        position: 'top'
      });
    }
  }

  removeGameRunningTooltip() {
    if (this.$playGameBtn) {
      Tooltip.remove(this.$playGameBtn);
    }
  }

  _setupTooltipObserver() {
    if (this.observer) {
      this.observer.disconnect();
    }

    this.observer = new MutationObserver((mutations) => {
      let shouldReapplyTooltips = false;
      
      for (const mutation of mutations) {
        if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
          for (const node of mutation.addedNodes) {
            if (node.nodeType === 1 && (
                node.id === 'clearConsoleButton' || 
                node.id === 'clearPacketLogButton' ||
                node.id === 'settingsButton' ||
                node.id === 'pluginsButton' ||
                node.querySelector('.modal-close-button-std') ||
                node.classList.contains('tab-content')
              )) {
              shouldReapplyTooltips = true;
              break;
            }
          }
        }
        
        if (shouldReapplyTooltips) break;
      }
      
      if (shouldReapplyTooltips) {
        setTimeout(() => this.applyTooltips(), 100);
      }
    });
    
    this.observer.observe(document.body, {
      childList: true,
      subtree: true,
      attributes: false,
      characterData: false
    });
  }

  _removeTitleAttributes() {
    $('#clearConsoleButton').removeAttr('title');
    $('#clearPacketLogButton').removeAttr('title');
    $('#refreshPluginsSection').removeAttr('title');
    $('#togglePluginsSection').removeAttr('title');
    $('#toggleNavSection').removeAttr('title');
    
    $('.plugin-info-button').removeAttr('title');

    $('#minimizeButton').removeAttr('title');
    $('#fullscreenButton').removeAttr('title');
    $('#mainCloseButton').removeAttr('title');
    $('#playGameBtn').removeAttr('title');
  }

  destroy() {
    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }
  }
}

module.exports = TooltipManager;

