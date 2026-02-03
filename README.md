# Getting started
* Download and install VS Code, if not installed yet
  * Run vsc_setup_windows.bat in Windows or vsc_setup_linux.sh in Linux

## Versions
* Python: 3.12.12
* C: C17
* C++: C++17

# Plan
* Implement a simple FIFO memory in different languages:
  * Python (DONE)
  * C (DONE)
  * C++ (DONE)
  * SystemC (prep...)
  * SystemVerilog
* Test each implementation with the same rules (ideally, the same test case script)
* Check for performance, when applicable.
* If possible, add a jenkins/gitlab file.

# Rules for the FIFO memory

## Parameters
Each implementation is parameterizable, with default values:
* DEPTH = 8
* WLEN = 32

## Out of scope
* Multi-threading
* Different clock domains
* Read/write operations taking more than one clock cycle to be performed

# SW Tools
* VS Code 1.108.1
* conda 25.11.1
* MinGW-W64 13.2.0