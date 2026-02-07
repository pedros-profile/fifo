#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
pushd "$SCRIPT_DIR" >/dev/null

    mkdir -p bin

    # Check if GTest libraries exist, if not, build them
    GTEST_INC_DIR="external/googletest/googletest/include"
    GTEST_LIB="bin/libgtest.a"
    GTEST_MAIN_LIB="bin/libgtest_main.a"

    # Should be run only once per googletest version checked out
    if [[ ! -f "$GTEST_LIB" || ! -f "$GTEST_MAIN_LIB" ]]; then
        echo "GTest libraries not found. Running ./cpp/build_gtest.sh first."
        bash ./build_gtest.sh
    fi

    # Clean up previous test executable if it exists
    EXECUTABLE="bin/gtest_fifo"
    if [[ -f "$EXECUTABLE" ]]; then
        echo "Cleaning up previous test executable..."
        rm -f "$EXECUTABLE"
    fi

    # (Re-)Build the test executable
    echo "Building tests..."
    g++ -std=c++17 \
        -I"$GTEST_INC_DIR" \
        -I. \
        gtest_fifo.cpp \
        fifo.h \
        -Lbin \
        -lgtest \
        -lgtest_main \
        -o "$EXECUTABLE" \
        -Wall \
        -g

    echo
    echo "=========================================="
    echo "Running tests..."
    echo "=========================================="
    "$EXECUTABLE"

popd >/dev/null
