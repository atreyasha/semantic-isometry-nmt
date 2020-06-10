#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import torch
from torch.nn import functional as F
from torch.utils.data import DataLoader
from pytorch_lightning.core.lightning import LightningModule
from sklearn.preprocessing import StandardScaler


class Permutation_Invariant_MLP(LightningModule):

    def __init__(self):
        super().__init__()
        self.layer_1 = torch.nn.Linear(1024, 512)
        self.layer_2 = torch.nn.Linear(512, 256)
        self.layer_3 = torch.nn.Linear(256, 128)
        self.layer_4 = torch.nn.Linear(128, 64)
        self.layer_5 = torch.nn.Linear(64, 32)
        self.layer_6 = torch.nn.Linear(32, 16)
        self.layer_7 = torch.nn.Linear(16, 1)
        self.scaler = StandardScaler()

    # def tune_scaler():
    #     ds = HDF5Dataset("./data/x-final/de/translated_train.hdf5",
    #                      transform = None)
    #     data_loader = DataLoader(ds, batch_size = 512)
    #     for sample in data_loader:
    #         scaler.partial_fit(sample[0].view((sample[0].shape[0]*2,1024)).numpy())

    def forward(self, x):
        batch_size, dims = x.size()
        x = x.view(batch_size, 2, dims//2)
        # layer 1
        x = self.layer_1(x)
        x = torch.relu(x)
        # multiplication
        x = x[:,0,:]*x[:,1,:]
        # layers 2-6
        x = self.layer_2(x)
        x = torch.relu(x)
        x = self.layer_3(x)
        x = torch.relu(x)
        x = self.layer_4(x)
        x = torch.relu(x)
        x = self.layer_5(x)
        x = torch.relu(x)
        x = self.layer_6(x)
        x = torch.relu(x)
        # layer 7
        x = self.layer_7(x)
        # probability score for binary label
        x = torch.sigmoid(x)
        return x

    # def train_dataloader(self):
    #     transform = transforms.Normalize(means, stds)
    #     mnist_train = MNIST(transform=transform)
    #     return DataLoader(mnist_train, batch_size = 64, shuffle = True)

    def training_step(self, batch, batch_idx):
        x, y = batch
        y_hat = self(x)
        loss = F.binary_cross_entropy(y_hat, y)
        return {"loss": loss}

    def configure_optimizers(self):
        return torch.optim.Adam(self.parameters(), lr=0.001)
