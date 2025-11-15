const $ = require('jquery');

class ToastService {
  constructor() {
    this.globalColors = {
      success: 'bg-highlight-green text-white',
      error: 'bg-error-red text-white',
      warning: 'bg-highlight-yellow text-black',
      notify: 'bg-custom-blue text-white',
      checking: 'bg-gray-600 text-white',
      available: 'bg-blue-500 text-white',
      downloaded: 'bg-purple-500 text-white'
    };

    this.modalColors = {
      success: 'bg-highlight-green text-white',
      error: 'bg-red-500 text-white',
      warning: 'bg-yellow-500 text-black'
    };

    this.modalIcons = {
      success: 'fas fa-check-circle',
      error: 'fas fa-exclamation-circle',
      warning: 'fas fa-exclamation-triangle'
    };

    this.activeToasts = [];
    this.toastSpacing = -16;
    this.baseBottomGlobal = 120;
    this.baseBottomModal = 16;
  }

  _calculateBottomPosition(toastIndex, isGlobal = true) {
    const baseBottom = isGlobal ? this.baseBottomGlobal : this.baseBottomModal;
    return baseBottom + (toastIndex * (this._getToastHeight() + this.toastSpacing));
  }

  _getToastHeight() {
    return 56;
  }

  _repositionToasts(isGlobal = true) {
    const filteredToasts = this.activeToasts.filter(t => t.isGlobal === isGlobal);
    filteredToasts.forEach((toastData, index) => {
      const $toast = $(`#${toastData.id}`);
      if ($toast.length) {
        const newBottom = this._calculateBottomPosition(index, isGlobal);
        $toast.css('bottom', `${newBottom}px`);
      }
    });
  }

  _addCloseButton($toast, toastData) {
    const $closeBtn = $('<button style="position: absolute; top: 4px; right: 4px; width: 20px; height: 20px; display: flex; align-items: center; justify-content: center; color: white; opacity: 0.7; cursor: pointer; background: transparent; border: none; padding: 0; font-size: 18px; line-height: 1; font-weight: bold;">×</button>');
    $closeBtn.on('mouseenter', function() {
      $(this).css('opacity', '1');
    });
    $closeBtn.on('mouseleave', function() {
      $(this).css('opacity', '0.7');
    });
    $closeBtn.on('click', (e) => {
      e.stopPropagation();
      this._removeToast(toastData.id, toastData.isGlobal);
    });
    $toast.append($closeBtn);
  }

  _removeToast(toastId, isGlobal) {
    const $toast = $(`#${toastId}`);
    if ($toast.length) {
      const toastIndex = this.activeToasts.findIndex(t => t.id === toastId);
      if (toastIndex !== -1) {
        const toastData = this.activeToasts[toastIndex];
        if (toastData.timeoutId) {
          clearTimeout(toastData.timeoutId);
        }
        this.activeToasts.splice(toastIndex, 1);
      }
      
      $toast.animate({ opacity: 0, transform: 'translateY(20px)' }, 300, () => {
        $toast.remove();
        this._repositionToasts(isGlobal);
      });
    }
  }

