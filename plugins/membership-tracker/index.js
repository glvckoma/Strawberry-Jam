const { ipcRenderer } = require('electron')

module.exports = function ({ application, dispatch }) {
  const DATA_FILE = 'membership-tracker.json'
  const WARN_DAYS = 3

  let enabled = true
  let memberships = {}
  let activePopup = null

  const getTodayDate = () => new Date().toISOString().split('T')[0]

  const getEffectiveDaysLeft = (u) => {
    if (u.daysLeft === -1) return -1
    const daysSinceLastSeen = Math.floor((Date.now() - u.lastSeen) / 86400000)
    return u.daysLeft - daysSinceLastSeen
  }

  const loadData = async () => {
    const data = await ipcRenderer.invoke('read-json-file', DATA_FILE, {
      enabled: true,
      memberships: {}
    })
    enabled = Boolean(data.enabled)
    memberships = data.memberships || {}
  }

  const saveData = async () => {
    await ipcRenderer.invoke('write-json-file', DATA_FILE, { enabled, memberships })
  }

  const closePopup = () => {
    if (activePopup) {
      activePopup.remove()
      activePopup = null
    }
  }

  const makeModal = (titleText) => {
    const wrapper = document.createElement('div')
    wrapper.style.cssText = 'position:fixed;inset:0;z-index:9000;background:rgba(0,0,0,0.7);backdrop-filter:blur(4px);display:flex;align-items:center;justify-content:center;'

    const modal = document.createElement('div')
    modal.className = 'modal-container'
    modal.style.cssText = 'width:420px;max-width:90vw;'

    const header = document.createElement('div')
    header.className = 'modal-header'

    const icon = document.createElement('i')
    icon.className = 'fas fa-shield-alt modal-section-icon'

    const title = document.createElement('span')
    title.className = 'modal-header-title'
    title.textContent = titleText

    header.appendChild(icon)
    header.appendChild(title)
    modal.appendChild(header)
    wrapper.appendChild(modal)

    return { wrapper, modal }
  }

  const makeFooterButton = (label, onClick) => {
    const footer = document.createElement('div')
    footer.className = 'modal-footer'
    footer.style.justifyContent = 'flex-end'

    const btn = document.createElement('button')
    btn.className = 'modal-btn-primary'
    btn.textContent = label
    btn.addEventListener('click', onClick)

    footer.appendChild(btn)
    return footer
  }

  const makeRow = (u, badgeText, badgeClass) => {
    const row = document.createElement('div')
    row.className = 'modal-setting-row mb-1'

    const name = document.createElement('span')
    name.className = 'text-sm text-text-primary'
    name.textContent = u.userName

    const right = document.createElement('div')
    right.className = 'flex items-center gap-3'

    const badge = document.createElement('span')
    badge.className = 'text-xs font-semibold ' + badgeClass
    badge.textContent = badgeText

    const deleteBtn = document.createElement('button')
    deleteBtn.className = 'text-gray-500 hover:text-error-red transition-colors'
    deleteBtn.innerHTML = '<i class="fas fa-times" style="font-size:11px;"></i>'
    deleteBtn.addEventListener('click', async () => {
      delete memberships[u.userId]
      await saveData()
      row.remove()
    })

    right.appendChild(badge)
    right.appendChild(deleteBtn)
    row.appendChild(name)
    row.appendChild(right)
    return row
  }

  const buildAlertPopup = (entries) => {
    closePopup()
    const { wrapper, modal } = makeModal('Membership Expiring')

    const body = document.createElement('div')
    body.className = 'modal-body themed-scrollbar'
    body.style.maxHeight = '240px'

    entries.forEach(({ u, effectiveDaysLeft }) => {
      const badgeText = effectiveDaysLeft <= 0
        ? 'Expires today'
        : effectiveDaysLeft + ' day' + (effectiveDaysLeft === 1 ? '' : 's') + ' left'
      const badgeClass = effectiveDaysLeft <= 0 ? 'text-error-red' : 'text-highlight-yellow'
      body.appendChild(makeRow(u, badgeText, badgeClass))
    })

    modal.appendChild(body)
    modal.appendChild(makeFooterButton('Dismiss', closePopup))
    document.body.appendChild(wrapper)
    activePopup = wrapper
  }

  const buildListPopup = (entries) => {
    closePopup()
    const { wrapper, modal } = makeModal('Tracked Memberships')

    const body = document.createElement('div')
    body.className = 'modal-body themed-scrollbar'
    body.style.maxHeight = '300px'

    if (entries.length === 0) {
      const empty = document.createElement('p')
      empty.className = 'text-sm text-gray-400 text-center py-4'
      empty.textContent = 'No memberships tracked yet.'
      body.appendChild(empty)
    } else {
      entries.forEach(u => {
        const effectiveDaysLeft = getEffectiveDaysLeft(u)
        let badgeText, badgeClass

        if (effectiveDaysLeft === -1) {
          badgeText = 'Recurring'
          badgeClass = 'text-highlight-green'
        } else if (effectiveDaysLeft <= 0) {
          badgeText = 'Expired'
          badgeClass = 'text-error-red'
        } else if (effectiveDaysLeft <= WARN_DAYS) {
          badgeText = effectiveDaysLeft + ' day' + (effectiveDaysLeft === 1 ? '' : 's') + ' left'
          badgeClass = 'text-highlight-yellow'
        } else {
          const expiresAt = new Date(u.lastSeen + u.daysLeft * 86400000)
          badgeText = expiresAt.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' })
          badgeClass = 'text-highlight-green'
        }

        body.appendChild(makeRow(u, badgeText, badgeClass))
      })
    }

    modal.appendChild(body)
    modal.appendChild(makeFooterButton('Close', closePopup))
    document.body.appendChild(wrapper)
    activePopup = wrapper
  }

  const checkStartupAlerts = async () => {
    const today = getTodayDate()
    const toAlert = Object.values(memberships)
      .map(u => ({ u, effectiveDaysLeft: getEffectiveDaysLeft(u) }))
      .filter(({ u, effectiveDaysLeft }) =>
        effectiveDaysLeft >= 0 && effectiveDaysLeft <= WARN_DAYS && u.lastNotifiedDate !== today
      )

    if (toAlert.length === 0) return

    toAlert.forEach(({ u }) => {
      memberships[u.userId].lastNotifiedDate = today
    })
    await saveData()
    buildAlertPopup(toAlert)
  }

  const handleLoginMessage = async ({ message }) => {
    if (!enabled) return

    const params = message.value.b.o.params
    if (!params) return

    const { userName, userId, numDaysLeftOnSubscription } = params
    if (!userName || userId == null) return

    const daysLeft = typeof numDaysLeftOnSubscription === 'number' ? numDaysLeftOnSubscription : -1
    const prev = memberships[userId] || {}

    memberships[userId] = {
      userName,
      userId,
      daysLeft,
      lastSeen: Date.now(),
      lastNotifiedDate: prev.lastNotifiedDate || null
    }

    await saveData()

    if (daysLeft === -1) {
      application.consoleMessage({ message: `[Membership Tracker] ${userName}: recurring membership`, type: 'notify' })
    } else if (daysLeft === 0) {
      application.consoleMessage({ message: `[Membership Tracker] ${userName}: membership expires today`, type: 'error' })
    } else if (daysLeft <= WARN_DAYS) {
      application.consoleMessage({ message: `[Membership Tracker] ${userName}: ${daysLeft} day${daysLeft === 1 ? '' : 's'} remaining`, type: 'warn' })
    } else {
      application.consoleMessage({ message: `[Membership Tracker] ${userName}: ${daysLeft} days remaining`, type: 'notify' })
    }
  }

  const handleTrackCommand = async ({ parameters }) => {
    if (parameters[0] === 'list') {
      buildListPopup(Object.values(memberships))
      return
    }
    enabled = !enabled
    await saveData()
    application.consoleMessage({
      message: `[Membership Tracker] Tracking ${enabled ? 'enabled' : 'disabled'}.`,
      type: enabled ? 'success' : 'notify'
    })
  }

  dispatch.onMessage({
    type: 'aj',
    message: 'login',
    callback: handleLoginMessage
  })

  dispatch.onCommand({
    name: 'trackmembership',
    description: 'Toggle membership tracking, or use "list" to view all tracked accounts.',
    callback: handleTrackCommand,
    parameters: [
      {
        name: 'list',
        description: 'Show all tracked memberships with expiration dates.',
        required: false
      }
    ]
  })

  loadData().then(() => {
    setTimeout(checkStartupAlerts, 2500)
    dispatch.setInterval(checkStartupAlerts, 86400000)
  })
}
