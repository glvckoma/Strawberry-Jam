const { dispatch, application } = jam;
const TFD_packets = require('./TFD_packets.json');

// Constants
const QUEST_ID = '23'; // Hardcoded for The Forgotten Desert

// UI Elements
const startButton = document.getElementById('startButton');
const stopButton = document.getElementById('stopButton');
const resetStatsButton = document.getElementById('resetStatsButton');
const statusMessage = document.getElementById('statusMessage');
const statusIcon = document.getElementById('statusIcon');
const progressBar = document.getElementById('progressBar');
const progressText = document.getElementById('progressText');
const successCount = document.getElementById('successCount');
const failureCount = document.getElementById('failureCount');
const totalRuns = document.getElementById('totalRuns');

// Settings Elements
const autoRetryCheckbox = document.getElementById('autoRetryCheckbox');
const soundNotificationCheckbox = document.getElementById('soundNotificationCheckbox');
const dontLogRecycledCheckbox = document.getElementById('dontLogRecycledCheckbox');
const efficientModeCheckbox = document.getElementById('efficientModeCheckbox');
const specialModeCheckbox = document.getElementById('specialModeCheckbox');
const specialModeContainer = document.getElementById('specialModeContainer');
const crystalDelayContainer = document.getElementById('crystalDelayContainer');
const crystalDelay = document.getElementById('crystalDelay');
const maxRetries = document.getElementById('maxRetries');
const loopMode = document.getElementById('loopMode');

// Modal Elements
const educationalModal = document.getElementById('educationalModal');
const closeModal = document.getElementById('closeModal');
const startAutomationFromModal = document.getElementById('startAutomationFromModal');
const infoButton = document.getElementById('infoButton');

// Item Filter Elements
const clothingWhitelist = document.getElementById('clothingWhitelist');
const denWhitelist = document.getElementById('denWhitelist');
const saveWhitelistsButton = document.getElementById('saveWhitelistsButton');
const clearWhitelistsButton = document.getElementById('clearWhitelistsButton');
const openClothingJson = document.getElementById('openClothingJson');
const openDenItemsJson = document.getElementById('openDenItemsJson');
const enableFilteringCheckbox = document.getElementById('enableFilteringCheckbox');
const filterStatusText = document.getElementById('filterStatusText');

// Received Items Log Elements
const itemLog = document.getElementById('itemLog');
const clearLogButton = document.getElementById('clearLogButton');
const toggleLogButton = document.getElementById('toggleLogButton');
const itemSearchBox = document.getElementById('itemSearchBox');

// State Variables
let receivedItems = [];
let clothingItems = {};
let denItems = {};
let isAutomationRunning = false;
let currentTimeout = null;
let currentRoom = null; // Textual room name
let currentInternalRoomId = null; // Numerical instance ID
let playerSfsUserId = null;
let currentStep = 0;
let totalSteps = 0;
let stats = {
    successful: 0,
    failed: 0,
    total: 0
};
let retryCount = 0;
let questStartTime = null; // Track when quest started
let currentLoopCount = 0;
let totalLoopsToRun = 1;
let isLooping = false;
let knownDenInvIds = new Set();
let isFirstDiPacket = true;
let hasCapturedInitialDenState = false; // New state for den inventory
const QUEST_DURATION_MS = 17 * 60 * 1000; // 17 minutes in milliseconds
const MIN_WAIT_TIME_MS = 4 * 60 * 1000; // Must wait at least 4 minutes (17:00 - 13:00)

// Efficient Mode Variables
let isEfficientMode = false;
let isSpecialMode = false;
let efficientSniffing = false;
let efficientSeqActive = false;
let efficientCurrentInterval = null;
let efficientQueue = [];
let joinStepTimers = [];
let giftCollectorTimers = [];
let joinRetryTimer = null;
let giftRetryTimer = null;
let specialGiftSlots = [];
let lastDetectedGoodies = [];
let totalGoodies = 0;
let efficientCrystalDelay = 10;

// Efficient Mode Helper Functions
const pad = k => String(k).padStart(2, '0');

// Room ID management functions (based on phantoms plugin)
const refreshRoom = async () => {
    const textualRoom = await dispatch.getState('room');
    const internalRoomState = await dispatch.getState('internalRoomId');

    currentRoom = textualRoom; // Can be null

    if (internalRoomState) {
        const parsedId = parseInt(internalRoomState, 10);
        if (!isNaN(parsedId)) {
            currentInternalRoomId = parsedId;
        } else {
            console.warn(`[TFD Automation] internalRoomId '${internalRoomState}' from state could not be parsed to a number.`);
            currentInternalRoomId = null;
        }
    } else {
        currentInternalRoomId = null;
    }

    if (!currentRoom && !currentInternalRoomId) {
        console.warn('[TFD Automation] No room ID is currently available from dispatch state.');
        if (isAutomationRunning) {
            updateStatus('Error: Lost room connection. Please enter a room and restart.', 'error');
        }
    }
};

// Get the best available room ID (prioritize numerical)
const getRoomIdToUse = () => {
    const roomId = currentInternalRoomId || currentRoom;
    if (!roomId) {
        console.warn('[TFD Automation] getRoomIdToUse() called but no room ID is available');
    }
    return roomId;
};

// Check if room is available and notify user if not
const validateRoomAvailability = async () => {
    await refreshRoom();
    if (!getRoomIdToUse()) {
        updateStatus('Error: No room available. Please enter a room first.', 'error');
        return false;
    }
    return true;
}

// ===== EFFICIENT MODE FUNCTIONS =====

// Dynamic Crystal Packet Generator
let efficientCrystalPackets = [];
let waitPeriodCrystalPackets = []; // Additional packets for wait period in special mode
let detectedGiftItems = [];

// Generate crystal packets based on detected patterns
const generateEfficientCrystalPackets = (crystalData) => {
    const packets = [];
    
    // Add crystals based on detected patterns (instead of using TFD_packets.json)
    crystalData.forEach(({ type, variant, count }) => {
        for (let i = 1; i <= count; i++) {
            let packet;
            switch (type) {
                case '1crystal':
                case '2crystal':
                    packet = {
                        content: `%xt%o%qat%{room}%${type}_${pad(i)}${variant}%0%`,
                        delay: efficientCrystalDelay / 1000 // Convert to seconds
                    };
                    break;
                case '3water':
                    const idx = Math.ceil(i / 2);
                    const isPailPacket = (i % 2) === 1;
                    packet = {
                        content: isPailPacket ? 
                            `%xt%o%qpup%{room}%3pail_00e%1441722%` :
                            `%xt%o%qat%{room}%3water_${pad(idx)}${variant}%0%`,
                        delay: isPailPacket ? 
                            Math.max(efficientCrystalDelay / 1000, 0.8) : // Pail pickup needs more time
                            Math.max(efficientCrystalDelay / 1000, 0.6)   // Water collection can be faster
                    };
                    break;
                case '3crystal':
                    packet = {
                        content: `%xt%o%qat%{room}%3crystal_${pad(i)}${variant}%0%`,
                        delay: efficientCrystalDelay / 1000
                    };
                    break;
                case '4socvol':
                    packet = {
                        content: `%xt%o%qat%{room}%4socvol${pad(i)}${variant}%0%`,
                        delay: Math.max(efficientCrystalDelay / 1000, 1.0) // 4socvol needs minimum 1 second
                    };
                    break;
                case '4crystal':
                    packet = {
                        content: `%xt%o%qat%{room}%4crystal_${pad(i)}${variant}%0%`,
                        delay: Math.max(efficientCrystalDelay / 1000, 0.8) // 4crystal needs minimum 800ms
                    };
                    break;
            }
            if (packet) packets.push(packet);
        }
    });
    
    return packets;
};

