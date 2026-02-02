"""General functionality testing of FIFO.

This implementation fits both FIFO Python versions; FifoRef and Fifo.
To be used as a template for the other implementations.
"""

# Standard library imports
import unittest
import random

# Setup CFFI to load C FIFO implementation
# This will compile the C code and load the resulting DLL
import cffi_load
ffi, lib = cffi_load.cffi_load()
# ffi, lib = cffi_load.compile_ffi()

# Project constants
DEPTH = lib.DEPTH
WLEN = 32   # long
MIN_VALUE = - 2 ** (WLEN - 1)
MAX_VALUE = 2 ** (WLEN - 1) - 1


class TestFifoPython(unittest.TestCase):
    def setUp(self):
        self.dut_ptr = ffi.new("fifo_t*")
        lib.init_fifo(self.dut_ptr)

    def test_read_back(self):
        """Write and read back one value a time. Assert read values match."""
        dut_val = ffi.new("long*")
        for _ in range(DEPTH + 2):
            val = random.randint(MIN_VALUE, MAX_VALUE)
            lib.write(self.dut_ptr, val)
            lib.read(self.dut_ptr, dut_val)
            self.assertEqual(dut_val[0], val)

    def test_read_back_constant(self):
        """Write a bulk of values, then read them all back. Assert read values match."""
        dut_val = ffi.new("long*")
        values = [*range(DEPTH - 1)]
        for val in values:
            stat = lib.write(self.dut_ptr, val)
            self.assertEqual(stat, lib.PARTIAL, msg=f"Failed to write value {val}.")
        for idx, val in enumerate(values):
            stat = lib.read(self.dut_ptr, dut_val)
            self.assertEqual(int(dut_val[0]), val, msg=f"Read value mismatch at entry #{idx}.")

    def test_overflow(self):
        """Check if overflow raises BufferError."""
        # Almost fill up FIFO
        for idx in range(DEPTH - 1):
            stat = lib.write(self.dut_ptr, idx)
            self.assertEqual(stat, lib.PARTIAL, msg=f"Failed to write at position {idx}.")
        # Make it full
        stat = lib.write(self.dut_ptr, 100)
        self.assertEqual(self.dut_ptr.status, lib.FULL)
        self.assertEqual(stat, lib.FULL)
        # Make it overflow
        stat = lib.write(self.dut_ptr, 101)
        self.assertEqual(self.dut_ptr.status, lib.FULL)
        self.assertEqual(stat, lib.OVERFLOW)

    def test_underflow(self):
        """Check if underflow raises BufferError at startup and runtime."""
        # test startup underflow
        dut_val = ffi.new("long*")
        dut_val[0] = -117
        stat = lib.read(self.dut_ptr, dut_val)
        self.assertEqual(stat, lib.UNDERFLOW)   # checks if underflow is raised
        self.assertEqual(dut_val[0], -117)      # checks if pointed value remains
        # write some random values (but not fill up)
        values = [random.randint(MIN_VALUE, MAX_VALUE) for _ in range(random.randint(1, DEPTH - 1))]
        for val in values:
            stat = lib.write(self.dut_ptr, val)
            self.assertEqual(stat, lib.PARTIAL)
        # read them all back
        for _ in values:
            stat = lib.read(self.dut_ptr, dut_val)
            self.assertNotEqual(stat, lib.UNDERFLOW)
        # test runtime underflow
        prev_val = dut_val[0]                   # store the previously pointed value
        stat = lib.read(self.dut_ptr, dut_val)
        self.assertEqual(stat, lib.UNDERFLOW)
        self.assertEqual(prev_val, dut_val[0])  # previous value remains?

    def test_under_and_overflow_cycle(self):
        """Test a full cycle of filling and emptying the FIFO twice."""
        dut_val = ffi.new("long*")
        for _ in range(2):
            # Prepare values to be written/read
            expected_values = [random.randint(MIN_VALUE, MAX_VALUE) for _ in range(DEPTH)]
            excess_values = [random.randint(MIN_VALUE, MAX_VALUE) for _ in range(DEPTH // 4)]
            self.assertEqual(self.dut_ptr.status, lib.EMPTY)
            # Write up to one less than full
            for val in expected_values[:-1]:
                stat = lib.write(self.dut_ptr, val)
                self.assertEqual(stat, lib.PARTIAL)
                self.assertEqual(self.dut_ptr.status, lib.PARTIAL)
            # Insert last value to fill FIFO
            stat = lib.write(self.dut_ptr, expected_values[-1])
            self.assertEqual(stat, lib.FULL)
            self.assertEqual(self.dut_ptr.status, lib.FULL)
            # Get overflow error
            for val in excess_values:
                stat = lib.write(self.dut_ptr, val)
                self.assertEqual(stat, lib.OVERFLOW)
                self.assertEqual(self.dut_ptr.status, lib.FULL)
            # Read back all expected values but one
            for val in expected_values[:-1]:
                stat = lib.read(self.dut_ptr, dut_val)
                self.assertEqual(stat, lib.PARTIAL)
                self.assertEqual(self.dut_ptr.status, lib.PARTIAL)
                self.assertEqual(dut_val[0], val)
            # Read last expected value, emptying FIFO
            stat = lib.read(self.dut_ptr, dut_val)
            self.assertEqual(stat, lib.EMPTY)
            self.assertEqual(self.dut_ptr.status, lib.EMPTY)
            self.assertEqual(dut_val[0], expected_values[-1])
            # Test underflow
            for _ in excess_values:
                stat = lib.read(self.dut_ptr, dut_val)
                self.assertEqual(stat, lib.UNDERFLOW)
                self.assertAlmostEqual(self.dut_ptr.status, lib.EMPTY)  # DUT is flagging EMPTY
                self.assertEqual(dut_val[0], expected_values[-1])       # ptr unchanged?

    def test_value_bounds(self):
        """Test that values written respect bounds and format."""
        # Lower than minimum
        with self.assertRaises(OverflowError):
            stat = lib.write(self.dut_ptr, MIN_VALUE - 1)
        # Higher than maximum
        with self.assertRaises(OverflowError):
            stat = lib.write(self.dut_ptr, MAX_VALUE + 1)
        # Non-integer value
        with self.assertRaises(TypeError):
            lib.write(self.dut_ptr, 3.14)
        # Valid: lower bound
        stat = lib.write(self.dut_ptr, MIN_VALUE)
        self.assertEqual(stat, lib.PARTIAL)
        # Valid: upper bound
        stat = lib.write(self.dut_ptr, MAX_VALUE)
        self.assertEqual(stat, lib.PARTIAL)

if __name__ == "__main__":
    unittest.main(verbosity=0)
