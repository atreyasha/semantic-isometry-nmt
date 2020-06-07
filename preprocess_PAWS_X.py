#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import StandardScaler
from laserembeddings import Laser
from utils.parser import parse_arguments
from typing import List, Tuple, Union
from glob import glob
import numpy as np
import h5py
import os
import codecs
import joblib
import logging
import logging.config
logging.config.fileConfig('./utils/resources/logging.conf',
                          disable_existing_loggers=False)


def data_generator(file_path: str, batch_size: int = 1000,
                   drop_first: bool = True) -> List[List[str]]:
    """
    Generator which outputs lines in batches

    Args:
      file_path (str): path to file
      batch_size (int): number of data instances in each batch
      drop_first (bool): drop first row given it is a header

    Returns:
      collection (List[List[str]]): parsed textual data with
      newline symbols removed and split at tab symbols
    """
    with codecs.open(file_path, "r", encoding="utf-8") as f:
        collection = []
        for line in f:
            if drop_first:
                drop_first = False
                continue
            split_line = line.strip().split("\t")
            assert len(split_line) == 4
            collection.append(split_line)
            if len(collection) == batch_size:
                yield collection
                collection = []
        if len(collection) != 0:
            yield collection


def convert_2_feature_arrays(sentences: List[str],
                             laser: Laser,
                             lang: str,
                             scalers: Union[None, List[StandardScaler]] = None) -> Tuple[np.ndarray]:
    """
    Converts input sentences into Laser embeddings and
    computes additional features

    Args:
      sentences (List[str]): list containing sentences to embed, paired
      sentences should be adjacent to one another
      laser (Laser): instantiated Laser model object
      lang (str): language identification code
      scalers (Union[None, List[StandardScaler]]): standard scalers to be partially
      fit on training data

    Returns:
      embeddings (np.ndarray): column stacked embeddings for paired sentences
      cosim_norm (np.ndarray): column stacked cosine similarities and norm
      differences between relevant sentence pairs
    """
    embeddings = laser.embed_sentences(sentences, lang=lang)
    evens = embeddings[0::2]
    odds = embeddings[1::2]
    cos_sim = np.array([cosine_similarity(evens[i].reshape(1, -1),
                                          odds[i].reshape(1, -1)).item()
                        for i in range(embeddings.shape[0]//2)], dtype="float32")
    norm_diff = np.linalg.norm(evens-odds, axis=1)
    cosim_norm = np.column_stack((cos_sim, norm_diff))
    if scalers is not None:
        scalers[0].partial_fit(embeddings)
        scalers[1].partial_fit(cosim_norm)
    embeddings = np.column_stack((evens, odds))
    return embeddings, cosim_norm


def create_hdf5_datasets(file_obj: h5py.File,
                         batch_size: int) -> Tuple[h5py.Dataset]:
    """
    Function creates hdf5 datasets for a provided file

    Args:
      file_obj (h5py.File): Opened hdf5 file where datasets will be created
      batch_size (int): Batch size with which to incrementally write

    Returns:
      dset_vec (h5py.Dataset): Pointer to hdf5 dataset for raw embeddings
      dset_cosim_norm (h5py.Dataset): Pointer to hdf5 dataset for cosine
      similarities and vector difference norms
      dset_labels (h5py.Dataset): Pointer to hdf5 dataset for target labels
      dset_ids (h5py.Dataset): Pointer to hdf5 dataset for data id's
    """
    # make generic datasets
    dset_vec = file_obj.create_dataset("embeddings",
                                       shape=(batch_size, 2048),
                                       maxshape=(None, 2048),
                                       compression="gzip",
                                       dtype="float32")
    dset_cosim_norm = file_obj.create_dataset("cosim_norm",
                                              shape=(batch_size, 2),
                                              maxshape=(None, 2),
                                              compression="gzip",
                                              dtype="float32")
    dset_labels = file_obj.create_dataset("labels",
                                          shape=(batch_size,),
                                          maxshape=(None,),
                                          compression="gzip",
                                          dtype="int32")
    dset_ids = file_obj.create_dataset("ids",
                                       shape=(batch_size,),
                                       maxshape=(None,),
                                       compression="gzip",
                                       dtype="int32")
    return dset_vec, dset_cosim_norm, dset_labels, dset_ids


def extend_hdf5_dataset(dset: h5py.Dataset,
                        data: np.ndarray) -> None:
    """
    Function that extends a hdf5 dataset in-place and adds new data

    Args:
      dset (h5py.Dataset): Dataset to extend
      data (np.ndarray): Numpy data to add in dset
    """
    # extend existing dataset with new data
    dset.resize(dset.shape[0]+data.shape[0], axis=0)
    dset[-data.shape[0]:] = data


def main() -> None:
    """
    Function that streams input data, transforms it to Laser-based
    features and finally saves it into hdf5 files
    """
    # get arguments from parser
    args = parse_arguments(subtype="pre_process")
    # set verbosity
    if args.verbosity == 1:
        logger = logging.getLogger('base')
    else:
        logger = logging.getLogger('root')
    # set local variables from parser
    input_lang = args.input_lang
    batch_size = args.batch_size
    laser = Laser()
    input_lang_dirs = glob(os.path.join("./data/x-final", input_lang))
    for input_lang_dir in input_lang_dirs:
        lang = os.path.basename(input_lang_dir)
        logger.info("Processing language: %s", lang)
        input_files = glob(os.path.join(input_lang_dir, "*tsv"))
        assert len(input_files) == 3
        for counter, input_file in enumerate(input_files):
            logger.info("Handling target %d/%d: %s",
                        counter+1, len(input_files), input_file)
            with open(input_file, "r") as f:
                # offset by 1 in case of extra terminal newline symbol
                num_lines = sum(1 for line in f) - 1
            total_batches = int(np.ceil(num_lines/batch_size))
            data = data_generator(input_file, batch_size)
            if "train" in input_file:
                scaler_embeddings = StandardScaler()
                scaler_cn = StandardScaler()
                scalers = [scaler_embeddings, scaler_cn]
            else:
                scalers = None
            # open hdf5 files to write into
            with h5py.File((os.path.splitext(input_file)[0] +
                            ".hdf5"), 'w') as raw:
                (dset_vec, dset_cn,
                 dset_labels, dset_ids) = create_hdf5_datasets(raw, batch_size)
                # initialize batch counter
                first_batch = True
                sub_counter = 0
                for batch in data:
                    logger.info("Batch %d/%d", sub_counter+1, total_batches)
                    sentences = [sentence for data_instance in batch
                                 for sentence in [data_instance[1],
                                                  data_instance[2]]]
                    ids = np.array([int(data_instance[0])
                                    for data_instance in batch],
                                   dtype="int32")
                    labels = np.array([int(data_instance[3])
                                       for data_instance in batch],
                                      dtype="int32")
                    embeddings, cosim_norm = convert_2_feature_arrays(sentences,
                                                                      laser,
                                                                      lang,
                                                                      scalers)
                    if first_batch:
                        dset_vec[:] = embeddings
                        dset_cn[:] = cosim_norm
                        dset_labels[:] = labels
                        dset_ids[:] = ids
                        first_batch = False
                    else:
                        extend_hdf5_dataset(dset_vec, embeddings)
                        extend_hdf5_dataset(dset_cn, cosim_norm)
                        extend_hdf5_dataset(dset_labels, labels)
                        extend_hdf5_dataset(dset_ids, ids)
                    # increment batch counter
                    sub_counter += 1
            if "train" in input_file:
                joblib.dump(scaler_embeddings,
                            os.path.join(input_lang_dir, "scaler_embed.p"))
                joblib.dump(scaler_cn,
                            os.path.join(input_lang_dir, "scaler_cn.p"))


if __name__ == "__main__":
    main()
