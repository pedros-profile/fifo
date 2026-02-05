#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pushd "$ROOT_DIR" >/dev/null
    mkdir -p c/bin
    EXECUTABLE="c/bin/fifo_sanity_check"
    gcc -O2 -Wall -o "$EXECUTABLE" c/fifo.c c/fifo.h
    $EXECUTABLE
popd >/dev/null
