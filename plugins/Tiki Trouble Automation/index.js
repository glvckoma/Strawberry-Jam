const { dispatch, application } = jam;
const tikiPackets = require('./tiki_trouble_packets.json');

const startButton = document.getElementById('startButton');
const stopButton = document.getElementById('stopButton');
const resetButton = document.getElementById('resetButton');
const statusMessage = document.getElementById('statusMessage');
const statusIcon = document.getElementById('statusIcon');
const progressBar = document.getElementById('progressBar');
const progressText = document.getElementById('progressText');
const loopMode = document.getElementById('loopMode');
const soundEnabled = document.getElementById('soundEnabled');
const autoRetry = document.getElementById('autoRetry');
const maxRetries = document.getElementById('maxRetries');
const targetAccount = document.getElementById('targetAccount');
const settingsHeader = document.getElementById('settingsHeader');
const settingsBody = document.getElementById('settingsBody');
const settingsChevron = document.getElementById('settingsChevron');
const statSuccessful = document.getElementById('statSuccessful');
const statFailed = document.getElementById('statFailed');
const statTotal = document.getElementById('statTotal');

let isAutomationRunning = false;
let currentTimeout = null;
let countdownInterval = null;
let currentRoom = null;
let currentInternalRoomId = null;
let currentUserId = null;
let currentStep = 0;
let totalSteps = 0;
let currentLoopCount = 0;
let totalLoopsToRun = 1;
let stats = { successful: 0, failed: 0, total: 0 };

const STORAGE_PREFIX = 'tiki_trouble_';

const pad = (n) => String(n).padStart(2, '0');

function toggleSection(body, chevron, storageKey) {
    const isCollapsed = body.classList.contains('collapsed');
    if (isCollapsed) {
        body.classList.remove('collapsed');
        if (chevron) chevron.style.transform = 'rotate(0deg)';
    } else {
        body.classList.add('collapsed');
        if (chevron) chevron.style.transform = 'rotate(-90deg)';
    }
    localStorage.setItem(storageKey, !isCollapsed);
}

function loadSettings() {
    const collapsed = localStorage.getItem(STORAGE_PREFIX + 'settings_collapsed');
    if (collapsed === 'true') {
        settingsBody.classList.add('collapsed');
        settingsChevron.style.transform = 'rotate(-90deg)';
    }

    const sound = localStorage.getItem(STORAGE_PREFIX + 'sound');
    if (sound !== null) soundEnabled.checked = JSON.parse(sound);

    const retry = localStorage.getItem(STORAGE_PREFIX + 'auto_retry');
    if (retry !== null) autoRetry.checked = JSON.parse(retry);

    const retries = localStorage.getItem(STORAGE_PREFIX + 'max_retries');
    if (retries !== null) maxRetries.value = retries;

    const loop = localStorage.getItem(STORAGE_PREFIX + 'loop_mode');
    if (loop !== null) loopMode.value = loop;

    const savedStats = localStorage.getItem(STORAGE_PREFIX + 'stats');
    if (savedStats) {
        try {
            stats = JSON.parse(savedStats);
            renderStats();
        } catch (e) {}
    }
}

function saveSettings() {
    localStorage.setItem(STORAGE_PREFIX + 'sound', soundEnabled.checked);
    localStorage.setItem(STORAGE_PREFIX + 'auto_retry', autoRetry.checked);
    localStorage.setItem(STORAGE_PREFIX + 'max_retries', maxRetries.value);
    localStorage.setItem(STORAGE_PREFIX + 'loop_mode', loopMode.value);
}

function saveStats() {
    localStorage.setItem(STORAGE_PREFIX + 'stats', JSON.stringify(stats));
}

function renderStats() {
    statSuccessful.textContent = stats.successful;
    statFailed.textContent = stats.failed;
    statTotal.textContent = stats.total;
}

function resetStats() {
    stats = { successful: 0, failed: 0, total: 0 };
    saveStats();
    renderStats();
}

