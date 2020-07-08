#!/usr/bin/env bash
# Script sourced and adapted from https://github.com/pytorch/fairseq/blob/master/examples/scaling_nmt/README.md

TEXT="./data/wmt16_en_de_bpe32k"

# pre-process and make ready for model training
fairseq-preprocess \
    --source-lang de --target-lang en \
    --trainpref "$TEXT/train.tok.clean.bpe.32000" \
    --validpref "$TEXT/newstest2013.tok.bpe.32000" \
    --testpref "$TEXT/newstest2014.tok.bpe.32000" \
    --destdir "data/wmt16_en_de_bpe32k/bin" \
    --nwordssrc 32768 --nwordstgt 32768 \
    --joined-dictionary \
    --workers 20
