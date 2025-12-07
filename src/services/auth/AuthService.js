class AuthService {
  constructor(options = {}) {
    this.globals = options.globals || (typeof window !== 'undefined' ? window.globals : null)
    this.showOtpModal = options.showOtpModal || null
    this.getDf = options.getDf || null
    this.getGameData = options.getGameData || null
    this.fetch = options.fetch || null
    this.config = options.config || null
  }

  isTokenExpired(token) {
    if (!token) return true

    const tokenParts = token.split('.')
    if (tokenParts.length !== 3) {
      console.log("Token does not have JWT format (3 parts):", tokenParts.length, "- treating as non-expiring refresh token")
      return false
    }

    try {
      const payloadBase64 = tokenParts[1].replace(/-/g, '+').replace(/_/g, '/')
      const decodedJson = atob(payloadBase64)
      const decoded = JSON.parse(decodedJson)

      if (typeof decoded.exp !== 'number') {
        console.error("Token expiration ('exp') is not a number:", decoded.exp)
        return true
      }

      const nowInSeconds = (Date.now() / 1000)
      return decoded.exp < (nowInSeconds + 5)

    } catch (e) {
      console.error("Failed to decode or parse token:", e)
      return true
    }
  }

  async authenticate(request, customDf, showOtpModalCallback) {
    const showOtp = showOtpModalCallback || this.showOtpModal
    const getDf = this.getDf || (this.globals && (() => this.globals.df))
    const getGameDataFunc = typeof this.getGameData === 'function' ? this.getGameData() : (this.getGameData || null)
    const fetch = this.fetch || (this.globals && this.globals.fetch)
    const config = this.config || (this.globals && this.globals.config)

    if (!fetch || !config) {
      throw new Error("AuthService: fetch or config not available")
    }

    console.log(`[ANIMAL JAM] Starting authentication with Animal Jam authenticator: ${config.authenticator}/authenticate`)
    request.domain = "flash"

    try {
      const freshDf = await (typeof window !== 'undefined' && window.ipc ? window.ipc.getDf() : (getDf ? getDf() : null))

      if (freshDf && this.globals) {
        this.globals.df = freshDf
        console.log(`[ANIMAL JAM] Using fresh DF for authentication`)
      } else if (!freshDf) {
        console.warn("[AUTH] Failed to get fresh DF from main process")
      }
    } catch (err) {
      console.warn(`[AUTH] Error getting fresh df: ${err.message}`)
    }

    if (!this.globals || !this.globals.df) {
      console.error("[AUTH] No valid DF available, authentication may fail")
    }

    const dfToUse = customDf || (this.globals ? this.globals.df : null)
    request.df = dfToUse

    console.log(`[ANIMAL JAM] Sending authentication request`, {
      domain: request.domain,
      hasUsername: !!request.username,
      hasPassword: !!request.password,
      hasRefreshToken: !!request.refresh_token,
      hasOtp: !!request.otp,
      hasDf: !!request.df,
      fullRequest: request
    })

    // Build headers with Origin, Referer, User-Agent, and Accept to match server expectations
    const authHeaders = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    }
    
    // Add Origin and Referer headers if config.origin is available
    if (config.origin) {
      authHeaders["Origin"] = config.origin
      authHeaders["Referer"] = `${config.origin}/game/play`
    }
    
    // Add User-Agent to match expected format
    authHeaders["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) AJClassic/1.5.7 Chrome/87.0.4280.141 Electron/11.5.0 Safari/537.36"

    const response = await fetch(`${config.authenticator}/authenticate`, {
      method: "POST",
      mode: "cors",
      headers: authHeaders,
      body: JSON.stringify(request),
    }, [401, 403, 422, 500])

    if (response.status === 200) {
      const authenticateData = JSON.parse(await response.text())
      console.log("[AUTH] Authentication response data:", {
        hasAuthToken: !!authenticateData.auth_token,
        hasRefreshToken: !!authenticateData.refresh_token,
        authTokenLength: authenticateData.auth_token ? authenticateData.auth_token.length : 0,
        refreshTokenLength: authenticateData.refresh_token ? authenticateData.refresh_token.length : 0,
        refreshTokenParts: authenticateData.refresh_token ? authenticateData.refresh_token.split('.').length : 0,
        fullResponse: authenticateData
      })
      const authenticatedByToken = (request.refresh_token !== undefined)
      if (getGameDataFunc) {
        return await getGameDataFunc(authenticateData, authenticatedByToken, dfToUse)
      } else {
        return authenticateData
      }
    }

    if (response.status === 401) {
      const authError = JSON.parse(await response.text())

      const errorText = (authError.error || authError.message || '').toLowerCase()
      const errorCode = authError.error_code

      if (errorText.includes('otp') ||
          errorText.includes('two') ||
          errorText.includes('2fa') ||
          errorText.includes('verification') ||
          errorCode === 'otp_required' ||
          errorCode === 'two_factor_required') {
        if (showOtp) showOtp()
        throw new Error("OTP_NEEDED")
      }

      switch (authError.error_code) {
        case 100: throw new Error("REFRESH_TOKEN_EXPIRED")
        case 101: throw new Error("WRONG_CREDENTIALS")
        case 102: throw new Error("BANNED")
        case 103: throw new Error("SUSPENDED")
        default: throw new Error("LOGIN_ERROR")
      }
    }

    if (response.status === 422) {
      console.log("[AUTH] Received 422 status - checking for OTP requirements")

      try {
        const responseText = await response.text()
        console.log("[AUTH] 422 response body:", responseText)

        const authError = JSON.parse(responseText)
        console.log("[AUTH] Parsed 422 error:", authError)

        if (authError.error == "invalid_otp" || authError.error == "pending_otp_confirmation") {
          console.log("[AUTH] OTP requirement detected, showing modal")
          if (showOtp) showOtp()
          throw new Error("OTP_NEEDED")
        }

        if (authError.error == "username_not_present") {
          console.error("[AUTH] 422 error: username_not_present - this usually means auth_token was used instead of refresh_token")
          throw new Error("LOGIN_ERROR")
        }

        console.log("[AUTH] No OTP requirement found in 422 response, throwing LOGIN_ERROR")
        throw new Error("LOGIN_ERROR")
      } catch (parseErr) {
        console.error("[AUTH] Error parsing 422 response:", parseErr)
        throw new Error("LOGIN_ERROR")
      }
    }

    if (response.status === 403) {
      console.error("[AUTH] Received 403 Forbidden status")
      
      try {
        const responseText = await response.text()
        console.error("[AUTH] 403 response body:", responseText)
        
        // Check if response body contains rate limiting information
        if (responseText) {
          try {
            const errorData = JSON.parse(responseText)
            const errorText = (errorData.error || errorData.message || '').toLowerCase()
            
            // Check for rate limiting indicators
            if (errorText.includes('rate') || errorText.includes('limit') || errorText.includes('too many')) {
              console.log("[AUTH] Rate limiting detected in 403 response")
              throw new Error("RATE_LIMITED")
            }
          } catch (parseErr) {
            // If we can't parse, continue with generic 403 handling
          }
        }
        
        // Check for rate limit headers
        const rateLimitRemaining = response.headers.get('X-RateLimit-Remaining')
        const rateLimitReset = response.headers.get('X-RateLimit-Reset')
        
        if (rateLimitRemaining === '0' || rateLimitRemaining === null) {
          console.log("[AUTH] Rate limiting detected via headers")
          throw new Error("RATE_LIMITED")
        }
        
        // Generic 403 - could be IP blocked, missing permissions, etc.
        console.error("[AUTH] 403 Forbidden - possible IP block or missing permissions")
        throw new Error("LOGIN_ERROR")
      } catch (err) {
        // If error is already one we want to throw (RATE_LIMITED, LOGIN_ERROR), re-throw it
        if (err.message === "RATE_LIMITED" || err.message === "LOGIN_ERROR") {
          throw err
        }
        // Otherwise, generic 403 error
        console.error("[AUTH] Could not parse 403 response:", err)
        throw new Error("LOGIN_ERROR")
      }
    }

    console.error("[AUTH] Unexpected response status:", response.status)

    try {
      const responseText = await response.text()
      console.error("[AUTH] Response body:", responseText)

      const errorData = JSON.parse(responseText)
      const errorText = (errorData.error || errorData.message || '').toLowerCase()

      if (errorText.includes('otp') ||
          errorText.includes('two') ||
          errorText.includes('2fa') ||
          errorText.includes('verification')) {
        console.log("[AUTH] Found OTP requirement in unexpected response, showing OTP modal")
        if (showOtp) showOtp()
        throw new Error("OTP_NEEDED")
      }
    } catch (parseErr) {
      console.error("[AUTH] Could not parse response body:", parseErr)
    }

    throw new Error("ERROR")
  }

  async authenticateWithAuthToken(authToken, showOtpModalCallback) {
    console.log("[AUTH] authenticateWithAuthToken called - validating token through authenticate function")
    console.log("[AUTH] Token being validated:", authToken ? authToken.substring(0, 10) + '...' : 'null')
    const request = {auth_token: authToken}
    try {
      const result = await this.authenticate(request, null, showOtpModalCallback)
      console.log("[AUTH] Token validation successful")
      return result
    } catch (err) {
      console.error("[AUTH] Token validation failed:", err.message)
      throw err
    }
  }

  async authenticateWithRefreshToken(refreshToken, otp, showOtpModalCallback) {
    const request = {refresh_token: refreshToken}
    if (otp) {
      request.otp = otp
    }
    return await this.authenticate(request, null, showOtpModalCallback)
  }

  async authenticateWithPassword(username, password, otp, customDf, showOtpModalCallback) {
    const request = {username, password}
    if (otp) {
      request.otp = otp
    }
    return await this.authenticate(request, customDf, showOtpModalCallback)
  }
}

if (typeof module !== 'undefined' && module.exports) {
  module.exports = AuthService
}

if (typeof window !== 'undefined') {
  window.AuthService = AuthService
}

