const { dispatch } = jam

const colorPicker = document.getElementById('colorPicker')
const colorHex = document.getElementById('colorHex')
const preview = document.getElementById('preview')
const colorModeSelect = document.getElementById('colorMode')
const renderModeSelect = document.getElementById('renderMode')
const speedSlider = document.getElementById('speed')
const speedLabel = document.getElementById('speedLabel')
const toggleBtn = document.getElementById('toggleBtn')
const statusText = document.getElementById('status')
const targetAccount = document.getElementById('targetAccount')

let interval = null
let active = false
let hue = 0
let pulsePhase = 0

async function updateAccountDropdown() {
  try {
    let clients = []
    if (dispatch && typeof dispatch.getConnectedClients === 'function') {
      const result = dispatch.getConnectedClients()
      clients = result && typeof result.then === 'function' ? await result : result
    }
    if (!Array.isArray(clients)) clients = []

    const currentValue = targetAccount.value
    const existingValues = new Set()
    for (let i = targetAccount.options.length - 1; i >= 1; i--) {
      targetAccount.remove(i)
    }
    clients.forEach(client => {
      if (client && client.username && !existingValues.has(client.username)) {
        existingValues.add(client.username)
        const opt = document.createElement('option')
        opt.value = client.username
        opt.textContent = client.username
        targetAccount.appendChild(opt)
      }
    })
    if (currentValue) {
      const stillExists = Array.from(targetAccount.options).some(o => o.value === currentValue)
      targetAccount.value = stillExists ? currentValue : ''
    }
  } catch (_) {}
}

updateAccountDropdown()
setInterval(updateAccountDropdown, 5000)

function rgbToFull(r, g, b) {
  return ((0xFF << 24) | (r << 16) | (g << 8) | b) >>> 0
}

function rgbToOutline(r, g, b) {
  return ((r << 16) | (g << 8) | b) >>> 0
}

function hexToRgb(hex) {
  return [
    parseInt(hex.slice(1, 3), 16),
    parseInt(hex.slice(3, 5), 16),
    parseInt(hex.slice(5, 7), 16)
  ]
}

function hslToRgb(h, s, l) {
  const c = (1 - Math.abs(2 * l - 1)) * s
  const x = c * (1 - Math.abs((h / 60) % 2 - 1))
  const m = l - c / 2
  let r = 0, g = 0, b = 0
  if (h < 60) { r = c; g = x }
  else if (h < 120) { r = x; g = c }
  else if (h < 180) { g = c; b = x }
  else if (h < 240) { g = x; b = c }
  else if (h < 300) { r = x; b = c }
  else { r = c; b = x }
  return [Math.round((r + m) * 255), Math.round((g + m) * 255), Math.round((b + m) * 255)]
}

function toGameColor(r, g, b) {
  return renderModeSelect.value === 'outline' ? rgbToOutline(r, g, b) : rgbToFull(r, g, b)
}

function gameColorToHex(gc) {
  const r = (gc >>> 16) & 0xFF
  const g = (gc >>> 8) & 0xFF
  const b = gc & 0xFF
  return '#' + [r, g, b].map(v => v.toString(16).padStart(2, '0')).join('')
}

function updatePreview(hex) {
  preview.style.backgroundColor = hex
  preview.style.setProperty('--preview-color', hex)
  if (active) preview.classList.add('active')
}

async function getRoomId() {
  const internalId = await dispatch.getState('internalRoomId')
  if (internalId !== null && internalId !== undefined) {
    const parsed = parseInt(internalId, 10)
    if (!isNaN(parsed)) return parsed
  }
  return await dispatch.getState('room')
}

async function sendColor(gameColor) {
  const roomId = await getRoomId()
  if (!roomId) return
  const msg = `<msg t="sys"><body action="pubMsg" r="${roomId}"><txt><![CDATA[${gameColor}%8]]></txt></body></msg>`
  const options = {}
  const selected = targetAccount.value
  if (selected) options.targetUsername = selected
  dispatch.sendRemoteMessage(msg, options)
}

function getNextColor() {
  const colorMode = colorModeSelect.value

  if (colorMode === 'solid') {
    const [r, g, b] = hexToRgb(colorPicker.value)
    return toGameColor(r, g, b)
  }

  if (colorMode === 'rainbow') {
    hue = (hue + 5) % 360
    const [r, g, b] = hslToRgb(hue, 1, 0.5)
    return toGameColor(r, g, b)
  }

  if (colorMode === 'pulse') {
    pulsePhase = (pulsePhase + 0.1) % (Math.PI * 2)
    const brightness = 0.3 + 0.4 * ((Math.sin(pulsePhase) + 1) / 2)
    const [br, bg, bb] = hexToRgb(colorPicker.value)
    const r = Math.round((br / 255) * brightness * 255)
    const g = Math.round((bg / 255) * brightness * 255)
    const b = Math.round((bb / 255) * brightness * 255)
    return toGameColor(r, g, b)
  }

  const [r, g, b] = hexToRgb(colorPicker.value)
  return toGameColor(r, g, b)
}

function tick() {
  const gc = getNextColor()
  sendColor(gc)
  updatePreview(gameColorToHex(gc))
}

function start() {
  if (active) return
  active = true
  hue = 0
  pulsePhase = 0
  toggleBtn.className = 'glow-btn glow-btn-stop'
  toggleBtn.innerHTML = '<i class="fas fa-stop mr-1"></i> Stop Glow'
  statusText.textContent = 'Glow active'
  preview.style.display = 'block'
  preview.classList.add('active')
  tick()
  interval = setInterval(tick, parseInt(speedSlider.value))
}

function stop() {
  if (!active) return
  active = false
  if (interval) {
    clearInterval(interval)
    interval = null
  }
  sendColor(0)
  toggleBtn.className = 'glow-btn glow-btn-start'
  toggleBtn.innerHTML = '<i class="fas fa-play mr-1"></i> Start Glow'
  statusText.textContent = 'Stopped'
  preview.classList.remove('active')
  preview.style.display = 'none'
}

colorPicker.addEventListener('input', function () {
  colorHex.value = this.value
  updatePreview(this.value)
})

colorHex.addEventListener('input', function () {
  const val = this.value
  if (/^#[0-9a-fA-F]{6}$/.test(val)) {
    colorPicker.value = val
    updatePreview(val)
  }
})

colorHex.addEventListener('blur', function () {
  if (!/^#[0-9a-fA-F]{6}$/.test(this.value)) {
    this.value = colorPicker.value
  }
})

speedSlider.addEventListener('input', function () {
  speedLabel.textContent = this.value + 'ms'
  if (active) {
    clearInterval(interval)
    interval = setInterval(tick, parseInt(this.value))
  }
})

toggleBtn.addEventListener('click', function () {
  if (active) stop()
  else start()
})
