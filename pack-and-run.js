const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

// Paths
const extractedDir = path.resolve('assets/extracted-winapp');
const asarOutput = path.resolve('assets/winapp.asar');
const backupAsar = path.resolve('assets/winapp-backup.asar');

// Backup the current ASAR file if it exists
if (fs.existsSync(asarOutput) && !fs.existsSync(backupAsar)) {
  console.log('Backing up current ASAR file...');
  fs.copyFileSync(asarOutput, backupAsar);
}

// Pack the extracted directory into an ASAR file
console.log('Packing ASAR file...');
try {
  execSync(`npx asar pack "${extractedDir}" "${asarOutput}"`, { stdio: 'inherit' });
  console.log('ASAR file packed successfully!');
} catch (error) {
  console.error('Error packing ASAR file:', error.message);
  process.exit(1);
}

// Run the application
console.log('Starting the application...');
try {
  execSync('npm run dev', { stdio: 'inherit' });
} catch (error) {
  console.error('Error starting the application:', error.message);
}
