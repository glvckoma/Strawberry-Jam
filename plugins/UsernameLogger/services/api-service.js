/**
 * @file api-service.js - API communication service for Username Logger
 * @author glvckoma
 */

const { ipcRenderer } = require('electron');
const { LEAK_CHECK_API_URL } = require('../constants/constants');
const { wait } = require('../utils/username-utils');

/**
 * Service for handling API communication
 */
class ApiService {
  /**
   * Creates a new API service
   * @param {Object} options - Service options
   * @param {Object} options.application - The application object for logging
   */
  constructor({ application }) {
    this.application = application;
    this._cachedHttpClient = null;
  }

  /**
   * Gets the API key from application settings
   * @returns {Promise<string|null>} The API key or null if not found
   */
  async getApiKey() {
    try {
      // Get the key via IPC - wrapped in try/catch to prevent any issues
      let apiKeyResponse;
      try {
        apiKeyResponse = await ipcRenderer.invoke('get-setting', 'plugins.usernameLogger.apiKey'); // Corrected key
      } catch (ipcError) {
        // Log the error in dev mode, but still return null silently
        if (process.env.NODE_ENV === 'development') {
          this.application.consoleMessage({ type: 'error', message: `[Username Logger] IPC Error getting API key: ${ipcError.message}` });
        }
        return null;
      }

      // Log the raw response from IPC in dev mode
      if (process.env.NODE_ENV === 'development') {
        this.application.consoleMessage({ type: 'logger', message: `[Username Logger] Raw API key response from IPC: ${JSON.stringify(apiKeyResponse)}` });
      }

      // Handle different formats - the key might be directly returned or in a 'value' property
      let extractedValue = null;

      // Safely handle different response formats
      try {
        if (apiKeyResponse && typeof apiKeyResponse === 'object' && 'value' in apiKeyResponse) {
          // If it's an object with a value property (even if value is null/undefined)
          extractedValue = apiKeyResponse.value;
        } else if (typeof apiKeyResponse === 'string') {
          // If it's directly a string
          extractedValue = apiKeyResponse;
        }
        // Ignore other types or null/undefined apiKeyResponse

        // Ensure the final result is either a string or null
        const finalApiKey = (typeof extractedValue === 'string') ? extractedValue : null;

        // Log the final extracted key in dev mode
        if (process.env.NODE_ENV === 'development') {
          this.application.consoleMessage({ type: 'logger', message: `[Username Logger] Final extracted API key: ${finalApiKey === null ? 'null' : (finalApiKey.length > 8 ? finalApiKey.substring(0, 4) + '...' + finalApiKey.substring(finalApiKey.length - 4) : '********')}` });
        }

        return finalApiKey;

      } catch (formatError) {
        // Log the error in dev mode, but still return null silently
        if (process.env.NODE_ENV === 'development') {
          this.application.consoleMessage({ type: 'error', message: `[Username Logger] Error formatting API key: ${formatError.message}` });
        }
        return null;
      }

    } catch (error) {
      // Log the error in dev mode, but still return null silently
      if (process.env.NODE_ENV === 'development') {
        this.application.consoleMessage({ type: 'error', message: `[Username Logger] General error getting API key: ${error.message}` });
      }
      return null;
    }
  }

