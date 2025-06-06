// --- Global Variables & Constants ---
const IS_DEV = true; // Set to false for production builds to disable logs
let colorsDispatch = null; // Will hold the dispatch object once ready
const colors = [
    "#793647", "#762626", "#8b4c2b", "#9c8726", "#426b31", "#346851", "#396573", "#263876", "#463779", "#61316c",
    "#5c2e39", "#563520", "#6a4e31", "#6c643a", "#565a36", "#4b6351", "#33415e", "#3d3443", "#591d1d", "#6d7164",
    "#c5647d", "#be4b4b", "#e08654", "#fadb4d", "#73ae5a", "#5eab89", "#67a8bb", "#4b66be", "#7b66c6", "#a05aaf",
    "#965264", "#8c5c3d", "#ad8459", "#b1a669", "#8f9560", "#82a58b", "#5c6f99", "#675a70", "#903838", "#b8bdab",
    "#ee94ac", "#ed8383", "#ffb48a", "#ffec95", "#a8de90", "#95dbbd", "#98d4e6", "#839bed", "#a895ef", "#d190e0",
    "#cd8f9f", "#ca9d80", "#ddb890", "#ded39b", "#c5ca9a", "#afd1b9", "#95a7cf", "#a89bb0", "#ce7c7c", "#d7dcca",
    "#8b8a68", "#82727d", "#69838b", "#1a1a1a", "#666666", "#b3b3b3", "#987b35", "#80421e", "#07050c", "#eb6923",
    "#26632d", "#805912", "#20d998", "#d9cd20", "#080905", "#070a08", "#1c6075", "#060507", "#090303", "#0b0b0a",
    "#e7e5b4", "#dac2d3", "#b6dce7", "#333333", "#808080", "#cccccc", "#f7cd66", "#ce723e", "#612f25", "#100911",
    "#34944f", "#eea621", "#944c22", "#ee555d", "#eb5ba1", "#0d100e", "#2098d9", "#e13a74", "#0e0505", "#82d92b",
    "#faf8ca", "#eed8e6", "#cceff9", "#4d4d4d", "#999999", "#e6e6e6", "#ffe4a1", "#fca575", "#e1654c", "#140e16",
    "#8fdc9f", "#ffb870", "#ffd040", "#8c1414", "#f589bd", "#4b87bf", "#4ac3e8", "#45ae53", "#d32626", "#151614",
    "#853e3e", "#854b3e", "#85593e", "#85633e", "#85713e", "#857d3e", "#84853e", "#77853e", "#63853e", "#3e8565",
    "#3e857f", "#3e7285", "#3e4e85", "#403e85", "#4d3e85", "#5c3e85", "#693e85", "#783e85", "#853e70", "#853e5a",
    "#b96161", "#b97161", "#b98261", "#b99061", "#b9a161", "#b9af61", "#b8b961", "#a8b961", "#8fb961", "#61b993",
    "#61b9b2", "#61a2b9", "#6175b9", "#6461b9", "#7461b9", "#8761b9", "#9761b9", "#a961b9", "#b9619f", "#b96184",
    "#de9e9e", "#dea99e", "#deb59e", "#debf9e", "#decc9e", "#ded69e", "#dcde9e", "#d1de9e", "#bfde9e", "#9edec2",
    "#9eded9", "#9ecdde", "#9eacde", "#9f9ede", "#ab9ede", "#b99ede", "#c49ede", "#d29ede", "#de9ecb", "#de9eb7",
    "#705555", "#705a55", "#706155", "#706355", "#706955", "#706e55", "#707055", "#6b7055", "#637055", "#557065",
    "#55706f", "#556970", "#555b70", "#565570", "#5b5570", "#615570", "#655570", "#6b5570", "#705569", "#705561",
    "#a07e7e", "#a0847e", "#a08c7e", "#a0907e", "#a0977e", "#a09c7e", "#a0a07e", "#99a07e", "#90a07e", "#7ea092",
    "#7ea09e", "#7e97a0", "#7e86a0", "#7f7ea0", "#857ea0", "#8d7ea0", "#937ea0", "#997ea0", "#a07e96", "#a07e8c",
    "#cbb2b2", "#cbb7b2", "#cbbcb2", "#cbbeb2", "#cbc3b2", "#cbc7b2", "#cbcbb2", "#c6cbb2", "#becbb2", "#b2cbc1",
    "#b2cbc8", "#b2c3cb", "#b2b8cb", "#b3b2cb", "#b7b2cb", "#bdb2cb", "#c1b2cb", "#c6b2cb", "#cbb2c3", "#cbb2bc",
    "#d34242", "#d57740", "#e9ce2c", "#75c054", "#4bc993", "#62b4cc", "#4264d3", "#7b60da", "#ae54c1", "#0b180b",
    "#0e1812", "#0d1717", "#0d0e15", "#110c15", "#000000", "#ffffff"
];
const ajClassicColorIndices = [
    63, 18, 11, 12, 31, 32, 15, 16, 7, 135,
    103, 1, 38, 21, 87, 23, 129, 36, 27, 137,
    104, 139, 140, 20, 107, 86, 24, 25, 131, 37,
    105, 157, 40, 162, 42, 106, 44, 150, 151, 28,
    101, 178, 160, 222, 52, 43, 164, 169, 171, 175
];
const exclusiveColorIndices = colors.map((_, index) => index).filter(index => !ajClassicColorIndices.includes(index));
let presets = [];

