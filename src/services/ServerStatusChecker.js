/**
 * Server Status Checker Service
 * Handles checking Animal Jam server availability by mimicking actual game authentication
 */

const HttpClient = require('./HttpClient');

class ServerStatusChecker {
  /**
   * Check if Animal Jam servers are online by attempting authentication
   * This mimics the actual game login process to get accurate status
   * @param {string} serverHost - The server host to check (defaults to lb-iss04-classic-prod.animaljam.com)
   * @returns {Promise<{isOnline: boolean, responseTime: number, timestamp: number, server: string, accessStatus: string, statusCode: number|null, details: string}>} Status result
   */
  static async checkServerStatus(serverHost = 'lb-iss04-classic-prod.animaljam.com') {
    const result = {
      isOnline: false,
      responseTime: 0,
      timestamp: Date.now(),
      server: serverHost,
      accessStatus: 'unknown', // 'unknown', 'ok', 'blocked', 'rate_limited', 'auth_error', 'network_error', 'server_error'
      statusCode: null,
      details: ''
    };
    
    try {
      const startTime = performance.now();
      
      // Use the same authentication endpoint as the actual game
      const authEndpoint = 'https://authenticator.animaljam.com/authenticate';
      
      // Create a request that mimics the actual game authentication
      // We use intentionally invalid credentials to test server response
      const authRequest = {
        domain: 'flash',
        username: 'test_user_' + Math.random().toString(36).substr(2, 9), // Random invalid username
        password: 'invalid_password_' + Math.random().toString(36).substr(2, 9), // Random invalid password
        df: this.generateRandomDF() // Generate a random DF like the game would
      };
      
      const options = {
        url: authEndpoint,
        timeout: 8000, // 8 second timeout (longer than before since auth is slower)
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) AJClassic/1.5.7 Chrome/87.0.4280.141 Electron/11.5.0 Safari/537.36',
          'Origin': 'https://www.animaljam.com',
          'Referer': 'https://www.animaljam.com/game/play'
        },
        body: JSON.stringify(authRequest),
        resolveWithFullResponse: true,
        simple: false // Don't throw on non-2xx responses
      };
      
      // Make the authentication request
      const response = await HttpClient.post(options);
      const endTime = performance.now();
      
      result.responseTime = Math.round(endTime - startTime);
      result.statusCode = response.statusCode;
      
      // Analyze the response based on actual game authentication logic
      if (response.statusCode === 401) {
        // Authentication failed - this is actually GOOD news for server status
        // It means the server is online and processing authentication requests
        result.isOnline = true;
        
        try {
          const errorData = JSON.parse(response.body);
          const errorCode = errorData.error_code;
          
          // Map error codes like the actual game does
          switch (errorCode) {
            case 101: // WRONG_CREDENTIALS - Expected with our invalid test credentials
              result.accessStatus = 'ok';
              result.details = 'Servers online - Authentication service responding normally';
              break;
            case 102: // BANNED
              result.accessStatus = 'ok'; // Server is up, just this specific request is banned
              result.details = 'Servers online - Test request was banned (normal behavior)';
              break;
            case 103: // SUSPENDED  
              result.accessStatus = 'ok'; // Server is up, just this specific request is suspended
              result.details = 'Servers online - Test request was suspended (normal behavior)';
              break;
            default:
              result.accessStatus = 'auth_error';
              result.details = `Authentication service returned error code: ${errorCode}`;
          }
        } catch (parseError) {
          // If we can't parse the error, but got a 401, server is likely up
          result.accessStatus = 'ok';
          result.details = 'Servers online - Authentication service responding (unparseable error)';
        }
      }
      else if (response.statusCode === 402 || response.statusCode === 403) {
        // Payment required or Forbidden - likely IP blocked
        result.isOnline = true;
        result.accessStatus = 'blocked';
        result.details = 'Servers online but your IP appears to be blocked';
      }
      else if (response.statusCode === 422) {
        // Unprocessable request - server is online but request was malformed
        result.isOnline = true;
        result.accessStatus = 'ok';
        result.details = 'Servers online - Request was unprocessable (expected with test data)';
      }
      else if (response.statusCode === 429) {
        // Too Many Requests - clear rate limiting
        result.isOnline = true;
        result.accessStatus = 'rate_limited';
        result.details = 'Servers online but rate limiting requests';
      }
      else if (response.statusCode === 503) {
        // Service Unavailable - could be down OR rate limited, treat as potentially down
        result.isOnline = false;
        result.accessStatus = 'server_error';
        result.details = 'Authentication service unavailable - servers may be down or under maintenance';
      }
      else if (response.statusCode === 200) {
        // Unexpected success with invalid credentials - should not happen
        result.isOnline = true;
        result.accessStatus = 'unusual';
        result.details = 'Servers online but authentication behaved unexpectedly';
      }
      else if (response.statusCode >= 500) {
        // Server errors indicate the authentication service is having issues
        result.isOnline = false;
        result.accessStatus = 'server_error';
        result.details = `Authentication servers experiencing errors (HTTP ${response.statusCode})`;
      }
      else {
        // Other status codes - be conservative and assume server issues
        result.isOnline = false;
        result.accessStatus = 'server_error';
        result.details = `Authentication service returned unexpected status: HTTP ${response.statusCode}`;
      }
      
