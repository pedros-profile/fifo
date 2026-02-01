#define DEPTH 8

typedef enum FifoStatus {
    EMPTY,
    FULL,
    PARTIAL,
    OVERFLOW,  // To be used as a return value only
    UNDERFLOW, // To be used as a return value only
} fifo_status_t;

// TODO: add header pre-processing for datatypes
typedef struct {
    int addr_rd;
    int addr_wr;
    long internal_mem[DEPTH];
    fifo_status_t status;
} fifo_t;

void init_fifo(fifo_t* fifo);
int get_queue_len(fifo_t* fifo);
signed char write(fifo_t* fifo, long val);
signed char read(fifo_t* fifo, long* val);
