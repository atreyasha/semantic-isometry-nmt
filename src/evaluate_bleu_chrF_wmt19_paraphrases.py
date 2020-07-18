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
            src_orig_de = store[key]["sentence_original"]["src"]
            src_para_de = store[key]["sentence_paraphrase"]["src"]
            trans_orig_en = store[key]["sentence_original"]["translated"]
            trans_para_en = store[key]["sentence_paraphrase"]["translated"]
            chrf_src = (sacrebleu.sentence_chrf(src_orig_de,
                                                src_para_de).score +
                        sacrebleu.sentence_chrf(src_para_de,
                                                src_orig_de).score)/2
            chrf_trans = (sacrebleu.sentence_chrf(trans_orig_en,
                                                  trans_para_en).score +
                          sacrebleu.sentence_chrf(trans_para_en,
                                                  trans_orig_en).score)/2
            bleu_src = (sacrebleu.sentence_bleu(src_orig_de,
                                                src_para_de).score +
                        sacrebleu.sentence_bleu(src_para_de,
                                                src_orig_de).score)/2
            bleu_trans = (sacrebleu.sentence_bleu(trans_orig_en,
                                                  trans_para_en).score +
                          sacrebleu.sentence_bleu(trans_para_en,
                                                  trans_orig_en).score)/2
            store[key]["chrF_src"] = chrf_src
            store[key]["chrF_translated"] = chrf_trans
            store[key]["bleu_src"] = bleu_src
            store[key]["bleu_translated"] = bleu_trans
            store[key]["chrF_avg"] = (chrf_src + chrf_trans)/2
            store[key]["bleu_avg"] = (bleu_src + bleu_trans)/2
        # write back json to disk
        with open(input_file, "w") as f:
            store = json.dump(store, f, ensure_ascii=False)


if __name__ == "__main__":
    main()
