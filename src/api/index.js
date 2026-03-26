const { urlencoded, json } = require('body-parser')
const express = require('express')

const FilesController = require('./controllers/FilesController')
const { API_SERVER_PORTS } = require('../Constants')

const ApiRouter = require('./routes')

const app = express()

const API_PORT = API_SERVER_PORTS[0]

let actualApiPort = null

app.use(urlencoded({ extended: true }))
app.use(json())

app.use('/', ApiRouter)

FilesController.initializeSwf().catch(err => {
  console.error('[API Server] Critical error during SWF initialization:', err)
})

async function startServer() {
  await new Promise((resolve, reject) => {
    const server = app.listen(API_PORT, '127.0.0.1', () => {
      actualApiPort = API_PORT
      console.log(`[API Server] Successfully started on port ${API_PORT}`)

      global.apiServer = server

      if (process.send) {
        process.send({ type: 'api-port', port: API_PORT })
      }

      resolve()
    })

    server.on('error', (error) => {
      if (error.code === 'EADDRINUSE') {
        console.error(`[API Server] Port ${API_PORT} is required but is already in use.`)
      }
      reject(error)
    })
  })
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