// --- Utility Functions ---
function hexToSignedInt(hex) {
    let num = parseInt(hex, 16);
    if ((num & 0x80000000) !== 0) {
        num = num - 0x100000000;
    }
    return num;
}
function convertToHexString(color1, color2, color3, color4) {
    const color1Hex = color1.toString(16).padStart(2, '0').toUpperCase();
    const color2Hex = color2.toString(16).padStart(2, '0').toUpperCase();
    const color3Hex = color3.toString(16).padStart(2, '0').toUpperCase();
    const color4Hex = color4.toString(16).padStart(2, '0').toUpperCase();
    return `${color1Hex}${color2Hex}${color3Hex}${color4Hex}`;
}
function hexToRGB(hex) {
    const bigint = parseInt(hex.slice(1), 16);
    const r = (bigint >> 16) & 255;
    const g = (bigint >> 8) & 255;
    const b = bigint & 255;
    return [r, g, b];
}
function calculateDistance(color1, color2) {
    return Math.sqrt(
        Math.pow(color1[0] - color2[0], 2) +
        Math.pow(color1[1] - color2[1], 2) +
        Math.pow(color1[2] - color2[2], 2)
    );
}
function findClosestColor(targetColor) {
    const targetRGB = hexToRGB(targetColor);
    let closestIndex = 0;
    let closestDistance = Infinity;

    colors.forEach((color, index) => {
        const colorRGB = hexToRGB(color);
        const distance = calculateDistance(targetRGB, colorRGB);

        if (distance < closestDistance) {
            closestDistance = distance;
            closestIndex = index;
        }
    });

    // Clamp the index to ensure it's within bounds
    const finalIndex = Math.min(closestIndex, colors.length - 1);
    if (IS_DEV && finalIndex !== closestIndex) {
        console.warn(`[Colors] Clamped closest color index from ${closestIndex} to ${finalIndex}`);
    }
    return finalIndex;
}

