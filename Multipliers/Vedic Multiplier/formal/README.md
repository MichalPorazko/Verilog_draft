# Vedic multiplier formal verification

Run the combinational, short-pipeline, and long-pipeline proofs with:

```sh
bash run_formal.sh
```

The runner copies the actual RTL into a local `work/` directory because several
repository paths contain spaces. The default width is six bits, which exercises
an even multiplier whose four internal multipliers are three-bit odd-width
instances.

The combinational proof checks `out == a * b` for arbitrary symbolic operands.
The short-pipeline proof checks a one-cycle data/valid delay. The long-pipeline
proof checks a four-cycle data/valid delay. The multiplication reference operands
are explicitly widened before `*` so the reference result is not truncated by
Verilog expression sizing.

Formal elaborates one parameter set at a time. Run the proofs again with the
exact final tapeout width before submission.
