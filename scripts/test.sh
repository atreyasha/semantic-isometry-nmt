#!/usr/bin/env bash
# Script sourced and adapted from https://github.com/pytorch/fairseq/blob/master/examples/scaling_nmt/README.md
set -e

# usage function
usage() {
  cat <<EOF
Usage: evaluate_wmt16_de_en.sh [-h|--help] checkpoint [subset]
Evaluate trained fairseq model on WMT16 de-en data

Optional arguments:
  -h, --help         Show this help message and exit
  subset <str>       Which subset to evaluate in {train, valid, test},
                     defaults to "test"

Required arguments:
  checkpoint <path>  Path to checkpoint which should be used
EOF
}

# check for help
check_help() {
  for arg; do
    if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]; then
      usage
      exit 1
    fi
  done
}

# define function
evaluate_wmt16_de_en() {
  # declare variables
  local checkpoint_path="$1" subset="${2:-test}"
  local outfile="${checkpoint_path}.${subset}_trial.out"
  [ ! -f "$checkpoint_path" ] && usage && exit 1
  # process generations
  fairseq-interactive \
    "data/wmt16_en_de_bpe32k/bin" \
    --path "$checkpoint_path" \
    --source-lang de --target-lang en \
    --bpe fastbpe --bpe-codes "data/wmt16_en_de_bpe32k/bpe.32000" \
    --beam 5 --lenpen 0.6 --remove-bpe \
    --batch-size 512 --buffer-size 1028 \
    --sacrebleu \
    --tokenizer moses --input ./data/wmt19/*ref | tee "$outfile
  # TODO add sacrebleu evaluation here as well
  # TODO run both wmt16 and wmt19 evaluations to check new tokenizer
}

# execute function
check_help "$@"
evaluate_wmt16_de_en "$@"
