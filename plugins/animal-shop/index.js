const { dispatch } = jam
const path = require('path')

const BASE_ANIMALS = [
  { id: 1,  name: 'Tiger',             member: false },
  { id: 2,  name: 'Eagle',             member: true },
  { id: 3,  name: 'Deer',              member: true },
  { id: 4,  name: 'Wolf',              member: false },
  { id: 5,  name: 'Koala',             member: false },
  { id: 6,  name: 'Panda',             member: false },
  { id: 7,  name: 'Monkey',            member: false },
  { id: 8,  name: 'Bunny',             member: false },
  { id: 9,  name: 'Hyena',             member: true },
  { id: 10, name: 'Otter',             member: true },
  { id: 11, name: 'Polar Bear',        member: true },
  { id: 12, name: 'Owl',               member: true },
  { id: 13, name: 'Rhino',             member: false },
  { id: 14, name: 'Llama',             member: true },
  { id: 15, name: 'Crocodile',         member: true },
  { id: 16, name: 'Elephant',          member: true },
  { id: 17, name: 'Lion',              member: true },
  { id: 18, name: 'Seal',              member: false },
  { id: 19, name: 'Dolphin',           member: true },
  { id: 20, name: 'Shark',             member: true },
  { id: 21, name: 'Octopus',           member: true },
  { id: 22, name: 'Sea Turtle',        member: false },
  { id: 23, name: 'Horse',             member: true },
  { id: 24, name: 'Penguin',           member: false },
  { id: 25, name: 'Fox',               member: true },
  { id: 26, name: 'Giraffe',           member: false },
  { id: 27, name: 'Kangaroo',          member: true },
  { id: 28, name: 'Arctic Wolf',       member: true },
  { id: 29, name: 'Snow Leopard',      member: true },
  { id: 30, name: 'Raccoon',           member: true },
  { id: 31, name: 'Cheetah',           member: true },
  { id: 32, name: 'Lynx',              member: true },
  { id: 33, name: 'Arctic Fox',        member: true },
  { id: 34, name: 'Goat',              member: true },
  { id: 35, name: 'Falcon',            member: true },
  { id: 36, name: 'Pig',               member: false },
  { id: 37, name: 'Sloth',             member: true },
  { id: 38, name: 'Lemur',             member: true },
  { id: 39, name: 'Toucan',            member: true },
  { id: 40, name: 'Sheep',             member: true },
  { id: 41, name: 'Cougar',            member: true },
  { id: 42, name: 'Coyote',            member: true },
  { id: 43, name: 'Flamingo',          member: true },
  { id: 44, name: 'Red Panda',         member: true },
  { id: 45, name: 'Clydesdale Horse',  member: true },
  { id: 46, name: 'Sabertooth',        member: true },
  { id: 47, name: 'Direwolf',          member: true },
  { id: 48, name: 'Skunk',             member: true },
  { id: 49, name: 'Great Horned Owl',  member: true },
  { id: 50, name: 'Fennec Fox',        member: true },
  { id: 51, name: 'Camel',             member: true },
  { id: 52, name: 'Arabian Horse',     member: true },
  { id: 53, name: 'Moose',             member: true }
]

const CUSTOM_ANIMALS = [
  { id: 1,  name: 'Spring Bunny',           avatarRef: 8,  member: false },
  { id: 2,  name: 'Snowflake Arctic Wolf',  avatarRef: 28, member: true },
  { id: 3,  name: 'Polar Arctic Fox',       avatarRef: 33, member: true },
  { id: 4,  name: 'Enchanted Eagle',        avatarRef: 2,  member: true },
  { id: 5,  name: 'Autumn Coyote',          avatarRef: 42, member: true },
  { id: 6,  name: 'Spooky Snow Leopard',    avatarRef: 29, member: true },
  { id: 7,  name: 'Jamaaliday Deer',        avatarRef: 3,  member: true },
  { id: 8,  name: 'Legendary Eagle',        avatarRef: 2,  member: true },
  { id: 9,  name: 'Fearsome Falcon',        avatarRef: 35, member: true },
  { id: 10, name: 'Royal Red Panda',        avatarRef: 44, member: true },
  { id: 11, name: 'Frolicking Fox',         avatarRef: 25, member: true },
  { id: 12, name: 'Rainbow Raccoon',        avatarRef: 30, member: true }
]

