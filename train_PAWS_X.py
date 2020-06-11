#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import torch
from utils.Permutation_Invariant_MLP import Permutation_Invariant_MLP
from utils.HDF5Dataset import HDF5Dataset_Full_Loader
from torch.utils.data import DataLoader
from pytorch_lightning import Trainer

# initialize and fit train dataset
train_ds = HDF5Dataset_Full_Loader("./data/x-final/de/translated_train.hdf5")
train_ds.fit_scaler()
train_ds.apply_scaler()
# initialize and fit dev dataset
dev_ds = HDF5Dataset_Full_Loader("./data/x-final/de/dev_2k.hdf5")
dev_ds.apply_scaler(train_ds.scaler)
# initialize three data loaders
train_dataloader = DataLoader(train_ds, batch_size = 256, shuffle = True,
                              num_workers = 4)
dev_dataloader = DataLoader(dev_ds, batch_size = 256, num_workers = 4)

# initialize model-specific aspects
model = Permutation_Invariant_MLP()
trainer = Trainer(gpus = 1)
trainer.fit(model, train_dataloader, dev_dataloader)

# Developments:
# TODO add gpus back
# 1. figure out basic grid-search with hparams variable -> GS over LR and DR
# 2. monitor accuracies and performances -> do it quickly
# Note: model checkpointing and early stopping are already implemented
