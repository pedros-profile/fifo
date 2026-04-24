import sys
import warnings
import re
from pathlib import Path
import cffi

PRE_CDEF_FPATH = (Path(__file__).parent / "fifo.h").resolve()
C_SO_FPATH = (Path(__file__).parent / "bin/fifo.so").resolve()


def cffi_load(cdef_fpath: Path = PRE_CDEF_FPATH, so_fpath: Path = C_SO_FPATH):
    """Load C definitions and shared object using CFFI."""
    # Load C definitions and SO using CFFI
    ffi = cffi.FFI()
    with open(cdef_fpath, "r", encoding="ascii") as cdef_file:
        cdef_content = cdef_file.read()
    ffi.cdef(cdef_content)

    # Load the compiled SO
    print(f"Loading SO from {so_fpath}...")
    lib = ffi.dlopen(str(so_fpath))

    return ffi, lib


def pre_process_cdef(pre_cdef_fpath: Path, post_cdef_fpath: Path, **params_dict) -> str:
    """Pre-process the CDEF file by replacing parameters with their values."""
    # Read the pre-processed CDEF content
    with open(pre_cdef_fpath, "r", encoding="ascii") as cdef_file:
        cdef_content = cdef_file.read()

    # Replace parameters in the CDEF content
    for param_name, param_value in params_dict.items():
        pattern = rf"#define\s+{param_name}\s+(\d+)"
        match = re.search(pattern, cdef_content)
        if match:
            cdef_content = re.sub(pattern, f"#define {param_name} {param_value}", cdef_content)

    # Write the post-processed CDEF content to the output file
    with open(post_cdef_fpath, "w", encoding="ascii") as cdef_file:
        cdef_file.write(cdef_content)
        print(f"Pre-processed CDEF file saved to {post_cdef_fpath} with parameters: {params_dict}")


if __name__ == "__main__":
    # Pre-process the CDEF file with default filepaths and parameter values
    if len(sys.argv) < 3:
        warnings.warn("Pre-processing CDEF file with default parameters since no arguments were provided.")
        pre_process_cdef(
            pre_cdef_fpath=PRE_CDEF_FPATH,
            post_cdef_fpath=PRE_CDEF_FPATH,
        )
    # If only the pre and post CDEF file paths are provided, pre-process with default parameters
    elif len(sys.argv) == 3:
        pre_process_cdef(
            pre_cdef_fpath=sys.argv[1],
            post_cdef_fpath=sys.argv[2],
        )
    # If additional parameters are provided, pre-process with those parameters
    else:
        pre_process_cdef(
            pre_cdef_fpath=sys.argv[1],
            post_cdef_fpath=sys.argv[2],
            **{arg.split('=')[0]: arg.split('=')[1] for arg in sys.argv[3:]}
        )
