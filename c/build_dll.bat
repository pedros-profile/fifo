@echo off
setlocal
set LOCAL_DIR=%~dp0
pushd %LOCAL_DIR%

    :: === Toolchain ===
    set CC=gcc

    :: === Flags for CFFI + debugging ===
    set CFLAGS=-std=c17 -g -O0 -Wall -Wextra
    set LDFLAGS=-shared

    :: === Files ===
    set SRC=fifo.c
    set INC=fifo.h
    set OBJ=bin/fifo.o
    set DLL=bin/fifo.dll

    echo [1/2] Compiling to object file...
    %CC% %CFLAGS% -c %SRC% -l %INC% -o %OBJ%
    if errorlevel 1 goto fail

    echo [2/2] Linking object into DLL...
    %CC% %LDFLAGS% -g %OBJ% -o %DLL%
    if errorlevel 1 goto fail

    echo.
    echo Build successful: %DLL%
    goto end

    :fail
    echo.
    echo Build FAILED
    exit /b 1

    :end
popd
endlocal
