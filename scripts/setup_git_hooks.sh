#!/usr/bin/env bash
# This script sets up pre-commit and post-commit hooks for use
set -e

# usage function
usage(){
  cat <<EOF
Usage: setup_git_hooks.sh [-h|--help]
Force copy git hooks to git repository config

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
setup_git_hooks(){
  cp --force ./hooks/pre-commit ./.git/hooks/pre-commit
  cp --force ./hooks/pre-push ./.git/hooks/pre-push
}

# execute function
check_help "$@"; setup_git_hooks
