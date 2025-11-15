const HTTPClient = require('../../services/HttpClient')
const path = require('path')
const fs = require('fs')

class FilesController {
  constructor(app = null) {
    this._app = app;
    this._assetsPath = null;
    this._flashDir = null;
    this._optionsDir = null;
    this._initialized = false;
    
    if (app) {
      this._initializePaths(app);
    }
  }
  
  _initializePaths(app) {
    const { getAssetsPath } = require('../../Constants');
    this._assetsPath = getAssetsPath(app);
    this._flashDir = path.join(this._assetsPath, 'flash');
    this._optionsDir = path.join(this._flashDir, 'options');
    this._initialized = true;
  }
  
  initialize(app) {
    if (!app) {
      throw new Error('FilesController.initialize requires the Electron app object');
    }
    this._app = app;
    this._initializePaths(app);
  }
  
  _ensureInitialized() {
    if (this._initialized) {
      return;
    }
    
    if (this._app) {
      this._initializePaths(this._app);
    } else {
      let assetsPath;
      if (process.env.STRAWBERRY_JAM_ASSETS_PATH) {
        assetsPath = process.env.STRAWBERRY_JAM_ASSETS_PATH;
      } else if (process.resourcesPath) {
        assetsPath = path.join(process.resourcesPath, 'assets');
      } else {
        assetsPath = path.join(__dirname, '../../assets');
      }
      this._assetsPath = assetsPath;
      this._flashDir = path.join(assetsPath, 'flash');
      this._optionsDir = path.join(this._flashDir, 'options');
      this._initialized = true;
    }
  }
  
  get flashDir() {
    this._ensureInitialized();
    return this._flashDir;
  }
  
  get optionsDir() {
    this._ensureInitialized();
    return this._optionsDir;
  }

  /**
   * Host endpoint.
   */
  get baseUrl () {
    return 'https://ajcontent.akamaized.net'
  }

  /**
   * Request headers.
   */
  get baseHeaders () {
    return {
      Host: 'ajcontent.akamaized.net',
      Referer: 'https://desktop.animaljam.com/gameClient/game/index.html'
    }
  }

  /**
   * Initializes the SWF system.
   * This should be called on application startup.
   * @returns {Promise<void>}
   */
  async initializeSwf() {
    try {
      // Ensure options directory exists
      if (!fs.existsSync(this.optionsDir)) {
        await fs.promises.mkdir(this.optionsDir, { recursive: true });
        console.log('Created options directory for SWF files.');
      }

      const activeSwfPath = path.join(this.flashDir, 'ajclient.swf');
      const prodSwfPath = path.join(this.optionsDir, 'ajclient-prod.swf');

      // If active SWF doesn't exist, create it from the production version.
      if (!fs.existsSync(activeSwfPath) && fs.existsSync(prodSwfPath)) {
        await fs.promises.copyFile(prodSwfPath, activeSwfPath);
        console.log('Created active SWF file from production version.');
      }
    } catch (error) {
      console.error('Failed to initialize SWF system:', error);
    }
  }

  /**
   * Gets the selected SWF file from settings.
   * This always returns 'ajclient.swf' because the active file is always a copy.
   */
  getSelectedSwfFile () {
    return 'ajclient.swf'
  }

  /**
   * Replaces the active ajclient.swf with the selected file from the options.
   * @param {string} selectedFile - The filename to make active
   * @returns {Promise<{success: boolean, message?: string, error?: string}>}
   */
  async replaceSwfFile(selectedFile) {
    const targetFile = path.join(this.flashDir, 'ajclient.swf');
    const sourceFromOptions = path.join(this.optionsDir, selectedFile);

    try {
      if (!fs.existsSync(sourceFromOptions)) {
        return { success: false, error: `Option for ${selectedFile} not found.` };
      }

      await fs.promises.copyFile(sourceFromOptions, targetFile);
      console.log(`Switched active client to ${selectedFile}`);

      return {
        success: true,
        message: `Successfully switched to ${selectedFile}`
      };

    } catch (error) {
      console.error('Error replacing SWF file:', error);
      return {
        success: false,
        error: `Failed to replace SWF file: ${error.message}`
      };
    }
  }

