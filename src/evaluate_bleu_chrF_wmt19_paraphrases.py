#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from .arg_parser import parse_arguments
from glob import glob
from tqdm import tqdm
import os
import json
import sacrebleu
import logging
import logging.config
logging.config.fileConfig(os.path.join(os.path.dirname(__file__), "resources",
                                       "logging.conf"),
                          disable_existing_loggers=True)


def main() -> None:
    args = parse_arguments(subtype="evaluate")
    # get verbosity
    if args.verbosity == 1:
        logger = logging.getLogger('base')
    else:
        logger = logging.getLogger('root')
    # define json glob
    json_glob = args.json_glob
    # define search space
    files = glob(json_glob)
    for input_file in files:
        # log information
        logger.info("Computing bleu and chrF scores: %s", input_file)
        # load single dictionary and compute surface similarity scores
        with open(input_file, "r") as f:
            store = json.load(f)
        for key in tqdm(store.keys()):
            chrf_src = sacrebleu.sentence_chrf(
                store[key]["sentence_original"]["src"],
                store[key]["sentence_paraphrase"]["src"])
            chrf_translated = sacrebleu.sentence_chrf(
                store[key]["sentence_original"]["translated"],
                store[key]["sentence_paraphrase"]["translated"])
            bleu_src = sacrebleu.sentence_bleu(
                store[key]["sentence_original"]["src"],
                store[key]["sentence_paraphrase"]["src"])
            bleu_translated = sacrebleu.sentence_bleu(
                store[key]["sentence_original"]["translated"],
                store[key]["sentence_paraphrase"]["translated"])
            store[key]["chrF_src"] = chrf_src.score
            store[key]["chrF_translated"] = chrf_translated.score
            store[key]["bleu_src"] = bleu_src.score
            store[key]["bleu_translated"] = bleu_translated.score
            store[key]["chrF_avg"] = (chrf_src.score + chrf_translated.score)/2
            store[key]["bleu_avg"] = (bleu_src.score + bleu_translated.score)/2
        # write back json to disk
        with open(input_file, "w") as f:
            store = json.dump(store, f, ensure_ascii=False)


if __name__ == "__main__":
    main()
