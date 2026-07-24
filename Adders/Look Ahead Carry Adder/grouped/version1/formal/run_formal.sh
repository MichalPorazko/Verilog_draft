#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="${FORMAL_WORK_DIR:-$HERE/work}"
SRC="$HERE/../src"

rm -rf "$WORK"
mkdir -p "$WORK"

cp "$SRC/calc_carries.v" "$WORK/"
cp "$SRC/cla_tree.v" "$WORK/"
cp "$SRC/CLA_grouped.v" "$WORK/"
cp "$HERE"/*.v "$HERE"/*.sby "$WORK/"

cd "$WORK"
sby -f calc_carries.sby
sby -f cla_tree.sby
sby -f CLA.sby
