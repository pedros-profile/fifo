from pathlib import Path
import cffi

# Get paths to CDEF and DLL files
CDEF_FILE = Path(__file__).parent / "fifo.h"
DLL_FILE = Path(__file__).parent / "bin/fifo.dll"
assert CDEF_FILE.is_file(), f"CDEF file not found: {CDEF_FILE}"
assert DLL_FILE.is_file(), f"DLL file not found: {DLL_FILE}"

# Load C definitions and DLL
ffi = cffi.FFI()
with open(CDEF_FILE, "r") as cdef_file:
    cdef_content = cdef_file.read()
    ffi.cdef(cdef_content)
lib = ffi.dlopen(str(DLL_FILE))

pass
