const { ipcRenderer } = require('electron')

class TutorialManager {
  constructor(application) {
    this.application = application
    this.currentStepIndex = 0
    this.steps = []
    this.isActive = false
    this.overlay = null
  }

  async initialize() {
    try {
      const tutorialSteps = require('../../data/tutorial-steps.json')
      this.steps = tutorialSteps
      
      if (!this.application || !this.application.settings || !this.application.settings._isLoaded) {
        let attempts = 0
        while ((!this.application || !this.application.settings || !this.application.settings._isLoaded) && attempts < 50) {
          await new Promise(resolve => setTimeout(resolve, 100))
          attempts++
        }
      }
      
      const completed = await this.isTutorialCompleted()
      if (!completed && this.steps.length > 0) {
        const shouldShow = await this.shouldShowTutorial()
        if (shouldShow) {
          setTimeout(() => {
            this.startTutorial()
          }, 1500)
        }
      }
    } catch (error) {
      console.error('[TutorialManager] Error initializing:', error)
    }
  }

  async shouldShowTutorial() {
    try {
      if (this.application && this.application.settings && this.application.settings._isLoaded) {
        const showTutorial = this.application.settings.get('ui.showTutorialOnFirstLaunch', true)
        return showTutorial !== false
      }
      return true
    } catch (error) {
      console.error('[TutorialManager] Error checking tutorial preference:', error)
      return true
    }
  }

  async isTutorialCompleted() {
    try {
      if (this.application && this.application.settings && this.application.settings._isLoaded) {
        const completed = this.application.settings.get('ui.tutorialCompleted', false)
        return completed === true
      }
      return false
    } catch (error) {
      console.error('[TutorialManager] Error checking tutorial completion:', error)
      return false
    }
  }

  async markTutorialCompleted() {
    try {
      if (this.application && this.application.settings && this.application.settings._isLoaded) {
        this.application.settings.update('ui.tutorialCompleted', true)
        this.application.settings.update('ui.showTutorialOnFirstLaunch', false)
        if (typeof this.application.settings.flush === 'function') {
          await this.application.settings.flush()
        }
      } else {
        console.warn('[TutorialManager] Settings not loaded, cannot mark tutorial as completed')
      }
    } catch (error) {
      console.error('[TutorialManager] Error marking tutorial as completed:', error)
    }
  }

  async resetTutorial() {
    try {
      if (this.application && this.application.settings && this.application.settings._isLoaded) {
        this.application.settings.update('ui.tutorialCompleted', false)
        this.application.settings.update('ui.showTutorialOnFirstLaunch', true)
        if (typeof this.application.settings.flush === 'function') {
          await this.application.settings.flush()
        }
      }
      this.currentStepIndex = 0
    } catch (error) {
      console.error('[TutorialManager] Error resetting tutorial:', error)
    }
  }

  async startTutorial() {
    if (this.steps.length === 0) {
      console.warn('[TutorialManager] No tutorial steps available')
      return
    }

    this.isActive = true
    this.currentStepIndex = 0
    await this.showCurrentStep()
  }

  getCurrentStep() {
    if (this.currentStepIndex >= 0 && this.currentStepIndex < this.steps.length) {
      return this.steps[this.currentStepIndex]
    }
    return null
  }

  async nextStep() {
    if (this.currentStepIndex < this.steps.length - 1) {
      this.currentStepIndex++
      await this.showCurrentStep()
    } else {
      await this.completeTutorial()
    }
  }

  async previousStep() {
    if (this.currentStepIndex > 0) {
      this.currentStepIndex--
      await this.showCurrentStep()
    }
  }

  async skipTutorial() {
    await this.markTutorialCompleted()
    this.isActive = false
    this.removeHighlight()
    if (this.application && this.application.modals) {
      this.application.modals.close()
    }
  }

  async completeTutorial() {
    await this.markTutorialCompleted()
    this.isActive = false
    this.removeHighlight()
    if (this.application && this.application.modals) {
      this.application.modals.close()
    }
    
    if (this.application && this.application.consoleMessage) {
      this.application.consoleMessage({
        type: 'success',
        message: 'Tutorial completed! Use Settings to restart it anytime.'
      })
    }
  }

