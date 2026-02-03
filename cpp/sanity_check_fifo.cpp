#include <iostream>
#include <map>
#include "fifo.h"

using namespace std;

const map<fifo_status_t, string> fifo_st_map = {
    {fifo_status_t::EMPTY, "EMPTY"},
    {fifo_status_t::FULL, "FULL"},
    {fifo_status_t::PARTIAL, "PARTIAL"},
    {fifo_status_t::OVERFLOW, "OVERFLOW"},
    {fifo_status_t::UNDERFLOW, "UNDERFLOW"}};


int main() {
#ifdef __cplusplus
    cout << "C++ standard version: " << __cplusplus << "\n" << endl;
#endif

    Fifo fifo;
    long val;
    fifo_status_t stat;
    cout << "Created a FIFO object.\n" << endl;

    stat = fifo.write(101);
    cout << "Value 101 written in the FIFO." << endl;
    cout << "Status: " << stat << " (" << fifo_st_map.at(stat) << ")" << "\n" << endl;

    stat = fifo.read(&val);
    cout << "Read value " << val << " from FIFO." << endl;
    cout << "Status: " << stat << " (" << fifo_st_map.at(stat) << ")" << "\n" << endl;
    return 0;
}
