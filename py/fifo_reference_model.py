MIN_VALUE = - 2 ** 31
MAX_VALUE = 2 ** 31 - 1

class FifoRef:
    """High-level model of a FIFO. It simulates depth, empty/full flags and data format constraints."""

    def __init__(self, depth=8):
        self.__depth = depth
        self._queue = []

    def write(self, value):
        if not (MIN_VALUE <= value <= MAX_VALUE) or value % 1:
            raise ValueError(f"Value out of bounds ({value})")
        if self.is_full:
            raise BufferError("FIFO is full")
        self._queue.append(value)

    def read(self):
        if self.is_empty:
            raise BufferError("FIFO is empty")
        return self._queue.pop(0)

    @property
    def queue_len(self):
        return len(self._queue)

    @property
    def is_empty(self):
        return len(self._queue) == 0

    @property
    def is_full(self):
        return len(self._queue) >= self.__depth

    @property
    def queue(self):
        return tuple(self._queue)
