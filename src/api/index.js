const { urlencoded, json } = require('body-parser')
const express = require('express')

const FilesController = require('./controllers/FilesController')
const { API_SERVER_PORTS } = require('../Constants')

const ApiRouter = require('./routes')

const app = express()

let actualApiPort = null

app.use(urlencoded({ extended: true }))
app.use(json())

app.use('/', ApiRouter)

FilesController.initializeSwf().catch(err => {
  console.error('[API Server] Critical error during SWF initialization:', err)
})

async function tryListenOnPort(port) {
  return new Promise((resolve, reject) => {
    const server = app.listen(port, '127.0.0.1', () => {
      resolve(server)
    })
    server.on('error', reject)
  })
}

async function startServer() {
  for (const port of API_SERVER_PORTS) {
    try {
      const server = await tryListenOnPort(port)
      actualApiPort = port
      global.apiServer = server
      console.log(`[API Server] Successfully started on port ${port}`)
      if (process.send) {
        process.send({ type: 'api-port', port })
      }
      return
    } catch (error) {
      if (error.code === 'EADDRINUSE') {
        console.warn(`[API Server] Port ${port} is already in use, trying next...`)
      } else {
        console.error(`[API Server] Failed to bind port ${port}:`, error.message)
      }
    }
  }
  throw new Error(`All API ports (${API_SERVER_PORTS.join(', ')}) are unavailable`)
}

function getActualApiPort() {
  return actualApiPort
}

function closeServer() {
  return new Promise((resolve) => {
    if (global.apiServer) {
      global.apiServer.close(() => {
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
