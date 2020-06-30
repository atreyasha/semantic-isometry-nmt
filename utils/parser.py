#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
from .arg_metav_formatter import arg_metav_formatter


def parse_arguments(subtype: str) -> argparse.Namespace:
    """
    Generic command-line parser which can be re-used across project

    Args:
      subtype (str): subtype of parser which loads extra arguments

    Returns:
      args (Namespace): Namespace object to be used in downstream functions
    """
    parser = argparse.ArgumentParser(formatter_class=arg_metav_formatter)
    if subtype == "translate":
        parser.add_argument("--input_glob",
                            type=str,
                            default="./data/wmt19_paraphrased/*",
                            help="Input glob for WMT19 paraphrase data")
        parser.add_argument("--target-languages",
                            type=str,
                            default="en",
                            help=("Comma separated target language(s),"
                                  " where source language is German"))
        parser.add_argument("--batch-size",
                            type=int,
                            default=256,
                            help="Batch size for translation")
    parser.add_argument("--verbosity",
                        type=int,
                        default=1,
                        choices=[0, 1],
                        help=("0 for warning/error logger,"
                              " 1 for verbose information logger"))
    args = parser.parse_args()
    return args
