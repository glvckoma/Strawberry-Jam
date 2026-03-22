const { ipcRenderer } = require('electron')

document.addEventListener('DOMContentLoaded', () => {
  const searchInput = document.getElementById('searchInput')
  const searchButton = document.getElementById('searchButton')
  const statusBar = document.getElementById('statusBar')
  const resultsList = document.getElementById('resultsList')
  const detailsArea = document.getElementById('detailsArea')
  const imageModal = document.getElementById('imageModal')
  const modalImage = document.getElementById('modalImage')
  const closeModalButton = document.getElementById('closeModalButton')

  const STATUS_COLORS = {
    ready: 'rgba(255,255,255,0.5)',
    searching: '#eab308',
    fetching: '#3b82f6',
    success: '#10b981',
    no_results: 'rgba(255,255,255,0.4)',
    error: '#ef4444'
  }

  const updateStatus = (message, state = 'ready') => {
    statusBar.textContent = message
    statusBar.style.color = STATUS_COLORS[state] || STATUS_COLORS.ready
  }

  const setControlsEnabled = (enabled) => {
    searchInput.disabled = !enabled
    searchButton.disabled = !enabled
    searchButton.style.opacity = enabled ? '1' : '0.5'
  }

  const displayResults = (results) => {
    resultsList.innerHTML = ''
    if (!results || results.length === 0) return
    results.forEach(result => {
      const li = document.createElement('li')
      li.textContent = result.title
      li.dataset.title = result.title
      li.dataset.url = result.url
      resultsList.appendChild(li)
    })
  }

  const showImageModal = (imageUrl) => {
    modalImage.src = imageUrl
    imageModal.classList.add('show')
  }

  const hideImageModal = () => {
    imageModal.classList.remove('show')
    modalImage.src = ''
  }

  const displayDetails = (sections, sourceUrl) => {
    detailsArea.innerHTML = ''
    if (!Array.isArray(sections) || sections.length === 0) {
      detailsArea.textContent = 'No details available.'
      return
    }

    sections.forEach(section => {
      if (section.title) {
        const titleEl = document.createElement('div')
        titleEl.style.cssText = 'font-size: 12px; font-weight: 600; color: rgba(255,255,255,0.6); text-transform: uppercase; letter-spacing: 0.3px; margin: 10px 0 6px 0;'
        titleEl.textContent = section.title
        detailsArea.appendChild(titleEl)
      }

      if (section.type === 'table' && section.headers && section.rows) {
        const table = document.createElement('table')
        const thead = document.createElement('thead')
        const tbody = document.createElement('tbody')

        if (section.imageUrls && section.imageUrls.some(url => url !== null)) {
          const imageRow = document.createElement('tr')
          const colCount = section.headers.length > 0 ? section.headers.length : section.imageUrls.length
          for (let i = 0; i < colCount; i++) {
            const td = document.createElement('td')
            td.style.textAlign = 'center'
            const imageUrl = section.imageUrls[i]
            if (imageUrl) {
              const img = document.createElement('img')
              img.src = imageUrl
              img.alt = section.headers[i] || 'Item'
              img.addEventListener('click', () => showImageModal(imageUrl))
              td.appendChild(img)
            }
            imageRow.appendChild(td)
          }
          tbody.appendChild(imageRow)
        }

        if (section.headers.length > 0) {
          const headerRow = document.createElement('tr')
          section.headers.forEach(headerText => {
            const th = document.createElement('th')
            th.textContent = headerText
            headerRow.appendChild(th)
          })
          thead.appendChild(headerRow)
          table.appendChild(thead)
        }

        section.rows.forEach(rowData => {
          const dataRow = document.createElement('tr')
          rowData.forEach(cellText => {
            const td = document.createElement('td')
            td.textContent = cellText
            dataRow.appendChild(td)
          })
          tbody.appendChild(dataRow)
        })
        table.appendChild(tbody)
        detailsArea.appendChild(table)
      } else if (section.type === 'text' && section.content) {
        const p = document.createElement('p')
        p.style.cssText = 'font-size: 12px; color: rgba(255,255,255,0.6); padding: 8px 0;'
        p.textContent = section.content
        detailsArea.appendChild(p)
      }
    })

    if (sourceUrl) {
      const sourceP = document.createElement('p')
      sourceP.style.cssText = 'margin-top: 10px; font-size: 11px;'
      const sourceLink = document.createElement('a')
      sourceLink.href = sourceUrl
      sourceLink.textContent = 'View on Wiki'
      sourceLink.addEventListener('click', (event) => {
        event.preventDefault()
        ipcRenderer.send('open-url', sourceUrl)
      })
      sourceP.appendChild(sourceLink)
      detailsArea.appendChild(sourceP)
    }
  }

  const handleSearch = async () => {
    const searchTerm = searchInput.value.trim()
    if (!searchTerm) {
      updateStatus('Enter an item name to search.', 'error')
      return
    }

    updateStatus(`Searching for "${searchTerm}"...`, 'searching')
    resultsList.innerHTML = ''
    detailsArea.innerHTML = ''
    setControlsEnabled(false)

    try {
      const results = await ipcRenderer.invoke('search-wiki', searchTerm)
      displayResults(results)
      if (results.length > 0) {
        updateStatus(`Found ${results.length} result${results.length > 1 ? 's' : ''}.`, 'success')
      } else {
        updateStatus('No results found.', 'no_results')
      }
    } catch (error) {
      updateStatus(`Search failed: ${error.message}`, 'error')
    } finally {
      setControlsEnabled(true)
    }
  }

  const handleResultClick = async (event) => {
    const listItem = event.target.closest('li')
    if (!listItem || !listItem.dataset.title) return

    const pageTitle = listItem.dataset.title
    updateStatus(`Loading "${pageTitle}"...`, 'fetching')
    detailsArea.innerHTML = ''
    setControlsEnabled(false)

    try {
      const response = await ipcRenderer.invoke('get-page-details', pageTitle)
      if (response && Array.isArray(response.sections)) {
        displayDetails(response.sections, response.source_url)
        updateStatus('Details loaded.', 'success')
      } else {
        throw new Error('Invalid response from server.')
      }
    } catch (error) {
      updateStatus(`Failed: ${error.message}`, 'error')
      detailsArea.textContent = error.message
    } finally {
      setControlsEnabled(true)
    }
  }

  searchButton.addEventListener('click', handleSearch)
  searchInput.addEventListener('keypress', (event) => {
    if (event.key === 'Enter') handleSearch()
  })
  resultsList.addEventListener('click', handleResultClick)
  closeModalButton.addEventListener('click', hideImageModal)
  imageModal.addEventListener('click', (event) => {
    if (event.target === imageModal) hideImageModal()
  })

  updateStatus('Ready', 'ready')
})