      // If we successfully determined status from auth endpoint, try to get actual server info
      if (result.isOnline && result.accessStatus === 'ok') {
        try {
          // Try to get the actual server assignment (this might fail, which is okay)
          const serverInfo = await this.getServerInfo(serverHost);
          if (serverInfo) {
            result.server = serverInfo;
          }
        } catch (serverInfoError) {
          // Ignore errors getting server info - we already know servers are up
        }
      }
      
    } catch (error) {
      // Network or connection error
      result.isOnline = false;
      result.accessStatus = 'network_error';
      result.details = `Cannot connect to Animal Jam authentication servers: ${error.message}`;
      
      // Try the fallback check to the game server directly
      try {
        const fallbackResult = await this.fallbackServerCheck(serverHost);
        return fallbackResult;
      } catch (fallbackError) {
        // Both primary and fallback failed
        result.details += ` (Fallback also failed: ${fallbackError.message})`;
      }
    }
    
    return result;
  }
  
  /**
   * Generate a random DF (device fingerprint) like the game does
   * @returns {string} Random DF string
   * @private
   */
  static generateRandomDF() {
    // Generate a UUID-like string that mimics the game's DF format
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }
  
  /**
   * Try to get actual server information from the flashvars endpoint
   * @param {string} defaultServer - Default server name
   * @returns {Promise<string>} Server name
   * @private
   */
  static async getServerInfo(defaultServer) {
    try {
      const flashvarsData = await HttpClient.fetchFlashvars();
      if (flashvarsData && flashvarsData.smartfoxServer) {
        // Convert internal server format to external format like the game does
        let serverName = flashvarsData.smartfoxServer;
        if (serverName.includes('.internal')) {
          serverName = serverName.replace(/\.(stage|prod)\.animaljam\.internal$/, '-$1.animaljam.com');
          serverName = 'lb-' + serverName;
        }
        return serverName;
      }
    } catch (error) {
      // Ignore errors - we'll use the default
    }
    return defaultServer;
  }
  
  /**
   * Fallback check that directly pings the game server
   * @param {string} serverHost - The server host to check
   * @param {number} [port=8080] - The port to check on the server
   * @returns {Promise<{isOnline: boolean, responseTime: number, timestamp: number, server: string, accessStatus: string, statusCode: number|null, details: string}>} Status result
   * @private
   */
  static async fallbackServerCheck(serverHost, port = 8080) {
    const result = {
      isOnline: false,
      responseTime: 0,
      timestamp: Date.now(),
      server: serverHost,
      accessStatus: 'unknown',
      statusCode: null,
      details: ''
    };
    
    try {
      const startTime = performance.now();
      
      // Try to connect to the SmartFox server port (this is what the game actually connects to)
      const options = {
        url: `https://${serverHost}:${port}`,
        timeout: 5000,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) AJClassic/1.5.7 Chrome/87.0.4280.141 Electron/11.5.0 Safari/537.36',
          'Accept': '*/*',
          'Connection': 'close'
        },
        resolveWithFullResponse: true,
        simple: false
      };
      
      const response = await HttpClient.get(options);
      const endTime = performance.now();
      
      result.responseTime = Math.round(endTime - startTime);
      result.statusCode = response.statusCode;
      
      // Any response means the server is up
      result.isOnline = true;
      result.accessStatus = 'ok';
      result.details = `Game server responding on port ${port} (HTTP ${response.statusCode})`;
      
    } catch (error) {
      // Check if it's a connection refused or timeout (indicating server might be down)
      if (error.code === 'ECONNREFUSED' || error.code === 'ETIMEDOUT') {
        result.isOnline = false;
        result.accessStatus = 'network_error';
        result.details = `Cannot connect to game server ${serverHost}:${port} - Server appears to be offline`;
      } else {
        // Other errors might indicate server is up but not responding to HTTP
        result.isOnline = true;
        result.accessStatus = 'ok';
        result.details = `Game server ${serverHost} appears to be running (rejected HTTP connection as expected)`;
      }
    }
    
    return result;
  }
}

module.exports = ServerStatusChecker;
