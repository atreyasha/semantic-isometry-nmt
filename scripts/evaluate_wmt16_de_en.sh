#!/usr/bin/env bash
# Script sourced and adapted from https://github.com/pytorch/fairseq/blob/master/examples/scaling_nmt/README.md
set -e

# usage function
usage(){
  cat <<EOF
Usage: evaluate_wmt16_de_en.sh [-h|--help] checkpoint [subset]

Optional arguments:
  -h, --help         Show this help message and exit
  subset <str>       Which subset to evaluate in {train, valid, test},
                     defaults to "test"

Required arguments:
  checkpoint <path>  Path to checkpoint which should be used
EOF
}

# check for help
check_help(){
  for arg; do
    if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]; then
      usage
      exit 1
    fi
  done
}

evaluate(){
# compulsory
path="$1"
# optional
subset="${2:-test}"
# derived
outfile="$(dirname "$path")/$(basename "$path")."$subset".out"
# TODO add auto scoring here next to outfile

# process generations
fairseq-generate \
    data/wmt16_en_de_bpe32k/bin \
    --path "$path" \
    --beam 4 --lenpen 0.6 --remove-bpe \
    --gen-subset "$subset" \
    --max-tokens 2048 | tee "$outfile"
}

check_help "$@"; evaluate "$@"
