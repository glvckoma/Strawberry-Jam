const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const newVersion = process.argv[2];

if (!newVersion) {
  console.error('Usage: node version-bump.js <version>');
  console.error('Example: node version-bump.js 5.2.0');
  process.exit(1);
}

const rootDir = path.join(__dirname, '..');
const packageJsonPath = path.join(rootDir, 'package.json');
const latestYmlPath = path.join(rootDir, 'build', 'latest.yml');
const electronBuilderPath = path.join(rootDir, 'electron-builder.json');
const flashDir = path.join(rootDir, 'assets', 'flash');
const optionsDir = path.join(flashDir, 'options');

const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
const oldVersion = packageJson.version;

const oldSwfName = `v${oldVersion}.swf`;
const newSwfName = `v${newVersion}.swf`;
const oldSwfLabel = `v${oldVersion}`;
const newSwfLabel = `v${newVersion}`;

console.log(`Bumping version from ${oldVersion} to ${newVersion}...\n`);

try {
  execSync(`npm version ${newVersion} --no-git-tag-version`, { stdio: 'inherit' });
  console.log('[OK] package.json updated');
} catch (error) {
  console.error('[FAIL] npm version failed:', error.message);
  process.exit(1);
}

if (fs.existsSync(latestYmlPath)) {
  try {
    let content = fs.readFileSync(latestYmlPath, 'utf8');
    const regex = new RegExp(oldVersion.replace(/\./g, '\\.'), 'g');
    content = content.replace(regex, newVersion);
    fs.writeFileSync(latestYmlPath, content, 'utf8');
    console.log('[OK] build/latest.yml updated');
  } catch (error) {
    console.error('[FAIL] build/latest.yml:', error.message);
  }
} else {
  console.log('[SKIP] build/latest.yml not found');
}

if (fs.existsSync(electronBuilderPath)) {
  try {
    let content = fs.readFileSync(electronBuilderPath, 'utf8');
    const regex = new RegExp(oldVersion.replace(/\./g, '\\.'), 'g');
    const updated = content.replace(regex, newVersion);
    if (updated !== content) {
      fs.writeFileSync(electronBuilderPath, updated, 'utf8');
      console.log('[OK] electron-builder.json updated');
    } else {
      console.log('[SKIP] electron-builder.json (no version references found)');
    }
  } catch (error) {
    console.error('[FAIL] electron-builder.json:', error.message);
  }
}

const oldSwfPath = path.join(optionsDir, oldSwfName);
const newSwfPath = path.join(optionsDir, newSwfName);
if (fs.existsSync(oldSwfPath)) {
  try {
    fs.renameSync(oldSwfPath, newSwfPath);
    console.log(`[OK] Renamed ${oldSwfName} -> ${newSwfName}`);
  } catch (error) {
    console.error(`[FAIL] SWF rename: ${error.message}`);
  }
} else if (fs.existsSync(newSwfPath)) {
  console.log(`[SKIP] ${newSwfName} already exists`);
} else {
  console.log(`[SKIP] ${oldSwfName} not found in options/`);
}

const srcFiles = [
  'src/api/controllers/FilesController.js',
  'src/ui/managers/SettingsLoader.js',
  'src/ui/managers/SettingsUIManager.js'
];

const swfRefRegex = new RegExp(oldSwfName.replace(/\./g, '\\.'), 'g');
const labelRegex = new RegExp(`${oldSwfLabel} \\(latest\\)`, 'g');

for (const relPath of srcFiles) {
  const filePath = path.join(rootDir, relPath);
  if (!fs.existsSync(filePath)) {
    console.log(`[SKIP] ${relPath} not found`);
    continue;
  }
  try {
    let content = fs.readFileSync(filePath, 'utf8');
    const original = content;
    content = content.replace(swfRefRegex, newSwfName);
    content = content.replace(labelRegex, `${newSwfLabel} (latest)`);
    if (content !== original) {
      fs.writeFileSync(filePath, content, 'utf8');
      const count = (original.match(swfRefRegex) || []).length + (original.match(labelRegex) || []).length;
      console.log(`[OK] ${relPath} (${count} reference(s) updated)`);
    } else {
      console.log(`[SKIP] ${relPath} (no references to update)`);
    }
  } catch (error) {
    console.error(`[FAIL] ${relPath}: ${error.message}`);
  }
}

const swfFiles = [];
if (fs.existsSync(flashDir)) {
  const mainSwf = path.join(flashDir, 'ajclient.swf');
  if (fs.existsSync(mainSwf)) swfFiles.push(mainSwf);
}
if (fs.existsSync(optionsDir)) {
  fs.readdirSync(optionsDir)
    .filter(f => f.endsWith('.swf'))
    .forEach(f => swfFiles.push(path.join(optionsDir, f)));
}

if (swfFiles.length > 0) {
  const now = new Date();
  swfFiles.forEach(f => {
    try { fs.utimesSync(f, now, now); } catch (_) {}
  });
  console.log(`[OK] Touched ${swfFiles.length} SWF file(s) for auto-reapply`);
}

console.log(`\nVersion bump complete: ${oldVersion} -> ${newVersion}`);
