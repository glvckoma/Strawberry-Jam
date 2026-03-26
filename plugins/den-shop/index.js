const { dispatch } = jam

const DENS = [
  { name: "Arcade",                  member: true,  gem: { defId: 19, cost: 5 },      diamond: { defId: 49, cost: 3 } },
  { name: "Art Gallery",             member: true,  gem: null,                         diamond: { defId: 263, cost: 7 } },
  { name: "Autumn Small House",      member: false, gem: { defId: 40, cost: 2000 },   diamond: { defId: 285, cost: 10 } },
  { name: "Beach House",             member: true,  gem: null,                         diamond: { defId: 68, cost: 3 } },
  { name: "Beta Den",                member: false, gem: { defId: 56, cost: 5000 },   diamond: { defId: 250, cost: 3 } },
  { name: "Boreal Cottage",          member: true,  gem: null,                         diamond: { defId: 272, cost: 3 } },
  { name: "Bounce House",            member: true,  gem: { defId: 25, cost: 7500 },   diamond: { defId: 69, cost: 3 } },
  { name: "Castle",                  member: true,  gem: { defId: 4, cost: 6000 },    diamond: { defId: 732, cost: 10 } },
  { name: "Cosmo's Den",             member: true,  gem: { defId: 18, cost: 7500 },   diamond: { defId: 4, cost: 3 } },
  { name: "Cosmo's Tree House",      member: true,  gem: null,                         diamond: { defId: 147, cost: 3 } },
  { name: "Crystal Palace",          member: true,  gem: null,                         diamond: { defId: 216, cost: 3 } },
  { name: "Enchanted Hollow",        member: true,  gem: { defId: 16, cost: 7000 },   diamond: { defId: 5, cost: 3 } },
  { name: "Epic Beta Den",           member: true,  gem: null,                         diamond: { defId: 254, cost: 3 } },
  { name: "Epic Haunted Manor",      member: true,  gem: null,                         diamond: { defId: 79, cost: 3 } },
  { name: "Fantasy Castle",          member: true,  gem: { defId: 15, cost: 7500 },   diamond: null },
  { name: "Friendship Cottage",      member: true,  gem: null,                         diamond: { defId: 1, cost: 10 } },
  { name: "Friendship Fortress",     member: true,  gem: null,                         diamond: { defId: 933, cost: 7 } },
  { name: "Garden Treehouse",        member: true,  gem: null,                         diamond: { defId: 2621, cost: 7 } },
  { name: "Gingerbread House",       member: false, gem: { defId: 11, cost: 5000 },   diamond: { defId: 36, cost: 5 } },
  { name: "Graham's Observatory",    member: true,  gem: null,                         diamond: { defId: 146, cost: 3 } },
  { name: "Greely's Haunted Hideout",member: true,  gem: null,                         diamond: { defId: 842, cost: 7 } },
  { name: "Greely's Hideout",        member: true,  gem: null,                         diamond: { defId: 116, cost: 7 } },
  { name: "Haunted Mansion",         member: false, gem: { defId: 10, cost: 6500 },   diamond: { defId: 86, cost: 10 } },
  { name: "Icy Snow Fort",           member: true,  gem: null,                         diamond: { defId: 207, cost: 3 } },
  { name: "Igloo Estate",            member: true,  gem: null,                         diamond: { defId: 931, cost: 7 } },
  { name: "Jamaaliday House",        member: true,  gem: null,                         diamond: { defId: 161, cost: 5 } },
  { name: "Jolly Gingerbread Lodge", member: true,  gem: null,                         diamond: { defId: 2145, cost: 7 } },
  { name: "Liza's Garden",           member: true,  gem: null,                         diamond: { defId: 346, cost: 7 } },
  { name: "Lost Ruins",              member: true,  gem: { defId: 14, cost: 3500 },   diamond: { defId: 70, cost: 3 } },
  { name: "Lucky Castle",            member: true,  gem: null,                         diamond: { defId: 100, cost: 3 } },
  { name: "Lucky Small House",       member: false, gem: null,                         diamond: { defId: 219, cost: 3 } },
  { name: "Mushroom Hut",            member: true,  gem: { defId: 17, cost: 5000 },   diamond: { defId: 31, cost: 3 } },
  { name: "Ol' Barn",                member: true,  gem: { defId: 12, cost: 5000 },   diamond: { defId: 113, cost: 10 } },
  { name: "Peck's Den",              member: true,  gem: null,                         diamond: { defId: 111, cost: 3 } },
  { name: "Pixel Place",             member: true,  gem: null,                         diamond: { defId: 112, cost: 3 } },
  { name: "Princess Castle",         member: true,  gem: { defId: 3, cost: 6000 },    diamond: { defId: 610, cost: 10 } },
  { name: "Regal Winter Palace",     member: true,  gem: null,                         diamond: { defId: 879, cost: 7 } },
  { name: "Restaurant",              member: true,  gem: { defId: 6, cost: 4000 },    diamond: { defId: 841, cost: 10 } },
  { name: "Sandcastle",              member: true,  gem: null,                         diamond: { defId: 145, cost: 3 } },
  { name: "Schoolhouse",             member: true,  gem: null,                         diamond: { defId: 2834, cost: 7 } },
  { name: "Sir Gilbert's Palace",    member: true,  gem: null,                         diamond: { defId: 171, cost: 10 } },
  { name: "Sky Kingdom",             member: true,  gem: null,                         diamond: { defId: 101, cost: 7 } },
  { name: "Small House",             member: false, gem: { defId: 1, cost: 2000 },    diamond: null },
  { name: "Snow Fort",               member: true,  gem: { defId: 13, cost: 5000 },   diamond: null },
  { name: "Sol Arcade Den",          member: true,  gem: { defId: 20, cost: 7500 },   diamond: { defId: 56, cost: 3 } },
  { name: "Spooky Castle",           member: true,  gem: null,                         diamond: { defId: 195, cost: 3 } },
  { name: "Spring Cottage",          member: true,  gem: null,                         diamond: { defId: 103, cost: 3 } },
  { name: "Spring Small House",      member: false, gem: { defId: 46, cost: 2000 },   diamond: { defId: 635, cost: 10 } },
  { name: "Sunken Ship",             member: false, gem: { defId: 8, cost: 2500 },    diamond: { defId: 889, cost: 10 } },
  { name: "Tree House",              member: true,  gem: { defId: 2, cost: 4000 },    diamond: { defId: 55, cost: 10 } },
  { name: "Trendy Restaurant",       member: true,  gem: null,                         diamond: { defId: 234, cost: 3 } },
  { name: "Volcano",                 member: true,  gem: { defId: 5, cost: 3000 },    diamond: { defId: 835, cost: 10 } },
  { name: "Warm Sands Sanctuary",    member: true,  gem: null,                         diamond: { defId: 954, cost: 10 } },
  { name: "Water Park",              member: true,  gem: { defId: 7, cost: 4000 },    diamond: null },
  { name: "Winter Castle",           member: true,  gem: null,                         diamond: { defId: 2588, cost: 7 } },
  { name: "Winter Palace",           member: true,  gem: null,                         diamond: { defId: 83, cost: 3 } },
  { name: "Winter Small House",      member: false, gem: { defId: 44, cost: 2000 },   diamond: { defId: 168, cost: 3 } }
]

