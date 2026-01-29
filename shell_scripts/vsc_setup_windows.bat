:: @echo off

set "URL=https://code.visualstudio.com/sha/download?build=stable^&os=win32-x64"
set "FILE=VSCodeSetup-x64.exe"

echo Downloading VS Code...
curl -L "%URL%" -o "%FILE%"
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%URL%' -OutFile %FILE%"

echo Installing VS Code...
"%FILE%" & :: /silent

:: Install C/C++ extension
:: Make sure VS Code is installed and 'code' command is available in PATH
echo Installing C/C++ extension...
code --install-extension ms-vscode.cpptools
