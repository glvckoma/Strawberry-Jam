function hexToRgb(hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16)
  } : null;
}

function rgbToHsl(r, g, b) {
  r /= 255;
  g /= 255;
  b /= 255;
  
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  let h, s, l = (max + min) / 2;
  
  if (max === min) {
    h = s = 0;
  } else {
    const d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    
    switch (max) {
      case r: h = ((g - b) / d + (g < b ? 6 : 0)) / 6; break;
      case g: h = ((b - r) / d + 2) / 6; break;
      case b: h = ((r - g) / d + 4) / 6; break;
    }
  }
  
  return { h: h * 360, s: s * 100, l: l * 100 };
}

function hexToHsl(hex) {
  const rgb = hexToRgb(hex);
  if (!rgb) return null;
  return rgbToHsl(rgb.r, rgb.g, rgb.b);
}

function hexToCssFilter(hexColor, baseColor = '#e83d52') {
  const targetHsl = hexToHsl(hexColor);
  const baseHsl = hexToHsl(baseColor);
  
  if (!targetHsl || !baseHsl) {
    return 'none';
  }
  
  const hueDiff = targetHsl.h - baseHsl.h;
  const satDiff = targetHsl.s - baseHsl.s;
  const lightDiff = targetHsl.l - baseHsl.l;
  
  const hueRotate = hueDiff;
  const saturate = 100 + satDiff;
  const brightness = 100 + lightDiff;
  
  return `hue-rotate(${hueRotate}deg) saturate(${Math.max(0, saturate)}%) brightness(${Math.max(0, Math.min(200, brightness))}%)`;
}

function isValidHexColor(hex) {
  return /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/.test(hex);
}

function normalizeHexColor(hex) {
  if (!hex) return null;
  hex = hex.trim();
  if (!hex.startsWith('#')) {
    hex = '#' + hex;
  }
  if (hex.length === 4) {
    hex = '#' + hex[1] + hex[1] + hex[2] + hex[2] + hex[3] + hex[3];
  }
  return isValidHexColor(hex) ? hex.toLowerCase() : null;
}

module.exports = {
  hexToRgb,
  rgbToHsl,
  hexToHsl,
  hexToCssFilter,
  isValidHexColor,
  normalizeHexColor
};
