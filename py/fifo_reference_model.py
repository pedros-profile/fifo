MIN_VALUE = - 2 ** 31
MAX_VALUE = 2 ** 31 - 1

class FifoRef:
    """High-level model of a FIFO. It simulates depth, empty/full flags and data format constraints."""

    def __init__(self, depth=8):
        self.depth = depth
        self.queue = []

    def write(self, value):
        if not (MIN_VALUE <= value <= MAX_VALUE) or value % 1:
            raise ValueError(f"Value out of bounds ({value})")
        if self.is_full:
            raise BufferError("FIFO is full")
        self.queue.append(value)

    def read(self):
        if len(self.queue) == 0:
            raise BufferError("FIFO is empty")
        return self.queue.pop(0)

    @property
    def queue_len(self):
        return len(self.queue)

    @property
    def is_empty(self):
        return len(self.queue) == 0

    @property
    def is_full(self):
        return len(self.queue) >= self.depth
