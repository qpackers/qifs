#!/bin/bash

set -e

qifs=("$@")
[[ $# -eq 0 ]] && qifs=(../../qifs/*.qif)

cd "$(dirname "$0")"
for q in "${qifs[@]}"; do
    qbase="$(basename "$q" .qif)"
    echo "$qbase:"
    for t in 256 512 4096; do
	    for r in $((t / 2)) $((t * 3 / 4)) $t; do
            for b in 0 100; do
                for a in ack noack; do
                    opts=(-t "$t" -r "$r" -b "$b")
                    [[ "$a" == "ack" ]] && opts+=(-a)
                    out="${qbase}.minhq.$t.$r.$b.$a"
                    cmd=(go run github.com/martinthomson/minhq/hc/qif encode "${opts[@]}" "$q")
                    echo "  ${cmd[@]}"
                    "${cmd[@]}" > "$out"
                done
            done
        done
    done
done
