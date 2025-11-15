class PluginListChecker {
  checkEmptyPluginList() {
    const pluginList = document.getElementById('pluginList')
    const emptyPluginMessage = document.getElementById('emptyPluginMessage')
    
    if (pluginList && emptyPluginMessage) {
      const hasPlugins = Array.from(pluginList.children)
        .some(child => child.nodeType !== 3 && child.textContent.trim() !== '')
      
      emptyPluginMessage.classList.toggle('hidden', hasPlugins)
    }
  }
}

module.exports = PluginListChecker

