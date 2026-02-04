#include <iostream>
#include "fifo.h"

Fifo::Fifo() {
    addr_rd = 0;
    addr_wr = 0;
    status = EMPTY;
}

fifo_status_t Fifo::read(long* val) {
    if (status == EMPTY) {return UNDERFLOW;}

    *val = internal_mem[addr_rd];
    addr_rd = (addr_rd + 1) % DEPTH;

    if (addr_rd == addr_wr) {
        status = EMPTY;
    }
    else {
        status = PARTIAL;
    }
    return status;
}

fifo_status_t Fifo::write(long val) {
    if (status == FULL) {return OVERFLOW;}

    internal_mem[addr_wr] = val;
    addr_wr = (addr_wr + 1) % DEPTH;
    if (addr_rd == addr_wr) {
        status = FULL;
    }
    else {
        status = PARTIAL;
    }
    return status;
}