function playNotificationSound(type = 'success') {
    if (!soundEnabled || !soundEnabled.checked) return;
    try {
        const ctx = new (window.AudioContext || window.webkitAudioContext)();
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.connect(gain);
        gain.connect(ctx.destination);

        if (type === 'success') {
            osc.frequency.setValueAtTime(523, ctx.currentTime);
            osc.frequency.setValueAtTime(659, ctx.currentTime + 0.1);
            osc.frequency.setValueAtTime(784, ctx.currentTime + 0.2);
            gain.gain.setValueAtTime(0.3, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.4);
            osc.start(ctx.currentTime);
            osc.stop(ctx.currentTime + 0.4);
        } else if (type === 'error') {
            osc.frequency.setValueAtTime(400, ctx.currentTime);
            osc.frequency.setValueAtTime(300, ctx.currentTime + 0.15);
            gain.gain.setValueAtTime(0.3, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.4);
            osc.start(ctx.currentTime);
            osc.stop(ctx.currentTime + 0.4);
        } else if (type === 'failure') {
            osc.frequency.setValueAtTime(200, ctx.currentTime);
            gain.gain.setValueAtTime(0.3, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.6);
            osc.start(ctx.currentTime);
            osc.stop(ctx.currentTime + 0.6);
        }
    } catch (e) {}
}

const refreshRoom = async () => {
    try {
        currentRoom = await dispatch.getState('room');
        const internalRoomState = await dispatch.getState('internalRoomId');
        if (internalRoomState) {
            const parsed = parseInt(internalRoomState, 10);
            if (!isNaN(parsed)) currentInternalRoomId = parsed;
        }
    } catch (e) {
        currentRoom = null;
        currentInternalRoomId = null;
    }
};

const refreshUserId = async () => {
    try {
        const userId = await dispatch.getState('userId');
        if (userId) currentUserId = userId;
    } catch (e) {}
};

const getRoomIdToUse = () => currentInternalRoomId || currentRoom;

async function isConnected() {
    try {
        return await dispatch.getState('connected');
    } catch (e) {
        return false;
    }
}

async function updateAccountDropdown() {
    try {
        let clients = [];
        if (dispatch && typeof dispatch.getConnectedClients === 'function') {
            clients = await dispatch.getConnectedClients();
        }
        const savedAccount = localStorage.getItem(STORAGE_PREFIX + 'target_account');
        targetAccount.innerHTML = '<option value="">All Accounts</option>';
        const seen = new Set();
        clients.forEach(client => {
            if (client && client.username && client.connected && !seen.has(client.username)) {
                seen.add(client.username);
                const opt = document.createElement('option');
                opt.value = client.username;
                opt.textContent = client.username;
                targetAccount.appendChild(opt);
            }
        });
        if (savedAccount) targetAccount.value = savedAccount;
    } catch (e) {}
}

function updateStatus(message, type = 'info', step = null) {
    if (statusMessage) statusMessage.textContent = message;

    if (statusIcon) {
        let iconClass = 'fas fa-circle text-gray-400';
        let iconText = 'Idle';
        switch (type) {
            case 'success':
                iconClass = 'fas fa-check-circle text-green-400';
                iconText = 'Success';
                break;
            case 'error':
                iconClass = 'fas fa-exclamation-circle text-red-400';
                iconText = 'Error';
                break;
            case 'warning':
                iconClass = 'fas fa-exclamation-triangle text-yellow-400';
                iconText = 'Warning';
                break;
            case 'info':
                if (isAutomationRunning) {
                    iconClass = 'fas fa-spinner fa-spin text-blue-400';
                    iconText = 'Running';
                }
                break;
        }
        statusIcon.innerHTML = `<i class="${iconClass}" style="font-size: 8px; margin-right: 4px;"></i>${iconText}`;
    }

    if (step !== null && totalSteps > 0) {
        currentStep = step;
        const progress = Math.round((currentStep / totalSteps) * 100);
        if (progressBar) progressBar.style.width = `${progress}%`;
        if (progressText) progressText.textContent = `${progress}%`;
    }

    if (application && application.consoleMessage) {
        application.consoleMessage({ message: `Tiki Trouble: ${message}`, type });
    }
}

