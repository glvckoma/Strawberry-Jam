/**
 * Server Status Checker Service
 * Handles checking Animal Jam server availability
 */

const HttpClient = require('./HttpClient');

class ServerStatusChecker {
  /**
   * Check if Animal Jam servers are online
   * @param {string} serverHost - The server host to check (defaults to lb-iss04-classic-prod.animaljam.com)
   * @returns {Promise<{isOnline: boolean, responseTime: number, timestamp: number, server: string, accessStatus: string, statusCode: number|null}>} Status result
   */
  static async checkServerStatus(serverHost = 'lb-iss04-classic-prod.animaljam.com') {
    const result = {
      isOnline: false,
      responseTime: 0,
      timestamp: Date.now(),
      server: serverHost,
      accessStatus: 'unknown', // 'unknown', 'ok', 'blocked', 'limited', 'error'
      statusCode: null
    };
    
    try {
      const startTime = performance.now();
      
      // Try to check the session endpoint first - which is what the actual game uses
      // This is more reliable than checking the server directly
      const sessionEndpoint = 'https://www.animaljam.com/api/playerSession?platform=classic';
      
      const options = {
        url: sessionEndpoint,
        timeout: 5000, // 5 second timeout
        headers: {
          // Headers that mimic the actual game client
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) AJClassic/1.5.7 Chrome/87.0.4280.141 Electron/11.5.0 Safari/537.36',
          'Origin': 'https://www.animaljam.com',
          'Referer': 'https://www.animaljam.com/game/play'
        },
        resolveWithFullResponse: true,
        simple: false // Don't throw on non-2xx responses
      };
      
      // Make the request and measure time
      const response = await HttpClient.get(options);
      const endTime = performance.now();
      
      result.responseTime = Math.round(endTime - startTime);
      
      // Store the status code for debugging
      if (response && typeof response === 'object') {
        result.statusCode = response.statusCode || null;
      }
      
      // Parse response if it's valid JSON to get the actual server status
      if (response && typeof response === 'object') {
        if (response.statusCode) {
          // Check for specific status codes that indicate different issues
          if (response.statusCode === 200) {
            // Perfect - we have access
            result.isOnline = true;
            result.accessStatus = 'ok';
            
            // Try to parse server name from response
            if (response.body) {
              try {
                const sessionData = JSON.parse(response.body);
                if (sessionData && sessionData.gameServer) {
                  result.server = sessionData.gameServer;
                }
              } catch (parseError) {
                // Ignore parse errors, we already know server is up
              }
            }
          } 
          else if (response.statusCode === 403 || response.statusCode === 401) {
            // Server is up but we're blocked
            result.isOnline = true;
            result.accessStatus = 'blocked';
          }
          else if (response.statusCode === 429 || response.statusCode === 503) {
            // Server is up but we're rate limited
            // 429 = Too Many Requests, 503 = Service Unavailable (used for rate limiting)
            result.isOnline = true;
            result.accessStatus = 'limited';
          }
          else if (response.statusCode >= 500) {
            // Server errors indicate the server is having issues
            result.isOnline = false;
            result.accessStatus = 'error';
          }
          else {
            // Other status codes (300s, other 400s) - server is responding but with unusual status
            result.isOnline = true;
            result.accessStatus = 'unusual';
          }
        } else if (response.body) {
          // We got a response body but no status code - assume server is up
          result.isOnline = true;
          result.accessStatus = 'ok';
        }
      }
      
      // If we couldn't determine status from the API, try the direct check
      if (result.accessStatus === 'unknown') {
        return await this.fallbackServerCheck(serverHost);
      }
    } catch (error) {
      // If the first check failed with an error, try the direct server check
      return await this.fallbackServerCheck(serverHost);
    }
    
    return result;
  }
  
  /**
   * Fallback check that directly pings the server
   * @param {string} serverHost - The server host to check
   * @returns {Promise<{isOnline: boolean, responseTime: number, timestamp: number, server: string, accessStatus: string, statusCode: number|null}>} Status result
   * @private
   */
  static async fallbackServerCheck(serverHost) {
    const result = {
      isOnline: false,
      responseTime: 0,
      timestamp: Date.now(),
      server: serverHost,
      accessStatus: 'unknown',
      statusCode: null
    };
    
    try {
      const startTime = performance.now();
      
      // Attempt to connect to server with timeout
      const options = {
        url: `https://${serverHost}`,
        timeout: 5000, // 5 second timeout
        headers: {
          ...HttpClient.baseHeaders,
          'Host': serverHost,
          'Accept': '*/*',
          'Connection': 'close'
        },
        resolveWithFullResponse: true,
        simple: false // Don't throw on non-2xx responses
      };
      
      // Make the request and measure time
      const response = await HttpClient.get(options);
      const endTime = performance.now();
      
      // Store response time
      result.responseTime = Math.round(endTime - startTime);
      
      // Process the response
      if (response && typeof response === 'object') {
        result.statusCode = response.statusCode || null;
        
        // Analyze status code to determine server status
        if (response.statusCode) {
          if (response.statusCode === 403 || response.statusCode === 401) {
            // Server is up but access is blocked
            result.isOnline = true;
            result.accessStatus = 'blocked';
          }
          else if (response.statusCode === 429 || response.statusCode === 503) {
            // Server is up but we're rate limited
            result.isOnline = true;
            result.accessStatus = 'limited';
          }
          else if (response.statusCode >= 500) {
            // Server errors
            result.isOnline = false;
            result.accessStatus = 'error';
          }
          else {
            // Any other response means server is up
            result.isOnline = true;
            result.accessStatus = 'unusual'; // We don't expect 2xx from direct server ping
          }
        } else {
          // No status code but got a response object
          result.isOnline = true;
          result.accessStatus = 'unusual';
        }
      }
    } catch (error) {
      // Connection error - could be network, timeout, or server down
      result.isOnline = false;
      result.accessStatus = 'network-error';
      result.error = error.message;
    }
    
    return result;
  }
}

module.exports = ServerStatusChecker; 