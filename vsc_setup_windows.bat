:: @echo off

set "URL=https://code.visualstudio.com/sha/download?build=stable^&os=win32-x64"
set "FILE=VSCodeSetup-x64.exe"

echo Downloading VS Code...
curl -L "%URL%" -o "%FILE%"
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%URL%' -OutFile %FILE%"

echo Installing VS Code...
"%FILE%" & :: /silent
