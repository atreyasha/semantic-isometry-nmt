#!/usr/bin/env bash
# Script sourced and adapted from https://github.com/pytorch/fairseq/blob/master/examples/scaling_nmt/README.md
set -e

# usage function
usage(){
  cat <<EOF
Usage: preprocess_wmt16_de_en.sh [-h|--help]
Preprocess WMT16 de-en data for training fairseq model

Optional arguments:
  -h, --help  Show this help message and exit
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

# define function
preprocess_wmt16(){
  local WMT16="./data/wmt16_en_de_bpe32k"
  # pre-process and make ready for model training
  fairseq-preprocess \
      --source-lang de --target-lang en \
      --trainpref "$WMT16/train.tok.clean.bpe.32000" \
      --validpref "$WMT16/newstest2013.tok.bpe.32000" \
      --testpref "$WMT16/newstest2014.tok.bpe.32000" \
      --destdir "$WMT16/bin" \
      --nwordssrc 32768 --nwordstgt 32768 \
      --joined-dictionary \
      --workers 20
}

# execute function
check_help "$@"; preprocess_wmt16
