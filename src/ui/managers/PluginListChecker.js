class PluginListChecker {
  checkEmptyPluginList() {
    const pluginList = document.getElementById('pluginList')
    const emptyPluginMessage = document.getElementById('emptyPluginMessage')

    if (pluginList && emptyPluginMessage) {
      const hasVisiblePlugins = Array.from(pluginList.children)
        .some(child => child.nodeType !== 3 && child.style.display !== 'none' && child.textContent.trim() !== '')

      emptyPluginMessage.classList.toggle('hidden', hasVisiblePlugins)
    }
  }
}

module.exports = PluginListChecker
