// Using CommonJS for core modules
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');
const asar = require('@electron/asar'); // This is a dependency of electron-builder

const DEV_SOURCE_DIR = path.join(__dirname, 'assets', 'extracted-winapp-dev');
const PUBLIC_SOURCE_DIR = path.join(__dirname, 'assets', 'extracted-winapp-public');
const TARGET_ASAR = path.join(__dirname, 'assets', 'winapp.asar'); // Changed target to winapp.asar
const ELECTRON_CMD = path.join(__dirname, 'node_modules', '.bin', 'electron');

// Modified to accept chalk as a parameter
async function packAsar(sourceDir, destAsar, chalk) {
    console.log(chalk.blue(`\nPacking ASAR from ${path.basename(sourceDir)}...`));
    try {
        // Ensure source directory exists
        if (!fs.existsSync(sourceDir)) {
            throw new Error(`Source directory not found: ${sourceDir}`);
        }
        // Ensure node_modules exists within the source directory (critical for ASAR)
        const nodeModulesPath = path.join(sourceDir, 'node_modules');
        if (!fs.existsSync(nodeModulesPath)) {
            console.warn(chalk.yellow(`Warning: 'node_modules' directory not found in ${sourceDir}. Packing might fail or the packed app might crash.`));
            // Consider adding logic here to copy node_modules if needed, or throw an error
        }

        await asar.createPackage(sourceDir, destAsar);
        console.log(chalk.green(`Successfully packed to ${destAsar}`));
        return true;
    } catch (error) {
        console.error(chalk.red(`Error packing ASAR: ${error.message}`));
        console.error(error.stack); // Log full stack for debugging
        return false;
    } // Added missing closing brace for try...catch
} // Added missing closing brace for the function

// Modified to accept chalk as a parameter
function runElectron(chalk) {
    console.log(chalk.blue('\nLaunching Strawberry Jam...'));
    try {
        // Get the correct electron executable path
        const electronPath = process.platform === 'win32' ? `${ELECTRON_CMD}.cmd` : ELECTRON_CMD;
        const indexPath = path.join(__dirname, 'src', 'index.js');

        // Set NODE_ENV for the child Electron process
        const env = { ...process.env, NODE_ENV: 'production' };
        
        console.log(chalk.gray(`Using Electron at: ${electronPath}`));
        console.log(chalk.gray(`Running script: ${indexPath} with NODE_ENV=${env.NODE_ENV}`));
        
        // On Windows, we need to be careful with paths containing spaces
        let appProcess;
        if (process.platform === 'win32') {
            // Use spawn with shell:true and properly quote the paths
            appProcess = spawn(`"${electronPath}"`, [`"${indexPath}"`], {
                stdio: 'inherit',
                shell: true,
                env: env
            });
        } else {
            // On non-Windows platforms, we can use the standard approach
            appProcess = spawn(electronPath, [indexPath], {
                stdio: 'inherit',
                env: env
            });
        }

        appProcess.on('close', (code) => {
            console.log(chalk.yellow(`Strawberry Jam exited with code ${code}`));
        });

        appProcess.on('error', (err) => {
            console.error(chalk.red('Failed to start Strawberry Jam:'), err);
            console.error(chalk.red('Error details:'), err.message);
        });
    } catch (error) {
        console.error(chalk.red(`Error launching Electron: ${error.message}`));
        console.error(error.stack);
    }
}

async function main() {
    try {
        // Dynamically import chalk and inquirer (ESM modules)
        const chalk = (await import('chalk')).default;
        const inquirer = await import('inquirer');
        
        // In inquirer v12+, prompt is a method on the default export
        const prompt = inquirer.default.prompt;
        
        if (typeof prompt !== 'function') {
            throw new Error('Failed to import inquirer.prompt function. Check inquirer version compatibility.');
        }

        console.log(chalk.bold.magenta('--- Strawberry Jam Pack & Run Utility ---'));

        const answers = await prompt([
            {
                type: 'list',
                name: 'versionChoice',
                message: 'Which version do you want to pack and run?',
                choices: [
                    // Remove explicit chalk styling; inquirer will handle selection highlight
                    { name: 'Public    (from assets/extracted-winapp-public)', value: 'public' },
                    // Separator removed to fix 'undefined'
                    { name: 'Cancel', value: 'cancel' }
                ],
                prefix: '🍓'
            }
        ]);

        let sourceDir;
        if (answers.versionChoice === 'public') {
            sourceDir = PUBLIC_SOURCE_DIR;
        } else { // Handles 'cancel'
            console.log(chalk.yellow('Operation cancelled.'));
            return;
        }

        // Pass chalk to the function
        const packSuccess = await packAsar(sourceDir, TARGET_ASAR, chalk);

        if (packSuccess) {
            // Pass chalk to the function
            runElectron(chalk);
        } else {
            console.log(chalk.red('Packing failed. Application will not be launched.'));
        }
    } catch (error) {
        console.error('Error in main function:');
        console.error(error);
    }
}

main().catch(error => {
    // Use standard console.error as chalk is not available here
    console.error('An unexpected error occurred:');
    console.error(error);
    
    // Provide more helpful error information
    if (error.message && error.message.includes('inquirer')) {
        console.error('\nPossible solution: Try installing an older version of inquirer:');
        console.error('npm uninstall inquirer && npm install inquirer@8.2.5');
        console.error('\nOr convert this file to an ES module by renaming it to pack-and-run.mjs');
    }
});
