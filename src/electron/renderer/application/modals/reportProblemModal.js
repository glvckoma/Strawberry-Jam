const { ipcRenderer } = require('electron');
const logManager = require('../../../../utils/LogManagerPreload');
const path = require('path');

/**
 * Modal for reporting problems with the application
 */
module.exports = {
  name: 'reportProblem',
  title: 'Report a Problem',
  width: 550,

  /**
   * Render the modal content
   * This is called by the ModalSystem.show method
   * @param {Application} application The application instance
   * @param {Object} options Modal options
   * @returns {JQuery<HTMLElement>} The modal content
   */
  render(application, options = {}) {
    // Create container element
    const $modal = $(`
      <div class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-70 backdrop-blur-sm">
        <div class="modal-content rounded-lg bg-secondary-bg shadow-lg w-full mx-4 max-w-2xl max-h-[80vh] overflow-hidden">
          <div class="modal-header bg-tertiary-bg border-b border-gray-700 p-4 flex justify-between items-center sticky top-0 z-10">
            <h3 class="text-lg font-medium text-text-primary flex items-center">
              <i class="fas fa-bug mr-2 text-highlight-purple"></i>
              Report a Problem
            </h3>
            <button class="modal-close-button-std p-2 rounded text-gray-400 hover:bg-error-red hover:text-white transition-colors focus:outline-none">
              <i class="fas fa-times"></i>
            </button>
          </div>
          
          <div class="p-6 space-y-6 overflow-y-auto" style="max-height: calc(80vh - 140px);">
            <div class="flex flex-col space-y-4">
              <div class="mb-2">
                <label class="block text-sm font-medium text-gray-300 mb-2">What problem are you experiencing?</label>
                <textarea 
                  id="problem-description" 
                  class="w-full p-3 bg-tertiary-bg rounded-md border border-gray-700 focus:border-highlight-purple focus:ring focus:ring-highlight-purple/20 focus:outline-none text-text-primary"
                  rows="4"
                  placeholder="Please describe the issue in detail..."
                ></textarea>
                <div id="description-error" class="hidden mt-1 text-xs text-error-red">
                  <i class="fas fa-exclamation-circle mr-1"></i>
                  Please describe the problem you are experiencing.
                </div>
              </div>
              
              <div class="mb-2">
                <label class="block text-sm font-medium text-gray-300 mb-2">Steps to reproduce</label>
                <textarea 
                  id="steps-to-reproduce" 
                  class="w-full p-3 bg-tertiary-bg rounded-md border border-gray-700 focus:border-highlight-purple focus:ring focus:ring-highlight-purple/20 focus:outline-none text-text-primary"
                  rows="3"
                  placeholder="1. Open the application\n2. Click on...\n3. When I try to..."
                ></textarea>
              </div>
              
              <div class="flex items-center space-x-2">
                <input type="checkbox" id="include-logs" class="form-checkbox bg-tertiary-bg border-gray-600 rounded focus:ring-highlight-purple" checked>
                <label for="include-logs" class="text-sm text-gray-300">Include application logs</label>
              </div>
              
              <div id="discord-instructions" class="hidden mt-4 p-4 bg-highlight-purple/10 rounded-md border border-highlight-purple/30">
                <h3 class="text-sm font-medium text-highlight-purple mb-2">How to submit your report:</h3>
                <ol class="text-sm text-gray-300 list-decimal pl-5 space-y-1">
                  <li>Save the report by clicking the button below</li>
                  <li>Join our <a href="https://discord.gg/a2y6bZnhB3" style="color: #a855f7; font-weight: 500;" class="hover:underline" target="_blank">Discord server</a></li>
                  <li>Upload the saved report file in the #support channel</li>
                </ol>
              </div>
              
              <div id="report-output" class="hidden mt-4 opacity-0 transition-all duration-300 transform translate-y-4">
                <div class="flex justify-between items-center mb-2">
                  <label class="block text-sm font-medium text-gray-300">Report Information</label>
                  <div class="flex space-x-2">
                    <button id="copy-report" class="text-xs px-2 py-1 bg-tertiary-bg hover:bg-highlight-purple/20 text-gray-300 hover:text-white rounded transition-colors">
                      <i class="fas fa-copy mr-1"></i> Copy
                    </button>
                    <button id="save-report" class="text-xs px-2 py-1 bg-highlight-purple hover:bg-highlight-purple/80 text-white rounded transition-colors">
                      <i class="fas fa-download mr-1"></i> Save as .txt
                    </button>
                  </div>
                </div>
                <div id="report-content" class="w-full p-3 bg-tertiary-bg rounded-md border border-gray-700 text-xs font-mono text-gray-300 h-[250px] overflow-y-auto whitespace-pre-wrap break-all"></div>
              </div>
            </div>
          </div>
          
          <div class="flex items-center justify-between px-6 py-4 bg-tertiary-bg border-t border-gray-700 sticky bottom-0 z-10">
            <button id="cancel-report" class="px-4 py-2 bg-gray-700 hover:bg-gray-600 hover:text-white text-gray-300 transition-colors duration-200 rounded-md flex items-center transform hover:scale-105">
              <i class="fas fa-times mr-1.5"></i> Cancel
            </button>
            <button id="generate-report" class="px-4 py-2 bg-highlight-purple hover:bg-highlight-purple/80 text-white transition-colors duration-200 rounded-md flex items-center transform hover:scale-105 hover:shadow-glow focus:outline-none">
              <i class="fas fa-file-alt mr-1.5"></i> Generate Report
            </button>
          </div>
        </div>
      </div>
    `);
    
    // Add entrance animation
    const $modalContent = $modal.find('.modal-content');
    $modalContent.css({
      'opacity': '0',
      'transform': 'scale(0.95)'
    });
    
    $modal.css({
      'opacity': '0'
    });
    
    setTimeout(() => {
      $modalContent.css({
        'opacity': '1',
        'transform': 'scale(1)',
        'transition': 'opacity 0.25s ease-out, transform 0.25s ease-out'
      });
      
      $modal.css({
        'opacity': '1',
        'transition': 'opacity 0.25s ease-out'
      });
    }, 10);
    
    // Add shadow glow style
    const styleEl = document.head.querySelector('#report-modal-style') || document.createElement('style');
    styleEl.id = 'report-modal-style';
    styleEl.textContent = `
      .hover\\:shadow-glow:hover {
        box-shadow: 0 0 10px 0 var(--theme-primary, #e83d52);
      }
      @keyframes slideIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
      }
      .animate-slide-in {
        animation: slideIn 0.4s ease-out forwards;
      }
      #report-content {
        height: 250px !important;
        max-height: 250px !important;
        overflow-y: auto !important;
        overflow-x: hidden !important;
        white-space: pre-wrap !important;
        word-break: break-all !important;
        word-wrap: break-word !important;
      }
      .modal-content {
        max-width: 90vw !important;
        max-height: 80vh !important;
      }
    `;
    document.head.appendChild(styleEl);
    
    // Save application reference
    this.application = application;
    
    // Set up context for logging
    logManager.setContext('modal-report');
    logManager.debug('Initializing Report Problem modal');
    
    // Bind events
    this.bindEvents($modal);
    
    // Return the modal content
    return $modal;
  },

  /**
   * Bind event listeners
   * @param {JQuery<HTMLElement>} $modal Modal container
   */
  bindEvents($modal) {
    const $generateButton = $modal.find('#generate-report');
    const $cancelButton = $modal.find('#cancel-report');
    const $copyButton = $modal.find('#copy-report');
    const $saveButton = $modal.find('#save-report');
    const $closeButton = $modal.find('.modal-close-button-std');
    const $problemDescription = $modal.find('#problem-description');
    const $descriptionError = $modal.find('#description-error');
    const $modalContent = $modal.find('.modal-content');
    
    // Handle input validation as user types
    $problemDescription.on('input', function() {
      if ($(this).val().trim() !== '') {
        $descriptionError.addClass('hidden');
      }
    });
    
    // Add exit animation function
    const animateClose = (callback) => {
      $modalContent.css({
        'opacity': '1',
        'transform': 'scale(1)',
        'transition': 'opacity 0.25s ease-in-out, transform 0.25s ease-in-out'
      }).animate({
        'opacity': '0',
        'transform': 'scale(0.95)'
      }, {
        duration: 250,
        step: function(now, fx) {
          if (fx.prop === 'transform') {
            $(this).css('transform', `scale(${now})`);
          }
        },
        complete: callback
      });
      
      // Fade out backdrop
      $modal.animate({
        'opacity': '0'
      }, 250);
    };
    
    // Generate report
    $generateButton.on('click', async () => {
      // Check if problem description is empty
      if ($problemDescription.val().trim() === '') {
        $descriptionError.removeClass('hidden');
        $problemDescription.focus();
        return;
      }
      
      await this.generateReport($modal);
    });
    
    // Cancel/close modal
    $cancelButton.on('click', () => {
      animateClose(() => {
        if (this.application && this.application.modals) {
          this.application.modals.close();
        }
      });
    });
    
    // X close button
    $closeButton.on('click', () => {
      animateClose(() => {
        if (this.application && this.application.modals) {
          this.application.modals.close();
        }
      });
    });
    
    // Handle backdrop click
    $modal.on('click', (e) => {
      if (e.target === $modal[0]) {
        animateClose(() => {
          if (this.application && this.application.modals) {
            this.application.modals.close();
          }
        });
      }
    });
    
    // Copy report to clipboard
    $copyButton.on('click', () => {
      const reportContent = $modal.find('#report-content').text();
      navigator.clipboard.writeText(reportContent);
      
      const originalHtml = $copyButton.html();
      $copyButton.html('<i class="fas fa-check mr-1"></i> Copied!');
      
      setTimeout(() => {
        $copyButton.html(originalHtml);
      }, 2000);
    });
    
    // Save report as .txt file
    $saveButton.on('click', async () => {
      const reportContent = $modal.find('#report-content').text();
      try {
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const filename = `strawberry-jam-report-${timestamp}.txt`;
        await ipcRenderer.invoke('save-text-file', {
          content: reportContent,
          suggestedFilename: filename
        });
        
        const originalHtml = $saveButton.html();
        $saveButton.html('<i class="fas fa-check mr-1"></i> Saved!');
        
        setTimeout(() => {
          $saveButton.html(originalHtml);
        }, 2000);
        
      } catch (error) {
        window.jam.application.consoleMessage({
          type: 'error',
          message: 'Failed to save report: ' + error.message
        });
      }
    });
  },

  /**
   * Generate problem report
   * @param {JQuery<HTMLElement>} $modal Modal container
   */
  async generateReport($modal) {
    const problemDescription = $modal.find('#problem-description').val().trim();
    const stepsToReproduce = $modal.find('#steps-to-reproduce').val().trim();
    const includeLogs = $modal.find('#include-logs').prop('checked');
    
    // Reset animation state if the report was already generated
    if (!$modal.find('#report-output').hasClass('hidden')) {
      $modal.find('#report-output')
        .addClass('opacity-0 translate-y-4')
        .removeClass('animate-slide-in');
    }
    
    // Validate inputs
    if (!problemDescription) {
      // Show error inline
      $modal.find('#description-error').removeClass('hidden');
      $modal.find('#problem-description').focus();
      return;
    }
    
    try {
      // Show loading state
      const $generateButton = $modal.find('#generate-report');
      $generateButton.prop('disabled', true);
      $generateButton.addClass('animate-pulse');
      $generateButton.html('<i class="fas fa-spinner fa-spin mr-1.5"></i> Generating...');
      
      // Get application info
      const appVersion = await ipcRenderer.invoke('get-app-version');
      const osInfo = await ipcRenderer.invoke('get-os-info');
      
      // Generate report content
      let reportContent = `## Strawberry Jam Problem Report\n\n`;
      reportContent += `**Version:** ${appVersion}\n`;
      reportContent += `**OS:** ${osInfo.platform} ${osInfo.release}\n\n`;
      reportContent += `### Problem Description\n${problemDescription}\n\n`;
      
      if (stepsToReproduce) {
        reportContent += `### Steps to Reproduce\n${stepsToReproduce}\n\n`;
      }
      
      // Include logs if requested
      if (includeLogs) {
        // Get comprehensive logs using the new method
        const allLogs = await logManager.getAllLogs({
          maxResults: 100 // Limit to 100 logs of each type for readability
        });
        
        // Add system info section
        if (allLogs.systemInfo) {
          reportContent += `### System Information\n`;
          Object.entries(allLogs.systemInfo).forEach(([key, value]) => {
            reportContent += `- **${key}:** ${this.redactSensitiveData(String(value))}\n`;
          });
          reportContent += `\n`;
        }
        
        // Export logs to file
        const logFilePath = await logManager.exportLogs({
          includeMemoryLogs: true,
          includeDevToolsLogs: true,
          format: 'text' // This will use the main process LogManager's export, which isn't redacted by this modal
        });
        
        // Add recent logs to the report
        if (allLogs.logs && allLogs.logs.length > 0) {
          reportContent += `### Recent Application Logs (Redacted)\n\`\`\`\n`;
          
          allLogs.logs.forEach(entry => {
            const redactedMessage = this.redactSensitiveData(entry.message);
            reportContent += `[${entry.timestamp}] [${entry.levelName}] [${entry.context}] ${redactedMessage}\n`;
          });
          
          reportContent += `\`\`\`\n\n`;
        }
        
        // Add recent DevTools logs to the report
        if (allLogs.devToolsLogs && allLogs.devToolsLogs.length > 0) {
          reportContent += `### Recent DevTools Logs (Redacted)\n\`\`\`\n`;
          
          allLogs.devToolsLogs.forEach(entry => {
            const redactedMessage = this.redactSensitiveData(entry.message);
            const sourcePart = entry.source ? ` (${path.basename(entry.source)}:${entry.line || '?'})` : '';
            reportContent += `[${entry.timestamp}] [${entry.levelName}] [${entry.window}] ${redactedMessage}${sourcePart}\n`;
          });
          
          reportContent += `\`\`\`\n\n`;
        }
        
        reportContent += `Full unredacted logs may be available in: ${logFilePath}\n (Note: The file itself is not redacted by this modal's current operation)\n\n`;
      }
      
      reportContent += `### System Information (from renderer)\n`;
      reportContent += `- Screen Resolution: ${window.screen.width}x${window.screen.height}\n`;
      reportContent += `- Connected to Animal Jam: ${window.jam.server && window.jam.server.clients && window.jam.server.clients.size > 0 ? 'Yes' : 'No'}\n`;
      
      // Add plugins information
      const enabledPlugins = await ipcRenderer.invoke('get-enabled-plugins');
      if (enabledPlugins && enabledPlugins.length > 0) {
        reportContent += `\n### Enabled Plugins\n`;
        enabledPlugins.forEach(plugin => {
          reportContent += `- ${plugin.name} v${plugin.version || '?'}\n`;
        });
      }
      
      // Hide form sections to make room for the report
      $modal.find('#problem-description').closest('.mb-2').slideUp(300);
      $modal.find('#steps-to-reproduce').closest('.mb-2').slideUp(300);
      $modal.find('#include-logs').closest('.flex').slideUp(300);
      
      // Change generate button text to "Create New Report"
      $generateButton.html('<i class="fas fa-file-alt mr-1.5"></i> Create New Report');
      $generateButton.off('click').on('click', function() {
        // Show the form sections again
        $modal.find('#problem-description').closest('.mb-2').slideDown(300);
        $modal.find('#steps-to-reproduce').closest('.mb-2').slideDown(300);
        $modal.find('#include-logs').closest('.flex').slideDown(300);
        
        // Hide the report sections
        $modal.find('#report-output').addClass('hidden');
        $modal.find('#discord-instructions').addClass('hidden');
        
        // Reset the button
        $generateButton.html('<i class="fas fa-file-alt mr-1.5"></i> Generate Report');
        $generateButton.off('click').on('click', function() {
          module.exports.generateReport($modal);
        });
      });
      
      // Display the report - chunk the content to avoid overwhelming the DOM
      const $reportContent = $modal.find('#report-content');
      $reportContent.empty(); // Clear any existing content
      
      // Insert content in chunks to prevent layout issues
      const chunkSize = 2000; // Characters per chunk
      for (let i = 0; i < reportContent.length; i += chunkSize) {
        const chunk = reportContent.substring(i, i + chunkSize);
        $reportContent.append(document.createTextNode(chunk));
      }
      
      $modal.find('#report-output').removeClass('hidden');
      
      // Ensure the report content size is constrained
      $reportContent.css({
        'height': '250px',
        'max-height': '250px',
        'overflow-y': 'auto',
        'overflow-x': 'hidden',
        'white-space': 'pre-wrap',
        'word-break': 'break-all',
        'word-wrap': 'break-word'
      });
      
      // Add animation with a slight delay
      setTimeout(() => {
        $modal.find('#report-output')
          .removeClass('opacity-0 translate-y-4')
          .addClass('animate-slide-in');
      }, 50);
      
      $modal.find('#discord-instructions').removeClass('hidden');
      
      // Restore button state
      $generateButton.prop('disabled', false);
      $generateButton.removeClass('animate-pulse');
      
      logManager.info('Problem report generated');
      
    } catch (error) {
      try {
        logManager.error('Error generating problem report: ' + error.message);
      } catch (logErr) {
        console.error('Error generating problem report: ' + error.message);
      }
      window.jam.application.consoleMessage({
        type: 'error',
        message: 'Failed to generate report: ' + error.message
      });
      
      // Restore button state
      const $generateButton = $modal.find('#generate-report');
      $generateButton.prop('disabled', false);
      $generateButton.removeClass('animate-pulse');
      $generateButton.html('<i class="fas fa-file-alt mr-1.5"></i> Generate Report');
    }
  },

  /**
   * Redacts sensitive data from a given string.
   * @param {string} message The string to redact.
   * @returns {string} The redacted string.
   */
  redactSensitiveData(message) {
    if (typeof message !== 'string') {
      return message;
    }

    let redactedMessage = message;

    // Regex for common sensitive patterns
    const patterns = {
      // More specific API keys (common prefixes)
      apiKey: /(api_key|apikey|api-key|client_secret|token|auth_token|secret_key)\s*[:=]\s*['"]?([a-zA-Z0-9_.-]{20,})['"]?/gi,
      // Generic sensitive key-value pairs (broader but might have false positives)
      sensitiveParams: /(['"]?(password|secret|token|apiKey|authKey|privateKey)['"]?\s*[:=]\s*['"]?)([^'"\s,&]+)(['"]?)/gi,
      // UUIDs
      uuid: /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/gi,
      // Email addresses
      email: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/gi,
      // IP Addresses (v4)
      ipv4: /\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b/gi,
      // Common username patterns (alphanumeric, 3-20 chars, often after "user" or "username")
      // This is more prone to false positives, use with caution or make more specific
      username: /(user(?:name)?\s*[:=]\s*['"]?)([a-zA-Z0-9_.-]{3,20})(['"]?)/gi
    };

    // Apply redactions
    redactedMessage = redactedMessage.replace(patterns.apiKey, '$1[REDACTED_API_KEY]');
    // For sensitiveParams, we only redact the value part
    redactedMessage = redactedMessage.replace(patterns.sensitiveParams, '$1[REDACTED_VALUE]$4');
    redactedMessage = redactedMessage.replace(patterns.uuid, '[REDACTED_UUID]');
    redactedMessage = redactedMessage.replace(patterns.email, '[REDACTED_EMAIL]');
    
    // For IP addresses, only redact if not a common non-sensitive IP like localhost
    redactedMessage = redactedMessage.replace(patterns.ipv4, (match) => {
      if (match === '127.0.0.1' || match.startsWith('192.168.') || match.startsWith('10.')) {
        return match; // Don't redact common local/private IPs
      }
      return '[REDACTED_IP]';
    });
    
    // Username redaction - careful with this one
    redactedMessage = redactedMessage.replace(patterns.username, '$1[REDACTED_USERNAME]$3');

    // Redact long strings of numbers (potential IDs, card numbers if not caught by specific patterns)
    // Be careful, this can be overly aggressive.
    // redactedMessage = redactedMessage.replace(/\b\d{10,}\b/g, '[REDACTED_NUMBER_SEQUENCE]');

    return redactedMessage;
  },
 
  /**
   * Close handler
   */
  close() {
    // Nothing special to do
  }
};