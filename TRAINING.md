## Training non-SOTA NMT model on WMT16 de-en

1. Preprocess WMT16 with BPE codes into an appropriate format:

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
    Usage: train_continue_wmt16_de_en.sh [-h|--help] save_dir
    Continue training fairseq model on WMT16 de-en data

    Optional arguments:
      -h, --help       Show this help message and exit

    Required arguments:
      save_dir <path>  Path to directory containing checkpoints
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

## Fine-tuning XL transformer language model on PAWS-X

Fine-tune a large XL transformer language model on the `PAWS-X` paraphrase detection task using `train_evaluate_pawsx.sh`:

```
Usage: train_evaluate_pawsx.sh [-h|--help] [model]
Train (fine-tune) and evaluate large transformer language
models on the PAWS-X paraphrase detection task

Optional arguments:
  -h, --help    Show this help message and exit
  model <arch>  Architecture for use in model, defaults
                to "xlm-roberta-large"
```

Our script allows for fine-tuning using the three following language models: `bert-base-multilingual-cased`, `xlm-roberta-base` and `xlm-roberta-large`. In order to use our default settings, simply execute:

```shell
bash scripts/train_evaluate_pawsx.sh
```

This script will automatically evaluate the model against the `dev` set during training and the `test` set after training. Therefore a separate evaluation step is not necessary.
