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
    required = parser.add_argument_group('required arguments')
    if subtype == "translate":
        parser.add_argument(
            "--model-subset",
            type=str,
            default="both",
            choices=["local", "hub", "both"],
            help="Whether to use hub or local NMT models, or both")
        parser.add_argument(
            "--checkpoints-glob",
            type=str,
            default=
            "./models/transformer_vaswani_wmt_en_de_big.wmt16.de-en.1594228573/checkpoint_best.pt",
            help="Input glob for finding model checkpoint files")
        parser.add_argument("--wmt-references",
                            type=str,
                            default="both",
                            choices=["ar", "wmt", "both"],
                            help="WMT reference to use")
        parser.add_argument("--batch-size",
                            type=int,
                            default=256,
                            help="Batch size for translation")
    elif "evaluate" in subtype:
        parser.add_argument("--json-glob",
                            type=str,
                            default="./predictions/*/*.json",
                            help="Input glob to find json translation outputs")
        if subtype == "evaluate_paraphrase_detection":
            parser.add_argument("--checkpoints-dir-glob",
                                default="./models/*pawsx*/checkpoint-best",
                                type=str,
                                help="Input glob for finding model checkpoint directories")
            parser.add_argument("--batch-size",
                                default=8,
                                type=int,
                                help="Batch size per GPU/CPU for evaluation")
            parser.add_argument("--no_cuda",
                                action="store_true",
                                help="Avoid using CUDA when available")
            parser.add_argument("--seed",
                                type=int,
                                default=42,
                                help="Random seed for initialization")
            parser.add_argument(
                "--do_lower_case",
                action="store_true",
                help="Set this flag if you are using an uncased model.")
    elif subtype == "tensorboard":
        required.add_argument("--tb-log-dir-glob",
                              required=True,
                              type=str,
                              help="Input glob for finding tensorboard log directories")
    parser.add_argument("--verbosity",
                        type=int,
                        default=1,
                        choices=[0, 1],
                        help=("0 for warning/error logger,"
                              " 1 for verbose information logger"))
    args = parser.parse_args()
    return args
