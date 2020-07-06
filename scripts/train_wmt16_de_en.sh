#!/usr/bin/env bash
# Script sourced and adapted from https://github.com/pytorch/fairseq/blob/master/examples/scaling_nmt/README.md

# declare variables
unix_epoch="$(date +%s)"
arch="${1:-transformer_vaswani_wmt_en_de_big}"

# train fairseq model
fairseq-train \
    ./data/wmt16_en_de_bpe32k/bin \
    --arch "$arch" --share-all-embeddings \
    --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
    --lr 0.0005 --lr-scheduler inverse_sqrt --warmup-updates 4000 --warmup-init-lr 1e-07 \
    --dropout 0.3 --weight-decay 0.0 \
    --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
    --max-tokens 3584 \
    --save-dir "./models/${arch}.wmt16.de-en.${unix_epoch}" \
    --tensorboard-logdir "./models/${arch}.wmt16.de-en.${unix_epoch}" \
    --max-epoch 5
