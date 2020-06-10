#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import torch
from utils.model_utils import Permutation_Invariant_MLP
from utils.HDF5Dataset import HDF5Dataset
from torch.utils.data import DataLoader
from pytorch_lightning import Trainer

ds = HDF5Dataset("./data/x-final/de/translated_train.hdf5")
train_dataloader = DataLoader(ds, batch_size = 256, shuffle = True)
model = Permutation_Invariant_MLP()
trainer = Trainer(max_epochs=100)
trainer.fit(model, train_dataloader)
# ds.close_hdf5()

# Developments:
# TODO add scaler initialization step -> can transform with torch normalizer
# TODO add dropout and other optimizations here
# TODO set up quick code and run grid-search for best models
# close all datasets at the end
