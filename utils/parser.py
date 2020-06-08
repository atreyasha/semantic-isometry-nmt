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
    parser.add_argument("--input-glob",
                        type=str,
                        default="./data/x-final/*/*.tsv",
                        help="glob for finding input file(s)")
    if subtype == "train":
        parser.add_argument("--random-seed",
                            type=int,
                            default=42,
                            help="Random seed for pseudo-stochastic simulation")
    elif subtype == "pre_process":
        parser.add_argument("--batch-size",
                            type=int,
                            default=1000,
                            help="Batch size for reading/writing data")
    parser.add_argument("--verbosity",
                        type=int,
                        default=1,
                        choices=[0, 1],
                        help="0 for warnings and critical information,"
                        " 1 for general information and progress bars")
    args = parser.parse_args()
    return args
