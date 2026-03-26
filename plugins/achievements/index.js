const { dispatch } = jam

const G = [
  {v:1,a:[{id:1,n:"1000 Gems!",t:1000},{id:2,n:"10,000 Gems!",t:10000},{id:3,n:"25,000 Gems!",t:25000},{id:4,n:"50,000 Gems!",t:50000},{id:5,n:"100,000 Gems!",t:100000}]},
  {v:2,a:[{id:6,n:"5000 Gems Spent!",t:5000},{id:7,n:"15,000 Gems Spent!",t:15000},{id:8,n:"35,000 Gems Spent!",t:35000},{id:9,n:"65,000 Gems Spent!",t:65000},{id:10,n:"100,000 Gems Spent!",t:100000}]},
  {v:3,a:[{id:11,n:"25th Den Item!",t:25},{id:12,n:"50th Den Item!",t:50},{id:13,n:"100th Den Item!",t:100},{id:14,n:"250th Den Item!",t:250}]},
  {v:4,a:[{id:15,n:"Clothes Shopper 25!",t:25},{id:16,n:"Clothes Shopper 50!",t:50},{id:17,n:"Clothes Shopper 100!",t:100},{id:18,n:"Clothes Shopper 250!",t:250}]},
  {v:5,a:[{id:19,n:"Chatterbox!",t:1}]},
  {v:6,a:[{id:20,n:"Matchmaker!",t:10},{id:21,n:"Matchminor!",t:25},{id:22,n:"Matchmajor!",t:40},{id:23,n:"Matchmaster!",t:60}]},
  {v:7,a:[{id:24,n:"Fast Match!",t:1}]},
  {v:8,a:[{id:25,n:"Flowbie!",t:5},{id:26,n:"Flowbot!",t:15},{id:27,n:"Flowmaster!",t:30},{id:28,n:"Open The Floodgates!",t:50}]},
  {v:9,a:[{id:29,n:"Overflow Boss!",t:50},{id:30,n:"Overflow Master!",t:100}]},
  {v:10,a:[{id:31,n:"Whiz Kid!",t:5},{id:32,n:"Prodigy!",t:10},{id:33,n:"Head Of The Class!",t:25},{id:34,n:"A+!",t:50}]},
  {v:11,a:[{id:35,n:"Trivia Star!",t:1}]},
  {v:12,a:[{id:36,n:"Stratus!",t:10},{id:37,n:"Nimbus!",t:20},{id:38,n:"Cumulus!",t:35},{id:39,n:"Cirrus!",t:50}]},
  {v:13,a:[{id:40,n:"Cloud Commander!",t:1}]},
  {v:14,a:[{id:41,n:"Fighter!",t:5},{id:42,n:"Hunter!",t:10},{id:43,n:"Exterminator!",t:25},{id:44,n:"Eradicator!",t:50}]},
  {v:15,a:[{id:45,n:"Phantom Warrior!",t:11}]},
  {v:16,a:[{id:46,n:"Play Ball!",t:10},{id:47,n:"On The Ball!",t:20},{id:48,n:"Having A Ball!",t:35},{id:49,n:"Great Balls Of Fire!",t:50}]},
  {v:17,a:[{id:50,n:"Jackpot!",t:1},{id:150,n:"Double Jackpot!",t:2}]},
  {v:18,a:[{id:51,n:"Pea Shooter!",t:5},{id:52,n:"Crack_Shot!",t:10},{id:53,n:"Sharpshooter!",t:25},{id:54,n:"Deadeye!",t:50}]},
  {v:19,a:[{id:55,n:"Spider King!",t:40}]},
  {v:20,a:[{id:56,n:"Far!",t:10},{id:57,n:"Farther!",t:20},{id:58,n:"Farthest!",t:35},{id:59,n:"Fartherest!",t:50}]},
  {v:21,a:[{id:60,n:"10,000 Plus!",t:10000},{id:61,n:"20,000 Plus!",t:20000}]},
  {v:22,a:[{id:62,n:"Petty Officer!",t:5},{id:63,n:"Lieutenant!",t:10},{id:64,n:"Captain!",t:25},{id:65,n:"Admiral!",t:50}]},
  {v:23,a:[{id:66,n:"Speed Boat!",t:5}]},
  {v:24,a:[{id:67,n:"Breeze!",t:5},{id:68,n:"Wind!",t:10},{id:69,n:"Gale!",t:25},{id:70,n:"Storm!",t:50}]},
  {v:25,a:[{id:71,n:"Twister Top Dog!",t:30000}]},
  {v:26,a:[{id:72,n:"Bouncer!",t:5},{id:73,n:"Hopper!",t:15},{id:74,n:"Jumper!",t:30},{id:75,n:"Vaulter!",t:50}]},
  {v:27,a:[{id:76,n:"Treasure Chest!",t:1}]},
  {v:31,a:[{id:171,n:"Reduce!",t:5},{id:172,n:"Reuse!",t:10},{id:173,n:"Recycle!",t:25},{id:174,n:"Sir Sortsalot!",t:50}]},
  {v:32,a:[{id:175,n:"Go Green!",t:20}]},
  {v:36,a:[{id:77,n:"Casual Gamer!",t:50},{id:78,n:"Pro Gamer!",t:100},{id:79,n:"Frigid Gamer!",t:250}]},
  {v:37,a:[{id:176,n:"Super Sorter!",t:200}]},
  {v:38,a:[{id:84,n:"Pen Pal!",t:1}]},
  {v:39,a:[{id:85,n:"1 Gift Sent!",t:1},{id:86,n:"10 Gifts Sent!",t:10},{id:87,n:"25 Gifts Sent!",t:25},{id:88,n:"50 Gifts Sent!",t:50},{id:89,n:"100 Gifts Sent!",t:100}]},
  {v:41,a:[{id:91,n:"Fact Finder!",t:5},{id:92,n:"Bookworm!",t:20},{id:93,n:"Know It All!",t:50},{id:94,n:"Ultimate Explorer!",t:100}]},
  {v:44,a:[{id:95,n:"Dance Commander!",t:1}]},{v:45,a:[{id:96,n:"Fire Starter!",t:1}]},
  {v:46,a:[{id:97,n:"Falling Rocks!",t:1}]},{v:47,a:[{id:98,n:"Phantom Dream!",t:1}]},
  {v:48,a:[{id:99,n:"Can You Keep A Secret?",t:1}]},
  {v:50,a:[{id:100,n:"5 Hour Jammer!",t:5},{id:101,n:"10 Hour Jammer!",t:10},{id:102,n:"20 Hour Jammer!",t:20},{id:103,n:"50 Hour Jammer!",t:50},{id:104,n:"100 Hour Jammer!",t:100}]},
  {v:51,a:[{id:105,n:"Second Animal!",t:2},{id:106,n:"Beastmaster!",t:6}]},
  {v:52,a:[{id:107,n:"Production Assistant!",t:5},{id:108,n:"Key Grip!",t:10},{id:109,n:"Cinematographer!",t:25},{id:110,n:"Director!",t:50},{id:111,n:"Executive Producer!",t:100}]},
  {v:53,a:[{id:112,n:"First Quest!",t:1},{id:113,n:"10 Quests!",t:10},{id:114,n:"25 Quests!",t:25},{id:115,n:"50 Quests!",t:50},{id:116,n:"100 Quests!",t:100}]},
  {v:54,a:[{id:117,n:"Epic Quest!",t:1},{id:118,n:"Questmaster 5!",t:5},{id:119,n:"Questmaster 10!",t:10}]},
  {v:55,a:[{id:120,n:"World Traveler!",t:5}]},{v:56,a:[{id:121,n:"Mapper!",t:1}]},
  {v:57,a:[{id:122,n:"10 Base Visits - Rabbit!",t:10}]},{v:58,a:[{id:123,n:"10 Base Visits - Wolf!",t:10}]},
  {v:59,a:[{id:124,n:"10 Base Visits - Tiger!",t:10}]},{v:60,a:[{id:125,n:"10 Base Visits - Koala!",t:10}]},
  {v:61,a:[{id:126,n:"10 Base Visits - Panda!",t:10}]},{v:62,a:[{id:127,n:"10 Base Visits - Monkey!",t:10}]},
  {v:64,a:[{id:128,n:"Den Design 50!",t:50},{id:129,n:"Den Design 100!",t:100},{id:130,n:"Den Design 200!",t:200},{id:131,n:"Den Design 350!",t:350},{id:132,n:"Den Design 500!",t:500}]},
  {v:65,a:[{id:133,n:"Perfect Host!",t:1}]},
  {v:67,a:[{id:135,n:"1 Month Member!",t:1},{id:136,n:"3 Month Member!",t:3},{id:137,n:"6 Month Member!",t:6},{id:138,n:"9 Month Member!",t:9},{id:139,n:"Member - 1 Year!",t:12}]},
  {v:76,a:[{id:140,n:"Mira Says!",t:1}]},
  {v:77,a:[{id:142,n:"Mime!",t:5},{id:143,n:"Imitator!",t:10},{id:144,n:"Mimicker!",t:25},{id:145,n:"Copycat!",t:50}]},
  {v:79,a:[{id:151,n:"Team Rider!",t:10}]},{v:80,a:[{id:149,n:"300!",t:300}]},
  {v:81,a:[{id:154,n:"Ring King!",t:18}]},{v:82,a:[{id:152,n:"Team Zapper!",t:50}]},
  {v:83,a:[{id:153,n:"Perfectionist!",t:1}]},{v:84,a:[{id:148,n:"Superpower!",t:1}]},
  {v:85,a:[{id:147,n:"Untouchable!",t:3}]},
  {v:86,a:[{id:80,n:"Bronze Gamer!",t:25},{id:155,n:"Friendly Gamer!",t:25},{id:81,n:"Silver Gamer!",t:50},{id:156,n:"Friendlier Gamer!",t:50},{id:82,n:"Gold Gamer!",t:100},{id:157,n:"Friendliest Gamer!",t:100},{id:83,n:"Platinum Gamer!",t:250}]},
  {v:87,a:[{id:158,n:"Winner!",t:10},{id:159,n:"Victor!",t:25},{id:160,n:"Champion!",t:50}]},
  {v:91,a:[{id:161,n:"Breaker!",t:10},{id:162,n:"Buster!",t:20},{id:163,n:"Crasher!",t:35},{id:164,n:"Smasher!",t:50}]},
  {v:92,a:[{id:165,n:"Gem Guru!",t:10}]},{v:93,a:[{id:166,n:"Gem Ace!",t:20}]},
  {v:94,a:[{id:167,n:"Thin Ice!",t:1}]},{v:97,a:[{id:169,n:"Double Slide!",t:55555}]},
  {v:130,a:[{id:179,n:"Squash!",t:10},{id:180,n:"Smash!",t:20},{id:181,n:"Squish!",t:35},{id:182,n:"Splat!",t:50}]},
  {v:131,a:[{id:183,n:"400 Legs!",t:50}]},{v:132,a:[{id:184,n:"10,000 Pests!",t:10000}]},
  {v:143,a:[{id:185,n:"Fruit Salad!",t:10},{id:186,n:"Fruit Cake!",t:20},{id:187,n:"Fruit Juice!",t:35},{id:188,n:"Fruit Basket!",t:50}]},
  {v:144,a:[{id:189,n:"Ripe!",t:25}]},{v:145,a:[{id:190,n:"Kaboom!",t:1}]},
  {v:159,a:[{id:191,n:"Peachy Keen!",t:11},{id:192,n:"Top Banana!",t:51}]},
  {v:160,a:[{id:193,n:"Fruit Of The Doom!",t:300}]},
  {v:277,a:[{id:197,n:"Bounce!",t:5},{id:198,n:"Recoil!",t:10},{id:199,n:"Rebound!",t:25},{id:200,n:"Ricochet!",t:50}]},
  {v:278,a:[{id:201,n:"Bug Bomb!",t:1}]},{v:279,a:[{id:202,n:"Roly Poly!",t:1}]},
  {v:280,a:[{id:203,n:"Go For The Gold!",t:1}]},
  {v:281,a:[{id:204,n:"Seek!",t:5},{id:205,n:"Scan!",t:10},{id:206,n:"Search!",t:25},{id:207,n:"Discover!",t:50}]},
  {v:282,a:[{id:208,n:"Pinpoint!",t:500}]},{v:283,a:[{id:209,n:"Quick Find!",t:1}]},
  {v:284,a:[{id:210,n:"Nibble!",t:5},{id:211,n:"Bite!",t:10},{id:212,n:"Chomp!",t:25},{id:213,n:"Gulp!",t:50}]},
  {v:285,a:[{id:214,n:"Om Nom Nom!",t:500},{id:215,n:"Big Tuna!",t:5000}]},
  {v:292,a:[{id:216,n:"Seamstress!",t:5},{id:217,n:"Stylist!",t:10},{id:218,n:"Designer!",t:25},{id:219,n:"Model!",t:50}]},
  {v:293,a:[{id:220,n:"High Fashion!",t:20}]},{v:294,a:[{id:221,n:"Tres Chic!",t:1}]},
  {v:310,a:[{id:222,n:"Critter Finder!",t:6},{id:223,n:"Creature Seeker!",t:30}]},
  {v:309,a:[{id:224,n:"Catch Some Rays!",t:10}]},
  {v:308,a:[{id:225,n:"Magic Touch!",t:100},{id:226,n:"Golden Touch!",t:250}]},
  {v:313,a:[{id:227,n:"Lucky Dog!",t:25},{id:228,n:"Hot Dog!",t:50},{id:229,n:"Top Dog!",t:100}]},
  {v:314,a:[{id:230,n:"Catch Me If You Can!",t:5000}]},{v:315,a:[{id:231,n:"Pirate Puppy!",t:1}]},
  {v:316,a:[{id:232,n:"Duck And Cover!",t:50},{id:233,n:"Sitting Duck!",t:100},{id:234,n:"Ducks In A Row!",t:150}]},
  {v:317,a:[{id:235,n:"Quack Quack!",t:5000}]},{v:318,a:[{id:236,n:"Dapper Ducky!",t:1}]},
  {v:321,a:[{id:237,n:"Breakfast!",t:25},{id:238,n:"Lunch!",t:50},{id:239,n:"Dinner!",t:100}]},
  {v:322,a:[{id:240,n:"Dessert!",t:1000}]},{v:323,a:[{id:241,n:"Yum Yum!",t:5}]},
  {v:324,a:[{id:242,n:"Sharp!",t:5},{id:243,n:"Classy!",t:10},{id:244,n:"Posh!",t:25},{id:245,n:"Elegant!",t:50}]},
  {v:325,a:[{id:246,n:"Dashing!",t:20}]},{v:326,a:[{id:247,n:"In Vogue!",t:1}]},
  {v:327,a:[{id:248,n:"Trot!",t:10},{id:249,n:"Canter!",t:25},{id:250,n:"Gallop!",t:50}]},
  {v:328,a:[{id:251,n:"Foal!",t:10},{id:252,n:"Mare!",t:25},{id:253,n:"Stallion!",t:50}]},
  {v:329,a:[{id:254,n:"Jamaa Cup!",t:1}]},{v:330,a:[{id:255,n:"Thoroughbred!",t:15}]},
  {v:331,a:[{id:256,n:"Perfect Race!",t:1}]},
  {v:344,a:[{id:257,n:"Crust!",t:10},{id:258,n:"Mantle!",t:25},{id:259,n:"Core!",t:50}]},
  {v:345,a:[{id:260,n:"Fissure!",t:10},{id:261,n:"Dome!",t:25},{id:262,n:"Volcano!",t:50}]},
  {v:346,a:[{id:263,n:"Eruption!",t:5}]},{v:347,a:[{id:264,n:"Ring Of Fire!",t:1}]},
  {v:349,a:[{id:265,n:"Road Hog!",t:10},{id:266,n:"Hog Wild!",t:25},{id:267,n:"Whole Hog!",t:50}]},
  {v:350,a:[{id:268,n:"Hedge Your Bets!",t:10}]},{v:351,a:[{id:269,n:"Phantom Catcher!",t:1000}]},
  {v:352,a:[{id:270,n:"Finders Keepers!",t:50}]},{v:353,a:[{id:271,n:"Super Streak!",t:10}]},
  {v:357,a:[{id:272,n:"Dorsal Fin!",t:10},{id:273,n:"Blowhole!",t:25},{id:274,n:"Fluke!",t:50}]},
  {v:358,a:[{id:275,n:"Quick!",t:10},{id:276,n:"Swift!",t:25},{id:277,n:"Speedy!",t:50}]},
  {v:359,a:[{id:278,n:"High Five!",t:1}]},{v:360,a:[{id:279,n:"Regatta!",t:15}]},
  {v:361,a:[{id:280,n:"Bottlenose!",t:1}]},
  {v:378,a:[{id:281,n:"Flying High!",t:10},{id:282,n:"Flying Colors!",t:20},{id:283,n:"Flight Of Fancy!",t:35},{id:284,n:"Topflight!",t:50}]},
  {v:377,a:[{id:285,n:"For The Birds!",t:15},{id:286,n:"Birds Of A Feather!",t:40}]},
  {v:386,a:[{id:287,n:"Spotter!",t:10},{id:288,n:"Spotting!",t:25},{id:289,n:"Spotted!",t:50}]},
  {v:387,a:[{id:290,n:"Super Spot!",t:25},{id:291,n:"Hyper Spot!",t:50},{id:292,n:"Awesome Spot!",t:100}]},
  {v:388,a:[{id:293,n:"Ultra Spot!",t:10}]},
  {v:403,a:[{id:294,n:"Guess!",t:5},{id:295,n:"Good Guess!",t:10},{id:296,n:"Better Guess!",t:25},{id:297,n:"Best Guess!",t:50}]},
  {v:405,a:[{id:298,n:"Best Guesser!",t:10},{id:299,n:"Guess Master!",t:20}]},
  {v:444,a:[{id:303,n:"Saucier!",t:10},{id:304,n:"Sous-Chef!",t:25},{id:305,n:"Chef De Cuisine!",t:50}]},
  {v:445,a:[{id:300,n:"Hostess!",t:10},{id:301,n:"Waitress!",t:50},{id:302,n:"Ma\u00eetre D'!",t:100}]},
  {v:446,a:[{id:306,n:"Super Service!",t:15},{id:307,n:"Perfect Service!",t:40}]}
]

