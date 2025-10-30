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

  window.LoginScreenUtilities = {
    sanitizeLogMessage,
    captureLog,
    forgotPassword,
    darkenColor,
    isLightColor,
    getConsoleLogs: () => consoleLogs
  };
})();