// --- Core Logic Functions ---
async function getColorPacket(primaryColor, secondaryColor, patternColor, eyeColor) {
    if (!colorsDispatch) {
        if (IS_DEV) console.error('[Colors] Dispatch not ready for getColorPacket');
        colorsDispatch.showToast('Colors: Dispatch not ready.', 'error');
        return null; // Or handle error appropriately
    }
    
    // Get room ID - after reversion, this will be the primary method
    const textualRoomId = await colorsDispatch.getState('room');
    let internalRoomIdValue = await colorsDispatch.getState('internalRoomId');
    let parsedInternalRoomId = null;

    if (internalRoomIdValue !== null && internalRoomIdValue !== undefined) {
        parsedInternalRoomId = parseInt(internalRoomIdValue, 10);
        if (isNaN(parsedInternalRoomId)) {
            if (IS_DEV) console.warn(`[Colors] internalRoomId '${internalRoomIdValue}' could not be parsed to a number.`);
            parsedInternalRoomId = null; // Ensure it's null if parsing failed
        }
    }

    let roomIdToUse = null;

    if (parsedInternalRoomId !== null) {
        roomIdToUse = parsedInternalRoomId;
        if (IS_DEV) console.log(`[Colors] Using parsed internalRoomId: ${parsedInternalRoomId}`);
    } else if (textualRoomId) {
        roomIdToUse = textualRoomId;
        if (IS_DEV) console.warn(`[Colors] Parsed internalRoomId not available (original value: ${internalRoomIdValue}). Falling back to textualRoomId: ${textualRoomId}. Packet may not work as expected.`);
    }

    if (!roomIdToUse) {
        if (IS_DEV) console.error('[Colors] No room identifier available (textual or internal). Cannot generate color packet.');
        colorsDispatch.showToast('Colors: Room not found. Cannot send packet.', 'error');
        return null; // Prevent sending a malformed packet
    }

    if (IS_DEV) console.log(`[Colors] Room ID for packet: ${roomIdToUse} (Source: ${parsedInternalRoomId !== null ? 'internalRoomId' : 'textualRoomId'})`);

    const bodyColorHex = convertToHexString(primaryColor, secondaryColor, 0, 0);
    const patternColorHex = convertToHexString(patternColor, 0, 0, 0);
    const eyeColorHex = convertToHexString(eyeColor, 0, 0, 0);
    const bodyColor = hexToSignedInt(bodyColorHex);
    const patternColorInt = hexToSignedInt(patternColorHex);
    const eyeColorInt = hexToSignedInt(eyeColorHex);
    // Reverting to dynamic room ID based on user feedback.
    // The original robust room fetching logic (lines 101-146) will provide the ${room} variable.
    // This check is now redundant due to the check at the beginning of the function.
    // if (!room) { // Ensure room is available, otherwise packet is invalid
    //     if (IS_DEV) console.error('[Colors] Cannot generate color packet: Room ID is unavailable.');
    //     // alert('Error: Could not determine your current room. Cannot send color packet.'); // Optional user feedback
    //     return null; // Prevent sending a malformed packet
    // }
    return `%xt%o%ap%${roomIdToUse}%${bodyColor}%${patternColorInt}%${eyeColorInt}%0%`;
}
async function sendColorPacket() {
    if (!colorsDispatch) {
        if (IS_DEV) console.error('[Colors] Dispatch not ready for sendColorPacket');
        colorsDispatch.showToast('Colors: Dispatch not ready.', 'error');
        return;
    }
    const primaryBodyColor = parseInt(document.getElementById('primaryBodyColor').value, 10);
    const secondaryBodyColor = parseInt(document.getElementById('secondaryBodyColor').value, 10);
    const patternColor = parseInt(document.getElementById('patternColor').value, 10);
    const eyeColor = parseInt(document.getElementById('eyeColor').value, 10);

    if (IS_DEV) console.log(`[Colors] sendColorPacket - Indices: Primary=${primaryBodyColor}, Secondary=${secondaryBodyColor}, Pattern=${patternColor}, Eye=${eyeColor}`);

    const colorPacket = await getColorPacket(primaryBodyColor, secondaryBodyColor, patternColor, eyeColor);
    if (colorPacket) {
        if (IS_DEV) console.log('[Colors] Sending packet:', colorPacket);
        colorsDispatch.sendRemoteMessage(colorPacket);
        // Show alert after sending
        alert('Colors sent! Relog or switch animals to see the changes.');
    }
}
function copyColorPacket() {
    const primaryBodyColor = parseInt(document.getElementById('primaryBodyColor').value, 10);
    const secondaryBodyColor = parseInt(document.getElementById('secondaryBodyColor').value, 10);
    const patternColor = parseInt(document.getElementById('patternColor').value, 10);
    const eyeColor = parseInt(document.getElementById('eyeColor').value, 10);

    if (IS_DEV) console.log(`[Colors] copyColorPacket - Indices: Primary=${primaryBodyColor}, Secondary=${secondaryBodyColor}, Pattern=${patternColor}, Eye=${eyeColor}`);

    const colorPacket = getColorPacket(primaryBodyColor, secondaryBodyColor, patternColor, eyeColor);
    if (colorPacket) {
        if (IS_DEV) console.log('[Colors] Copying packet:', colorPacket);
        
        // Try to copy to clipboard using multiple methods
        const copyToClipboard = async () => {
            // Method 1: Modern clipboard API with focus check
            if (document.hasFocus()) {
                try {
                    await navigator.clipboard.writeText(colorPacket);
                    alert(`Packet copied to clipboard!\n${colorPacket}`);
                    return true;
                } catch (err) {
                    if (IS_DEV) console.error('[Colors] Clipboard API error: ', err);
                    // Fall through to alternative methods
                }
            }
            
            // Method 2: execCommand fallback (older browsers)
            try {
                const textArea = document.createElement('textarea');
                textArea.value = colorPacket;
                textArea.style.position = 'fixed';  // Avoid scrolling to bottom
                document.body.appendChild(textArea);
                textArea.focus();
                textArea.select();
                
                const successful = document.execCommand('copy');
                document.body.removeChild(textArea);
                
                if (successful) {
                    alert(`Packet copied to clipboard!\n${colorPacket}`);
                    return true;
                }
            } catch (err) {
                if (IS_DEV) console.error('[Colors] execCommand fallback error: ', err);
                // Fall through to final method
            }
            
            // Method 3: If all else fails, show the packet for manual copy
            const packetDisplay = document.createElement('div');
            packetDisplay.style.position = 'fixed';
            packetDisplay.style.top = '50%';
            packetDisplay.style.left = '50%';
            packetDisplay.style.transform = 'translate(-50%, -50%)';
            packetDisplay.style.backgroundColor = '#1c1e26';
            packetDisplay.style.padding = '20px';
            packetDisplay.style.borderRadius = '5px';
            packetDisplay.style.zIndex = '9999';
            packetDisplay.style.boxShadow = '0 0 10px rgba(0,0,0,0.5)';
            packetDisplay.style.maxWidth = '90%';
            
            packetDisplay.innerHTML = `
                <p style="margin-bottom: 10px; color: white;">Could not copy automatically. Please select and copy this packet:</p>
                <textarea style="width: 100%; min-width: 300px; padding: 10px; font-family: monospace; margin-bottom: 10px;">${colorPacket}</textarea>
                <button style="padding: 5px 10px; background: #38b000; color: white; border: none; border-radius: 3px; cursor: pointer;" id="closePacketDisplay">Close</button>
            `;
            
            document.body.appendChild(packetDisplay);
            const textarea = packetDisplay.querySelector('textarea');
            textarea.select();
            
            document.getElementById('closePacketDisplay').addEventListener('click', () => {
                document.body.removeChild(packetDisplay);
            });
            
            return false;
        };
        
        copyToClipboard();
    } else {
        alert('Could not generate packet to copy.');
    }
}

