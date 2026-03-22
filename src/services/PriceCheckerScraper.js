const axios = require('axios')
const cheerio = require('cheerio')

const BASE_URL = "https://aj-item-worth.fandom.com"
const API_URL = `${BASE_URL}/api.php`
const REQUEST_TIMEOUT = 30000

async function searchForItems(searchTerm) {
  const response = await axios.get(API_URL, {
    params: {
      action: 'query',
      list: 'search',
      srsearch: searchTerm,
      srnamespace: 0,
      srlimit: 15,
      format: 'json'
    },
    timeout: REQUEST_TIMEOUT
  })

  if (!response.data.query || !response.data.query.search) {
    return []
  }

  return response.data.query.search.map(result => ({
    title: result.title,
    url: `${BASE_URL}/wiki/${encodeURIComponent(result.title.replace(/ /g, '_'))}`
  }))
}

async function getItemDetails(pageTitle) {
  const response = await axios.get(API_URL, {
    params: {
      action: 'parse',
      page: pageTitle,
      prop: 'text',
      format: 'json'
    },
    timeout: REQUEST_TIMEOUT
  })

  if (!response.data.parse || !response.data.parse.text) {
    throw new Error('No content found for page')
  }

  const htmlContent = response.data.parse.text['*']
  const pageUrl = `${BASE_URL}/wiki/${encodeURIComponent(pageTitle.replace(/ /g, '_'))}`
  const sections = extractWorthDetails(htmlContent)
  return { sections, source_url: pageUrl }
}

function extractTableFromRows(rows, $) {
  let headers = []
  let tableRowsData = []
  let tableImageUrls = []

  if (rows.length === 0) return null

  const headerRow = rows.first()
  headers = headerRow.find('th, td').map((i, el) => $(el).text().trim()).get()
  const dataRowsTr = rows.slice(1)
  let imageRowIndex = -1

  dataRowsTr.each((rowIndex, rowElement) => {
    if ($(rowElement).find('img').length > 0) {
      imageRowIndex = rowIndex
      const numColumns = headers.length > 0 ? headers.length : $(rowElement).find('td, th').length
      const imageCells = $(rowElement).find('td, th')
      for (let i = 0; i < numColumns; i++) {
        let cellImageUrl = null
        if (i < imageCells.length) {
          const imgTag = $(imageCells[i]).find('img').first()
          if (imgTag.length > 0) {
            cellImageUrl = imgTag.attr('data-src') || imgTag.attr('src')
            if (cellImageUrl && cellImageUrl.includes('/scale-to-width-down/')) {
              cellImageUrl = cellImageUrl.split('/scale-to-width-down/')[0]
            }
          }
        }
        tableImageUrls.push(cellImageUrl)
      }
      return false
    }
  })

  dataRowsTr.each((rowIndex, rowElement) => {
    if (rowIndex === imageRowIndex) return
    let rowCellsText = []
    $(rowElement).find('td, th').each((cellIndex, cellElement) => {
      let cellText = $(cellElement).text().replace(/\s+/g, ' ').trim()
      rowCellsText.push(cellText)
    })
    if (rowCellsText.some(text => text)) {
      tableRowsData.push(rowCellsText)
    }
  })

  if (headers.length === 0 && tableRowsData.length === 0) return null
  return { headers, rows: tableRowsData, imageUrls: tableImageUrls }
}

function extractWorthDetails(htmlContent) {
  const $ = cheerio.load(htmlContent)
  const sections = []
  const contentArea = $('div.mw-parser-output')

  if (contentArea.length === 0) {
    return [{ type: "text", title: "Error", content: "Could not find main content area to parse." }]
  }

  contentArea.find('h2').each((index, h2Element) => {
    const sectionTitle = $(h2Element).find('.mw-headline').text().trim()
    if (!sectionTitle) return

    let worthTable = null
    let currentNode = $(h2Element).next()
    while (currentNode.length > 0 && !currentNode.is('h2')) {
      if (currentNode.is('table.wikitable, table.article-table')) {
        worthTable = currentNode
        break
      }
      const foundTable = currentNode.find('table.wikitable, table.article-table').first()
      if (foundTable.length > 0) {
        worthTable = foundTable
        break
      }
      currentNode = currentNode.next()
    }

    if (worthTable && worthTable.length > 0) {
      const tableData = extractTableFromRows(worthTable.find('tr'), $)
      if (tableData) {
        sections.push({
          type: "table",
          title: sectionTitle,
          ...tableData
        })
      }
    }
  })

  if (sections.length === 0) {
    const worthTable = contentArea.find('table.wikitable, table.article-table').first()
    if (worthTable.length > 0) {
      const tableData = extractTableFromRows(worthTable.find('tr'), $)
      if (tableData) {
        sections.push({
          type: "table",
          title: "Worth Details",
          ...tableData
        })
      }
    }
  }

  if (sections.length === 0) {
    sections.push({ type: "text", title: "Not Found", content: "Could not extract worth details from the page." })
  }
  return sections
}

module.exports = {
  searchForItems,
  getItemDetails
}
