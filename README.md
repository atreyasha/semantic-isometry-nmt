## NMT model robustness to hand-crafted adversarial paraphrases

### Overview :book:

This repository investigates the performance of state-of-the-art Neural Machine Translation (NMT) models in effectively and consistently transfering the semantics of hand-crafted adversarial paraphrases. Through this, we aim to interpret the robustness of said models to such adversarial paraphrases.

### Dependencies :neckbeard:

This repository's code was tested with Python versions `3.7+`. We recommend the two following methods for syncing python dependencies.

1. If poetry is installed on your system, you can create a virtual environment and install dependencies with just one command:

    ```shell
    poetry install
    ```

2. Create a virtual environment (recommended) and install dependencies via `pip`:

    ```shell
    pip install -r requirements.txt
    ```

### Repository Initialization :fire:

1. Manually download [preprocessed WMT'16 En-De data](https://drive.google.com/uc?export=download&id=0B_bZck-ksdkpM25jRUN2X2UxMm8) provided by Google and place the tarball in the `data` directory.

2. To download/prepare `PAWS-X` and `WMT19` original + additional references + paraphrased test data, as well as prepare the previously downloaded `WMT16` data, run the command below:

    ```shell
    bash scripts/prepare_data.sh
    ```

3. Optionally, if you want to further develop this repository; you can keep python dependencies and the development log updated by initializing a pre-commit hook:

    ```shell
    bash scripts/setup_pre_commit_hook.sh
    ```

### Development :snail:

As we are still under development, several parts of this repository might change significantly.

Check our development [log](./docs/develop.md) for information on current developments.

### Citations

```
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
