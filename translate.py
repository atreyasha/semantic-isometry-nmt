#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from utils.parser import parse_arguments
from typing import List, Dict, Any
from tqdm import tqdm
import codecs
import json
import re
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
    assert len(dataset_1) == len(
        dataset_2), "Input datasets have differing lengths"
    interwoven = []
    for i in range(len(dataset_1)):
        interwoven.append([i, dataset_1[i], dataset_2[i], 1])
    return interwoven


def write_to_file(model_name: str, metadata: str, store: Dict) -> None:
    """
    Write processed dictionary to json file

    Args:
        model_name (str): Name of translation model
        metadata (str): Metadata for naming of file
        store (Dict): Dictionary ouput of translation task
    """
    # write everything to a json file to keep things simple
    path = os.path.join("./out", model_name)
    os.makedirs(path, exist_ok=True)
    with open(os.path.join(path, metadata + ".json"), "w") as json_file:
        json.dump(store, json_file, ensure_ascii=False)


def translate_process(model: Any, input_data: List[str],
                      batch_size: int) -> Dict:
    """
    Translate source data and append outputs into neat dictionary

    Args:
        model (fairseq.hub_utils.GeneratorHubInterface): Translation model,
        defaults to 'Any' type because this class is dynamically loaded
        input_data (List[str]): Source sentences
        batch_size (int): Batch size for translation

    Returns:
        store (Dict): Dictionary output containing all necessary translations
    """
    # initialize data store
    store = {}
    # disable dropout for prediction
    model.eval()
    # enable GPU hardware acceleration if GPU/CUDA present
    if torch.cuda.is_available():
        model.cuda()
    # conduct batch translation and data processing
    for i in tqdm(range(0, len(input_data), batch_size)):
        chunk = input_data[i:i + batch_size]
        original = [seg[1] for seg in chunk]
        original = model.translate(original)
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
    return store


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
    # create path dictionary
    path_dict = {
        "wmt": [[
            "./data/wmt19/wmt19.test.truecased.de.ref",
            "./data/wmt19_paraphrased/wmt19-ende-wmtp.ref"
        ]],
        "ar": [[
            "./data/wmt19_paraphrased/wmt19-ende-ar.ref",
            "./data/wmt19_paraphrased/wmt19-ende-arp.ref"
        ]]
    }
    path_dict["both"] = path_dict["wmt"] + path_dict["ar"]
    # define available models for de-en
    model_names = [
        "transformer.wmt19.de-en.single_model", "transformer.wmt19.de-en"
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
            # reduce batch size due to high memory usage
            batch_size = 32
        # loop over paraphrase files
        for input_paths in path_dict[args.wmt_references]:
            base = os.path.basename(input_paths[0])
            # read original de data here
            logger.info("Reading reference data: %s", base)
            de_input_original = read_data(input_paths[0])
            # read de paraphrase data
            logger.info("Reading paraphrased reference data: %s",
                        os.path.basename(input_paths[1]))
            de_input_paraphrased = read_data(input_paths[1])
            # assemble combined input data
            logger.info("Interweaving 'de' input data")
            de_input = interweave(de_input_original, de_input_paraphrased)
            logger.info("Translating and processing to 'en'")
            # translate and process
            store = translate_process(model, de_input, batch_size)
            # get relevant metadata for writing to disk
            if all(re.search("-arp?.ref$", path) for path in input_paths):
                metadata = "wmt19.ar.arp"
            else:
                metadata = "wmt19.wmt.wmtp"
            # write json to disk
            write_to_file(model_name, metadata, store)


if __name__ == "__main__":
    main()