async function sendPacket(packet, step) {
    if (!isAutomationRunning) return;

    if (!(await isConnected())) {
        stopAutomation();
        throw new Error('Connection lost. Automation stopped.');
    }

    await refreshRoom();
    await refreshUserId();
    const roomId = getRoomIdToUse();
    if (!roomId) throw new Error('No room ID available.');

    let content = packet.content.replaceAll('{room}', roomId);
    if (currentUserId) {
        content = content.replaceAll('{userId}', currentUserId);
    }
    const delay = parseFloat(packet.delay) * 1000;

    updateStatus(`Sending: ${packet.name}`, 'info', step);

    const options = {};
    const selectedAccount = targetAccount ? targetAccount.value : '';
    if (selectedAccount) options.targetUsername = selectedAccount;

    await dispatch.sendRemoteMessage(content, options);

    if (delay > 0) {
        if (delay >= 30000) {
            await waitWithCountdown(Math.ceil(delay / 1000), `Waiting after ${packet.name}`, step);
        } else {
            updateStatus(`Waiting ${packet.delay}s...`, 'info', step);
            return new Promise(resolve => {
                currentTimeout = setTimeout(resolve, delay);
            });
        }
    }
}

async function sendPacketWithRetry(packet, step, retryCount = 0) {
    try {
        await sendPacket(packet, step);
    } catch (error) {
        const shouldRetry = autoRetry && autoRetry.checked;
        const maxRetryCount = parseInt(maxRetries ? maxRetries.value : '3', 10);

        if (shouldRetry && retryCount < maxRetryCount) {
            const delay = 5000 * (retryCount + 1);
            updateStatus(`Retry ${retryCount + 1}/${maxRetryCount} in ${delay / 1000}s...`, 'warning', step);
            await sleep(delay);
            return sendPacketWithRetry(packet, step, retryCount + 1);
        }
        throw error;
    }
}

function sleep(ms) {
    return new Promise(resolve => {
        currentTimeout = setTimeout(resolve, ms);
    });
}

async function waitWithCountdown(totalSeconds, label = 'Waiting', step = null) {
    if (!isAutomationRunning) return;
    let remaining = totalSeconds;
    updateStatus(`${label} ${Math.floor(remaining / 60)}m ${pad(remaining % 60)}s...`, 'info', step);
    await new Promise(resolve => {
        countdownInterval = setInterval(() => {
            if (!isAutomationRunning) {
                clearInterval(countdownInterval);
                countdownInterval = null;
                resolve();
                return;
            }
            remaining -= 1;
            if (remaining <= 0) {
                clearInterval(countdownInterval);
                countdownInterval = null;
                resolve();
                return;
            }
            updateStatus(`${label} ${Math.floor(remaining / 60)}m ${pad(remaining % 60)}s...`, 'info', step);
        }, 1000);
    });
}

async function validateDenStart() {
    await refreshRoom();
    const textualRoom = await dispatch.getState('room');
    if (!textualRoom || typeof textualRoom !== 'string' || !textualRoom.toLowerCase().startsWith('den')) {
        updateStatus('You must start from your den.', 'error');
        playNotificationSound('error');
        return false;
    }
    return true;
}

function parseLoopSettings() {
    const loopValue = loopMode ? loopMode.value : '1';
    if (loopValue === 'infinite') {
        totalLoopsToRun = Infinity;
    } else {
        totalLoopsToRun = parseInt(loopValue, 10) || 1;
    }
    currentLoopCount = 0;
}

