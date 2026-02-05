#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "$SCRIPT_DIR" >/dev/null

    mkdir -p bin

    GTEST_DIR="external/googletest/googletest"
    GTEST_OBJ="bin/gtest-all.o"
    GTEST_MAIN_OBJ="bin/gtest_main.o"
    GTEST_LIB="bin/libgtest.a"
    GTEST_MAIN_LIB="bin/libgtest_main.a"

    if [[ -f "$GTEST_OBJ" ]]; then
        rm -f "$GTEST_OBJ"
    fi
    if [[ -f "$GTEST_MAIN_OBJ" ]]; then
        rm -f "$GTEST_MAIN_OBJ"
    fi

    if [[ -f "$GTEST_LIB" ]]; then
        rm -f "$GTEST_LIB"
    fi
    if [[ -f "$GTEST_MAIN_LIB" ]]; then
        rm -f "$GTEST_MAIN_LIB"
    fi

    echo "Building GTest libraries..."

    g++ -std=c++17 \
        -I"$GTEST_DIR/include" \
        -I"$GTEST_DIR" \
        -c "$GTEST_DIR/src/gtest-all.cc" \
        -o "$GTEST_OBJ"

    ar rcs "$GTEST_LIB" "$GTEST_OBJ"

    g++ -std=c++17 \
        -I"$GTEST_DIR/include" \
        -I"$GTEST_DIR" \
        -c "$GTEST_DIR/src/gtest_main.cc" \
        -o "$GTEST_MAIN_OBJ"

    ar rcs "$GTEST_MAIN_LIB" "$GTEST_MAIN_OBJ"

    echo "Built: $GTEST_LIB"
    echo "Built: $GTEST_MAIN_LIB"

popd >/dev/null
