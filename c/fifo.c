#include <stdio.h>
#include <string.h>
#include "fifo.h"

// TO READ: "Using GCC for compilation" - https://docs.openeuler.org/en/docs/20.03_LTS/docs/ApplicationDev/using-gcc-for-compilation.html#basics

// Get current length of fifo
int get_queue_len(fifo_t* fifo) {
    switch (fifo->status) {
        case EMPTY:
            return 0;
        case FULL:
            return DEPTH;
        case PARTIAL:
        default:
            return (fifo->addr_wr - fifo->addr_rd) % DEPTH;
    }
}

// A pseudo-constructor for Fifo
void init_fifo(fifo_t* fifo) {
    fifo->addr_rd = 0;
    fifo->addr_wr = 0;
    fifo->status = EMPTY;
}

// Insert value into fifo
signed char write(fifo_t* fifo, long val) {
    // If full, flag as an error
    if (fifo->status == FULL) {
        return OVERFLOW;
    }
    fifo->internal_mem[fifo->addr_wr] = val;
    fifo->addr_wr = (fifo->addr_wr + 1) % DEPTH;
    fifo->status = (fifo->addr_wr == fifo->addr_rd) ? FULL : PARTIAL;
    return fifo->status;
}

// Retrieve value from fifo
signed char read(fifo_t* fifo, long* val){
    if (fifo->status == EMPTY) {
        return UNDERFLOW;
    }
    *val = fifo->internal_mem[fifo->addr_rd];
    fifo->addr_rd = (fifo->addr_rd + 1) % DEPTH;
    fifo->status = (fifo->addr_rd == fifo->addr_wr) ? EMPTY : PARTIAL;
    return fifo->status;
}

// Sanity check
int main() {

#ifdef __STDC_VERSION__
    printf("C standard version: %lu\n",__STDC_VERSION__);
#endif

    long val;
    fifo_t fifo;
    init_fifo(&fifo);
    printf("Created FIFO with depth %d\n", DEPTH);
    write(&fifo, 42);
    printf("Current queue length: %d\n", get_queue_len(&fifo));
    read(&fifo, &val);
    printf("Read value: %ld\n", val);
    return 0;
}
