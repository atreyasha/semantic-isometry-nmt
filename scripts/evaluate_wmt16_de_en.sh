#!/usr/bin/env bash
# Script sourced and adapted from https://github.com/pytorch/fairseq/blob/master/examples/scaling_nmt/README.md

# declare variables
path="$1"
subset="${2:-test}"
outfile="$(dirname "$path")/$(basename "$path")."$subset".out"

# process generations
fairseq-generate \
    data/wmt16_en_de_bpe32k/bin \
    --path "$path" \
    --beam 4 --lenpen 0.6 --remove-bpe \
    --gen-subset "$subset" \
    --max-tokens 2048 | tee "$outfile"
