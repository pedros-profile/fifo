@echo off
setlocal
set ROOT_DIR=%~dp0..
pushd %ROOT_DIR%
  if not exist c\bin mkdir c\bin else del /S /Q c\bin\*
  gcc -O2 -Wall -o c/bin/fifo.exe c/fifo.c c/fifo.h
  .\c\bin\fifo.exe
popd
endlocal
