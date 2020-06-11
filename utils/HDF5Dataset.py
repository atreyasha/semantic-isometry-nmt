#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import h5py
import torch
import numpy as np
import torch.utils.data as data
from typing import Callable
from sklearn.preprocessing import StandardScaler


class HDF5Dataset_Full_Loader(data.Dataset):

    def __init__(self, file_path):
        super(HDF5Dataset_Full_Loader, self).__init__()
        assert os.path.exists(file_path)
        with h5py.File(file_path, "r") as h5_file:
            self.data = h5_file.get("embeddings")[:]
            self.target = h5_file.get("labels")[:]
        self.scaler = StandardScaler()

    def fit_scaler(self):
        self.scaler.fit(np.reshape(self.data,
                                   (self.data.shape[0]*2,
                                    self.data.shape[1]//2)))

    def apply_scaler(self, scaler = None):
        self.data.resize(self.data.shape[0]*2, self.data.shape[1]//2)
        if scaler is None:
            self.data = self.scaler.transform(self.data)
        else:
            self.data = scaler.transform(self.data)
        self.data.resize(self.data.shape[0]//2,self.data.shape[1]*2)

    def __getitem__(self, index):
        x = torch.from_numpy(self.data[index]).float()
        y = torch.from_numpy(self.target[index]).float()
        return (x, y)

    def __len__(self):
        return self.data.shape[0]
