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

    $allTabs.each(function() {
      const $tab = $(this);
      const currentTabDataId = $tab.data('tab');

      if (currentTabDataId === tabDataId) {
        $tab.addClass('active');
      } else {
        $tab.removeClass('active');
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

    try {
      const swfFiles = await ipcRenderer.invoke('get-swf-files');

      $dropdown.empty();

      swfFiles.forEach(file => {
        const sizeText = formatBytes(file.size);
        const optionText = `${file.displayName} (${sizeText})`;
        const option = new Option(optionText, file.filename);
        option.selected = file.filename === selectedFile;
        $dropdown.append(option);
      });

      $dropdown.val(selectedFile);
      if (!$dropdown.val()) $dropdown.val('v5.1.0.swf');
    } catch (error) {
      console.error('Error loading SWF files:', error);
      $dropdown.html(`
        <option value="v5.1.0.swf">v5.1.0 (latest)</option>
      `);
      $dropdown.val(selectedFile);
    }
  }

  async updateSwfFileInfo($modal, filename) {
    const $dropdown = $modal.find('#selectedSwfFile');
    
    try {
      const swfFiles = await ipcRenderer.invoke('get-swf-files');
      
      $dropdown.find('option').each(function() {
        const $option = $(this);
        if ($option.val() === filename) {
          const fileInfo = swfFiles.find(f => f.filename === filename);
          if (fileInfo) {
            const sizeText = formatBytes(fileInfo.size);
            $option.text(`${fileInfo.displayName} (${sizeText})`);
          }
        }
      });
    } catch (error) {
      console.error('Error updating SWF file info:', error);
    }
  }

  async refreshActiveSwfInfo($modal) {
    const $dropdown = $modal.find('#selectedSwfFile');
    
    try {
      const activeInfo = await ipcRenderer.invoke('get-active-swf-info');
      
      if (activeInfo && activeInfo.active) {
        const swfFiles = await ipcRenderer.invoke('get-swf-files');
        const fileInfo = swfFiles.find(f => f.filename === activeInfo.active);
        
        if (fileInfo) {
          $dropdown.find('option').each(function() {
            const $option = $(this);
            if ($option.val() === activeInfo.active) {
              const sizeText = formatBytes(activeInfo.size);
              $option.text(`${fileInfo.displayName} (${sizeText})`);
            }
          });
        }
      }
    } catch (error) {
      console.error('Error refreshing active SWF info:', error);
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

        if (sizes.byType) {
          const updateCacheTypeSize = (checkboxId, size) => {
            const $checkbox = $modal.find(`#${checkboxId}`);
            const $label = $checkbox.next('label') || $checkbox.closest('div').find('label');
            const $container = $checkbox.closest('div.flex');
            if ($container.length) {
              const existingSize = $container.find('.cache-size-badge');
              if (existingSize.length) {
                existingSize.text(formatBytes(size));
              } else {
                const $sizeBadge = $(`<span class="cache-size-badge text-xs text-highlight-yellow ml-2">${formatBytes(size)}</span>`);
                $label.after($sizeBadge);
              }
            }
          };

          if (sizes.byType.gameSession !== undefined) {
            updateCacheTypeSize('cacheGameSession', sizes.byType.gameSession);
          }
          if (sizes.byType.auth !== undefined) {
            updateCacheTypeSize('cacheAuth', sizes.byType.auth);
          }
          if (sizes.byType.plugins !== undefined) {
            updateCacheTypeSize('cachePlugins', sizes.byType.plugins);
          }
          if (sizes.byType.logs !== undefined) {
            updateCacheTypeSize('cacheLogs', sizes.byType.logs);
          }
          if (sizes.byType.temp !== undefined) {
            updateCacheTypeSize('cacheTemp', sizes.byType.temp);
          }
        }
      } else {
        $cacheSizeValue.text('Not available');
      }
    } catch (error) {
      console.error('Error loading cache size:', error);
      $cacheSizeValue.text('Error calculating');
    }
  }

  showConfirmationModal(title, message, confirmText = 'Confirm', cancelText = 'Cancel', options = {}) {
    return new Promise((resolve) => {
      let messageHtml = `<p class="text-sm text-gray-400 mb-4">${message}</p>`;
      
      if (options.totalSize !== undefined && options.totalSize > 0) {
        messageHtml += `<div class="bg-tertiary-bg/30 p-3 rounded mb-4 text-center">`;
        messageHtml += `<p class="text-sm font-medium text-text-primary">Total size to clear: <span class="text-highlight-yellow">${formatBytes(options.totalSize)}</span></p>`;
        messageHtml += `</div>`;
      }

      const $confirmModal = $(`
        <div class="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4 confirmation-modal">
          <div class="relative bg-secondary-bg rounded-lg shadow-xl max-w-md w-full">
            <div class="p-5">
              <div class="text-center mb-4">
                <i class="fas fa-exclamation-triangle text-red-500 text-4xl mb-4"></i>
                <h3 class="text-lg font-semibold text-text-primary mb-2">${title}</h3>
              </div>
              <div class="text-center mb-6">
                ${messageHtml}
              </div>
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