// Efficient QQM Packet Handler - Gift Detection Only
const efficientHandleQqm = (data) => {
    if (!isEfficientMode || !isAutomationRunning) return;
    
    // Check if this is a qqm packet
    const { raw: rawMessage } = data;
    if (!rawMessage || !rawMessage.includes('%xt%qqm%')) return;
    
    try {
        // Parse the raw message to extract base64 data
        const parts = rawMessage.split('%');
        if (parts.length < 5) {
            return;
        }
        
        const b64 = parts[4];
        if (!b64) {
            return;
        }

        const decoded = require('zlib')
            .inflateSync(Buffer.from(b64, 'base64'))
            .toString('utf8');

        const splitParts = decoded
            .split(/[^\x20-\x7E]+/)
            .filter(p => p.length);

        // Detect gift contents for smart collection - check both gift codes
        const GIFT_CODES = ['guipckgft2', 'guipckgft4'];
        // Based on user feedback: 385 is Red Brick Walls (den), 570 is Longbow (clothing)
        // Let's try different offsets: maybe IDs are at positions 8, 11 instead
        const GIFT_ID_OFFSETS = [8, 11, 14, 17]; // Try shifted pattern
        const GIFT_FLAG_OFFSETS = [9, 12, 15, 18]; // Flags follow IDs
        
        for (let base = 0; base + Math.max(...GIFT_FLAG_OFFSETS) < splitParts.length; base++) {
            const currentCode = splitParts[base];
            if (GIFT_CODES.includes(currentCode)) {
                const ids = GIFT_ID_OFFSETS.map(off => splitParts[base + off] || '0');
                const flags = GIFT_FLAG_OFFSETS.map(off => splitParts[base + off] || '0');
                
                const whitelists = getWhitelists();
                console.log(`[TFD Automation] Current whitelists - Clothing: ${Array.from(whitelists.clothing).join(', ')}, Den: ${Array.from(whitelists.den).join(', ')}`);
                
                // Track which slots we've already detected to avoid duplicates, but don't reset the entire array
                const currentPacketGifts = [];

                ids.forEach((id, i) => {
                    // Skip empty slots (ID '0' or undefined)
                    if (!id || id === '0') {
                        return;
                    }
                    
                    // Validate flag value (should be '0' or '1')
                    const flagValue = flags[i];
                    let itemType, isWhitelisted;
                    
                    if (flagValue !== '0' && flagValue !== '1') {
                        // Try to determine item type by looking it up in both databases
                        const clothingName = getItemName(id, 'clothing');
                        const denName = getItemName(id, 'den');
                        
                        // If we found a match in clothing items (and it's not just the ID), use that
                        if (clothingName && !clothingName.startsWith('Unknown') && clothingName !== id) {
                            itemType = 'clothing';
                            isWhitelisted = whitelists.clothing.has(id);
                        }
                        // Otherwise try den items
                        else if (denName && !denName.startsWith('Unknown') && denName !== id) {
                            itemType = 'den';
                            isWhitelisted = whitelists.den.has(id);
                        }
                        // If not found in either, default to clothing
                        else {
                            itemType = 'clothing';
                            isWhitelisted = whitelists.clothing.has(id);
                        }
                    } else {
                        itemType = flagValue === '0' ? 'den' : 'clothing';
                        isWhitelisted = flagValue === '0' ? 
                            whitelists.den.has(id) : whitelists.clothing.has(id);
                    }
                    
                    const itemName = getItemName(id, itemType);
                    
                    // Debug whitelist checking
                    console.log(`[TFD Automation] Chest item: ${itemName} (ID: ${id}, Type: ${itemType}, Whitelisted: ${isWhitelisted})`);
                    
                    const giftItem = {
                        slot: i,
                        id: id,
                        name: itemName,
                        type: itemType,
                        isWhitelisted: isWhitelisted
                    };
                    
                    // Add to current packet gifts
                    currentPacketGifts.push(giftItem);
                    
                    // Check if this exact item (by ID and slot) is already in detectedGiftItems
                    const existingItemIndex = detectedGiftItems.findIndex(item => 
                        item.id === id && item.slot === i);
                    
                    if (existingItemIndex === -1) {
                        // New item - add to detected gifts
                        detectedGiftItems.push(giftItem);
                        console.log(`[TFD Automation] NEW GIFT DETECTED: ${itemName} (slot ${i})`);
                        
                        // Log items based on whitelist status
                        if (isWhitelisted) {
                            logReceivedItem(itemName, 'kept'); // Mark valuable items as kept immediately
                            console.log(`[TFD Automation] ${itemName} is WHITELISTED - marked as kept`);
                        } else {
                            logReceivedItem(itemName, 'skipped');
                            console.log(`[TFD Automation] ${itemName} is NOT whitelisted - will be skipped`);
                        }
                    } else {
                        console.log(`[TFD Automation] EXISTING GIFT: ${itemName} (slot ${i}) - already detected`);
                    }
                });

                // Show summary for current packet AND total accumulated gifts
                const currentPacketValuable = currentPacketGifts.filter(item => item.isWhitelisted);
                const totalValuableItems = detectedGiftItems.filter(item => item.isWhitelisted);
                
                console.log(`[TFD Automation] === GIFT DETECTION COMPLETE ===`);
                console.log(`[TFD Automation] Current packet items: ${currentPacketGifts.length}`);
                console.log(`[TFD Automation] Current packet valuable: ${currentPacketValuable.length}`);
                console.log(`[TFD Automation] TOTAL accumulated items: ${detectedGiftItems.length}`);
                console.log(`[TFD Automation] TOTAL valuable items: ${totalValuableItems.length}`);
                console.log(`[TFD Automation] All detected items: ${detectedGiftItems.map(item => `${item.name}(${item.isWhitelisted ? 'KEEP' : 'SKIP'})`).join(', ')}`);
                
                if (currentPacketValuable.length > 0) {
                    updateStatus(`🎁 New valuable items: ${currentPacketValuable.map(item => item.name).join(', ')} (Total: ${totalValuableItems.length})`, 'success');
                    console.log(`[TFD Automation] New valuable items detected in this packet`);
                } else if (totalValuableItems.length > 0) {
                    updateStatus(`📊 Total valuable items: ${totalValuableItems.length} (${currentPacketGifts.length} new regular items)`, 'info');
                    console.log(`[TFD Automation] No new valuable items in this packet, but have ${totalValuableItems.length} total valuable items`);
                } else {
                    updateStatus(`📦 No valuable items in gifts, will skip collection`, 'info');
                    console.log(`[TFD Automation] Still no valuable items detected`);
                }
                break;
            }
        }

        // Detect crystal patterns for dynamic packet generation
        const OFFSETS = [0, 270, 547, 781];
        for (let base = 0; base + OFFSETS[3] < splitParts.length; base++) {
            const p1 = splitParts[base];
            const p2 = splitParts[base + OFFSETS[1]];
            const p3 = splitParts[base + OFFSETS[2]];
            const p4 = splitParts[base + OFFSETS[3]];

            const m1 = /^1crystal_01([ab])$/.exec(p1);
            const m2 = /^2crystal_01([ab])$/.exec(p2);
            const m3 = /^3water_01([ab])$/.exec(p3);
            const m4 = /^4ppoint01([ab])$/.exec(p4);

            if (m1 || m2 || m3 || m4) {
                const crystalData = [];
                
                if (m1) crystalData.push({ type: '1crystal', variant: m1[1], count: 25 });
                if (m2) crystalData.push({ type: '2crystal', variant: m2[1], count: 25 });
                
                // In special mode, save layer 3&4 crystals for wait period collection
                if (!isSpecialMode) {
                    if (m3) {
                        crystalData.push({ type: '3water', variant: m3[1], count: 40 });
                        crystalData.push({ type: '3crystal', variant: m3[1], count: 20 });
                    }
                    if (m4) {
                        crystalData.push({ type: '4socvol', variant: m4[1], count: 15 });
                        crystalData.push({ type: '4crystal', variant: m4[1], count: 15 });
                    }
                } else {
                    // Store layer 3&4 crystal data for wait period collection
                    const waitPeriodData = [];
                    if (m3) {
                        waitPeriodData.push({ type: '3water', variant: m3[1], count: 40 });
                        waitPeriodData.push({ type: '3crystal', variant: m3[1], count: 20 });
                    }
                    if (m4) {
                        waitPeriodData.push({ type: '4socvol', variant: m4[1], count: 15 });
                        waitPeriodData.push({ type: '4crystal', variant: m4[1], count: 15 });
                    }
                    waitPeriodCrystalPackets = generateEfficientCrystalPackets(waitPeriodData);
                    console.log(`[TFD Automation] Special mode: Reserved ${waitPeriodCrystalPackets.length} packets for wait period collection`);
                }
                
                // Generate efficient crystal packets
                efficientCrystalPackets = generateEfficientCrystalPackets(crystalData);
                if (isSpecialMode && waitPeriodCrystalPackets.length > 0) {
                    updateStatus(`🔮 Crystal patterns detected! Generated ${efficientCrystalPackets.length} primary + ${waitPeriodCrystalPackets.length} wait-period packets`, 'info');
                } else {
                    updateStatus(`🔮 Crystal patterns detected! Generated ${efficientCrystalPackets.length} optimized packets`, 'info');
                }
                break;
            }
        }
    } catch (e) {
        console.error('[TFD Automation] Error processing qqm packet:', e);
    }
};

