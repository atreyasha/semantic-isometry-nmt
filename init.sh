#!/bin/bash

read -rep "create pre-commit hook for updating python dependencies? (y/n): " ans
if [ $ans == "y" ]; then
  # move pre-commit hook into local .git folder for activation
  cp ./hooks/pre-commit.sample ./.git/hooks/pre-commit
fi

read -rep "download and deploy WMT 2017 en-de dev/test dataset(s) [2.3 MB]? (y/n): " ans
if [ $ans == "y" ]; then
  # download WMT datasets
  wget "http://data.statmt.org/wmt17/translation-task/preprocessed/de-en/dev.tgz" -O ./data/dev.tar.gz
  # unzip training data
  tar -zxvf ./data/dev.tar.gz -C ./data/raw
  cd ./data
  # get dev dataset
  ln -sf ./raw/newstest2015.tc.de ./dev.truecased.de
  ln -sf ./raw/newstest2015.tc.en ./dev.truecased.en
  # get test dataset
  ln -sf ./raw/newstest2016.tc.de ./test.truecased.de
  ln -sf ./raw/newstest2016.tc.en ./test.truecased.en
  # return back to base directory
  cd ..
fi

read -rep "download and deploy SCPN models [150 MB]? (y/n): " ans
if [ $ans == "y" ]; then
  fileid="1AuH1aHrE9maYttuSJz_9eltYOAad8Mfj"
  # curl code adapted from https://gist.github.com/amit-chahar/db49ce64f46367325293e4cce13d2424
  curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${fileid}" > /dev/null
  curl -Lb ./cookie "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' ./cookie`&id=${fileid}" -o ./scpn_models/scpn_models.zip
  rm -f ./cookie
  cd ./models
  unzip scpn_models.zip
  mv scpn_models/*pt .
  rm -rf scpn_models
  cd ..
fi