  async showCurrentStep() {
    const step = this.getCurrentStep()
    if (!step) return

    const previousOverlay = this.overlay
    
    if (this.application && this.application.modals) {
      await this.application.modals.show('tutorial', '#modalContainer', {
        step: step,
        stepNumber: this.currentStepIndex + 1,
        totalSteps: this.steps.length,
        onNext: () => this.nextStep(),
        onPrevious: () => this.previousStep(),
        onSkip: () => this.skipTutorial(),
        onFinish: () => this.completeTutorial()
      })
    }

    if (step.showOverlay) {
      if (step.targetSelector) {
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            this.highlightElement(step.targetSelector, step.position)
            if (previousOverlay) {
              previousOverlay.hideInstant()
            }
          })
        })
      } else {
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            this.showOverlayOnly()
            if (previousOverlay) {
              previousOverlay.hideInstant()
            }
          })
        })
      }
    } else {
      this.removeHighlight()
    }
  }

  highlightElement(selector, position = 'bottom') {
    this.removeHighlight()

    let $target = $(selector)
    
    if (selector === '.plugin-info-button') {
      const $firstPlugin = $('#pluginList li.plugin-list-item').first()
      if ($firstPlugin.length > 0) {
        $firstPlugin.addClass('group')
        const $infoButton = $firstPlugin.find('.plugin-info-button')
        if ($infoButton.length > 0) {
          const style = document.createElement('style')
          style.id = 'tutorial-plugin-info-fix'
          style.textContent = `
            .plugin-list-item.group .plugin-info-button {
              opacity: 1 !important;
              visibility: visible !important;
              display: block !important;
              pointer-events: auto !important;
            }
          `
          if (!document.getElementById('tutorial-plugin-info-fix')) {
            document.head.appendChild(style)
          }
          
          $target = $infoButton
          $target.css({
            'opacity': '1',
            'visibility': 'visible',
            'display': 'block'
          })
          
          setTimeout(() => {
            const rect = $target[0].getBoundingClientRect()
            if (rect.width === 0 || rect.height === 0) {
              console.warn('[TutorialManager] Plugin info button still has zero dimensions, falling back to plugin item')
              this._createOverlay($firstPlugin, position)
            } else {
              this._createOverlay($target, position)
            }
          }, 150)
          return
        } else {
          console.warn('[TutorialManager] Plugin info button not found in first plugin, using plugin item instead')
          $target = $firstPlugin
        }
      } else {
        console.warn('[TutorialManager] No plugins found, skipping plugin info highlight')
        return
      }
    }
    
    if ($target.length === 0) {
      console.warn(`[TutorialManager] Target element not found: ${selector}`)
      return
    }

    this._createOverlay($target, position)
  }

  _createOverlay($target, position) {
    if ($target.hasClass('plugin-info-button')) {
      $target.css({
        'opacity': '1',
        'visibility': 'visible',
        'display': 'block'
      })
      
      const parentPlugin = $target.closest('.plugin-list-item')
      if (parentPlugin.length > 0) {
        parentPlugin.addClass('group')
      }
    }
    
    const rect = $target[0].getBoundingClientRect()
    if (rect.width === 0 || rect.height === 0) {
      console.warn(`[TutorialManager] Target element has zero dimensions`)
      if ($target.hasClass('plugin-info-button')) {
        setTimeout(() => {
          const retryRect = $target[0].getBoundingClientRect()
          if (retryRect.width > 0 && retryRect.height > 0) {
            const TutorialOverlay = require('../components/TutorialOverlay')
            this.overlay = new TutorialOverlay($target, position)
            this.overlay.show()
          } else {
            const $firstPlugin = $('#pluginList li.plugin-list-item').first()
            if ($firstPlugin.length > 0) {
              const TutorialOverlay = require('../components/TutorialOverlay')
              this.overlay = new TutorialOverlay($firstPlugin, position)
              this.overlay.show()
            }
          }
        }, 200)
      }
      return
    }

    const computedStyle = window.getComputedStyle($target[0])
    if (computedStyle.display === 'none') {
      $target.css('display', 'block')
    }
    
    if (computedStyle.visibility === 'hidden') {
      $target.css('visibility', 'visible')
    }
    
    if (parseFloat(computedStyle.opacity) === 0 && !$target.hasClass('plugin-info-button')) {
      $target.css('opacity', '1')
    }

    const TutorialOverlay = require('../components/TutorialOverlay')
    this.overlay = new TutorialOverlay($target, position)
    this.overlay.show()
  }

  showOverlayOnly() {
    this.removeHighlight()
    
    const TutorialOverlay = require('../components/TutorialOverlay')
    const $dummy = $('<div>').css({ position: 'fixed', width: '1px', height: '1px', opacity: 0, pointerEvents: 'none' })
    $('body').append($dummy)
    
    this.overlay = new TutorialOverlay($dummy, 'center')
    this.overlay.showOverlayOnly = true
    this.overlay.show()
    
    setTimeout(() => {
      $dummy.remove()
    }, 100)
  }

  removeHighlight() {
    if (this.overlay) {
      this.overlay.hide()
      this.overlay = null
    }
  }
}

module.exports = TutorialManager
