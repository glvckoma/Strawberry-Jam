const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const newVersion = process.argv[2];

if (!newVersion) {
  console.error('Please provide a new version number.');
  process.exit(1);
}

const packageJsonPath = path.join(__dirname, '..', 'package.json');
const latestYmlPath = path.join(__dirname, '..', 'build', 'latest.yml');

// Step 1: Get the old version from package.json
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
const oldVersion = packageJson.version;

// Step 2: Run npm version
try {
  console.log(`Bumping version from ${oldVersion} to ${newVersion}...`);
  execSync(`npm version ${newVersion} --no-git-tag-version`, { stdio: 'inherit' });
} catch (error) {
  console.error('Failed to bump version using npm.', error);
  process.exit(1);
}

// Step 3: Update build/latest.yml
try {
  if (fs.existsSync(latestYmlPath)) {
    console.log('Updating build/latest.yml...');
    let latestYml = fs.readFileSync(latestYmlPath, 'utf8');
    const oldVersionRegex = new RegExp(oldVersion.replace(/\./g, '\\.'), 'g');
    latestYml = latestYml.replace(oldVersionRegex, newVersion);
    fs.writeFileSync(latestYmlPath, latestYml, 'utf8');
    console.log('Successfully updated build/latest.yml.');
  } else {
    console.warn('Warning: build/latest.yml not found. Skipping update.');
  }
} catch (error) {
  console.error('Failed to update build/latest.yml.', error);
  process.exit(1);
}

console.log('Version bump complete.');
