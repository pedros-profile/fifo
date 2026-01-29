#include <stdio.h>

#define DEPTH 8
// WLEN is not necessary here

typedef struct {
    int ptr_rd;
    int ptr_wr;
    long internal_mem[DEPTH];
} fifo_t;

// Get current length of fifo
int get_queue_len(fifo_t* fifo) {
    return (fifo->ptr_wr - fifo->ptr_rd) % DEPTH;
}

// A pseudo-constructor for Fifo
fifo_t create_fifo() {
    fifo_t fifo;
    fifo.ptr_rd = 0;
    fifo.ptr_wr = 0;
    for (int idx = 0; idx < DEPTH; idx++) {
        fifo.internal_mem[idx] = 0;
    }
    return fifo;
}

// Insert value into fifo
int write(fifo_t* fifo, long val) {
    int queue_len = get_queue_len(fifo);
    if (queue_len != DEPTH - 1) {
        fifo->internal_mem[fifo->ptr_wr % DEPTH] = val;
        fifo->ptr_wr++;
        return queue_len;
    }
    return -1;
}

// Retrieve value from fifo
long read(fifo_t* fifo){
    long val;
    int queue_len = get_queue_len(fifo);
    if (queue_len != 0) {
        val = fifo->internal_mem[fifo->ptr_rd % DEPTH];
        fifo->ptr_rd++;
        return val;
    }
    return -1;
}

// Sanity check
int main() {
    long val;
    fifo_t fifo = create_fifo();
    printf("Created FIFO with depth %d\n", DEPTH);
    printf("Current queue length: %d\n", get_queue_len(&fifo));
    write(&fifo, 42);
    val = read(&fifo);
    printf("Read value: %ld\n", val);
    return 0;
}
