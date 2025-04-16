/**
 * Login Packet Manipulator UI Plugin
 * Author: Glockoma
 * For Strawberry Jam (fork of Jam by sxip)
 * 
 * Allows viewing, intercepting, editing, blocking, and replaying login-related packets.
 * 
 * WARNING: Manipulating login packets can result in account bans, instability, or data loss.
 * Use at your own risk.
 */

console.log("[LoginPacketManipulator] index.js loaded at " + new Date().toISOString());
(function () {
  // Function to initialize the plugin logic
  function initializePlugin() {
    if (!window.jam || !window.jam.dispatch || !window.jam.application || typeof window.jam.onPacket !== 'function') {
      console.error("[UI Plugin] Core not fully detected after jam-ready, window.jam:", window.jam);
      alert("Strawberry Jam core not fully initialized. This plugin must be run as a UI plugin. Please restart.");
      const errorDiv = document.getElementById('errorDisplay'); // Assuming an error display div exists
      if (errorDiv) {
        errorDiv.textContent = "Error: Could not connect to Jam core. Please restart the application.";
        errorDiv.classList.remove('hidden');
      }
      return;
    }

    // --- State ---
    let originalLoginPacket = null; // Store the full original packet
    let interceptEnabled = true; // Simple flag to enable/disable interception
    let unsubscribePacketListener = null; // To store the unsubscribe function

    // --- DOM Elements ---
    const editorContainer = document.getElementById("login-packet-editor");
    const sendButton = document.getElementById("send-modified-login");
    const interceptInCheckbox = document.getElementById("intercept-in");
    const executeOnLoginCheckbox = document.getElementById("executeOnLogin"); // New checkbox
    const xmlUsernameInput = document.getElementById("xmlUsername"); // New input
    const xmlPasswordInput = document.getElementById("xmlPassword"); // New input
    const statusPanel = document.getElementById("status-panel");

    // --- localStorage Keys ---
    const STORAGE_KEY_EXECUTE_ON_LOGIN = 'loginManipulator_executeOnLogin';
    const STORAGE_KEY_XML_USERNAME = 'loginManipulator_xmlUsername';
    const STORAGE_KEY_XML_PASSWORD = 'loginManipulator_xmlPassword';

    // --- Utility Functions ---
    function nowTime() {
      return new Date().toLocaleTimeString();
    }

    function logStatus(msg, type = "info") {
      if (statusPanel) {
        statusPanel.textContent = `[${nowTime()}] ${msg}`;
        statusPanel.className = `fixed bottom-0 left-0 w-full px-4 py-2 text-xs ${
          type === 'error' ? 'bg-red-700 text-white' : type === 'warn' ? 'bg-yellow-600 text-black' : 'bg-gray-800 text-gray-300'
        }`;
      }
      // Also log to main console for audit
      try {
        window.jam.application.consoleMessage(type, "[LoginPacketManipulator] " + msg);
      } catch (e) {
        console.error("[UI Plugin] Error sending console message:", e);
      }
    }

    // --- State Persistence (Outgoing XML) ---
    function saveOutgoingState() {
      try {
        localStorage.setItem(STORAGE_KEY_EXECUTE_ON_LOGIN, executeOnLoginCheckbox.checked);
        localStorage.setItem(STORAGE_KEY_XML_USERNAME, xmlUsernameInput.value);
        localStorage.setItem(STORAGE_KEY_XML_PASSWORD, xmlPasswordInput.value);
        // logStatus("Outgoing injection settings saved.", "info"); // Optional: Can be noisy
      } catch (e) {
        logStatus("Error saving outgoing state: " + e.message, "error");
      }
    }

    function loadOutgoingState() {
      try {
        const execute = localStorage.getItem(STORAGE_KEY_EXECUTE_ON_LOGIN) === 'true';
        const username = localStorage.getItem(STORAGE_KEY_XML_USERNAME) || '';
        const password = localStorage.getItem(STORAGE_KEY_XML_PASSWORD) || '';

        executeOnLoginCheckbox.checked = execute;
        xmlUsernameInput.value = username;
        xmlPasswordInput.value = password;
        logStatus("Loaded saved outgoing injection settings.", "info");
      } catch (e) {
        logStatus("Error loading outgoing state: " + e.message, "error");
      }
    }

    // --- Editor Display (Incoming JSON) ---
    function displayLoginPacketEditor(packetObj) {
      if (!editorContainer) return;

      originalLoginPacket = packetObj; // Store the full packet
      const dataObject = packetObj?.b?.o;

      if (!dataObject) {
        logStatus("Received packet is not the expected login structure.", "warn");
        return;
      }

      editorContainer.innerHTML = ''; // Clear previous content
      logStatus("Login packet received. Displaying editor.");

      // Organize fields into sections
      const sections = {
        "Connection Info": ["_cmd", "sessionId", "userId", "dbUserId", "perUserAvId", "uuid", "status"],
        "User Info": ["userName", "userNameModerated", "avName", "email", "pendingEmail"],
        "Currency & Resources": [
          "gemsCount", "ticketsCount", "diamondsCount", "ecoCreditsCount", "ecoCredits",
          "orbsCount", "bambooCount", "woodCount", "goldCount", "silverCount", "strawCount",
          "stoneCount", "gemstoneCount"
        ],
        "Member Status": [
          "accountType", "subscriptionSourceType", "accountTypeChanged", 
          "numDaysLeftOnSubscription", "numAJHQGiftCards", "numAJHQBulkGiftCards", "dailyGiftIndex"
        ],
        "Chat & Privacy": [
          "statusId", "sgChatType", "sgChatTypeNonDegraded",
          "denPrivacySettings", "eCardPrivacySettings", "webWallStatus", "playerWallSettings"
        ],
        "User Flags & Stats": [
          "isModerator", "isGuide", "pendingFlags", "interactions",
          "hasOnlineBuddies", "recyclePercentage", "numLogins"
        ],
        "Den & Pet": ["activeDenRoomInvId", "activePetInvId"],
        "Activity Data": [
          "createdAt", "jamaaDate", "numRedemptionCards", "numUnreadECards",
          "lastBroadcastMessage"
        ],
        "Lists & Defs": ["newspaperDefs", "usableAdoptAPetDefs"]
      };

      // Create sections
      Object.entries(sections).forEach(([sectionName, fields]) => {
        const sectionDiv = document.createElement('div');
        sectionDiv.className = 'mb-6';
        
        const sectionTitle = document.createElement('h3');
        sectionTitle.className = 'text-lg font-bold text-gray-300 mb-2 border-b border-gray-700 pb-1';
        sectionTitle.textContent = sectionName;
        sectionDiv.appendChild(sectionTitle);

        // Add fields that exist in the packet
        fields.forEach(key => {
          if (key === "params") return; // Skip rendering params in the main editor
          if (key in dataObject) {
            const value = dataObject[key];
            const valueType = typeof value;
            const isComplex = Array.isArray(value) || (value !== null && valueType === 'object');
            const valueString = isComplex ? JSON.stringify(value, null, 2) : String(value);

            const fieldDiv = document.createElement('div');
            fieldDiv.className = 'flex flex-col sm:flex-row sm:items-center mb-2';

            const label = document.createElement('label');
            label.textContent = `${key}:`;
            label.className = 'w-full sm:w-1/4 font-medium text-gray-300 mb-1 sm:mb-0';
            label.htmlFor = `edit-${key}`;

            // Add tooltips for special fields
            if (key === 'statusId') {
              label.title = 'Login Status Code:\n-11: Account in use\n-12: Account maintenance\n-14: Too many connections\n-15: Banned user\n-16: Server maintenance\n-24: Client version mismatch';
            }
            else if (key === 'sgChatType' || key === 'sgChatTypeNonDegraded') {
              label.title = 'Chat Safety Type (2 = Restricted Mode)';
            }

            let inputElement;
            if (isComplex) {
              inputElement = document.createElement('textarea');
              inputElement.rows = 3;
              inputElement.className = 'w-full sm:w-3/4 p-1 bg-gray-700 text-gray-200 border border-gray-600 rounded font-mono text-xs';
            } else if (valueType === 'boolean') {
              inputElement = document.createElement('select');
              inputElement.className = 'w-full sm:w-3/4 p-1 bg-gray-700 text-gray-200 border border-gray-600 rounded text-xs';
              const optionTrue = document.createElement('option'); optionTrue.value = 'true'; optionTrue.textContent = 'true';
              const optionFalse = document.createElement('option'); optionFalse.value = 'false'; optionFalse.textContent = 'false';
              inputElement.appendChild(optionTrue); inputElement.appendChild(optionFalse);
              inputElement.value = String(value);
            } else {
              inputElement = document.createElement('input');
              inputElement.type = valueType === 'number' ? 'number' : 'text';
              inputElement.className = 'w-full sm:w-3/4 p-1 bg-gray-700 text-gray-200 border border-gray-600 rounded text-xs';
            }

            inputElement.id = `edit-${key}`;
            inputElement.value = valueString;
            inputElement.dataset.key = key;
            inputElement.dataset.type = valueType;
            inputElement.dataset.isComplex = isComplex;

            fieldDiv.appendChild(label);
            fieldDiv.appendChild(inputElement);
            sectionDiv.appendChild(fieldDiv);
          }
        });

        // Only add section if it has fields
        if (sectionDiv.children.length > 1) {
          editorContainer.appendChild(sectionDiv);
        }
      });

      // Add any remaining fields that weren't in predefined sections
      const remainingFields = Object.keys(dataObject).filter(key => 
        !Object.values(sections).flat().includes(key)
      );

      if (remainingFields.length > 0) {
        const otherSection = document.createElement('div');
        otherSection.className = 'mb-6';
        
        const sectionTitle = document.createElement('h3');
        sectionTitle.className = 'text-lg font-bold text-gray-300 mb-2 border-b border-gray-700 pb-1';
        sectionTitle.textContent = 'Other Fields';
        otherSection.appendChild(sectionTitle);

        remainingFields.forEach(key => {
          if (key === "params") return; // Skip rendering params in the "Other Fields" section too
          const value = dataObject[key];
          const valueType = typeof value;
          const isComplex = Array.isArray(value) || (value !== null && valueType === 'object');
          const valueString = isComplex ? JSON.stringify(value, null, 2) : String(value);

          const fieldDiv = document.createElement('div');
          fieldDiv.className = 'flex flex-col sm:flex-row sm:items-center mb-2';

          const label = document.createElement('label');
          label.textContent = `${key}:`;
          label.className = 'w-full sm:w-1/4 font-medium text-gray-300 mb-1 sm:mb-0';
          label.htmlFor = `edit-${key}`;

          let inputElement;
          if (isComplex) {
            inputElement = document.createElement('textarea');
            inputElement.rows = 3;
            inputElement.className = 'w-full sm:w-3/4 p-1 bg-gray-700 text-gray-200 border border-gray-600 rounded font-mono text-xs';
          } else if (valueType === 'boolean') {
            inputElement = document.createElement('select');
            inputElement.className = 'w-full sm:w-3/4 p-1 bg-gray-700 text-gray-200 border border-gray-600 rounded text-xs';
            const optionTrue = document.createElement('option'); optionTrue.value = 'true'; optionTrue.textContent = 'true';
            const optionFalse = document.createElement('option'); optionFalse.value = 'false'; optionFalse.textContent = 'false';
            inputElement.appendChild(optionTrue); inputElement.appendChild(optionFalse);
            inputElement.value = String(value);
          } else {
            inputElement = document.createElement('input');
            inputElement.type = valueType === 'number' ? 'number' : 'text';
            inputElement.className = 'w-full sm:w-3/4 p-1 bg-gray-700 text-gray-200 border border-gray-600 rounded text-xs';
          }

          inputElement.id = `edit-${key}`;
          inputElement.value = valueString;
          inputElement.dataset.key = key;
          inputElement.dataset.type = valueType;
          inputElement.dataset.isComplex = isComplex;

          fieldDiv.appendChild(label);
          fieldDiv.appendChild(inputElement);
          otherSection.appendChild(fieldDiv);
        });

        // Only add section if it has fields
        if (otherSection.children.length > 1) {
          editorContainer.appendChild(otherSection);
        }
      }

      // Render params as a flat list in the params-section (moved here)
      const paramsSection = document.getElementById("params-section");
      const paramsFields = document.getElementById("params-fields");
      if (dataObject.params && typeof dataObject.params === 'object' && paramsSection && paramsFields) {
        paramsSection.classList.remove("hidden");
        paramsFields.innerHTML = ""; // Clear previous params
        Object.entries(dataObject.params).forEach(([paramKey, paramValue]) => {
          const paramType = typeof paramValue;
          const isParamComplex = Array.isArray(paramValue) || (paramValue !== null && paramType === 'object');
          const paramValueString = isParamComplex ? JSON.stringify(paramValue, null, 2) : String(paramValue);

          const paramDiv = document.createElement('div');
          paramDiv.className = 'flex flex-col sm:flex-row sm:items-center mb-2';

          const paramLabel = document.createElement('label');
          paramLabel.textContent = `${paramKey}:`;
          paramLabel.className = 'w-full sm:w-1/3 font-medium text-gray-300 mb-1 sm:mb-0';
          paramLabel.htmlFor = `edit-${paramKey}`;

          let paramInput;
          if (isParamComplex) {
            paramInput = document.createElement('textarea');
            paramInput.rows = 3;
            paramInput.className = 'w-full sm:w-2/3 p-1 bg-gray-700 text-gray-200 border border-gray-600 rounded font-mono text-xs';
          } else if (paramType === 'boolean') {
            paramInput = document.createElement('select');
            paramInput.className = 'w-full sm:w-2/3 p-1 bg-gray-700 text-gray-200 border border-gray-600 rounded text-xs';
            const optionTrue = document.createElement('option'); optionTrue.value = 'true'; optionTrue.textContent = 'true';
            const optionFalse = document.createElement('option'); optionFalse.value = 'false'; optionFalse.textContent = 'false';
            paramInput.appendChild(optionTrue); paramInput.appendChild(optionFalse);
            paramInput.value = String(paramValue);
          } else {
            paramInput = document.createElement('input');
            paramInput.type = paramType === 'number' ? 'number' : 'text';
            paramInput.className = 'w-full sm:w-2/3 p-1 bg-gray-700 text-gray-200 border border-gray-600 rounded text-xs';
          }

          paramInput.id = `edit-${paramKey}`;
          paramInput.value = paramValueString;
          paramInput.dataset.key = paramKey;
          paramInput.dataset.type = paramType;
          paramInput.dataset.isComplex = isParamComplex;

          paramDiv.appendChild(paramLabel);
          paramDiv.appendChild(paramInput);
          paramsFields.appendChild(paramDiv);
        });
      } else if (paramsSection) {
        // Hide params section if not present or elements not found
        paramsSection.classList.add("hidden");
      }

      if (sendButton) {
        sendButton.disabled = false; // Enable the send button
      }
    }

    // --- Send Modified Packet ---
    function sendModifiedLoginPacket() {
      if (!originalLoginPacket || !editorContainer || !sendButton) {
        logStatus("Cannot send: Original packet or editor not found.", "error");
        return;
      }

      logStatus("Reconstructing and sending modified packet...");
      sendButton.disabled = true; // Disable while processing

      try {
        // Reconstruct the 'o' object, including nested 'params'
        const modifiedO = {};
        const modifiedParams = {};

        // Query the whole document to get inputs from both main editor and params section
        const inputs = document.querySelectorAll('input, textarea, select');
        inputs.forEach(input => {
          // Skip inputs without a data-key (e.g., the intercept checkbox)
          if (!input.dataset.key) return; 
          
          const key = input.dataset.key;
          const originalType = input.dataset.type;
          const isComplex = input.dataset.isComplex === 'true';
          let newValue = input.value;
          let targetObject = modifiedO; // Default to main 'o' object

          // Determine if this key belongs to the 'params' object
          if (originalLoginPacket.b.o.params && key in originalLoginPacket.b.o.params) {
             targetObject = modifiedParams;
          }

          try {
            if (isComplex) {
              newValue = JSON.parse(newValue); // Parse complex types from JSON string
            } else if (originalType === 'number') {
              newValue = Number(newValue);
              if (isNaN(newValue)) throw new Error(`Invalid number format for ${key}`);
            } else if (originalType === 'boolean') {
              newValue = newValue === 'true';
            }
            // Strings remain strings
            targetObject[key] = newValue;
          } catch (parseError) {
             logStatus(`Error parsing value for '${key}': ${parseError.message}. Using original value.`, "warn");
             // Keep original value if parsing fails
             if (targetObject === modifiedParams) {
                targetObject[key] = originalLoginPacket.b.o.params[key];
             } else {
                targetObject[key] = originalLoginPacket.b.o[key];
             }
          }
        });

        // Add the reconstructed 'params' object back to 'o'
        if (Object.keys(modifiedParams).length > 0) {
           modifiedO.params = modifiedParams;
        } else if (originalLoginPacket.b.o.params) {
           // If params existed but no inputs were found (e.g., empty object), keep original
           modifiedO.params = originalLoginPacket.b.o.params;
        }


        // Create the new full packet structure
        const modifiedPacket = {
          ...originalLoginPacket, // Copy top-level keys like 't'
          b: {
            ...originalLoginPacket.b, // Copy other keys within 'b' like 'r'
            o: modifiedO // Use the modified 'o' object
          }
        };

        const modifiedJsonString = JSON.stringify(modifiedPacket);

        // Send to client
        window.jam.dispatch.sendConnectionMessage(modifiedJsonString);
        logStatus("Sent modified login packet to client.", "success");

      } catch (error) {
        logStatus(`Error sending modified packet: ${error.message}`, "error");
        console.error("[UI Plugin] Error sending modified packet:", error);
      } finally {
         // Re-enable button after a short delay to prevent rapid clicks
         setTimeout(() => { if (sendButton) sendButton.disabled = false; }, 500);
      }
    }

    // --- Packet Hooking ---
    try {
      // Store the unsubscribe function returned by onPacket
      unsubscribePacketListener = window.jam.onPacket(function (packetData) {
        if (!interceptEnabled || !packetData || packetData.direction !== 'in') {
          return; // Only process incoming packets if enabled
        }

        try {
          const parsedPacket = JSON.parse(packetData.raw);
          // Check for the specific login packet structure
          if (parsedPacket && parsedPacket.t === 'xt' && parsedPacket.b && parsedPacket.b.o && parsedPacket.b.o._cmd === 'login') {
            displayLoginPacketEditor(parsedPacket);
          }
        } catch (e) {
          // Ignore packets that are not valid JSON or don't match
        }
      });
      logStatus("Subscribed to incoming packets for JSON login display.");
    } catch (err) {
      console.error("[UI Plugin] Error setting up incoming packet subscription:", err);
      logStatus("Error setting up incoming packet listener: " + err.message, "error");
    }

    // --- Outgoing Packet Hooking ---
    let unsubscribeOutgoingHook = null;
    try {
      unsubscribeOutgoingHook = window.jam.dispatch.hookPacket('outgoing', function(packetData) {
        if (!packetData || !packetData.raw || typeof packetData.raw !== 'string') {
          return packetData.raw; // Let non-string packets pass
        }

        const rawPacket = packetData.raw;
        const isXmlLogin = rawPacket.startsWith("<msg t='sys'><body action='login'");

        if (isXmlLogin) {
          const execute = executeOnLoginCheckbox.checked; // Check current state
          logStatus(`Outgoing XML login packet detected. Injection enabled: ${execute}`, "info");

          if (execute) {
            const username = xmlUsernameInput.value;
            const password = xmlPasswordInput.value;

            if (!username || !password) {
              logStatus("Inject enabled, but username or password field is empty. Blocking original packet.", "warn");
              return null; // Block original if fields are empty but injection is on
            }

            // Construct the new XML packet
            // Basic escaping for CDATA end sequence, though unlikely in JWT/username format
            const safeUsername = username.replace(']]>', ']]]]><![CDATA[>');
            const safePassword = password.replace(']]>', ']]]]><![CDATA[>');
            const newXmlString = `<msg t='sys'><body action='login' r='0'><login z='sbiLogin'><nick><![CDATA[${safeUsername}]]></nick><pword><![CDATA[${safePassword}]]></pword></login></body></msg>`;

            logStatus("Injecting modified XML login packet to server.", "success");
            window.jam.dispatch.sendRemoteMessage(newXmlString); // Send to server

            return null; // Block the original packet
          } else {
            // Injection not enabled, let original packet pass
            return rawPacket;
          }
        } else {
          // Not the XML login packet, let it pass
          return rawPacket;
        }
      });
      logStatus("Hooked outgoing packets for XML login injection.");
    } catch (err) {
      console.error("[UI Plugin] Error setting up outgoing packet hook:", err);
      logStatus("Error setting up outgoing packet hook: " + err.message, "error");
    }


    // --- UI Event Handlers ---
    // Incoming Intercept Checkbox
    if (interceptInCheckbox) {
      interceptInCheckbox.checked = interceptEnabled;
      interceptInCheckbox.addEventListener("change", function () {
        interceptEnabled = this.checked;
        logStatus("Incoming packet interception " + (interceptEnabled ? "enabled" : "disabled"));
        if (!interceptEnabled) {
           // Optionally clear editor and disable button if interception is turned off
           if (editorContainer) editorContainer.innerHTML = '<p class="text-gray-400 italic">Interception disabled. Enable to see login packet.</p>';
           if (sendButton) sendButton.disabled = true;
           originalLoginPacket = null;
        }
      });
    } else {
        logStatus("Incoming intercept checkbox not found.", "warn");
    }

    // Outgoing Inject Checkbox
    if (executeOnLoginCheckbox) {
      executeOnLoginCheckbox.addEventListener("change", saveOutgoingState);
    } else {
      logStatus("Outgoing inject checkbox not found.", "warn");
    }

    // Outgoing XML Inputs
    if (xmlUsernameInput) {
      xmlUsernameInput.addEventListener("input", saveOutgoingState);
    } else {
      logStatus("XML Username input not found.", "warn");
    }
    if (xmlPasswordInput) {
      xmlPasswordInput.addEventListener("input", saveOutgoingState);
    } else {
      logStatus("XML Password input not found.", "warn");
    }


    // Send Modified Incoming JSON Button
    if (sendButton) {
      sendButton.addEventListener("click", sendModifiedLoginPacket);
    } else {
        logStatus("Send button (for incoming JSON) not found.", "warn");
    }

    // Remove listeners/hide old elements if they somehow still exist
    const clearLogButton = document.getElementById("clear-log");
    if (clearLogButton) clearLogButton.style.display = 'none'; // Hide old button
    const packetFilterInput = document.getElementById("packet-filter");
    if (packetFilterInput) packetFilterInput.style.display = 'none'; // Hide old input
    const interceptOutCheckbox = document.getElementById("intercept-out");
    if (interceptOutCheckbox) interceptOutCheckbox.parentElement.style.display = 'none'; // Hide old checkbox


    // --- Initial Load ---
    loadOutgoingState(); // Load saved outgoing settings on startup
    logStatus("Login Packet Editor initialized and ready.");

  } // End of initializePlugin function

  // Wait for the jam-ready event before initializing
  if (window.jam && window.jam.dispatch && window.jam.application && typeof window.jam.onPacket === 'function') {
    initializePlugin();
  } else {
    window.addEventListener('jam-ready', initializePlugin, { once: true });
  }

  // Add cleanup listener for window close
  window.addEventListener('beforeunload', () => {
    // Unsubscribe from incoming listener
    if (typeof unsubscribePacketListener === 'function') {
      try {
        unsubscribePacketListener();
        console.log("[LoginPacketManipulator] Unsubscribed from incoming packet listener.");
      } catch (e) {
        console.error("[LoginPacketManipulator] Error unsubscribing from incoming packet listener:", e);
      }
    }
    // Unsubscribe from outgoing hook
    if (typeof unsubscribeOutgoingHook === 'function') {
      try {
        unsubscribeOutgoingHook();
        console.log("[LoginPacketManipulator] Unsubscribed from outgoing packet hook.");
      } catch (e) {
        console.error("[LoginPacketManipulator] Error unsubscribing from packet listener:", e);
      }
    }
  });

})();
