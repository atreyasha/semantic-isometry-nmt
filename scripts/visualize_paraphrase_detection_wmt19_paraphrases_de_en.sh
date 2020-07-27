#!/usr/bin/env bash
# Script to plot paraphrase detection predictions of WMT19 paraphrase translations
set -e

# usage function
usage() {
  cat <<EOF
Usage: visualize_paraphrase_detection_wmt19_paraphrases_de_en.sh [-h|--help] [glob]
Visualize paraphrase detection predictions of WMT19 paraphrase translations

Optional arguments:
  -h, --help   Show this help message and exit
  glob <glob>  Glob for finding input json translations, defaults to
               "./predictions/*/*.json"
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
visualize_paraphrase_detection_wmt19_paraphrases_de_en() {
  local glob="${1:-"./predictions/*/*.json"}"
  Rscript src/visualize_wmt19_paraphrases_de_en.R -p -j "$glob"
}

# execute function
check_help "$@"
visualize_paraphrase_detection_wmt19_paraphrases_de_en "$@"
