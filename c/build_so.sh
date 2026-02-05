#!/usr/bin/env bash
set -euo pipefail

LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "$LOCAL_DIR" >/dev/null

    # === Toolchain ===
    CC=gcc

    # === Flags for CFFI + debugging ===
    CFLAGS="-std=c17 -g -O0 -Wall -Wextra"
    LDFLAGS="-shared"

    # === Files ===
    SRC="fifo.c"
    OBJ="bin/fifo.o"
    SO="bin/fifo.so"

    mkdir -p bin

    echo "[1/2] Compiling to object file..."
    "$CC" $CFLAGS -c "$SRC" -o "$OBJ"

    echo "[2/2] Linking object into shared object..."
    "$CC" $LDFLAGS -g "$OBJ" -o "$SO"

    echo
    echo "Build successful: $SO"

popd >/dev/null
