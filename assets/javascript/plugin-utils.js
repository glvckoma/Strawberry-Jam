/**
 * Strawberry Jam - Plugin UI Utilities
 * This file provides standardized functionality for plugin UI components
 */

(function() {
  /**
   * Initialize plugin UI components with standard behavior
   * Call this function in each plugin's script to standardize UI behavior
   */
  window.initializePluginUI = function() {
    // Add the stylesheet if not already added
    if (!document.getElementById('jam-plugin-styles')) {
      const link = document.createElement('link');
      link.id = 'jam-plugin-styles';
      link.rel = 'stylesheet';
      link.href = '../../assets/css/plugin-styles.css';
      document.head.appendChild(link);
    }

    // Handle minimize button functionality
    const minimizeBtn = document.querySelector('.jam-plugin-minimize');
    
    if (minimizeBtn) {
      // Use actual window minimize functionality instead of content hiding
      minimizeBtn.addEventListener('click', function() {
        // Target the current plugin window specifically
        try {
          // Use Electron's remote module to get the current BrowserWindow instance
          // This will ensure we're targeting the plugin window, not the main window
          const { remote } = require('electron');
          if (remote && remote.getCurrentWindow) {
            const currentWindow = remote.getCurrentWindow();
            currentWindow.minimize();
            return; // Exit early if successful
          }
        } catch (e) {
          console.warn("[Plugin Utils] Could not use remote module to minimize window:", e);
          // Continue to fallback methods
        }

        // Fallback 1: Try Electron's ipcRenderer with a specific channel for plugins
        try {
          const { ipcRenderer } = require('electron');
          // Use a specific channel for plugin windows
          ipcRenderer.send('plugin-window-minimize');
          return; // Exit early if we reach this point
        } catch (e) {
          console.warn("[Plugin Utils] Could not use ipcRenderer for plugin window:", e);
        }

        // Fallback 2: Try a more direct approach with window.minimize if available
        if (window.minimize) {
          window.minimize();
          return;
        }

        // Last resort: Try regular window methods
        try {
          window.blur();
        } catch (e) {
          console.error("[Plugin Utils] All minimize attempts failed:", e);
        }
      });
    }

    // Make sure close button works properly
    const closeBtn = document.querySelector('.jam-plugin-close');
    if (closeBtn) {
      closeBtn.addEventListener('click', function() {
        try {
          // Try to get the current window and close it
          const { remote } = require('electron');
          if (remote && remote.getCurrentWindow) {
            const currentWindow = remote.getCurrentWindow();
            currentWindow.close();
            return;
          }
        } catch (e) {
          console.warn("[Plugin Utils] Could not use remote to close window:", e);
        }
        
        // Fallback to standard window.close()
        window.close();
      });
    }
  };

  /**
   * Make a specific element draggable within a plugin window
   * @param {string} selector - CSS selector for the draggable element
   */
  window.makeElementDraggable = function(selector) {
    const element = document.querySelector(selector);
    if (!element) return;
    
    let pos1 = 0, pos2 = 0, pos3 = 0, pos4 = 0;
    
    element.onmousedown = dragMouseDown;
    
    function dragMouseDown(e) {
      e = e || window.event;
      // Check if we're clicking on a non-draggable element
      if (e.target.closest('[data-no-drag]')) {
        return;
      }
      
      e.preventDefault();
      // Get the mouse cursor position at startup
      pos3 = e.clientX;
      pos4 = e.clientY;
      document.onmouseup = closeDragElement;
      // Call a function whenever the cursor moves
      document.onmousemove = elementDrag;
    }
    
    function elementDrag(e) {
      e = e || window.event;
      e.preventDefault();
      // Calculate the new cursor position
      pos1 = pos3 - e.clientX;
      pos2 = pos4 - e.clientY;
      pos3 = e.clientX;
      pos4 = e.clientY;
      // Set the element's new position
      element.style.top = (element.offsetTop - pos2) + "px";
      element.style.left = (element.offsetLeft - pos1) + "px";
    }
    
    function closeDragElement() {
      // Stop moving when mouse button is released
      document.onmouseup = null;
      document.onmousemove = null;
    }
  };
})(); 