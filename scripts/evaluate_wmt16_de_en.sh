#!/usr/bin/env bash
# Script sourced and adapted from https://github.com/pytorch/fairseq/blob/master/examples/scaling_nmt/README.md

# assign function for generation
generate() {
  # declare first positional argument as path
  local path="$1"
  # evaluate generations
  fairseq-generate \
      data/wmt16_en_de_bpe32k/bin \
      --path "$path" \
      --beam 4 --lenpen 0.6 --remove-bpe
}

# generate translations
generate "$@"
