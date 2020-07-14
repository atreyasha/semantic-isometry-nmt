#!/usr/bin/env bash
# Copyright 2020 Google and DeepMind.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -e

# usage function
usage(){
  cat <<EOF
Usage: train_pawsx.sh [-h|--help] [model]

Optional arguments:
  -h, --help    Show this help message and exit
  model <arch>  Architecture for use in model, defaults
                to "bert-base-multilingual-cased"
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

# define train function
train() {
  local MODEL=${1:-"bert-base-multilingual-cased"}
  local GPU=0
  local DATA_DIR="./data/paws_x"
  local OUT_DIR="./models"
  local TASK="pawsx"
  local LR=2e-5
  local EPOCH=10
  local MAXL=128
  local LANGS="de,en,es,fr,ja,ko,zh"
  local UNIX_EPOCH="$(date +%s)"
  local SAVE_DIR="${OUT_DIR}/${MODEL}.${TASK}.ML${MAXL}.${UNIX_EPOCH}"
  mkdir -p $SAVE_DIR

  if [ $MODEL == "bert-base-multilingual-cased" ]; then
    MODEL_TYPE="bert"
  elif [ $MODEL == "xlm-roberta-large" ] || [ $MODEL == "xlm-roberta-base" ]; then
    MODEL_TYPE="xlmr"
  fi

  if [ $MODEL == "xlm-roberta-large" ]; then
    BATCH_SIZE=8
    GRAD_ACC=4
  else
    BATCH_SIZE=32
    GRAD_ACC=1
  fi

  CUDA_VISIBLE_DEVICES=$GPU python3 -m src.paws_x.run_classify \
                      --model_type $MODEL_TYPE \
                      --model_name_or_path $MODEL \
                      --train_language en \
                      --task_name $TASK \
                      --do_train \
                      --do_predict \
                      --do_predict_dev \
                      --train_split train \
                      --test_split test \
                      --data_dir $DATA_DIR \
                      --gradient_accumulation_steps $GRAD_ACC \
                      --save_steps 200 \
                      --per_gpu_train_batch_size $BATCH_SIZE \
                      --learning_rate $LR \
                      --num_train_epochs $EPOCH \
                      --max_seq_length $MAXL \
                      --output_dir $SAVE_DIR \
                      --log_file 'train.log' \
                      --predict_languages $LANGS \
                      --save_only_best_checkpoint
}

check_help "$@"; train "$@"
