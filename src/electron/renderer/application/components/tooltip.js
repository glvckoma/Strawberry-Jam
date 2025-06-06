const $ = require('jquery');

/**
 * Tooltip Component
 * A lightweight, customizable tooltip system for Strawberry Jam
 * Features:
 * - Smart positioning (auto adjusts to viewport boundaries)
 * - Consistent animations
 * - Theme support matching UI colors
 * - Automatic cleanup
 */
class Tooltip {
  constructor(options = {}) {
    this.options = Object.assign({
      position: 'top', // top, right, bottom, left
      theme: 'default', // default, info, success, warning, error
      animationDuration: 200, // ms
      showDelay: 200, // ms before showing tooltip
      hideDelay: 100, // ms before hiding tooltip
      maxWidth: 200, // px
      offsetX: 0, // additional x offset
      offsetY: 0, // additional y offset
      allowHtml: false, // if true, content can contain HTML
      zIndex: 100, // z-index for the tooltip
      followCursor: false, // if true, tooltip follows cursor
      boundary: 10 // distance to maintain from viewport edges
    }, options);

    this.activeTooltips = new Map();
    this.tooltipId = 0;
    this.initialized = false;
  }

  /**
   * Initialize tooltip functionality
   * @param {Object} application - Application context
   * @returns {Tooltip} - This instance for chaining
   */
  init(application) {
    if (this.initialized) return this;
    this.application = application;
    
    // Add global stylesheet for tooltips if not already added
    if (!$('#tooltip-styles').length) {
      const tooltipStyles = `
        .sj-tooltip {
          position: absolute;
          background-color: var(--primary-bg, #1a1a1a);
          color: var(--text-primary, #e0e0e0);
          border: 1px solid var(--sidebar-border, #333);
          border-radius: 0.375rem;
          padding: 0.5rem 0.75rem;
          font-size: 0.75rem;
          line-height: 1.25;
          pointer-events: none;
          opacity: 0;
          transition-property: opacity, transform;
          box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
          max-width: 200px;
          word-wrap: break-word;
          z-index: 9999;
        }
        
        .sj-tooltip-arrow {
          position: absolute;
          width: 0;
          height: 0;
          border-style: solid;
          border-color: transparent;
        }
        
        /* Theme variants */
        .sj-tooltip-default {
          background-color: var(--primary-bg, #1a1a1a);
          border-color: var(--sidebar-border, #333);
        }
        
        .sj-tooltip-info {
          background-color: var(--highlight-blue, #3b82f6);
          border-color: var(--highlight-blue, #3b82f6);
          color: white;
        }
        
        .sj-tooltip-success {
          background-color: var(--highlight-green, #10b981);
          border-color: var(--highlight-green, #10b981);
          color: white;
        }
        
        .sj-tooltip-warning {
          background-color: var(--highlight-amber, #f59e0b);
          border-color: var(--highlight-amber, #f59e0b);
          color: white;
        }
        
        .sj-tooltip-error {
          background-color: var(--highlight-red, #ef4444);
          border-color: var(--highlight-red, #ef4444);
          color: white;
        }
      `;
      
      $('<style>', {
        id: 'tooltip-styles',
        html: tooltipStyles
      }).appendTo('head');
    }
    
    // Handle global document events
    $(document).on('mouseenter', '[data-tooltip]', this._handleMouseEnter.bind(this));
    $(document).on('mouseleave', '[data-tooltip]', this._handleMouseLeave.bind(this));
    $(document).on('mousemove', '[data-tooltip][data-tooltip-follow="true"]', this._handleMouseMove.bind(this));
    
    // Clean up on page changes or application unload
    $(window).on('beforeunload', this.destroy.bind(this));
    
    this.initialized = true;
    return this;
  }
  
