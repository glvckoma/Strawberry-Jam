document.addEventListener('DOMContentLoaded', function () {
  const clothingData = require('./assets/1000-clothing.json')
  const path = require('path')
  const fs = require('fs')
  const assetsDir = path.join(__dirname, 'assets')

  function playAudio (filename, pan) {
    const data = fs.readFileSync(path.join(assetsDir, filename))
    const blob = new Blob([data], { type: 'audio/mpeg' })
    const audio = new Audio(URL.createObjectURL(blob))
    if (pan !== undefined) {
      const ctx = new AudioContext()
      const src = ctx.createMediaElementSource(audio)
      const gain = ctx.createGain()
      gain.gain.value = 0.4
      const panner = ctx.createStereoPanner()
      panner.pan.value = pan
      src.connect(gain)
      gain.connect(panner)
      panner.connect(ctx.destination)
    }
    audio.play()
  }

  function buildItemList (layerId) {
    const seen = new Set()
    return Object.values(clothingData)
      .filter(function (item) {
        return item.layerId === layerId && item.name && item.name !== '1'
      })
      .map(function (item) { return item.name })
      .filter(function (name) {
        if (seen.has(name)) return false
        seen.add(name)
        return true
      })
      .sort()
  }

  function makeCombo (containerId, items) {
    const container = document.getElementById(containerId)

    const wrap = document.createElement('div')
    wrap.className = 'op-combo'

    const inputWrap = document.createElement('div')
    inputWrap.className = 'op-combo-wrap'

    const input = document.createElement('input')
    input.type = 'text'
    input.className = 'op-combo-input'
    input.placeholder = 'Search or select...'
    input.autocomplete = 'off'
    input.spellcheck = false

    const arrow = document.createElement('button')
    arrow.type = 'button'
    arrow.className = 'op-combo-arrow'
    arrow.tabIndex = -1
    arrow.innerHTML = '<i class="fas fa-chevron-down"></i>'

    const list = document.createElement('div')
    list.className = 'op-combo-list'

    inputWrap.appendChild(input)
    inputWrap.appendChild(arrow)
    wrap.appendChild(inputWrap)
    wrap.appendChild(list)
    container.appendChild(wrap)

    let selectedValue = ''
    let highlightIndex = -1
    let filtered = []
    let isOpen = false

    function getFiltered (query) {
      if (!query) return items
      const q = query.toLowerCase()
      const starts = items.filter(function (n) { return n.toLowerCase().startsWith(q) })
      const contains = items.filter(function (n) { return !n.toLowerCase().startsWith(q) && n.toLowerCase().includes(q) })
      return starts.concat(contains)
    }

    function renderList (query) {
      filtered = getFiltered(query)
      list.innerHTML = ''
      highlightIndex = -1

      if (filtered.length === 0) {
        const empty = document.createElement('div')
        empty.className = 'op-combo-more'
        empty.textContent = 'No items found'
        list.appendChild(empty)
        return
      }

      const visible = filtered.slice(0, 100)
      visible.forEach(function (name, i) {
        const opt = document.createElement('div')
        opt.className = 'op-combo-option'
        if (name === selectedValue) opt.classList.add('op-selected')
        opt.textContent = name
        opt.addEventListener('mousedown', function (e) {
          e.preventDefault()
          select(name)
        })
        list.appendChild(opt)
      })

      if (filtered.length > 100) {
        const more = document.createElement('div')
        more.className = 'op-combo-more'
        more.textContent = (filtered.length - 100) + ' more, type to narrow'
        list.appendChild(more)
      }
    }

    function open () {
      if (isOpen) return
      isOpen = true
      list.classList.add('open')
      arrow.classList.add('open')
      renderList(input.value)
      const sel = list.querySelector('.op-selected')
      if (sel) sel.scrollIntoView({ block: 'nearest' })
    }

    function close () {
      if (!isOpen) return
      isOpen = false
      list.classList.remove('open')
      arrow.classList.remove('open')
      highlightIndex = -1
    }

    function select (name) {
      selectedValue = name
      input.value = name
      close()
    }

    function setHighlight (index) {
      const opts = list.querySelectorAll('.op-combo-option')
      opts.forEach(function (o, i) { o.classList.toggle('op-hi', i === index) })
      if (index >= 0 && opts[index]) opts[index].scrollIntoView({ block: 'nearest' })
      highlightIndex = index
    }

    input.addEventListener('focus', function () { open() })

    input.addEventListener('blur', function () {
      setTimeout(function () {
        close()
        if (selectedValue && input.value !== selectedValue) {
          input.value = selectedValue
        }
      }, 160)
    })

    input.addEventListener('input', function () {
      selectedValue = ''
      if (!isOpen) open()
      else renderList(input.value)
    })

    input.addEventListener('keydown', function (e) {
      const opts = list.querySelectorAll('.op-combo-option')
      if (e.key === 'ArrowDown') {
        e.preventDefault()
        if (!isOpen) { open(); return }
        setHighlight(Math.min(highlightIndex + 1, opts.length - 1))
      } else if (e.key === 'ArrowUp') {
        e.preventDefault()
        setHighlight(Math.max(highlightIndex - 1, 0))
      } else if (e.key === 'Enter') {
        e.preventDefault()
        if (highlightIndex >= 0 && filtered[highlightIndex]) select(filtered[highlightIndex])
      } else if (e.key === 'Escape') {
        close()
        input.blur()
      }
    })

    arrow.addEventListener('mousedown', function (e) {
      e.preventDefault()
      if (isOpen) { close(); input.blur() } else { input.focus(); open() }
    })

    return {
      get value () { return selectedValue },
      shake () {
        input.classList.remove('op-invalid')
        void input.offsetWidth
        input.classList.add('op-invalid')
        setTimeout(function () { input.classList.remove('op-invalid') }, 400)
      },
      reset () {
        selectedValue = ''
        input.value = ''
        close()
      }
    }
  }

  const headCombo = makeCombo('op-head', buildItemList('8'))
  const topCombo = makeCombo('op-top', buildItemList('6'))
  const shoesCombo = makeCombo('op-shoes', buildItemList('5'))
  const neckCombo = makeCombo('op-neck', buildItemList('7'))
  const tailCombo = makeCombo('op-tail', buildItemList('4'))
  const combos = [headCombo, topCombo, shoesCombo, neckCombo, tailCombo]

  const equipBtn = document.getElementById('op-equip')
  const warning = document.getElementById('op-warning')
  const form = document.getElementById('op-form')
  const reveal = document.getElementById('op-reveal')
  const gif = document.getElementById('op-gif')
  const banner = document.getElementById('op-banner')

  let clickCount = 0

  equipBtn.addEventListener('click', function () {
    const allFilled = combos.every(function (c) { return c.value !== '' })
    if (!allFilled) {
      combos.forEach(function (c) { if (c.value === '') c.shake() })
      return
    }

    clickCount++
    if (clickCount === 1) {
      warning.style.display = 'block'
      playAudio('door.mp3', -1)
      return
    }
    equipBtn.disabled = true
    triggerReveal()
  })

  function triggerReveal () {
    const gifData = fs.readFileSync(path.join(assetsDir, 'gorilla-smile.gif'))
    gif.src = 'data:image/gif;base64,' + gifData.toString('base64')

    form.style.transition = 'opacity 500ms ease'
    form.style.opacity = '0'

    setTimeout(function () {
      form.style.display = 'none'

      const colors = ['#ffd700', '#ff6b9d', '#ffffff', '#00d8ff']
      'April Fools!'.split('').forEach(function (char, i) {
        const span = document.createElement('span')
        span.className = 'op-letter'
        span.textContent = char === ' ' ? '\u00A0' : char
        span.style.color = colors[i % colors.length]
        span.style.animationDelay = (i * 0.065) + 's'
        banner.appendChild(span)
      })

      reveal.style.pointerEvents = 'auto'
      reveal.style.transition = 'opacity 500ms ease'
      reveal.style.opacity = '1'

      setTimeout(function () { playAudio('Noise.mp3') }, 400)

      setTimeout(function () {
        reveal.style.transition = 'opacity 500ms ease'
        reveal.style.opacity = '0'

        setTimeout(function () {
          reveal.style.pointerEvents = 'none'
          banner.innerHTML = ''
          gif.src = ''

          warning.style.display = 'none'
          clickCount = 0
          equipBtn.disabled = false
          combos.forEach(function (c) { c.reset() })

          form.style.display = ''
          setTimeout(function () { form.style.opacity = '1' }, 0)
        }, 550)
      }, 9000)
    }, 600)
  }
})