// --- UI Interaction Functions ---
function openModal() {
    document.getElementById('modal').style.display = 'block';
}
function closeModal() {
    document.getElementById('modal').style.display = 'none';
}
function openColorChart(inputId) {
    const colorChart = document.getElementById('colorChart');
    colorChart.innerHTML = '';
    colors.forEach((color, index) => {
        const colorCell = document.createElement('div');
        colorCell.className = 'color-cell';
        colorCell.style.backgroundColor = color;
        colorCell.onclick = () => selectColor(index, color, inputId);
        colorChart.appendChild(colorCell);
    });

    const ajColorChart = document.getElementById('ajClassicChart'); // Corrected ID
    ajColorChart.innerHTML = '';
    ajClassicColorIndices.forEach((index) => {
        const color = colors[index];
        const colorCell = document.createElement('div');
        colorCell.className = 'color-cell';
        colorCell.style.backgroundColor = color;
        colorCell.onclick = () => selectColor(index, color, inputId);
        ajColorChart.appendChild(colorCell);
    });

    const exclusiveColorChart = document.getElementById('exclusiveColorChart'); // Corrected ID
    exclusiveColorChart.innerHTML = '';
    exclusiveColorIndices.forEach((index) => {
        const color = colors[index];
        const colorCell = document.createElement('div');
        colorCell.className = 'color-cell';
        colorCell.style.backgroundColor = color;
        colorCell.onclick = () => selectColor(index, color, inputId);
        exclusiveColorChart.appendChild(colorCell);
    });

    document.getElementById('modal').style.display = 'block';
}
function selectColor(colorIndex, color, inputId) {
    document.getElementById(inputId).value = colorIndex;
    document.getElementById(`${inputId}Display`).style.backgroundColor = color;
    closeModal();
}
function switchTab(tabName) {
    document.querySelectorAll('.tab-button').forEach(button => {
        button.classList.remove('active');
    });
    document.querySelectorAll('.color-chart-tab').forEach(tab => {
        tab.classList.remove('active');
    });

    if (tabName === 'full') {
        document.querySelector('.tab-button:nth-child(1)').classList.add('active');
        document.getElementById('fullChart').classList.add('active');
    } else if (tabName === 'ajClassic') {
        document.querySelector('.tab-button:nth-child(2)').classList.add('active');
        document.getElementById('ajClassicChart').classList.add('active'); // Corrected ID
    } else if (tabName === 'exclusive') {
        document.querySelector('.tab-button:nth-child(3)').classList.add('active');
        document.getElementById('exclusiveChart').classList.add('active'); // Corrected ID
    }
}
function sendHelloMessage() {
    alert('Color Changer by Nosmile\nIntegrated with Strawberry Jam');
}
function openColorPicker(inputId) {
    const colorPicker = document.getElementById('colorPicker');
    colorPicker.value = "#ffffff"; // Default to white
    colorPicker.click();

    // Use 'oninput' for live updates as the user drags the picker
    colorPicker.oninput = function() {
        const selectedColor = colorPicker.value;
        const closestColorIndex = findClosestColor(selectedColor);
        const closestColor = colors[closestColorIndex];

        document.getElementById(inputId).value = closestColorIndex;
        document.getElementById(`${inputId}Display`).style.backgroundColor = closestColor;
    };
}
function randomizeColors() {
    const primaryColorIndex = Math.floor(Math.random() * colors.length);
    const secondaryColorIndex = Math.floor(Math.random() * colors.length);
    const patternColorIndex = Math.floor(Math.random() * colors.length);
    const eyeColorIndex = Math.floor(Math.random() * colors.length);

    document.getElementById('primaryBodyColor').value = primaryColorIndex;
    document.getElementById('primaryBodyColorDisplay').style.backgroundColor = colors[primaryColorIndex];

    document.getElementById('secondaryBodyColor').value = secondaryColorIndex;
    document.getElementById('secondaryBodyColorDisplay').style.backgroundColor = colors[secondaryColorIndex];

    document.getElementById('patternColor').value = patternColorIndex;
    document.getElementById('patternColorDisplay').style.backgroundColor = colors[patternColorIndex];

    document.getElementById('eyeColor').value = eyeColorIndex;
    document.getElementById('eyeColorDisplay').style.backgroundColor = colors[eyeColorIndex];
}

