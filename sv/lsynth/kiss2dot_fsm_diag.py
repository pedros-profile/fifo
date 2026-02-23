#!/usr/bin/env python3
"""Convert kiss2 fsm extraction to dot diagram.

How to generate the kiss2 file at Yosys: at the fsm step,
apply the commands
> fsm -nomap
> fsm_export -o fsm.kiss2

Note that it won't generate an fsm.kiss2 file unless it detects a complete
FSM with 2-bits or more.
"""

import fileinput

print("digraph fsm {")

for line in fileinput.input():
    if not line.startswith("."):
        in_bits, from_state, to_state, out_bits = line.split()
        print("%s -> %s [label=\"IN=%s,\\nOUT=%s\"];" % (from_state, to_state,
                in_bits.replace("-", "?"), out_bits.replace("-", "?")))

print("}")