async function runSingleAutomation() {
    currentLoopCount += 1;
    currentStep = 0;
    const packets = (tikiPackets && tikiPackets.packets) ? tikiPackets.packets : [];
    totalSteps = packets.length;

    try {
        await refreshRoom();
        await refreshUserId();
        const roomId = getRoomIdToUse();
        if (!roomId) {
            updateStatus('Not in a valid room.', 'error');
            playNotificationSound('error');
            stopAutomation();
            return;
        }

        if (!currentUserId) {
            updateStatus('Could not fetch user ID. Please ensure you are logged in.', 'error');
            playNotificationSound('error');
            stopAutomation();
            return;
        }

        const loopLabel = totalLoopsToRun === Infinity
            ? `(Run ${currentLoopCount})`
            : `(Run ${currentLoopCount}/${totalLoopsToRun})`;

        for (let i = 0; i < packets.length; i++) {
            if (!isAutomationRunning) return;
            updateStatus(`${loopLabel} ${packets[i].name}`, 'info', i + 1);
            await sendPacketWithRetry(packets[i], i + 1);
        }

        stats.successful++;
        stats.total++;
        saveStats();
        renderStats();
        playNotificationSound('success');
        updateStatus(`${loopLabel} Run completed!`, 'success', totalSteps);

    } catch (error) {
        stats.failed++;
        stats.total++;
        saveStats();
        renderStats();
        playNotificationSound('failure');
        updateStatus(`Error: ${error.message}`, 'error');
        stopAutomation();
    }
}

async function startAutomation() {
    if (!(await validateDenStart())) return;

    parseLoopSettings();
    saveSettings();
    isAutomationRunning = true;
    startButton.disabled = true;
    stopButton.disabled = false;

    const loopLabel = totalLoopsToRun === Infinity ? 'infinite' : totalLoopsToRun;
    updateStatus(`Starting (${loopLabel} run${totalLoopsToRun !== 1 ? 's' : ''})...`, 'info');

    do {
        if (!isAutomationRunning) break;
        await runSingleAutomation();
        if (!isAutomationRunning) break;
        if (totalLoopsToRun === Infinity || currentLoopCount < totalLoopsToRun) {
            updateStatus(`Preparing next run (${currentLoopCount}/${loopLabel})...`, 'info');
            await sleep(3000);
        } else {
            break;
        }
    } while (isAutomationRunning);

    stopAutomation();
}

function stopAutomation() {
    isAutomationRunning = false;
    currentLoopCount = 0;
    totalLoopsToRun = 1;
    if (currentTimeout) {
        clearTimeout(currentTimeout);
        currentTimeout = null;
    }
    if (countdownInterval) {
        clearInterval(countdownInterval);
        countdownInterval = null;
    }
    startButton.disabled = false;
    stopButton.disabled = true;
    if (progressBar) progressBar.style.width = '0%';
    if (progressText) progressText.textContent = '0%';
    updateStatus('Stopped.', 'info');
}

startButton.addEventListener('click', startAutomation);
stopButton.addEventListener('click', stopAutomation);
resetButton.addEventListener('click', resetStats);

settingsHeader.addEventListener('click', () => {
    toggleSection(settingsBody, settingsChevron, STORAGE_PREFIX + 'settings_collapsed');
});

soundEnabled.addEventListener('change', saveSettings);
autoRetry.addEventListener('change', saveSettings);
maxRetries.addEventListener('change', saveSettings);
loopMode.addEventListener('change', saveSettings);
targetAccount.addEventListener('change', () => {
    localStorage.setItem(STORAGE_PREFIX + 'target_account', targetAccount.value);
});

function initialize() {
    loadSettings();
    updateAccountDropdown();
    updateStatus('Ready to start. Begin from your den.', 'info');

    if (typeof require === 'function') {
        try {
            const { ipcRenderer } = require('electron');
            ipcRenderer.on('connection-status-changed', (event, connected) => {
                if (!connected && isAutomationRunning) {
                    updateStatus('Connection lost. Stopping.', 'error');
                    playNotificationSound('failure');
                    stopAutomation();
                }
            });
        } catch (e) {}
    }
}

initialize();
