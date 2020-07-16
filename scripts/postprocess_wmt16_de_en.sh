#!/usr/bin/env bash
# This function exports model log directories neatly into tarballs for deployment
set -e

# usage function
usage() {
  cat <<EOF
Usage: postprocess_wmt16_de_en.sh [-h|--help] model_directory...
Postprocess desired model directories to get them ready for exporting

Optional arguments:
  -h, --help              Show this help message and exit

Required arguments:
  model_directory <path>  Path to directory containing model
                          checkpoints
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
postprocess_wmt16_de_en() {
  local directories="$@"
  local data_dir="./data/wmt16_en_de_bpe32k"
  local bpe_path_array=("${data_dir}/bpe.32000"
                        "${data_dir}/bin/dict.en.txt"
                        "${data_dir}/bin/dict.de.txt")
  [ -z "$directories" ] && usage && exit 1
  for direct in ${directories[@]}; do
    mkdir -p "${direct}/bpe"
    cp "${bpe_path_array[@]}" "${direct}/bpe"
  done
}

# execute function
check_help "$@"
postprocess_wmt16_de_en "$@"
