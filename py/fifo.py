"""Python version of FIFO implementation. It is a preview of what the C code should look like."""
# Design parameters
DEPTH = 8
WLEN = 32
# Derived constants
BOUND_LO = -2 ** (WLEN - 1)
BOUND_HI = 2 ** (WLEN - 1) - 1


class Fifo:
    """FIFO class. Slotted class, for gaining performance and fidelity of implementation."""
    __slots__ = "_mem", "_addr_rd", "_addr_wr", "is_empty"

    # ------------- #
    # BASIC METHODS #
    # ------------- #

    def __init__(self):
        self._mem = [0 for _ in range(DEPTH)]
        self._addr_rd = 0
        self._addr_wr = 0
        self.is_empty = True

    def write(self, val):
        """Insert a new value. Raise an error if not possible."""
        self._assert_wr(val)       # Check input value and available space
        self._mem[self._addr_wr] = int(val)
        self._addr_wr += 1
        self._addr_wr %= DEPTH
        self.is_empty = False

    def read(self) -> int:
        """Get the oldest entry in the queue. Raise an error if empty."""
        if self.is_empty:
            raise BufferError("FIFO is empty.")
        val = self._mem[self._addr_rd]
        self._addr_rd += 1
        self._addr_rd %= DEPTH
        if self._addr_rd == self._addr_wr:
            self.is_empty = True
        return val

    # ---------- #
    # PROPERTIES #
    # ---------- #

    @property
    def queue_len(self):
        """Get the number of elements queued."""
        q_len = (self._addr_wr - self._addr_rd) % DEPTH
        if q_len == 0:
            return 0 if self.is_empty else DEPTH
        return q_len

    @property
    def queue(self) -> int:
        """Get FIFO's queue, oldest-to-newest."""
        mem_cp = self._mem[self._addr_rd:] + self._mem[:self._addr_rd]
        return tuple(mem_cp[:self.queue_len])

    @property
    def is_full(self) -> bool:
        """Check if FIFO is full."""
        return not self.is_empty and (self._addr_rd == self._addr_wr)

    # --------------- #
    # PRIVATE METHODS #
    # --------------- #

    def _assert_wr(self, val):
        """Raise an error if the value to be written is invalid."""
        if not (BOUND_LO <= val <= BOUND_HI):
            raise ValueError(f"Value inserted out of bounds: |{val}| > {2**WLEN -1}")
        if val % 1:
            raise ValueError(f"Value inserted is not an integer: {val}")
        if self.is_full:
            raise BufferError(f"FIFO is full. ({DEPTH} words)")

if __name__ == "__main__":
    print("Python version of FIFO")
