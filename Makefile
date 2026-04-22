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

# ===== SV VARIABLES =====
SV_DIR := $(ROOT)/sv
SV_BUILD_DIR := $(SV_DIR)/build
SV_OUT_DIR := $(SV_BUILD_DIR)/verilator
SV_OBJ_DIR := $(SV_OUT_DIR)/obj
SV_EXEC := $(SV_OUT_DIR)/tb_fifo
SV_VCD := $(SV_OUT_DIR)/tb_fifo.vcd


.PHONY: all run_sanity_c run_cffi run_python clean clean_c \
 build_gtest run_gtest run_sanity_cpp clean_cpp run_sv_tb

all: run_cffi run_python run_gtest run_sv_tb


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
	if !(python3 -m unittest test_c_model.py -v); then \
		echo "" && \
		echo "******************"; \
		echo "CFFI tests failed!"; \
		echo "******************"; \
	fi
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
# 						   SYSTEMVERILOG IMPLEMENTATION 					  #
# *************************************************************************** #

$(SV_OBJ_DIR):
	mkdir -p $@

$(SV_EXEC): $(SV_DIR)/tb_fifo.sv $(SV_DIR)/fifo.sv | $(SV_OBJ_DIR)
	@echo "=========================================="
	@echo "Compiling SV TestBench with Verilator..."
	@echo "=========================================="
	verilator --binary -Wall -Wno-DECLFILENAME --timing -sv --trace $^ \
	 --Mdir $(SV_OBJ_DIR) -o $(SV_EXEC) -DWIDTH=32 -DDEPTH=8 -I$(SV_DIR) \
	 --top-module tb_fifo -DDUMPFILE=\"$(SV_VCD)\"
	@echo ""

$(SV_VCD): $(SV_EXEC)
	@echo "=========================================="
	@echo "Running SV testbench..."
	@echo "=========================================="
	cd $(SV_DIR) && \
	$(SV_EXEC)
	@echo ""

run_sv_tb: $(SV_VCD)

view_waveform: $(SV_VCD)
	@echo "=========================================="
	@echo "Opening waveform..."
	@echo "=========================================="
	gtkwave $(SV_VCD) &
	@echo ""

clean_sv:
	rm -rf $(SV_BUILD_DIR)

# *************************************************************************** #
# 						  			CLEAN   							      #
# *************************************************************************** #

clean: clean_c clean_cpp clean_sv
	@:
