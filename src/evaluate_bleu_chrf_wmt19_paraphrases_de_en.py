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
    args = parse_arguments(subtype="evaluate_shallow_metrics")
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
        logger.info("Computing bleu and chrf scores: %s", input_file)
        # load single dictionary and compute surface similarity scores
        with open(input_file, "r") as f:
            store = json.load(f)
        for key in tqdm(store.keys()):
            source_orig_de = store[key]["sentence_original"]["source"]
            source_para_de = store[key]["sentence_paraphrase"]["source"]
            target_orig_en = store[key]["sentence_original"]["target"]
            target_para_en = store[key]["sentence_paraphrase"]["target"]
            chrf_source = (sacrebleu.sentence_chrf(source_orig_de,
                                                   [source_para_de]).score +
                           sacrebleu.sentence_chrf(source_para_de,
                                                   [source_orig_de]).score) / 2
            chrf_target = (sacrebleu.sentence_chrf(target_orig_en,
                                                   [target_para_en]).score +
                           sacrebleu.sentence_chrf(target_para_en,
                                                   [target_orig_en]).score) / 2
            bleu_source = (sacrebleu.sentence_bleu(source_orig_de,
                                                   [source_para_de]).score +
                           sacrebleu.sentence_bleu(source_para_de,
                                                   [source_orig_de]).score) / 2
            bleu_target = (sacrebleu.sentence_bleu(target_orig_en,
                                                   [target_para_en]).score +
                           sacrebleu.sentence_bleu(target_para_en,
                                                   [target_orig_en]).score) / 2
            store[key]["chrf_source"] = chrf_source
            store[key]["chrf_target"] = chrf_target
            store[key]["bleu_source"] = bleu_source
            store[key]["bleu_target"] = bleu_target
            store[key]["chrf_mean"] = (chrf_source + chrf_target) / 2
            store[key]["bleu_mean"] = (bleu_source + bleu_target) / 2
        # write back json to disk
        with open(input_file, "w") as f:
            store = json.dump(store, f, ensure_ascii=False)


if __name__ == "__main__":
    main()
