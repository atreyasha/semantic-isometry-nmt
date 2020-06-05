#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
from argparse import Namespace
from .arg_metav_formatter import arg_metav_formatter


def parse_arguments() -> Namespace:
    """
    Generic command-line parser which can be re-used across project

    Returns:
      args (Namespace): Namespace object to be used in downstream functions
    """
    parser = argparse.ArgumentParser(formatter_class=arg_metav_formatter)
    parser.add_argument("--input-glob",
                        type=str,
                        default="./data/wmt_all/*en",
                        help="glob for finding input file(s)")
    parser.add_argument("--output-dir",
                        type=str,
                        default="./data/",
                        help="directory for saving outputs")
    parser.add_argument("--corenlp-dir",
                        type=str,
                        default="./data/sgcp/evaluation/apps/stanford-corenlp-full-2018-10-05/",
                        help="directory containing stanford corenlp files")
    parser.add_argument("--random-seed",
                        type=int,
                        default=42,
                        help="Random seed for pseudo-stochastic simulation")
    parser.add_argument("--verbosity",
                        type=int,
                        default=1,
                        choices=[0, 1],
                        help="0 for warnings and critical information,"
                        " 1 for general information and progress bars")
    args = parser.parse_args()
    return args
