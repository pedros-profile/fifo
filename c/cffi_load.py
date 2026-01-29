import os
from pathlib import Path
import cffi

# Compile the C FIFO DLL
C_DIR = Path(__file__).parent
assert C_DIR.is_dir(), f"C directory not found: {C_DIR}"
BATCH_FILE = (C_DIR / "build_dll.bat").resolve()
os.system(str(BATCH_FILE))

# Get paths to CDEF and DLL files
CDEF_FILE = Path(__file__).parent / "fifo.h"
DLL_FILE = Path(__file__).parent / "bin/fifo.dll"

# Load C definitions and DLL
ffi = cffi.FFI()
with open(CDEF_FILE, "r") as cdef_file:
    cdef_content = cdef_file.read()
ffi.cdef(cdef_content)
lib = ffi.dlopen(str(DLL_FILE))
