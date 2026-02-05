import os
import time
from pathlib import Path
import cffi

def compile_ffi():
    # Compile the C FIFO SO
    C_DIR = Path(__file__).parent
    assert C_DIR.is_dir(), f"C directory not found: {C_DIR}"
    BATCH_FILE = (C_DIR / "build_so.sh").resolve()
    sys_exit_code = os.system("bash " + str(BATCH_FILE))
    return sys_exit_code

def cffi_load(compile: bool = False, screen_time: float = 3.0):
    # Get paths to CDEF and SO files
    CDEF_FILE = Path(__file__).parent / "fifo.h"
    SO_FILE = Path(__file__).parent / "bin/fifo.so"
    SO_FILE = SO_FILE.resolve()  # Resolve to absolute path

    if compile or not SO_FILE.is_file():
        print("Compiling C code...")
        sys_exit_code = compile_ffi()
        if sys_exit_code != 0:
            print(f"Compilation failed with exit code {sys_exit_code}.")
            exit()
        time.sleep(screen_time)  # Allow time to read compilation output

    # Load C definitions and SO using CFFI
    ffi = cffi.FFI()
    with open(CDEF_FILE, "r", encoding="ascii") as cdef_file:
        cdef_content = cdef_file.read()
    ffi.cdef(cdef_content)

    # Load the compiled SO
    print(f"Loading SO from {SO_FILE}...")
    lib = ffi.dlopen(str(SO_FILE))

    return ffi, lib

if __name__ == "__main__":
    compile_ffi()
