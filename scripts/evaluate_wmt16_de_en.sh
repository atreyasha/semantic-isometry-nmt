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
  local outfile="${checkpoint_path}.${subset}.out"
  [ ! -f "$checkpoint_path" ] && usage && exit 1
  # process generations
  fairseq-generate \
    "data/wmt16_en_de_bpe32k/bin" \
    --path "$checkpoint_path" \
    --beam 5 --lenpen 0.6 --remove-bpe \
    --tokenizer moses \
    --gen-subset "$subset" \
    --max-tokens 3584 | tee "$outfile"
  # detokenize and compute sacrebleu
  grep ^H "$outfile" |
    sed 's/^D\-//' |
    sort -n -k 1 |
    cut -f 3 |
    sacrebleu --test-set "wmt14/full" \
      --language-pair "de-en" >"${outfile}.sacrebleu"
}

# execute function
check_help "$@"
evaluate_wmt16_de_en "$@"
