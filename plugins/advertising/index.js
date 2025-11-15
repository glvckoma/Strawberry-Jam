document.addEventListener('DOMContentLoaded', () => {
  const { dispatch } = jam;

  let isActive = false;
  let currentInterval = null;
  let messageIndex = 0;

  const messagesContainer = document.getElementById('messages-container');
  const addMessageBtn = document.getElementById('add-message-btn');
  const startBtn = document.getElementById('start-btn');
  const stopBtn = document.getElementById('stop-btn');
  const saveBtn = document.getElementById('save-btn');
  const loadBtn = document.getElementById('load-btn');
  const intervalInput = document.getElementById('interval');
  const orderType = document.getElementById('order-type');
  const statusIndicator = document.getElementById('status-indicator');
  const fileInput = document.getElementById('file-input');
  const messageTemplate = document.getElementById('message-template');
  const randomIntervalToggle = document.getElementById('random-interval-toggle');
  const staticIntervalContainer = document.getElementById('static-interval-container');
  const randomIntervalContainer = document.getElementById('random-interval-container');
  const minIntervalInput = document.getElementById('min-interval');
  const maxIntervalInput = document.getElementById('max-interval');

  /**
   * Saves all settings and messages to local storage
   */
  function saveState() {
    const messages = getAllMessages();
    const state = {
      messages,
      interval: intervalInput.value,
      orderType: orderType.value,
      randomIntervalEnabled: randomIntervalToggle.checked,
      minInterval: minIntervalInput.value,
      maxInterval: maxIntervalInput.value,
    };
    localStorage.setItem('advertisingPluginState', JSON.stringify(state));
  }

  /**
   * Loads all settings and messages from local storage
   */
  function loadState() {
    const state = JSON.parse(localStorage.getItem('advertisingPluginState'));
    if (!state) {
      addMessageBox();
      return;
    }

    intervalInput.value = state.interval || 60;
    orderType.value = state.orderType || 'sequential';
    randomIntervalToggle.checked = state.randomIntervalEnabled || false;
    minIntervalInput.value = state.minInterval || 30;
    maxIntervalInput.value = state.maxInterval || 90;

    if (Array.isArray(state.messages) && state.messages.length > 0) {
      messagesContainer.innerHTML = '';
      state.messages.forEach(messageText => {
        addMessageBox(messageText);
      });
    } else {
      addMessageBox();
    }
    
    toggleIntervalView();
  }

  /**
   * Toggles the visibility of interval input fields based on the checkbox
   */
  function toggleIntervalView() {
    if (randomIntervalToggle.checked) {
      staticIntervalContainer.classList.add('hidden');
      randomIntervalContainer.classList.remove('hidden');
    } else {
      staticIntervalContainer.classList.remove('hidden');
      randomIntervalContainer.classList.add('hidden');
    }
  }

  /**
   * Adds a new message input box to the container
   * @param {string} [text=''] - Optional text to pre-fill the textarea
   */
  function addMessageBox(text = '') {
    const messageCount = messagesContainer.children.length + 1;
    const templateContent = messageTemplate.content.cloneNode(true);
    const newMessage = templateContent.querySelector('.message-input');

    newMessage.querySelector('.message-label').textContent = `Message ${messageCount}`;
    const messageContent = newMessage.querySelector('.message-content');
    messageContent.value = text;
    messageContent.addEventListener('input', saveState);

    newMessage.querySelector('.preview-btn').addEventListener('click', function() {
      const message = this.closest('.message-input').querySelector('.message-content').value;
      previewMessage(message);
    });

    newMessage.querySelector('.remove-btn').addEventListener('click', function() {
      if (messagesContainer.children.length <= 1) {
        showToast("You must have at least one message", "warning");
        return;
      }
      this.closest('.message-input').remove();
      updateMessageLabels();
      saveState();
    });

    messagesContainer.appendChild(newMessage);
    
    const scrollableParent = messagesContainer.parentElement.parentElement;
    scrollableParent.scrollTop = scrollableParent.scrollHeight;
  }

  /**
   * Updates the labels for all message boxes to show the correct sequence
   */
  function updateMessageLabels() {
    document.querySelectorAll('.message-input').forEach((element, index) => {
      element.querySelector('.message-label').textContent = `Message ${index + 1}`;
    });
  }

  /**
   * Retrieves all message content from the UI
   * @returns {Array<string>} Array of all message texts
   */
  function getAllMessages() {
    const messages = [];
    document.querySelectorAll('.message-content').forEach(element => {
      messages.push(element.value);
    });
    return messages;
  }

  /**
   * Starts the advertising rotation
   */
  async function startAdvertising() {
    if (isActive) return;

    const initialRoom = await dispatch.getState('room');
    if (!initialRoom) {
      showToast("You must be in a room to start advertising.", "error");
      return;
    }

    const messages = getAllMessages().filter(msg => msg.trim() !== "");
    if (messages.length === 0) {
      showToast("Please enter at least one message", "error");
      return;
    }

    isActive = true;
    messageIndex = 0;

    startBtn.disabled = true;
    stopBtn.disabled = false;
    statusIndicator.classList.remove('bg-error-red/20', 'text-error-red');
    statusIndicator.classList.add('bg-highlight-green/20', 'text-highlight-green');
    statusIndicator.innerHTML = '<i class="fas fa-circle mr-1"></i> Active';

    // Send the first message immediately, then schedule the next one.
    sendNextMessage();
    showToast("Auto advertising started", "success");

  }

  /**
   * Schedules the next message to be sent
   */
  function scheduleNextMessage() {
    if (!isActive) return;

    let delay;
    if (randomIntervalToggle.checked) {
      const min = parseInt(minIntervalInput.value, 10) * 1000;
      const max = parseInt(maxIntervalInput.value, 10) * 1000;
      if (min >= max) {
        showToast("Max interval must be greater than min interval", "error");
        stopAdvertising();
        return;
      }
      delay = Math.floor(Math.random() * (max - min + 1)) + min;
    } else {
      delay = parseInt(intervalInput.value, 10) * 1000;
    }

    if (delay < 10000) {
        delay = 10000;
        showToast("Interval is too low. Defaulting to 10 seconds.", "warning");
    }

    currentInterval = setTimeout(sendNextMessage, delay);
  }

  /**
   * Stops the advertising rotation
   */
  function stopAdvertising() {
    if (!isActive) return;

    clearTimeout(currentInterval);
    currentInterval = null;
    isActive = false;

    startBtn.disabled = false;
    stopBtn.disabled = true;
    statusIndicator.classList.remove('bg-highlight-green/20', 'text-highlight-green');
    statusIndicator.classList.add('bg-error-red/20', 'text-error-red');
    statusIndicator.innerHTML = '<i class="fas fa-circle mr-1"></i> Inactive';

    showToast("Auto advertising stopped", "warning");
  }

  /**
   * Sends the next message in the rotation and schedules the following one.
   */
  async function sendNextMessage() {
    if (!isActive) return;

    const messages = getAllMessages().filter(msg => msg.trim() !== "");

    if (messages.length === 0) {
      stopAdvertising();
      return;
    }

    let messageToSend;
    if (orderType.value === "random") {
      const randomIndex = Math.floor(Math.random() * messages.length);
      messageToSend = messages[randomIndex];
    } else {
      if (messageIndex >= messages.length) {
        messageIndex = 0;
      }
      messageToSend = messages[messageIndex];
      messageIndex++;
    }

    const textualRoomId = await dispatch.getState('room');
    let internalRoomIdValue = await dispatch.getState('internalRoomId');
    let parsedInternalRoomId = null;

    if (internalRoomIdValue !== null && internalRoomIdValue !== undefined) {
        parsedInternalRoomId = parseInt(internalRoomIdValue, 10);
        if (isNaN(parsedInternalRoomId)) {
            console.warn(`Auto Advertising: internalRoomId '${internalRoomIdValue}' could not be parsed to a number.`);
            parsedInternalRoomId = null;
        }
    }

    let targetRoomId = null;
    if (parsedInternalRoomId !== null) {
        targetRoomId = parsedInternalRoomId;
    } else if (textualRoomId) {
        targetRoomId = textualRoomId;
        console.warn(`Auto Advertising: Parsed internalRoomId not available (original value: ${internalRoomIdValue}). Falling back to textualRoomId: ${textualRoomId}. pubMsg might not work correctly.`);
    }

    if (!targetRoomId) {
      console.warn("Auto Advertising: Room ID (internal or textual) not available when trying to send message. Skipping this tick.");
      scheduleNextMessage();
      return;
    }

    try {
      const packet = `<msg t="sys"><body action="pubMsg" r="${targetRoomId}"><txt><![CDATA[${messageToSend}%9]]></txt></body></msg>`;
      await dispatch.sendRemoteMessage(packet);
      scheduleNextMessage(); // Schedule the next message after successful send
    } catch (error) {
      console.error("Error sending message:", error);
      showToast("Error sending message", "error");
      scheduleNextMessage(); // Still schedule next attempt even on error
    }
  }

  /**
   * Saves the current configuration to a JSON file
   */
  function saveConfig() {
    const config = {
      interval: parseInt(intervalInput.value),
      orderType: orderType.value,
      messages: getAllMessages(),
      randomIntervalEnabled: randomIntervalToggle.checked,
      minInterval: minIntervalInput.value,
      maxInterval: maxIntervalInput.value,
    };

    const blob = new Blob([JSON.stringify(config, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);

    const a = document.createElement('a');
    a.href = url;
    a.download = `advertising-config-${new Date().toISOString().slice(0, 10)}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);

    showToast("Configuration saved", "success");
  }

  /**
   * Triggers file selection dialog to load a configuration file
   */
  function loadConfig() {
    fileInput.click();
  }

  /**
   * Shows a preview of a message
   * @param {string} message - The message to preview
   */
  async function previewMessage(message) {
    if (!message || message.trim() === "") {
      showToast("No message to preview", "error");
      return;
    }

    const textualRoomId = await dispatch.getState('room');
    let internalRoomIdValue = await dispatch.getState('internalRoomId');
    let parsedInternalRoomId = null;

    if (internalRoomIdValue !== null && internalRoomIdValue !== undefined) {
        parsedInternalRoomId = parseInt(internalRoomIdValue, 10);
        if (isNaN(parsedInternalRoomId)) {
            console.warn(`Auto Advertising (Preview): internalRoomId '${internalRoomIdValue}' could not be parsed to a number.`);
            parsedInternalRoomId = null;
        }
    }

    let targetRoomId = null;
    if (parsedInternalRoomId !== null) {
        targetRoomId = parsedInternalRoomId;
    } else if (textualRoomId) {
        targetRoomId = textualRoomId;
        console.warn(`Auto Advertising (Preview): Parsed internalRoomId not available (original value: ${internalRoomIdValue}). Falling back to textualRoomId: ${textualRoomId}. pubMsg might not work correctly.`);
    }

    if (!targetRoomId) {
      showToast("You must be in a room to preview a message.", "error");
      console.warn("Auto Advertising (Preview): Room ID (internal or textual) not available.");
      return;
    }

    try {
      const packet = `<msg t="sys"><body action="pubMsg" r="${targetRoomId}"><txt><![CDATA[${message}%9]]></txt></body></msg>`;
      await dispatch.sendRemoteMessage(packet);
      showToast(`Preview sent: "${message}"`, "success");
    } catch (error) {
      console.error("Error sending preview message:", error);
      showToast("Error sending preview message", "error");
    }
  }

  /**
   * Displays a toast notification
   * @param {string} message - The message to display
   * @param {string} type - The notification type: 'success', 'error', 'warning', or 'info'
   */
  function showToast(message, type = 'success') {
    const toastContainer = document.getElementById('toast-container');

    const toastClasses = {
      success: 'bg-highlight-green text-white',
      error: 'bg-error-red text-white',
      warning: 'bg-highlight-yellow text-white',
      info: 'bg-blue-400 text-white'
    };

    const toast = document.createElement('div');
    toast.className = `px-4 py-2 rounded shadow-lg mb-2 flex items-center ${toastClasses[type] || toastClasses.info}`;
    toast.innerHTML = `
      <i class="fas fa-${
        type === 'success' ? 'check-circle' :
        type === 'error' ? 'times-circle' :
        type === 'warning' ? 'exclamation-circle' :
        'info-circle'
      } mr-2"></i>
      ${message}
    `;

    toastContainer.appendChild(toast);

    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transition = 'opacity 0.5s';
      setTimeout(() => toast.remove(), 500);
    }, 3000);
  }

  fileInput.addEventListener('change', async function(event) {
    try {
      const file = event.target.files[0];
      if (!file) return;

      const text = await file.text();
      const config = JSON.parse(text);

      intervalInput.value = config.interval || 60;
      orderType.value = config.orderType || "sequential";
      randomIntervalToggle.checked = config.randomIntervalEnabled || false;
      minIntervalInput.value = config.minInterval || 30;
      maxIntervalInput.value = config.maxInterval || 90;
      toggleIntervalView();

      if (Array.isArray(config.messages)) {
        messagesContainer.innerHTML = '';
        config.messages.forEach(messageText => {
          addMessageBox(messageText);
        });
        if (config.messages.length === 0) {
          addMessageBox();
        }
      }

      showToast("Configuration loaded", "success");
      saveState();
    } catch (error) {
      console.error("Error loading configuration:", error);
      showToast("Error loading configuration", "error");
    }

    fileInput.value = "";
  });

  addMessageBtn.addEventListener('click', () => addMessageBox());
  startBtn.addEventListener('click', startAdvertising);
  stopBtn.addEventListener('click', stopAdvertising);
  saveBtn.addEventListener('click', saveConfig);
  loadBtn.addEventListener('click', loadConfig);
  randomIntervalToggle.addEventListener('change', () => {
    toggleIntervalView();
    saveState();
  });
  intervalInput.addEventListener('input', saveState);
  minIntervalInput.addEventListener('input', saveState);
  maxIntervalInput.addEventListener('input', saveState);
  orderType.addEventListener('change', saveState);

  window.addEventListener('beforeunload', stopAdvertising);

  loadState();
});
