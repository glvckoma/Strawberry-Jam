const { urlencoded, json } = require('body-parser')
const express = require('express')

/**
 * Routes
 */
const ApiRouter = require('./routes')

/**
 * Express instance
 */
const app = express()

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
 * Express listen with error handling and async callback
 */
const server = app.listen(8080, '127.0.0.1', () => {
  console.log('[API Server] Successfully started on port 8080')
})

server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.error('[API Server] Port 8080 is already in use. Attempting to use port 8081...')
    const fallbackServer = app.listen(8081, '127.0.0.1', () => {
      console.log('[API Server] Successfully started on fallback port 8081')
    })
    
    fallbackServer.on('error', (fallbackError) => {
      console.error('[API Server] Failed to start on both ports 8080 and 8081:', fallbackError.message)
      process.exit(1)
    })
  } else {
    console.error('[API Server] Failed to start server:', error.message)
    process.exit(1)
  }
})
