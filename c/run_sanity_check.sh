#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

pushd "$SCRIPT_DIR" >/dev/null
    mkdir -p bin
    EXECUTABLE="bin/fifo_sanity_check"
    gcc -O2 -Wall -o "$EXECUTABLE" fifo.c fifo.h
    $EXECUTABLE
popd >/dev/null
