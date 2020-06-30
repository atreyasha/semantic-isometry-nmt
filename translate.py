#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from utils.parser import parse_arguments
from typing import List, Dict
from tqdm import tqdm
from glob import glob
import codecs
import json
import os
import re
import torch
import logging
import logging.config
logging.config.fileConfig('./utils/resources/logging.conf',
                          disable_existing_loggers=True)


def read_data(file_path: str, drop_first: bool = False) -> List[List[str]]:
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
            split_line = line.strip()
            collection.append(split_line)
    return collection


def interweave(dataset_1: List[str], dataset_2: List[str]) -> List[str]:
    interwoven = []
    for i in range(len(dataset_1)):
        interwoven.append([i, dataset_1[i], dataset_2[i], 1])
    return interwoven


def write_to_file(lang: str, paraphrase_type: str, store: Dict) -> None:
    """
    Write processed dictionary to json file

    Args:
        lang (str): Target language
        paraphrase_type (str): Type of paraphrase data supplied
        store (Dict): Dictionary ouput of translation task
    """
    # write everything to a json file to keep things simple
    path = os.path.join("./out", "de-" + lang)
    os.makedirs(path, exist_ok=True)
    with open(os.path.join(path, paraphrase_type + ".json"),
              "w") as json_file:
        json.dump(store, json_file, ensure_ascii=False)


def translate_process(lang: str, input_data: List[str],
                      batch_size: int) -> Dict:
    """
    Translate source data and append outputs into neat dictionary

    Args:
        lang (str): Target language
        input_data (List[str]): Source sentences
        batch_size (int): Batch size for translation

    Returns:
        store (Dict): Dictionary output containing all necessary translations
    """
    # initialize data store
    store = {}
    # get model based on language
    if lang == "en":
        model = torch.hub.load("pytorch/fairseq",
                               "transformer.wmt19.de-en.single_model")
    # disable dropout for prediction
    model.eval()
    # enable GPU hardware acceleration if GPU/CUDA present
    if torch.cuda.is_available():
        model.cuda()
    # conduct batch translation and data processing
    for i in tqdm(range(0, len(input_data), batch_size)):
        en_chunk = input_data[i:i + batch_size]
        sentence_1s = [seg[1] for seg in en_chunk]
        sentence_2s = [seg[2] for seg in en_chunk]
        sentence_1s = model.translate(sentence_1s)
        sentence_2s = model.translate(sentence_2s)
        for j, seg in enumerate(en_chunk):
            store[seg[0]] = {
                "sentence_original": {
                    "de_src": seg[1],
                    "en_translated": sentence_1s[j]
                },
                "sentence_paraphrase": {
                    "de_src": seg[2],
                    "en_translated": sentence_2s[j]
                },
                "gold_label": seg[3]
            }
    # return final dictionary
    return store


def main() -> None:
    """
    Main function to read, translate and write English and target
    language data
    """
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
    # get paths corresponding to glob
    input_paths = glob(args.input_glob)
    assert len(input_paths) > 0, "No paths found corresponding to input glob"
    # local setting depending on models available
    supported_languages = ["en"]
    # read en_input data and concatenate here
    logger.info("Reading WMT19 en-de 'de' reference data")
    de_input_original = read_data("./data/wmt19/wmt19.test.truecased.de.ref")
    for i, input_path in enumerate(input_paths):
        paraphrase_type = os.path.basename(input_path)
        logger.info(
            "Reading WMT19 en-de 'de' '%s' paraphrased reference data: %d/%d",
            paraphrase_type, i + 1, len(input_paths))
        de_input_paraphrased = read_data(input_path)
        # perform sanity check on English source data
        logger.info("Performing sanity checks on 'de' input data")
        assert len(de_input_original) == len(de_input_paraphrased)
        de_input = interweave(de_input_original, de_input_paraphrased)
        for lang in target_languages:
            if lang not in supported_languages:
                logger.warning(
                    "Dropping language '%s' as it is not a supported language",
                    lang)
                continue
            else:
                logger.info("Translating and processing to %s", lang)
                store = translate_process(lang, de_input, batch_size)
                write_to_file(lang, paraphrase_type, store)


if __name__ == "__main__":
    main()
