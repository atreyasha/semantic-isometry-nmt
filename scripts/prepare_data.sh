#!/usr/bin/env bash
# This function downloads and deploy all necessary data
# Except cases of Google Drive data which must be manually downloaded/deployed

DATA="./data"
WMT19="./data/wmt19"
WMT19_PARAPHRASED="./data/wmt19_paraphrased"
WMT16="./data/wmt16_en_de_bpe32k"

wmt16() {
  if [ -f "./data/wmt16_en_de.tar.gz" ]; then
    mkdir -p "$WMT16"
    tar -xzvf "./data/wmt16_en_de.tar.gz" -C "$WMT16"
  fi
}

paws_x() {
	wget -N -P "$DATA" "https://storage.googleapis.com/paws/pawsx/x-final.tar.gz"
	tar -zxvf "$DATA/x-final.tar.gz" -C $DATA
    rm -rf "$DATA/paws_x"
	mv -f "$DATA/x-final" "$DATA/paws_x"
}

wmt19() {
	mkdir -p $WMT19
	sacrebleu --test-set "wmt19" --language-pair en-de --echo src > "$WMT19/wmt19.test.truecased.en.src"
	sacrebleu --test-set "wmt19" --language-pair en-de --echo ref > "$WMT19/wmt19.test.truecased.de.ref"
}

wmt19_paraphrased() {
	mkdir -p "$WMT19_PARAPHRASED"
	wget -N -P "$WMT19_PARAPHRASED" "https://raw.githubusercontent.com/google/wmt19-paraphrased-references/master/wmt19/ende/wmt19-ende-ar.ref"
	wget -N -P "$WMT19_PARAPHRASED" "https://raw.githubusercontent.com/google/wmt19-paraphrased-references/master/wmt19/ende/wmt19-ende-arp.ref"
	wget -N -P "$WMT19_PARAPHRASED" "https://raw.githubusercontent.com/google/wmt19-paraphrased-references/master/wmt19/ende/wmt19-ende-wmtp.ref"
}

# execute all functions
paws_x; wmt19; wmt19_paraphrased; wmt16