  /**
   * Gets the currently active SWF file info by comparing it against options.
   * @returns {Object} Info about the currently active file
   */
  getActiveSwfInfo() {
    const targetFile = path.join(this.flashDir, 'ajclient.swf');

    try {
      if (!fs.existsSync(targetFile) || !fs.existsSync(this.optionsDir)) {
        return { active: null, error: 'Active SWF or options directory not found.' };
      }

      const stats = fs.statSync(targetFile);
      let detectedSource = 'ajclient.swf'; // Default assumption

      const optionFiles = fs.readdirSync(this.optionsDir).filter(f => f.endsWith('.swf'));
      for (const filename of optionFiles) {
        const optionPath = path.join(this.optionsDir, filename);
        if (fs.existsSync(optionPath)) {
          const optionStats = fs.statSync(optionPath);
          // Compare by size as a reliable heuristic
          if (optionStats.size === stats.size) {
            detectedSource = filename;
            break;
          }
        }
      }

      return {
        active: detectedSource,
        size: stats.size,
        modified: stats.mtime
      };
    } catch (error) {
      console.error('Error getting active SWF info:', error.message);
      return { active: null, error: error.message };
    }
  }

  /**
   * Gets all available SWF files that can be selected.
   * @returns {Array<string>} Array of available SWF filenames
   */
  getAvailableSwfFiles () {
    try {
        if (!fs.existsSync(this.optionsDir)) {
            console.warn('Options directory not found during getAvailableSwfFiles. Returning defaults.');
            return ['ajclient-prod.swf'];
        }
        // The list of selectable files is simply the list of options.
        const files = fs.readdirSync(this.optionsDir)
            .filter(f => f.endsWith('.swf') && !fs.statSync(path.join(this.optionsDir, f)).isDirectory());
        
        return [...new Set(files)].sort(); // Return sorted unique list
    } catch (error) {
        console.error('Error scanning for SWF files:', error);
        return ['ajclient-prod.swf']; // Fallback
    }
  }

  /**
   * Gets SWF file information for display purposes.
   * @returns {Array<Object>} Array of SWF file info objects
   */
  getSwfFileInfo () {
    const files = this.getAvailableSwfFiles();
    
    return files.map(filename => {
      const optionPath = path.join(this.optionsDir, filename);
      let stats = null;
      let displayName = filename;
      
      try {
        if (fs.existsSync(optionPath)) {
          stats = fs.statSync(optionPath);
        }
        
        if (filename === 'ajclient-prod.swf') {
          displayName = 'Production Client';
        } else if (filename === 'ajclient-dev.swf') {
          displayName = 'Development Client';
        } else if (filename === 'ajclient-jam.swf') {
            displayName = 'Jam Client';
        } else if (filename === 'ajclient-old.swf') {
            displayName = 'Old Client';
        } else {
          displayName = filename.replace('.swf', '')
        }
      } catch (error) {
        console.error(`Error getting stats for ${filename}:`, error);
      }

      return {
        filename,
        displayName,
        size: stats ? stats.size : 0,
        modified: stats ? stats.mtime : null,
        exists: stats !== null
      };
    });
  }

  /**
   * Serves the active ajclient.swf file.
   */
  game (request, response) {
    const activeSwfPath = path.join(this.flashDir, 'ajclient.swf');
    
    if (!fs.existsSync(activeSwfPath)) {
      console.error(`Active SWF file not found: ${activeSwfPath}`);
      return response.status(404).send('SWF file not found');
    }
    
    console.log(`Serving active SWF file: ${activeSwfPath}`);
    return response.sendFile(activeSwfPath);
  }


  index (request, response) {
    const requestPath = request.path.toLowerCase();
    
    if (requestPath.includes('ajclient.swf')) {
      const legitimatePattern = /^\/\d{4}\/ajclient\.swf$/;
      if (legitimatePattern.test(request.path)) {
        console.log(`[SWF Update Blocker] Legitimate SWF request reached index(), serving locally: ${request.path}`);
        return this.game(request, response);
      } else {
        console.log(`[SWF Update Blocker] Blocked SWF update request: ${request.path}`);
        console.log(`[SWF Update Blocker] Note: Legitimate SWF requests should match /{4-digit}/ajclient.swf pattern`);
        return response.status(404).send('SWF update blocked - using local modded SWF');
      }
    }
    
    return request.pipe(
      HTTPClient.proxy({
        url: `${this.baseUrl}/${request.path}`,
        headers: this.baseHeaders
      })
    ).pipe(response);
  }
}

module.exports = new FilesController();