  /**
   * Create a tooltip for an element
   * @param {HTMLElement|jQuery} element - Target element
   * @param {string} content - Tooltip content
   * @param {Object} options - Tooltip options
   * @returns {string} - Generated tooltip ID
   */
  create(element, content, options = {}) {
    const $element = $(element);
    
    if (!$element.length) return null;
    
    // Remove any existing title attribute to prevent native browser tooltips
    if ($element.attr('title')) {
      // Store the original title in case we need it later
      $element.data('original-title', $element.attr('title'));
      $element.removeAttr('title');
    }
    
    // Set tooltip attributes
    $element.attr('data-tooltip', content);
    
    // Set custom position if provided
    if (options.position) {
      $element.attr('data-tooltip-position', options.position);
    }
    
    // Set theme if provided
    if (options.theme) {
      $element.attr('data-tooltip-theme', options.theme);
    }
    
    // Set follow cursor option if provided
    if (options.followCursor) {
      $element.attr('data-tooltip-follow', 'true');
    }
    
    return $element[0];
  }
  
  /**
   * Update tooltip content/options for an element
   * @param {HTMLElement|jQuery} element - Target element
   * @param {string} content - New tooltip content
   * @param {Object} options - Updated tooltip options
   */
  update(element, content, options = {}) {
    const $element = $(element);
    
    if (!$element.length) return;
    
    // Update content if provided
    if (content !== undefined) {
      $element.attr('data-tooltip', content);
    }
    
    // Update position if provided
    if (options.position) {
      $element.attr('data-tooltip-position', options.position);
    }
    
    // Update theme if provided
    if (options.theme) {
      $element.attr('data-tooltip-theme', options.theme);
    }
    
    // Update follow cursor option if provided
    if (options.followCursor !== undefined) {
      if (options.followCursor) {
        $element.attr('data-tooltip-follow', 'true');
      } else {
        $element.removeAttr('data-tooltip-follow');
      }
    }
    
    // If tooltip is currently shown, update it
    const tooltipId = $element.data('tooltip-id');
    if (tooltipId && this.activeTooltips.has(tooltipId)) {
      const tooltipData = this.activeTooltips.get(tooltipId);
      if (content !== undefined) {
        tooltipData.$tooltip.find('.sj-tooltip-content').html(
          this._getContentHtml(content, $element.attr('data-tooltip-html') === 'true')
        );
      }
      this._positionTooltip(tooltipData.$element, tooltipData.$tooltip);
    }
  }
  
  /**
   * Remove tooltip functionality from an element
   * @param {HTMLElement|jQuery} element - Target element
   */
  remove(element) {
    const $element = $(element);
    
    if (!$element.length) return;
    
    // Get tooltip ID if exists
    const tooltipId = $element.data('tooltip-id');
    
    // Remove from active tooltips
    if (tooltipId && this.activeTooltips.has(tooltipId)) {
      const tooltipData = this.activeTooltips.get(tooltipId);
      this._hideTooltip(tooltipData.$tooltip);
      this.activeTooltips.delete(tooltipId);
    }
    
    // Remove tooltip attributes
    $element.removeAttr('data-tooltip');
    $element.removeAttr('data-tooltip-position');
    $element.removeAttr('data-tooltip-theme');
    $element.removeAttr('data-tooltip-follow');
    $element.removeData('tooltip-id');
    $element.removeData('tooltip-timeout');
  }
  
  /**
   * Show tooltip for an element immediately
   * @param {HTMLElement|jQuery} element - Target element
   */
  show(element) {
    const $element = $(element);
    
    if (!$element.length) return;
    
    // Clear any pending show/hide
    const timeout = $element.data('tooltip-timeout');
    if (timeout) {
      clearTimeout(timeout);
      $element.removeData('tooltip-timeout');
    }
    
    this._showTooltip($element);
  }
  
