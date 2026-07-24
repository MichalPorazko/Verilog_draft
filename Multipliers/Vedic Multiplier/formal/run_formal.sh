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

run_proof() {
    local config="$1"
    local log="${config%.sby}.log"

    echo "==> $config"

    if sby -f "$config" >"$log" 2>&1; then
        tail -n 20 "$log"
    else
        echo "Formal proof failed; final log lines follow:"
        tail -n 100 "$log"
        return 1
    fi
}

run_proof vedic_comb.sby
run_proof vedic_spipe.sby
run_proof vedic_lpipe.sby
