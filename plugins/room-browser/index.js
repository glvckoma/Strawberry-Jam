const { dispatch } = jam
const path = require('path')

let ROOMS = []
try {
  ROOMS = require(path.join(__dirname, 'rooms.json'))
} catch (_) {}

const UNJOINABLE_PREFIXES = [
  'pachinkoassets/', 'memoryassets/', 'moatmadnessassets/', 'parachuteassets/',
  'triviaassets/', 'riverraceassets/', 'shootinggalleryassets/', 'skeeballassets/',
  'smoothieassets/', 'stackerassets/', 'twisterassets/', 'windriderassets/',
  'phantomfighterassets/', 'phantomstreasure/', 'fortsmasherassets/',
  'gembreakerassets/', 'feedingfrenzyassets/', 'popcornassets/', 'craneassets/',
  'eagleflapassets/', 'glideassets/', 'offthehookassets/', 'hedgehogassets/',
  'spidershooterassets/', 'pacmanassets/', 'towerdefense/',
  'truefalseassets/', 'astronomyassets/', 'geographyassets/', 'safetyquizassets/',
  'pvp_', 'micro', 'artstudio', 'artprintplayportrait/',
  'candycatcher/', 'cottoncandy/', 'distancechallenge/', 'dolphinrace/',
  'dunkaphantom/', 'fallingphantoms/', 'fashionshow/', 'fastfoodies/',
  'frogflyer/', 'horserace/', 'pillbugs/', 'pinball/', 'recyclesort/',
  'spoton/', 'supersort/', 'touchpoolassets/', 'whackphantom/',
  'prototypehorserace/', 'bradychemistryset/', 'bradyexpeditionsassets/',
  'activitygeography/', 'questparachuteassets/', 'coralpets/',
  'world_map/', 'first_five/', 'reuseplayer_den/',
  'player_den/', 'epic_dens/', 'adventures/'
]

function isJoinable (roomPath) {
  const lower = roomPath.toLowerCase()
  return !UNJOINABLE_PREFIXES.some(p => lower.indexOf(p) === 0)
}

const searchInput = document.getElementById('searchInput')
const joinableList = document.getElementById('joinableList')
const unjoinableList = document.getElementById('unjoinableList')
const joinableCount = document.getElementById('joinableCount')
const unjoinableCount = document.getElementById('unjoinableCount')
const joinBtn = document.getElementById('joinBtn')
const statusMsg = document.getElementById('statusMsg')

let selectedRoom = null

function setStatus (msg, isError) {
  statusMsg.textContent = msg
  statusMsg.className = isError ? 'status-err' : 'status-ok'
}

async function getRoomId () {
  const internalId = await dispatch.getState('internalRoomId')
  if (internalId !== null && internalId !== undefined) {
    const parsed = parseInt(internalId, 10)
    if (!isNaN(parsed)) return parsed
  }
  return await dispatch.getState('room')
}

function filterRooms () {
  const search = searchInput.value.toLowerCase().trim()
  return ROOMS.filter(r => {
    if (search && r[1].toLowerCase().indexOf(search) === -1 && r[4].toLowerCase().indexOf(search) === -1 && String(r[0]).indexOf(search) === -1) return false
    return true
  })
}

function createRoomItem (r) {
  const item = document.createElement('div')
  item.className = 'rb-room-item'

  const left = document.createElement('div')
  left.style.overflow = 'hidden'
  left.style.minWidth = '0'

  const name = document.createElement('div')
  name.textContent = r[4]
  name.style.whiteSpace = 'nowrap'
  name.style.overflow = 'hidden'
  name.style.textOverflow = 'ellipsis'
  left.appendChild(name)

  const pathEl = document.createElement('div')
  pathEl.className = 'rb-room-path'
  pathEl.textContent = r[1]
  left.appendChild(pathEl)

  const tags = document.createElement('div')
  tags.className = 'rb-room-tags'
  if (r[2] === 1) {
    const tag = document.createElement('span')
    tag.className = 'rb-tag rb-tag-ocean'
    tag.textContent = 'Ocean'
    tags.appendChild(tag)
  }
  if (r[3] === 1) {
    const tag = document.createElement('span')
    tag.className = 'rb-tag rb-tag-plat'
    tag.textContent = 'Platformer'
    tags.appendChild(tag)
  }

  item.appendChild(left)
  item.appendChild(tags)

  item.addEventListener('click', () => {
    joinableList.querySelectorAll('.rb-room-item.selected').forEach(el => el.classList.remove('selected'))
    unjoinableList.querySelectorAll('.rb-room-item.selected').forEach(el => el.classList.remove('selected'))
    item.classList.add('selected')
    selectedRoom = r
    joinBtn.disabled = false
  })

  return item
}

function renderRooms () {
  const filtered = filterRooms()
  joinableList.innerHTML = ''
  unjoinableList.innerHTML = ''
  selectedRoom = null
  joinBtn.disabled = true

  let jCount = 0
  let uCount = 0

  filtered.forEach(r => {
    const item = createRoomItem(r)
    if (isJoinable(r[1])) {
      joinableList.appendChild(item)
      jCount++
    } else {
      unjoinableList.appendChild(item)
      uCount++
    }
  })

  joinableCount.textContent = jCount + ' rooms'
  unjoinableCount.textContent = uCount + ' rooms'
}

searchInput.addEventListener('input', renderRooms)

renderRooms()

joinBtn.addEventListener('click', async () => {
  if (!selectedRoom) {
    setStatus('Select a room.', true)
    return
  }

  const roomId = await getRoomId()
  if (!roomId) {
    setStatus('Not currently in a room.', true)
    return
  }

  const roomPath = selectedRoom[1].replace(/\//g, '.')

  joinBtn.disabled = true
  const packet = `%xt%o%rj%${roomId}%${roomPath}#1%1%0%0%`
  setStatus('Joining ' + selectedRoom[4] + '...', false)
  dispatch.sendRemoteMessage(packet)

  setTimeout(() => { joinBtn.disabled = false }, 2000)
})
