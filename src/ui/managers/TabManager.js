class TabManager {
  constructor(application) {
    this.application = application
  }

  openTab(tabId) {
    if (tabId === 'packet-logging' && window._packetFilterManager) {
      setTimeout(() => window._packetFilterManager.applyToDOM(), 0)
    }

    const $currentActive = $('.tab-content.active')
    const $newActive = $(`#${tabId}`)
    
    if ($currentActive.attr('id') === $newActive.attr('id')) {
      return
    }
    
    $('.tab-button').removeClass('active')
    const $activeTab = $(`.tab-button[data-tab="${tabId}"]`).addClass('active')
    
    $('.active-indicator').css({
      'transform': 'scaleX(0)',
      'background-color': '',
      'box-shadow': '',
      'transition': 'transform 0.3s ease-out, background-color 0.3s ease, box-shadow 0.3s ease'
    })
    
    const themeColor = $('body').css('--theme-primary') || '#e83d52'
    $activeTab.find('.active-indicator').css({
      'transform': 'scaleX(1)',
      'background-color': themeColor,
      'box-shadow': `0 0 6px 0 ${themeColor}`,
      'transition': 'transform 0.3s ease-out, background-color 0.3s ease, box-shadow 0.3s ease'
    })
    
    $currentActive.css({
      'opacity': '1',
      'transform': 'translateY(0)',
      'transition': 'opacity 0.25s ease-out, transform 0.25s ease-out'
    })
    
    setTimeout(() => {
      $currentActive.css({
        'opacity': '0',
        'transform': 'translateY(10px)'
      })
      
      setTimeout(() => {
        $currentActive.removeClass('active').addClass('hidden')
        
        $newActive.removeClass('hidden').addClass('active').css({
          'opacity': '0',
          'transform': 'translateY(-10px)',
          'transition': 'opacity 0.25s ease-out, transform 0.25s ease-out'
        })
        
        setTimeout(() => {
          $newActive.css({
            'opacity': '1',
            'transform': 'translateY(0)'
          })
          
          if (this.application && typeof this.application._applyTooltips === 'function') {
            setTimeout(() => this.application._applyTooltips(), 300)
          }
        }, 10)
      }, 200)
    }, 10)
  }
}

module.exports = TabManager

