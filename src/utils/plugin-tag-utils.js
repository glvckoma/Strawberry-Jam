/**
 * Plugin Tag Utilities
 * 
 * Utility functions for managing plugin tags.
 */

const fs = require('fs');
const path = require('path');

/**
 * Add a tag to a plugin
 * @param {string} pluginName - The name of the plugin directory
 * @param {string} tagName - The tag to add
 * @returns {Promise<{success: boolean, message: string, tags?: string[]}>} - Result of the operation
 */
async function addTagToPlugin(pluginName, tagName) {
  return await managePluginTag(pluginName, 'add', tagName);
}

/**
 * Remove a tag from a plugin
 * @param {string} pluginName - The name of the plugin directory
 * @param {string} tagName - The tag to remove
 * @returns {Promise<{success: boolean, message: string, tags?: string[]}>} - Result of the operation
 */
async function removeTagFromPlugin(pluginName, tagName) {
  return await managePluginTag(pluginName, 'remove', tagName);
}

/**
 * Check if a plugin has a specific tag
 * @param {string} pluginName - The name of the plugin directory
 * @param {string} tagName - The tag to check for
 * @returns {Promise<boolean>} - True if the plugin has the tag, false otherwise
 */
async function pluginHasTag(pluginName, tagName) {
  try {
    const pluginDir = path.join(process.cwd(), 'plugins', pluginName);
    
    if (!fs.existsSync(pluginDir)) {
      return false;
    }
    
    const pluginJsonPath = path.join(pluginDir, 'plugin.json');
    
    if (!fs.existsSync(pluginJsonPath)) {
      return false;
    }
    
    const pluginJsonContent = await fs.promises.readFile(pluginJsonPath, 'utf8');
    const pluginJson = JSON.parse(pluginJsonContent);
    
    return Array.isArray(pluginJson.tags) && pluginJson.tags.includes(tagName);
  } catch (error) {
    console.error(`Error checking if plugin ${pluginName} has tag ${tagName}:`, error);
    return false;
  }
}

/**
 * Get all plugins with a specific tag
 * @param {string} tagName - The tag to filter by
 * @returns {Promise<string[]>} - Array of plugin names with the specified tag
 */
async function getPluginsWithTag(tagName) {
  try {
    const pluginsDir = path.join(process.cwd(), 'plugins');
    
    if (!fs.existsSync(pluginsDir)) {
      return [];
    }
    
    const dirs = await fs.promises.readdir(pluginsDir);
    const pluginsWithTag = [];
    
    for (const dir of dirs) {
      const pluginDir = path.join(pluginsDir, dir);
      const stat = await fs.promises.stat(pluginDir);
      
      if (stat.isDirectory()) {
        const hasTag = await pluginHasTag(dir, tagName);
        if (hasTag) {
          pluginsWithTag.push(dir);
        }
      }
    }
    
    return pluginsWithTag;
  } catch (error) {
    console.error(`Error getting plugins with tag ${tagName}:`, error);
    return [];
  }
}

/**
 * Add or remove a tag from a plugin
 * @param {string} pluginName - The name of the plugin directory
 * @param {string} action - 'add' or 'remove'
 * @param {string} tagName - The tag to add or remove
 * @returns {Promise<{success: boolean, message: string, tags?: string[]}>} - Result of the operation
 */
async function managePluginTag(pluginName, action, tagName) {
  if (action !== 'add' && action !== 'remove') {
    return { success: false, message: `Invalid action: ${action}. Must be 'add' or 'remove'.` };
  }
  
  const pluginDir = path.join(process.cwd(), 'plugins', pluginName);
  
  if (!fs.existsSync(pluginDir)) {
    return { success: false, message: `Plugin directory not found: ${pluginDir}` };
  }
  
  const pluginJsonPath = path.join(pluginDir, 'plugin.json');
  
  if (!fs.existsSync(pluginJsonPath)) {
    return { success: false, message: `Plugin configuration not found: ${pluginJsonPath}` };
  }
  
  try {
    const pluginJsonContent = await fs.promises.readFile(pluginJsonPath, 'utf8');
    const pluginJson = JSON.parse(pluginJsonContent);
    
    if (!pluginJson.tags) {
      pluginJson.tags = [];
    }
    
    if (action === 'add') {
      if (pluginJson.tags.includes(tagName)) {
        return { 
          success: true, 
          message: `Plugin ${pluginName} already has tag: ${tagName}`,
          tags: pluginJson.tags
        };
      } else {
        pluginJson.tags.push(tagName);
      }
    } else if (action === 'remove') {
      if (!pluginJson.tags.includes(tagName)) {
        return { 
          success: true, 
          message: `Plugin ${pluginName} does not have tag: ${tagName}`,
          tags: pluginJson.tags
        };
      } else {
        pluginJson.tags = pluginJson.tags.filter(tag => tag !== tagName);
      }
    }
    
    await fs.promises.writeFile(pluginJsonPath, JSON.stringify(pluginJson, null, 2), 'utf8');
    
    return { 
      success: true, 
      message: `${action === 'add' ? 'Added' : 'Removed'} tag ${tagName} ${action === 'add' ? 'to' : 'from'} plugin ${pluginName}`,
      tags: pluginJson.tags
    };
  } catch (error) {
    return { success: false, message: `Error managing plugin tag: ${error.message}` };
  }
}

module.exports = {
  addTagToPlugin,
  removeTagFromPlugin,
  pluginHasTag,
  getPluginsWithTag,
  managePluginTag
};
