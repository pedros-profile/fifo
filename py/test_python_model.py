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
        values = [random.randint(MIN_VALUE, MAX_VALUE) for _ in range(20)]
        for val in values:
            self.dut.write(val)
            val_dut = self.dut.read()
            self.assertTrue(val == val_dut, msg="Value #{idx}: {val}")

    def test_overflow(self):
        for idx in range(DEPTH):
            self.dut.write(idx)
        with self.assertRaises(BufferError):
            self.dut.write(100)

    # TODO: add a under/overflow combined test
    def test_underflow(self):
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

    def test_value_bounds(self):
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
