#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from typing import List
from tqdm import tqdm
import codecs
import json
import torch
import logging
import logging.config
logging.config.fileConfig('./utils/resources/logging.conf',
                          disable_existing_loggers=False)


def read_data(file_path: str, drop_first: bool = True) -> List[List[str]]:
    """
    Generator which outputs lines in batches

    Args:
        file_path (str): path to file
        drop_first (bool): drop first row given it is a header

    Returns:
        collection (List[List[str]]): parsed textual data with
        newline symbols removed and split at tab symbols
    """
    with codecs.open(file_path, "r", encoding="utf-8") as f:
        collection = []
        for line in f:
            if drop_first:
                drop_first = False
                continue
            split_line = line.strip().split("\t")
            assert len(split_line) == 4
            collection.append(split_line)
    return collection


def main() -> None:
    batch_size = 100
    en_test = read_data("./data/x-final/en/test_2k.tsv")
    de_test = read_data("./data/x-final/de/test_2k.tsv")
    nmt_en2de = torch.hub.load('pytorch/fairseq',
                               'transformer.wmt19.en-de.single_model')
    dict_store = {}
    # write everything to a dictionary json, keep it simple
    for i in tqdm(range(0, len(en_test[:100]), batch_size)):
        chunk = en_test[i:i+batch_size]
        de_chunk = de_test[i:i+batch_size]
        sentence_1s = [seg[1] for seg in chunk]
        sentence_2s = [seg[2] for seg in chunk]
        sentence_1s = nmt_en2de.translate(sentence_1s)
        sentence_2s = nmt_en2de.translate(sentence_2s)
        for j, seg in enumerate(chunk):
            dict_store[seg[0]] = {
                "sentence_1": {
                    "en": seg[1],
                    "de_gold": de_chunk[j][1],
                    "de_translate": sentence_1s[j]
                },
                "sentence_2": {
                    "en": seg[2],
                    "de_gold": de_chunk[j][2],
                    "de_translate": sentence_2s[j]
                },
                "label": seg[3]
            }
    with open("store.json", "w") as f:
        json.dump(dict_store, f, ensure_ascii=False)


if __name__ == "__main__":
    main()

# Developments:
# TODO create data in batches with tqdm and parse it accordingly -> add logger
# TODO run basic bleu-based similarity checks for german translations
