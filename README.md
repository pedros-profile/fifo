# Plan
This repository has strict educational purposes.
The goal here is to document the basic steps when setting up a cross-platform project from scratch in a Linux environment. The planned steps are:

1. Implement (and test) a simple FIFO memory in different languages:
  * Python (DONE)
  * C (DONE)
  * C++ (DONE)
  * SystemC (prep...)
  * SystemVerilog (DONE)
      * extra: verifying with cocotb (tbd)
      * extra: logic synthesis (tbd)
2. Test each implementation with the same rules
3. Check for performance, when applicable.

# Commands
All executions and cleanups are commanded from the root directory via Make.
The commands are listed and described below:

### Common commands
`make all`: Execute detailed tests on all the implementations. Compiles libraries if needed.

`make clean`: Clean up binaries from all implementations.

### C-Implementation related
`make run_sanity_c`: run a sanity check of the current C implementation. Compiles local libraries if needed.

`make run_cffi`: run CFFI more detailed tests of the current C implementation. Compiles shared object if needed.

`make clean_c`: clean all binaries from C implementation.

### Python
`make run_python`: run unittest test cases over the current Python implementation.

### C++
`run_sanity_cpp`: run a sanity check of the current C++ implementation. Compiles local libraries if needed.

`run_gtest`: run Google Test test cases over the current C++ implementation. Compiles GTest and local libraries if needed.

`clean_cpp`: clean all binaries from C++ implementation.

### SystemVerilog
`run_sv_tb`: run SystemVerilog testbench over the current SystemVerilog implementation and generate a VCD file as output. Compiles the RTL if needed.

`view_waveform`: Visualize the generated VCD on GtkWave. Executes _run_sv_tb_ if no VCD is found.

`clean_sv`: clean all binaries and VCD generated from SV compilation.


# Required tools

### GIT
```
# Install GIT
sudo apt-get git

# Clone this repo from GitHub (Below, with an SSH key.)
git clone --recurse-submodules git@github.com:pedros-profile/fifo.git
```


Third-party submodule repositories:
* [Google Test](https://github.com/google/googletest)
* [SystemC (at tag 3.0.2)](https://github.com/accellera-official/systemc)
* [Yosys](https://github.com/YosysHQ/yosys)

### Visual Code
```
# download
wget https://go.microsoft.com/fwlink/?LinkID=760868 -O ~/Downloads/code_latest_amd64.deb

# install (accept the automatic activation)
sudo apt install ~/Downloads/code_latest_amd64.deb
```

### C/C++ compilers
GCC and G++ already installed in Debian by default.

### Make
Make in Debian by default

### GDB
`sudo apt install gdb`

### CMake
`sudo apt-get install cmake`

### Miniconda3
```
# download installation script
INST_SCRIPT="~/Downloads/Miniconda3-latest-Linux-x86_64.sh"
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $INST_SCRIPT

# run install script (with Python 3.12.12)
bash $INST_SCRIPT

# create a virtual environment after installation is complete
conda create --name fifo_venv python=3.12.12
```

### Verilator
```
# Verilog/SystemVerilog compiler
sudo apt-get install verilator
```

### GTKWave
```
# Default tool for waveform visualization (but VS Code has support for VCD files too!)
sudo apt-get install gtkwave
```

### OPTIONAL: FST lib
```
# Requires GTKWave. VS Code does not support FST format.
sudo apt-get update && sudo apt-get install zlib1g-dev
```

### Python packages
```
conda activate fifo_venv
pip install -r ./fifo/py/requirements.txt
```

# Rules for the FIFO memory

### Parameters
Each implementation is parameterizable, with default values:
* DEPTH = 8
* WLEN = 32

### Out of scope
* Multi-threading
* Different clock domains
* Read/write operations taking more than one clock cycle to be performed

# SW Versions
* Python: 3.12.12
* C: C17
* C++: C++17
* SystemC: 3.0.2
* Debian 13
* VS Code 1.108.1
* conda 25.11.1
* GDB: 16.3
* Make 4.4.1
* CMake 3.31.6
* Verilator 5.032
* GTKWave v3.3.121

# VS Code extensions
* [VIm](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim)
* [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
