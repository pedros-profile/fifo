#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

pushd "$SCRIPT_DIR" >/dev/null
    mkdir -p bin
    rm -f bin/sanity_check_fifo.*

    g++ -O2 fifo.cpp sanity_check_fifo.cpp -o bin/sanity_check_fifo

    echo "-----------------------"
    echo "Running sanity check..."
    echo "-----------------------"
    ./bin/sanity_check_fifo
popd >/dev/null
