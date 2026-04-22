from pathlib import Path
import cffi

def cffi_load(cdef_fpath=None, so_fpath=None):
    # Get paths to CDEF and SO files
    if cdef_fpath is None:
        cdef_fpath = Path(__file__).parent / "fifo.h"
    cdef_fpath = cdef_fpath.resolve()
    if so_fpath is None:
        so_fpath = Path(__file__).parent / "bin/fifo.so"
    so_fpath = so_fpath.resolve()

    # Load C definitions and SO using CFFI
    ffi = cffi.FFI()
    with open(cdef_fpath, "r", encoding="ascii") as cdef_file:
        cdef_content = cdef_file.read()
    ffi.cdef(cdef_content)

    # Load the compiled SO
    print(f"Loading SO from {so_fpath}...")
    lib = ffi.dlopen(str(so_fpath))

    return ffi, lib
