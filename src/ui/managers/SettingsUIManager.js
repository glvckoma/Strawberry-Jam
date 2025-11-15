const $ = require('jquery');
const { ipcRenderer } = require('electron');
const { formatBytes } = require('../../utils/FormatUtils');
const ToastService = require('../services/ToastService');

class SettingsUIManager {
  constructor(app, toastService) {
    this.app = app;
    this.toastService = toastService || ToastService;
  }

  setActiveTab(tabDataId, $modalContext) {
    const $allTabs = $modalContext.find('.settings-tab');
    const $allContentPanes = $modalContext.find('.settings-tab-content');

    $allTabs.each(function() {
      const $tab = $(this);
      const $underline = $tab.find('.tab-underline');
      const currentTabDataId = $tab.data('tab');

      if (currentTabDataId === tabDataId) {
        $tab.addClass('active-tab text-text-primary').removeClass('text-sidebar-text');
        $underline.css({
          'background-color': 'var(--theme-primary)',
          'box-shadow': '0 0 6px 0 var(--theme-primary)',
          'transition': 'background-color 0.3s ease, box-shadow 0.3s ease'
        });
      } else {
        $tab.removeClass('active-tab text-text-primary').addClass('text-sidebar-text');
        $underline.css({
          'background-color': 'transparent',
          'box-shadow': 'none',
          'transition': 'background-color 0.3s ease, box-shadow 0.3s ease'
        });
      }
    });

    const $currentActive = $modalContext.find('.settings-tab-content:not(.hidden)');
    const $newActive = $modalContext.find('#' + tabDataId + 'TabContent');
    
    if ($currentActive.attr('id') === $newActive.attr('id')) {
      return;
    }

    if ($currentActive.length) {
      $currentActive.css({
        'opacity': '1',
        'transform': 'translateY(0)',
        'transition': 'opacity 0.2s ease-out, transform 0.2s ease-out'
      });
      
      setTimeout(() => {
        $currentActive.css({
          'opacity': '0',
          'transform': 'translateY(-10px)'
        });
        
        setTimeout(() => {
          $currentActive.addClass('hidden');
          
          $newActive.removeClass('hidden').css({
            'opacity': '0',
            'transform': 'translateY(10px)',
            'transition': 'opacity 0.2s ease-out, transform 0.2s ease-out'
          });
          
          setTimeout(() => {
            $newActive.css({
              'opacity': '1',
              'transform': 'translateY(0)'
            });
          }, 10);
        }, 200);
      }, 10);
    } else {
      $newActive.removeClass('hidden');
    }
  }

  async loadSwfFileSettings($modal, selectedFile) {
    const $dropdown = $modal.find('#selectedSwfFile');
    const $currentName = $modal.find('#currentSwfName');
    const $currentSize = $modal.find('#currentSwfSize');

    try {
      const swfFiles = await ipcRenderer.invoke('get-swf-files');

      $dropdown.empty();

      swfFiles.forEach(file => {
        const option = new Option(file.displayName, file.filename);
        option.selected = file.filename === selectedFile;
        $dropdown.append(option);
      });

      $dropdown.val(selectedFile);

      const currentFile = swfFiles.find(f => f.filename === selectedFile);
      if (currentFile) {
        $currentName.text(currentFile.filename);
        $currentSize.text(formatBytes(currentFile.size));
      } else {
        $currentName.text(selectedFile || 'N/A');
        $currentSize.text('Unknown');
      }
    } catch (error) {
      console.error('Error loading SWF files:', error);
      $dropdown.html(`
        <option value="ajclient-prod.swf">Production Client</option>
      `);
      $dropdown.val(selectedFile);
      $currentName.text(selectedFile);
      $currentSize.text('Error loading');
    }
  }

  async updateSwfFileInfo($modal, filename) {
    const $currentSize = $modal.find('#currentSwfSize');
    
    try {
      const swfFiles = await ipcRenderer.invoke('get-swf-files');
      const fileInfo = swfFiles.find(f => f.filename === filename);
      
      if (fileInfo) {
        $currentSize.text(formatBytes(fileInfo.size));
      } else {
        $currentSize.text('Unknown');
      }
    } catch (error) {
      console.error('Error updating SWF file info:', error);
      $currentSize.text('Error loading');
    }
  }

  async loadCacheSize($modal) {
    const $cacheSizeValue = $modal.find('#cacheSizeValue');
    const $cacheSizeDetails = $modal.find('#cacheSizeDetails');
    
    try {
      $cacheSizeValue.text('Calculating...');
      $cacheSizeDetails.addClass('hidden').empty();
      
      const sizes = await ipcRenderer.invoke('get-cache-size');
      
      if (sizes && sizes.total >= 0) {
        $cacheSizeValue.text(formatBytes(sizes.total));
        
        if (Object.keys(sizes.directories).length > 0) {
          const $detailsList = $('<ul class="space-y-1"></ul>');
          
          Object.entries(sizes.directories).forEach(([dir, size]) => {
            $detailsList.append(
              $(`<li class="flex justify-between">
                <span>${dir}:</span>
                <span>${formatBytes(size)}</span>
              </li>`)
            );
          });
          
          $cacheSizeDetails.html('<p class="font-medium mb-1">Cache breakdown:</p>').append($detailsList).removeClass('hidden');
        }
      } else {
        $cacheSizeValue.text('Not available');
      }
    } catch (error) {
      console.error('Error loading cache size:', error);
      $cacheSizeValue.text('Error calculating');
    }
  }

  showConfirmationModal(title, message, confirmText = 'Confirm', cancelText = 'Cancel') {
    return new Promise((resolve) => {
      const $confirmModal = $(`
        <div class="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4 confirmation-modal">
          <div class="relative bg-secondary-bg rounded-lg shadow-xl max-w-sm w-full">
            <div class="p-5 text-center">
              <i class="fas fa-exclamation-triangle text-red-500 text-4xl mb-4"></i>
              <h3 class="text-lg font-semibold text-text-primary mb-2">${title}</h3>
              <p class="text-sm text-gray-400 mb-6">${message}</p>
              <div class="flex justify-center gap-4">
                <button type="button" class="bg-gray-600 text-white px-4 py-2 rounded hover:bg-gray-700 transition" id="confirmCancelBtn">${cancelText}</button>
                <button type="button" class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition" id="confirmActionBtn">${confirmText}</button>
              </div>
            </div>
          </div>
        </div>
      `);

      $confirmModal.find('#confirmCancelBtn').on('click', () => {
        $confirmModal.remove();
        resolve(false);
      });

      $confirmModal.find('#confirmActionBtn').on('click', () => {
        $confirmModal.remove();
        resolve(true);
      });

      $('body').append($confirmModal);
    });
  }
}

module.exports = SettingsUIManager;

