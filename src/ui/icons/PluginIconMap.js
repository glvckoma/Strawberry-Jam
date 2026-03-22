const DEFAULT_ICON_MAP = {
  'Achievements': 'trophy',
  'Username Logger': 'users',
  'Return of the Phantoms': 'ghost',
  'Packet Spammer': 'send',
  'Glow': 'sparkles',
  'No Eyes': 'eye-off',
  'Advertising': 'megaphone',
  'In-game Chat Commands': 'terminal',
  'InvisibleToggle': 'eye',
  'Membership': 'crown',
  'TFD Automation': 'bot',
  'Tiki Trouble Automation': 'waves',
  'Price Checker': 'tag',
  'Gem Farm': 'gem',
  'Den Log': 'warehouse',
  'Private Chat Emojis': 'smile'
}

const TYPE_FALLBACK_ICONS = {
  ui: 'layout-grid',
  game: 'gamepad-2'
}

function getIconForPlugin(pluginName, pluginType, customIcons = {}) {
  if (customIcons[pluginName]) {
    return customIcons[pluginName]
  }
  if (DEFAULT_ICON_MAP[pluginName]) {
    return DEFAULT_ICON_MAP[pluginName]
  }
  return TYPE_FALLBACK_ICONS[pluginType] || 'puzzle'
}

const CURATED_ICONS = [
  'trophy', 'users', 'ghost', 'send', 'sparkles', 'eye-off', 'megaphone',
  'terminal', 'eye', 'crown', 'bot', 'waves', 'tag', 'gem', 'warehouse',
  'smile', 'layout-grid', 'gamepad-2', 'puzzle', 'sword', 'shield', 'heart',
  'star', 'zap', 'flame', 'snowflake', 'sun', 'moon', 'cloud', 'music',
  'volume-2', 'bell', 'bookmark', 'compass', 'map', 'target', 'crosshair',
  'swords', 'wand-2', 'dice-5', 'joystick', 'monitor', 'settings', 'wrench',
  'hammer', 'bug', 'code', 'database', 'folder', 'file-text', 'message-square',
  'mail', 'phone', 'camera', 'image', 'palette', 'brush', 'pen-tool',
  'scissors', 'gift', 'package', 'shopping-cart', 'wallet', 'key', 'lock',
  'unlock', 'search', 'filter', 'list', 'grid-3x3', 'layers', 'box'
]

function kebabToPascal(str) {
  return str.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join('')
}

function getLucideIcon(kebabName) {
  const lucide = require('lucide')
  const pascalName = kebabToPascal(kebabName)
  return lucide.icons[pascalName] || null
}

function createIconSvg(kebabName, className = '') {
  const iconData = getLucideIcon(kebabName)
  if (!iconData) {
    const fallback = getLucideIcon('puzzle')
    if (!fallback) return ''
    return buildSvgString(fallback, className)
  }
  return buildSvgString(iconData, className)
}

function buildSvgString(iconData, className) {
  const paths = iconData.map(([tag, attrs]) => {
    const attrStr = Object.entries(attrs).map(([k, v]) => `${k}="${v}"`).join(' ')
    return `<${tag} ${attrStr}/>`
  }).join('')
  return `<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="${className}">${paths}</svg>`
}

module.exports = { DEFAULT_ICON_MAP, TYPE_FALLBACK_ICONS, getIconForPlugin, CURATED_ICONS, createIconSvg, kebabToPascal, getLucideIcon }
