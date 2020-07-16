#!/usr/bin/env bash
# Script sourced and adapted from https://github.com/pytorch/fairseq/blob/master/examples/scaling_nmt/README.md
set -e

# usage function
usage() {
	cat <<EOF
Usage: train_continue_wmt16_de_en.sh [-h|--help] save_dir
Continue training fairseq model on WMT16 de-en data

Optional arguments:
  -h, --help       Show this help message and exit

Required arguments:
  save_dir <path>  Path to directory containing checkpoints
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
train_continue_wmt16_de_en() {
	# declare variables
	local save_dir="$1"
	# exit if no valid save_dir provided
	[ ! -d "$save_dir" ] && usage && exit 1
	# deduce architecture from save_dir name
	local arch="$(sed -re 's/^([^.]*)\.(.*)$/\1/g' <<<$(basename $save_dir))"
	# train fairseq model
	fairseq-train \
		"data/wmt16_en_de_bpe32k/bin" \
		--arch "$arch" --share-all-embeddings \
		--optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
		--lr 0.001 --lr-scheduler inverse_sqrt --warmup-updates 4000 --warmup-init-lr 1e-07 \
		--dropout 0.3 --weight-decay 0.0 \
		--criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
		--max-tokens 3584 --fp16 --update-freq 16 \
		--no-epoch-checkpoints --patience 5 --num-workers 5 \
		--save-dir "$save_dir" \
		--tensorboard-logdir "$save_dir"
}

# execute function
check_help "$@"
train_continue_wmt16_de_en "$@"
