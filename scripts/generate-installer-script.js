if (process.platform !== 'win32') {
  process.exit(0);
}

const fs = require('fs');
const path = require('path');

const buildDir = path.join(__dirname, '..', 'build');
const nshScriptPath = path.join(buildDir, 'installer.nsh');

if (!fs.existsSync(buildDir)) {
  fs.mkdirSync(buildDir, { recursive: true });
}

const nshScriptContent = `
RequestExecutionLevel user

!macro customInstDir
  StrCpy $INSTDIR "$LOCALAPPDATA\\Programs\\strawberry-jam"
!macroend

!macro customInit
  MessageBox MB_ICONINFORMATION|MB_OK "This project is free on https://github.com/glvckoma$\\nIf you paid for this you were scammed."

  ExecWait 'taskkill /F /IM strawberry-jam.exe'
  ExecWait 'taskkill /F /IM "AJ Classic.exe"'
!macroend
`;

fs.writeFileSync(nshScriptPath, nshScriptContent.trim());

console.log(`Successfully generated ${nshScriptPath}`);