// Function to collect additional crystals during wait period (special mode enhancement)
const collectWaitPeriodCrystals = async () => {
    if (!isSpecialMode || !isAutomationRunning || waitPeriodCrystalPackets.length === 0) {
        return;
    }
    
    console.log(`[TFD Automation] Starting wait period crystal collection - ${waitPeriodCrystalPackets.length} packets`);
    updateStatus(`🔮 Collecting additional crystals during wait period (${waitPeriodCrystalPackets.length} packets)...`, 'info');
    
    for (let i = 0; i < waitPeriodCrystalPackets.length; i++) {
        if (!isAutomationRunning) {
            console.log('[TFD Automation] Wait period crystal collection interrupted - automation stopped');
            return;
        }
        
        const packet = waitPeriodCrystalPackets[i];
        const packetType = packet.content.includes('3water') ? '3water' : 
                          packet.content.includes('3crystal') ? '3crystal' :
                          packet.content.includes('4socvol') ? '4socvol' :
                          packet.content.includes('4crystal') ? '4crystal' :
                          packet.content.includes('qpup') ? '3pail' : 'unknown';
        
        console.log(`[TFD Automation] Wait period crystal ${i + 1}/${waitPeriodCrystalPackets.length} (${packetType}, delay: ${packet.delay * 1000}ms): ${packet.content}`);
        
        try {
            await sendPacketWithRetry(packet, false, true);
        } catch (error) {
            console.error(`[TFD Automation] Error sending wait period crystal packet ${i + 1} (${packetType}):`, error);
            updateStatus(`Warning: Wait period crystal collection error - ${error.message}`, 'warning');
            break;
        }
    }
    
    console.log(`[TFD Automation] Wait period crystal collection completed`);
    updateStatus(`✨ Wait period crystal collection completed! Continuing to gift collection...`, 'success');
};

// Reset efficient mode variables
const resetEfficientMode = () => {
    efficientCrystalPackets = [];
    waitPeriodCrystalPackets = [];
    detectedGiftItems = [];
};

// Load stats from localStorage
function loadStats() {
    const savedStats = localStorage.getItem('tfd_automation_stats');
    if (savedStats) {
        stats = JSON.parse(savedStats);
        updateStatsDisplay();
    }
}

// Save stats to localStorage
function saveStats() {
    localStorage.setItem('tfd_automation_stats', JSON.stringify(stats));
}

// Update stats display
function updateStatsDisplay() {
    if (successCount) successCount.textContent = stats.successful;
    if (failureCount) failureCount.textContent = stats.failed;
    if (totalRuns) totalRuns.textContent = stats.total;
}

// Play notification sound for valuable whitelisted items
function playNotificationSound(type = 'success') {
    if (!soundNotificationCheckbox || !soundNotificationCheckbox.checked) return;
    
    try {
        const audioContext = new (window.AudioContext || window.webkitAudioContext)();
        const oscillator = audioContext.createOscillator();
        const gainNode = audioContext.createGain();
        
        oscillator.connect(gainNode);
        gainNode.connect(audioContext.destination);
        
        if (type === 'success') {
            oscillator.frequency.setValueAtTime(800, audioContext.currentTime);
            oscillator.frequency.setValueAtTime(1000, audioContext.currentTime + 0.1);
        } else if (type === 'error') {
            oscillator.frequency.setValueAtTime(300, audioContext.currentTime);
            oscillator.frequency.setValueAtTime(200, audioContext.currentTime + 0.2);
        }
        
        gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
        gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.3);
        
        oscillator.start(audioContext.currentTime);
        oscillator.stop(audioContext.currentTime + 0.3);
    } catch (e) {
        console.warn('[TFD Automation] Could not play notification sound:', e);
    }
}

// Helper function to update UI status and log messages
function updateStatus(message, type = 'info', step = null) {
    if (statusMessage) statusMessage.textContent = message;
    
    // Update status icon
    if (statusIcon) {
        let iconClass = 'fas fa-circle text-gray-400';
        let iconText = 'Idle';
        
        switch (type) {
            case 'success':
                iconClass = 'fas fa-check-circle text-green-400 pulse-animation';
                iconText = 'Success';
                break;
            case 'error':
                iconClass = 'fas fa-exclamation-circle text-red-400 pulse-animation';
                iconText = 'Error';
                break;
            case 'warning':
                iconClass = 'fas fa-exclamation-triangle text-yellow-400 pulse-animation';
                iconText = 'Warning';
                break;
            case 'info':
                if (isAutomationRunning) {
                    iconClass = 'fas fa-spinner fa-spin text-blue-400';
                    iconText = 'Running';
                } else {
                    iconClass = 'fas fa-circle text-gray-400';
                    iconText = 'Idle';
                }
                break;
        }
        
        statusIcon.innerHTML = `<i class="${iconClass}"></i> ${iconText}`;
    }
    
    // Update progress if step is provided
    if (step !== null && totalSteps > 0) {
        currentStep = step;
        const progress = Math.round((currentStep / totalSteps) * 100);
        if (progressBar) progressBar.style.width = `${progress}%`;
        if (progressText) progressText.textContent = `${progress}%`;
    }
    
    if (application && application.consoleMessage) {
        application.consoleMessage({
            message: `TFD Automation: ${message}`,
            type: type
        });
    }
}

// Function to get player SFS User ID dynamically
async function getPlayerSfsUserId() {
    try {
        const userId = await dispatch.getState('userId');
        if (userId) {
            return userId;
        }
    } catch (e) {
        console.error('[TFD Automation] Error getting dynamic userId, falling back to placeholder.', e);
    }
    const placeholderId = 1119652; // Fallback placeholder
    updateStatus(`Warning: Could not get dynamic player ID. Using placeholder: ${placeholderId}`, 'warning');
    return placeholderId;
}

// Function to get randomized delay for gem packets
function getRandomizedDelay(baseDelay, isGemPacket = false) {
    if (isGemPacket) {
        // If we're in efficient mode and have a custom crystal delay, use that instead of random
        if (isEfficientMode && baseDelay > 0) {
            console.log(`[TFD Automation] Using efficient mode crystal delay: ${baseDelay}ms`);
            return baseDelay;
        }
        // Otherwise, randomize between 500-1000ms for gem packets to avoid bot detection
        console.log(`[TFD Automation] Using randomized delay for standard gem packets`);
        return Math.floor(Math.random() * (1000 - 500 + 1)) + 500;
    }
    return baseDelay;
}

// Function to check connection status
async function isConnected() {
    try {
        return await dispatch.getState('connected');
    } catch (e) {
        return false; // Assume disconnected on error
    }
}

// Function to send a single packet with delay and critical connection check
async function sendPacket(packet, isRaw = false, isGemPacket = false) {
    if (!isAutomationRunning) return; // Exit if automation was stopped

    if (!(await isConnected())) {
        stopAutomation();
        throw new Error('Connection lost. Automation stopped.');
    }

    // Refresh room info before sending each packet
    await refreshRoom();
    
    let content = isRaw ? packet : packet.content;
    const type = isRaw ? 'aj' : packet.type; // Assume 'aj' for raw packets
    const baseDelay = isRaw ? 0 : parseFloat(packet.delay) * 1000; // No delay for raw sends unless specified
    const delay = getRandomizedDelay(baseDelay, isGemPacket);

    // Replace placeholders if they exist
    if (content.includes('{room}')) {
        const roomId = getRoomIdToUse();
        if (!roomId) {
            throw new Error('No room ID available for packet sending');
        }
        content = content.replaceAll('{room}', roomId);
    }
    if (content.includes('{playerSfsUserId}')) {
        content = content.replaceAll('{playerSfsUserId}', playerSfsUserId);
    }


    try {
        await dispatch.sendRemoteMessage(content);
    } catch (error) {
        // This is the critical change: if sendRemoteMessage fails, it will throw.
        // We re-throw a more specific error to be caught by the main try/catch block.
        throw new Error('Connection lost. Socket not writable.');
    }

    if (delay > 0) {
        // Introduce delay after sending the packet
        return new Promise(resolve => {
            currentTimeout = setTimeout(resolve, delay); // Store timeout ID
        });
    }
}

async function sendPacketWithRetry(packet, isRaw = false, isGemPacket = false, retryCount = 0) {
    const maxRetriesValue = parseInt(maxRetries.value, 10);
    try {
        await sendPacket(packet, isRaw, isGemPacket);
    } catch (error) {
        if (retryCount < maxRetriesValue) {
            const delay = 5000 * (retryCount + 1);
            updateStatus(`Connection error. Retrying in ${delay / 1000}s... (${retryCount + 1}/${maxRetriesValue})`, 'warning');
            await new Promise(resolve => setTimeout(resolve, delay));
            await sendPacketWithRetry(packet, isRaw, isGemPacket, retryCount + 1);
        } else {
            throw new Error(`Failed to send packet after ${maxRetriesValue} retries. Stopping automation.`);
        }
    }
}

