#!/usr/bin/env node

/**
 * Plugin Tag Management CLI
 * 
 * A command-line interface for managing plugin tags.
 * 
 * Usage:
 *   node manage-plugin-tags.js <plugin-name> <add|remove> <tag-name>
 *   node manage-plugin-tags.js list <tag-name>
 * 
 * Examples:
 *   node manage-plugin-tags.js UsernameLogger add beta
 *   node manage-plugin-tags.js UsernameLogger remove beta
 *   node manage-plugin-tags.js list beta
 */

const {
  addTagToPlugin,
  removeTagFromPlugin,
  getPluginsWithTag
} = require('./plugin-tag-utils');

// Simple colored console output
const colors = {
  blue: (text) => `\x1b[34m${text}\x1b[0m`,
  green: (text) => `\x1b[32m${text}\x1b[0m`,
  yellow: (text) => `\x1b[33m${text}\x1b[0m`,
  red: (text) => `\x1b[31m${text}\x1b[0m`
};

/**
 * Main function
 */
async function main() {
  const args = process.argv.slice(2);
  
  if (args.length === 0 || args[0] === '--help' || args[0] === '-h') {
    showHelp();
    return;
  }
  
  if (args[0] === 'list' && args.length === 2) {
    await listPluginsWithTag(args[1]);
    return;
  }
  
  if (args.length < 3) {
    console.error(colors.red('Error: Not enough arguments.'));
    showHelp();
    return;
  }
  
  const [pluginName, action, tagName] = args;
  
  if (action !== 'add' && action !== 'remove') {
    console.error(colors.red(`Error: Invalid action: ${action}. Must be 'add' or 'remove'.`));
    showHelp();
    return;
  }
  
  try {
    let result;
    
    if (action === 'add') {
      result = await addTagToPlugin(pluginName, tagName);
    } else {
      result = await removeTagFromPlugin(pluginName, tagName);
    }
    
    if (result.success) {
      console.log(colors.green(result.message));
      if (result.tags && result.tags.length > 0) {
        console.log(colors.blue(`Current tags: ${result.tags.join(', ')}`));
      } else {
        console.log(colors.blue('No tags remaining.'));
      }
    } else {
      console.error(colors.red(`Error: ${result.message}`));
    }
  } catch (error) {
    console.error(colors.red(`Error: ${error.message}`));
  }
}

/**
 * List all plugins with a specific tag
 * @param {string} tagName - The tag to filter by
 */
async function listPluginsWithTag(tagName) {
  try {
    const plugins = await getPluginsWithTag(tagName);
    
    if (plugins.length === 0) {
      console.log(colors.yellow(`No plugins found with tag: ${tagName}`));
    } else {
      console.log(colors.green(`Plugins with tag '${tagName}':`));
      plugins.forEach(plugin => {
        console.log(`  - ${plugin}`);
      });
    }
  } catch (error) {
    console.error(colors.red(`Error listing plugins: ${error.message}`));
  }
}

/**
 * Show help message
 */
function showHelp() {
  console.log(`
${colors.blue('Plugin Tag Management CLI')}

${colors.yellow('Usage:')}
  node manage-plugin-tags.js <plugin-name> <add|remove> <tag-name>
  node manage-plugin-tags.js list <tag-name>

${colors.yellow('Examples:')}
  node manage-plugin-tags.js UsernameLogger add beta
  node manage-plugin-tags.js UsernameLogger remove beta
  node manage-plugin-tags.js list beta
  `);
}

// Run the main function
main().catch(error => {
  console.error(colors.red(`Unhandled error: ${error.message}`));
  process.exit(1);
});
