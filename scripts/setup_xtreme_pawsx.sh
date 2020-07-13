#!/usr/bin/env bash
# Script to sync xtreme-pawsx submodule and symlink relevant source code

git submodule update --init --recursive --remote
mkdir -p ./src/paws_x
ln -srf ./submodules/xtreme-pawsx/scripts/train_pawsx.sh ./scripts/train_pawsx.sh
ln -srf ./submodules/xtreme-pawsx/src/* ./src/paws_x/
