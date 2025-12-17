class TutorialOverlay {
  constructor($targetElement, position = 'bottom') {
    this.$target = $targetElement
    this.position = position
    this.$overlay = null
    this.$highlight = null
    this.uniqueId = null
    this.observer = null
  }

  show() {
    if (this.$overlay) {
      this.hide()
    }

    const viewportWidth = window.innerWidth
    const viewportHeight = window.innerHeight

    this.uniqueId = `tutorial-mask-${Date.now()}`
    
    if (this.showOverlayOnly) {
      this._createOverlayOnly(viewportWidth, viewportHeight)
      return
    }

    const targetRect = this.$target[0].getBoundingClientRect()
    const padding = 8
    
    this.$overlay = $('<div>')
      .css({
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
        zIndex: 9998,
        pointerEvents: 'none',
        transition: 'opacity 0.3s ease'
      })
      .attr('id', 'tutorial-overlay')
      .attr('data-tutorial-overlay', 'true')

    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
    svg.setAttribute('width', viewportWidth)
    svg.setAttribute('height', viewportHeight)
    svg.style.position = 'absolute'
    svg.style.top = '0'
    svg.style.left = '0'
    svg.style.pointerEvents = 'none'

    const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs')
    const mask = document.createElementNS('http://www.w3.org/2000/svg', 'mask')
    mask.setAttribute('id', this.uniqueId)

    const maskRect = document.createElementNS('http://www.w3.org/2000/svg', 'rect')
    maskRect.setAttribute('x', '0')
    maskRect.setAttribute('y', '0')
    maskRect.setAttribute('width', viewportWidth)
    maskRect.setAttribute('height', viewportHeight)
    maskRect.setAttribute('fill', 'white')

    const borderRadius = 8
    const cutout = document.createElementNS('http://www.w3.org/2000/svg', 'rect')
    cutout.setAttribute('x', Math.max(0, targetRect.left - padding))
    cutout.setAttribute('y', Math.max(0, targetRect.top - padding))
    cutout.setAttribute('width', Math.min(targetRect.width + (padding * 2), viewportWidth))
    cutout.setAttribute('height', Math.min(targetRect.height + (padding * 2), viewportHeight))
    cutout.setAttribute('rx', borderRadius)
    cutout.setAttribute('ry', borderRadius)
    cutout.setAttribute('fill', 'black')
    
    mask.appendChild(maskRect)
    mask.appendChild(cutout)
    
    const modalContent = document.querySelector('[data-tutorial-modal-content="true"]')
    if (modalContent) {
      const modalRect = modalContent.getBoundingClientRect()
      if (modalRect.width > 0 && modalRect.height > 0) {
        const computedStyle = window.getComputedStyle(modalContent)
        const modalBorderRadius = parseFloat(computedStyle.borderRadius) || 8
        const modalCutout = document.createElementNS('http://www.w3.org/2000/svg', 'rect')
        modalCutout.setAttribute('x', Math.max(0, modalRect.left))
        modalCutout.setAttribute('y', Math.max(0, modalRect.top))
        modalCutout.setAttribute('width', Math.min(modalRect.width, viewportWidth))
        modalCutout.setAttribute('height', Math.min(modalRect.height, viewportHeight))
        modalCutout.setAttribute('rx', modalBorderRadius)
        modalCutout.setAttribute('ry', modalBorderRadius)
        modalCutout.setAttribute('fill', 'black')
        mask.appendChild(modalCutout)
      }
    }
    defs.appendChild(mask)
    svg.appendChild(defs)

    const overlayRect = document.createElementNS('http://www.w3.org/2000/svg', 'rect')
    overlayRect.setAttribute('x', '0')
    overlayRect.setAttribute('y', '0')
    overlayRect.setAttribute('width', viewportWidth)
    overlayRect.setAttribute('height', viewportHeight)
    overlayRect.setAttribute('fill', 'rgba(0, 0, 0, 0.7)')
    overlayRect.setAttribute('mask', `url(#${this.uniqueId})`)

    svg.appendChild(overlayRect)
    this.$overlay.append(svg)

    const highlightBorderRadius = 8
    this.$highlight = $('<div>')
      .css({
        position: 'fixed',
        left: `${targetRect.left - padding}px`,
        top: `${targetRect.top - padding}px`,
        width: `${targetRect.width + (padding * 2)}px`,
        height: `${targetRect.height + (padding * 2)}px`,
        border: '3px solid',
        borderColor: 'var(--theme-primary, #e83d52)',
        borderRadius: `${highlightBorderRadius}px`,
        boxShadow: '0 0 0 2px rgba(255, 255, 255, 0.3), 0 0 0 6px rgba(232, 61, 82, 0.4), 0 0 30px rgba(232, 61, 82, 0.6)',
        zIndex: 9999,
        pointerEvents: 'none',
        animation: 'tutorial-pulse 2s ease-in-out infinite',
        transition: 'all 0.2s ease',
        backgroundColor: 'transparent',
        opacity: '1'
      })
      .attr('id', 'tutorial-highlight')
      .attr('data-tutorial-highlight', 'true')

    const style = document.createElement('style')
    style.textContent = `
      @keyframes tutorial-pulse {
        0%, 100% {
          box-shadow: 0 0 0 4px rgba(232, 61, 82, 0.3), 0 0 20px rgba(232, 61, 82, 0.5);
        }
        50% {
          box-shadow: 0 0 0 6px rgba(232, 61, 82, 0.4), 0 0 30px rgba(232, 61, 82, 0.7);
        }
      }
    `
    document.head.appendChild(style)

    $('body').append(this.$overlay)
    $('body').append(this.$highlight)

    this.$target.addClass('tutorial-highlighted')
    const originalZIndex = this.$target.css('z-index')
    const originalPosition = this.$target.css('position')
    
    if (this.$target.hasClass('plugin-info-button')) {
      this.$target.css({
        'position': 'relative',
        'z-index': '10001',
        'filter': 'brightness(1.3) drop-shadow(0 0 6px rgba(232, 61, 82, 1))',
        'transition': 'filter 0.3s ease, transform 0.3s ease',
        'transform': 'scale(1.15)',
        'opacity': '1',
        'visibility': 'visible',
        'display': 'block'
      })
    } else {
      this.$target.css({
        'position': 'relative',
        'z-index': '10001',
        'filter': 'brightness(1.1)',
        'transition': 'filter 0.3s ease'
      })
    }
    this.originalZIndex = originalZIndex
    this.originalPosition = originalPosition


    const updatePosition = () => {
      if (!this.$target || this.$target.length === 0) return
      
      const rect = this.$target[0].getBoundingClientRect()
      const viewportWidth = window.innerWidth
      const viewportHeight = window.innerHeight
      
      if (this.$highlight) {
        const highlightBorderRadius = 8
        this.$highlight.css({
          left: `${Math.max(0, rect.left - padding)}px`,
          top: `${Math.max(0, rect.top - padding)}px`,
          width: `${Math.min(rect.width + (padding * 2), viewportWidth)}px`,
          height: `${Math.min(rect.height + (padding * 2), viewportHeight)}px`,
          borderRadius: `${highlightBorderRadius}px`
        })
      }
      
      if (this.$overlay && this.$overlay.find('svg').length > 0 && this.uniqueId) {
        const svg = this.$overlay.find('svg')[0]
        svg.setAttribute('width', viewportWidth)
        svg.setAttribute('height', viewportHeight)
        
        const mask = svg.querySelector(`mask[id="${this.uniqueId}"]`)
        if (mask) {
          const cutouts = mask.querySelectorAll('rect')
          if (cutouts.length > 1) {
            const borderRadius = 8
            const targetCutout = cutouts[1]
            targetCutout.setAttribute('x', Math.max(0, rect.left - padding))
            targetCutout.setAttribute('y', Math.max(0, rect.top - padding))
            targetCutout.setAttribute('width', Math.min(rect.width + (padding * 2), viewportWidth))
            targetCutout.setAttribute('height', Math.min(rect.height + (padding * 2), viewportHeight))
            targetCutout.setAttribute('rx', borderRadius)
            targetCutout.setAttribute('ry', borderRadius)
            
            const modalContent = document.querySelector('[data-tutorial-modal-content="true"]')
            if (modalContent && cutouts.length > 2) {
              const modalRect = modalContent.getBoundingClientRect()
              if (modalRect.width > 0 && modalRect.height > 0) {
                const computedStyle = window.getComputedStyle(modalContent)
                const modalBorderRadius = parseFloat(computedStyle.borderRadius) || 8
                const modalCutout = cutouts[2]
                modalCutout.setAttribute('x', Math.max(0, modalRect.left))
                modalCutout.setAttribute('y', Math.max(0, modalRect.top))
                modalCutout.setAttribute('width', Math.min(modalRect.width, viewportWidth))
                modalCutout.setAttribute('height', Math.min(modalRect.height, viewportHeight))
                modalCutout.setAttribute('rx', modalBorderRadius)
                modalCutout.setAttribute('ry', modalBorderRadius)
              }
            }
          }
        }
      }
    }

    $(window).on('resize.tutorial scroll.tutorial', updatePosition)
    this.updatePosition = updatePosition
    
    const observer = new MutationObserver(() => {
      updatePosition()
    })
    
    if (this.$target[0] && this.$target[0].parentNode) {
      observer.observe(this.$target[0].parentNode, {
        childList: true,
        subtree: true,
        attributes: true,
        attributeFilter: ['style', 'class']
      })
    }
    
    observer.observe(document.body, {
      childList: true,
      subtree: false,
      attributes: false
    })
    
    this.observer = observer
    
    setTimeout(() => {
      updatePosition()
    }, 100)
  }

  _createOverlayOnly(viewportWidth, viewportHeight) {
    this.$overlay = $('<div>')
      .css({
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100%',
        height: '100%',
        zIndex: 9998,
        pointerEvents: 'none',
        opacity: '1',
        transition: 'opacity 0.2s ease'
      })
      .attr('id', 'tutorial-overlay')
      .attr('data-tutorial-overlay', 'true')

    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
    svg.setAttribute('width', viewportWidth)
    svg.setAttribute('height', viewportHeight)
    svg.style.position = 'absolute'
    svg.style.top = '0'
    svg.style.left = '0'
    svg.style.pointerEvents = 'none'

    const defs = document.createElementNS('http://www.w3.org/2000/svg', 'defs')
    const mask = document.createElementNS('http://www.w3.org/2000/svg', 'mask')
    mask.setAttribute('id', this.uniqueId)

    const maskRect = document.createElementNS('http://www.w3.org/2000/svg', 'rect')
    maskRect.setAttribute('x', '0')
    maskRect.setAttribute('y', '0')
    maskRect.setAttribute('width', viewportWidth)
    maskRect.setAttribute('height', viewportHeight)
    maskRect.setAttribute('fill', 'white')

    mask.appendChild(maskRect)
    
    const modalContent = document.querySelector('[data-tutorial-modal-content="true"]')
    if (modalContent) {
      const modalRect = modalContent.getBoundingClientRect()
      if (modalRect.width > 0 && modalRect.height > 0) {
        const computedStyle = window.getComputedStyle(modalContent)
        const modalBorderRadius = parseFloat(computedStyle.borderRadius) || 8
        const modalCutout = document.createElementNS('http://www.w3.org/2000/svg', 'rect')
        modalCutout.setAttribute('x', Math.max(0, modalRect.left))
        modalCutout.setAttribute('y', Math.max(0, modalRect.top))
        modalCutout.setAttribute('width', Math.min(modalRect.width, viewportWidth))
        modalCutout.setAttribute('height', Math.min(modalRect.height, viewportHeight))
        modalCutout.setAttribute('rx', modalBorderRadius)
        modalCutout.setAttribute('ry', modalBorderRadius)
        modalCutout.setAttribute('fill', 'black')
        mask.appendChild(modalCutout)
      }
    }
    
    defs.appendChild(mask)
    svg.appendChild(defs)

    const overlayRect = document.createElementNS('http://www.w3.org/2000/svg', 'rect')
    overlayRect.setAttribute('x', '0')
    overlayRect.setAttribute('y', '0')
    overlayRect.setAttribute('width', viewportWidth)
    overlayRect.setAttribute('height', viewportHeight)
    overlayRect.setAttribute('fill', 'rgba(0, 0, 0, 0.7)')
    overlayRect.setAttribute('mask', `url(#${this.uniqueId})`)

    svg.appendChild(overlayRect)
    this.$overlay.append(svg)

    $('body').append(this.$overlay)

    const updatePosition = () => {
      const viewportWidth = window.innerWidth
      const viewportHeight = window.innerHeight
      
      if (this.$overlay && this.$overlay.find('svg').length > 0 && this.uniqueId) {
        const svg = this.$overlay.find('svg')[0]
        svg.setAttribute('width', viewportWidth)
        svg.setAttribute('height', viewportHeight)
        
        const mask = svg.querySelector(`mask[id="${this.uniqueId}"]`)
        if (mask) {
          const cutouts = mask.querySelectorAll('rect')
          if (cutouts.length > 1) {
            const modalContent = document.querySelector('[data-tutorial-modal-content="true"]')
            if (modalContent) {
              const computedStyle = window.getComputedStyle(modalContent)
              const modalBorderRadius = parseFloat(computedStyle.borderRadius) || 8
              const modalRect = modalContent.getBoundingClientRect()
              if (modalRect.width > 0 && modalRect.height > 0) {
                const modalCutout = cutouts[1]
                modalCutout.setAttribute('x', Math.max(0, modalRect.left))
                modalCutout.setAttribute('y', Math.max(0, modalRect.top))
                modalCutout.setAttribute('width', Math.min(modalRect.width, viewportWidth))
                modalCutout.setAttribute('height', Math.min(modalRect.height, viewportHeight))
                modalCutout.setAttribute('rx', modalBorderRadius)
                modalCutout.setAttribute('ry', modalBorderRadius)
              }
            }
          }
        }
      }
    }

    $(window).on('resize.tutorial scroll.tutorial', updatePosition)
    this.updatePosition = updatePosition
    
    const observer = new MutationObserver(() => {
      updatePosition()
    })
    
    observer.observe(document.body, {
      childList: true,
      subtree: false,
      attributes: false
    })
    
    this.observer = observer
    
    setTimeout(() => {
      updatePosition()
    }, 100)
  }

  hideInstant() {
    if (this.$overlay) {
      this.$overlay.remove()
      this.$overlay = null
    }

    if (this.$highlight) {
      this.$highlight.remove()
      this.$highlight = null
    }

    if (this.$target) {
      this.$target.removeClass('tutorial-highlighted')
      this.$target.css({
        'z-index': this.originalZIndex || '',
        'position': this.originalPosition || '',
        'filter': '',
        'transition': '',
        'transform': ''
      })
      
      if (this.$target.hasClass('plugin-info-button')) {
        this.$target.css({
          'opacity': '',
          'visibility': '',
          'display': ''
        })
        
        const $parentPlugin = this.$target.closest('.plugin-list-item')
        if ($parentPlugin.length > 0) {
          $parentPlugin.removeClass('group')
        }
      }
    }

    $(window).off('resize.tutorial scroll.tutorial')
    this.updatePosition = null
    
    if (this.observer) {
      this.observer.disconnect()
      this.observer = null
    }
    
    const tutorialStyle = document.getElementById('tutorial-plugin-info-fix')
    if (tutorialStyle) {
      tutorialStyle.remove()
    }
    
    $('#pluginList li.plugin-list-item').removeClass('group')
  }

  hide() {
    if (this.$overlay) {
      this.$overlay.css('opacity', '0')
      setTimeout(() => {
        if (this.$overlay) {
          this.$overlay.remove()
        }
        this.$overlay = null
      }, 300)
    }

    if (this.$highlight) {
      this.$highlight.css('opacity', '0')
      setTimeout(() => {
        if (this.$highlight) {
          this.$highlight.remove()
        }
        this.$highlight = null
      }, 300)
    }

    if (this.$target) {
      this.$target.removeClass('tutorial-highlighted')
      this.$target.css({
        'z-index': this.originalZIndex || '',
        'position': this.originalPosition || '',
        'filter': '',
        'transition': '',
        'transform': ''
      })
      
      if (this.$target.hasClass('plugin-info-button')) {
        this.$target.css({
          'opacity': '',
          'visibility': '',
          'display': ''
        })
        
        const $parentPlugin = this.$target.closest('.plugin-list-item')
        if ($parentPlugin.length > 0) {
          $parentPlugin.removeClass('group')
        }
      }
    }

    $(window).off('resize.tutorial scroll.tutorial')
    this.updatePosition = null
    
    if (this.observer) {
      this.observer.disconnect()
      this.observer = null
    }
    
    const tutorialStyle = document.getElementById('tutorial-plugin-info-fix')
    if (tutorialStyle) {
      tutorialStyle.remove()
    }
    
    $('#pluginList li.plugin-list-item').removeClass('group')
  }
}

module.exports = TutorialOverlay
