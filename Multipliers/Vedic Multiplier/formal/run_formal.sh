#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../../.." && pwd)"
WORK="${FORMAL_WORK_DIR:-$HERE/work}"
CLA_SRC="$ROOT/Adders/Look Ahead Carry Adder/grouped/version1/src"
VEDIC_ROOT="$HERE/.."

rm -rf "$WORK"
mkdir -p "$WORK"

cp "$CLA_SRC/calc_carries.v" "$WORK/"
cp "$CLA_SRC/cla_tree.v" "$WORK/"
cp "$CLA_SRC/CLA_grouped.v" "$WORK/"
cp "$VEDIC_ROOT/Vedic_mult_2bit.v" "$WORK/"
cp "$VEDIC_ROOT/combinational/src/Vedic_Mult_comb.v" "$WORK/"
cp "$VEDIC_ROOT/pipelined/short_pipeline/Vedic_Mult_spipe.v" "$WORK/"
cp "$VEDIC_ROOT/pipelined/long_pipeline/Vedic_Mult_lpipe.v" "$WORK/"
cp "$HERE"/*.v "$HERE"/*.sby "$WORK/"

cd "$WORK"
sby -f vedic_comb.sby
sby -f vedic_spipe.sby
sby -f vedic_lpipe.sby
