const fs = require('fs')
const path = require('path')

const downloadPluginFiles = async (contentsUrl, pluginDir) => {
  const response = await fetch(contentsUrl)
  if (!response.ok) throw new Error(`Failed to fetch plugin contents: ${response.statusText}`)
  const contents = await response.json()
  const filesArray = Array.isArray(contents) ? contents : [contents]

  for (const file of filesArray) {
    if (file.type === 'file') {
      const fileResponse = await fetch(file.download_url)
      if (!fileResponse.ok) throw new Error(`Failed to download ${file.name}: ${fileResponse.statusText}`)
      const filePath = path.join(pluginDir, file.name)
      const fileContent = Buffer.from(await fileResponse.arrayBuffer())
      try {
        fs.writeFileSync(filePath, fileContent)
      } catch (writeErr) {
        const tempPath = filePath + '.update'
        fs.writeFileSync(tempPath, fileContent)
        try {
          if (fs.existsSync(filePath)) fs.unlinkSync(filePath)
          fs.renameSync(tempPath, filePath)
        } catch (_) {}
      }
    } else if (file.type === 'dir') {
      const subDir = path.join(pluginDir, file.name)
      if (!fs.existsSync(subDir)) fs.mkdirSync(subDir, { recursive: true })
      await downloadPluginFiles(file.url, subDir)
    }
  }
}

module.exports = { downloadPluginFiles }
