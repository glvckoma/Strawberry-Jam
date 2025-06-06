const { ConnectionMessageTypes } = require('../../Constants')
const { TLSSocket } = require('tls')
const DelimiterTransform = require('../transform')
const { Socket } = require('net')

/**
 * Messages.
 * @constant
 */
const Message = require('../messages')
const XmlMessage = require('../messages/XmlMessage')
const XtMessage = require('../messages/XtMessage')
const JsonMessage = require('../messages/JsonMessage')

/**
 * Connection message blacklist types
 * @type {Set<string>}
 * @constant
 */
const BLACKLIST_MESSAGES = new Set([
  'apiOK',
  'verChk',
  'rndK',
  'login'
])

/**
 * Maximum message queue size before throttling
 * @type {number}
 * @constant
 */
const MAX_QUEUE_SIZE = 1000 // From jam-master

module.exports = class Client {
  /**
   * Constructor.
   * @constructor
   */
  constructor (connection, server) {
    /**
     * The server that instantiated this client
     * @type {Server}
     * @private
     */
    this._server = server

    /**
     * The remote connection to Animal Jam
     * @type {TLSSocket | Socket}
     * @private
     */
    const secureConnection = this._server.application.settings.get('secureConnection')
    this._aj = secureConnection ? new TLSSocket() : new Socket()

    /**
     * Connected indicator
     * @type {boolean}
     * @public
     */
    this.connected = false

    /**
     * The connection that instantiated this client
     * @type {NetifySocket} // Assuming NetifySocket or similar from context
     * @private
     */
    this._connection = connection

    /**
     * Message queue for handling high message volume
     * @type {Object}
     * @private
     */
    this._messageQueue = { // From jam-master
      aj: [],
      connection: [],
      processing: false
    }

    /**
     * Manual disconnect flag to prevent auto-reconnect
     * @type {boolean}
     * @private
     */
    this._manualDisconnect = false // From jam-master

    /**
     * Reconnection attempt counter
     * @type {number}
     * @private
     */
    this._reconnectAttempts = 0 // From jam-master
  }

  /**
   * Validates and returns the appropriate message type
   * @param {string} message
   * @returns {Message|null}
   * @private
   */
  static validate (message) { // Combined from both, essentially jam-master's version
    try {
      if (!message || typeof message !== 'string') return null

      if (message[0] === '<' && message[message.length - 1] === '>') return new XmlMessage(message)
      if (message[0] === '%' && message[message.length - 1] === '%') return new XtMessage(message)
      if (message[0] === '{' && message[message.length - 1] === '}') return new JsonMessage(message)
      return null
    } catch (error) {
      // console.error('[Client Validate] Error validating message:', error); // Optional: for debugging
      return null
    }
  }

  /**
   * Attempts to create a socket connection
   * @returns {Promise<void>}
   * @public
   */
  async connect () { // Adapted from jam-master
    if (this._aj.destroyed) {
      const secureConnection = this._server &&
        this._server.application &&
        this._server.application.settings &&
        typeof this._server.application.settings.get === 'function'
        ? this._server.application.settings.get('secureConnection')
        : false // Default to false if settings path is broken

      this._aj = secureConnection ? new TLSSocket() : new Socket()
    }

    try {
      await this._attemptConnection() // From jam-master

      this._reconnectAttempts = 0 // From jam-master
      this._manualDisconnect = false // From jam-master

      this._setupTransforms()
    } catch (error) {
      if (this._server && this._server.application) {
        this._server.application.consoleMessage({
          message: `Connection error: ${error.message}`,
          type: 'error'
        })
      }

      const shouldAutoReconnect = this._server &&
        this._server.application &&
        this._server.application.settings &&
        typeof this._server.application.settings.get === 'function'
        ? this._server.application.settings.get('autoReconnect') !== false // Default to true if not set
        : true // Default to true if settings path is broken

      if (shouldAutoReconnect && !this._manualDisconnect) {
        await this._handleReconnection() // From jam-master
      }
    }
  }

  /**
   * Attempts the actual socket connection with timeout
   * @returns {Promise<void>}
   * @private
   */
  async _attemptConnection () { // From jam-master
    return new Promise((resolve, reject) => {
      let connectionTimeout = null
      const timeoutDuration = (this._server && this._server.application && this._server.application.settings && this._server.application.settings.get('connectionTimeout')) || 10000;


      const onError = (err) => {
        cleanupListeners()
        clearTimeout(connectionTimeout)
        reject(err)
      }

      const onConnected = () => {
        cleanupListeners()
        clearTimeout(connectionTimeout)
        this.connected = true

        if (this._server && this._server.application) { // Check if application exists
            this._server.application.emit('connection:change', true)
        }
        resolve()
      }

      const cleanupListeners = () => {
        this._aj.off('error', onError)
        this._aj.off('connect', onConnected)
      }

      connectionTimeout = setTimeout(() => {
        cleanupListeners()
        this._aj.destroy(); // Ensure socket is destroyed on timeout
        reject(new Error(`Connection timed out after ${timeoutDuration / 1000} seconds`))
      }, timeoutDuration)

      this._aj.once('error', onError)
      this._aj.once('connect', onConnected)

      const smartfoxServer = (this._server && this._server.application && this._server.application.settings && this._server.application.settings.get('smartfoxServer')) || 'lb-iss04-classic-prod.animaljam.com';
      
      if (!smartfoxServer || typeof smartfoxServer !== 'string' || !smartfoxServer.includes('animaljam')) {
        cleanupListeners();
        clearTimeout(connectionTimeout);
        reject(new Error('Invalid server address. Unable to connect.'));
        return;
      }
      
      this._aj.connect({
        host: smartfoxServer,
        port: 443, // Assuming SSL, common for SmartFox
        rejectUnauthorized: false // Common for self-signed or dev certs
      })
    })
  }

  /**
   * Handle reconnection attempts with exponential backoff
   * @returns {Promise<void>}
   * @private
   */
  async _handleReconnection () { // From jam-master
    const maxReconnectAttempts = (this._server && this._server.application && this._server.application.settings && this._server.application.settings.get('maxReconnectAttempts')) || 5

    if (this._reconnectAttempts >= maxReconnectAttempts) {
      if (this._server && this._server.application) {
        this._server.application.consoleMessage({
          message: `Failed to reconnect after ${maxReconnectAttempts} attempts.`,
          type: 'error'
        })
      }
      return
    }

    this._reconnectAttempts++

    const baseDelay = 1000
    const maxDelay = 30000
    const jitter = Math.random() * 0.3 // 0-30% jitter

    const delay = Math.min(
      Math.pow(2, this._reconnectAttempts) * baseDelay * (1 + jitter),
      maxDelay
    )
    
    if (this._server && this._server.application) {
      this._server.application.consoleMessage({
        message: `Connection lost, attempting to reconnect in ${Math.round(delay / 1000)}s (${this._reconnectAttempts}/${maxReconnectAttempts})`,
        type: 'warn'
      })
    }

    await new Promise(resolve => setTimeout(resolve, delay))
    return this.connect() // Recursive call to connect
  }


  /**
   * Sets up the necessary transforms for socket connections.
   * @private
   */
  _setupTransforms () { // Adapted from jam-master to use _queueMessage
    const ajTransform = new DelimiterTransform(0x00)
    const connectionTransform = new DelimiterTransform(0x00)

    this._aj
      .pipe(ajTransform)
      .on('data', (message) => {
        message = message.toString() // Already done in DelimiterTransform, but good practice
        try {
          const validatedMessage = this.constructor.validate(message)
          if (validatedMessage) {
            this._queueMessage({ // Use queue from jam-master
              type: ConnectionMessageTypes.aj,
              message: validatedMessage,
              packet: message
            })
          }
        } catch (error) {
          if (this._server && this._server.application) {
            this._server.application.consoleMessage({
              message: `Error processing AJ message: ${error.message}`,
              type: 'error'
            })
          }
        }
      })
      .once('close', () => { // From jam-master
        if (this._server && this._server.application && !this._manualDisconnect) {
            this._server.application.emit('connection:change', false)
        }
        this.disconnect() // Calls our updated disconnect
      })
      .on('error', (err) => { // Added error handling for _aj socket
        if (this._server && this._server.application) {
            this._server.application.consoleMessage({
                message: `AJ Socket Error: ${err.message}`,
                type: 'error'
            });
        }
        // this.disconnect(); // Consider if disconnect is always appropriate here
      });


    this._connection
      .pipe(connectionTransform)
      .on('data', (message) => {
        message = message.toString()
        try {
          const validatedMessage = this.constructor.validate(message)
          if (validatedMessage) {
            this._queueMessage({ // Use queue from jam-master
              type: ConnectionMessageTypes.connection,
              message: validatedMessage,
              packet: message
            })
          }
        } catch (error) {
          if (this._server && this._server.application) {
            this._server.application.consoleMessage({
              message: `Error processing connection message: ${error.message}`,
              type: 'error'
            })
          }
        }
      })
      .once('close', this.disconnect.bind(this)) // Current project's way
      .on('error', (err) => { // Added error handling for _connection socket
        if (this._server && this._server.application) {
            this._server.application.consoleMessage({
                message: `Local Connection Socket Error: ${err.message}`,
                type: 'error'
            });
        }
        // this.disconnect();
      });

    this._processMessageQueue() // From jam-master
  }

  /**
   * Queues a message for processing
   * @param {Object} messageData - Message data to be processed
   * @private
   */
  _queueMessage (messageData) { // From jam-master
    const queueType = messageData.type === ConnectionMessageTypes.aj ? 'aj' : 'connection'
    const queue = this._messageQueue[queueType]

    if (queue.length > MAX_QUEUE_SIZE) {
      if (this._server && this._server.application) {
        this._server.application.consoleMessage({
          message: `Message queue size for ${queueType} exceeds ${MAX_QUEUE_SIZE} items, possible performance issue`,
          type: 'warn'
        })
      }
      // Optional: Implement strategy for oversized queue (e.g., drop oldest)
    }
    queue.push(messageData)

    if (!this._messageQueue.processing) {
      this._processMessageQueue()
    }
  }

  /**
   * Process messages from the queue
   * @private
   */
  async _processMessageQueue () { // From jam-master
    if (this._messageQueue.processing) return

    this._messageQueue.processing = true

    try {
      // Prioritize connection messages slightly, then AJ messages
      while (this._messageQueue.connection.length > 0) {
        const messageData = this._messageQueue.connection.shift()
        await this._processMessage(messageData)
      }

      while (this._messageQueue.aj.length > 0) {
        const messageData = this._messageQueue.aj.shift()
        await this._processMessage(messageData)
      }
    } catch (error) {
      if (this._server && this._server.application) {
        this._server.application.consoleMessage({
          message: `Error processing message queue: ${error.message}`,
          type: 'error'
        })
      }
    } finally {
      this._messageQueue.processing = false
      // If new messages arrived during processing, re-trigger immediately
      if (this._messageQueue.aj.length > 0 || this._messageQueue.connection.length > 0) {
        setImmediate(() => this._processMessageQueue())
      }
    }
  }

  /**
   * Process a single message from the queue
   * @param {Object} messageData - Message data to process
   * @private
   */
  async _processMessage (messageData) { // From jam-master
    try {
      // Ensure message is parsed (it should be if validate worked)
      if (typeof messageData.message.parse === 'function' && !messageData.message.type) { // Check if already parsed
          messageData.message.parse()
      }
      await this._onMessageReceived(messageData)
    } catch (error) {
      if (this._server && this._server.application) {
        this._server.application.consoleMessage({
          message: `Error processing individual message: ${error.message} for packet: ${messageData.packet}`,
          type: 'error'
        })
      }
    }
  }

  /**
   * Sends a connection message
   * @param message
   * @param {Object} options - Send options
   * @returns {Promise<number>}
   * @public
   */
  sendConnectionMessage (message, options = {}) { // From jam-master (passes options)
    return this._sendMessage(this._connection, message, options)
  }

  /**
   * Sends a remote message
   * @param message
   * @param {Object} options - Send options
   * @returns {Promise<number>}
   * @public
   */
  sendRemoteMessage (message, options = {}) { // From jam-master (passes options)
    if (window.IS_DEV) {
      console.log(`[Client] sendRemoteMessage called. Socket writable: ${this._aj && this._aj.writable}, Socket destroyed: ${this._aj && this._aj.destroyed}. Message:`, message);
    }
    if (!this._aj || !this._aj.writable || this._aj.destroyed) {
      console.error(`[Client] Attempted to send remote message, but AJ socket is not writable or is destroyed.`);
      if (this._server && this._server.application) {
        this._server.application.consoleMessage({
          message: `Cannot send message: AJ connection not writable.`,
          type: 'error'
        });
      }
      return Promise.reject(new Error('AJ socket not writable or destroyed.'));
    }
    return this._sendMessage(this._aj, message, options);
  }
  
  /**
   * Attempts to send a single message.
   * @param {Socket} socket - The socket to send through
   * @param {string} message - The message to send
   * @returns {Promise<number>} - The length of the message sent
   * @private
   */
  async _attemptSendInternal (socket, message) {
    // message here is expected to be a string, without the null terminator yet.
    const finalMessageString = message + '\x00';
    const messageBuffer = Buffer.from(finalMessageString);

    if (window.IS_DEV) {
      console.log(`[Client SEND_DEBUG] Attempting to write to ${socket === this._aj ? 'AJ_SOCKET' : 'CONN_SOCKET'}.`);
      console.log(`[Client SEND_DEBUG] Original Message: ${message}`);
      console.log(`[Client SEND_DEBUG] Final String (with \\x00): ${finalMessageString.replace('\x00', '\\x00')}`); // Log \x00 visibly
      console.log(`[Client SEND_DEBUG] Hex Buffer: ${messageBuffer.toString('hex')}`);
      console.log(`[Client SEND_DEBUG] Socket writable: ${socket.writable}, destroyed: ${socket.destroyed}`);
    }
    
    if (!socket.writable || socket.destroyed) {
      console.error(`[Client] _attemptSendInternal: Socket not writable or destroyed. Writable: ${socket.writable}, Destroyed: ${socket.destroyed}`);
      throw new Error('Socket not writable or destroyed in _attemptSendInternal!');
    }

    return new Promise((resolve, reject) => {
      const timeoutDuration = 5000;
      let operationTimeout = setTimeout(() => {
        cleanup();
        reject(new Error('Message send attempt timed out'));
      }, timeoutDuration);

      const onError = (err) => {
        cleanup();
        if (window.IS_DEV) {
          console.error(`[Client SEND_DEBUG] _attemptSendInternal socket error:`, err);
        }
        reject(err);
      };

      const onDrain = () => {
        cleanup();
        if (window.IS_DEV) {
          console.log(`[Client SEND_DEBUG] _attemptSendInternal socket drain.`);
        }
        resolve(messageBuffer.length); // Length of what was intended to be written
      };

      const onClose = () => {
        cleanup();
        if (window.IS_DEV) {
          console.log(`[Client SEND_DEBUG] _attemptSendInternal socket close.`);
        }
        reject(new Error('Socket closed before the message could be sent'));
      };

      const cleanup = () => {
        clearTimeout(operationTimeout);
        socket.off('error', onError);
        socket.off('drain', onDrain);
        socket.off('close', onClose);
      };

      socket.once('error', onError);
      socket.once('drain', onDrain);
      socket.once('close', onClose);

      const writable = socket.write(messageBuffer); // Write the single, combined buffer
      if (window.IS_DEV) {
        console.log(`[Client SEND_DEBUG] socket.write(Buffer) executed. Writable status after write: ${writable}`);
      }

      if (writable) {
        if (window.IS_DEV) {
          console.log(`[Client SEND_DEBUG] Message sent synchronously (Buffer write, writable was true).`);
        }
        cleanup();
        resolve(messageBuffer.length);
      } else {
        if (window.IS_DEV) {
          console.log(`[Client SEND_DEBUG] Message queued (Buffer write, writable was false), waiting for drain or close.`);
        }
      }
    });
  }

  /**
   * Sends a message through the provided socket with retry capability.
   * @param socket
   * @param message
   * @param {Object} options - Send options
   * @param {number} [options.retries=0] - Number of retries
   * @param {number} [options.retryDelay=200] - Delay between retries in ms
   * @returns {Promise<number>}
   * @private
   */
  async _sendMessage (socket, message, { retries = 0, retryDelay = 200 } = {}) { // Kept from previous refactor, now calls _attemptSendInternal
    if (message instanceof Message) message = message.toMessage();

    if (!socket.writable || socket.destroyed) {
      console.error(`[Client] _sendMessage: Initial check failed. Socket not writable or destroyed. Writable: ${socket.writable}, Destroyed: ${socket.destroyed}`);
      throw new Error('Failed to write to socket: Socket initially not writable or destroyed!');
    }

    let attempt = 0;
    let lastError;

    do {
      try {
        if (attempt > 0) {
          await new Promise(resolve => setTimeout(resolve, retryDelay));
           if (this._server && this._server.application) { // Check application exists
            // console.warn(`[Client] Retrying message send (${attempt}/${retries})...`); // Potentially too verbose
          }
        }
        return await this._attemptSendInternal(socket, message);
      } catch (error) {
        lastError = error;
        attempt++;
        if (this._server && this._server.application) {
           console.warn(`[Client] _sendMessage: Attempt ${attempt} failed. Error: ${error.message}`);
        }
      }
    } while (attempt <= retries);
    
    const errorMessage = `Message sending failed after ${retries + 1} attempts: ${lastError?.message || 'Unknown error'}`;
    if (this._server && this._server.application) {
      this._server.application.consoleMessage({
        message: errorMessage,
        type: 'error'
      });
    }
    console.error(`[Client] _sendMessage: ${errorMessage}`);
    throw lastError || new Error('Failed to send message after multiple retries.');
  }


  /**
   * Handles received message.
   * @param {Object} messageData - Message data to process
   * @param {string} messageData.type - Type of the message (aj or connection)
   * @param {Message} messageData.message - The message object
   * @param {string} messageData.packet - The raw message packet
   * @private
   */
  async _onMessageReceived ({ type, message, packet }) { // From jam-master
    if (this._server && this._server.application && this._server.application.dispatch) {
        this._server.application.dispatch.all({ client: this, type, message })
    }


    if (type === ConnectionMessageTypes.aj && packet.includes('cross-domain-policy')) {
      const crossDomainMessage = `<?xml version="1.0"?>
        <!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">
        <cross-domain-policy>
        <allow-access-from domain="*" to-ports="80,443"/>
        </cross-domain-policy>`

      await this.sendConnectionMessage(crossDomainMessage)
      return
    }

    // Handle blacklisted messages
    if (type === ConnectionMessageTypes.connection && BLACKLIST_MESSAGES.has(message.type)) {
      await this.sendRemoteMessage(packet) // Send the raw packet string
      return
    }

    if (message.send) { // message is an instance of Message class here
      if (type === ConnectionMessageTypes.connection) {
        await this.sendRemoteMessage(message) // sendRemoteMessage will call .toMessage() if it's a Message instance
      } else {
        await this.sendConnectionMessage(message) // same here
      }
    }
  }

  /**
   * Disconnects the session from the remote host and server.
   * @param {boolean} manual - Whether this is a manual disconnect
   * @returns {Promise<void>}
   * @public
   */
  async disconnect (manual = false) { // From jam-master
    this._manualDisconnect = manual;

    if (this._connection && !this._connection.destroyed) {
      this._connection.destroy();
    }

    if (this._aj && !this._aj.destroyed) {
      this._aj.destroy();
    }
    
    if (this._server && this._server.application && this._server.application.dispatch && this._server.application.dispatch.intervals) {
        this._server.application.dispatch.intervals.forEach((intervalId) => {
            if (this._server.application.dispatch.clearInterval) { // Check if function exists
                this._server.application.dispatch.clearInterval(intervalId);
            }
        });
        this._server.application.dispatch.intervals.clear();
    }


    if (this.connected) {
      this.connected = false;
      if (this._server && this._server.application && !manual) { // Check application exists
        this._server.application.emit('connection:change', false);
         // Only show disconnect message if not manual and game wasn't just launched
        const wasJustLaunched = (typeof this._wasGameJustLaunched === 'function') ? this._wasGameJustLaunched() : false;
        if (!wasJustLaunched) {
            this._server.application.consoleMessage({
                message: 'Connection to Animal Jam servers closed.',
                type: 'notify'
            });
        }
      }
    }
    
    // Clear queues
    this._messageQueue.aj = [];
    this._messageQueue.connection = [];

    if (this._server && this._server.clients) { // Check server and clients set exist
        this._server.clients.delete(this);
    }
  }
   /**
   * Checks if Animal Jam was just successfully launched.
   * @returns {boolean} True if the game was launched within the last 5 seconds
   * @private
   */
  _wasGameJustLaunched() { // Copied from current project as it's useful
    try {
      const messagesContainer = document.getElementById('messages');
      if (!messagesContainer) return false;
      
      const messages = messagesContainer.getElementsByClassName('message-animate-in');
      if (!messages || messages.length === 0) return false;
      
      const messageCount = Math.min(messages.length, 10); 
      for (let i = messages.length - 1; i >= messages.length - messageCount; i--) {
        const messageElement = messages[i];
        if (!messageElement) continue;
        
        const successText = messageElement.textContent || '';
        if (successText.includes('Successfully launched Animal Jam Classic')) {
          const timestampElement = messageElement.querySelector('.text-xs.text-gray-500');
          if (!timestampElement) return true; 
          
          const timestampText = timestampElement.textContent || '';
          const currentTime = new Date();
          const messageParts = timestampText.split(':');
          
          if (messageParts.length === 3) {
            const messageTime = new Date();
            messageTime.setHours(parseInt(messageParts[0], 10));
            messageTime.setMinutes(parseInt(messageParts[1], 10));
            messageTime.setSeconds(parseInt(messageParts[2], 10));
            
            const timeDiff = currentTime - messageTime;
            return timeDiff < 5000; 
          }
          return true; 
        }
      }
      return false; 
    } catch (e) {
      return false;
    }
  }
}
