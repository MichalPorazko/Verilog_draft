# Grouped CLA formal verification

The synthesizable sources remain Verilog-2001. The harnesses use Yosys formal
extensions and are read with `read -formal` through the SBY configuration files.

Run all three proofs from this directory with:

```sh
bash run_formal.sh
```

The default `BIT_WIDTH=6` and `GROUP_SIZE=4` case deliberately proves the
non-divisible `4 + 2` grouping. Formal elaborates one parameter set at a time,
so the final tapeout width should also be proved explicitly.

The `calc_carries` reference is not copied from the DUT output. It independently
computes `c[i+1] = g[i] | (p[i] & c[i])` from the symbolic inputs and compares
that reference vector with the expanded look-ahead implementation.
