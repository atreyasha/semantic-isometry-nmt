#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from utils.parser import parse_arguments
from typing import List, Dict
from tqdm import tqdm
import codecs
import json
import os
import re
import torch
import logging
import logging.config
logging.config.fileConfig('./utils/resources/logging.conf',
                          disable_existing_loggers=True)


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


def write_to_file(lang: str, store: Dict) -> None:
    # write everything to a json file to keep things simple
    path = os.path.join("./out", lang, "store.json")
    os.makedirs(path, exist_ok=True)
    with open(path, "w") as json_file:
        json.dump(store, json_file, ensure_ascii=False)


def translate_process(lang: str, en_input: List[str], target_gold: List[str],
                      batch_size: int) -> Dict:
    # initialize data store
    store = {}
    # ensure sanity of data
    assert len(en_input) == len(target_gold), ("Input and gold data"
                                               " are not of the same length")
    # get model based on language
    if lang == "de":
        model = torch.hub.load("pytorch/fairseq",
                               "transformer.wmt19.en-de.single_model")
    # disable dropout for prediction
    model.eval()
    # enable GPU hardware acceleration if GPU/CUDA present
    if torch.cuda.is_available():
        model.cuda()
    # conduct batch translation and data processing
    for i in tqdm(range(0, len(en_input), batch_size)):
        en_chunk = en_input[i:i + batch_size]
        target_chunk = target_gold[i:i + batch_size]
        sentence_1s = [seg[1] for seg in en_chunk]
        sentence_2s = [seg[2] for seg in en_chunk]
        sentence_1s = model.translate(sentence_1s)
        sentence_2s = model.translate(sentence_2s)
        for j, seg in enumerate(en_chunk):
            store[seg[0]] = {
                "sentence_1": {
                    "source_en": seg[1],
                    "target_translated": sentence_1s[j],
                    "target_gold": target_chunk[j][1]
                },
                "sentence_2": {
                    "source_en": seg[2],
                    "target_translated": sentence_2s[j],
                    "target_gold": target_chunk[j][2]
                },
                "gold_label": seg[3]
            }
    # return final dictionary
    return store


def main() -> None:
    args = parse_arguments(subtype="translate")
    # get verbosity
    if args.verbosity == 1:
        logger = logging.getLogger('base')
    else:
        logger = logging.getLogger('root')
    # get target language(s)
    target_languages = re.split(r"\s*,\s*", args.target_languages)
    assert len(target_languages) > 0, "No target language provided"
    # get batch-size
    batch_size = args.batch_size
    # local setting depending on models available
    supported_languages = ["de"]
    # read en_input data and concatenate here
    logger.info("Processing 'en' source data")
    en_input = (read_data("./data/x-final/en/dev_2k.tsv") +
                read_data("./data/x-final/en/test_2k.tsv"))
    # perform sanity check on English source data
    logger.info("Performing sanity checks on 'en' source data")
    en_input_unique_ids = set([instance[0] for instance in en_input])
    assert len(en_input) == len(en_input_unique_ids)
    for lang in target_languages:
        if lang not in supported_languages:
            logger.warning(
                "Dropping language '%s' as it is not a supported language",
                lang)
            continue
        else:
            logger.info("Processing '%s' target data", lang)
            target_dev_path = os.path.join("./data/x-final", lang,
                                           "dev_2k.tsv")
            target_test_path = os.path.join("./data/x-final", lang,
                                            "test_2k.tsv")
            target_gold = (read_data(target_dev_path) +
                           read_data(target_test_path))
            store = translate_process(lang, en_input, target_gold, batch_size)
            write_to_file(lang, store)


if __name__ == "__main__":
    main()
