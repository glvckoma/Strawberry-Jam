const os = require('os');

class SystemInfoService {
  getOsInfo() {
    return {
      platform: process.platform,
      release: os.release(),
      arch: process.arch
    };
  }
}

module.exports = SystemInfoService;

