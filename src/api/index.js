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
 * Handle raw body for multipart/form-data requests to preserve binary data
 */
app.use((req, res, next) => {
  if (req.path.toLowerCase().startsWith('/game/mp')) {
    // Use raw body parser for /game/mp requests to get binary data as buffer
    // This handles multipart/form-data and preserves the boundary information
    express.raw({ type: '*/*', limit: '50mb' })(req, res, next);
  } else {
    next();
  }
});

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
    let resolved = false
    
    try {
      await new Promise((resolve, reject) => {
        const timeout = setTimeout(() => {
          if (!resolved) {
            resolved = true
            reject(new Error(`Timeout waiting for server to start on port ${port}`))
          }
        }, 5000)

        server = app.listen(port, '127.0.0.1', () => {
          if (!resolved) {
            resolved = true
            clearTimeout(timeout)
            actualApiPort = port
            console.log(`[API Server] Successfully started on port ${port}`)
            
            if (process.send) {
              process.send({ type: 'api-port-ready', port: actualApiPort })
            }
            
            global.apiServer = server
            
            resolve()
          }
        })

        server.on('error', (err) => {
          if (!resolved) {
            resolved = true
            clearTimeout(timeout)
            
            if (server) {
              try {
                server.close()
              } catch (closeErr) {
              }
              server = null
            }
            
            if (err.code === 'EADDRINUSE') {
              console.warn(`[API Server] Port ${port} is busy, trying next port...`)
              resolve('EADDRINUSE')
            } else {
              reject(err)
            }
          }
        })
      })

      if (actualApiPort) {
        break
      }

      if (server) {
        try {
          server.close()
        } catch (closeErr) {
        }
        server = null
      }

    } catch (error) {
      lastError = error
      if (server) {
        try {
          server.close()
        } catch (closeErr) {
        }
        server = null
      }
      
      if (error.code === 'EADDRINUSE' || error === 'EADDRINUSE') {
        console.warn(`[API Server] Port ${port} is busy, trying next port...`)
        continue
      } else {
        console.error(`[API Server] Error starting on port ${port}:`, error.message)
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

// Start the server
startServer().catch(error => {
  console.error('[API Server] Failed to start:', error.message)
  process.exit(1)
})

// Export the port getter for IPC access
module.exports = { getActualApiPort }
