#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from .arg_parser import parse_arguments
from typing import List, Dict
from tqdm import tqdm
from glob import glob
from fairseq.hub_utils import GeneratorHubInterface
from fairseq.models.transformer import TransformerModel
import codecs
import json
import re
import os
import torch
import logging
import logging.config
logging.config.fileConfig(os.path.join(os.path.dirname(__file__), "resources",
                                       "logging.conf"),
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
    path = os.path.join("./predictions", model_name)
    os.makedirs(path, exist_ok=True)
    with open(os.path.join(path, metadata + ".json"), "w") as json_file:
        json.dump(store, json_file, ensure_ascii=False)


def translate_process(model: GeneratorHubInterface, input_data: List[str],
                      batch_size: int) -> Dict:
    """
    Translate source data and append outputs into neat dictionary

    Args:
        model (GeneratorHubInterface): Translation model interface class
        input_data (List[str]): Source sentences (without preprocessing)
        batch_size (int): Batch size for translation

    Returns:
        store (Dict): Dictionary output containing all necessary translations
    """
    # initialize data store
    store = {}
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
    # model subsets
    model_subset = args.model_subset
    # local model glob
    model_checkpoints_glob = args.checkpoints_glob
    # initialize model names
    model_names = []
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
    if model_subset in ["local", "both"]:
        model_names.extend(glob(model_checkpoints_glob))
    if model_subset in ["hub", "both"]:
        model_names.append("transformer.wmt19.de-en.single_model")
    # loop over respective models
    for model_name in model_names:
        # add rules for loading models
        if model_name == "transformer.wmt19.de-en.single_model":
            model = torch.hub.load("pytorch/fairseq",
                                   model_name,
                                   tokenizer="moses",
                                   bpe="fastbpe")
            model_name = "torch_hub." + model_name
        else:
            model = TransformerModel.from_pretrained(
                os.path.dirname(model_name),
                checkpoint_file=os.path.basename(model_name),
                bpe="fastbpe",
                tokenizer="moses",
                data_name_or_path="./bpe/",
                bpe_codes=os.path.join(os.path.dirname(model_name), "bpe",
                                       "bpe.32000"))
            model_name = "local." + os.path.basename(
                os.path.dirname(model_name))
        # disable dropout for prediction
        model.eval()
        # enable GPU hardware acceleration if GPU/CUDA present
        if torch.cuda.is_available():
            model.cuda()
        # log model used in current loop
        logger.info("Translating with model: %s", model_name)
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
            # modify metadata
            if all(re.search(r"-arp?.ref$", path) for path in input_paths):
                metadata = "wmt19.ar.arp"
            else:
                metadata = "wmt19.wmt.wmtp"
            # write json to disk
            write_to_file(model_name, metadata, store)


if __name__ == "__main__":
    main()
