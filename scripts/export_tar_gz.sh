#!/usr/bin/env bash
# This function exports model log directories neatly into tarballs for deployment
set -e

# usage function
usage() {
  cat <<EOF
Usage: export_tar_gz.sh [-h|--help] model_checkpoint...
Export training logs and best checkpoint to tarball

Optional arguments:
  -h, --help               Show this help message and exit

Required arguments:
  model_checkpoint <path>  Path corresponding to model checkpoint
                           that should be exported
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
  local checkpoints="$@"
  [ -z "$checkpoints" ] && usage && exit 1
  for checkpoint in ${checkpoints[@]}; do
    [ ! -e "$checkpoint" ] && printf "%s\n" "$checkpoint does not exist" && continue
    (
      local parent_name="$(dirname $(dirname $checkpoint))"
      local child_name="$(basename $(dirname $checkpoint))"
      local checkpoint_name="$(basename $checkpoint)"
      cd "$parent_name"
      local exclude_files=($(find "$child_name" -path "*checkpoint*" | grep --invert-match "$checkpoint_name"))
      # source: https://superuser.com/questions/1052950/bash-loop-for-adding-exclude-list-to-tar
      exclude_files=("${exclude_files[@]/#/--exclude=}")
      tar "${exclude_files[@]}" -zcvf "${child_name}.tar.gz" "$child_name"
    )
  done
}

# execute function
check_help "$@"
export_tar_gz "$@"
