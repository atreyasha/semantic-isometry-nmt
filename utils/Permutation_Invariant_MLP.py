#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import torch
from torch.nn import functional as F
from torch.utils.data import DataLoader
from pytorch_lightning.core.lightning import LightningModule


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
        self.dropout = torch.nn.Dropout(0.3)

    def forward(self, x):
        batch_size, dims = x.size()
        x = x.view(batch_size, 2, dims//2)
        # layer 1
        x = self.layer_1(x)
        x = torch.relu(x)
        x = self.dropout(x)
        # multiply to merge and keep permutation invariance
        x = x[:,0,:]*x[:,1,:]
        # layers 2-6
        x = self.layer_2(x)
        x = torch.relu(x)
        x = self.dropout(x)
        x = self.layer_3(x)
        x = torch.relu(x)
        x = self.dropout(x)
        x = self.layer_4(x)
        x = torch.relu(x)
        x = self.dropout(x)
        x = self.layer_5(x)
        x = torch.relu(x)
        x = self.dropout(x)
        x = self.layer_6(x)
        x = torch.relu(x)
        x = self.dropout(x)
        # layer 7
        x = self.layer_7(x)
        # probability score for binary label
        x = torch.sigmoid(x)
        return x

    def training_step(self, batch, batch_idx):
        x, y = batch
        y_hat = self(x)
        loss = F.binary_cross_entropy(y_hat, y)
        logs = {"loss": loss}
        return {"loss": loss, "log": logs}

    def validation_step(self, batch, batch_idx):
        x, y = batch
        y_hat = self(x)
        loss = F.binary_cross_entropy(y_hat, y)
        return {"val_loss": loss}

    def validation_epoch_end(self, outputs):
        avg_loss = torch.stack([x["val_loss"] for x in outputs]).mean()
        tensorboard_logs = {"val_loss": avg_loss}
        return {"val_loss": avg_loss, "log": tensorboard_logs}

    def configure_optimizers(self):
        return torch.optim.Adam(self.parameters(), lr=0.001)
