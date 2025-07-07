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
FilesController.initialize().catch(err => {
  console.error('[API Server] Critical error during SWF initialization:', err)
})

/**
 * Auto-detect available port and start server
 */
async function startServer() {
  let lastError = null

  for (const port of FALLBACK_PORTS) {
    try {
      await new Promise((resolve, reject) => {
        const server = app.listen(port, '127.0.0.1', () => {
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
      if (error.code === 'EADDRINUSE') {
        console.warn(`[API Server] Port ${port} is busy, trying next port...`)
        continue
      } else {
        // Re-throw non-port-busy errors immediately
        throw error
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

// Start the server
startServer().catch(error => {
  console.error('[API Server] Failed to start:', error.message)
  process.exit(1)
})

// Export the port getter for IPC access
module.exports = { getActualApiPort }