const HARDCODED_NAMES = {
  200: ['27093','27092','27091','27090','27089','27088','27087','27086','27085','27084','27083','27082','27081','27080','27079','27078','27077','27076','27075','27074','27073','27072','27071','27070','27069','27068','27067','27066','27065','27064','27063','27062','27061','27060','27059','27058','27057','27056','27055','27054','27053','27052','27051','27050','27049','27048','27046','27045','27044','27043','27042','27041','27040','27039','27038','27037','27036','27035','27034','15136','15137','15138','15139','15140','15141','15142','15143','15144','15145','15146','15147','15148','15149','15150','15151','15152','15153','15154','15155','15156','15157','15158','15159','15160','15161','15162','15163','15164','15165','15166','15167','15168','15169','15170','15171','15172','15173','15174','15175','15176','15177','15178','15179','15180','15181','15182','15183','15184','15185','15186','15187','15188','15189','15190','15191','15192','15193','15194','15195','15196','15197','15198','15199','15200','15201','15202','15203','15204','15205','15206','15207','15208','15209','15210','15211','15212','15213','15214','15215','15216','15217','15218','15219','15220','15221','15222','15223'],
  202: ['32697','27140','27139','27138','27137','27136','27135','27134','27133','27132','27131','27130','27129','27128','27127','27126','27125','27124','27123','27122','27121','27120','27119','27118','27117','27116','27115','27114','27113','27112','27111','27110','27109','27108','27107','27106','27105','27104','27103','27102','27101','27100','27099','27098','27097','27096','27095','15224','15225','15226','15227','15228','15229','15230','15231','15232','15234','15235','15236','15237','15238','15239','15240','15241','15242','15243','15244','15245','15246','15247','15248','15249','15251','15252','15253','15254','15255','15256','15257','15258','15259','15260','15261','15262','15263','15264','15265','15266','15267','15268','15269','15270','15271','15272','15273','15274','15275','15276','15277','15278','15279','15280','15281','15282','15283','15284','15285','15286','15287','15288','15289','15290','15291','15292','15293','15294','15295','15296','15297','15298'],
  203: ['32184','32534','29236','30568','29970','29111','28706','28101','27495','27184','27183','27182','27181','27180','27179','27178','27177','27176','27175','27174','27173','27172','27171','27170','27169','27168','27167','27166','27165','27164','27163','27162','27161','27160','27159','27158','27157','27156','27155','27154','27153','27152','27151','27150','27149','27148','27147','27146','27145','27144','27143','27142','27141','25472','25275','24997','24448','23585','22813','22796','21508','18936','15299','15300','15301','15302','15303','15304','15305','15306','15307','15308','15309','15310','15311','15312','15313','15314','15315','15316','15317','15318','15319','15320','15321','15322','15323','15324','15325','15326','15327','15328','15329','15330','15331','15332','15333','15334','15335','15336','15337','15338','15339','15340','15341','15342','15343','15344','15345','15346','15347','15348','15349','15350','15351','15352','15353','15354','15355','15356','15357','15358','15359','15360','15361','15362','15363','15364','15365','15366','15367','15368','15369','15370','15371','15372','15373','15374','15375','15376','15377','15378','15379','15380','15381','15382','15383','15384','15385','15784','18542']
}

const animalSelect = document.getElementById('animalSelect')
const name1Select = document.getElementById('name1')
const name2Select = document.getElementById('name2')
const name3Select = document.getElementById('name3')
const buyBtn = document.getElementById('buyBtn')
const statusMsg = document.getElementById('statusMsg')

let stringLookup = {}
try {
  stringLookup = require(path.join(__dirname, 'names.json'))
} catch (_) {}

const baseGroup = document.createElement('optgroup')
baseGroup.label = 'Base Animals'
BASE_ANIMALS.forEach(animal => {
  const opt = document.createElement('option')
  opt.value = 'base:' + animal.id
  const prefix = animal.member ? '(Members) ' : ''
  opt.textContent = prefix + animal.name
  baseGroup.appendChild(opt)
})
animalSelect.appendChild(baseGroup)

