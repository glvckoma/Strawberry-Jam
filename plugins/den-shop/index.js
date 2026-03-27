const { dispatch } = jam
const path = require('path')

let denData = { d: {}, m: {} }
try {
  denData = require(path.join(__dirname, 'dens.json'))
} catch (_) {}

const denSelect = document.getElementById('denSelect')
const slotInput = document.getElementById('slotInput')
const buyBtn = document.getElementById('buyBtn')
const statusMsg = document.getElementById('statusMsg')

let availableDiamondIds = null
let builtEntries = []

function setStatus (msg, isError) {
  statusMsg.textContent = msg
  statusMsg.className = isError ? 'status-err' : 'status-ok'
}

function getDenInfo (denId) {
  return denData.d[String(denId)] || null
}

function buildDropdown () {
  denSelect.innerHTML = ''
  builtEntries = []

  const gemGroup = document.createElement('optgroup')
  gemGroup.label = 'Gem Dens'
  const diamondGroup = document.createElement('optgroup')
  diamondGroup.label = 'Diamond Dens'

  const denIds = Object.keys(denData.d).map(Number).sort((a, b) => a - b)
  const addedGem = new Set()

  for (const denId of denIds) {
    const info = denData.d[String(denId)]
    if (info.s === 5) continue
    if (info.c >= 10000) continue

    addedGem.add(denId)
    const idx = builtEntries.length
    builtEntries.push({ denId, type: 'gem', defId: denId, cost: info.c })
    const opt = document.createElement('option')
    opt.value = idx
    const prefix = info.m ? '(Members) ' : ''
    opt.textContent = prefix + info.n + ' - ' + info.c.toLocaleString() + ' Gems'
    gemGroup.appendChild(opt)
  }

  if (availableDiamondIds) {
    const seen = new Set()
    for (const diamId of availableDiamondIds) {
      const mapping = denData.m[String(diamId)]
      if (!mapping) continue
      const [denId, cost] = mapping
      const info = getDenInfo(denId)
      if (!info || info.s === 5) continue
      const key = denId + ':' + cost
      if (seen.has(key)) continue
      seen.add(key)

      const idx = builtEntries.length
      builtEntries.push({ denId, type: 'diamond', defId: parseInt(diamId), cost })
      const opt = document.createElement('option')
      opt.value = idx
      const prefix = info.m ? '(Members) ' : ''
      opt.textContent = prefix + info.n + ' - ' + cost + ' Diamonds'
      diamondGroup.appendChild(opt)
    }
  }

  if (gemGroup.children.length > 0) denSelect.appendChild(gemGroup)
  if (diamondGroup.children.length > 0) denSelect.appendChild(diamondGroup)

  if (diamondGroup.children.length === 0 && availableDiamondIds === null) {
    const loading = document.createElement('optgroup')
    loading.label = 'Diamond dens loading...'
    denSelect.appendChild(loading)
  }
}

async function getRoomId () {
  const internalId = await dispatch.getState('internalRoomId')
  if (internalId !== null && internalId !== undefined) {
    const parsed = parseInt(internalId, 10)
    if (!isNaN(parsed)) return parsed
  }
  return await dispatch.getState('room')
}

let pendingPurchase = null

if (jam.onPacket) {
  jam.onPacket(({ raw, direction }) => {
    if (!raw) return

    if (direction === 'in' && raw.includes('%gl%')) {
      const parts = raw.split('%').filter(Boolean)
      if (parts[1] !== 'gl') return
      const listId = parseInt(parts[3], 10)
      if (listId !== 214) return
      const count = parseInt(parts[9], 10)
      if (isNaN(count) || count <= 0) return
      availableDiamondIds = []
      for (let i = 0; i < count; i++) {
        const id = parts[10 + i]
        if (id) availableDiamondIds.push(id)
      }
      buildDropdown()
      setStatus('Diamond shop loaded (' + availableDiamondIds.length + ' available)', false)
    }

    if (direction === 'in' && raw.includes('%db%')) {
      const parts = raw.split('%').filter(Boolean)
      if (parts[1] !== 'db') return
      const status = parseInt(parts[3], 10)
      const balance = parts[4]

      if (status === 1) {
        pendingPurchase = null
        setStatus('Purchase successful! Balance: ' + balance, false)
        buyBtn.disabled = false
        return
      }

      pendingPurchase = null
      setStatus('Purchase failed. Ensure the slot # is correct otherwise you don\'t have enough gems/diamonds or membership required.', true)
      buyBtn.disabled = false
    }
  })
}

buildDropdown()

async function requestDiamondShop () {
  const roomId = await getRoomId()
  const target = roomId || '-1'
  dispatch.sendRemoteMessage('%xt%o%gl%' + target + '%214%')
}

requestDiamondShop()

buyBtn.addEventListener('click', async () => {
  const idx = parseInt(denSelect.value, 10)
  const entry = builtEntries[idx]
  const slot = parseInt(slotInput.value, 10)

  if (!entry) {
    setStatus('Select a den.', true)
    return
  }

  if (!slot || slot < 1) {
    setStatus('Enter a valid slot number.', true)
    return
  }

  const roomId = await getRoomId()
  if (!roomId) {
    setStatus('Not currently in a room.', true)
    return
  }

  const info = getDenInfo(entry.denId)
  const denName = info ? info.n : 'Den'
  const currency = entry.type === 'diamond' ? 1 : 0
  const unit = currency === 1 ? 'Diamonds' : 'Gems'

  buyBtn.disabled = true
  pendingPurchase = true
  const packet = `%xt%o%db%${roomId}%-1%384%${entry.defId}%${slot}%${currency}%`
  dispatch.sendRemoteMessage(packet)
  setStatus('Trying ' + denName + ' with ' + unit + '...', false)
})
