# Considerations
### Platform
This repository is run on Windows. Adaptions must be done for executing it on Linux.

### Clone
When cloning this repository, also download its third-party submodules with:
`git clone --recurse-submodules https://github.com/pedros-profile/fifo.git`

#### Third-party submodule repositories
* [Google Test](https://github.com/google/googletest)
* [SystemC](https://github.com/accellera-official/systemc)


# Getting started
* (OPTIONAL) Download and install VS Code, if not installed yet
  * Run vsc_setup_windows.bat in Windows or vsc_setup_linux.sh in Linux
* (RECOMMENDED) install Miniconda3
  * Pick Python version 3.12.12
* [Python] Install required packages
  * `cd py/; pip install -r requirements.txt`
* [C/C++] Install MinGW

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
* CMake 3.27.1