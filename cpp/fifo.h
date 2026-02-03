#define DEPTH 8

enum fifo_status_t {
    EMPTY = 0,
    FULL = 1,
    PARTIAL = 2,
    OVERFLOW = -1,  // To be used as a return value only
    UNDERFLOW = -2, // To be used as a return value only
};

class Fifo {
    public:
        fifo_status_t status;
        Fifo();
        fifo_status_t read(long* val);
        fifo_status_t write(long val);

    protected:
        int addr_rd;
        int addr_wr;
        long internal_mem[DEPTH];
};
