#!/usr/bin/env bash
# Script to sync xtreme-pawsx submodule
set -e

git submodule update --init --recursive --remote