const selections = {}
let sending = false
let stopRequested = false
const expanded = new Set()

const achList = document.getElementById('achList')
const searchInput = document.getElementById('searchInput')
const countLabel = document.getElementById('countLabel')
const sendBtn = document.getElementById('sendBtn')
const stopBtn = document.getElementById('stopBtn')
const statusMsg = document.getElementById('statusMsg')
const progressBar = document.getElementById('progressBar')
const progressFill = document.getElementById('progressFill')

function groupSearchText(g) {
  return g.a.map(a => a.n).join(' ').toLowerCase()
}

function countImplied(g, tierIdx) {
  let c = 0
  const selectedTrigger = g.a[tierIdx].t
  for (let i = 0; i < tierIdx; i++) {
    if (g.a[i].t <= selectedTrigger) c++
  }
  return c
}

function renderList() {
  achList.innerHTML = ''
  const query = searchInput.value.toLowerCase().trim()

  G.forEach((g, gi) => {
    if (query && !groupSearchText(g).includes(query)) return

    const isSingle = g.a.length === 1
    const isExpanded = expanded.has(gi)
    const selectedTierIdx = selections[gi] !== undefined ? selections[gi] : null

    const groupDiv = document.createElement('div')
    groupDiv.className = 'ach-group'

    const header = document.createElement('div')
    header.className = 'ach-group-header' + (selectedTierIdx !== null ? ' has-selection' : '')

    if (isSingle) {
      const cb = document.createElement('input')
      cb.type = 'checkbox'
      cb.className = 'ach-single-cb'
      cb.checked = selectedTierIdx !== null
      cb.addEventListener('change', () => {
        if (sending) { cb.checked = !cb.checked; return }
        if (cb.checked) selections[gi] = 0
        else delete selections[gi]
        updateCount()
        renderList()
      })
      header.appendChild(cb)

      const name = document.createElement('span')
      name.className = 'ach-group-name'
      name.textContent = g.a[0].n
      header.appendChild(name)

      header.addEventListener('click', (e) => {
        if (sending || e.target === cb) return
        cb.checked = !cb.checked
        if (cb.checked) selections[gi] = 0
        else delete selections[gi]
        updateCount()
        renderList()
      })
    } else {
      const chevron = document.createElement('i')
      chevron.className = 'fas fa-chevron-right ach-group-chevron' + (isExpanded ? ' open' : '')
      header.appendChild(chevron)

      const name = document.createElement('span')
      name.className = 'ach-group-name'
      if (selectedTierIdx !== null) {
        const sel = g.a[selectedTierIdx]
        const implied = countImplied(g, selectedTierIdx)
        name.textContent = sel.n + (implied > 0 ? ' (+' + implied + ' below)' : '')
      } else {
        name.textContent = g.a[0].n + ' \u2192 ' + g.a[g.a.length - 1].n
      }
      header.appendChild(name)

      const badge = document.createElement('span')
      badge.className = 'ach-badge'
      badge.textContent = g.a.length
      header.appendChild(badge)

      header.addEventListener('click', () => {
        if (sending) return
        if (isExpanded) expanded.delete(gi)
        else expanded.add(gi)
        renderList()
      })
    }

    groupDiv.appendChild(header)

    if (!isSingle && isExpanded) {
      const tiersDiv = document.createElement('div')
      tiersDiv.className = 'ach-tiers open'

      g.a.forEach((ach, ai) => {
        const isSelected = selectedTierIdx === ai
        const isImplied = selectedTierIdx !== null && ai < selectedTierIdx && ach.t <= g.a[selectedTierIdx].t

        const tierDiv = document.createElement('div')
        tierDiv.className = 'ach-tier' + (isSelected ? ' selected' : '') + (isImplied ? ' implied' : '')

        const radio = document.createElement('input')
        radio.type = 'radio'
        radio.name = 'group-' + gi
        radio.checked = isSelected
        radio.addEventListener('change', () => {
          if (sending) return
          if (isSelected) {
            delete selections[gi]
            radio.checked = false
          } else {
            selections[gi] = ai
          }
          updateCount()
          renderList()
        })

        const nameSpan = document.createElement('span')
        nameSpan.className = 'ach-tier-name'
        nameSpan.textContent = ach.n

        const valSpan = document.createElement('span')
        valSpan.className = 'ach-tier-val'
        valSpan.textContent = ach.t.toLocaleString()

        tierDiv.appendChild(radio)
        tierDiv.appendChild(nameSpan)

        if (isImplied) {
          const impliedSpan = document.createElement('span')
          impliedSpan.className = 'ach-tier-implied'
          impliedSpan.textContent = 'included'
          tierDiv.appendChild(impliedSpan)
        }

        tierDiv.appendChild(valSpan)

        tierDiv.addEventListener('click', (e) => {
          if (sending || e.target === radio) return
          if (isSelected) {
            delete selections[gi]
          } else {
            selections[gi] = ai
          }
          updateCount()
          renderList()
        })

        tiersDiv.appendChild(tierDiv)
      })

      groupDiv.appendChild(tiersDiv)
    }

    achList.appendChild(groupDiv)
  })
}

