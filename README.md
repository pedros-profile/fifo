# Plan
This repository has strict educational purposes.
The goal here is to document the basic steps when setting up a cross-platform project from scratch in a Linux environment. The planned steps are:

1. Implement a simple FIFO memory in different languages:
  * Python (DONE)
  * C (DONE)
  * C++ (DONE)
  * SystemC (prep...)
  * SystemVerilog (DONE)
2. Test each implementation with the same rules (ideally, the same test case script)
3. Check for performance, when applicable.
4. If possible, add a jenkins/gitlab file.

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
`sudo apt-get install verilator`

### OPTIONAL: GTKWave
```
# VS Code has support for VCD files too
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

# Execution
All commands here are assumed to be executed from the repo's root.

## Python
`python ./py/test_python_model.py`

## C
```
# Sanity check
bash ./c/run_sanity_check.sh

# Default test with CFFI (remove "--compile" if no re-compilation is needed)
python ./c/test_c_model.py --compile
```

## C++
```
# Sanity check
bash ./cpp/run_sanity_check.sh

# Build and run GoogleTest
bash ./cpp/run_gtest.sh
```

## SystemC
TDB

## SystemVerilog
```
# Compile and execute the testbench. If it passes, synthesize it. If not, open waveform.
bash ./sv/run_generic_synthesis.sh
```

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
