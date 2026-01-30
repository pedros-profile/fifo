#define DEPTH 8

typedef struct {
    int ptr_rd;
    int ptr_wr;
    long internal_mem[DEPTH];
} fifo_t;

void init_fifo(fifo_t* fifo);
int get_queue_len(fifo_t* fifo);
int write(fifo_t* fifo, long val);
long read(fifo_t* fifo);
