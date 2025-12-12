const { ipcRenderer } = require('electron')

document.addEventListener('DOMContentLoaded', () => {
  console.log('[PriceCheckerPlugin] Initialized')

  const searchInput = document.getElementById('searchInput')
  const searchButton = document.getElementById('searchButton')
  const statusBar = document.getElementById('statusBar')
  const resultsList = document.getElementById('resultsList')
  const detailsArea = document.getElementById('detailsArea')
  const imageModal = document.getElementById('imageModal')
  const modalImage = document.getElementById('modalImage')
  const closeModalButton = document.getElementById('closeModalButton')

  const STATUS_STYLES = {
    ready: 'text-gray-600 dark:text-gray-400',
    searching: 'text-yellow-600 dark:text-yellow-400',
    fetching: 'text-blue-600 dark:text-blue-400',
    success: 'text-green-600 dark:text-green-400',
    no_results: 'text-gray-500 dark:text-gray-500',
    error: 'text-red-600 dark:text-red-400'
  }

  const updateStatus = (message, state = 'ready') => {
    if (!STATUS_STYLES[state]) {
      state = 'ready'
    }
    statusBar.textContent = `Status: ${message}`
    Object.values(STATUS_STYLES).forEach(className => {
      className.split(' ').forEach(cls => {
        if (cls) statusBar.classList.remove(cls)
      })
    })
    STATUS_STYLES[state].split(' ').forEach(cls => {
      if (cls) statusBar.classList.add(cls)
    })
  }

  const setControlsEnabled = (enabled) => {
    searchInput.disabled = !enabled
    searchButton.disabled = !enabled
  }

  const clearResultsAndDetails = () => {
    resultsList.innerHTML = ''
    detailsArea.innerHTML = ''
  }

  const displayResults = (results) => {
    resultsList.innerHTML = ''
    if (!results || results.length === 0) {
      return
    }
    results.forEach(result => {
      const li = document.createElement('li')
      li.textContent = result.title
      li.dataset.url = result.url
      li.title = `Click to view details for: ${result.title}\nURL: ${result.url}`
      resultsList.appendChild(li)
    })
  }

  const displayDetails = (sections, sourceUrl) => {
    detailsArea.innerHTML = ''
    if (!Array.isArray(sections) || sections.length === 0) {
      detailsArea.textContent = 'Error: Received no details data or invalid format.'
      return
    }

    sections.forEach(section => {
      if (section.title && section.title !== 'Worth Details') {
        const titleEl = document.createElement('h3')
        titleEl.className = 'text-md font-semibold mt-4 mb-2 dark:text-gray-300 first:mt-0'
        titleEl.textContent = section.title
        detailsArea.appendChild(titleEl)
      }

      if (section.type === 'table' && section.headers && section.rows) {
        const table = document.createElement('table')
        table.className = 'w-full border-collapse border border-gray-300 dark:border-gray-600 text-xs mb-2'
        const thead = document.createElement('thead')
        const tbody = document.createElement('tbody')

        if (section.imageUrls && section.imageUrls.length > 0 && section.imageUrls.some(url => url !== null)) {
          const imageRow = document.createElement('tr')
          imageRow.className = 'bg-white dark:bg-gray-700'
          const imageCellsToAdd = section.headers.length > 0 ? section.headers.length : section.imageUrls.length
          for (let i = 0; i < imageCellsToAdd; i++) {
            const td = document.createElement('td')
            td.className = 'p-1 border border-gray-300 dark:border-gray-600 text-center align-middle'
            const imageUrl = section.imageUrls[i]
            if (imageUrl) {
              const img = document.createElement('img')
              img.src = imageUrl
              img.alt = section.headers[i] || 'Item Variant'
              img.className = 'inline-block max-h-16 object-contain cursor-pointer hover:opacity-80 transition-opacity'
              img.addEventListener('click', () => {
                modalImage.src = imageUrl
                imageModal.classList.remove('hidden')
              })
              td.appendChild(img)
            } else {
              td.innerHTML = '&nbsp;'
            }
            imageRow.appendChild(td)
          }
          tbody.appendChild(imageRow)
        }

        if (section.headers.length > 0) {
          thead.className = 'bg-gray-100 dark:bg-gray-600'
          const headerRow = document.createElement('tr')
          section.headers.forEach(headerText => {
            const th = document.createElement('th')
            th.textContent = headerText
            th.className = 'border border-gray-300 dark:border-gray-600 p-2 text-left font-semibold'
            headerRow.appendChild(th)
          })
          thead.appendChild(headerRow)
          table.appendChild(thead)
        }

        section.rows.forEach(rowData => {
          const dataRow = document.createElement('tr')
          dataRow.className = 'even:bg-white odd:bg-gray-50 dark:even:bg-gray-700 dark:odd:bg-gray-600'
          rowData.forEach(cellText => {
            const td = document.createElement('td')
            td.textContent = cellText
            td.className = 'border border-gray-300 dark:border-gray-600 p-2 align-top'
            dataRow.appendChild(td)
          })
          tbody.appendChild(dataRow)
        })
        table.appendChild(tbody)
        detailsArea.appendChild(table)
      } else if (section.type === 'text' && section.content) {
        const pre = document.createElement('pre')
        pre.className = 'whitespace-pre-wrap break-words text-sm'
        pre.textContent = section.content
        detailsArea.appendChild(pre)
      }
    })

    if (sourceUrl) {
      const sourceP = document.createElement('p')
      sourceP.className = 'source-url mt-4'
      const sourceLink = document.createElement('a')
      sourceLink.href = sourceUrl
      sourceLink.textContent = sourceUrl
      sourceLink.target = '_blank'
      sourceLink.rel = 'noopener noreferrer'
      sourceLink.className = 'text-blue-600 dark:text-blue-400 hover:underline cursor-pointer'
      sourceLink.addEventListener('click', (event) => {
        event.preventDefault()
        ipcRenderer.send('open-url', sourceUrl)
      })
      sourceP.appendChild(document.createTextNode('Source: '))
      sourceP.appendChild(sourceLink)
      detailsArea.appendChild(sourceP)
    }
  }

  const handleSearch = async () => {
    const searchTerm = searchInput.value.trim()
    if (!searchTerm) {
      updateStatus('Please enter an item name.', 'error')
      return
    }

    updateStatus(`Searching for "${searchTerm}"...`, 'searching')
    clearResultsAndDetails()
    setControlsEnabled(false)

    try {
      const results = await ipcRenderer.invoke('search-wiki', searchTerm)
      displayResults(results)
      const statusState = results.length > 0 ? 'success' : 'no_results'
      const statusMessage = results.length > 0 ? `Found ${results.length} results.` : 'No results found.'
      updateStatus(statusMessage, statusState)
    } catch (error) {
      console.error('Search Error:', error)
      updateStatus(`Search failed: ${error.message}`, 'error')
    } finally {
      setControlsEnabled(true)
    }
  }

  const handleResultClick = async (event) => {
    const listItem = event.target.closest('li')
    if (!listItem || !listItem.dataset.url) {
      return
    }

    const pageUrl = listItem.dataset.url
    const pageTitle = listItem.textContent

    updateStatus(`Fetching details for "${pageTitle}"...`, 'fetching')
    detailsArea.innerHTML = ''
    setControlsEnabled(false)

    try {
      const response = await ipcRenderer.invoke('get-page-details', pageUrl)
      if (response && Array.isArray(response.sections)) {
        displayDetails(response.sections, response.source_url)
        updateStatus('Details loaded.', 'success')
        document.getElementById('detailsArea').scrollIntoView({ behavior: 'smooth' })
      } else {
        throw new Error('Invalid data structure received from main process.')
      }
    } catch (error) {
      console.error('Details Fetch Error:', error)
      const errorMessage = `Failed to fetch details: ${error.message}`
      updateStatus(errorMessage, 'error')
      detailsArea.textContent = errorMessage
    } finally {
      setControlsEnabled(true)
    }
  }

  searchButton.addEventListener('click', handleSearch)
  searchInput.addEventListener('keypress', (event) => {
    if (event.key === 'Enter') {
      handleSearch()
    }
  })
  resultsList.addEventListener('click', handleResultClick)
  closeModalButton.addEventListener('click', () => {
    imageModal.classList.add('hidden')
    modalImage.src = ''
  })
  imageModal.addEventListener('click', (event) => {
    if (event.target === imageModal) {
      imageModal.classList.add('hidden')
      modalImage.src = ''
    }
  })

  updateStatus('Ready. Enter an item name.', 'ready')
})
