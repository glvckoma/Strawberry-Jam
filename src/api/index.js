const { urlencoded, json } = require('body-parser')
const express = require('express')

const FilesController = require('./controllers/FilesController')
const { API_SERVER_PORTS } = require('../Constants')

const ApiRouter = require('./routes')

const app = express()

const FALLBACK_PORTS = [...API_SERVER_PORTS]

let actualApiPort = null

app.use(urlencoded({ extended: true }))
app.use(json())

app.use('/', ApiRouter)

FilesController.initializeSwf().catch(err => {
  console.error('[API Server] Critical error during SWF initialization:', err)
})

async function startServer() {
  let lastError = null

  for (const port of FALLBACK_PORTS) {
    let server = null
    try {
      await new Promise((resolve, reject) => {
        server = app.listen(port, '127.0.0.1', () => {
          actualApiPort = port
          console.log(`[API Server] Successfully started on port ${port}`)

          global.apiServer = server

          if (process.send) {
            process.send({ type: 'api-port', port: port })
          }

          resolve()
        })

        server.on('error', reject)
      })

      // Success! Break out of loop
      break

    } catch (error) {
      lastError = error
      if (server) {
        try {
          server.close()
        } catch (closeError) {
        }
        server = null
      }
      if (error.code === 'EADDRINUSE') {
        console.warn(`[API Server] Port ${port} is busy, trying next port...`)
        continue
      } else {
        console.warn(`[API Server] Port ${port} failed with error: ${error.message}, trying next port...`)
        continue
      }
    }
  }

  if (!actualApiPort) {
    const errorMessage = `[API Server] Could not find an available port after trying ports: ${FALLBACK_PORTS.join(', ')}`
    console.error(errorMessage + (lastError ? `. Last error: ${lastError.message}` : ''))
    process.exit(1)
  }
}

/**
 * Get the actual API server port
 * @returns {number|null} The port the API server is running on
 */
function getActualApiPort() {
  return actualApiPort
}

/**
 * Gracefully close the API server
 * @returns {Promise<void>}
 */
function closeServer() {
  return new Promise((resolve) => {
    if (global.apiServer) {
      global.apiServer.close(() => {
        console.log('[API Server] Server closed successfully')
        global.apiServer = null
        actualApiPort = null
        resolve()
      })
    } else {
      resolve()
    }
  })
}

function setupGracefulShutdown() {
  const shutdown = async (signal) => {
    console.log(`[API Server] Received ${signal}, closing server...`)
    await closeServer()
    process.exit(0)
  }

  process.on('SIGTERM', () => shutdown('SIGTERM'))
  process.on('SIGINT', () => shutdown('SIGINT'))
  
  process.on('message', (message) => {
    if (message && message.type === 'shutdown') {
      shutdown('shutdown-message').catch(() => process.exit(0))
    }
  })
}

// Start the server
startServer().catch(error => {
  console.error('[API Server] Failed to start:', error.message)
  process.exit(1)
})

setupGracefulShutdown()

// Export the port getter and cleanup function for IPC access
module.exports = { getActualApiPort, closeServer }