// Main function to start the automation sequence
async function startAutomation() {
    // Check room availability before starting
    if (!(await validateRoomAvailability())) {
        return; // Don't start if no room is available
    }

    // Get settings
    isEfficientMode = efficientModeCheckbox && efficientModeCheckbox.checked;
    isSpecialMode = specialModeCheckbox && specialModeCheckbox.checked;
    efficientCrystalDelay = crystalDelay ? parseInt(crystalDelay.value) : 10;

    // Initialize loop settings
    const loopValue = loopMode ? loopMode.value : '1';
    if (loopValue === 'infinite') {
        totalLoopsToRun = Infinity;
        isLooping = true;
    } else {
        totalLoopsToRun = parseInt(loopValue);
        isLooping = totalLoopsToRun > 1;
    }
    currentLoopCount = 0;

    updateStatus(`Starting TFD automation${isLooping ? ` (${totalLoopsToRun === Infinity ? '∞' : totalLoopsToRun} runs)` : ''}...`, 'info');
    if (startButton) startButton.disabled = true;
    if (stopButton) stopButton.disabled = false;
    isAutomationRunning = true;
    
    // Reset efficient mode data
    resetEfficientMode();
    
    // Run normal automation (efficient mode enhances it automatically)
    await runSingleAutomation();
}

