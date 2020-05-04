#!/bin/bash

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
