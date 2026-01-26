"""Python version of FIFO implementation."""
# Design parameters
DEPTH = 8
WLEN = 32
# Derived constants
BOUND_LO = -2 ** (WLEN - 1)
BOUND_HI = 2 ** (WLEN - 1) - 1


class Fifo:
    """FIFO class."""
    __slots__ = "__mem", "__ptr_rd", "__ptr_wr"

    # ------------- #
    # BASIC METHODS #
    # ------------- #

    def __init__(self):
        self.__mem = [0 for _ in range(DEPTH)]
        self.__ptr_rd = 0
        self.__ptr_wr = 0

    def write(self, val) -> int:
        """Insert a new value to FIFO. Raise an error if val is out of bounds or if there's no room for new entries."""
        self._assert_wr(val)       # Check input value and available space
        self.__mem[self.__ptr_wr] = int(val)
        self.__ptr_wr += 1
        self.__ptr_wr %= DEPTH
        return self.__ptr_wr - self.__ptr_rd

    def read(self) -> int:
        """Get the oldest entry in the queue. Raise an error if empty."""
        self._assert_rd()       # Check for available data
        val = self.__mem[self.__ptr_rd]
        self.__ptr_rd += 1
        self.__ptr_rd %= DEPTH
        return val

    # ---------- #
    # PROPERTIES #
    # ---------- #

    @property
    def queue(self) -> int:
        """Get total of entries currently in the FIFO."""
        mem_cp = self.__mem[self.__ptr_rd:] + self.__mem[:self.__ptr_rd]
        return tuple(*mem_cp[:self.queue_len])

    @property
    def ptr_rd(self):
        return self.__ptr_rd

    @property
    def ptr_wr(self):
        return self.__ptr_wr

    @property
    def queue_len(self):
        return (self.__ptr_wr - self.__ptr_rd + DEPTH) % DEPTH

    # --------------- #
    # PRIVATE METHODS #
    # --------------- #

    def _assert_wr(self, val):
        if not (BOUND_LO <= val <= BOUND_HI):
            raise ValueError(f"Value inserted out of bounds: |{val}| > {2**WLEN -1}")
        if val % 1:
            raise ValueError(f"Value inserted is not an integer: {val}")
        if self.queue_len == DEPTH:
            raise BufferError(f"FIFO is full. ({DEPTH} words)")

    def _assert_rd(self):
        if self.__ptr_rd == self.__ptr_wr:
            raise BufferError("No new values to FIFO yet.")

if __name__ == "__main__":
    print("Python version of FIFO")
