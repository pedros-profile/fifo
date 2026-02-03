@echo off
setlocal
pushd %~dp0

    if not exist bin mkdir bin

    set EXECUTABLE=bin\gtest_fifo.exe
    if exist %EXECUTABLE% (
        echo Cleaning up previous test executable...
        del %EXECUTABLE%
    )

    set GTEST_DIR=external\googletest\googletest

    echo Building tests...
    g++ -std=c++17 ^
        -I%GTEST_DIR%\include ^
        -I%GTEST_DIR% ^
        -I. ^
        gtest_fifo.cpp ^
        fifo.h ^
        %GTEST_DIR%\src\gtest-all.cc ^
        %GTEST_DIR%\src\gtest_main.cc ^
        -o %EXECUTABLE% ^
        -Wall ^
        -g

    if %ERRORLEVEL% EQU 0 (
        echo.
        echo ==========================================
        echo Running tests...
        echo ==========================================
        %EXECUTABLE%
    ) else (
        echo Build failed!
    )

popd
endlocal
