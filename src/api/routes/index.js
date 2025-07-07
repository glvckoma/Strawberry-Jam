const { Router } = require('express')

/**
 * Controllers.
 */
const FilesController = require('../controllers/FilesController')

/**
 * Express router.
 * @type {Router}
 * @const
 */
const router = Router()

/**
 * AJ Classic close notification route.
 * @public
 */
router.post('/api/aj-classic-close', (request, response) => {
  try {
    console.log('[API] Received AJ Classic close notification');
    
    // Send message to parent process (main Electron process) via IPC
    if (process.send) {
      process.send({ type: 'aj-classic-closing' });
      console.log('[API] Sent aj-classic-closing message to main process');
    } else {
      console.warn('[API] process.send is not available - running in main process?');
    }
    
    response.status(200).json({ success: true, message: 'AJ Classic close notification received' });
  } catch (error) {
    console.error('[API] Error handling AJ Classic close notification:', error);
    response.status(500).json({ success: false, error: error.message });
  }
})

/**
 * Animal Jam files route.
 * @public
 */
router.get(/^\/(\d{4})\/ajclient\.swf$/, (request, response) => FilesController.game(request, response))
router.get('*', (request, response) => FilesController.index(request, response))

module.exports = router