const denSelect = document.getElementById('denSelect')
const slotInput = document.getElementById('slotInput')
const buyBtn = document.getElementById('buyBtn')
const statusMsg = document.getElementById('statusMsg')

DENS.forEach((den, idx) => {
  const opt = document.createElement('option')
  opt.value = idx
  const prefix = den.member ? '(Members) ' : ''
  const costs = []
  if (den.gem) costs.push(den.gem.cost.toLocaleString() + ' Gems')
  if (den.diamond) costs.push(den.diamond.cost + ' Diamonds')
  opt.textContent = `${prefix}${den.name} - ${costs.join(' / ')}`
  denSelect.appendChild(opt)
})

function setStatus(msg, isError) {
  statusMsg.textContent = msg
  statusMsg.className = isError ? 'status-err' : 'status-ok'
}

async function getRoomId() {
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
    if (direction !== 'in' || !raw || !raw.includes('%db%')) return
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

    if (pendingPurchase && pendingPurchase.fallback) {
      const fb = pendingPurchase.fallback
      pendingPurchase = null
      tryPurchase(fb.defId, fb.currency, fb.slot, fb.roomId, fb.den, null)
      return
    }

    pendingPurchase = null
    setStatus('Purchase failed (code ' + status + '). Balance: ' + balance, true)
    buyBtn.disabled = false
  })
}

function tryPurchase(defId, currency, slot, roomId, den, fallback) {
  pendingPurchase = { fallback }
  const packet = `%xt%o%db%${roomId}%-1%384%${defId}%${slot}%${currency}%`
  dispatch.sendRemoteMessage(packet)
  const unit = currency === 1 ? 'Diamonds' : 'Gems'
  setStatus(`Trying ${den.name} with ${unit}...`, false)
}

buyBtn.addEventListener('click', async () => {
  const idx = parseInt(denSelect.value, 10)
  const den = DENS[idx]
  const slot = parseInt(slotInput.value, 10)

  if (!den) {
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

  buyBtn.disabled = true

  if (den.gem) {
    const fallback = den.diamond
      ? { defId: den.diamond.defId, currency: 1, slot, roomId, den }
      : null
    tryPurchase(den.gem.defId, 0, slot, roomId, den, fallback)
  } else if (den.diamond) {
    tryPurchase(den.diamond.defId, 1, slot, roomId, den, null)
  }
})
