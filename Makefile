# ===== SHARED VARIABLES =====
ROOT := $(abspath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# ===== C VARIABLES =====
CC := gcc
C_DIR := $(ROOT)/c
C_BIN := $(C_DIR)/bin
C_SRC := $(wildcard $(C_DIR)/*.c)
C_FLAGS := -std=c17 -g -O0 -Wall -Wextra
C_OBJ := $(C_BIN)/fifo.o
C_SO := $(C_BIN)/fifo.so
C_SANITY_EXECUTABLE := $(C_BIN)/fifo_sanity_check
PY_DIR := $(ROOT)/py

# ===== CPP VARIABLES =====
CXX := g++
AR := ar rcs
CXXFLAGS := -std=c++17 -Wall -g
SANITY_CXXFLAGS := -O2
CPP_DIR := $(ROOT)/cpp
CPP_BIN := $(CPP_DIR)/bin
GTEST_DIR := $(CPP_DIR)/external/googletest/googletest
GTEST_OBJ := $(CPP_BIN)/gtest-all.o
GTEST_MAIN_OBJ := $(CPP_BIN)/gtest_main.o
GTEST_LIB := $(CPP_BIN)/libgtest.a
GTEST_MAIN_LIB := $(CPP_BIN)/libgtest_main.a
GTEST_EXEC := $(CPP_BIN)/gtest_fifo
SANITY_EXEC := $(CPP_BIN)/sanity_check_fifo


.PHONY: all run_sanity_c run_cffi run_python clean clean_c \
 build_gtest run_gtest run_sanity_cpp clean_cpp

all: run_sanity_c

# *************************************************************************** #
# 							C IMPLEMENTATION 							      #
# *************************************************************************** #

# C sanity check
run_sanity_c: $(C_SANITY_EXECUTABLE)
	@echo "=========================================="
	@echo "Running sanity check for C version..."
	@echo "=========================================="
	$(C_SANITY_EXECUTABLE)
	@echo ""

$(C_SANITY_EXECUTABLE): $(C_OBJ)
	@echo "=========================================="
	@echo "Building sanity check for C version..."
	@echo "=========================================="
	$(CC) $(C_FLAGS) -o $@ $^
	@echo ""

$(C_OBJ): $(C_DIR)/fifo.c | $(C_BIN)
	@echo "=========================================="
	@echo "Building C version..."
	@echo "=========================================="
	$(CC) $(C_FLAGS) -c $< -o $@
	@echo ""

$(C_BIN):
	mkdir -p $@

# CFFI
run_cffi: $(C_SO)
	@echo "=========================================="
	@echo "Running CFFI tests..."
	@echo "=========================================="
	cd "$(C_DIR)" && \
	python3 -m unittest test_c_model.py -v
	@echo ""

$(C_SO): $(C_SRC) | $(C_BIN)
	@echo "=========================================="
	@echo "Building CFFI library..."
	@echo "=========================================="
	$(CC) -fPIC -shared $(C_FLAGS) -o $@ $^
	@echo "CFFI library $@ built successfully!"
	@echo ""

clean_c:
	rm -rf $(C_BIN)

# *************************************************************************** #
# 						  PYTHON IMPLEMENTATION 						      #
# *************************************************************************** #
run_python:
	@echo "=========================================="
	@echo "Running Python tests..."
	@echo "=========================================="
	cd "$(PY_DIR)" && \
	python3 -m unittest test_python_model.py -v
	@echo ""

# *************************************************************************** #
# 						  C++ IMPLEMENTATION 							      #
# *************************************************************************** #

build_gtest: $(GTEST_LIB) $(GTEST_MAIN_LIB)

$(CPP_BIN):
	mkdir -p $@

$(GTEST_OBJ): $(GTEST_DIR)/src/gtest-all.cc | $(CPP_BIN)
	$(CXX) $(CXXFLAGS) -I$(GTEST_DIR)/include -I$(GTEST_DIR) -c $< -o $@

$(GTEST_MAIN_OBJ): $(GTEST_DIR)/src/gtest_main.cc | $(CPP_BIN)
	$(CXX) $(CXXFLAGS) -I$(GTEST_DIR)/include -I$(GTEST_DIR) -c $< -o $@

$(GTEST_LIB): $(GTEST_OBJ)
	$(AR) $@ $^

$(GTEST_MAIN_LIB): $(GTEST_MAIN_OBJ)
	$(AR) $@ $^

run_gtest: $(GTEST_EXEC)
	@echo "=========================================="
	@echo "Running tests..."
	@echo "=========================================="
	$(GTEST_EXEC)

$(GTEST_EXEC): $(CPP_DIR)/gtest_fifo.cpp $(CPP_DIR)/fifo.h $(GTEST_LIB) $(GTEST_MAIN_LIB) | $(CPP_BIN)
	$(CXX) $(CXXFLAGS) -I$(GTEST_DIR)/include -I$(CPP_DIR) $< -L$(CPP_BIN) -lgtest -lgtest_main -o $@

run_sanity_cpp: $(SANITY_EXEC)
	@echo "-----------------------"
	@echo "Running sanity check..."
	@echo "-----------------------"
	$(SANITY_EXEC)

$(SANITY_EXEC): $(CPP_DIR)/fifo.cpp $(CPP_DIR)/sanity_check_fifo.cpp $(CPP_DIR)/fifo.h | $(CPP_BIN)
	$(CXX) $(SANITY_CXXFLAGS) $(CPP_DIR)/fifo.cpp $(CPP_DIR)/sanity_check_fifo.cpp -o $@

clean_cpp:
	rm -rf $(CPP_BIN)

# *************************************************************************** #
# 						  			CLEAN   							      #
# *************************************************************************** #

clean: clean_c clean_cpp
	@:
