## NMT model robustness to hand-crafted adversarial paraphrases

1. [Overview](#Overview-book)
2. [Dependencies](#Dependencies-neckbeard)
3. [Repository Initialization](#Repository-Initialization-fire)
4. [Usage](#Usage-cyclone)
    1. [Training](#Training)
    2. [Translation](#Translation)
    3. [Evaluation](#Evaluation)
5. [Citations](#Citations-sweat_drops)
6. [Development](#Development-snail)

### Overview :book:

This repository investigates the performance of Neural Machine Translation (NMT) models in effectively and consistently transfering the semantics of hand-crafted adversarial paraphrases. Through this, we aim to interpret the robustness of said models to such adversarial paraphrases.

To approach this objective, we start by gathering hand-crafted [paraphrases](https://github.com/google/wmt19-paraphrased-references) of WMT19 `en-de` test data's legacy and additional references. We then translate these paraphrases in the reverse direction ie. `de-en` using both SOTA and non-SOTA NMT models to obtain various translation samples. We use Facebook's FAIR WMT19 winning [base model](https://github.com/pytorch/fairseq/blob/master/examples/translation/README.md) from [Ng. et al., 2019](https://arxiv.org/abs/1907.06616) as our SOTA model. We train a large [transformer model](https://github.com/pytorch/fairseq/blob/master/examples/scaling_nmt/README.md) based off [Ott et al., 2018](https://arxiv.org/abs/1806.00187) on reversed WMT16 data and utilize this model as our non-SOTA model.

Finally, to check the quality/consistency of the translated paraphrases; we train a large paraphrase detection model based off Google's [XTREME](https://github.com/google-research/xtreme) benchmarks on the [PAWS-X](https://github.com/google-research-datasets/paws/tree/master/pawsx) paraphrase detection task and apply this model on the aforementioned translations. A detailed description of our methodologies and results can be found in our research paper. 

### Dependencies :neckbeard:

This repository's code was tested with Python versions `3.7+`. To sync dependencies, we recommend creating a virtual environment and installing the relevant packages via `pip`:

```shell
pip install -r requirements.txt
```

### Repository Initialization :fire:

1. Initialize the [xtreme-pawsx](https://github.com/atreyasha/xtreme-pawsx) git submodule by running the following command:

    ```shell
    bash scripts/setup_xtreme_pawsx.sh
    ```

2. Manually download [preprocessed WMT'16 En-De data](https://drive.google.com/uc?export=download&id=0B_bZck-ksdkpM25jRUN2X2UxMm8) provided by Google and place the tarball in the `data` directory.

3. Manually download the following four pre-trained models and place all of the tarballs in the `models` directory (~9 GB total download size):
    1. [Large NMT Transformer](https://drive.google.com/uc?id=1xT082A30WkwWfxv-scYF2TrOopD1odUt&export=download) for non-SOTA `de-en` translation
    2. [BERT-Multilingual-Base](https://drive.google.com/uc?id=1LFjYMo36RgcS8VDaWoHz1EKQsXgAq_u6&export=download) for multilingual paraphrase detection
    3. [XLM-R-Base](https://drive.google.com/uc?id=1g1KTF7K1rHUPfxmpLGCJ23JW10IHSZOc&export=download) for multilingual paraphrase detection
    4. [XLM-R-Large](https://drive.google.com/uc?id=10iestAbz2aCIOYGRYPAK_kpHukz_pEM4&export=download) for multilingual paraphrase detection

3. To download/prepare `PAWS-X` and `WMT19` original + additional references + paraphrased test data, as well as prepare the previously downloaded `WMT16` data and pre-trained models, run the command below:

    ```shell
    bash scripts/prepare_data_models.sh
    ```

4. **Optional:** We provide a mirror branch `slurm-s3it` for executing scripts on the `s3it` server with `slurm`. To use this branch, simply execute:

    ```
    git checkout slurm-s3it
    ```

5. **Optional:** If you want to further develop this repository; you can auto-format shell scripts and synchronize python dependencies, the development log and the `slurm-s3it` branch by initializing our pre-commit and pre-push `git` hooks:

    ```shell
    bash scripts/setup_git_hooks.sh
    ```

### Usage :cyclone: 

#### i. Training

Since we already provide pre-trained models in this repository, we treat model training from scratch as an auxiliary procedure. If you would like to indeed train non-SOTA NMT and paraphrase detection models from scratch, refer to the instructions in [TRAINING.md](TRAINING.md).

#### ii. Translation

In order to translate WMT19 legacy and additional references with corresponding paraphrases, we provide a script `translate_wmt19_paraphrases_de_en.sh`: 

```
Usage: translate_wmt19_paraphrases_de_en.sh [-h|--help] [glob]
Translate WMT19 paraphrases using both torch-hub and local
model globs

Optional arguments:
  -h, --help   Show this help message and exit
  glob <glob>  Glob for finding local NMT models, defaults to
               "./models/transformer_vaswani_wmt_en_de_big.wmt16.de-en.1594228573"
```

This script will run translation using Facebook FAIR'S winning WMT19 model as the SOTA model and the previously downloaded NMT model as the non-SOTA model. Translation results will be saved as `json` files in the `predictions` directory. To run this script using our defaults, simply execute:

```shell
bash scripts/translate_wmt19_paraphrases_de_en.sh 
```

#### iii. Evaluation

##### BLEU and chrF

After translating the WMT19 paraphrases, we can conduct a *quick and dirty* evaluation of the paraphrases using the `BLEU` and `chrF` sequence similarity metrics. For this, we provide `evaluate_bleu_chrF_wmt19_paraphrases_de_en.sh`:

```
Usage: evaluate_bleu_chrF_wmt19_paraphrases_de_en.sh [-h|--help] [glob]
Conduct shallow evaluation of WMT19 paraphrases with BLEU and
chrF scores

Optional arguments:
  -h, --help   Show this help message and exit
  glob <glob>  Glob for finding input json translations, defaults to
               "./predictions/*/*.json"
```

This script will analyze the translation `json` outputs and append `BLEU` and `chrF` scores in-place. To run this script, simply execute:

```shell
bash scripts/evaluate_bleu_chrF_wmt19_paraphrases.sh
```

### Citations :sweat_drops:

Below are the key citations that were used in this research:

```
@inproceedings{ott2018scaling,
  title = {Scaling Neural Machine Translation},
  author = {Ott, Myle and Edunov, Sergey and Grangier, David and Auli, Michael},
  booktitle = {Proceedings of the Third Conference on Machine Translation (WMT)},
  year = 2018,
}

@InProceedings{pawsx2019emnlp,
  title = {PAWS-X: A Cross-lingual Adversarial Dataset for Paraphrase Identification},
  author = {Yang, Yinfei and Zhang, Yuan and Tar, Chris and Baldridge, Jason},
  booktitle = {Proc. of EMNLP},
  year = {2019}
}

@article{hu2020xtreme,
  author = {Junjie Hu and Sebastian Ruder and Aditya Siddhant and Graham Neubig and Orhan Firat
  and Melvin Johnson},
  title = {XTREME: A Massively Multilingual Multi-task Benchmark for Evaluating Cross-lingual 
  Generalization},
  journal = {CoRR},
  volume = {abs/2003.11080},
  year = {2020},
  archivePrefix = {arXiv},
  eprint = {2003.11080}
}

@article{freitag-bleu-paraphrase-references-2020,
  title = {BLEU might be Guilty but References are not Innocent},
  author = {Markus Freitag and David Grangier and Isaac Caswell},
  journal = {ArXiv},
  year = {2020},
  volume = {abs/2004.06063}
}
```

### Development :snail:

Check our development [log](./docs/develop.md) for information on prospective changes.
