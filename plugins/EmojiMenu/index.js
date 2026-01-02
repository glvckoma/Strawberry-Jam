class EmojiMenu {
  constructor() {
    this.initialized = false;
    this.emojiList = [];
    this.currentRoom = null;
    this.currentInternalRoomId = null;
    
    try {
      this.dispatch = window.jam?.dispatch;
    } catch (e) {
      console.error('[EmojiMenu] Failed to get dispatch:', e);
    }
    
    this.init();
  }

  init() {
    if (this.initialized) return;
    
    this.setupElements();

    this.loadEmojiData();
    
    this.setupEventListeners();

    window.resizeTo(300, 550);
    
    console.log('[EmojiMenu] Initialized');
    this.initialized = true;
  }

  setupElements() {
    this.emojiGrid = document.getElementById('emojiGrid');
    this.searchInput = document.getElementById('searchInput');
    if (!this.emojiGrid || !this.searchInput) {
      console.error('[EmojiMenu] Required elements not found');
    }
  }

  setupEventListeners() {
    if (this.searchInput) {
      this.searchInput.addEventListener('input', (e) => this.handleSearch(e));
    }
  }

  handleSearch(e) {
    const query = e.target.value.toLowerCase().trim();
    
    if (query === '') {
      this.renderEmojis(this.emojiList);
      return;
    }
    
    const filtered = this.emojiList.filter(emoji =>
      emoji.alias.toLowerCase().includes(query)
    );
    
    this.renderEmojis(filtered);
  }

  async loadEmojiData() {
    if (!this.emojiGrid) return;
    
    try {
      const response = await fetch('https://raw.githubusercontent.com/DrEmoji/AJPrivChat/main/Emojis/Alias.json');
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      
      const data = await response.json();
      
      this.emojiList = Object.entries(data).map(([alias, imageUrl]) => ({
        alias,
        imageUrl
      }));
      
      this.renderEmojis(this.emojiList);
    } catch (error) {
      console.error('[EmojiMenu] Failed to load emojis:', error);
    }
  }

  renderEmojis(emojisToShow = this.emojiList) {
    if (!this.emojiGrid) return;
    
    this.emojiGrid.innerHTML = '';
    
    emojisToShow.forEach(emoji => {
      const btn = document.createElement('button');
      btn.className = 'emoji-btn';
      btn.title = emoji.alias;
      
      const img = document.createElement('img');
      img.src = emoji.imageUrl;
      img.alt = emoji.alias;
      img.style.width = '100%';
      img.style.height = '100%';
      img.style.objectFit = 'contain';
      
      btn.appendChild(img);
      btn.addEventListener('click', () => this.sendEmoji(emoji.alias));
      
      this.emojiGrid.appendChild(btn);
    });
  }

  async refreshRoom() {
    try {
      const roomState = await this.dispatch?.getState('room');
      this.currentRoom = roomState?.name || null;
      
      const internalRoomId = await this.dispatch?.getState('internalRoomId');
      if (internalRoomId) {
        const parsed = parseInt(internalRoomId, 10);
        if (!isNaN(parsed)) {
          this.currentInternalRoomId = parsed;
        }
      }
    } catch (e) {
      console.error('[EmojiMenu] Failed to refresh room:', e);
    }
  }

  getRoomIdToUse() {
    return this.currentInternalRoomId || this.currentRoom;
  }

  async sendEmoji(alias) {
    try {
      await this.refreshRoom();
      const roomId = this.getRoomIdToUse();
      
      const packet = `<msg t="sys"><body action="pubMsg" r="${roomId}"><txt><![CDATA[pe:${alias}%3%0]]></txt></body></msg>`;
      
      if (this.dispatch?.sendRemoteMessage) {
        await this.dispatch.sendRemoteMessage(packet);
      }
    } catch (error) {
      console.error('[EmojiMenu] Failed to send emoji:', error);
    }
  }
}

window.emojiMenu = new EmojiMenu();
