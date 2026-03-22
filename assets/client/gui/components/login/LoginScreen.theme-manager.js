"use strict";

(() => {
  const { isLightColor, darkenColor, hexToCssFilter, normalizeHexColor } = window.LoginScreenUtilities || window;

  window.LoginScreenThemeManager = class {
    constructor(loginScreenInstance) {
      this.loginScreen = loginScreenInstance;
    }

    async applyCustomColorTheme(customColor, customName, customFruit) {
      if (!customColor) return false;
      
      const normalizedColor = normalizeHexColor(customColor);
      if (!normalizedColor) return false;
      
      if (!customName && window.ipc) {
        customName = await window.ipc.invoke('get-setting', 'ui.customThemeName').catch(() => 'Custom Jam');
      }
      customName = customName || 'Custom Jam';
      
      if (!customFruit && window.ipc) {
        customFruit = await window.ipc.invoke('get-setting', 'ui.customThemeFruit').catch(() => 'strawberry.png');
      }
      customFruit = customFruit || 'strawberry.png';
      
      const loginAppIconElem = this.loginScreen.loginAppIconElem;
      if (loginAppIconElem) {
        loginAppIconElem.src = `images/${customFruit}`;
        const filter = hexToCssFilter(normalizedColor);
        loginAppIconElem.style.filter = filter;
      }
      
      const root = this.loginScreen.shadowRoot.host;
      const primaryIsLight = isLightColor(normalizedColor);
      
      const r = parseInt(normalizedColor.slice(1, 3), 16);
      const g = parseInt(normalizedColor.slice(3, 5), 16);
      const b = parseInt(normalizedColor.slice(5, 7), 16);
      
      root.style.setProperty('--theme-primary', normalizedColor);
      root.style.setProperty('--theme-secondary', `rgba(${r}, ${g}, ${b}, 0.3)`);
      root.style.setProperty('--theme-highlight', `rgba(${Math.min(255, r + 30)}, ${Math.min(255, g + 30)}, ${Math.min(255, b + 30)}, 0.3)`);
      root.style.setProperty('--theme-shadow', `rgba(${r}, ${g}, ${b}, 0.1)`);
      root.style.setProperty('--theme-gradient-start', `rgba(${Math.min(255, r + 30)}, ${Math.min(255, g + 30)}, ${Math.min(255, b + 30)}, 0.3)`);
      root.style.setProperty('--theme-gradient-end', `rgba(255, 245, 230, 0.6)`);
      root.style.setProperty('--theme-hover-border', `rgba(${r}, ${g}, ${b}, 0.5)`);
      root.style.setProperty('--theme-radial-1', `rgba(${r}, ${g}, ${b}, 0.05)`);
      root.style.setProperty('--theme-radial-2', `rgba(${r}, ${g}, ${b}, 0.07)`);
      root.style.setProperty('--theme-settings-hover', `rgba(${r}, ${g}, ${b}, 0.05)`);
      root.style.setProperty('--theme-settings-border', `rgba(${r}, ${g}, ${b}, 0.2)`);
      
      if (this.loginScreen.playerLoginTextElem) {
        this.loginScreen.playerLoginTextElem.innerText = customName;
      }
      
      if (primaryIsLight) {
        root.style.setProperty('--theme-box-background', 'rgba(225, 210, 180, 0.97)');
        root.style.setProperty('--theme-text-shadow', '0 1px 1px rgba(0, 0, 0, 0.5)');
        root.style.setProperty('--theme-border-enhancement', '1px solid rgba(0, 0, 0, 0.2)');
        const playerLoginText = this.loginScreen.shadowRoot.getElementById('player-login-text');
        if (playerLoginText) {
          playerLoginText.style.textShadow = '0 1px 1px rgba(0, 0, 0, 0.5)';
          playerLoginText.style.webkitTextStroke = '0.5px rgba(0, 0, 0, 0.5)';
        }
      } else {
        root.style.setProperty('--theme-box-background', 'rgba(255, 245, 230, 0.95)');
        root.style.setProperty('--theme-text-shadow', 'none');
        root.style.setProperty('--theme-border-enhancement', 'none');
        const playerLoginText = this.loginScreen.shadowRoot.getElementById('player-login-text');
        if (playerLoginText) {
          playerLoginText.style.textShadow = `1px 2px 0px rgba(${r}, ${g}, ${b}, 0.1)`;
        }
      }
      
      const buttonBg = primaryIsLight ? darkenColor(normalizedColor, 20) : normalizedColor;
      root.style.setProperty('--theme-button-bg', buttonBg);
      root.style.setProperty('--theme-button-border', primaryIsLight ? 'rgba(0, 0, 0, 0.3)' : `rgba(${r}, ${g}, ${b}, 0.3)`);
      root.style.setProperty('--theme-button-text', primaryIsLight ? '#333333' : '#FFFFFF');
      
      const loginBtn = this.loginScreen.shadowRoot.getElementById('log-in-btn');
      const createAccountBtn = this.loginScreen.shadowRoot.getElementById('create-account-btn');
      
      if (loginBtn) {
        loginBtn.style.setProperty('--ajd-bubble-button-background-color', buttonBg);
        loginBtn.style.setProperty('--ajd-bubble-button-border-color', primaryIsLight ? 'rgba(0, 0, 0, 0.3)' : `rgba(${r}, ${g}, ${b}, 0.3)`);
        loginBtn.style.setProperty('--ajd-bubble-button-text-color', primaryIsLight ? '#333333' : '#FFFFFF');
        loginBtn.style.setProperty('--ajd-bubble-button-background-color-hover', primaryIsLight ? darkenColor(buttonBg, 10) : darkenColor(buttonBg, -15));
        loginBtn.style.setProperty('--ajd-bubble-button-background-color-active', buttonBg);
      }
      
      if (createAccountBtn) {
        createAccountBtn.style.setProperty('--ajd-bubble-button-background-color', buttonBg);
        createAccountBtn.style.setProperty('--ajd-bubble-button-border-color', primaryIsLight ? 'rgba(0, 0, 0, 0.3)' : `rgba(${r}, ${g}, ${b}, 0.3)`);
        createAccountBtn.style.setProperty('--ajd-bubble-button-text-color', primaryIsLight ? '#333333' : '#FFFFFF');
        createAccountBtn.style.setProperty('--ajd-bubble-button-background-color-hover', primaryIsLight ? darkenColor(buttonBg, 10) : darkenColor(buttonBg, -15));
        createAccountBtn.style.setProperty('--ajd-bubble-button-background-color-active', buttonBg);
      }
      
      return true;
    }

    setupFruitRotation() {
      const loginAppIconElem = this.loginScreen.loginAppIconElem;
      if (!loginAppIconElem) return;

      loginAppIconElem.style.cursor = 'pointer';
      loginAppIconElem.addEventListener('click', async () => {
        if (window.ipc) {
          const customEnabled = await window.ipc.invoke('get-setting', 'ui.customThemeEnabled').catch(() => false);
          if (customEnabled === true) {
            return;
          }
        }
        
        this.loginScreen._currentFruitIndex = (this.loginScreen._currentFruitIndex + 1) % this.loginScreen._fruitImages.length;
        const nextFruitKey = this.loginScreen._fruitImages[this.loginScreen._currentFruitIndex];
        
        loginAppIconElem.src = `images/${nextFruitKey}`;
        loginAppIconElem.style.filter = 'none';
        this.applyTheme(nextFruitKey);

        if (window.ipc) {
          window.ipc.invoke('set-setting', 'fruitTheme', nextFruitKey)
            .catch(err => {});
        }

        loginAppIconElem.classList.remove('fruit-animate'); 
        void loginAppIconElem.offsetWidth; 
        loginAppIconElem.classList.add('fruit-animate'); 

        setTimeout(() => {
          if (loginAppIconElem) { 
            loginAppIconElem.classList.remove('fruit-animate');
          }
        }, 300); 
      });
    }

    applyTheme(fruitKey) {
      const theme = this.loginScreen._fruitThemes[fruitKey];
      if (!theme) {
        return;
      }
      const root = this.loginScreen.shadowRoot.host;

      let fruitName = fruitKey.replace('.png', '');
      if (fruitName === 'blueberries') {
        fruitName = 'blueberry';
      }
      const displayName = fruitName.charAt(0).toUpperCase() + fruitName.slice(1) + ' Jam';

      if (this.loginScreen.playerLoginTextElem) {
        this.loginScreen.playerLoginTextElem.innerText = displayName;
      }
      
      const primaryIsLight = isLightColor(theme.primary);

      root.style.setProperty('--theme-primary', theme.primary);
      root.style.setProperty('--theme-secondary', theme.secondary);
      root.style.setProperty('--theme-highlight', theme.highlight);
      root.style.setProperty('--theme-shadow', theme.shadow);
      root.style.setProperty('--theme-gradient-start', theme.gradientStart);
      root.style.setProperty('--theme-gradient-end', theme.gradientEnd);
      root.style.setProperty('--theme-hover-border', theme.hoverBorder);
      root.style.setProperty('--theme-radial-1', theme.radial1);
      root.style.setProperty('--theme-radial-2', theme.radial2);
      root.style.setProperty('--theme-settings-hover', theme.settingsHover);
      root.style.setProperty('--theme-settings-border', theme.settingsBorder);

      if (primaryIsLight && (fruitKey === 'banana.png' || fruitKey === 'pineapple.png')) {
        root.style.setProperty('--theme-box-background', 'rgba(225, 210, 180, 0.97)');
        root.style.setProperty('--theme-text-shadow', '0 1px 1px rgba(0, 0, 0, 0.5)');
        root.style.setProperty('--theme-border-enhancement', '1px solid rgba(0, 0, 0, 0.2)');
        const playerLoginText = this.loginScreen.shadowRoot.getElementById('player-login-text');
        if (playerLoginText) {
          playerLoginText.style.textShadow = '0 1px 1px rgba(0, 0, 0, 0.5)';
          playerLoginText.style.webkitTextStroke = '0.5px rgba(0, 0, 0, 0.5)';
        }
        const settingsHeadings = this.loginScreen.shadowRoot.querySelectorAll('#settings-panel h3, #tester-info-modal .modal-header h3');
        settingsHeadings.forEach(heading => {
          heading.style.textShadow = '0 1px 1px rgba(0, 0, 0, 0.5)';
          heading.style.webkitTextStroke = '0.5px rgba(0, 0, 0, 0.5)';
        });
        root.style.setProperty('--standard-text-shadow', 'none');
      } else {
        root.style.setProperty('--theme-box-background', 'rgba(255, 245, 230, 0.95)');
        root.style.setProperty('--theme-text-shadow', 'none');
        root.style.setProperty('--theme-border-enhancement', 'none');
        root.style.setProperty('--standard-text-shadow', 'none');
        const playerLoginText = this.loginScreen.shadowRoot.getElementById('player-login-text');
        if (playerLoginText) {
          playerLoginText.style.textShadow = '1px 2px 0px var(--theme-shadow)';
        }
        const settingsHeadings = this.loginScreen.shadowRoot.querySelectorAll('#settings-panel h3, #tester-info-modal .modal-header h3');
        settingsHeadings.forEach(heading => {
          heading.style.textShadow = '1px 1px 0px var(--theme-shadow)';
        });
      }

      const buttonBg = primaryIsLight ? darkenColor(theme.primary, 20) : theme.primary;
      root.style.setProperty('--theme-button-bg', buttonBg);
      root.style.setProperty('--theme-button-border', primaryIsLight ? 'rgba(0, 0, 0, 0.3)' : theme.secondary);
      root.style.setProperty('--theme-button-text', primaryIsLight ? '#333333' : '#FFFFFF');
      
      const loginBtn = this.loginScreen.shadowRoot.getElementById('log-in-btn');
      const createAccountBtn = this.loginScreen.shadowRoot.getElementById('create-account-btn');
      
      if (loginBtn) {
        loginBtn.style.setProperty('--ajd-bubble-button-background-color', buttonBg);
        loginBtn.style.setProperty('--ajd-bubble-button-border-color', primaryIsLight ? 'rgba(0, 0, 0, 0.3)' : theme.secondary);
        loginBtn.style.setProperty('--ajd-bubble-button-text-color', primaryIsLight ? '#333333' : '#FFFFFF');
        loginBtn.style.setProperty('--ajd-bubble-button-background-color-hover', primaryIsLight ? darkenColor(buttonBg, 10) : darkenColor(buttonBg, -15));
        loginBtn.style.setProperty('--ajd-bubble-button-background-color-active', buttonBg);
        if (primaryIsLight && (fruitKey === 'banana.png' || fruitKey === 'pineapple.png')) {
          loginBtn.style.boxShadow = '0 0 0 1px rgba(0, 0, 0, 0.3)';
        } else {
          loginBtn.style.boxShadow = '';
        }
      }
      
      if (createAccountBtn) {
        createAccountBtn.style.setProperty('--ajd-bubble-button-background-color', buttonBg);
        createAccountBtn.style.setProperty('--ajd-bubble-button-border-color', primaryIsLight ? 'rgba(0, 0, 0, 0.3)' : theme.secondary);
        createAccountBtn.style.setProperty('--ajd-bubble-button-text-color', primaryIsLight ? '#333333' : '#FFFFFF');
        createAccountBtn.style.setProperty('--ajd-bubble-button-background-color-hover', primaryIsLight ? darkenColor(buttonBg, 10) : darkenColor(buttonBg, -15));
        createAccountBtn.style.setProperty('--ajd-bubble-button-background-color-active', buttonBg);
        if (primaryIsLight && (fruitKey === 'banana.png' || fruitKey === 'pineapple.png')) {
          createAccountBtn.style.boxShadow = '0 0 0 1px rgba(0, 0, 0, 0.3)';
        } else {
          createAccountBtn.style.boxShadow = '';
        }
      }

      if (this.loginScreen.accountPanelInstance && typeof this.loginScreen.accountPanelInstance.updateTheme === 'function') {
        this.loginScreen.accountPanelInstance.updateTheme(fruitKey);
      }
      if (window.UserTrayManager && window.UserTrayManager.instance && typeof window.UserTrayManager.instance.updateTheme === 'function') {
        window.UserTrayManager.instance.updateTheme(theme);
      }
      if (this.loginScreen.importButtonInstance && typeof this.loginScreen.importButtonInstance.updateTheme === 'function') {
        this.loginScreen.importButtonInstance.updateTheme(fruitKey);
      }
      if (this.loginScreen.autoWheelButtonInstance && typeof this.loginScreen.autoWheelButtonInstance.updateTheme === 'function') {
        this.loginScreen.autoWheelButtonInstance.updateTheme(fruitKey);
      }
    }
  };
})();