// Function to run a single automation cycle
async function runSingleAutomation() {
    currentStep = 0;
    // Calculate total steps based on mode
    const packetsToUse = (isEfficientMode && efficientCrystalPackets.length > 0) ? 
        efficientCrystalPackets : TFD_packets.packets;
    totalSteps = 5 + packetsToUse.length; // 5 main steps + packet count
    retryCount = 0;
    currentLoopCount++;
    
    // Reset state for the new run
    knownDenInvIds.clear();
    isFirstDiPacket = true;
    hasCapturedInitialDenState = false; // Reset for each new adventure

    try {
        await refreshRoom();
        const textualRoomName = await dispatch.getState('room'); // Get textual room name (e.g., "denladyliya")

        if (!getRoomIdToUse() || !textualRoomName) { // Check both for validity
            updateStatus('Error: Not in a valid room. Please enter a room first.', 'error');
            stopAutomation();
            return;
        }

        playerSfsUserId = await getPlayerSfsUserId(); // Get player SFS User ID

        // Send a request for the current den inventory to establish a baseline
        await sendPacketWithRetry(`%xt%o%di%${getRoomIdToUse()}%`, true);

        // Step 1: Quest Creation
        updateStatus(`Creating TFD private quest (ID: ${QUEST_ID})...`, 'info', 1);
        const createQuestPacket = `%xt%o%qjc%${getRoomIdToUse()}%${textualRoomName}%${QUEST_ID}%0%`;
        await sendPacketWithRetry(createQuestPacket, true);

        // Increased delay to allow game client to process qjc and join quest room
        await new Promise(resolve => {
            currentTimeout = setTimeout(resolve, 5000); // 5 second delay
        });
        if (!isAutomationRunning) return;

        // Manually send quest start request after joining the quest room
        updateStatus('Quest room joined. Sending quest start request...', 'info', 2);
        const startQuestPacket = `%xt%o%qs%${getRoomIdToUse()}%${textualRoomName}%`;
        await sendPacketWithRetry(startQuestPacket, true);

        // Record quest start time for timer calculations
        questStartTime = Date.now();

        await new Promise(resolve => {
            currentTimeout = setTimeout(resolve, 2000); // Short delay after starting quest
        });
        if (!isAutomationRunning) return;

        // Step 3: Send Adventure Join Request
        updateStatus('Joining the adventure...', 'info', 3);
        const adventureJoinPacket = `%xt%o%qaskr%${getRoomIdToUse()}%liza01_%0%1%`;
        await sendPacketWithRetry(adventureJoinPacket, true);

        await new Promise(resolve => {
            currentTimeout = setTimeout(resolve, 3000); // 3 second delay for adventure join
        });
        if (!isAutomationRunning) return;

        // Refresh room info after joining adventure
        await refreshRoom();
        const adventureRoomId = getRoomIdToUse();

        updateStatus('Adventure joined. Beginning gem collection...', 'info', 4);

        // Step 4: Automate Gem Collection (use efficient packets if available)
        console.log(`[TFD Automation] Gem collection phase - isEfficientMode: ${isEfficientMode}, isSpecialMode: ${isSpecialMode}`);
        console.log(`[TFD Automation] Efficient crystal packets available: ${efficientCrystalPackets.length}`);
        console.log(`[TFD Automation] Default TFD packets available: ${TFD_packets.packets.length}`);
        
        const packetsToUse = (isEfficientMode && efficientCrystalPackets.length > 0) ? 
            efficientCrystalPackets : TFD_packets.packets;
        
        console.log(`[TFD Automation] Will use ${packetsToUse.length} packets for gem collection`);
        
        if (isEfficientMode && efficientCrystalPackets.length > 0) {
            updateStatus(`🚀 Using ${efficientCrystalPackets.length} optimized crystal packets!`, 'success', 4);
            console.log(`[TFD Automation] Efficient mode active - using optimized packets`);
        } else if (isEfficientMode) {
            console.log(`[TFD Automation] Efficient mode active but no optimized packets - using default packets`);
        } else {
            console.log(`[TFD Automation] Normal mode - using default TFD packets`);
        }
        
        for (let i = 0; i < packetsToUse.length; i++) {
            if (!isAutomationRunning) { // Check if automation was stopped before sending next packet
                updateStatus('Gem collection interrupted.');
                return;
            }
            const packet = packetsToUse[i];
            updateStatus(`Collecting gem ${i + 1}/${packetsToUse.length}...`, 'info', 4 + i);
            await sendPacketWithRetry(packet, false, true); // Send packet with randomized delay for gems
        }
        if (!isAutomationRunning) return; // Check if automation was stopped after loop

        updateStatus('Gem collection complete. Calculating reward timing...', 'info', totalSteps - 1);
        console.log(`[TFD Automation] Gem collection completed successfully`);

        // In efficient mode, wait for gift detection to complete
        if (isEfficientMode) {
            console.log(`[TFD Automation] Waiting for gift detection to complete...`);
            await new Promise(resolve => {
                currentTimeout = setTimeout(resolve, 3000); // Wait 3 seconds for gift detection
            });
            if (!isAutomationRunning) return;
            console.log(`[TFD Automation] Gift detection wait period completed`);
        }

        // Check if efficient mode detected no valuable items - skip reward collection entirely
        console.log(`[TFD Automation] === REWARD COLLECTION DECISION ===`);
        console.log(`[TFD Automation] isEfficientMode: ${isEfficientMode}`);
        console.log(`[TFD Automation] isSpecialMode: ${isSpecialMode}`);
        console.log(`[TFD Automation] detectedGiftItems.length: ${detectedGiftItems.length}`);
        console.log(`[TFD Automation] detectedGiftItems: ${JSON.stringify(detectedGiftItems.map(item => ({name: item.name, whitelisted: item.isWhitelisted})))}`);
        
        if (isEfficientMode && detectedGiftItems.length > 0) {
            const valuableItems = detectedGiftItems.filter(item => item.isWhitelisted);
            console.log(`[TFD Automation] Valuable items found: ${valuableItems.length}`);
            console.log(`[TFD Automation] Valuable items: ${JSON.stringify(valuableItems.map(item => item.name))}`);
            
            if (valuableItems.length === 0) {
                console.log(`[TFD Automation] === EFFICIENT EXIT: No valuable items detected ===`);
                updateStatus('📦 No valuable items detected - leaving quest immediately', 'info');
                
                // Jump straight to quest exit
                console.log('[TFD Automation] Refreshing room for quest exit...');
                try {
                    await Promise.race([
                        refreshRoom(),
                        new Promise((_, reject) => 
                            setTimeout(() => reject(new Error('Room refresh timeout')), 5000)
                        )
                    ]);
                } catch (error) {
                    console.error('[TFD Automation] Room refresh failed:', error);
                }
                const exitRoomId = getRoomIdToUse();
                console.log(`[TFD Automation] Sending leave quest packet for room ${exitRoomId}...`);
                const leaveQuestPacket = `%xt%o%qx%${exitRoomId}%`;
                
                try {
                    // Add timeout to prevent hanging
                    await Promise.race([
                        sendPacketWithRetry(leaveQuestPacket, true),
                        new Promise((_, reject) => 
                            setTimeout(() => reject(new Error('Quest exit timeout')), 10000)
                        )
                    ]);
                    console.log('[TFD Automation] Leave quest packet sent successfully');
                } catch (error) {
                    console.error('[TFD Automation] Failed to send leave quest packet:', error);
                    // Continue anyway to avoid getting stuck
                }
                
                // Success - completed efficiently without waiting
                stats.successful++;
                stats.total++;
                saveStats();
                updateStatsDisplay();
                
                const loopStatus = isLooping ? ` (${currentLoopCount}/${totalLoopsToRun === Infinity ? '∞' : totalLoopsToRun})` : '';
                updateStatus(`TFD automation completed efficiently!${loopStatus}`, 'success', totalSteps);
                
                // Check if we should continue looping
                if (isLooping && (totalLoopsToRun === Infinity || currentLoopCount < totalLoopsToRun) && isAutomationRunning) {
                    updateStatus(`Preparing next run${loopStatus}...`, 'info');
                    await new Promise(resolve => {
                        currentTimeout = setTimeout(resolve, 3000); // 3 second delay between runs
                    });
                    if (isAutomationRunning) {
                        await runSingleAutomation();
                        return;
                    }
                }
                
                stopAutomation();
                return;
            }
        }

        // Calculate how long we need to wait before collecting rewards
        const elapsedTime = Date.now() - questStartTime;
        const timeUntilSafeReward = MIN_WAIT_TIME_MS - elapsedTime;
        
        if (timeUntilSafeReward > 0) {
            const totalSeconds = Math.ceil(timeUntilSafeReward / 1000);
            const minutesLeft = Math.floor(totalSeconds / 60);
            const secondsLeft = totalSeconds % 60;
            console.log(`[TFD Automation] === WAITING FOR 13:00 RULE ===`);
            console.log(`[TFD Automation] Time until safe reward: ${timeUntilSafeReward}ms (${minutesLeft}m ${secondsLeft}s)`);
            updateStatus(`Waiting ${minutesLeft}m ${secondsLeft}s for safe reward collection (13:00 rule)...`, 'info');
            
            // Special mode enhancement: collect additional crystals during wait if available
            if (isSpecialMode && waitPeriodCrystalPackets.length > 0) {
                console.log(`[TFD Automation] === SPECIAL MODE ENHANCEMENT: WAIT PERIOD CRYSTAL COLLECTION ===`);
                
                // Calculate time needed for crystal collection (estimate 3-5 seconds buffer)
                const crystalCollectionTime = waitPeriodCrystalPackets.length * (efficientCrystalDelay + 100) + 5000; // Add 5s buffer
                const timeAfterCrystals = timeUntilSafeReward - crystalCollectionTime;
                
                if (timeAfterCrystals > 0) {
                    console.log(`[TFD Automation] Sufficient time for crystal collection. Starting immediately...`);
                    updateStatus(`🚀 Special mode: Collecting additional crystals during wait period...`, 'info');
                    
                    // Collect crystals during wait period
                    await collectWaitPeriodCrystals();
                    if (!isAutomationRunning) return;
                    
                    // Request updated quest data to detect new gifts from additional crystals
                    console.log(`[TFD Automation] === DETECTING NEW GIFTS FROM WAIT PERIOD CRYSTALS ===`);
                    updateStatus(`🔍 Requesting updated quest data to detect new gifts...`, 'info');
                    
                    // Send quest status request to trigger server to send updated qqm data
                    await refreshRoom();
                    const questStatusRoomId = getRoomIdToUse();
                    if (questStatusRoomId) {
                        console.log(`[TFD Automation] Sending quest status request to get updated gift data...`);
                        try {
                            // Request quest status update which should trigger new qqm packet with updated gifts
                            const questStatusPacket = `%xt%o%qgs%${questStatusRoomId}%`;
                            await sendPacketWithRetry(questStatusPacket, true);
                            
                            // Wait for server response and gift detection
                            await new Promise(resolve => {
                                currentTimeout = setTimeout(resolve, 4000); // Wait 4 seconds for server response and processing
                            });
                            if (!isAutomationRunning) return;
                            
                            console.log(`[TFD Automation] Quest status request completed - gift detection should be updated`);
                        } catch (error) {
                            console.error(`[TFD Automation] Failed to request quest status for gift detection:`, error);
                            updateStatus(`Warning: Could not refresh gift data - ${error.message}`, 'warning');
                            
                            // Fallback: just wait without the quest status request
                            await new Promise(resolve => {
                                currentTimeout = setTimeout(resolve, 2000);
                            });
                            if (!isAutomationRunning) return;
                        }
                    } else {
                        console.log(`[TFD Automation] No room ID available for quest status request - using fallback wait`);
                        await new Promise(resolve => {
                            currentTimeout = setTimeout(resolve, 3000);
                        });
                        if (!isAutomationRunning) return;
                    }
                    
                    console.log(`[TFD Automation] New gift detection completed`);
                    
                    // Wait remaining time after crystal collection and gift detection
                    const remainingWaitTime = Math.max(0, MIN_WAIT_TIME_MS - (Date.now() - questStartTime));
                    if (remainingWaitTime > 0) {
                        const remainingSeconds = Math.ceil(remainingWaitTime / 1000);
                        const remainingMinutes = Math.floor(remainingSeconds / 60);
                        const remainingSecondsDisplay = remainingSeconds % 60;
                        console.log(`[TFD Automation] Crystal collection complete. Waiting additional ${remainingWaitTime}ms (${remainingMinutes}m ${remainingSecondsDisplay}s)`);
                        updateStatus(`⏱️ Waiting ${remainingMinutes}m ${remainingSecondsDisplay}s more until 13:00...`, 'info');
                        
                        await new Promise(resolve => {
                            currentTimeout = setTimeout(resolve, remainingWaitTime);
                        });
                        if (!isAutomationRunning) return;
                    }
                } else {
                    console.log(`[TFD Automation] Not enough time for crystal collection (need ${crystalCollectionTime}ms, have ${timeUntilSafeReward}ms). Using standard wait.`);
                    updateStatus(`⏱️ Limited time - using standard wait for ${minutesLeft}m ${secondsLeft}s...`, 'info');
                    
                    await new Promise(resolve => {
                        currentTimeout = setTimeout(resolve, timeUntilSafeReward);
                    });
                    if (!isAutomationRunning) return;
                }
            } else {
                // Standard wait period (no special mode or no crystals to collect)
                await new Promise(resolve => {
                    currentTimeout = setTimeout(resolve, timeUntilSafeReward);
                });
                if (!isAutomationRunning) return;
            }

            // **Proactive Connection Check**
            // Send a harmless packet to ensure the connection is still alive before proceeding.
            console.log(`[TFD Automation] Verifying connection after wait period...`);
            updateStatus('Pinging server to verify connection...', 'info');
            await refreshRoom();
            const pingPacket = `%xt%o%gps%${getRoomIdToUse()}%`; // gps (get player status) is a safe ping
            await sendPacketWithRetry(pingPacket, true);
            // If sendPacket fails, it will throw and be caught by the main try/catch, stopping the automation.
            updateStatus('Connection verified. Proceeding to collect rewards.', 'info');
            console.log(`[TFD Automation] Connection verified - proceeding to reward collection`);

        } else {
            console.log(`[TFD Automation] No wait needed - proceeding directly to reward collection`);
        }

        updateStatus('Processing rewards...', 'info', totalSteps - 1);
        
        // Enhanced special mode: Show summary of ALL detected gifts before collection
        if (isSpecialMode && detectedGiftItems.length > 0) {
            const valuableItems = detectedGiftItems.filter(item => item.isWhitelisted);
            const regularItems = detectedGiftItems.filter(item => !item.isWhitelisted);
            console.log(`[TFD Automation] === FINAL GIFT SUMMARY ===`);
            console.log(`[TFD Automation] Total gifts detected: ${detectedGiftItems.length}`);
            console.log(`[TFD Automation] Valuable gifts (will collect): ${valuableItems.length} - ${valuableItems.map(item => item.name).join(', ')}`);
            console.log(`[TFD Automation] Regular gifts (will skip): ${regularItems.length} - ${regularItems.map(item => item.name).join(', ')}`);
            
            if (valuableItems.length > 0) {
                updateStatus(`🎁 Final summary: ${valuableItems.length} valuable + ${regularItems.length} regular gifts detected`, 'success');
            }
        }

        // Step 5: Automate Reward Collection (following phantoms plugin pattern)
        // Refresh room info before reward collection
        await refreshRoom();
        const rewardRoomId = getRoomIdToUse();
        
        if (!rewardRoomId) {
            console.error('[TFD Automation] No room ID available for reward collection');
            updateStatus('Error: No room ID for reward collection', 'error');
            throw new Error('No room ID available for reward collection');
        }


        // Send a request for the current den inventory to establish a baseline
        await sendPacketWithRetry(`%xt%o%di%${rewardRoomId}%`, true);
        
        // Wait a moment for the initial `di` packet to be processed
        await new Promise(resolve => {
            currentTimeout = setTimeout(resolve, 2000);
        });

        // Send qpgift packets (use efficient detection if available)
        if (isEfficientMode && detectedGiftItems.length > 0) {
            const valuableItems = detectedGiftItems.filter(item => item.isWhitelisted);
            
            if (valuableItems.length > 0) {
                updateStatus(`🎁 Collecting only valuable gifts: ${valuableItems.map(item => item.name).join(', ')}`, 'success');
                
                // Only collect valuable gift slots
                for (const item of valuableItems) {
                    if (!isAutomationRunning) return;
                    
                    const qpgiftPacket = `%xt%o%qpgift%${rewardRoomId}%${item.slot}%0%0%`;
                    await sendPacketWithRetry(qpgiftPacket, true);
                    
                    await new Promise(resolve => {
                        currentTimeout = setTimeout(resolve, 1000);
                    });
                }
            } else {
                console.log(`[TFD Automation] === EFFICIENT MODE: No valuable items detected - skipping gift collection ===`);
                updateStatus(`📦 No valuable items detected, skipping gift collection`, 'info');
            }
        } else if (isEfficientMode) {
            console.log(`[TFD Automation] === EFFICIENT MODE: Standard collection - no gift detection or fallback ===`);
            // Standard collection for all slots
            for (let i = 0; i < 6; i++) {
                if (!isAutomationRunning) return;
                
                console.log(`[TFD Automation] Collecting gift slot ${i}/5...`);
                const qpgiftPacket = `%xt%o%qpgift%${rewardRoomId}%${i}%0%0%`;
                await sendPacketWithRetry(qpgiftPacket, true);
                
                // Small delay between qpgift packets
                await new Promise(resolve => {
                    currentTimeout = setTimeout(resolve, 1000);
                });
            }
        } else {
            console.log(`[TFD Automation] === NORMAL MODE: Standard collection ===`);
            // Standard collection for all slots
            for (let i = 0; i < 6; i++) {
                if (!isAutomationRunning) return;
                
                console.log(`[TFD Automation] Collecting gift slot ${i}/5...`);
                const qpgiftPacket = `%xt%o%qpgift%${rewardRoomId}%${i}%0%0%`;
                await sendPacketWithRetry(qpgiftPacket, true);
                
                // Small delay between qpgift packets
                await new Promise(resolve => {
                    currentTimeout = setTimeout(resolve, 1000);
                });
            }
        }

        // Send qpgiftdone packet to finalize reward collection
        if (!isAutomationRunning) return;
        console.log(`[TFD Automation] Sending qpgiftdone packet to finalize collection...`);
        const qpgiftdonePacket = `%xt%o%qpgiftdone%${rewardRoomId}%`;
        await sendPacketWithRetry(qpgiftdonePacket, true);
        
        // Random pause after done packet (500-1000ms)
        const randomPause = Math.floor(Math.random() * 501) + 500; // 500-1000ms
        console.log(`[TFD Automation] Waiting ${randomPause}ms after gift collection...`);
        await new Promise(resolve => {
            currentTimeout = setTimeout(resolve, randomPause);
        });

        updateStatus('Rewards collected. Leaving quest...', 'info', totalSteps);
        console.log(`[TFD Automation] === QUEST EXIT PHASE ===`);

        // Step 6: Leave Quest
        await new Promise(resolve => {
            currentTimeout = setTimeout(resolve, 2000);
        });
        if (!isAutomationRunning) return;

        // Refresh room info before leaving
        console.log('[TFD Automation] Refreshing room for normal quest exit...');
        try {
            await Promise.race([
                refreshRoom(),
                new Promise((_, reject) => 
                    setTimeout(() => reject(new Error('Room refresh timeout')), 5000)
                )
            ]);
        } catch (error) {
            console.error('[TFD Automation] Room refresh failed:', error);
        }
        const exitRoomId = getRoomIdToUse();
        console.log(`[TFD Automation] Sending leave quest packet for room ${exitRoomId}...`);
        const leaveQuestPacket = `%xt%o%qx%${exitRoomId}%`;
        
        try {
            // Add timeout to prevent hanging
            await Promise.race([
                sendPacketWithRetry(leaveQuestPacket, true),
                new Promise((_, reject) => 
                    setTimeout(() => reject(new Error('Quest exit timeout')), 10000)
                )
            ]);
            console.log('[TFD Automation] Leave quest packet sent successfully');
        } catch (error) {
            console.error('[TFD Automation] Failed to send leave quest packet:', error);
            // Continue anyway to avoid getting stuck
        }
        
        // Success
        stats.successful++;
        stats.total++;
        saveStats();
        updateStatsDisplay();
        
        const loopStatus = isLooping ? ` (${currentLoopCount}/${totalLoopsToRun === Infinity ? '∞' : totalLoopsToRun})` : '';
        updateStatus(`TFD automation completed successfully!${loopStatus}`, 'success', totalSteps);
        
        // Check if we should continue looping
        if (isLooping && (totalLoopsToRun === Infinity || currentLoopCount < totalLoopsToRun) && isAutomationRunning) {
            updateStatus(`Preparing next run${loopStatus}...`, 'info');
            await new Promise(resolve => {
                currentTimeout = setTimeout(resolve, 3000); // 3 second delay between runs
            });
            if (isAutomationRunning) {
                await runSingleAutomation();
                return;
            }
        }
        
    } catch (error) {
        console.error('[TFD Automation] Error:', error);
        stats.failed++;
        stats.total++;
        saveStats();
        updateStatsDisplay();
        updateStatus(`Error: ${error.message}`, 'error');
        playNotificationSound('error');
        
        // Auto-retry logic is now handled by sendPacketWithRetry
    }
    
    stopAutomation();
}