const customGroup = document.createElement('optgroup')
customGroup.label = 'Custom Animals'
CUSTOM_ANIMALS.forEach(animal => {
  const opt = document.createElement('option')
  opt.value = 'custom:' + animal.id
  const prefix = animal.member ? '(Members) ' : ''
  opt.textContent = prefix + animal.name
  customGroup.appendChild(opt)
})
animalSelect.appendChild(customGroup)

function populateNameSelect (selectEl, ids) {
  selectEl.innerHTML = ''
  const entries = ids.map(id => ({ id, label: stringLookup[id] || String(id) }))
  entries.sort((a, b) => a.label.localeCompare(b.label))
  entries.forEach(({ id, label }) => {
    const opt = document.createElement('option')
    opt.value = id
    opt.textContent = label
    selectEl.appendChild(opt)
  })
  selectEl.selectedIndex = Math.floor(Math.random() * entries.length)
}

function buildNameDropdowns (lists) {
  populateNameSelect(name1Select, lists[200])
  populateNameSelect(name2Select, lists[202])
  populateNameSelect(name3Select, lists[203])
}

buildNameDropdowns(HARDCODED_NAMES)

const liveLists = { 200: null, 202: null, 203: null }

function parseGlResponse (raw) {
  const parts = raw.split('%').filter(Boolean)
  if (parts[1] !== 'gl') return
  const listId = parseInt(parts[3], 10)
  if (listId !== 200 && listId !== 202 && listId !== 203) return
  const count = parseInt(parts[9], 10)
  if (isNaN(count) || count <= 0) return
  const ids = []
  for (let i = 0; i < count; i++) {
    const id = parts[10 + i]
    if (id) ids.push(id)
  }
  liveLists[listId] = ids
  if (liveLists[200] && liveLists[202] && liveLists[203]) {
    buildNameDropdowns(liveLists)
  }
}

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

function parseAnimalSelection () {
  const val = animalSelect.value
  if (!val) return null
  const [type, idStr] = val.split(':')
  const id = parseInt(idStr, 10)
  if (type === 'custom') {
    const custom = CUSTOM_ANIMALS.find(a => a.id === id)
    if (!custom) return null
    return { avTypeId: custom.avatarRef, customAvId: custom.id, name: custom.name }
  }
  const base = BASE_ANIMALS.find(a => a.id === id)
  if (!base) return null
  return { avTypeId: base.id, customAvId: -1, name: base.name }
}

let pendingPurchaseRoomId = null

if (jam.onPacket) {
  jam.onPacket(({ raw, direction }) => {
    if (!raw) return

    if (direction === 'in' && raw.includes('%gl%')) {
      parseGlResponse(raw)
    }

    if (direction === 'in' && raw.includes('%aa%')) {
      const parts = raw.split('%').filter(Boolean)
      const aaIdx = parts.indexOf('aa')
      if (aaIdx < 0) return
      const status = parseInt(parts[aaIdx + 2], 10)
      if (status === 1) {
        setStatus('Purchase successful, please relog to see the animal!', false)
      } else {
        setStatus('Purchase failed. Not enough gems or membership required.', true)
      }
      pendingPurchaseRoomId = null
      buyBtn.disabled = false
    }
  })
}

async function requestNameLists () {
  const roomId = await getRoomId()
  if (!roomId) return
  dispatch.sendRemoteMessage(`%xt%o%gl%${roomId}%200%`)
  dispatch.sendRemoteMessage(`%xt%o%gl%${roomId}%202%`)
  dispatch.sendRemoteMessage(`%xt%o%gl%${roomId}%203%`)
}

requestNameLists()

buyBtn.addEventListener('click', async () => {
  const animal = parseAnimalSelection()
  if (!animal) {
    setStatus('Select an animal.', true)
    return
  }

  const n1 = name1Select.value
  const n2 = name2Select.value
  const n3 = name3Select.value
  if (!n1 || !n2 || !n3) {
    setStatus('Select all 3 name words.', true)
    return
  }

  const roomId = await getRoomId()
  if (!roomId) {
    setStatus('Not currently in a room.', true)
    return
  }

  buyBtn.disabled = true
  pendingPurchaseRoomId = roomId
  const packet = `%xt%o%aa%${roomId}%${n1}%${n2}%${n3}%${animal.avTypeId}%${animal.customAvId}%-1%-1%`
  dispatch.sendRemoteMessage(packet)
  setStatus('Purchasing ' + animal.name + '...', false)
})
