#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

CLA_BASE="$ROOT/Adders/Look Ahead Carry Adder/grouped/version1"
CLA_SRC="$CLA_BASE/src"
CLA_TEST="$CLA_BASE/tests"
VEDIC_BASE="$ROOT/Multipliers/Vedic Multiplier"

run_tb() {
    local top="$1"
    shift

    echo "==> $top"
    iverilog -g2005 -Wall -s "$top" -o "$WORK/$top.vvp" "$@"
    vvp "$WORK/$top.vvp"
}

run_tb tb_calc_carries \
    "$CLA_SRC/calc_carries.v" \
    "$CLA_TEST/tb_calc_carries.v"

run_tb tb_cla_tree \
    "$CLA_SRC/calc_carries.v" \
    "$CLA_SRC/cla_tree.v" \
    "$CLA_TEST/tb_cla_tree.v"

run_tb CLA_grouped_tb \
    "$CLA_SRC/calc_carries.v" \
    "$CLA_SRC/cla_tree.v" \
    "$CLA_SRC/CLA_grouped.v" \
    "$CLA_TEST/CLA_grouped_tb.v"

run_tb Vedic_Mult_comb_tb \
    "$CLA_SRC/calc_carries.v" \
    "$CLA_SRC/cla_tree.v" \
    "$CLA_SRC/CLA_grouped.v" \
    "$VEDIC_BASE/Vedic_mult_2bit.v" \
    "$VEDIC_BASE/combinational/src/Vedic_Mult_comb.v" \
    "$VEDIC_BASE/combinational/test/Vedic_Mult_comb_tb.v"

run_tb Vedic_Mult_spipe_tb \
    "$CLA_SRC/calc_carries.v" \
    "$CLA_SRC/cla_tree.v" \
    "$CLA_SRC/CLA_grouped.v" \
    "$VEDIC_BASE/Vedic_mult_2bit.v" \
    "$VEDIC_BASE/combinational/src/Vedic_Mult_comb.v" \
    "$VEDIC_BASE/pipelined/short_pipeline/Vedic_Mult_spipe.v" \
    "$VEDIC_BASE/pipelined/short_pipeline/Vedic_Mult_spipe_tb.v"

run_tb Vedic_Mult_lpipe_tb \
    "$CLA_SRC/calc_carries.v" \
    "$CLA_SRC/cla_tree.v" \
    "$CLA_SRC/CLA_grouped.v" \
    "$VEDIC_BASE/Vedic_mult_2bit.v" \
    "$VEDIC_BASE/combinational/src/Vedic_Mult_comb.v" \
    "$VEDIC_BASE/pipelined/long_pipeline/Vedic_Mult_lpipe.v" \
    "$VEDIC_BASE/pipelined/long_pipeline/Vedic_Mult_lpipe_tb.v"
