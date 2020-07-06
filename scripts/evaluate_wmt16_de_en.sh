#!/usr/bin/env bash
# Script sourced and adapted from https://github.com/pytorch/fairseq/blob/master/examples/scaling_nmt/README.md

# declare first positional argument as path
path="$1"

# assign function for generation
generate() {
  # evaluate generations
  fairseq-generate \
      data/wmt16_en_de_bpe32k/bin \
      --path "$path" \
      --beam 4 --lenpen 0.6 --remove-bpe
}

# generate translations
generate "$@"
