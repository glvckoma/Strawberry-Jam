"use strict";

(function() {
  // Define the custom element
  class ExitConfirmModal extends HTMLElement {
    constructor() {
      super();
      
      // Bind methods to preserve 'this' context
      this.handleKeyDown = this.handleKeyDown.bind(this);
      this.handleBackdropClick = this.handleBackdropClick.bind(this);
      
      this.isClosing = false;
      this.initialized = false;
      
      // Ensure show method is immediately available
      this.show = this.show.bind(this);
      this.close = this.close.bind(this);
    }
    
    connectedCallback() {
      // Set up the modal when it's connected to the DOM
      if (!this.initialized) {
        this.initializeModal();
        this.initialized = true;
      }
    }
    
    initializeModal() {
      // Apply styles
      this.style.cssText = `
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.7);
        backdrop-filter: blur(5px);
        z-index: 10000;
        align-items: center;
        justify-content: center;
        font-family: 'CCDigitalDelivery', sans-serif;
        opacity: 1;
      `;
      
      this.createModal();
      this.setupEventListeners();
      this.updateTheme();
    }
    
    createModal() {
      // Don't create modal content if it already exists
      if (this.querySelector('.modal-content')) {
        return;
      }
      
      // Create the modal content without inline event handlers
      const modalContainer = document.createElement('div');
      modalContainer.innerHTML = `
        <div class="modal-content">
          <div class="modal-header">
            <span class="exit-icon">✕</span>
            Exit Game
          </div>
          
          <div class="modal-body">
            Are you sure you want to exit the game?<br>
            This will close all plugins as well.
          </div>
          
          <div class="checkbox-container" id="dontAskContainer">
            <input type="checkbox" id="dontAskCheckbox">
            <label for="dontAskCheckbox">Don't ask me again</label>
          </div>
          
          <div class="button-container">
            <button id="cancelBtn">Cancel</button>
            <button id="confirmBtn">Yes, Exit</button>
          </div>
        </div>
      `;
      
      // Add styles
      const style = document.createElement('style');
      style.textContent = `
        exit-confirm-modal .modal-content {
          background: var(--modal-bg, linear-gradient(135deg, #2D1B69 0%, #11101D 100%));
          border: 3px solid var(--modal-border, #4A90E2);
          border-radius: 15px;
          padding: 30px;
          max-width: 450px;
          width: 90%;
          box-shadow: 0 20px 40px var(--modal-shadow, rgba(0, 0, 0, 0.8));
          text-align: center;
          position: relative;
          animation: modalSlideIn 0.3s ease-out;
        }
        
        exit-confirm-modal .modal-header {
          color: var(--modal-text-primary, #4A90E2);
          font-size: 24px;
          font-weight: bold;
          margin-bottom: 20px;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 10px;
          text-shadow: var(--modal-text-shadow, none);
        }
        
        exit-confirm-modal .exit-icon {
          background: #E74C3C;
          color: white;
          width: 32px;
          height: 32px;
          border-radius: 50%;
          display: inline-flex;
          align-items: center;
          justify-content: center;
          font-size: 18px;
        }
        
        exit-confirm-modal .modal-body {
          color: var(--modal-text-secondary, #E2E8F0);
          font-size: 16px;
          line-height: 1.5;
          margin-bottom: 25px;
          text-shadow: var(--modal-text-shadow, none);
        }
        
        exit-confirm-modal .checkbox-container {
          margin-bottom: 25px;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
          cursor: pointer;
          user-select: none;
        }
        
        exit-confirm-modal .checkbox-container input {
          width: 16px;
          height: 16px;
          cursor: pointer;
          accent-color: #4A90E2;
        }
        
        exit-confirm-modal .checkbox-container label {
          color: var(--modal-text-tertiary, #A0AEC0);
          font-size: 14px;
          cursor: pointer;
          text-shadow: var(--modal-text-shadow, none);
        }
        
        exit-confirm-modal .checkbox-container:hover label {
          color: #E2E8F0;
        }
        
        exit-confirm-modal .button-container {
          display: flex;
          gap: 15px;
          justify-content: center;
        }
        
        exit-confirm-modal #cancelBtn {
          background: #4A5568;
          color: white;
          border: none;
          padding: 12px 24px;
          border-radius: 8px;
          font-size: 14px;
          font-weight: bold;
          cursor: pointer;
          transition: all 0.2s ease;
          min-width: 100px;
        }
        
        exit-confirm-modal #confirmBtn {
          background: var(--modal-confirm-bg, #E74C3C);
          color: var(--modal-confirm-text, white);
          border: none;
          padding: 12px 24px;
          border-radius: 8px;
          font-size: 14px;
          font-weight: bold;
          cursor: pointer;
          transition: all 0.2s ease;
          min-width: 100px;
          text-shadow: var(--modal-button-text-shadow, none);
          box-shadow: var(--modal-button-shadow, none);
        }
        
        exit-confirm-modal #cancelBtn:hover {
          background: #5A6578;
          transform: translateY(-1px);
        }
        
        exit-confirm-modal #confirmBtn:hover {
          background: var(--modal-confirm-hover-bg, #C0392B);
          transform: translateY(-1px);
        }
        
        @keyframes modalSlideIn {
          from {
            opacity: 0;
            transform: scale(0.9) translateY(-20px);
          }
          to {
            opacity: 1;
            transform: scale(1) translateY(0);
          }
        }
        
        @keyframes modalSlideOut {
          from {
            opacity: 1;
            transform: scale(1) translateY(0);
          }
          to {
            opacity: 0;
            transform: scale(0.9) translateY(-20px);
          }
        }
      `;
      
      // Append style and content to this element
      this.appendChild(style);
      this.appendChild(modalContainer);
    }
    
    setupEventListeners() {
      const cancelBtn = this.querySelector('#cancelBtn');
      const confirmBtn = this.querySelector('#confirmBtn');
      const dontAskContainer = this.querySelector('#dontAskContainer');
      const checkbox = this.querySelector('#dontAskCheckbox');
      
      // Cancel button
      cancelBtn.addEventListener('click', () => {
        this.close(false);
      });
      
      // Confirm button
      confirmBtn.addEventListener('click', () => {
        const dontAskAgain = checkbox.checked;
        this.close(true, dontAskAgain);
      });
      
      // Checkbox container click
      dontAskContainer.addEventListener('click', (e) => {
        if (e.target !== checkbox) {
          checkbox.checked = !checkbox.checked;
        }
      });
      
      // Backdrop click to cancel
      this.addEventListener('click', this.handleBackdropClick);
      
      // Escape key to cancel
      document.addEventListener('keydown', this.handleKeyDown);
    }
    
    handleKeyDown(e) {
      if (e.key === 'Escape') {
        this.close(false);
      }
    }
    
    handleBackdropClick(e) {
      if (e.target === this) {
        this.close(false);
      }
    }
    
    show() {
      // Ensure modal is initialized before showing
      if (!this.initialized) {
        this.initializeModal();
        this.initialized = true;
      }
      
      this.style.display = 'flex';
      this.style.opacity = '1';
      
      // Focus the modal for keyboard events
      setTimeout(() => {
        const cancelBtn = this.querySelector('#cancelBtn');
        if (cancelBtn) {
          cancelBtn.focus();
        }
      }, 100);
    }
    
    close(confirmed, dontAskAgain = false) {
      // Prevent multiple close calls
      if (this.isClosing) {
        return;
      }
      this.isClosing = true;
      
      // Clean up event listeners
      document.removeEventListener('keydown', this.handleKeyDown);
      this.removeEventListener('click', this.handleBackdropClick);
      
      // Dispatch event with result
      this.dispatchEvent(new CustomEvent('result', {
        detail: {
          confirmed: confirmed,
          dontAskAgain: dontAskAgain
        }
      }));
      
      // Animate out and remove
      const modalContent = this.querySelector('.modal-content');
      if (modalContent) {
        modalContent.style.animation = 'modalSlideOut 0.2s ease-in forwards';
      }
      
      // Fade out the backdrop
      this.style.transition = 'opacity 0.2s ease-in';
      this.style.opacity = '0';
      
      setTimeout(() => {
        if (this.parentNode) {
          this.parentNode.removeChild(this);
        }
      }, 200);
    }
    
    updateTheme() {
      // Get current theme from the login screen element
      const loginScreen = document.getElementById('login-screen');
      let themePrimary = '#e83d52'; // Default strawberry theme
      let themeSecondary = 'rgba(232, 61, 82, 0.3)';
      let themeShadow = 'rgba(252, 93, 93, 0.1)';
      let themeBoxBackground = 'rgba(255, 245, 230, 0.95)';
      
      if (loginScreen && loginScreen.shadowRoot) {
        const computedStyle = getComputedStyle(loginScreen.shadowRoot.host);
        themePrimary = computedStyle.getPropertyValue('--theme-primary').trim() || themePrimary;
        themeSecondary = computedStyle.getPropertyValue('--theme-secondary').trim() || themeSecondary;
        themeShadow = computedStyle.getPropertyValue('--theme-shadow').trim() || themeShadow;
        themeBoxBackground = computedStyle.getPropertyValue('--theme-box-background').trim() || themeBoxBackground;
      }

      // Apply theme CSS variables
      this.style.setProperty('--modal-bg', themeBoxBackground);
      this.style.setProperty('--modal-border', themePrimary);
      this.style.setProperty('--modal-shadow', themeShadow);
      this.style.setProperty('--modal-text-primary', themePrimary);
      this.style.setProperty('--modal-text-secondary', '#333333');
      this.style.setProperty('--modal-text-tertiary', '#666666');
      this.style.setProperty('--modal-confirm-bg', themePrimary);
      this.style.setProperty('--modal-confirm-text', 'white');
      this.style.setProperty('--modal-confirm-hover-bg', this.darkenColor(themePrimary, 15));
    }
    
    darkenColor(hex, percent) {
      if (!hex || hex.length < 7) return hex;
      
      // Convert hex to RGB
      let r = parseInt(hex.slice(1, 3), 16);
      let g = parseInt(hex.slice(3, 5), 16);
      let b = parseInt(hex.slice(5, 7), 16);
      
      // Darken
      r = Math.max(0, Math.floor(r * (100 - percent) / 100));
      g = Math.max(0, Math.floor(g * (100 - percent) / 100));
      b = Math.max(0, Math.floor(b * (100 - percent) / 100));
      
      // Convert back to hex
      return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`;
    }
    
    
    disconnectedCallback() {
      // Clean up event listeners when element is removed
      document.removeEventListener('keydown', this.handleKeyDown);
      this.removeEventListener('click', this.handleBackdropClick);
    }
  }
  
  // Register the custom element
  try {
    customElements.define('exit-confirm-modal', ExitConfirmModal);
    console.log('[Exit Confirmation] Custom element registered successfully');
  } catch (error) {
    console.error('[Exit Confirmation] Failed to register custom element:', error);
  }
})();