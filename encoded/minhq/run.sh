#!/bin/bash

set -e

cd "$(dirname "$0")"

go build github.com/martinthomson/minhq/hc/qif

for q in ../../qifs/*.qif; do
    bq="${q##*/}"
    echo "$bq:"
    for t in 256 512 4096; do
        for f in 1 3/4 1/2; do
            r=$(($t * $f))
            for b in 0 100; do
                for a in ack noack; do
                    args=(encode -t "$t" -r "$r" -b "$b")
                    [[ "$a" == "ack" ]] && args+=(-a)
                    args+=("$q" "${bq%.qif}.minhq.$t.$r.$b.$a")
                    echo "   ${args[@]}"
                    [[ -z "$NOOP" ]] && ./qif "${args[@]}"
                done
            done
        done
    done
done