function updateCount() {
  const groupCount = Object.keys(selections).length
  let achCount = 0
  for (const gi in selections) {
    const g = G[gi]
    const tierIdx = selections[gi]
    const selectedTrigger = g.a[tierIdx].t
    achCount += g.a.filter((a, i) => i === tierIdx || (i < tierIdx && a.t <= selectedTrigger)).length
  }
  countLabel.textContent = groupCount + ' groups, ~' + achCount + ' achievements'
  sendBtn.disabled = groupCount === 0 || sending
}

function setStatus(msg, type) {
  statusMsg.textContent = msg
  statusMsg.className = type === 'error' ? 'status-err' : type === 'progress' ? 'status-prog' : 'status-ok'
}

document.getElementById('selectAllBtn').addEventListener('click', () => {
  if (sending) return
  G.forEach((g, gi) => { selections[gi] = g.a.length - 1 })
  updateCount()
  renderList()
})

document.getElementById('selectNoneBtn').addEventListener('click', () => {
  if (sending) return
  for (const k in selections) delete selections[k]
  updateCount()
  renderList()
})

searchInput.addEventListener('input', () => renderList())

async function getRoomId() {
  const internalId = await dispatch.getState('internalRoomId')
  if (internalId !== null && internalId !== undefined) {
    const parsed = parseInt(internalId, 10)
    if (!isNaN(parsed)) return parsed
  }
  return await dispatch.getState('room')
}

