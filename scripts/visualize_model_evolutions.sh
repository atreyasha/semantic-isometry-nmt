#!/usr/bin/env bash
# Script to plot model evolutions for translation and paraphrase detection models
set -e

# usage function
usage() {
  cat <<EOF
Usage: visualize_model_evolutions.sh [-h|--help] [glob]
Visualize model evolutions for translation and paraphrase detection models

Optional arguments:
  -h, --help   Show this help message and exit
  glob <glob>  Glob for finding tensorboard log directories, which will
               be converted to csv's and then plotted. Defaults to
               "./models/*/{train,train_inner,valid}"
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
visualize_model_evolutions() {
  local glob=("${1:-"./models/*/{train,train_inner,valid}"}")
  for log_dir in ${glob[@]}; do
    python3 -m src.tensorboard_events2csv --tb-log-dir-glob "$log_dir"
  done
  Rscript src/visualize_wmt19_paraphrases_de_en.R -e
}

# execute function
check_help "$@"
visualize_model_evolutions "$@"
