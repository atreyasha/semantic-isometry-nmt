#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import h5py
import torch
import torch.utils.data as data
from typing import Callable


class HDF5Dataset(data.Dataset):
    """
    HDF5 Dataset class for downstream PyTorch dataloaders

    Note: Due to restricted reading on HDF5 files, this dataset
    class can only work with num_workers = 1 in DataLoaders
    """

    def __init__(self, file_path):
        """ Initialize dataset class """
        super(HDF5Dataset, self).__init__()
        assert os.path.exists(file_path)
        self.h5_file = h5py.File(file_path, "r")
        self.data = self.h5_file.get("embeddings")[:]
        self.target = self.h5_file.get("labels")[:]

    def __getitem__(self, index):
        """ Get relevant data items with transformations """
        x = torch.from_numpy(self.data[index]).float()
        y = torch.from_numpy(self.target[index]).float()
        # transform x where possible
        # if self.transform is not None:
        #     x = self.transform(x)
        return (x, y)

    def __len__(self):
        """ Check length of dataset """
        return self.data.shape[0]

    def close_hdf5(self):
        """ Close HDF5 file at the end """
        self.h5_file.close()
