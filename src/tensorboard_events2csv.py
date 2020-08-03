#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from .arg_parser import parse_arguments
from typing import Dict, List
from collections import defaultdict
from tensorboard.backend.event_processing.event_accumulator import EventAccumulator
from braceexpand import braceexpand
from glob import glob
import os
import csv
import numpy as np
import logging
import logging.config
logging.config.fileConfig(os.path.join(os.path.dirname(__file__), "resources",
                                       "logging.conf"),
                          disable_existing_loggers=True)


def dict2csv(out: Dict[str, List], dpath: str) -> None:
    """
    Function to write dictionary object as csv file

    Args:
        out (Dict[str, List): Dictionary containing values/steps to write
        dpath (str): Path of the directory containing tensoboard logs
    """
    with open(os.path.join(dpath, "%s.csv" % os.path.basename(dpath)),
              "w") as f:
        writer = csv.DictWriter(f, out.keys())
        writer.writeheader()
        for i in range(len(out["steps"])):
            writer.writerow({key: out[key][i] for key in out.keys()})


def tabulate_events(dpath: str) -> Dict[str, List]:
    """
    Function to tabulate and aggregate event logs into single dictionary
    with post-processing to ensure data sanity

    Args:
        dpath (str): Path of the directory containing tensoboard logs

    Returns:
        out (Dict[str, List]): Dictionary containing relevant tensorboard data
    """
    summary_iterators = [
        EventAccumulator(os.path.join(dpath, dname)).Reload()
        for dname in os.listdir(dpath) if ".csv" not in dname
    ]
    # find lowest common denominator in tags
    tags = set(summary_iterators[0].Tags()["scalars"])
    for summary_iterator in summary_iterators[1:]:
        tags.intersection_update(summary_iterator.Tags()["scalars"])
    tags = list(tags)
    # create variable dictionary
    out = defaultdict(list)
    # loop over summary iterators
    for summary_iterator in summary_iterators:
        # find lowest common denominator of step elements
        steps_list = [[event.step for event in summary_iterator.Scalars(tag)]
                      for tag in tags]
        steps = set(steps_list[0])
        for inner_list in steps_list[1:]:
            steps.intersection_update(inner_list)
        # sort these in ascending order
        steps = sorted(list(steps))
        out["steps"].extend(steps)
        for tag in tags:
            hold = []
            for event in summary_iterator.Scalars(tag):
                current_steps = [] if hold == [] else list(zip(*hold))[0]
                if event.step in steps and event.step not in current_steps:
                    hold.append([event.step, event.value])
            # sort hold again in case this was disrupted during event access
            hold = [element[1] for element in sorted(hold, key=lambda x: x[0])]
            # ensure all lengths are the same
            assert len(hold) == len(steps)
            # append to out after sorting/cleaning
            out[tag].extend(hold)
    # sort everything based on steps
    sorting_indices = np.argsort(out["steps"])
    for tag in tags + ["steps"]:
        out[tag] = [out[tag][i] for i in sorting_indices]
    return out


def main() -> None:
    """ Main function to tabulate tensoboard data and write to disk as csv """
    args = parse_arguments(subtype="tensorboard")
    # get verbosity
    if args.verbosity == 1:
        logger = logging.getLogger('base')
    else:
        logger = logging.getLogger('root')
    # parse for tensoboard logs
    tensorboard_log_dir_Glob = args.tensorboard_log_dir_glob
    tensorboard_log_dir_Glob = list(braceexpand(tensorboard_log_dir_Glob))
    tensorboard_log_dirs = [
        log_dir for tensorboard_log_dir_glob in tensorboard_log_dir_Glob
        for log_dir in glob(tensorboard_log_dir_glob)
    ]
    # loop over log directories
    for tensorboard_log_dir in tensorboard_log_dirs:
        logger.info("Processing: %s", tensorboard_log_dir)
        out = tabulate_events(tensorboard_log_dir)
        logger.info("Writing results to directory: %s", tensorboard_log_dir)
        dict2csv(out, tensorboard_log_dir)


if __name__ == "__main__":
    main()
