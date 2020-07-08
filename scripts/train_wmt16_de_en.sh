#!/usr/bin/env bash
# Script sourced and adapted from https://github.com/pytorch/fairseq/blob/master/examples/scaling_nmt/README.md
set -e

# usage function
usage(){
  cat <<EOF
Usage: train_wmt16_de_en.sh [-h|--help] [arch]

Optional arguments:
  -h, --help           Show this help message and exit
  arch <fairseq_arch>  Architecture for use in model, defaults
                       to "transformer_vaswani_wmt_en_de_big"
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

# train function
train(){
  # declare variables
  local arch="${1:-transformer_vaswani_wmt_en_de_big}"
  local unix_epoch="$(date +%s)"
  # train fairseq model
  fairseq-train \
      "data/wmt16_en_de_bpe32k/bin" \
      --arch "$arch" --share-all-embeddings \
      --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
      --lr 0.001 --lr-scheduler inverse_sqrt --warmup-updates 4000 --warmup-init-lr 1e-07 \
      --dropout 0.3 --weight-decay 0.0 \
      --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
      --max-tokens 3584 --fp16 --update-freq 16 \
      --keep-last-epochs 10 \
      --save-dir "./models/${arch}.wmt16.de-en.${unix_epoch}" \
      --tensorboard-logdir "./models/${arch}.wmt16.de-en.${unix_epoch}"
}

check_help "$@"; train "$@"
