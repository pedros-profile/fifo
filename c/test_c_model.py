"""General functionality testing of FIFO.

This implementation fits both FIFO Python versions; FifoRef and Fifo.
To be used as a template for the other implementations.
"""

# Standard library imports
import os
import unittest
import random
import time

# Setup CFFI to load C FIFO implementation
# This will compile the C code and load the resulting DLL
from cffi_load import ffi, lib

# Clean CLI
time.sleep(3)   # Give some time for the user to read any compilation errors
os.system("cls" if os.name == "nt" else "clear")

# Project constants
DEPTH = lib.DEPTH
WLEN = 32
MIN_VALUE = - 2 ** (WLEN - 1)
MAX_VALUE = 2 ** (WLEN - 1) - 1

# TODO: create a ERR component in C code to avoid using -1 as error code?

class TestFifoPython(unittest.TestCase):
    def setUp(self):
        self.dut_ptr = ffi.new("fifo_t*")
        lib.init_fifo(self.dut_ptr)

    def test_read_back(self):
        """Write and read back one value a time. Assert read values match."""
        for _ in range(DEPTH + 2):
            val = random.randint(MIN_VALUE, MAX_VALUE)
            lib.write(self.dut_ptr, val)
            dut_val = lib.read(self.dut_ptr)
            self.assertEqual(dut_val, val)

    def test_read_back_constant(self):
        """Write a bulk of values, then read them all back. Assert read values match."""
        values = [*range(DEPTH)]
        for val in values:
            dut_res = lib.write(self.dut_ptr, val)
            self.assertNotEqual(dut_res, -1, msg=f"Failed to write value {val}.")
        for idx, val in enumerate(values):
            dut_val = lib.read(self.dut_ptr)
            self.assertEqual(dut_val, val, msg=f"Read value mismatch at entry #{idx}.")

    def test_overflow(self):
        """Check if overflow raises BufferError."""
        for idx in range(DEPTH):
            dut_res = lib.write(self.dut_ptr, idx)
            self.assertNotEqual(dut_res, -1, msg=f"Failed to write at position {idx}.")
        dut_res = lib.write(self.dut_ptr, 100)
        self.assertEqual(dut_res, -1)

    def test_underflow(self):
        """Check if underflow raises BufferError at startup and runtime."""
        # test startup underflow
        dut_res = lib.read(self.dut_ptr)
        self.assertEqual(dut_res, -1)
        # write some random values without overflowing it
        values = [random.randint(MIN_VALUE, MAX_VALUE) for _ in range(random.randint(1, DEPTH - 1))]
        for val in values:
            dut_res = lib.write(self.dut_ptr, val)
            self.assertNotEqual(dut_res, -1)
        # read them all back
        for _ in values:
            lib.read(self.dut_ptr)
        # test runtime underflow
        dut_val = lib.read(self.dut_ptr)
        self.assertEqual(dut_val, -1)

    # TODO: add is_empty and is_full to C model
    def test_under_and_overflow(self):
        """Test a full cycle of filling and emptying the FIFO twice."""
        for _ in range(2):
            rnd_values = [random.randint(MIN_VALUE, MAX_VALUE) for _ in range(DEPTH + 3)]
            rnd_values[DEPTH] = 123     # Make sure this one isn't -1
            expetced_values = rnd_values[:DEPTH]
            # Write up to one less than full
            for val in expetced_values[:-1]:
                dut_res = lib.write(self.dut_ptr, val)
                self.assertNotEqual(dut_res, -1)
                # self.assertFalse(self.dut.is_empty)
                # self.assertFalse(self.dut.is_full)
            # Insert last value to fill FIFO
            dut_res = lib.write(self.dut_ptr, expetced_values[-1])
            self.assertNotEqual(dut_res, -1)
            # self.assertFalse(self.dut.is_empty)
            # self.assertTrue(self.dut.is_full)
            # Read back all expected values but one
            for val in expetced_values[:-1]:
                val_dut = lib.read(self.dut_ptr)
                self.assertEqual(val_dut, val)
                # self.assertFalse(self.dut.is_empty)
                # self.assertFalse(self.dut.is_full)
            # Read last expected value, emptying FIFO
            val_dut = lib.read(self.dut_ptr)
            self.assertEqual(val_dut, expetced_values[-1])
            # self.assertTrue(self.dut.is_empty)
            # self.assertFalse(self.dut.is_full)
            # Test underflow
            dut_res = lib.read(self.dut_ptr)
            self.assertEqual(dut_res, -1)
            # self.assertTrue(self.dut.is_empty)
            # self.assertFalse(self.dut.is_full)

    def test_value_bounds(self):
        """Test that values written respect bounds and format."""
        # Lower than minimum
        with self.assertRaises(OverflowError):
            dut_res = lib.write(self.dut_ptr, MIN_VALUE - 1)
        # Higher than maximum
        with self.assertRaises(OverflowError):
            dut_res = lib.write(self.dut_ptr, MAX_VALUE + 1)
        # Non-integer value
        with self.assertRaises(TypeError):
            lib.write(self.dut_ptr, 3.14)
        # Valid: lower bound
        dut_res = lib.write(self.dut_ptr, MIN_VALUE)
        self.assertNotEqual(dut_res, -1)
        # Valid: upper bound
        dut_res = lib.write(self.dut_ptr, MAX_VALUE)
        self.assertNotEqual(dut_res, -1)

if __name__ == "__main__":
    unittest.main(verbosity=0)
