## Training models

1. [Training fairseq NMT model on WMT16 de-en](#1-Training-fairseq-NMT-model-on-WMT16-de-en)
2. [Fine-tuning multilingual transformer language model on PAWS-X](#2-Fine-tuning-multilingual-transformer-language-model-on-PAWS-X)
3. [Exporting-models](#3-Exporting-models)

### Overview

This readme provides additional information on training/fine-tuning models used in this repository from (quasi) scratch. It is highly recommended to use the defaults as per the provided shell scripts, since there could be unforeseen issues related to using new model configurations.

### 1. Training fairseq NMT model on WMT16 de-en

1. Preprocess WMT16 with pre-computed BPE codes into an appropriate format using `preprocess_wmt16_de_en.sh`:

    ```
    Usage: preprocess_wmt16_de_en.sh [-h|--help]
    Preprocess WMT16 de-en data for training fairseq model

    Optional arguments:
      -h, --help  Show this help message and exit
    ```

    To run this script, execute:

    ```shell
    bash scripts/preprocess_wmt16_de_en.sh
    ```

2. Train a large transformer model using `train_wmt16_de_en.sh`:

    ```
    Usage: train_wmt16_de_en.sh [-h|--help] [arch]
    Train fairseq model on WMT16 de-en data

    Optional arguments:
      -h, --help           Show this help message and exit
      arch <fairseq_arch>  Architecture for use in model, defaults
                           to "transformer_vaswani_wmt_en_de_big"    
    ```

    Generally, any of the `fairseq` [architectures](<https://fairseq.readthedocs.io/en/latest/command_line_tools.html#Model configuration>) could be used as an argument for this script. To use our default settings based on experiments, simply execute:

    ```
    bash scripts/train_wmt16_de_en.sh
    ```

3. In case training was discontinued and needs to be continued later on, use `train_continue_wmt16_de_en.sh`:

    ```
    Usage: train_continue_wmt16_de_en.sh [-h|--help] model_directory
    Continue training fairseq model on WMT16 de-en data

    Optional arguments:
      -h, --help              Show this help message and exit

    Required arguments:
      model_directory <path>  Path to directory containing model
                              checkpoints
    ```

    An example of running this script would be:

    ```shell
    bash scripts/train_continue_wmt16_de_en.sh \
    "./models/transformer_vaswani_wmt_en_de_big.wmt16.de-en.1594228573"
    ```

4. Evaluate an existing checkpoint using `evaluate_wmt16_de_en.sh`:

    ```
    Usage: evaluate_wmt16_de_en.sh [-h|--help] checkpoint [subset]
    Evaluate trained fairseq model on WMT16 de-en data

    Optional arguments:
      -h, --help         Show this help message and exit
      subset <str>       Which subset to evaluate in {train, valid, test},
                         defaults to "test"

    Required arguments:
      checkpoint <path>  Path to checkpoint which should be used
    ```

    An example of running this script would be:

    ```shell
    bash scripts/evaluate_wmt16_de_en.sh \
    "./models/transformer_vaswani_wmt_en_de_big.wmt16.de-en.1594228573/checkpoint_best.pt"
    ```

5. After choosing the best model, execute post-processing on the model directory using `postprocess_wmt16_de_en.sh`:

    ```
    Usage: postprocess_wmt16_de_en.sh [-h|--help] model_directory...
    Postprocess desired model directories to get them ready for exporting

    Optional arguments:
      -h, --help              Show this help message and exit

    Required arguments:
      model_directory <path>  Path to directory containing model
                              checkpoints
    ```

    This process copies over relevant `bpe` files into the model directory; which is necessary in order to export the model. An example of running this script would be:

    ```shell
    bash scripts/postprocess_wmt16_de_en.sh \
    "./models/transformer_vaswani_wmt_en_de_big.wmt16.de-en.1594228573"
    ```

### 2. Fine-tuning multilingual transformer language model on PAWS-X

Fine-tune a large multilingual transformer language model on the `PAWS-X` paraphrase detection task using `train_evaluate_pawsx.sh`:

```
Usage: train_evaluate_pawsx.sh [-h|--help] [model]
Train (fine-tune) and evaluate multilingual transformer
language models on the PAWS-X paraphrase detection task

Optional arguments:
  -h, --help     Show this help message and exit
  model <model>  Pre-trained language model to fine-tune,
                 defaults to "xlm-roberta-large"
```

Our script allows for fine-tuning using the three following language models: `bert-base-multilingual-cased`, `xlm-roberta-base` and `xlm-roberta-large`. In order to use our default settings, simply execute:

```shell
bash scripts/train_evaluate_pawsx.sh
```

This script will automatically evaluate the model against the `dev` set during training and the `test` set after training. Therefore a separate evaluation step is not necessary.

### 3. Exporting models

To export the final models, you can use `export_tar_gz.sh`:

```
Usage: export_tar_gz.sh [-h|--help] model_directory...
Export training logs and best checkpoint to tarball

Optional arguments:
  -h, --help              Show this help message and exit

Required arguments:
  model_directory <path>  Path to directory containing model
                          checkpoints
```

This script will select and compress the best checkpoints along with logging information for deployment purposes downstream. An example of executing this script would be:

```shell
bash scripts/export_tar_gz.sh \
    "./models/transformer_vaswani_wmt_en_de_big.wmt16.de-en.1594228573" \
    "./models/bert-base-multilingual-cased.pawsx.ML128.1594737128"
```
