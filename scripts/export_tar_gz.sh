#!/usr/bin/env bash
# This function exports model log directories neatly into tarballs for deployment
set -e

# usage function
usage() {
  cat <<EOF
Usage: export_tar_gz.sh [-h|--help] model_directory...
Export training logs and best checkpoint to tarball

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
export_tar_gz() {
  local directories="$@"
  [ -z "$directories" ] && usage && exit 1
  for direct in ${directories[@]}; do
    [ ! -d "$direct" ] && printf "%s\n" "$direct does not exist" && continue
    (
      cd "$(dirname $direct)"
      tar --exclude="*checkpoint_last*" --exclude="*checkpoint-training-end*" \
        -zcvf "$(basename "$direct").tar.gz" "$(basename $direct)"
    )
  done
}

# execute function
check_help "$@"
export_tar_gz "$@"
