#!/bin/bash

set -e

cd "$(dirname "$0")"

qifs=("$@")
[[ $# -eq 0 ]] && qifs=(../../../qifs/*.qif)
go build github.com/martinthomson/minhq/hc/qif

for q in "${qifs[@]}"; do
    bq="${q##*/}"
    echo "$bq:"
    for t in 256 512 4096; do
        for f in 1 3/4 1/2; do
            r=$(($t * $f))
            for b in 0 100; do
                for a in ack noack; do
                    args=(-t "$t" -r "$r" -b "$b")
                    [[ "$a" == "ack" ]] && args+=(-a)
                    args+=("$q" "${bq%.qif}.minhq.$t.$r.$b.$a")
                    echo "   ${args[@]}"
                    [[ -z "$NOOP" ]] && ./qif encode "${args[@]}"
                done
            done
        done
    done
done
