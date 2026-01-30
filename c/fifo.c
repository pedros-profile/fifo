#include <stdio.h>
#include <string.h>
#include "fifo.h"

// TODO: Add error handling for overflow and underflow
// TODO: Make ptr_rd and ptr_wr actual pointers
// TODO: Improve create_fifo (to return pointer to heap-allocated fifo)
// TODO: Add unit tests in C
// TODO: Fix caught errors
// TODO: Add is_empty and is_full functions/flags
// TO READ: "Using GCC for compilation" - https://docs.openeuler.org/en/docs/20.03_LTS/docs/ApplicationDev/using-gcc-for-compilation.html#basics

// Get current length of fifo
int get_queue_len(fifo_t* fifo) {
    return (fifo->ptr_wr - fifo->ptr_rd) % DEPTH;
}

// A pseudo-constructor for Fifo
void init_fifo(fifo_t* fifo) {
    fifo->ptr_rd = 0;
    fifo->ptr_wr = 0;
}

// Insert value into fifo
int write(fifo_t* fifo, long val) {
    int queue_len = get_queue_len(fifo);
    if (queue_len != DEPTH - 1) {
        fifo->internal_mem[fifo->ptr_wr] = val;
        fifo->ptr_wr = (fifo->ptr_wr + 1) % DEPTH;
        return queue_len;
    }
    return -1;
}

// Retrieve value from fifo
long read(fifo_t* fifo){
    long val;
    int queue_len = get_queue_len(fifo);
    if (queue_len != 0) {
        val = fifo->internal_mem[fifo->ptr_rd];
        fifo->ptr_rd = (fifo->ptr_rd + 1) % DEPTH;
        return val;
    }
    return -1;
}

// Sanity check
int main() {
    long val;
    fifo_t fifo;
    init_fifo(&fifo);
    printf("Created FIFO with depth %d\n", DEPTH);
    write(&fifo, 42);
    printf("Current queue length: %d\n", get_queue_len(&fifo));
    val = read(&fifo);
    printf("Read value: %ld\n", val);
    return 0;
}