  showGlobal(message, type = 'success', duration = 7000) {
    const colors = this.globalColors;
    const toastId = `global-toast-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    const existingGlobalToasts = this.activeToasts.filter(t => t.isGlobal);
    existingGlobalToasts.forEach((toastData, index) => {
      const $toast = $(`#${toastData.id}`);
      if ($toast.length) {
        const newBottom = this._calculateBottomPosition(index + 1, true);
        $toast.css('bottom', `${newBottom}px`);
      }
    });
    
    const bottomPosition = this._calculateBottomPosition(0, true);
    const toast = $(`
      <div id="${toastId}" class="pl-6 pr-12 py-3 rounded-lg shadow-xl text-sm font-medium ${colors[type] || colors.notify}">
        ${message}
      </div>
    `);
    
    toast.css({
      'position': 'fixed',
      'bottom': `${bottomPosition}px`,
      'right': '1rem',
      'z-index': '999999',
      'opacity': '0',
      'transform': 'translateY(20px)'
    });

    const toastData = {
      id: toastId,
      isGlobal: true,
      timeoutId: null
    };
    this.activeToasts.unshift(toastData);
    this._addCloseButton(toast, toastData);
    
    $('body').append(toast);

    toast.animate({ opacity: 1, transform: 'translateY(0)' }, 300);

    const timeoutId = setTimeout(() => {
      this._removeToast(toastId, true);
    }, duration);
    toastData.timeoutId = timeoutId;
  }

  showInModal($modal, message, type = 'success', duration = 3000, useEnhancedAnimation = false) {
    if (useEnhancedAnimation) {
      return this._showEnhancedModalToast($modal, message, type, duration);
    }

    const colors = this.modalColors;
    const toastId = `modal-toast-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    const existingModalToasts = this.activeToasts.filter(t => !t.isGlobal);
    existingModalToasts.forEach((toastData, index) => {
      const $toast = $(`#${toastData.id}`);
      if ($toast.length) {
        const newBottom = this._calculateBottomPosition(index + 1, false);
        $toast.css('bottom', `${newBottom}px`);
      }
    });
    
    const bottomPosition = this._calculateBottomPosition(0, false);
    const toast = $(`<div id="${toastId}" class="py-2 rounded shadow-lg text-sm font-medium ${colors[type]}">${message}</div>`);
    toast.css({
      'position': 'fixed',
      'bottom': `${bottomPosition}px`,
      'right': '1rem',
      'z-index': '999999',
      'padding-left': '20px',
      'padding-right': '36px'
    });

    const toastData = {
      id: toastId,
      isGlobal: false,
      timeoutId: null
    };
    this.activeToasts.unshift(toastData);
    this._addCloseButton(toast, toastData);
    
    $('body').append(toast);

    const timeoutId = setTimeout(() => {
      this._removeToast(toastId, false);
    }, duration);
    toastData.timeoutId = timeoutId;
  }

  _showEnhancedModalToast($modal, message, type, duration) {
    const colors = this.modalColors;
    const icons = this.modalIcons;
    const toastId = `updates-toast-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    const existingModalToasts = this.activeToasts.filter(t => !t.isGlobal);
    existingModalToasts.forEach((toastData, index) => {
      const $toast = $(`#${toastData.id}`);
      if ($toast.length) {
        const newBottom = this._calculateBottomPosition(index + 1, false);
        $toast.css('bottom', `${newBottom}px`);
      }
    });
    
    const bottomPosition = this._calculateBottomPosition(0, false);
    const toast = $(`
      <div id="${toastId}" class="py-2 rounded-lg shadow-xl text-sm font-medium ${colors[type] || colors.success}">
        <i class="${icons[type]} mr-2"></i>${message}
      </div>
    `);
    
    toast.css({
      'position': 'fixed',
      'bottom': `${bottomPosition}px`,
      'right': '1rem',
      'z-index': '999999',
      'opacity': '0',
      'transform': 'translateY(20px) scale(0.9)',
      'filter': 'blur(2px)',
      'transition': 'opacity 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94), transform 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94), filter 0.2s ease-out',
      'padding-left': '20px',
      'padding-right': '36px'
    });

    const toastData = {
      id: toastId,
      isGlobal: false,
      timeoutId: null
    };
    this.activeToasts.unshift(toastData);
    this._addCloseButton(toast, toastData);
    
    $('body').append(toast);
    
    setTimeout(() => {
      toast.css({
        'opacity': '1',
        'transform': 'translateY(0px) scale(1)',
        'filter': 'blur(0px)',
        'z-index': '999999'
      });
    }, 10);

    const timeoutId = setTimeout(() => {
      this._removeToast(toastId, false);
    }, duration);
    toastData.timeoutId = timeoutId;
  }

  show(message, type = 'success', options = {}) {
    const {
      position = 'global',
      duration = position === 'global' ? 7000 : 3000,
      $modal = null,
      useEnhancedAnimation = false
    } = options;

    if (position === 'global') {
      return this.showGlobal(message, type, duration);
    } else if (position === 'modal' && $modal) {
      return this.showInModal($modal, message, type, duration, useEnhancedAnimation);
    } else {
      return this.showGlobal(message, type, duration);
    }
  }
}

module.exports = new ToastService();

