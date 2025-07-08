"use strict";

(function() {
  // Define the custom element
  class ExitConfirmModal extends HTMLElement {
    constructor() {
      super();
      this.style.display = 'none';
      this.style.position = 'fixed';
      this.style.top = '0';
      this.style.left = '0';
      this.style.width = '100%';
      this.style.height = '100%';
      this.style.backgroundColor = 'rgba(0, 0, 0, 0.7)';
      this.style.backdropFilter = 'blur(5px)';
      this.style.zIndex = '10000';
      this.style.display = 'flex';
      this.style.alignItems = 'center';
      this.style.justifyContent = 'center';
      this.style.fontFamily = "'CCDigitalDelivery', sans-serif";
      
      this.createModal();
      
      this.setupEventListeners();
      this.updateTheme();
    }
    
    createModal() {
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
      this.addEventListener('click', (e) => {
        if (e.target === this) {
          this.close(false);
        }
      });
      
      // Escape key to cancel
      document.addEventListener('keydown', this.handleKeyDown);
    }
    
    handleKeyDown = (e) => {
      if (e.key === 'Escape') {
        this.close(false);
      }
    }
    
    show() {
      this.style.display = 'flex';
      // Focus the modal for keyboard events
      setTimeout(() => {
        this.querySelector('#cancelBtn').focus();
      }, 100);
    }
    
    close(confirmed, dontAskAgain = false) {
      document.removeEventListener('keydown', this.handleKeyDown);
      
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
      this.style.opacity = '0';
      
      setTimeout(() => {
        if (this.parentNode) {
          this.parentNode.removeChild(this);
        }
      }, 200);
    }
    
    connectedCallback() {
      // Custom element lifecycle method - called when element is added to DOM
    }
  }
  
  // Register the custom element
  customElements.define('exit-confirm-modal', ExitConfirmModal);
})();