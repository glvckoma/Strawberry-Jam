const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

// Paths
const devSourceDir = path.resolve('assets/extracted-winapp-dev');
const publicSourceDir = path.resolve('assets/extracted-winapp-public');
const asarOutput = path.resolve('assets/winapp.asar');
const backupAsar = path.resolve('assets/winapp-backup.asar');

async function main() {
  // Dynamically import inquirer
  let inquirer;
  try {
    inquirer = (await import('inquirer')).default;
  } catch (err) {
    console.error('Error importing inquirer:', err);
    console.log('Please install inquirer: npm install inquirer');
    process.exit(1);
  }

  // Prompt user for build type
  const answers = await inquirer.prompt([
    {
      type: 'list',
      name: 'buildType',
      message: 'Which ASAR version do you want to pack and run?',
      choices: [
        { name: 'Development (with Account Tester)', value: 'dev' },
        { name: 'Public (without Account Tester)', value: 'public' },
      ],
      default: 'dev',
    },
  ]);

  const sourceDir = answers.buildType === 'public' ? publicSourceDir : devSourceDir;
  console.log(`Selected build type: ${answers.buildType}. Using source: ${sourceDir}`);

  // Ensure source directory exists
  if (!fs.existsSync(sourceDir)) {
    console.error(`Error: Source directory not found: ${sourceDir}`);
    if (answers.buildType === 'public' && fs.existsSync(devSourceDir)) {
       console.error(`The public source directory ('${path.basename(publicSourceDir)}') seems missing. Did you forget to create it from the dev version ('${path.basename(devSourceDir)}') and remove the tester code?`);
    } else if (answers.buildType === 'dev' && !fs.existsSync(devSourceDir)) {
       console.error(`The dev source directory ('${path.basename(devSourceDir)}') seems missing. Did you rename 'extracted-winapp' correctly?`);
    }
    process.exit(1);
  }


  // Backup the current ASAR file if it exists
  if (fs.existsSync(asarOutput) && !fs.existsSync(backupAsar)) {
    console.log('Backing up current ASAR file...');
    try {
      fs.copyFileSync(asarOutput, backupAsar);
      console.log(`Backup created at ${backupAsar}`);
    } catch (backupError) {
       console.error('Error creating backup ASAR file:', backupError.message);
       // Decide if you want to proceed without backup or exit
       // process.exit(1);
    }
  }

  // Pack the selected directory into an ASAR file
  console.log(`Packing ASAR file from ${path.basename(sourceDir)}...`);
  try {
    execSync(`npx asar pack "${sourceDir}" "${asarOutput}"`, { stdio: 'inherit' });
    console.log('ASAR file packed successfully!');
  } catch (error) {
    console.error('Error packing ASAR file:', error.message);
    process.exit(1);
  }

  // Run the application
  console.log('Starting the application (npm run dev)...');
  try {
    execSync('npm run dev', { stdio: 'inherit' });
  } catch (error) {
    console.error('Error starting the application:', error.message);
  }
}

main().catch(err => {
  console.error("Script failed:", err);
  process.exit(1);
});