  /**
   * Sets the API key in application settings
   * @param {string} apiKey - The API key to set
   * @returns {Promise<boolean>} True if successful
   */
  async setApiKey(apiKey) {
    try {
      // Validate API key format (basic validation)
      if (!apiKey || typeof apiKey !== 'string' || apiKey.trim() === '') {
        this.application.consoleMessage({
          type: 'error',
          message: `[Username Logger] Invalid API key format. Please provide a valid API key.`
        });
        return false;
      }
      
      // Use IPC to save the API key (consistent with how we retrieve it)
      await ipcRenderer.invoke('set-setting', 'plugins.usernameLogger.apiKey', apiKey); // Corrected key
      
      this.application.consoleMessage({
        type: 'success',
        message: `[Username Logger] API key saved successfully.`
      });
      return true;
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] Could not save API key to application settings: ${error.message}`
      });
      return false;
    }
  }

  /**
   * Validates the API key by making a silent call to the stats endpoint.
   * @param {string} apiKey - The API key to validate.
   * @returns {Promise<{valid: boolean, reason?: 'invalid_key' | 'api_error', error?: Error}>} Validation result.
   */
  async validateApiKey(apiKey) {
    // Basic check (redundant but safe)
    if (!apiKey || typeof apiKey !== 'string' || apiKey.trim() === '') {
      return { valid: false, reason: 'invalid_key' }; // Treat blank as invalid for validation purposes
    }

    const httpClient = await this.loadHttpClient();
    if (!httpClient) {
      return { valid: false, reason: 'api_error', error: new Error('Failed to load HTTP client for validation') };
    }

    const statsUrl = `${LEAK_CHECK_API_URL}/stats`; // Use the base stats endpoint

    try {
      let responseStatus;
      let responseData;

      if (httpClient.isAxios !== false) {
        const headers = { 'Accept': 'application/json', 'X-API-Key': apiKey };
        const response = await httpClient.get(statsUrl, {
          headers: headers,
          validateStatus: (status) => status < 500 // Accept 4xx errors as valid responses
        });
        responseStatus = response.status;
        responseData = response.data;
      } else {
        const headers = { 'Accept': 'application/json', 'X-API-Key': apiKey };
        const fetchResponse = await httpClient.client(statsUrl, { method: 'GET', headers: headers });
        responseStatus = fetchResponse.status;
        if (!fetchResponse.ok && fetchResponse.status !== 400) { // Allow 400 for invalid key check
           throw new Error(`HTTP error! status: ${fetchResponse.status}`);
        }
        try {
            responseData = await fetchResponse.json();
        } catch (e) {
            // If response is not JSON (e.g., plain text error), handle gracefully
            responseData = { error: `Non-JSON response: ${await fetchResponse.text()}` };
        }
      }

      // Check response
      if (responseStatus === 200 && responseData?.success) {
        return { valid: true };
      } else if (responseStatus === 400 && responseData?.error === 'Invalid X-API-Key') {
        return { valid: false, reason: 'invalid_key' };
      } else {
        // Any other non-200 or error response indicates a problem
        const errorMsg = responseData?.error || `Unexpected validation status: ${responseStatus}`;
         if (process.env.NODE_ENV === 'development') {
            this.application.consoleMessage({ type: 'error', message: `[Username Logger] API Key validation failed: ${errorMsg}` });
         }
        return { valid: false, reason: 'api_error', error: new Error(errorMsg) };
      }
    } catch (error) {
       if (process.env.NODE_ENV === 'development') {
         this.application.consoleMessage({ type: 'error', message: `[Username Logger] Error during API Key validation request: ${error.message}` });
       }
      return { valid: false, reason: 'api_error', error: error };
    }
  }

  /**
   * Loads an HTTP client for API requests
   * @returns {Promise<Object|null>} The HTTP client or null if not available
   */
  async loadHttpClient() {
    if (this._cachedHttpClient) {
      return this._cachedHttpClient;
    }

    try {
      // Method 1: Try to get axios from dispatch
      this._cachedHttpClient = require('axios');
      if (process.env.NODE_ENV === 'development') {
        this.application.consoleMessage({
          type: 'logger',
          message: `[Username Logger] Loaded axios via direct require`
        });
      }
      return this._cachedHttpClient;
    } catch (axiosLoadError1) {
      try {
        // Method 2: Try global fetch if available
        if (typeof fetch === 'function') {
          this.application.consoleMessage({
            type: 'warn',
            message: `[Username Logger] Using fetch API as fallback after axios loading failed`
          });
          this._cachedHttpClient = { 
            isAxios: false,
            client: fetch 
          };
          return this._cachedHttpClient;
        } else {
          // No HTTP client available
          throw new Error(`Failed to load HTTP client: ${axiosLoadError1.message}`);
        }
      } catch (error) {
        this.application.consoleMessage({
          type: 'error',
          message: `[Username Logger] Failed to load HTTP client: ${error.message}`
        });
        return null;
      }
    }
  }

  /**
   * Checks a username against leak databases
   * @param {string} username - The username to check
   * @param {string} apiKey - The API key to use
   * @param {number} [rateLimit=400] - The rate limit delay in ms
   * @returns {Promise<Object>} The check result
   */
  async checkUsername(username, apiKey, rateLimit = 400) {
    // Add defense-in-depth: Check API key validity here as well
    if (!apiKey || typeof apiKey !== 'string' || apiKey.trim() === '') {
        // Throw an error that will be caught by the calling service
        throw new Error('API key is missing or blank. Cannot perform check.');
    }

    // Wait for rate limit
    await wait(rateLimit);

    // Load HTTP client if not already loaded
    const httpClient = await this.loadHttpClient();
    if (!httpClient) {
      throw new Error('Failed to load HTTP client');
    }

    // Check if we have a valid API key
    if (!apiKey) {
      throw new Error('API key is required');
    }

    // Log request details only in development mode (without revealing full API key)
    const maskedKey = apiKey.length > 8 
      ? `${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}`
      : '********';
    
    if (process.env.NODE_ENV === 'development') {
      this.application.consoleMessage({
        type: 'logger',
        message: `[Username Logger] Making API request for username: ${username}`
      });
      
      this.application.consoleMessage({
        type: 'logger',
        message: `[Username Logger] API URL: ${LEAK_CHECK_API_URL}/${encodeURIComponent(username)}?type=username`
      });
      
      this.application.consoleMessage({
        type: 'logger',
        message: `[Username Logger] Using API key: ${maskedKey}`
      });
    }

    // Perform the request
    let response;
    try {
      // Build the full URL with explicit type parameter
      const apiUrl = `${LEAK_CHECK_API_URL}/${encodeURIComponent(username)}`;
      
      if (httpClient.isAxios !== false) {
        // Using axios with explicit headers
        const headers = {
          'Accept': 'application/json',
          'X-API-Key': String(apiKey) // Ensure it's a string
        };
        
        if (process.env.NODE_ENV === 'development') {
          this.application.consoleMessage({
            type: 'logger',
            message: `[Username Logger] Request headers: ${JSON.stringify({...headers, 'X-API-Key': '[MASKED]'})}`
          });
        }
        
        response = await httpClient.get(apiUrl, {
          params: { type: 'username' },
          headers: headers,
          validateStatus: (status) => status < 500 // Treat 4xx as valid responses to check error message
        });

        // No longer log the specific invalid key error here, it's handled by pre-validation
        // if (response.status === 400 && response.data?.error === 'Invalid X-API-Key') { ... }

        return {
          status: response.status,
          data: response.data,
          error: null
        };
      } else {
        // Using fetch API with explicit headers
        const headers = {
          'Accept': 'application/json',
          'X-API-Key': String(apiKey) // Ensure it's a string
        };
        
        if (process.env.NODE_ENV === 'development') {
          this.application.consoleMessage({
            type: 'logger',
            message: `[Username Logger] Using fetch with headers: ${JSON.stringify({...headers, 'X-API-Key': '[MASKED]'})}`
          });
        }
        
        const fetchResponse = await httpClient.client(`${apiUrl}?type=username`, {
          method: 'GET',
          headers: headers
        });

        // Handle fetch response
        if (!fetchResponse.ok) {
          throw new Error(`HTTP error! status: ${fetchResponse.status}`);
        }

        const responseText = await fetchResponse.text();
        let responseData;
        try {
          responseData = JSON.parse(responseText);
        } catch (jsonError) {
          responseData = {
            error: `Failed to parse response as JSON: ${responseText.substring(0, 100)}...`,
            success: false,
            found: 0
          };
        }

        return {
          status: fetchResponse.status,
          data: responseData,
          error: null
        };
      }
    } catch (error) {
      this.application.consoleMessage({
        type: 'error',
        message: `[Username Logger] API request error: ${error.message}`
      });
      
      return {
        status: 0,
        data: null,
        error: error.message
      };
    }
  }

  /**
   * Extracts passwords from leak check results
   * @param {Object} result - The leak check result
   * @returns {Array<{password: string, isAjc: boolean}>} Array of passwords with source flag
   */
  extractPasswordsFromResult(result) {
    if (!result?.data?.success || result.data.found <= 0 || !Array.isArray(result.data.result)) {
      return [];
    }
    
    const passwords = [];
    
    for (const breach of result.data.result) {
      if (breach.password) {
        let isAjcSource = false;
        
        // Check if source exists and name is AnimalJam.com
        if (breach.source) {
          const sourceName = typeof breach.source === 'object' 
            ? breach.source.name 
            : breach.source;
          
          if (sourceName === "AnimalJam.com") {
            isAjcSource = true;
          }
        }
        
        passwords.push({
          password: breach.password,
          isAjc: isAjcSource
        });
      }
    }
    
    return passwords;
  }

  /**
   * Determines if a response has invalid characters error
   * @param {Object} result - The API response object
   * @returns {boolean} True if the error is due to invalid characters
   */
  isInvalidCharactersError(result) {
    return result.status === 400 && 
           result.data?.error === 'Invalid characters in query';
  }
}

module.exports = ApiService;
