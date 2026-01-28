# Standard library imports
import unittest
import random

# Project imports
from fifo import Fifo, DEPTH, WLEN

# Project constants
MIN_VALUE = - 2 ** (WLEN - 1)
MAX_VALUE = 2 ** (WLEN - 1) - 1


class TestFifoPython(unittest.TestCase):
    def setUp(self):
        self.dut = Fifo()

    def test_read_back(self):
        """Write and read back one value a time. Assert read values match."""
        for _ in range(DEPTH + 2):
            val = random.randint(MIN_VALUE, MAX_VALUE)
            self.dut.write(val)
            self.assertTrue(val == self.dut.read())

    def test_read_back_constant(self):
        """Write a bulk of values, then read them all back. Assert read values match."""
        values = [-3, 4, 0, -90, -120, 45, 2, -7][:DEPTH]
        for val in values:
            self.dut.write(val)
        for val in values:
            self.assertTrue(self.dut.read() == val)

    def test_overflow(self):
        """Check if overflow raises BufferError."""
        for idx in range(DEPTH):
            self.dut.write(idx)
        with self.assertRaises(BufferError):
            self.dut.write(100)

    def test_underflow(self):
        """Check if underflow raises BufferError at startup and runtime."""
        # test startup underflow
        with self.assertRaises(BufferError):
            self.dut.read()
        # write some random values without overflowing it
        values = [random.randint(MIN_VALUE, MAX_VALUE) for _ in range(random.randint(1, DEPTH - 1))]
        for val in values:
            self.dut.write(val)
        # read them all back
        for _ in values:
            self.dut.read()
        # test runtime underflow
        with self.assertRaises(BufferError):
            self.dut.read()

    def test_under_and_overflow(self):
        """Test a full cycle of filling and emptying the FIFO twice."""
        for _ in range(2):
            rnd_values = [random.randint(MIN_VALUE, MAX_VALUE) for _ in range(DEPTH + 3)]
            expetced_values = rnd_values[:DEPTH]
            # Write up to one less than full
            for val in expetced_values[:-1]:
                self.dut.write(val)
                self.assertFalse(self.dut.is_empty)
                self.assertFalse(self.dut.is_full)
            # Insert last value to fill FIFO
            self.dut.write(expetced_values[-1])
            self.assertFalse(self.dut.is_empty)
            self.assertTrue(self.dut.is_full)
            # Read back all expected values but one
            for val in expetced_values[:-1]:
                val_dut = self.dut.read()
                self.assertTrue(val == val_dut)
                self.assertFalse(self.dut.is_empty)
                self.assertFalse(self.dut.is_full)
            # Read last expected value, emptying FIFO
            val_dut = self.dut.read()
            self.assertTrue(expetced_values[-1] == val_dut)
            self.assertTrue(self.dut.is_empty)
            self.assertFalse(self.dut.is_full)
            # Test underflow
            with self.assertRaises(BufferError):
                self.dut.read()
            self.assertTrue(self.dut.is_empty)
            self.assertFalse(self.dut.is_full)

    def test_value_bounds(self):
        """Test that values written respect bounds and format."""
        with self.assertRaises(ValueError):
            self.dut.write(MIN_VALUE - 1)
        with self.assertRaises(ValueError):
            self.dut.write(MAX_VALUE + 1)
        with self.assertRaises(ValueError):
            self.dut.write(3.14)
        self.dut.write(MIN_VALUE)
        self.dut.write(MAX_VALUE)

if __name__ == "__main__":
    unittest.main(verbosity=0)
