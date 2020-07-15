#!/usr/bin/env bash
# Script to sync xtreme-pawsx submodule
set -e

# usage function
usage(){
  cat <<EOF
Usage: setup_xtreme_pawsx.sh [-h|--help]
Initialize/update xtreme-pawsx git submodule

Optional arguments:
  -h, --help         Show this help message and exit
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

# define function
setup_xtreme_pawsx(){
  git submodule update --init --recursive --remote
}

# execute function
check_help "$@"; setup_xtreme_pawsx
