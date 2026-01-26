echo off
setlocal

:: Set MinGW download URL (latest stable release, 64-bit)
set DOWNLOAD_URL=https://github.com/msys2/msys2-installer/releases/download/2023-05-04/msys2-x86_64-20230504.exe
set INSTALL_DIR=C:\mingw-w64

:: Create install directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Download MinGW installer
echo Downloading MinGW-w64...
powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%INSTALL_DIR%\mingw-installer.exe'"
:: 
:: :: Launch installer (user will need to follow GUI steps)
:: echo.
:: echo Launching installer. Please install to: %INSTALL_DIR%
:: start "" "%INSTALL_DIR%\mingw-installer.exe"
:: 
:: echo.
:: echo After installation, add the bin folder to PATH:
:: echo Example: setx PATH "%%PATH%%;%INSTALL_DIR%\mingw64\bin"
:: echo.
:: pause
:: endlocal
