#!/usr/bin/env bash
set -e

# usage function
usage() {
  cat <<EOF
Usage: translate_wmt19_paraphrases_de_en.sh [-h|--help] [glob]
Translate WMT19 paraphrases using both torch-hub and local
model globs

Optional arguments:
  -h, --help   Show this help message and exit
  glob <glob>  Glob for finding local NMT models, defaults to
               "./models/transformer_vaswani_wmt_en_de_big.wmt16.de-en.1594228573"
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
translate_wmt19_paraphrases_de_en() {
  local glob="${1:-"./models/transformer_vaswani_wmt_en_de_big.wmt16.de-en.1594228573"}"
  python3 -m src.translate --local-model-glob "$glob"
}

# execute function
check_help "$@"
translate_wmt19_paraphrases_de_en "$@"
