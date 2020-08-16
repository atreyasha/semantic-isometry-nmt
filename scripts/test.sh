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
  local outfile="${checkpoint_path}.${subset}_wmt19.out"
  local datapath="data/wmt16_en_de_bpe32k"
  [ ! -f "$checkpoint_path" ] && usage && exit 1
  # process generations
  fairseq-interactive \
    "${datapath}/bin" \
    --path "$checkpoint_path" \
    --source-lang "de" --target-lang "en" \
    --bpe "fastbpe" --bpe-codes "${datapath}/bpe.32000" \
    --beam 5 --lenpen 0.6 --remove-bpe \
    --batch-size 128 --buffer-size 256 \
    --tokenizer "moses" \
    --input "./data/wmt19/wmt19.test.truecased.de.ref" | tee "$outfile"
  # detokenize and compute sacrebleu
  grep ^D "$outfile" |
    sed 's/^D\-//' |
    sort -n -k 1 |
    cut -f 3 |
    sacrebleu --test-set "wmt19" \
      --language-pair "en-de" >"${outfile}.sacrebleu"
}

# execute function
check_help "$@"
evaluate_wmt16_de_en "$@"
