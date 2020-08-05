## Investigating the isometric properties of Neural Machine Translation functions on semantic metric spaces

1. [Overview](#Overview-book)
2. [Dependencies](#Dependencies-neckbeard)
3. [Repository initialization](#Repository-initialization-fire)
4. [Usage](#Usage-cyclone)
    1. [Training](#i-Training)
    2. [Translation](#ii-Translation)
    3. [Evaluation](#iii-Evaluation)
    4. [Visualization](#iv-Visualization)
5. [References](#References-sweat_drops)
6. [Development](#Development-snail)

### Overview :book:

Isometry can be defined as a distance-preserving transformation between metric spaces. This repository investigates the isometric properties of Neural Machine Translation (NMT) functions (and thereby models) on semantic metric spaces.

To motivate this investigation, we postulate that well-performing NMT models should preserve a supposed semantic distance metric on both the source and target-side. That is to say; if two sentences are semantically equivalent on the source side, they should also be semantically equivalent after translation on the target side. This concept of isometry in a semantic metric space can be stated more explicitly with the following mathematical description:

<p align="center">
<img src="./img/basic_eqn.svg" width="400">
</p>

To approach this objective, we start by gathering hand-crafted (semantically equivalent) [paraphrases](https://github.com/google/wmt19-paraphrased-references) of WMT19 `en-de` test data's legacy and additional references. We then translate these paraphrases in the reverse direction ie. `de-en` using both SOTA and non-SOTA NMT models to introduce performance-dependent variance into translation samples. We use Facebook's FAIR WMT19 winning (single) model from [Ng. et al., 2019](https://arxiv.org/abs/1907.06616) as our SOTA model. We train a large transformer model based on the Scaling NMT methodology from [Ott et al., 2018](https://arxiv.org/abs/1806.00187) on reversed WMT16 data and utilize this model as our non-SOTA model.

We then quantify (and simplify) the notion of a semantic distance metric into a binary decision problem, specifically between semantic equality and inequality. For this, we train and utilize paraphrase detection models; where a positive result for paraphrase detection corresponds to semantic equality while a negative result corresponds to semantic inequality.

To realize this concept, we train large paraphrase detection models based off Google's [XTREME](https://github.com/google-research/xtreme) benchmarks on the [PAWS-X](https://github.com/google-research-datasets/paws/tree/master/pawsx) paraphrase detection task and apply these models on the aforementioned translations. A more detailed description of our methodologies and results can be found in our research paper. 

### Dependencies :neckbeard:

1. This repository's code was tested with Python versions `3.7+`. To sync dependencies, we recommend creating a virtual environment and installing the relevant packages via `pip`:

    ```shell
    pip install -r requirements.txt
    ```

2. In this repository, we use `R` (versions `3.6+`) and `lualatex` for efficient `TikZ` visualizations. Execute the following within your `R` console to get the dependencies:

    ```r
    install.packages(c("ggplot2","optparse","tikzDevice","rjson","ggpointdensity",
                       "fields","gridExtra","devtools"))
    devtools::install_github("teunbrand/ggh4x")
    ```

### Repository initialization :fire:

1. Initialize the [xtreme-pawsx](https://github.com/atreyasha/xtreme-pawsx) git submodule by running the following command:

    ```shell
    bash scripts/setup_xtreme_pawsx.sh
    ```

2. Manually download [preprocessed WMT'16 En-De data](https://drive.google.com/uc?export=download&id=0B_bZck-ksdkpM25jRUN2X2UxMm8) provided by Google and place the tarball in the `data` directory (~480 MB download size).

3. Manually download the following four pre-trained models and place all of the tarballs in the `models` directory (~9 GB total download size):
    1. [Scaling NMT WMT16 Transformer](https://drive.google.com/uc?id=16LGqlWYppOYVgy7EKMdL7H4j8pj_DXfV&export=download) for non-SOTA `de-en` translation
    2. [BERT-Multilingual-Base](https://drive.google.com/uc?id=1LFjYMo36RgcS8VDaWoHz1EKQsXgAq_u6&export=download) for multilingual paraphrase detection
    3. [XLM-R-Base](https://drive.google.com/uc?id=1g1KTF7K1rHUPfxmpLGCJ23JW10IHSZOc&export=download) for multilingual paraphrase detection
    4. [XLM-R-Large](https://drive.google.com/uc?id=10iestAbz2aCIOYGRYPAK_kpHukz_pEM4&export=download) for multilingual paraphrase detection

3. To download/prepare `PAWS-X` and `WMT19` original + additional references + paraphrased test data, as well as prepare the previously downloaded `WMT16` data and pre-trained models, run the command below:

    ```shell
    bash scripts/prepare_data_models.sh
    ```

4. **Optional:** We provide a mirror branch `slurm-s3it` for executing computationally heavy workflows (eg. training, evaluating) on the `s3it` server with `slurm`. To use this branch, simply execute:

    ```
    git checkout slurm-s3it
    ```

5. **Optional:** If you want to further develop this repository; you can auto-format shell/R scripts and synchronize python dependencies, the development log and the `slurm-s3it` branch by initializing our pre-commit and pre-push `git` hooks:

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
Translate WMT19 paraphrases using both torch-hub and local models

Optional arguments:
  -h, --help   Show this help message and exit
  glob <glob>  Glob for finding local NMT model checkpoints, defaults to
               "./models/transformer_vaswani_wmt_en_de_big.wmt16.de-en.1594228573/
               checkpoint_best.pt"
```

This script will run translation using Facebook FAIR's winning WMT19 model as the SOTA model and the previously downloaded NMT model as the non-SOTA model. Translation results will be saved as `json` files in the `predictions` directory. To run this script using our defaults, simply execute:


```shell
bash scripts/translate_wmt19_paraphrases_de_en.sh 
```

#### iii. Evaluation

##### BLEU and chrF

After translating the WMT19 paraphrases, we can conduct a *quick and dirty* evaluation of the paraphrases using the `BLEU` and `chrF` sequence similarity metrics. For this, we provide `evaluate_bleu_chrf_wmt19_paraphrases_de_en.sh`:

```
Usage: evaluate_bleu_chrf_wmt19_paraphrases_de_en.sh [-h|--help] [glob]
Conduct shallow evaluation of WMT19 paraphrases with BLEU and
chrF scores

Optional arguments:
  -h, --help   Show this help message and exit
  glob <glob>  Glob for finding input json translations, defaults to
               "./predictions/*/*.json"
```

This script will analyze the translation `json` outputs and append `BLEU` and `chrF` scores in-place. To run this script, simply execute:

```shell
bash scripts/evaluate_bleu_chrf_wmt19_paraphrases_de_en.sh
```

##### Paraphrase detection

Next, we can run our pre-trained paraphrase detection models on the translations. For this, we provide `evaluate_paraphrase_detection_wmt19_paraphrases_de_en.sh`:

```
Usage: evaluate_paraphrase_detection_wmt19_paraphrases_de_en.sh [-h|--help] [glob]
Conduct evaluation of WMT19 paraphrases using pre-trained paraphrase
detection models

Optional arguments:
  -h, --help   Show this help message and exit
  glob <glob>  Glob for finding input json translations, defaults to
               "./predictions/*/*.json"
```

This script will analyze the translation `json` outputs and append the paraphrase detection models' `softmax` scores for the paraphrase (or positive) label. The input `json` files will also be updated with these scores in-place. To run this script, simply execute:

```shell
bash scripts/evaluate_paraphrase_detection_wmt19_paraphrases_de_en.sh
```

#### iv. Visualization

##### Model evolutions

In order to plot the evolutions of model training parameters, we provide `visualize_model_evolutions.sh`:

```
Usage: visualize_model_evolutions.sh [-h|--help] [glob]
Visualize model evolutions for translation and paraphrase detection models

Optional arguments:
  -h, --help   Show this help message and exit
  glob <glob>  Glob for finding tensorboard log directories, which will
               be converted to csv's and then plotted. Defaults to
               "./models/*/{train,train_inner,valid}"
```

This script will aggregate/convert tensorboard event logs into `csv` files and produce/save fancy plots of model evolutions as tikz-based `pdf` files in the `img` directory. To run this script, simply execute:

```shell
bash scripts/visualize_model_evolutions.sh
```

##### BLEU and chrF

In order to visualize the previously processed `BLEU` and `chrF` results, we provide `visualize_bleu_chrf_wmt19_paraphrases_de_en.sh`:

```
Usage: visualize_bleu_chrf_wmt19_paraphrases_de_en.sh [-h|--help] [glob]
Visualize shallow evaluation scores of WMT19 paraphrase translations

Optional arguments:
  -h, --help   Show this help message and exit
  glob <glob>  Glob for finding input json translations, defaults to
               "./predictions/*/*.json"
```

This script will produce fancy plots of the respective shallow evaluation scores and will save them as tikz-based `pdf` files in the `img` directory. To run this script, simply execute:

```shell
bash scripts/visualize_bleu_chrf_wmt19_paraphrases_de_en.sh
```

##### Paraphrase detection

In order to visualize the previously processed paraphrase detection results, we provide `visualize_paraphrase_detection_wmt19_paraphrases_de_en.sh`:

```
Usage: visualize_paraphrase_detection_wmt19_paraphrases_de_en.sh [-h|--help] [glob]
Visualize paraphrase detection predictions of WMT19 paraphrase translations

Optional arguments:
  -h, --help   Show this help message and exit
  glob <glob>  Glob for finding input json translations, defaults to
               "./predictions/*/*.json"
```

This script will produce fancy plots of the respective paraphrase detection `softmax` scores and will save them as tikz-based `pdf` files in the `img` directory. To run this script, simply execute:

```shell
bash scripts/visualize_paraphrase_detection_wmt19_paraphrases_de_en.sh
```

##### Correlation between chrF and paraphrase detection predictions

In order to visualize correlations between `chrF` scores and paraphrase detection predictions, we provide `visualize_paraphrase_detection_wmt19_paraphrases_de_en.sh`:

```
Usage: visualize_chrf_paraphrase_detection_wmt19_paraphrases_de_en.sh [-h|--help] [glob]
Visualize chrf and paraphrase detection predictions of WMT19 paraphrase translations

Optional arguments:
  -h, --help   Show this help message and exit
  glob <glob>  Glob for finding input json translations, defaults to
               "./predictions/*/*.json"
```

This script will produce fancy plots of correlations between `chrF` and paraphrase detection predictions and will save them as tikz-based `pdf` files in the `img` directory. To run this script, simply execute:

```shell
bash scripts/visualize_chrf_paraphrase_detection_wmt19_paraphrases_de_en.sh
```

### References :sweat_drops:

Below are the key references that were used in this research:

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
