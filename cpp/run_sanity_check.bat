@echo off
setlocal
pushd %~dp0
    if not exist bin mkdir bin
    if exist bin\sanity_check_fifo.* del /Q bin\sanity_check_fifo.*
    g++ -O2 fifo.cpp sanity_check_fifo.cpp -o bin/sanity_check_fifo -Lfifo.h
    echo -----------------------
    echo Running sanity check...
    echo -----------------------
    bin\sanity_check_fifo
popd
endlocal