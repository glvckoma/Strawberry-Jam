/**
 * @file confirmExitModal.js - Modal for confirming application exit.
 */

const { ipcRenderer } = require('electron');

// Define isDevelopment for environment checks
const isDevelopment = process.env.NODE_ENV === 'development';

// Helper: Only log in development
function devLog(...args) {
  if (isDevelopment) console.log(...args);
}

module.exports = {
  name: 'confirmExitModal',

  /**
   * Renders the confirm exit modal.
   * @param {Application} application - The application instance.
   * @param {Object} data - Optional data (not used here).
   * @returns {JQuery<HTMLElement>} - The rendered modal element.
   */
  render (application, data = {}) {
    devLog('[ConfirmExitModal] Rendering modal...');

    // Create the modal content
    const $modal = $(`
      <div class="flex items-center justify-center min-h-screen p-4" style="z-index: 9999;">
        <!-- Modal Backdrop -->
        <div class="fixed inset-0 bg-black bg-opacity-70 backdrop-blur-sm transition-opacity" id="modalBackdrop" style="z-index: 9000;"></div>
        
        <!-- Modal Content -->
        <div class="relative bg-secondary-bg rounded-lg shadow-xl max-w-md w-full" style="z-index: 9100;">
          <!-- Modal Header -->
          <div class="flex items-center justify-between p-4 border-b border-sidebar-border">
            <h3 class="text-lg font-semibold text-text-primary">
              <i class="fas fa-sign-out-alt text-error-red mr-2"></i>
              Exit Application
            </h3>
          </div>
          
          <!-- Modal Body -->
          <div class="p-5">
            <p class="text-text-primary mb-5">
              Are you sure you want to exit Strawberry Jam?
            </p>
            
            <div class="flex items-center mb-1 select-none cursor-pointer" id="dontAskAgainContainer">
              <input type="checkbox" id="dontAskAgain" class="mr-2 cursor-pointer">
              <label for="dontAskAgain" class="text-sm text-gray-400 cursor-pointer">Don't ask me again</label>
            </div>
          </div>
          
          <!-- Modal Footer -->
          <div class="flex items-center justify-end p-4 border-t border-sidebar-border space-x-3">
            <button type="button" class="text-text-primary bg-tertiary-bg hover:bg-sidebar-hover transition px-4 py-2 rounded text-sm" id="cancelExitBtn">
              Cancel
            </button>
            <button type="button" class="text-white bg-error-red hover:bg-error-red/90 transition px-4 py-2 rounded text-sm" id="confirmExitBtn">
              Yes, Exit
            </button>
          </div>
        </div>
      </div>
    `);

    // Add entrance animation
    $modal.find('.relative').css({
      'opacity': '0',
      'transform': 'scale(0.95)'
    });

    setTimeout(() => {
      $modal.find('.relative').css({
        'opacity': '1',
        'transform': 'scale(1)',
        'transition': 'opacity 0.25s ease-out, transform 0.25s ease-out'
      });
      
      // Animate backdrop
      $modal.find('#modalBackdrop').css({
        'opacity': '0'
      }).animate({
        'opacity': '1'
      }, 200);
    }, 10);

    // Make checkbox toggle when clicking the label container
    $modal.find('#dontAskAgainContainer').on('click', function(e) {
      if (e.target !== $modal.find('#dontAskAgain')[0]) {
        const $checkbox = $modal.find('#dontAskAgain')
        $checkbox.prop('checked', !$checkbox.prop('checked'))
      }
    });

    // Cancel exit
    $modal.find('#cancelExitBtn').on('click', function() {
      const dontAskAgain = $modal.find('#dontAskAgain').prop('checked')
      
      // Add exit animation
      $modal.find('.relative').css({
        'opacity': '1',
        'transform': 'scale(1)',
        'transition': 'opacity 0.2s ease-in-out, transform 0.2s ease-in-out'
      }).animate({
        'opacity': '0',
        'transform': 'scale(0.95)'
      }, {
        duration: 200,
        step: function(now, fx) {
          if (fx.prop === 'transform') {
            $(this).css('transform', `scale(${now})`);
          }
        },
        complete: function() {
          // Send the response to main process
          ipcRenderer.send('exit-confirmation-response', {
            confirmed: false,
            dontAskAgain
          });
          
          // Close the modal
          application.modals.close();
        }
      });
      
      // Fade out backdrop
      $modal.find('#modalBackdrop').animate({
        'opacity': '0'
      }, 200);
    });

    // Confirm exit
    $modal.find('#confirmExitBtn').on('click', function() {
      const dontAskAgain = $modal.find('#dontAskAgain').prop('checked')
      
      // Add exit animation before confirming
      $modal.find('.relative').css({
        'opacity': '1',
        'transform': 'scale(1)',
        'transition': 'opacity 0.2s ease-in-out, transform 0.2s ease-in-out'
      }).animate({
        'opacity': '0',
        'transform': 'scale(0.95)'
      }, {
        duration: 200,
        step: function(now, fx) {
          if (fx.prop === 'transform') {
            $(this).css('transform', `scale(${now})`);
          }
        },
        complete: function() {
          // Send the response to main process
          ipcRenderer.send('exit-confirmation-response', {
            confirmed: true,
            dontAskAgain
          });
        }
      });
      
      // Fade out backdrop
      $modal.find('#modalBackdrop').animate({
        'opacity': '0'
      }, 200);
    });

    // Also handle clicks on the backdrop
    $modal.find('#modalBackdrop').on('click', function() {
      // Treat backdrop click as cancel
      $modal.find('#cancelExitBtn').click();
    });

    return $modal;
  },

  // Optional: Add a close handler if needed for specific cleanup
  close (application) {
    devLog('[ConfirmExitModal] Close handler called (optional).');
    // Perform any cleanup specific to this modal if necessary
  }
};
