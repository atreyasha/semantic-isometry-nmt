#!/usr/bin/env bash
# This script sets up pre-commit and post-commit hooks for use
set -e

cp --force ./hooks/pre-commit ./.git/hooks/pre-commit
cp --force ./hooks/pre-push ./.git/hooks/pre-push
