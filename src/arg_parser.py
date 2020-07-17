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
      args (argparse.Namespace): Namespace object for downstream functions
    """
    parser = argparse.ArgumentParser(formatter_class=arg_metav_formatter)
    if subtype == "translate":
        parser.add_argument("--model-subset",
                            type=str,
                            default="both",
                            choices=["local", "hub", "both"],
                            help="Whether to use hub or local NMT models, or both")
        parser.add_argument("--local-model-glob",
                            type=str,
                            default="./models/transformer_vaswani_wmt_en_de_big.wmt16.de-en.1594228573",
                            help="Input glob to find local models")
        parser.add_argument("--wmt-references",
                            type=str,
                            default="both",
                            choices=["ar", "wmt", "both"],
                            help="WMT reference to use")
        parser.add_argument("--batch-size",
                            type=int,
                            default=128,
                            help="Batch size for translation")
    parser.add_argument("--verbosity",
                        type=int,
                        default=1,
                        choices=[0, 1],
                        help=("0 for warning/error logger,"
                              " 1 for verbose information logger"))
    args = parser.parse_args()
    return args
