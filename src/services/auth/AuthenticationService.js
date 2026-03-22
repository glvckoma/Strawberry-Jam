const axios = require('axios')
const crypto = require('crypto')

const AUTH_HEADERS = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Origin': 'https://www.animaljam.com',
  'Referer': 'https://www.animaljam.com/game/play',
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) AJClassic/1.5.7 Chrome/87.0.4280.141 Electron/11.5.0 Safari/537.36',
  'Host': 'authenticator.animaljam.com'
}

const SESSION_HEADERS = {
  'Accept': 'application/json',
  'Origin': 'https://www.animaljam.com',
  'Referer': 'https://www.animaljam.com/game/play',
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) AJClassic/1.5.7 Chrome/87.0.4280.141 Electron/11.5.0 Safari/537.36'
}

class AuthenticationService {
  constructor(config) {
    this.config = config
  }

  async authenticate(request) {
    request.domain = 'flash'

    let response
    try {
      response = await axios({
        method: 'POST',
        url: `${this.config.authenticator}/authenticate`,
        headers: AUTH_HEADERS,
        data: request,
        validateStatus: () => true,
        timeout: 15000
      })
    } catch (err) {
      throw new Error('NETWORK_ERROR')
    }

    if (response.status === 200) {
      return response.data
    }

    if (response.status === 401) {
      const authError = response.data || {}
      const errorText = (authError.error || authError.message || '').toLowerCase()
      const errorCode = authError.error_code

      if (errorText.includes('otp') ||
          errorText.includes('two') ||
          errorText.includes('2fa') ||
          errorText.includes('verification') ||
          errorCode === 'otp_required' ||
          errorCode === 'two_factor_required') {
        throw new Error('OTP_NEEDED')
      }

      switch (errorCode) {
        case 100: throw new Error('REFRESH_TOKEN_EXPIRED')
        case 101: throw new Error('WRONG_CREDENTIALS')
        case 102: throw new Error('BANNED')
        case 103: throw new Error('SUSPENDED')
        default: throw new Error('LOGIN_ERROR')
      }
    }

    if (response.status === 422) {
      const authError = response.data || {}
      if (authError.error === 'invalid_otp' || authError.error === 'pending_otp_confirmation') {
        throw new Error('OTP_NEEDED')
      }
      throw new Error('LOGIN_ERROR')
    }

    if (response.status === 403) {
      const errorData = response.data || {}
      const errorText = (errorData.error || errorData.message || '').toLowerCase()
      if (errorText.includes('rate') || errorText.includes('limit') || errorText.includes('too many')) {
        throw new Error('RATE_LIMITED')
      }
      throw new Error('LOGIN_ERROR')
    }

    throw new Error('LOGIN_ERROR')
  }

  async getFlashVars() {
    try {
      const response = await axios({
        method: 'GET',
        url: `${this.config.web}/flashvars`,
        headers: {
          'Host': 'www.animaljam.com',
          'User-Agent': SESSION_HEADERS['User-Agent']
        },
        timeout: 15000
      })
      return typeof response.data === 'string' ? JSON.parse(response.data) : response.data
    } catch (err) {
      throw new Error('NETWORK_ERROR')
    }
  }

  async getPlayerSessionData(authToken, clientVersion) {
    let params = `domain=flash&client_version=${encodeURIComponent(clientVersion)}`

    try {
      const response = await axios({
        method: 'GET',
        url: `${this.config.playerSessionData}/player?${params}`,
        headers: {
          ...SESSION_HEADERS,
          'Authorization': `Bearer ${authToken}`,
          'Host': 'player-session-data.animaljam.com'
        },
        validateStatus: () => true,
        timeout: 15000
      })

      if (response.status !== 200) {
        throw new Error('AUTH_TOKEN_EXPIRED')
      }

      return typeof response.data === 'string' ? JSON.parse(response.data) : response.data
    } catch (err) {
      if (err.message === 'AUTH_TOKEN_EXPIRED') throw err
      throw new Error('NETWORK_ERROR')
    }
  }

  async fullLogin({ username, password, otp, authToken, refreshToken, df, apiPort, serverPort, localeOverride }) {
    let request = {}

    if (refreshToken) {
      request = { refresh_token: refreshToken }
      if (otp) request.otp = otp
    } else if (authToken) {
      request = { auth_token: authToken }
    } else {
      request = { username, password }
      if (otp) request.otp = otp
    }

    request.df = df || crypto.randomUUID()

    const authenticateData = await this.authenticate(request)

    const flashVars = await this.getFlashVars()
    const requestedClientVersion = flashVars.deploy_version

    const playerSessionData = await this.getPlayerSessionData(
      authenticateData.auth_token,
      requestedClientVersion
    )

    if (playerSessionData.game_server && playerSessionData.game_server !== 'NONE_AVAIL') {
      flashVars.smartfoxServer = playerSessionData.game_server
      flashVars.blueboxServer = playerSessionData.game_server
    }

    const userData = {
      username: playerSessionData.screen_name,
      accountType: playerSessionData.game_account_type,
      language: playerSessionData.language,
      authToken: authenticateData.auth_token
    }

    if (authenticateData.refresh_token) {
      userData.refreshToken = authenticateData.refresh_token
    }

    flashVars.content = `http://localhost:${apiPort}/`
    flashVars.clientURL = `http://localhost:${apiPort}/${flashVars.deploy_version}/ajclient.swf`
    flashVars.playerWallHost = `http://localhost:${apiPort}/wall/`
    flashVars.mdUrl = `http://localhost:${apiPort}/game/`
    flashVars.auth_token = authenticateData.auth_token
    flashVars.df = request.df
    flashVars.locale = localeOverride || playerSessionData.language || 'en'
    flashVars.smartfoxServer = '127.0.0.1'
    flashVars.blueboxServer = '127.0.0.1'
    flashVars.smartfoxPort = serverPort.toString()
    flashVars.blueboxPort = serverPort.toString()
    flashVars.username = playerSessionData.screen_name
    flashVars.webRefPath = 'game/play'
    flashVars.clientPlatform = 'electron'
    flashVars.clientPlatformVersion = '5.0.0'
    flashVars.clientOS = process.platform === 'darwin' ? 'mac' : process.platform === 'win32' ? 'win' : 'linux'

    return { userData, flashVars }
  }
}

module.exports = AuthenticationService