// --- Preset Functions ---
function addPreset() {
    const primaryColor = parseInt(document.getElementById('primaryBodyColor').value, 10);
    const secondaryColor = parseInt(document.getElementById('secondaryBodyColor').value, 10);
    const patternColor = parseInt(document.getElementById('patternColor').value, 10);
    const eyeColor = parseInt(document.getElementById('eyeColor').value, 10);

    const preset = {
        primaryColor,
        secondaryColor,
        patternColor,
        eyeColor,
        name: `Color Preset ${presets.length + 1}`
    };

    presets.unshift(preset); // Add to the beginning
    renderPresets();
}
function renderPresets() {
    const presetContainer = document.getElementById('presetContainer');
    presetContainer.innerHTML = ''; // Clear existing presets

    presets.forEach((preset, index) => {
        const presetElement = document.createElement('div');
        presetElement.className = 'preset';

        presetElement.innerHTML = `
        <span class="preset-color-display" style="background-color: ${colors[preset.primaryColor]};"></span>
        <span class="preset-color-display" style="background-color: ${colors[preset.secondaryColor]};"></span>
        <span class="preset-color-display" style="background-color: ${colors[preset.patternColor]};"></span>
        <span class="preset-color-display" style="background-color: ${colors[preset.eyeColor]};"></span>
        <input type="text" value="${preset.name}" onchange="updatePresetName(${index}, this.value)" />
        <button class="px-4 py-2 bg-highlight-green/20 hover:bg-highlight-green/30 text-highlight-green rounded-md transition text-base" onclick="applyPreset(${index})"><i class="fas fa-paint-brush mr-2"></i> Apply</button>
        <button class="px-4 py-2 bg-error-red/20 hover:bg-error-red/30 text-error-red rounded-md transition text-base" onclick="deletePreset(${index})"><i class="fas fa-trash mr-2"></i> Delete</button>
        `;

        presetContainer.appendChild(presetElement);
    });
}
function updatePresetName(index, newName) {
    presets[index].name = newName;
    // Optionally, re-render or save immediately if needed
}
async function applyPreset(index) {
    if (!colorsDispatch) {
        if (IS_DEV) console.error('[Colors] Dispatch not ready for applyPreset');
        colorsDispatch.showToast('Colors: Dispatch not ready.', 'error');
        return;
    }
    const preset = presets[index];
    const colorPacket = await getColorPacket(preset.primaryColor, preset.secondaryColor, preset.patternColor, preset.eyeColor);
    if (colorPacket) {
        colorsDispatch.sendRemoteMessage(colorPacket);
        // Update the main color selectors to reflect the applied preset
        document.getElementById('primaryBodyColor').value = preset.primaryColor;
        document.getElementById('primaryBodyColorDisplay').style.backgroundColor = colors[preset.primaryColor];
        document.getElementById('secondaryBodyColor').value = preset.secondaryColor;
        document.getElementById('secondaryBodyColorDisplay').style.backgroundColor = colors[preset.secondaryColor];
        document.getElementById('patternColor').value = preset.patternColor;
        document.getElementById('patternColorDisplay').style.backgroundColor = colors[preset.patternColor];
        document.getElementById('eyeColor').value = preset.eyeColor;
        document.getElementById('eyeColorDisplay').style.backgroundColor = colors[preset.eyeColor];
        // Show alert after applying preset
        alert('Preset colors sent! Relog or switch animals to see the changes.');
    }
}
function deletePreset(index) {
    presets.splice(index, 1);
    renderPresets(); // Re-render the list
}
function savePresets() {
    const json = JSON.stringify(presets, null, 2); // Pretty print JSON
    const blob = new Blob([json], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'color_presets.json'; // More descriptive filename
    document.body.appendChild(a); // Required for Firefox
    a.click();
    document.body.removeChild(a); // Clean up
    URL.revokeObjectURL(url);
}
function loadPresets() {
    const fileInput = document.getElementById('fileInput');
    fileInput.value = null; // Reset file input to allow loading the same file again
    fileInput.click();

    fileInput.onchange = function(event) {
        const file = event.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function(e) {
            const content = e.target.result;
            try {
                const loadedPresets = JSON.parse(content);
                if (Array.isArray(loadedPresets)) {
                    // Basic validation for preset structure (optional but recommended)
                    const isValid = loadedPresets.every(p =>
                        typeof p.primaryColor === 'number' &&
                        typeof p.secondaryColor === 'number' &&
                        typeof p.patternColor === 'number' &&
                        typeof p.eyeColor === 'number' &&
                        typeof p.name === 'string'
                    );
                    if (isValid) {
                        presets = loadedPresets;
                        renderPresets();
                        alert('Presets loaded successfully!');
                    } else {
                        alert('Invalid preset structure in the file.');
                    }
                } else {
                    alert('Invalid file format. Please load a valid JSON array of presets.');
                }
            } catch (error) {
                alert('Error reading or parsing file: ' + error.message);
            }
        };
        reader.onerror = function() {
            alert('Error reading file.');
        };
        reader.readAsText(file);
    };
}

// --- Initialization ---
function waitForDispatch(callback) {
  if (window.jam && window.jam.dispatch) {
    callback(window.jam.dispatch);
  } else {
    if (IS_DEV) console.log('[Colors] Waiting for dispatch...');
    setTimeout(() => waitForDispatch(callback), 100); // Check every 100ms
  }
}

waitForDispatch(function(dispatchInstance) {
  if (IS_DEV) console.log('[Colors] Dispatch is ready.');
  colorsDispatch = dispatchInstance; // Store dispatch globally

  // Initial setup calls
  renderPresets(); // Render any saved presets on load

  // Add global event listener for modal closing if needed
  window.onclick = function(event) {
      if (event.target === document.getElementById('modal')) {
          closeModal();
      }
  }
});

// Note: Functions are now defined globally and can be called by onclick handlers.
// The waitForDispatch ensures colorsDispatch is set before functions needing it are called by user interaction.

// Set up the minimize button functionality
document.addEventListener('DOMContentLoaded', function() {
  const minimizeBtn = document.getElementById('minimize-btn');
  if (minimizeBtn) {
    minimizeBtn.addEventListener('click', () => {
      if (window.jam && window.jam.application) {
        window.jam.application.minimize();
      } else {
        // Fallback if jam.application is not available
        try {
          const { ipcRenderer } = require('electron');
          ipcRenderer.send('window-minimize');
        } catch (e) {
          console.error("[Colors] Error minimizing window:", e);
        }
      }
    });
  }
});

// Initialize minimize/maximize functionality when the document is fully loaded
document.addEventListener('DOMContentLoaded', function() {
  // This will be handled by the plugin-utils.js initializePluginUI function
  // Any plugin-specific initialization code can be added here
  
  console.log('[Color Changer] Plugin initialized');
});
