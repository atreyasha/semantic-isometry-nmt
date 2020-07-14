#!/usr/bin/env bash
# This script installs all necessary dependencies
set -e

pip install -r requirements.txt
(
cd src
git clone https://github.com/NVIDIA/apex
cd apex
pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
)
