#!/usr/bin/env bash
# Script sourced and adapted from https://github.com/pytorch/fairseq/blob/master/examples/scaling_nmt/README.md
set -e

WMT16="./data/wmt16_en_de_bpe32k"

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