// Function to stop the automation sequence
function stopAutomation() {
    const completedRuns = currentLoopCount; // Capture the count before resetting
    const wasLooping = isLooping && completedRuns > 0;
    isAutomationRunning = false; // Set flag to halt further execution BEFORE updating status
    isLooping = false;
    currentLoopCount = 0;
    totalLoopsToRun = 1;
    
    // Reset efficient mode data
    resetEfficientMode();
    
    updateStatus(`Automation stopped${wasLooping ? ` after ${completedRuns} run(s)` : ''}.`, 'info');
    if (startButton) startButton.disabled = false;
    if (stopButton) stopButton.disabled = true;
    if (progressBar) progressBar.style.width = '0%';
    if (progressText) progressText.textContent = '0%';
    
    if (currentTimeout) {
        clearTimeout(currentTimeout); // Clear any pending setTimeout
        currentTimeout = null;
    }
}

// Reset statistics
function resetStats() {
    if (confirm('Are you sure you want to reset all statistics?')) {
        stats = { successful: 0, failed: 0, total: 0 };
        saveStats();
        updateStatsDisplay();
        updateStatus('Statistics reset.', 'info');
    }
}

// Modal functionality
function showModal() {
    if (educationalModal) {
        educationalModal.style.display = 'flex';
    }
}

function hideModal() {
    if (educationalModal) {
        educationalModal.style.display = 'none';
    }
}

// Whitelist management
function getWhitelists() {
    const getIds = (element) => {
        if (!element || !element.value.trim()) return new Set();
        return new Set(element.value.split(',').map(id => id.trim()).filter(Boolean));
    };
    return {
        clothing: getIds(clothingWhitelist),
        den: getIds(denWhitelist),
    };
}

function isFilteringEnabled() {
    const whitelists = getWhitelists();
    return whitelists.clothing.size > 0 || whitelists.den.size > 0;
}

function saveWhitelists() {
    const whitelists = getWhitelists();
    localStorage.setItem('tfd_clothing_whitelist', JSON.stringify(Array.from(whitelists.clothing)));
    localStorage.setItem('tfd_den_whitelist', JSON.stringify(Array.from(whitelists.den)));
    updateStatus('Whitelists saved successfully.', 'success');
    updateFilteringStatus();
}

function loadWhitelists() {
    const loadList = (key, element) => {
        const saved = localStorage.getItem(key);
        if (saved && element) {
            try {
                element.value = JSON.parse(saved).join(', ');
            } catch (e) {
                console.error(`[TFD Automation] Failed to load whitelist ${key}:`, e);
            }
        }
    };
    loadList('tfd_clothing_whitelist', clothingWhitelist);
    loadList('tfd_den_whitelist', denWhitelist);
    updateFilteringStatus();
}

function updateFilteringStatus() {
    const whitelists = getWhitelists();
    const totalCount = whitelists.clothing.size + whitelists.den.size;

    if (filterStatusText) {
        if (totalCount > 0) {
            filterStatusText.textContent = `Enabled (${whitelists.clothing.size} clothing, ${whitelists.den.size} den)`;
            filterStatusText.className = 'text-green-300';
        } else {
            filterStatusText.textContent = 'Disabled (no item IDs specified)';
            filterStatusText.className = 'text-gray-400';
        }
    }
}

function clearWhitelists() {
    if (confirm('Are you sure you want to clear both whitelists?')) {
        if (clothingWhitelist) clothingWhitelist.value = '';
        if (denWhitelist) denWhitelist.value = '';
        localStorage.removeItem('tfd_clothing_whitelist');
        localStorage.removeItem('tfd_den_whitelist');
        updateFilteringStatus();
        updateStatus('Whitelists cleared.', 'info');
    }
}

// Enhanced item name lookup with better error handling
function getItemName(defId, itemType) {
    if (!defId) return 'Unknown Item';

    try {
        if (itemType === 'clothing' && clothingItems && clothingItems[defId]) {
            return `${clothingItems[defId].name || `Clothing ID ${defId}`}`;
        }
        if (itemType === 'den' && denItems && denItems[defId]) {
            return `${denItems[defId].abbrName || `Den ID ${defId}`}`;
        }
    } catch (error) {
        console.warn(`[TFD Automation] Error looking up item name for ID ${defId}:`, error);
    }
    
    return `Unknown ${itemType || 'Item'} (ID: ${defId})`;
}

