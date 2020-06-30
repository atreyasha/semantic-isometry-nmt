#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from utils.parser import parse_arguments
from typing import List, Dict, Union, Tuple, Any
from tqdm import tqdm
from glob import glob
import codecs
import json
import os
import torch
import logging
import logging.config
logging.config.fileConfig('./utils/resources/logging.conf',
                          disable_existing_loggers=True)


def read_data(file_path: str, drop_first: bool = False) -> List[str]:
    """
    Function to read textual data with simple newline formatting

    Args:
        file_path (str): path to file
        drop_first (bool): drop first row given it is a header

    Returns:
        collection (List[str]): parsed textual data with
        newline symbols removed
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
    """
    Interweave two datasets into one with the same ordering;
    different from zip because it requires an index and
    gold label to be inserted

    Args:
        dataset_1 (List[str]): First dataset
        dateset_2 (List[str]): Second dataset

    Returns:
        interwoven (List[str]): Interwoven dataset
    """
    interwoven = []
    for i in range(len(dataset_1)):
        interwoven.append([i, dataset_1[i], dataset_2[i], 1])
    return interwoven


def write_to_file(target_lang: str, model_name: str, paraphrase_type: str,
                  store: Dict) -> None:
    """
    Write processed dictionary to json file

    Args:
        target_lang (str): Target language
        model_name (str): Name of translation model
        paraphrase_type (str): Type of paraphrase data supplied
        store (Dict): Dictionary ouput of translation task
    """
    # write everything to a json file to keep things simple
    path = os.path.join("./out", model_name, "de-" + target_lang)
    os.makedirs(path, exist_ok=True)
    with open(os.path.join(path, paraphrase_type + ".json"), "w") as json_file:
        json.dump(store, json_file, ensure_ascii=False)


def translate_process(
        model: Any, input_data: List[str],
        batch_size: int,
        original_cache: Union[None, List[str]]) -> Tuple[Dict, List[str]]:
    """
    Translate source data and append outputs into neat dictionary

    Args:
        input_data (List[str]): Source sentences
        batch_size (int): Batch size for translation
        original_cache (Union[None, List[str]): Cache of original data
        translation, otherwise set to be None

    Returns:
        store (Dict): Dictionary output containing all necessary translations
        original_cache (List[str]): Cache of original data translations
    """
    # initialize data store
    store = {}
    # define whether to use cache or not
    if original_cache is not None:
        use_cache = True
    else:
        use_cache = False
        original_cache = []
    # disable dropout for prediction
    model.eval()
    # enable GPU hardware acceleration if GPU/CUDA present
    if torch.cuda.is_available():
        model.cuda()
    # conduct batch translation and data processing
    for i in tqdm(range(0, len(input_data), batch_size)):
        chunk = input_data[i:i + batch_size]
        if use_cache:
            original = original_cache[i:i + batch_size]
        else:
            original = [seg[1] for seg in chunk]
            original = model.translate(original)
            original_cache.extend(original)
        paraphrase = [seg[2] for seg in chunk]
        paraphrase = model.translate(paraphrase)
        for j, seg in enumerate(chunk):
            store[seg[0]] = {
                "sentence_original": {
                    "src": seg[1],
                    "translated": original[j]
                },
                "sentence_paraphrase": {
                    "src": seg[2],
                    "translated": paraphrase[j]
                },
                "gold_label": seg[3]
            }
    # return final dictionary
    return store, original_cache


def main() -> None:
    """
    Main function to read, translate and write data to disk
    """
    args = parse_arguments(subtype="translate")
    # get verbosity
    if args.verbosity == 1:
        logger = logging.getLogger('base')
    else:
        logger = logging.getLogger('root')
    # get batch-size
    batch_size = args.batch_size
    # get paths corresponding to glob
    input_paths = glob(args.input_glob)
    assert len(input_paths) > 0, "No paths found corresponding to input glob"
    # read original de data here
    logger.info("Reading WMT19 'de' reference data")
    de_input_original = read_data("./data/wmt19/wmt19.test.truecased.de.ref")
    # define available models for de-en
    model_names = [
        "transformer.wmt19.de-en", "transformer.wmt19.de-en.single_model"
    ]
    # loop over respective models
    for model_name in model_names:
        if "single_model" in model_name:
            model = torch.hub.load("pytorch/fairseq",
                                   model_name,
                                   tokenizer="moses",
                                   bpe="fastbpe")
        else:
            model = torch.hub.load(
                "pytorch/fairseq",
                model_name,
                checkpoint_file="model1.pt:model2.pt:model3.pt:model4.pt",
                tokenizer="moses",
                bpe="fastbpe")
        # loop over paraphrase files
        for i, input_path in enumerate(input_paths):
            paraphrase_type = os.path.basename(input_path)
            logger.info(
                "Reading WMT19 'de %s' paraphrased reference data: %d/%d",
                paraphrase_type, i + 1, len(input_paths))
            # read de paraphrase data
            de_input_paraphrased = read_data(input_path)
            # perform sanity check on de overall data
            logger.info("Performing sanity checks on 'de' input data")
            assert len(de_input_original) == len(de_input_paraphrased)
            # assemble combined input data
            de_input = interweave(de_input_original, de_input_paraphrased)
            logger.info("Translating and processing to 'en'")
            if i == 0:
                # translate and cache original translations for re-use
                store, original_cache = translate_process(
                    model, de_input, batch_size, None)
            else:
                # translate and use existing translation cache
                store, _ = translate_process(model, de_input, batch_size,
                                             original_cache)
            # write json to disk
            write_to_file("en", model_name, paraphrase_type, store)


if __name__ == "__main__":
    main()
