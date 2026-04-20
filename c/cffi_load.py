from pathlib import Path
import cffi

def cffi_load():
    # Get paths to CDEF and SO files
    CDEF_FILE = Path(__file__).parent / "fifo.h"
    SO_FILE = Path(__file__).parent / "bin/fifo.so"
    SO_FILE = SO_FILE.resolve()  # Resolve to absolute path

    # Load C definitions and SO using CFFI
    ffi = cffi.FFI()
    with open(CDEF_FILE, "r", encoding="ascii") as cdef_file:
        cdef_content = cdef_file.read()
    ffi.cdef(cdef_content)

    # Load the compiled SO
    print(f"Loading SO from {SO_FILE}...")
    lib = ffi.dlopen(str(SO_FILE))

    return ffi, lib
