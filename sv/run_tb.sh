#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

pushd "$SCRIPT_DIR" >/dev/null
    OUT_DIR="$SCRIPT_DIR/build/verilator"
    mkdir -p "$OUT_DIR"

    echo ""
    echo "-----------------------------------------"
    echo "Compiling the TestBench with Verilator..."
    echo "-----------------------------------------"
    echo ""
    # For FST, use --trace-fst and change dumpfile in tb_fifo
    verilator --binary -Wall -Wno-DECLFILENAME --timing -sv --trace \
        "test_under_and_overflow.sv" \
        "fifo.sv" \
        --Mdir "$OUT_DIR/obj" \
        -o "$OUT_DIR/test_uf_ov"

    echo ""
    echo "-----------------------------------------"
    echo "Running the TestBench $OUT_DIR/tb_fifo..."
    echo "-----------------------------------------"
    echo ""
    "$OUT_DIR/tb_fifo"
    tb_exit_code=$?
    echo ""
    echo "--------------------------------------------"
    echo "TestBench executed (exit_code=$tb_exit_code)"
    echo "--------------------------------------------"
    echo ""
    echo "------------------------------------------------------"
    echo "Opening trace file with waveform visualizer GTKWave..."
    echo "------------------------------------------------------"
    echo ""
    gtkwave build/verilator/tb_fifo.vcd &
    exit "$tb_exit_code"
popd >/dev/null
