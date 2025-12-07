(() => {
  let forgotBlocked = false;
  const consoleLogs = [];

  function sanitizeLogMessage(message) {
    let sanitized = message;

    const sensitiveJsonKeys = ['authToken', 'refreshToken', 'df', 'username', 'password', 'auth_token', 'gameSessionIdStr'];
    sensitiveJsonKeys.forEach(key => {
      const regex = new RegExp(`(["']?${key}["']?\\s*:\\s*["'])([^"']*)(["'])`, 'gi');
      sanitized = sanitized.replace(regex, `$1[REDACTED]$3`);
    });

    const passwordWarningRegex = /(Retrieved plaintext password for )([^ ]+)( from)/gi;
    sanitized = sanitized.replace(passwordWarningRegex, '$1[REDACTED]$3');

    const tokenRegex = /([a-zA-Z0-9-_]+\.[a-zA-Z0-9-_]+\.[a-zA-Z0-9-_]{20,})/g;
    sanitized = sanitized.replace(tokenRegex, '[REDACTED_TOKEN]');

    const dfRegex = /[a-f0-9]{64}/gi;
    sanitized = sanitized.replace(dfRegex, '[REDACTED_DF]');

    return sanitized;
  }

  function captureLog(level, ...args) {
    const timestamp = new Date().toISOString();
    const message = args.map(arg => typeof arg === 'object' ? JSON.stringify(arg) : String(arg)).join(' ');
    const sanitizedMessage = sanitizeLogMessage(message);
    consoleLogs.push({ timestamp, level, message: sanitizedMessage });
    if (consoleLogs.length > 500) {
      consoleLogs.splice(0, consoleLogs.length - 400);
    }
  }

  function forgotPassword() {
    if (forgotBlocked) {
      return;
    }
    forgotBlocked = true;

    const modal = document.createElement('ajd-forgot-password-modal');
    modal.addEventListener('close', () => {
      document.getElementById('modal-layer').removeChild(modal);
      forgotBlocked = false;
    });
    document.getElementById('modal-layer').appendChild(modal);
  }

  function darkenColor(hex, percent) {
    if (!hex || hex.length < 7) return hex;

    let r = parseInt(hex.slice(1, 3), 16);
    let g = parseInt(hex.slice(3, 5), 16);
    let b = parseInt(hex.slice(5, 7), 16);

    r = Math.max(0, Math.floor(r * (100 - percent) / 100));
    g = Math.max(0, Math.floor(g * (100 - percent) / 100));
    b = Math.max(0, Math.floor(b * (100 - percent) / 100));

    return `#${r.toString(16).padStart(2, '0')}${g.toString(16).padStart(2, '0')}${b.toString(16).padStart(2, '0')}`;
  }

  function isLightColor(hexColor) {
    if (!hexColor || hexColor.length < 7) return false;
    const r = parseInt(hexColor.slice(1, 3), 16);
    const g = parseInt(hexColor.slice(3, 5), 16);
    const b = parseInt(hexColor.slice(5, 7), 16);
    const luminance = (r * 299 + g * 587 + b * 114) / 1000;
    return luminance > 150;
  }

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

  function normalizeHexColor(hex) {
    if (!hex) return null;
    hex = hex.trim();
    if (!hex.startsWith('#')) {
      hex = '#' + hex;
    }
    if (hex.length === 4) {
      hex = '#' + hex[1] + hex[1] + hex[2] + hex[2] + hex[3] + hex[3];
    }
    const isValid = /^#([A-Fa-f0-9]{6})$/.test(hex);
    return isValid ? hex.toLowerCase() : null;
  }

  window.LoginScreenUtilities = {
    sanitizeLogMessage,
    captureLog,
    forgotPassword,
    darkenColor,
    isLightColor,
    getConsoleLogs: () => consoleLogs,
    hexToCssFilter,
    normalizeHexColor
  };
})();
