# Getting started
* Download and install VS Code, if not installed yet
  * Run \[TO BE ADDED\] in Windows or \[TO BE ADDED\] in Linux

# Plan
* Implement/simulate a simple FIFO memory in different languages: Python, C, C++, SystemC, SystemVerilog.
* Test each implementation with the same rules (ideally, the same test case script)
* Check for performance, when applicable.
* If possible, add a jenkins/gitlab file.

# Rules for the FIFO memory

### Parameters
* DEPTH = 128
* WORDLEN = 32

### Reset values
* pos_rd = 0
* pos_wr = 0

### Errors
* Empty memory: read request when pos_rd == pos_wr
* Full memory: write request when pos_wr == pos_rd - 1 (mod DEPTH)

### Out of scope
* Different clock domains
* Read/write operations taking more than one clock cycle to be performed