// Improved packet handler for item filtering with better packet parsing
async function handleIncomingPackets(data) {
    // Only process packets if automation is running and filtering is enabled
    if (!isAutomationRunning || !data || data.direction !== 'in' || !isFilteringEnabled()) {
        return;
    }

    const { raw: rawMessage } = data;
    const parts = rawMessage.split('%');

    // Handle clothing/accessory item packets (%xt%il%)
    if (rawMessage.startsWith('%xt%il%') && parts.length > 10 && parts[4] === '2') {
        try {
            const numAdded = parseInt(parts[9]);
            if (numAdded > 0) {
                let currentIndex = 11;
                for (let i = 0; i < numAdded; i++) {
                    if (parts.length > currentIndex + 1) {
                        const invId = parts[currentIndex];
                        const defId = parts[currentIndex + 1];
                        await processItemForFiltering(defId, invId, 'clothing');
                        currentIndex += 2; // Move to the next pair
                    }
                }
            }
        } catch (error) {
            console.error('[TFD Automation] Error processing `il` packet:', error);
        }
    }
    
    // Handle den item inventory packets (%xt%di%)
    else if (rawMessage.startsWith('%xt%di%')) {
        try {
            const isAdventureRunning = questStartTime !== null; // A simple check to see if we're in an active run

            // Only capture the initial state ONCE per adventure run, before gifts are opened
            if (isAdventureRunning && !hasCapturedInitialDenState) {
                const denItemCount = parseInt(parts[5]);
                if (isNaN(denItemCount)) return;

                knownDenInvIds.clear();
                let currentIndex = 7;
                for (let i = 0; i < denItemCount; i++) {
                    if (parts.length > currentIndex) {
                        knownDenInvIds.add(parts[currentIndex]);
                    }
                    currentIndex += 9;
                }
                hasCapturedInitialDenState = true; // Mark as captured
            } else if (isAdventureRunning) {
                // This is a subsequent `di` packet, likely a gift update.
                const denItemCount = parseInt(parts[5]);
                if (isNaN(denItemCount)) return;

                let currentIndex = 7;
                for (let i = 0; i < denItemCount; i++) {
                    if (parts.length > currentIndex + 1) {
                        const invId = parts[currentIndex];
                        const defId = parts[currentIndex + 1];

                        if (!knownDenInvIds.has(invId)) {
                            await processItemForFiltering(defId, invId, 'den');
                            knownDenInvIds.add(invId); // Add to known list to avoid reprocessing
                        }
                    }
                    currentIndex += 9;
                }
            }
        } catch (error) {
            console.error('[TFD Automation] Error processing `di` packet:', error);
        }
    }
}

// Helper function to process an item for filtering
async function processItemForFiltering(defId, invId, itemType) {
    const whitelists = getWhitelists();
    const whitelist = itemType === 'clothing' ? whitelists.clothing : whitelists.den;

    if (defId && invId && defId.length > 0 && invId.length > 0) {
        const itemName = getItemName(defId, itemType);

        if (whitelist.has(defId)) {
            updateStatus(`✓ Whitelisted: ${itemName}. Keeping it.`, 'info');
            
            // Check if this item was already seen in chest (logged as kept or skipped)
            const existingItemIndex = receivedItems.findIndex(item => 
                item.name === itemName && (item.status === 'kept' || item.status === 'skipped'));
            
            if (existingItemIndex !== -1) {
                // Update existing item (refresh timestamp if already kept, or update skipped to kept)
                const oldStatus = receivedItems[existingItemIndex].status;
                receivedItems[existingItemIndex].status = 'kept';
                receivedItems[existingItemIndex].timestamp = new Date().toISOString();
                console.log(`[TFD Automation] Updated ${itemName} from ${oldStatus} to kept (actual collection)`);
                renderItemLog();
                localStorage.setItem('tfd_item_log', JSON.stringify(receivedItems));
            } else {
                // Log as new kept item (not seen in chest preview)
                console.log(`[TFD Automation] New kept item (not detected in chest): ${itemName}`);
                logReceivedItem(itemName, 'kept');
            }
            
            playNotificationSound('success'); // Play sound when valuable item is kept
        } else {
            updateStatus(`♻ Recycling: ${itemName}.`, 'warning');
            logReceivedItem(itemName, 'recycled');
            
            await new Promise(resolve => setTimeout(resolve, 150)); // Small delay
            
            await refreshRoom();
            
            let recyclePacket;
            if (itemType === 'den') {
                // Use the den-specific recycling packet with the correct format
                recyclePacket = `%xt%o%dr%${getRoomIdToUse()}%0%${invId}%`;
            } else {
                // Default to the standard item recycling packet for clothing
                recyclePacket = `%xt%o%ir%${getRoomIdToUse()}%${invId}%`;
            }
            
            try {
                await sendPacketWithRetry(recyclePacket, true);
            } catch (error) {
                console.error(`[TFD Automation] FAILED: Could not send recycle request for InvID ${invId}:`, error);
                updateStatus(`Error recycling ${itemName}: ${error.message}`, 'error');
            }
        }
    } else {
        console.warn(`[TFD Automation] WARNING: Could not process item. Invalid DefID or InvID. DefID: ${defId}, InvID: ${invId}`);
    }
}

// Function to add item to the received items log
function logReceivedItem(itemName, status) {
    // Check if the checkbox exists and is checked before skipping recycled and skipped items
    if (dontLogRecycledCheckbox && dontLogRecycledCheckbox.checked && (status === 'recycled' || status === 'skipped')) {
        return; // Do not log recycled or skipped items if the setting is checked
    }
    
    // Add debug logging to help troubleshoot
    console.log(`[TFD Automation] Logging item: ${itemName} (${status})`);
    
    receivedItems.push({ name: itemName, status, timestamp: new Date().toISOString() });
    renderItemLog();
    localStorage.setItem('tfd_item_log', JSON.stringify(receivedItems));
    
    // Force update the UI
    if (itemLog) {
        console.log(`[TFD Automation] Total received items: ${receivedItems.length}`);
    }
}

function renderItemLog() {
    if (!itemLog) {
        console.warn('[TFD Automation] itemLog element not found');
        return;
    }

    console.log(`[TFD Automation] Rendering item log with ${receivedItems.length} items`);

    const isCollapsed = itemLog.classList.contains('collapsed');
    const searchTerm = itemSearchBox ? itemSearchBox.value.toLowerCase() : '';
    
    // Filter items based on search term
    let filteredItems = receivedItems;
    if (searchTerm) {
        filteredItems = receivedItems.filter(item => 
            item.name.toLowerCase().includes(searchTerm) ||
            item.status.toLowerCase().includes(searchTerm)
        );
    }
    
    const itemsToRender = isCollapsed ? filteredItems.slice(-5) : filteredItems;

    if (receivedItems.length === 0) {
        itemLog.innerHTML = '<p class="text-sm text-text-secondary text-center">No items received yet.</p>';
        if (toggleLogButton) toggleLogButton.style.display = 'none';
        return;
    }

    if (filteredItems.length === 0 && searchTerm) {
        itemLog.innerHTML = '<p class="text-sm text-text-secondary text-center">No items match your search.</p>';
        if (toggleLogButton) toggleLogButton.style.display = 'none';
        return;
    }

    itemLog.innerHTML = ''; // Clear the log before rendering
    itemsToRender.forEach(item => {
        let iconClass;
        if (item.status === 'kept') {
            iconClass = 'fa-star text-yellow-400';
        } else if (item.status === 'skipped') {
            iconClass = 'fa-forward text-blue-400';
        } else {
            iconClass = 'fa-trash text-red-400'; // recycled
        }
        const itemElement = document.createElement('div');
        itemElement.className = 'flex items-center justify-between text-sm p-1 bg-gray-900/50 rounded';
        itemElement.innerHTML = `
            <span class="truncate">${item.name}</span>
            <i class="fas ${iconClass} ml-2"></i>
        `;
        itemLog.appendChild(itemElement);
    });

    // Manage toggle button visibility and text
    const totalCount = searchTerm ? filteredItems.length : receivedItems.length;
    if (totalCount > 5 && toggleLogButton) {
        toggleLogButton.style.display = 'inline-block';
        toggleLogButton.textContent = isCollapsed ? `Show All (${totalCount})` : 'Show Less';
    } else if (toggleLogButton) {
        toggleLogButton.style.display = 'none';
    }

    itemLog.scrollTop = itemLog.scrollHeight;
    console.log(`[TFD Automation] Rendered ${itemsToRender.length} items in log`);
}

