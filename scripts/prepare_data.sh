#!/usr/bin/env bash
# This function downloads and deploy all necessary data
# Except cases of Google Drive data which must be manually downloaded/deployed
set -e

# usage function
usage(){
  cat <<EOF
Usage: prepare_data.sh [-h|--help]
Prepare WMT19, WMT19-AR, WMT16 and PAWS-X data

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

wmt16() {
  local WMT16="./data/wmt16_en_de_bpe32k"
  if [ -f "./data/wmt16_en_de.tar.gz" ]; then
    mkdir -p "$WMT16"
    tar -xzvf "./data/wmt16_en_de.tar.gz" -C "$WMT16"
  fi
}

paws_x() {
  local DATA="./data"
  wget -N -P "$DATA" "https://storage.googleapis.com/paws/pawsx/x-final.tar.gz"
  tar -zxvf "$DATA/x-final.tar.gz" -C $DATA
  rm -rf "$DATA/paws_x"
  python3 -m src.paws_x.preprocess \
    --data_dir "$DATA/x-final" \
    --output_dir "$DATA/paws_x/"
  rm -rf "$DATA/x-final"
}

wmt19() {
  local WMT19="./data/wmt19"
	mkdir -p $WMT19
	sacrebleu --test-set "wmt19" --language-pair en-de --echo src > "$WMT19/wmt19.test.truecased.en.src"
	sacrebleu --test-set "wmt19" --language-pair en-de --echo ref > "$WMT19/wmt19.test.truecased.de.ref"
}

wmt19_paraphrased() {
  local WMT19_PARAPHRASED="./data/wmt19_paraphrased"
	mkdir -p "$WMT19_PARAPHRASED"
	wget -N -P "$WMT19_PARAPHRASED" "https://raw.githubusercontent.com/google/wmt19-paraphrased-references/master/wmt19/ende/wmt19-ende-ar.ref"
	wget -N -P "$WMT19_PARAPHRASED" "https://raw.githubusercontent.com/google/wmt19-paraphrased-references/master/wmt19/ende/wmt19-ende-arp.ref"
	wget -N -P "$WMT19_PARAPHRASED" "https://raw.githubusercontent.com/google/wmt19-paraphrased-references/master/wmt19/ende/wmt19-ende-wmtp.ref"
}

# execute all functions
check_help "$@"; paws_x; wmt19; wmt19_paraphrased; wmt16
