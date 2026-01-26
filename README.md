# Getting started
* Download and install VS Code, if not installed yet
  * Run vsc_setup_windows.bat in Windows or vsc_setup_linux.sh in Linux

## Versions
* Python: 3.12.12

# Plan
* Implement/simulate a simple FIFO memory in different languages: Python, C, C++, SystemC, SystemVerilog.
* Test each implementation with the same rules (ideally, the same test case script)
* Check for performance, when applicable.
* If possible, add a jenkins/gitlab file.

# Rules for the FIFO memory

## Parameters
* DEPTH = 8
* WLEN = 32

## Out of scope
* Different clock domains
* Read/write operations taking more than one clock cycle to be performed
