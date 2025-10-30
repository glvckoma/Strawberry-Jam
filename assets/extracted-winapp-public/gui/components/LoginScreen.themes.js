(() => {
  const FRUIT_THEMES = {
        'strawberry.png': { primary: '#e83d52', secondary: 'rgba(232, 61, 82, 0.3)', highlight: 'rgba(255, 220, 220, 0.3)', shadow: 'rgba(252, 93, 93, 0.1)', gradientStart: 'rgba(255, 220, 220, 0.3)', gradientEnd: 'rgba(255, 245, 230, 0.6)', hoverBorder: 'rgba(232, 61, 82, 0.5)', radial1: 'rgba(255, 180, 180, 0.05)', radial2: 'rgba(255, 200, 200, 0.07)', settingsHover: 'rgba(232, 61, 82, 0.05)', settingsBorder: 'rgba(232, 61, 82, 0.2)' },
        'banana.png': { primary: '#FFDA03', secondary: 'rgba(255, 218, 3, 0.3)', highlight: 'rgba(255, 248, 220, 0.3)', shadow: 'rgba(255, 218, 3, 0.1)', gradientStart: 'rgba(255, 248, 220, 0.3)', gradientEnd: 'rgba(255, 250, 235, 0.6)', hoverBorder: 'rgba(255, 218, 3, 0.5)', radial1: 'rgba(255, 230, 100, 0.05)', radial2: 'rgba(255, 240, 150, 0.07)', settingsHover: 'rgba(255, 218, 3, 0.05)', settingsBorder: 'rgba(255, 218, 3, 0.2)' },
        'blueberry.png': { primary: '#4682B4', secondary: 'rgba(70, 130, 180, 0.3)', highlight: 'rgba(173, 216, 230, 0.3)', shadow: 'rgba(70, 130, 180, 0.1)', gradientStart: 'rgba(173, 216, 230, 0.3)', gradientEnd: 'rgba(220, 235, 245, 0.6)', hoverBorder: 'rgba(70, 130, 180, 0.5)', radial1: 'rgba(100, 150, 200, 0.05)', radial2: 'rgba(120, 170, 220, 0.07)', settingsHover: 'rgba(70, 130, 180, 0.05)', settingsBorder: 'rgba(70, 130, 180, 0.2)' },
        'cantaloupe.png': { primary: '#FFA07A', secondary: 'rgba(255, 160, 122, 0.3)', highlight: 'rgba(255, 228, 196, 0.3)', shadow: 'rgba(255, 160, 122, 0.1)', gradientStart: 'rgba(255, 228, 196, 0.3)', gradientEnd: 'rgba(255, 245, 230, 0.6)', hoverBorder: 'rgba(255, 160, 122, 0.5)', radial1: 'rgba(255, 180, 150, 0.05)', radial2: 'rgba(255, 200, 170, 0.07)', settingsHover: 'rgba(255, 160, 122, 0.05)', settingsBorder: 'rgba(255, 160, 122, 0.2)' },
        'coconut.png': { primary: '#A0522D', secondary: 'rgba(160, 82, 45, 0.3)', highlight: 'rgba(210, 180, 140, 0.3)', shadow: 'rgba(160, 82, 45, 0.1)', gradientStart: 'rgba(210, 180, 140, 0.3)', gradientEnd: 'rgba(245, 222, 179, 0.6)', hoverBorder: 'rgba(160, 82, 45, 0.5)', radial1: 'rgba(180, 120, 80, 0.05)', radial2: 'rgba(200, 140, 100, 0.07)', settingsHover: 'rgba(160, 82, 45, 0.05)', settingsBorder: 'rgba(160, 82, 45, 0.2)' },
        'dragonfruit.png': { primary: '#E91E63', secondary: 'rgba(233, 30, 99, 0.3)', highlight: 'rgba(248, 187, 208, 0.3)', shadow: 'rgba(233, 30, 99, 0.1)', gradientStart: 'rgba(248, 187, 208, 0.3)', gradientEnd: 'rgba(252, 228, 236, 0.6)', hoverBorder: 'rgba(233, 30, 99, 0.5)', radial1: 'rgba(244, 143, 177, 0.05)', radial2: 'rgba(244, 143, 177, 0.07)', settingsHover: 'rgba(233, 30, 99, 0.05)', settingsBorder: 'rgba(233, 30, 99, 0.2)' },
        'pineapple.png': { primary: '#FFEC8B', secondary: 'rgba(255, 236, 139, 0.3)', highlight: 'rgba(255, 250, 205, 0.3)', shadow: 'rgba(255, 236, 139, 0.1)', gradientStart: 'rgba(255, 250, 205, 0.3)', gradientEnd: 'rgba(255, 255, 224, 0.6)', hoverBorder: 'rgba(255, 236, 139, 0.5)', radial1: 'rgba(255, 240, 160, 0.05)', radial2: 'rgba(255, 245, 180, 0.07)', settingsHover: 'rgba(255, 236, 139, 0.05)', settingsBorder: 'rgba(255, 236, 139, 0.2)' },
      };
  const DEFAULT_FRUIT = 'strawberry.png';

  function cloneThemes() {
    const clone = {};
    for (const [fruit, theme] of Object.entries(FRUIT_THEMES)) {
      clone[fruit] = { ...theme };
    }
    return clone;
  }

  window.LoginScreenThemes = {
    getThemes: cloneThemes,
    getDefaultFruit: () => DEFAULT_FRUIT,
    getFruitImages: () => Object.keys(FRUIT_THEMES)
  };
})();
