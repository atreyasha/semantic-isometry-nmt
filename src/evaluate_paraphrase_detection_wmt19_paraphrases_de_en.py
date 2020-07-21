#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from .arg_parser import parse_arguments
from .paws_x.utils import convert_examples_to_features, InputExample
from torch.utils.data import DataLoader, TensorDataset, SequentialSampler
from typing import Dict, List, Union
from transformers import (
    BertConfig,
    BertForSequenceClassification,
    BertTokenizer,
    XLMRobertaConfig,
    XLMRobertaTokenizer,
    XLMRobertaForSequenceClassification,
)
from tqdm import tqdm
from argparse import Namespace
from scipy.special import softmax
import random
import numpy as np
import glob
import json
import torch
import os
import re
import logging
import logging.config
logging.config.fileConfig(os.path.join(os.path.dirname(__file__), "resources",
                                       "logging.conf"),
                          disable_existing_loggers=True)


def set_seed(args: Namespace) -> None:
    """
    Function to 
"""
    random.seed(args.seed)
    np.random.seed(args.seed)
    torch.manual_seed(args.seed)
    if args.n_gpu > 0:
        torch.cuda.manual_seed_all(args.seed)


def prepare_prediction_data(store: Dict, tokenizer: Union[XLMRobertaTokenizer,
                                                          BertTokenizer],
                            max_seq_length: int) -> List[TensorDataset]:
    examples_source = []
    examples_trans = []
    data_out = []
    for key in store.keys():
        examples_source.append(
            InputExample(guid=key,
                         text_a=store[key]["sentence_original"]["src"],
                         text_b=store[key]["sentence_paraphrase"]["src"],
                         language="de",
                         label=str(store[key]["gold_label"])))
        examples_trans.append(
            InputExample(
                guid=key,
                text_a=store[key]["sentence_original"]["translated"],
                text_b=store[key]["sentence_paraphrase"]["translated"],
                language="en",
                label=str(store[key]["gold_label"])))
    # loop over examples to get features
    for examples in [examples_source, examples_trans]:
        features = convert_examples_to_features(
            examples,
            tokenizer,
            label_list=["0", "1"],
            max_length=max_seq_length,
            output_mode="classification",
            pad_on_left=False,
            pad_token=tokenizer.convert_tokens_to_ids([tokenizer.pad_token
                                                       ])[0],
            pad_token_segment_id=0)
        # Convert to Tensors and build dataset
        all_input_ids = torch.tensor([f.input_ids for f in features],
                                     dtype=torch.long)
        all_attention_mask = torch.tensor([f.attention_mask for f in features],
                                          dtype=torch.long)
        all_token_type_ids = torch.tensor([f.token_type_ids for f in features],
                                          dtype=torch.long)
        all_labels = torch.tensor([f.label for f in features],
                                  dtype=torch.long)
        data_out.append(
            TensorDataset(all_input_ids, all_attention_mask,
                          all_token_type_ids, all_labels))
    return data_out


def predict(model: Union[BertForSequenceClassification,
                         XLMRobertaForSequenceClassification],
            eval_dataloader: DataLoader, args: Namespace) -> np.ndarray:
    preds = None
    for batch in tqdm(eval_dataloader, desc="Evaluating"):
        model.eval()
        batch = tuple(t.to(args.device) for t in batch)
        with torch.no_grad():
            inputs = {
                "input_ids": batch[0],
                "attention_mask": batch[1],
                "labels": batch[3]
            }
            if args.model_type != "distilbert":
                inputs["token_type_ids"] = (
                    batch[2] if args.model_type in ["bert"] else None
                )  # XLM and DistilBERT don't use segment_ids
            outputs = model(**inputs)
            _, logits = outputs[:2]
        if preds is None:
            preds = logits.detach().cpu().numpy()
        else:
            preds = np.append(preds, logits.detach().cpu().numpy(), axis=0)
    return softmax(preds, axis=1)[:, 1]


def main() -> None:
    # define global variable
    global MODEL_CLASSES
    global logger
    MODEL_CLASSES = {
        "bert": (BertConfig, BertForSequenceClassification, BertTokenizer),
        "xlmr": (XLMRobertaConfig, XLMRobertaForSequenceClassification,
                 XLMRobertaTokenizer),
    }
    # parse arguments
    args = parse_arguments(subtype="evaluate_paraphrase_detection")
    # get verbosity
    if args.verbosity == 1:
        logger = logging.getLogger('base')
    else:
        logger = logging.getLogger('root')
    # find input json files
    input_files = glob.glob(args.json_glob)
    # find input model checkpoints
    model_paths = glob.glob(args.model_glob)
    # Setup CUDA and GPU
    device = torch.device(
        "cuda" if torch.cuda.is_available() and not args.no_cuda else "cpu")
    args.n_gpu = torch.cuda.device_count()
    args.device = device
    # Set seed
    set_seed(args)
    # Start model based loop
    for model_path in model_paths:
        metadata = os.path.basename(os.path.dirname(model_path))
        logging.info("Loading model: %s", metadata)
        # infer model type
        if "xlm-roberta" in metadata:
            args.model_type = "xlmr"
        else:
            args.model_type = "bert"
        # infer maximum sequence length
        max_seq_length = int(re.search(r"(ML)([0-9]*)", metadata).groups()[1])
        # load pretrained model and tokenizer
        config_class, model_class, tokenizer_class = MODEL_CLASSES[
            args.model_type]
        tokenizer = tokenizer_class.from_pretrained(
            model_path, do_lower_case=args.do_lower_case)
        model = model_class.from_pretrained(model_path)
        model.to(args.device)
        # start data loop
        for input_file in input_files:
            logging.info("Processing file: %s", input_file)
            with open(input_file, "r") as f:
                store = json.load(f)
            eval_datasets = prepare_prediction_data(store, tokenizer,
                                                    max_seq_length)
            for i, eval_dataset in enumerate(eval_datasets):
                eval_sampler = SequentialSampler(eval_dataset)
                eval_dataloader = DataLoader(eval_dataset,
                                             sampler=eval_sampler,
                                             batch_size=args.batch_size)
                preds = predict(model, eval_dataloader, args).tolist()
                entry = "src" if i == 0 else "translated"
                entry = "%s_%s" % (metadata, entry)
                for j, key in enumerate(store.keys()):
                    store[key].update({entry: preds[j]})
            with open(input_file, "w") as f:
                json.dump(store, f, ensure_ascii=False)


if __name__ == "__main__":
    main()
