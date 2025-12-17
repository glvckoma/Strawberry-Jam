const $ = require('jquery')

module.exports = {
  name: 'tutorial',

  async render(application, data = {}) {
    const { step, stepNumber, totalSteps, onNext, onPrevious, onSkip, onFinish } = data

    if (!step) {
      console.error('[TutorialModal] No step data provided')
      return null
    }

    const isFirstStep = stepNumber === 1
    const isLastStep = stepNumber === totalSteps
    const themeColor = getComputedStyle(document.documentElement).getPropertyValue('--theme-primary').trim() || '#e83d52'

    const style = document.createElement('style')
    style.id = 'tutorial-modal-style'
    style.textContent = `
      [data-tutorial-modal="true"],
      [data-tutorial-modal-content="true"] {
        filter: none !important;
        backdrop-filter: none !important;
        opacity: 1 !important;
        visibility: visible !important;
      }
    `
    if (!document.getElementById('tutorial-modal-style')) {
      document.head.appendChild(style)
    }

    const $modal = $(`
      <div class="flex items-center justify-center min-h-screen p-4" style="z-index: 10010; position: relative;" data-tutorial-modal="true">
        <div class="relative bg-secondary-bg rounded-lg shadow-xl max-w-lg w-full" style="z-index: 10012; position: relative;" data-tutorial-modal-content="true">
          <div class="p-6">
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-xl font-semibold text-text-primary flex items-center">
                <i class="fas fa-graduation-cap mr-2" style="color: ${themeColor};"></i>
                ${step.title}
              </h3>
              ${step.skipButtonText ? `<button type="button" class="text-gray-400 hover:text-text-primary transition text-sm" id="tutorialSkipBtn">${step.skipButtonText}</button>` : ''}
            </div>
            
            <div class="mb-4">
              <div class="flex items-center justify-between mb-2">
                <span class="text-xs text-gray-400">Step ${stepNumber} of ${totalSteps}</span>
              </div>
              <div class="w-full bg-tertiary-bg rounded-full h-2">
                <div class="h-2 rounded-full transition-all duration-300" style="width: ${(stepNumber / totalSteps) * 100}%; background-color: ${themeColor};"></div>
              </div>
            </div>
            
            <div class="mb-6">
              <p class="text-text-primary leading-relaxed">${step.description}</p>
            </div>
            
            <div class="flex items-center justify-between">
              <div>
                ${!isFirstStep ? `<button type="button" class="text-text-primary bg-tertiary-bg hover:bg-sidebar-hover transition px-4 py-2 rounded text-sm" id="tutorialPrevBtn">
                  <i class="fas fa-arrow-left mr-1"></i> Previous
                </button>` : ''}
              </div>
              <div class="flex items-center space-x-2">
                ${isLastStep ? `
                  <button type="button" class="text-white transition px-6 py-2 rounded text-sm font-medium" id="tutorialFinishBtn" style="background-color: ${themeColor};">
                    Finish
                  </button>
                ` : `
                  <button type="button" class="text-white transition px-6 py-2 rounded text-sm font-medium" id="tutorialNextBtn" style="background-color: ${themeColor};">
                    ${step.nextButtonText || 'Next'} <i class="fas fa-arrow-right ml-1"></i>
                  </button>
                `}
              </div>
            </div>
          </div>
        </div>
      </div>
    `)

    $modal.find('.relative').css({
      'opacity': '0',
      'transform': 'scale(0.95)'
    })

    setTimeout(() => {
      $modal.find('.relative').css({
        'opacity': '1',
        'transform': 'scale(1)',
        'transition': 'opacity 0.25s ease-out, transform 0.25s ease-out'
      })
      
    }, 10)

    $modal.find('#tutorialNextBtn').on('click', () => {
      if (onNext) onNext()
    })

    $modal.find('#tutorialPrevBtn').on('click', () => {
      if (onPrevious) onPrevious()
    })

    $modal.find('#tutorialSkipBtn').on('click', () => {
      if (onSkip) onSkip()
    })

    $modal.find('#tutorialFinishBtn').on('click', () => {
      if (onFinish) onFinish()
    })


    $(document).on('keydown.tutorial', (e) => {
      if (e.key === 'Escape') {
        if (onSkip) onSkip()
        $(document).off('keydown.tutorial')
      } else if (e.key === 'ArrowLeft' && !isFirstStep) {
        if (onPrevious) onPrevious()
      } else if (e.key === 'ArrowRight' && !isLastStep) {
        if (onNext) onNext()
      } else if (e.key === 'Enter' && !isLastStep) {
        if (onNext) onNext()
      } else if (e.key === 'Enter' && isLastStep) {
        if (onFinish) onFinish()
      }
    })

    return $modal
  },

  close(application) {
    $(document).off('keydown.tutorial')
    const tutorialStyle = document.getElementById('tutorial-modal-style')
    if (tutorialStyle) {
      tutorialStyle.remove()
    }
  }
}
