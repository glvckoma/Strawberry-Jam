const axios = require('axios');
const cheerio = require('cheerio');
const url = require('url');

const BASE_URL = "https://aj-item-worth.fandom.com";
const SEARCH_PATH = "/wiki/Special:Search";
const REQUEST_TIMEOUT = 30000;

let puppeteerBrowser = null;
let puppeteerPage = null;

const ENHANCED_HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'Accept-Language': 'en-US,en;q=0.9',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'none',
    'Sec-Fetch-User': '?1',
    'Cache-Control': 'max-age=0',
    'DNT': '1',
    'Referer': BASE_URL
};

async function initPuppeteer() {
    if (puppeteerBrowser && puppeteerPage) {
        try {
            await puppeteerBrowser.version();
            return puppeteerPage;
        } catch (error) {
            if (puppeteerPage) {
                try {
                    await puppeteerPage.close();
                } catch (closeError) {
                }
            }
            if (puppeteerBrowser) {
                try {
                    await puppeteerBrowser.close();
                } catch (closeError) {
                }
            }
            puppeteerBrowser = null;
            puppeteerPage = null;
        }
    }

    let browser = null;
    let page = null;
    try {
        const puppeteer = require('puppeteer-extra');
        const StealthPlugin = require('puppeteer-extra-plugin-stealth');
        puppeteer.use(StealthPlugin());

        browser = await puppeteer.launch({
            headless: 'new',
            args: [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage',
                '--disable-accelerated-2d-canvas',
                '--disable-gpu',
                '--window-size=1920,1080'
            ]
        });

        page = await browser.newPage();
        await page.setViewport({ width: 1920, height: 1080 });
        await page.setUserAgent(ENHANCED_HEADERS['User-Agent']);
        await page.setExtraHTTPHeaders({
            'Accept-Language': ENHANCED_HEADERS['Accept-Language'],
            'Accept-Encoding': ENHANCED_HEADERS['Accept-Encoding']
        });

        puppeteerBrowser = browser;
        puppeteerPage = page;
        return page;
    } catch (error) {
        if (page) {
            try {
                await page.close();
            } catch (closeError) {
            }
        }
        if (browser) {
            try {
                await browser.close();
            } catch (closeError) {
            }
        }
        puppeteerBrowser = null;
        puppeteerPage = null;
        throw new Error(`Puppeteer initialization failed: ${error.message}`);
    }
}

async function fetchWithPuppeteer(targetUrl) {
    let page = null;
    try {
        page = await initPuppeteer();
        
        await page.goto(targetUrl, {
            waitUntil: 'domcontentloaded',
            timeout: REQUEST_TIMEOUT
        });
        
        if (targetUrl.includes('/Special:Search')) {
            try {
                await page.waitForSelector('ul.unified-search__results', { timeout: 10000 });
            } catch (selectorError) {
                await page.waitForTimeout(2000);
            }
        } else {
            await page.waitForTimeout(500);
        }
        
        const content = await page.content();
        return content;
    } catch (error) {
        if (page && page === puppeteerPage) {
            try {
                await page.close();
                puppeteerPage = null;
            } catch (closeError) {
            }
        }
        throw new Error(`Puppeteer fetch failed: ${error.message}`);
    }
}

async function fetchWithEnhancedAxios(targetUrl) {
    try {
        const axiosInstance = axios.create({
            timeout: REQUEST_TIMEOUT,
            maxRedirects: 5,
            validateStatus: (status) => status < 500
        });

        const response = await axiosInstance.get(targetUrl, {
            headers: ENHANCED_HEADERS,
            withCredentials: false
        });

        if (response.status === 403 || response.status === 429) {
            throw new Error(`Blocked by server (${response.status}). Try using puppeteer method.`);
        }

        if (response.status !== 200) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        return response.data;
    } catch (error) {
        if (error.response) {
            throw new Error(`HTTP ${error.response.status}: ${error.response.statusText}`);
        }
        throw new Error(`Network error: ${error.message}`);
    }
}

async function fetchPageContent(targetUrl) {
    try {
        return await fetchWithPuppeteer(targetUrl);
    } catch (puppeteerError) {
        try {
            return await fetchWithEnhancedAxios(targetUrl);
        } catch (axiosError) {
            throw new Error(`All scraping methods failed. Last error: ${axiosError.message}`);
        }
    }
}

function parseSearchResults(htmlContent) {
    const $ = cheerio.load(htmlContent);
    const results = [];
    const resultItems = $('ul.unified-search__results li.unified-search__result');
    
    resultItems.slice(0, 15).each((index, element) => {
        const linkTag = $(element).find('article h3.unified-search__result__header a.unified-search__result__title');
        const title = linkTag.text().trim();
        const relativeUrl = linkTag.attr('href');

        if (title && relativeUrl) {
            const absoluteUrl = url.resolve(BASE_URL, relativeUrl);
            results.push({ title: title, url: absoluteUrl });
        }
    });
    
    return results;
}