  /**
   * Hide tooltip for an element immediately
   * @param {HTMLElement|jQuery} element - Target element
   */
  hide(element) {
    const $element = $(element);
    
    if (!$element.length) return;
    
    // Clear any pending show/hide
    const timeout = $element.data('tooltip-timeout');
    if (timeout) {
      clearTimeout(timeout);
      $element.removeData('tooltip-timeout');
    }
    
    // Get tooltip ID if exists
    const tooltipId = $element.data('tooltip-id');
    
    // Hide tooltip
    if (tooltipId && this.activeTooltips.has(tooltipId)) {
      const tooltipData = this.activeTooltips.get(tooltipId);
      this._hideTooltip(tooltipData.$tooltip);
    }
  }
  
  /**
   * Handle mouse enter event
   * @private
   * @param {Event} e - Mouse event
   */
  _handleMouseEnter(e) {
    const $element = $(e.currentTarget);
    const content = $element.attr('data-tooltip');
    
    if (!content) return;
    
    // Clear any existing timeout
    const timeout = $element.data('tooltip-timeout');
    if (timeout) {
      clearTimeout(timeout);
    }
    
    // Set timeout for showing tooltip
    const showDelay = parseInt($element.attr('data-tooltip-delay') || this.options.showDelay);
    const showTimeout = setTimeout(() => {
      this._showTooltip($element);
      $element.removeData('tooltip-timeout');
    }, showDelay);
    
    $element.data('tooltip-timeout', showTimeout);
  }
  
  /**
   * Handle mouse leave event
   * @private
   * @param {Event} e - Mouse event
   */
  _handleMouseLeave(e) {
    const $element = $(e.currentTarget);
    
    // Clear any existing timeout
    const timeout = $element.data('tooltip-timeout');
    if (timeout) {
      clearTimeout(timeout);
    }
    
    // Set timeout for hiding tooltip
    const hideDelay = parseInt($element.attr('data-tooltip-hide-delay') || this.options.hideDelay);
    const hideTimeout = setTimeout(() => {
      // Get tooltip ID if exists
      const tooltipId = $element.data('tooltip-id');
      
      // Hide tooltip
      if (tooltipId && this.activeTooltips.has(tooltipId)) {
        const tooltipData = this.activeTooltips.get(tooltipId);
        this._hideTooltip(tooltipData.$tooltip);
        
        // Remove tooltip ID reference from element to allow future tooltips
        $element.removeData('tooltip-id');
        this.activeTooltips.delete(tooltipId);
      }
      
      $element.removeData('tooltip-timeout');
    }, hideDelay);
    
    $element.data('tooltip-timeout', hideTimeout);
  }
  
  /**
   * Handle mouse move event for follow cursor tooltips
   * @private
   * @param {Event} e - Mouse event
   */
  _handleMouseMove(e) {
    const $element = $(e.currentTarget);
    const tooltipId = $element.data('tooltip-id');
    
    if (!tooltipId || !this.activeTooltips.has(tooltipId)) return;
    
    const tooltipData = this.activeTooltips.get(tooltipId);
    this._positionTooltipWithCursor(e, tooltipData.$tooltip);
  }
  
