const axios = require('axios')

function adaptResponse(axiosResponse, options) {
  if (options.resolveWithFullResponse) {
    return {
      statusCode: axiosResponse.status,
      headers: axiosResponse.headers,
      body: axiosResponse.data
    }
  }
  return axiosResponse.data
}

function buildAxiosConfig(options) {
  const config = {
    url: options.url || options.uri,
    headers: options.headers || {},
    timeout: options.timeout || 10000,
    validateStatus: options.simple === false ? () => true : undefined
  }
  if (options.body) {
    config.data = options.body
  }
  if (options.json === true) {
    config.headers['Content-Type'] = config.headers['Content-Type'] || 'application/json'
  }
  return config
}

module.exports = class HttpClient {
  constructor () {
    throw new Error(`The ${this.constructor.name} class may not be instantiated.`)
  }

  static get baseHeaders () {
    return {
      Host: 'www.animaljam.com',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) AJClassic/1.5.4 Chrome/87.0.4280.141 Electron/11.5.0 Safari/537.36'
    }
  }

  static proxy (options) {
    const url = typeof options === 'string' ? options : options.url
    const headers = typeof options === 'string' ? {} : (options.headers || {})
    return axios({
      method: 'GET',
      url,
      headers,
      responseType: 'stream',
      timeout: 30000
    }).then(response => response.data)
  }

  static async get (options = {}) {
    if (!options.headers) options.headers = this.baseHeaders
    const config = buildAxiosConfig(options)
    config.method = 'GET'
    const response = await axios(config)
    return adaptResponse(response, options)
  }

  static async post (options = {}) {
    if (!options.headers) options.headers = this.baseHeaders
    const config = buildAxiosConfig(options)
    config.method = 'POST'
    const response = await axios(config)
    return adaptResponse(response, options)
  }

  static async fetchFlashvars () {
    const data = await this.get({
      url: 'https://www.animaljam.com/flashvars'
    })
    return typeof data === 'string' ? JSON.parse(data) : data
  }
}