function extractWorthDetails(htmlContent, pageUrl) {
    const $ = cheerio.load(htmlContent);
    const sections = [];
    const contentArea = $('div.mw-parser-output');

    if (contentArea.length === 0) {
        sections.push({ type: "text", title: "Error", content: "Could not find main content area to parse." });
        return sections;
    }

    contentArea.find('h2').each((index, h2Element) => {
        const sectionTitle = $(h2Element).find('.mw-headline').text().trim();
        if (!sectionTitle) return;

        let worthTable = null;
        let currentNode = $(h2Element).next();
        while (currentNode.length > 0 && !currentNode.is('h2')) {
            if (currentNode.is('table.wikitable, table.article-table')) {
                worthTable = currentNode;
                break;
            }
            const foundTable = currentNode.find('table.wikitable, table.article-table').first();
            if (foundTable.length > 0) {
                worthTable = foundTable;
                break;
            }
            currentNode = currentNode.next();
        }

        if (worthTable && worthTable.length > 0) {
            const rows = worthTable.find('tr');
            let headers = [];
            let tableRowsData = [];
            let tableImageUrls = [];

            if (rows.length > 0) {
                const headerRow = rows.first();
                headers = headerRow.find('th, td').map((i, el) => $(el).text().trim()).get();
                const dataRowsTr = rows.slice(1);
                let imageRowIndex = -1;

                dataRowsTr.each((rowIndex, rowElement) => {
                    if ($(rowElement).find('img').length > 0) {
                        imageRowIndex = rowIndex;
                        const numColumns = headers.length > 0 ? headers.length : $(rowElement).find('td, th').length;
                        const imageCells = $(rowElement).find('td, th');
                        for (let i = 0; i < numColumns; i++) {
                            let cellImageUrl = null;
                            if (i < imageCells.length) {
                                const imgTag = $(imageCells[i]).find('img').first();
                                if (imgTag.length > 0) {
                                    cellImageUrl = imgTag.attr('data-src') || imgTag.attr('src');
                                    if (cellImageUrl && cellImageUrl.includes('/scale-to-width-down/')) {
                                        cellImageUrl = cellImageUrl.split('/scale-to-width-down/')[0];
                                    }
                                }
                            }
                            tableImageUrls.push(cellImageUrl);
                        }
                        return false;
                    }
                });

                dataRowsTr.each((rowIndex, rowElement) => {
                    if (rowIndex === imageRowIndex) return;
                    let rowCellsText = [];
                    $(rowElement).find('td, th').each((cellIndex, cellElement) => {
                        let cellText = $(cellElement).text().replace(/\s+/g, ' ').trim();
                        rowCellsText.push(cellText);
                    });
                    if (rowCellsText.some(text => text)) {
                        tableRowsData.push(rowCellsText);
                    }
                });
            }

            if (headers.length > 0 || tableRowsData.length > 0) {
                sections.push({
                    type: "table",
                    title: sectionTitle,
                    headers: headers,
                    rows: tableRowsData,
                    imageUrls: tableImageUrls
                });
            }
        }
    });

    if (sections.length === 0) {
        const worthTable = contentArea.find('table.wikitable, table.article-table').first();
        if (worthTable.length > 0) {
            const rows = worthTable.find('tr');
            let headers = [];
            let tableRowsData = [];
            let tableImageUrls = [];

            if (rows.length > 0) {
                const headerRow = rows.first();
                headers = headerRow.find('th, td').map((i, el) => $(el).text().trim()).get();
                const dataRowsTr = rows.slice(1);
                let imageRowIndex = -1;

                dataRowsTr.each((rowIndex, rowElement) => {
                    if ($(rowElement).find('img').length > 0) {
                        imageRowIndex = rowIndex;
                        const numColumns = headers.length > 0 ? headers.length : $(rowElement).find('td, th').length;
                        const imageCells = $(rowElement).find('td, th');
                        for (let i = 0; i < numColumns; i++) {
                            let cellImageUrl = null;
                            if (i < imageCells.length) {
                                const imgTag = $(imageCells[i]).find('img').first();
                                if (imgTag.length > 0) {
                                    cellImageUrl = imgTag.attr('data-src') || imgTag.attr('src');
                                    if (cellImageUrl && cellImageUrl.includes('/scale-to-width-down/')) {
                                        cellImageUrl = cellImageUrl.split('/scale-to-width-down/')[0];
                                    }
                                }
                            }
                            tableImageUrls.push(cellImageUrl);
                        }
                        return false;
                    }
                });

                dataRowsTr.each((rowIndex, rowElement) => {
                    if (rowIndex === imageRowIndex) return;
                    let rowCellsText = [];
                    $(rowElement).find('td, th').each((cellIndex, cellElement) => {
                        let cellText = $(cellElement).text().replace(/\s+/g, ' ').trim();
                        rowCellsText.push(cellText);
                    });
                    if (rowCellsText.some(text => text)) {
                        tableRowsData.push(rowCellsText);
                    }
                });
            }

            if (headers.length > 0 || tableRowsData.length > 0) {
                sections.push({
                    type: "table",
                    title: "Worth Details",
                    headers: headers,
                    rows: tableRowsData,
                    imageUrls: tableImageUrls
                });
            }
        }
    }

    if (sections.length === 0) {
        sections.push({ type: "text", title: "Not Found", content: "Could not extract specific worth details from the page structure." });
    }
    return sections;
}

async function searchForItems(searchTerm) {
    const searchUrl = `${BASE_URL}${SEARCH_PATH}?query=${encodeURIComponent(searchTerm)}&scope=internal&navigationSearch=true`;
    
    try {
        const htmlContent = await fetchPageContent(searchUrl);
        const results = parseSearchResults(htmlContent);
        return results;
    } catch (error) {
        throw error;
    }
}

async function getItemDetails(pageUrl) {
    if (!pageUrl || !pageUrl.startsWith(BASE_URL)) {
        throw new Error(`Invalid page URL provided.`);
    }
    const htmlContent = await fetchPageContent(pageUrl);
    const sections = extractWorthDetails(htmlContent, pageUrl);
    return { sections: sections, source_url: pageUrl };
}

process.on('exit', () => {
    if (puppeteerBrowser) {
        puppeteerBrowser.close().catch(() => {});
    }
});

module.exports = {
  searchForItems,
  getItemDetails
};