  /**
   * Show tooltip for element
   * @private
   * @param {jQuery} $element - Target element
   */
  _showTooltip($element) {
    const content = $element.attr('data-tooltip');
    if (!content) return;
    
    // Check if tooltip already exists
    let tooltipId = $element.data('tooltip-id');
    let $tooltip;
    
    if (tooltipId && this.activeTooltips.has(tooltipId)) {
      // Use existing tooltip
      const tooltipData = this.activeTooltips.get(tooltipId);
      $tooltip = tooltipData.$tooltip;
      
      // Update content if it changed
      const contentHtml = this._getContentHtml(
        content, 
        $element.attr('data-tooltip-html') === 'true'
      );
      
      $tooltip.find('.sj-tooltip-content').html(contentHtml);
    } else {
      // Create new tooltip
      tooltipId = `sj-tooltip-${++this.tooltipId}`;
      
      // Get theme class
      const theme = $element.attr('data-tooltip-theme') || this.options.theme;
      const themeClass = `sj-tooltip-${theme}`;
      
      // Create tooltip element
      $tooltip = $('<div>', {
        id: tooltipId,
        class: `sj-tooltip ${themeClass}`,
        css: {
          opacity: 0,
          zIndex: this.options.zIndex
        }
      });
      
      // Add content container
      $('<div>', {
        class: 'sj-tooltip-content',
        html: this._getContentHtml(
          content, 
          $element.attr('data-tooltip-html') === 'true'
        )
      }).appendTo($tooltip);
      
      // Add arrow element
      $('<div>', {
        class: 'sj-tooltip-arrow'
      }).appendTo($tooltip);
      
      // Add to DOM
      $tooltip.appendTo('body');
      
      // Store reference
      $element.data('tooltip-id', tooltipId);
      this.activeTooltips.set(tooltipId, {
        $element,
        $tooltip
      });
    }
    
    // Position the tooltip
    if ($element.attr('data-tooltip-follow') === 'true') {
      this._positionTooltipWithCursor(
        { clientX: $element.offset().left, clientY: $element.offset().top },
        $tooltip
      );
    } else {
      this._positionTooltip($element, $tooltip);
    }
    
    // Show with animation
    $tooltip.css({
      opacity: 0,
      transform: 'scale(0.9)'
    }).animate({
      opacity: 1,
      transform: 'scale(1)'
    }, this.options.animationDuration);
  }
  
  /**
   * Hide and remove tooltip
   * @private
   * @param {jQuery} $tooltip - Tooltip element
   */
  _hideTooltip($tooltip) {
    $tooltip.animate({
      opacity: 0,
      transform: 'scale(0.9)'
    }, this.options.animationDuration, function() {
      $(this).remove();
    });
  }
  
  /**
   * Position tooltip relative to element
   * @private
   * @param {jQuery} $element - Target element
   * @param {jQuery} $tooltip - Tooltip element
   */
  _positionTooltip($element, $tooltip) {
    const elementRect = $element[0].getBoundingClientRect();
    const tooltipRect = $tooltip[0].getBoundingClientRect();
    const position = $element.attr('data-tooltip-position') || this.options.position;
    const boundary = this.options.boundary;
    
    // Calculate positions
    let top, left;
    const arrow = $tooltip.find('.sj-tooltip-arrow');
    arrow.css({ borderWidth: '5px' });
    
    // Default positioning
    switch (position) {
      case 'top':
        top = elementRect.top - tooltipRect.height - 10;
        left = elementRect.left + (elementRect.width / 2) - (tooltipRect.width / 2);
        arrow.css({
          bottom: '-10px',
          left: '50%',
          marginLeft: '-5px',
          borderTopColor: $tooltip.css('border-color'),
          borderRightColor: 'transparent',
          borderBottomColor: 'transparent',
          borderLeftColor: 'transparent'
        });
        break;
        
      case 'right':
        top = elementRect.top + (elementRect.height / 2) - (tooltipRect.height / 2);
        left = elementRect.right + 10;
        arrow.css({
          left: '-10px',
          top: '50%',
          marginTop: '-5px',
          borderTopColor: 'transparent',
          borderRightColor: $tooltip.css('border-color'),
          borderBottomColor: 'transparent',
          borderLeftColor: 'transparent'
        });
        break;
        
      case 'bottom':
        top = elementRect.bottom + 10;
        left = elementRect.left + (elementRect.width / 2) - (tooltipRect.width / 2);
        arrow.css({
          top: '-10px',
          left: '50%',
          marginLeft: '-5px',
          borderTopColor: 'transparent',
          borderRightColor: 'transparent',
          borderBottomColor: $tooltip.css('border-color'),
          borderLeftColor: 'transparent'
        });
        break;
        
      case 'left':
        top = elementRect.top + (elementRect.height / 2) - (tooltipRect.height / 2);
        left = elementRect.left - tooltipRect.width - 10;
        arrow.css({
          right: '-10px',
          top: '50%',
          marginTop: '-5px',
          borderTopColor: 'transparent',
          borderRightColor: 'transparent',
          borderBottomColor: 'transparent',
          borderLeftColor: $tooltip.css('border-color')
        });
        break;
    }
    
    // Apply user offset
    const offsetX = parseInt($element.attr('data-tooltip-offset-x') || this.options.offsetX);
    const offsetY = parseInt($element.attr('data-tooltip-offset-y') || this.options.offsetY);
    top += offsetY;
    left += offsetX;
    
    // Boundary detection
    const viewportWidth = $(window).width();
    const viewportHeight = $(window).height();
    
    // Horizontal boundary check
    if (left < boundary) {
      left = boundary;
      if (position === 'top' || position === 'bottom') {
        arrow.css({ left: elementRect.left + (elementRect.width / 2) - left });
      }
    } else if (left + tooltipRect.width > viewportWidth - boundary) {
      left = viewportWidth - tooltipRect.width - boundary;
      if (position === 'top' || position === 'bottom') {
        arrow.css({ left: elementRect.left + (elementRect.width / 2) - left });
      }
    }
    
    // Vertical boundary check
    if (top < boundary) {
      top = boundary;
      if (position === 'left' || position === 'right') {
        arrow.css({ top: elementRect.top + (elementRect.height / 2) - top });
      }
    } else if (top + tooltipRect.height > viewportHeight - boundary) {
      top = viewportHeight - tooltipRect.height - boundary;
      if (position === 'left' || position === 'right') {
        arrow.css({ top: elementRect.top + (elementRect.height / 2) - top });
      }
    }
    
    // Apply position
    $tooltip.css({ top, left });
  }
  
