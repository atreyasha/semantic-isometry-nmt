#!/usr/bin/env bash
# Script sourced and adapted from https://github.com/pytorch/fairseq/blob/master/examples/scaling_nmt/README.md

unix_epoch="$(date +%s)"

# train fairseq model
fairseq-train \
    ./data/wmt16_en_de_bpe32k/bin \
    --arch transformer_wmt_en_de --share-all-embeddings \
    --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
    --lr 0.0005 --lr-scheduler inverse_sqrt --warmup-updates 4000 --warmup-init-lr 1e-07 \
    --dropout 0.3 --weight-decay 0.0 \
    --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
    --max-tokens 3584 \
    --save-dir "./model_logs/transformer_wmt16_de_en_${unix_epoch}" \
    --tensorboard-logdir "./model_logs/transformer_wmt16_de_en_${unix_epoch}" \
    --keep-last-epochs 10