// Function to clear the received items log
function clearItemLog() {
    receivedItems = [];
    renderItemLog();
    localStorage.removeItem('tfd_item_log');
    updateStatus('Item log cleared.', 'info');
}

// Function to open a file in the default editor
function openFileInEditor(fileName) {
    if (typeof require === 'function') {
        try {
            const { ipcRenderer } = require('electron');
            // The main process will resolve the full path relative to the plugin directory
            ipcRenderer.send('open-file-in-editor', fileName);
        } catch (e) {
            console.error(`[TFD Automation] Could not open file ${fileName}.`, e);
            updateStatus(`Error: Could not open file ${fileName}.`, 'error');
        }
    }
}

// --- Settings Persistence ---
function saveSettings() {
    if (dontLogRecycledCheckbox) {
        localStorage.setItem('tfd_dont_log_recycled', dontLogRecycledCheckbox.checked);
    }
    if (autoRetryCheckbox) {
        localStorage.setItem('tfd_auto_retry', autoRetryCheckbox.checked);
    }
    if (soundNotificationCheckbox) {
        localStorage.setItem('tfd_sound_notification', soundNotificationCheckbox.checked);
    }
    if (efficientModeCheckbox) {
        localStorage.setItem('tfd_efficient_mode', efficientModeCheckbox.checked);
    }
    if (specialModeCheckbox) {
        localStorage.setItem('tfd_special_mode', specialModeCheckbox.checked);
    }
    if (crystalDelay) {
        localStorage.setItem('tfd_crystal_delay', crystalDelay.value);
    }
    if (maxRetries) {
        localStorage.setItem('tfd_max_retries', maxRetries.value);
    }
    if (loopMode) {
        localStorage.setItem('tfd_loop_mode', loopMode.value);
    }
}

function loadSettings() {
    if (dontLogRecycledCheckbox) {
        const dontLogRecycled = localStorage.getItem('tfd_dont_log_recycled');
        if (dontLogRecycled !== null) {
            dontLogRecycledCheckbox.checked = JSON.parse(dontLogRecycled);
        }
    }
    
    if (autoRetryCheckbox) {
        const autoRetry = localStorage.getItem('tfd_auto_retry');
        if (autoRetry !== null) {
            autoRetryCheckbox.checked = JSON.parse(autoRetry);
        }
    }
    
    if (soundNotificationCheckbox) {
        const soundNotification = localStorage.getItem('tfd_sound_notification');
        if (soundNotification !== null) {
            soundNotificationCheckbox.checked = JSON.parse(soundNotification);
        }
    }
    
    if (efficientModeCheckbox) {
        const efficientMode = localStorage.getItem('tfd_efficient_mode');
        if (efficientMode !== null) {
            efficientModeCheckbox.checked = JSON.parse(efficientMode);
            // Update UI visibility
            const isChecked = efficientModeCheckbox.checked;
            if (specialModeContainer) {
                specialModeContainer.style.display = isChecked ? 'block' : 'none';
            }
            if (crystalDelayContainer) {
                crystalDelayContainer.style.display = isChecked ? 'block' : 'none';
            }
        }
    }
    
    if (specialModeCheckbox) {
        const specialMode = localStorage.getItem('tfd_special_mode');
        if (specialMode !== null) {
            specialModeCheckbox.checked = JSON.parse(specialMode);
        }
    }
    
    if (crystalDelay) {
        const delay = localStorage.getItem('tfd_crystal_delay');
        if (delay !== null) {
            crystalDelay.value = delay;
        }
    }
    
    if (maxRetries) {
        const maxRetriesValue = localStorage.getItem('tfd_max_retries');
        if (maxRetriesValue !== null) {
            maxRetries.value = maxRetriesValue;
        }
    }
    
    if (loopMode) {
        const loopModeValue = localStorage.getItem('tfd_loop_mode');
        if (loopModeValue !== null) {
            loopMode.value = loopModeValue;
        }
    }
}

// --- Event Listeners ---
if (dontLogRecycledCheckbox) dontLogRecycledCheckbox.addEventListener('change', saveSettings);
if (autoRetryCheckbox) autoRetryCheckbox.addEventListener('change', saveSettings);
if (soundNotificationCheckbox) soundNotificationCheckbox.addEventListener('change', saveSettings);
if (maxRetries) maxRetries.addEventListener('change', saveSettings);
if (loopMode) loopMode.addEventListener('change', saveSettings);

// Efficient Mode Event Listeners
if (efficientModeCheckbox) {
    efficientModeCheckbox.addEventListener('change', () => {
        const isChecked = efficientModeCheckbox.checked;
        if (specialModeContainer) {
            specialModeContainer.style.display = isChecked ? 'block' : 'none';
        }
        if (crystalDelayContainer) {
            crystalDelayContainer.style.display = isChecked ? 'block' : 'none';
        }
        saveSettings();
    });
}

if (specialModeCheckbox) {
    specialModeCheckbox.addEventListener('change', saveSettings);
}

if (crystalDelay) {
    crystalDelay.addEventListener('change', saveSettings);
}

// Event Listeners for UI buttons
if (startButton) startButton.addEventListener('click', startAutomation);
if (stopButton) stopButton.addEventListener('click', stopAutomation);
if (resetStatsButton) resetStatsButton.addEventListener('click', resetStats);
if (infoButton) infoButton.addEventListener('click', showModal);
if (saveWhitelistsButton) saveWhitelistsButton.addEventListener('click', saveWhitelists);
if (clearWhitelistsButton) clearWhitelistsButton.addEventListener('click', clearWhitelists);
if (clearLogButton) clearLogButton.addEventListener('click', clearItemLog);
if (toggleLogButton) {
    toggleLogButton.addEventListener('click', () => {
        itemLog.classList.toggle('collapsed');
        renderItemLog(); // Re-render to update view and button text
    });
}
if (openClothingJson) openClothingJson.addEventListener('click', () => openFileInEditor('1000-clothing.json'));
if (openDenItemsJson) openDenItemsJson.addEventListener('click', () => openFileInEditor('1030-denitems.json'));

// Add event listener for whitelist input changes to update status in real-time
if (clothingWhitelist) clothingWhitelist.addEventListener('input', updateFilteringStatus);
if (denWhitelist) denWhitelist.addEventListener('input', updateFilteringStatus);

// Add event listener for search box
if (itemSearchBox) {
    itemSearchBox.addEventListener('input', () => {
        renderItemLog();
    });
}

// Modal event listeners
if (closeModal) closeModal.addEventListener('click', hideModal);
if (startAutomationFromModal) {
    startAutomationFromModal.addEventListener('click', () => {
        hideModal();
        // Don't auto-start, just close the modal
    });
}

// Close modal when clicking outside
if (educationalModal) {
    educationalModal.addEventListener('click', (e) => {
        if (e.target === educationalModal) {
            hideModal();
        }
    });
}

// Function to load item data from JSON files
async function loadItemData() {
    try {
        const clothingResponse = await fetch('./1000-clothing.json');
        if (clothingResponse.ok) {
            clothingItems = await clothingResponse.json();
        } else {
            console.error('[TFD Automation] Failed to load clothing.json');
        }

        const denItemsResponse = await fetch('./1030-denitems.json');
        if (denItemsResponse.ok) {
            denItems = await denItemsResponse.json();
        } else {
            console.error('[TFD Automation] Failed to load den_items.json');
        }
    } catch (error) {
        console.error('[TFD Automation] Error loading item data:', error);
    }
}

// Function to load the item log from localStorage
function loadItemLog() {
    const savedLog = localStorage.getItem('tfd_item_log');
    if (savedLog) {
        try {
            receivedItems = JSON.parse(savedLog);
            renderItemLog();
        } catch (e) {
            console.error('[TFD Automation] Failed to load item log:', e);
            receivedItems = [];
        }
    }
}


// Initialize
async function initialize() {
    loadStats();
    loadSettings();
    loadWhitelists();
    loadItemLog();
    await loadItemData();

    // The plugin's 'dispatch' object does not have event listeners.
    // We must use ipcRenderer to listen for events from the main application.
    if (typeof require === 'function') {
        try {
            const { ipcRenderer } = require('electron');
            
            // Listener for individual packets
            ipcRenderer.on('packet-event', (event, data) => {
                handleIncomingPackets(data);
                // Handle efficient mode packets
                if (isEfficientMode && isAutomationRunning) {
                    efficientHandleQqm(data);
                }
            });

            // Listener for global connection status changes
            ipcRenderer.on('connection-status-changed', (event, isConnected) => {
                if (!isConnected && isAutomationRunning) {
                    updateStatus('Connection lost. Stopping automation.', 'error');
                    stopAutomation();
                }
            });

        } catch (e) {
            console.error('[TFD Automation] Could not set up IPC listeners.', e);
            updateStatus('Error: Could not initialize listeners.', 'error');
        }
    }

    updateStatus('Ready to start TFD automation', 'info');
}

initialize();
