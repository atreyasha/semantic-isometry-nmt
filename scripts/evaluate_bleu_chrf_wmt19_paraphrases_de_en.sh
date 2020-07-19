#!/usr/bin/env bash
# Script to shallowly evaluate WMT19 translations and paraphrases
# with BLEU and chrF scores
set -e

# usage function
usage() {
  cat <<EOF
Usage: evaluate_bleu_chrf_wmt19_paraphrases_de_en.sh [-h|--help] [glob]
Conduct shallow evaluation of WMT19 paraphrases with BLEU and
chrF scores

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
evaluate_bleu_chrf_wmt19_paraphrases() {
  local glob="${1:-"./predictions/*/*.json"}"
  python3 -m src.evaluate_bleu_chrf_wmt19_paraphrases_de_en --json-glob "$glob"
}

# execute function
check_help "$@"
evaluate_bleu_chrf_wmt19_paraphrases"$@"
