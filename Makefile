# ===== SHARED VARIABLES =====
ROOT := $(shell pwd)

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

.PHONY: all run_sanity_c run_cffi_tests run_python clean clean-c

all: run_sanity_c

# C sanity check
run_sanity_c: $(C_SANITY_EXECUTABLE)
	@echo "*****************************************"
	@echo "* Running sanity check for C version... *"
	@echo "*****************************************"
	$(C_SANITY_EXECUTABLE)
	@echo ""

$(C_SANITY_EXECUTABLE): $(C_OBJ)
	@echo "******************************************"
	@echo "* Building sanity check for C version... *"
	@echo "******************************************"
	$(CC) $(C_FLAGS) -o $@ $^
	@echo ""

$(C_OBJ): $(C_SRC) | $(C_BIN)
	@echo "*************************"
	@echo "* Building C version... *"
	@echo "*************************"
	$(CC) $(C_FLAGS) -c $< -o $@
	@echo ""

$(C_BIN):
	mkdir -p $@

# CFFI
run_cffi_tests: $(C_SO)
	@echo "*************************"
	@echo "* Running CFFI tests... *"
	@echo "*************************"
	python3 -c "import cffi; ffi = cffi.FFI(); lib = ffi.dlopen('$(C_SO)'); print(lib.fifo_sanity_check())"
	@echo ""

$(C_SO): $(C_SRC) | $(C_BIN)
	@echo "****************************"
	@echo "* Building CFFI library... *"
	@echo "****************************"
	$(CC) -fPIC -shared $(C_FLAGS) -o $@ $^
	@echo "CFFI library $@ built successfully!"
	@echo ""

# PYTHON TESTS
run_python:
	@echo "***************************"
	@echo "* Running Python tests... *"
	@echo "***************************"
	cd "$(PY_DIR)" && \
	python3 -m unittest test_python_model.py -v
	@echo ""

clean: clean-c
	@:

clean-c:
	rm -rf $(C_BIN)