  /**
   * Position tooltip based on cursor position
   * @private
   * @param {Event} e - Mouse event
   * @param {jQuery} $tooltip - Tooltip element
   */
  _positionTooltipWithCursor(e, $tooltip) {
    const tooltipRect = $tooltip[0].getBoundingClientRect();
    const boundary = this.options.boundary;
    
    // Calculate positions
    let top = e.clientY + 15; // Position below cursor
    let left = e.clientX + 10; // Position right of cursor
    
    // Boundary detection
    const viewportWidth = $(window).width();
    const viewportHeight = $(window).height();
    
    // Horizontal boundary check
    if (left + tooltipRect.width > viewportWidth - boundary) {
      left = e.clientX - tooltipRect.width - 10; // Position left of cursor instead
    }
    
    // Vertical boundary check
    if (top + tooltipRect.height > viewportHeight - boundary) {
      top = e.clientY - tooltipRect.height - 10; // Position above cursor instead
    }
    
    // Apply position
    $tooltip.css({ top, left });
  }
  
  /**
   * Format content for display
   * @private
   * @param {string} content - Raw tooltip content
   * @param {boolean} allowHtml - Whether to allow HTML content
   * @returns {string} - Processed content
   */
  _getContentHtml(content, allowHtml) {
    if (allowHtml || this.options.allowHtml) {
      return content;
    } else {
      return $('<div>').text(content).html();
    }
  }
  
  /**
   * Remove all tooltips and clean up events
   */
  destroy() {
    // Remove all active tooltips
    this.activeTooltips.forEach(tooltipData => {
      tooltipData.$tooltip.remove();
      tooltipData.$element.removeData('tooltip-id');
      tooltipData.$element.removeData('tooltip-timeout');
    });
    
    this.activeTooltips.clear();
    
    // Remove event handlers
    $(document).off('mouseenter', '[data-tooltip]', this._handleMouseEnter);
    $(document).off('mouseleave', '[data-tooltip]', this._handleMouseLeave);
    $(document).off('mousemove', '[data-tooltip][data-tooltip-follow="true"]', this._handleMouseMove);
    
    // Remove stylesheet
    $('#tooltip-styles').remove();
    
    this.initialized = false;
  }
}

module.exports = new Tooltip(); 