sendBtn.addEventListener('click', async () => {
  const keys = Object.keys(selections)
  if (sending || keys.length === 0) return

  const roomId = await getRoomId()
  if (!roomId) {
    setStatus('Not currently in a room.', 'error')
    return
  }

  sending = true
  stopRequested = false
  sendBtn.style.display = 'none'
  stopBtn.style.display = ''
  progressBar.style.display = ''
  progressFill.style.width = '0%'

  let sent = 0
  for (let i = 0; i < keys.length; i++) {
    if (stopRequested) break

    const gi = keys[i]
    const g = G[gi]
    const tierIdx = selections[gi]
    const ach = g.a[tierIdx]

    dispatch.sendRemoteMessage(`%xt%o%zs%${roomId}%${g.v}%${ach.t}%1%`)
    sent++

    const pct = ((sent / keys.length) * 100).toFixed(1)
    progressFill.style.width = pct + '%'
    setStatus(`Sending ${sent}/${keys.length} (${ach.n})...`, 'progress')

    if (i < keys.length - 1) await new Promise(r => setTimeout(r, 110))
  }

  sending = false
  sendBtn.style.display = ''
  stopBtn.style.display = 'none'
  updateCount()

  if (stopRequested) {
    setStatus(`Stopped. Sent ${sent}/${keys.length} groups.`, 'error')
  } else {
    setStatus(`Done! Sent ${sent} group(s).`, 'ok')
  }

  setTimeout(() => {
    progressBar.style.display = 'none'
    progressFill.style.width = '0%'
  }, 2000)
})

stopBtn.addEventListener('click', () => { stopRequested = true })

renderList()
updateCount()
