const { urlencoded, json } = require('body-parser')
const express = require('express')

const FilesController = require('./controllers/FilesController')

/**
 * Routes
 */
const ApiRouter = require('./routes')

/**
 * Express instance
 */
const app = express()

/**
 * Fallback ports to try if the primary port is busy.
 * @type {number[]}
 */
const FALLBACK_PORTS = [8080, 8081, 8082, 9080, 3000]

/**
 * The actual port the API server is listening on.
 * @type {?number}
 */
let actualApiPort = null

/**
 * Middleware
 */
app.use(urlencoded({ extended: true }))
app.use(json())

/**
 * Routers
 */
app.use('/', ApiRouter)

/**
 * Initialize SWF backups on startup
 */
FilesController.initializeSwf().catch(err => {
  console.error('[API Server] Critical error during SWF initialization:', err)
})

/**
 * Auto-detect available port and start server
 */
async function startServer() {
  let lastError = null

  for (const port of FALLBACK_PORTS) {
    let server = null
    try {
      await new Promise((resolve, reject) => {
        server = app.listen(port, '127.0.0.1', () => {
          actualApiPort = port
          console.log(`[API Server] Successfully started on port ${port}`)
          
          // Store reference for cleanup
          global.apiServer = server
          
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
