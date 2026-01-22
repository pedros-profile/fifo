"""Python version of FIFO implementation."""
DEPTH = 8
WLEN = 32
PTR_RD_INIT = 0
PTR_WR_INIT = 0

class Fifo:
    """FIFO class."""
    __slots__ = "__internal_mem", "__ptr_rd", "__ptr_wr"
    BOUND_LO = -2 ** (WLEN - 1)
    BOUND_HI = 2 ** (WLEN - 1) - 1

    def __init__(self):
        self.__internal_mem = [0 for _ in range(DEPTH)]
        self.__ptr_rd = PTR_RD_INIT
        self.__ptr_wr = PTR_WR_INIT

    def write(self, val) -> int:
        """Insert a new value to FIFO. Raise an error if val is out of bounds or if there's no room for new entries."""
        self._assert_val(val)
        self._assert_wr()
        self.__internal_mem[self.__ptr_wr] = int(val)
        self.__ptr_wr += 1
        self.__ptr_wr %= DEPTH
        return self.__ptr_wr - self.__ptr_rd
    
    def read(self) -> int:
        """Get the oldest entry in the queue. Raise an error if all have already been read or none been written."""
        self._assert_rd()
        val = self.__internal_mem[self.__ptr_rd]
        self.__ptr_rd += 1
        self.__ptr_rd %= DEPTH
        return val

    def queue(self) -> int:
        """Get"""
        mem_cp = self.__internal_mem[self.__ptr_rd:] + self.__internal_mem[:self.__ptr_rd]
        return tuple(*mem_cp[:self.queue_len])

    # -------------------------- #
    # SUPPORT METHODS/PROPERTIES #
    # -------------------------- #

    @property
    def queue_len(self):
        return (self.__ptr_wr - self.__ptr_rd + DEPTH) % DEPTH

    @classmethod
    def _assert_val(cls, val):
        if not (cls.BOUND_LO <= val <= cls.BOUND_HI):
            raise ValueError(f"Value inserted out of bounds: |{val}| > {2**WLEN}")
        if val % 1:
            raise ValueError(f"Value inserted is not an integer: {val}")
    
    def _assert_wr(self):
        if self.queue_len == DEPTH:
            raise BufferError(f"FIFO is full. ({DEPTH} words)")

    def _assert_rd(self):
        if self.__ptr_rd == self.__ptr_wr:
            raise BufferError("No new values to FIFO yet.")
