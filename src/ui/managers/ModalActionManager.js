/**
 * ModalActionManager - Manages modal opening actions
 * 
 * @module ModalActionManager
 */
class ModalActionManager {
  constructor(application) {
    this.application = application
  }

  /**
   * Opens the settings modal
   * @public
   */
  openSettings() {
    this.application.modals.show('settings')
  }

  /**
   * Opens the Plugin Hub modal
   * @public
   */
  openPluginHub() {
    this.application.modals.show('pluginHub', '#modalContainer')
  }

  /**
   * Opens the Links modal
   * @public
   */
  openLinksModal() {
    this.application.modals.show('links', '#modalContainer')
  }

  /**
   * Opens the Report Problem modal
   * @public
   */
  openReportProblemModal() {
    this.application.modals.show('reportProblem')
  }

  /**
   * Initializes the hover styles for standardized modal close buttons
   * @public
   */
  initializeModalCloseButtonStyles() {
    $(document).on('mouseenter', '.modal-close-button-std', function () {
      $(this).css({
        'color': 'var(--theme-primary)',
        'background-color': 'rgba(232, 61, 82, 0.1)',
        'transform': 'scale(1.1)'
      })
    })

    $(document).on('mouseleave', '.modal-close-button-std', function () {
      $(this).css({
        'color': '',
        'background-color': '',
        'transform': ''
      })
    })
  }
}

module.exports = ModalActionManager

