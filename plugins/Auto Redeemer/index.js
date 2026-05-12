class AutoRedeemer {
    constructor() {
        this.codes = []
        this.currentIndex = 0
        this.isRunning = false
        this.isPaused = false
        this.roomId = null
        this.pendingResolve = null
        this.timeoutTimer = null

        this.dispatch = null
        this.isInlineFrame = window.parent !== window

        this.startBtn = document.getElementById('startBtn')
        this.pauseBtn = document.getElementById('pauseBtn')
        this.stopBtn = document.getElementById('stopBtn')
        this.delayInput = document.getElementById('delayInput')
        this.fileInput = document.getElementById('fileInput')
        this.loadFileBtn = document.getElementById('loadFileBtn')
        this.codeTextarea = document.getElementById('codeTextarea')
        this.codeCount = document.getElementById('codeCount')
        this.statusIcon = document.getElementById('statusIcon')
        this.statusMessage = document.getElementById('statusMessage')
        this.progressText = document.getElementById('progressText')
        this.progressBar = document.getElementById('progressBar')
        this.codeList = document.getElementById('codeList')
        this.emptyListMsg = document.getElementById('emptyListMsg')
        this.clearResultsBtn = document.getElementById('clearResultsBtn')
        this.statTotal = document.getElementById('statTotal')
        this.statSuccess = document.getElementById('statSuccess')
        this.statInvalid = document.getElementById('statInvalid')

        this.setupBridge()
        this.setupEventListeners()
        this.setupPacketListener()
    }

    setupBridge() {
        const waitForJam = () => {
            if (window.jam && window.jam.dispatch) {
                this.dispatch = window.jam.dispatch
                return
            }
            setTimeout(waitForJam, 100)
        }

        if (window.jam && window.jam.dispatch) {
            this.dispatch = window.jam.dispatch
        } else {
            window.addEventListener('jam-ready', () => {
                if (window.jam && window.jam.dispatch) {
                    this.dispatch = window.jam.dispatch
                }
            })
            waitForJam()
        }
    }

    setupEventListeners() {
        this.loadFileBtn.addEventListener('click', () => this.fileInput.click())
        this.fileInput.addEventListener('change', (e) => this.handleFileSelect(e))
        this.startBtn.addEventListener('click', () => this.handleStartClick())
        this.pauseBtn.addEventListener('click', () => this.handlePauseClick())
        this.stopBtn.addEventListener('click', () => this.stop())
        this.clearResultsBtn.addEventListener('click', () => this.clearResults())
        this.codeTextarea.addEventListener('input', () => this.parseTextarea())
    }

    setupPacketListener() {
        const handler = (packetData) => {
            if (!packetData || typeof packetData !== 'string') return
            if (!packetData.includes('%xt%grc%')) return
            this.handleGrcResponse(packetData)
        }

        if (this.isInlineFrame) {
            window.parent.addEventListener('jam-packet', (e) => {
                handler(e.detail)
            })
        }

        try {
            const { ipcRenderer } = require('electron')
            if (!this.isInlineFrame) {
                ipcRenderer.on('packet-event', (event, data) => {
                    handler(data)
                })
            }
            ipcRenderer.on('connection-status-changed', (event, isConnected) => {
                if (!isConnected && this.isRunning) {
                    this.stop()
                    this.setStatus('error', 'Disconnected from game')
                    this.showToast('Lost connection to game, stopping', 'error')
                }
            })
        } catch (e) {}
    }

    handleGrcResponse(packet) {
        if (!this.pendingResolve) return

        const parts = packet.split('%').filter(p => p !== '')
        const resolve = this.pendingResolve
        this.pendingResolve = null

        if (this.timeoutTimer) {
            clearTimeout(this.timeoutTimer)
            this.timeoutTimer = null
        }

        const status = this.classifyResponse(parts)
        resolve(status)
    }

    classifyResponse(parts) {
        const statusField1 = parts[2] || ''
        const statusField2 = parts[3] || ''
        const statusCode = parts[5] || ''

        if (statusField1 === '-1' && statusField2 === '-1' && statusCode === '0') {
            return 'invalid'
        }

        if (statusCode === '0' || statusField1 === '-1') {
            return 'invalid'
        }

        if (statusCode === '2' || statusCode === '3') {
            return 'already_redeemed'
        }

        return 'success'
    }

    handleFileSelect(e) {
        const file = e.target.files[0]
        if (!file) return
        const reader = new FileReader()
        reader.onload = (ev) => {
            const existing = this.codeTextarea.value.trim()
            this.codeTextarea.value = existing
                ? existing + '\n' + ev.target.result
                : ev.target.result
            this.parseTextarea()
            this.showToast(`Loaded codes from ${file.name}`, 'success')
        }
        reader.onerror = () => this.showToast('Failed to read file', 'error')
        reader.readAsText(file)
        this.fileInput.value = ''
    }

    parseTextarea() {
        const lines = this.codeTextarea.value.split(/\r?\n/)
            .map(l => l.trim())
            .filter(l => l.length > 0)

        this.codes = lines.map(code => ({ code, status: 'pending' }))
        this.currentIndex = 0
        this.codeCount.textContent = this.codes.length

        this.renderCodeList()
        this.updateStats()
        this.updateProgress()
        this.updateButtonStates()
    }

    renderCodeList() {
        this.codeList.innerHTML = ''

        if (this.codes.length === 0) {
            this.codeList.innerHTML = '<p class="text-xs text-text-secondary text-center py-4">No codes loaded</p>'
            return
        }

        this.codes.forEach((entry, i) => {
            const row = document.createElement('div')
            row.className = `code-row${entry.status === 'processing' ? ' processing' : ''}`
            row.id = `code-row-${i}`
            row.innerHTML = `<span class="code-index">${i + 1}.</span>` +
                `<span class="code-text">${this.escapeHtml(entry.code)}</span>` +
                `<span class="code-status status-${entry.status}">${this.statusLabel(entry.status)}</span>`
            this.codeList.appendChild(row)
        })
    }

    updateCodeRow(index) {
        const row = document.getElementById(`code-row-${index}`)
        if (!row) return
        const entry = this.codes[index]
        row.className = `code-row${entry.status === 'processing' ? ' processing' : ''}`
        const statusEl = row.querySelector('.code-status')
        statusEl.className = `code-status status-${entry.status}`
        statusEl.textContent = this.statusLabel(entry.status)
    }

    scrollToCode(index) {
        const row = document.getElementById(`code-row-${index}`)
        if (row) {
            row.scrollIntoView({ behavior: 'smooth', block: 'nearest' })
        }
    }

    statusLabel(status) {
        const labels = {
            pending: 'Pending',
            processing: 'Sending...',
            success: 'Success',
            invalid: 'Invalid',
            already_redeemed: 'Already Used',
            timeout: 'Timeout'
        }
        return labels[status] || status
    }

    updateStats() {
        let success = 0, invalid = 0
        for (const entry of this.codes) {
            if (entry.status === 'success') success++
            else if (entry.status === 'invalid' || entry.status === 'already_redeemed' || entry.status === 'timeout') invalid++
        }
        this.statTotal.textContent = this.codes.length
        this.statSuccess.textContent = success
        this.statInvalid.textContent = invalid
    }

    updateProgress() {
        const processed = this.codes.filter(c =>
            c.status !== 'pending' && c.status !== 'processing'
        ).length
        const total = this.codes.length
        this.progressText.textContent = `${processed} / ${total}`
        const pct = total > 0 ? (processed / total) * 100 : 0
        this.progressBar.style.width = `${pct}%`
    }

    updateButtonStates() {
        const hasCodes = this.codes.length > 0
        const hasUnprocessed = this.codes.some(c => c.status === 'pending')

        if (this.isRunning) {
            this.startBtn.disabled = true
            this.pauseBtn.disabled = false
            this.stopBtn.disabled = false
            this.loadFileBtn.disabled = true
            this.codeTextarea.disabled = true
            this.delayInput.disabled = true
        } else if (this.isPaused) {
            this.startBtn.disabled = false
            this.startBtn.innerHTML = '<i class="fas fa-play mr-1"></i>Resume'
            this.pauseBtn.disabled = true
            this.stopBtn.disabled = false
            this.loadFileBtn.disabled = true
            this.codeTextarea.disabled = true
            this.delayInput.disabled = false
        } else {
            this.startBtn.disabled = !(hasCodes && hasUnprocessed)
            this.startBtn.innerHTML = '<i class="fas fa-play mr-1"></i>Start'
            this.pauseBtn.disabled = true
            this.stopBtn.disabled = true
            this.loadFileBtn.disabled = false
            this.codeTextarea.disabled = false
            this.delayInput.disabled = false
        }
    }

    setStatus(type, message) {
        this.statusMessage.textContent = message
        const icons = {
            idle: '<i class="fas fa-circle text-gray-400"></i> Idle',
            running: '<i class="fas fa-circle text-green-400"></i> Running',
            paused: '<i class="fas fa-circle text-yellow-400"></i> Paused',
            complete: '<i class="fas fa-check-circle text-green-400"></i> Complete',
            error: '<i class="fas fa-exclamation-circle text-red-400"></i> Error'
        }
        this.statusIcon.innerHTML = icons[type] || icons.idle
    }

    async handleStartClick() {
        if (this.isPaused) {
            this.resume()
            return
        }
        await this.start()
    }

    async start() {
        if (!this.dispatch) {
            this.showToast('Plugin bridge not ready, try again', 'error')
            return
        }

        try {
            const internalId = await this.dispatch.getState('internalRoomId')
            if (internalId !== null && internalId !== undefined) {
                const parsed = parseInt(internalId, 10)
                if (!isNaN(parsed)) this.roomId = parsed
            }
        } catch (e) {
            this.showToast('Failed to get room ID', 'error')
            return
        }

        if (!this.roomId) {
            this.showToast('Cannot send: not in a room', 'error')
            return
        }

        const firstPending = this.codes.findIndex(c => c.status === 'pending')
        if (firstPending === -1) {
            this.showToast('No pending codes to process', 'error')
            return
        }
        this.currentIndex = firstPending

        this.isRunning = true
        this.isPaused = false
        this.updateButtonStates()
        this.setStatus('running', 'Processing codes...')

        this.processLoop()
    }

    async processLoop() {
        while (this.isRunning && !this.isPaused && this.currentIndex < this.codes.length) {
            const entry = this.codes[this.currentIndex]

            if (entry.status !== 'pending') {
                this.currentIndex++
                continue
            }

            entry.status = 'processing'
            this.updateCodeRow(this.currentIndex)
            this.scrollToCode(this.currentIndex)
            this.setStatus('running', `Sending code ${this.currentIndex + 1}/${this.codes.length}: ${entry.code}`)

            const packet = `%xt%o%grc%${this.roomId}%${entry.code}%%%`
            const result = await this.sendAndWaitForResponse(packet)

            if (!this.isRunning) break

            entry.status = result
            this.updateCodeRow(this.currentIndex)
            this.updateStats()
            this.updateProgress()

            this.currentIndex++

            if (this.isRunning && !this.isPaused && this.currentIndex < this.codes.length) {
                const nextPending = this.codes.slice(this.currentIndex).findIndex(c => c.status === 'pending')
                if (nextPending === -1) break

                const delay = parseInt(this.delayInput.value) || 1500
                this.setStatus('running', `Waiting ${delay}ms before next code...`)
                await this.sleep(delay)
            }
        }

        if (this.isRunning && !this.isPaused) {
            this.isRunning = false
            this.setStatus('complete', 'All codes processed')
            this.showToast('Finished processing all codes', 'success')
            this.updateButtonStates()
        }
    }

    sendAndWaitForResponse(packet) {
        return new Promise((resolve) => {
            this.pendingResolve = resolve
            this.timeoutTimer = setTimeout(() => {
                if (this.pendingResolve === resolve) {
                    this.pendingResolve = null
                    resolve('timeout')
                }
            }, 5000)

            try {
                this.dispatch.sendRemoteMessage(packet)
            } catch (e) {
                clearTimeout(this.timeoutTimer)
                this.timeoutTimer = null
                this.pendingResolve = null
                resolve('invalid')
            }
        })
    }

    handlePauseClick() {
        if (this.isRunning && !this.isPaused) {
            this.pause()
        }
    }

    pause() {
        this.isPaused = true
        this.isRunning = false
        this.setStatus('paused', `Paused at code ${this.currentIndex + 1}/${this.codes.length}`)
        this.updateButtonStates()
        this.showToast('Paused', 'info')
    }

    resume() {
        this.isPaused = false
        this.isRunning = true
        this.updateButtonStates()
        this.setStatus('running', 'Resuming...')
        this.showToast('Resumed', 'info')
        this.processLoop()
    }

    stop() {
        this.isRunning = false
        this.isPaused = false

        if (this.pendingResolve) {
            this.pendingResolve('timeout')
            this.pendingResolve = null
        }
        if (this.timeoutTimer) {
            clearTimeout(this.timeoutTimer)
            this.timeoutTimer = null
        }

        const processingEntry = this.codes.find(c => c.status === 'processing')
        if (processingEntry) {
            processingEntry.status = 'pending'
            const idx = this.codes.indexOf(processingEntry)
            this.updateCodeRow(idx)
        }

        this.setStatus('idle', 'Stopped by user')
        this.updateButtonStates()
        this.updateStats()
        this.showToast('Stopped', 'info')
    }

    clearResults() {
        if (this.isRunning || this.isPaused) {
            this.showToast('Stop processing first', 'error')
            return
        }
        this.codes.forEach(entry => { entry.status = 'pending' })
        this.currentIndex = 0
        this.renderCodeList()
        this.updateStats()
        this.updateProgress()
        this.updateButtonStates()
        this.setStatus('idle', 'Results cleared')
    }

    showToast(message, type) {
        if (window.jam && window.jam.showToast) {
            window.jam.showToast(message, type)
        }
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms))
    }

    escapeHtml(str) {
        const div = document.createElement('div')
        div.textContent = str
        return div.innerHTML
    }
}

window.autoRedeemer = new AutoRedeemer()
