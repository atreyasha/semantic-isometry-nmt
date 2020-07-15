## NMT model robustness to hand-crafted adversarial paraphrases

### Overview :book:

This repository investigates the performance of state-of-the-art Neural Machine Translation (NMT) models in effectively and consistently transfering the semantics of hand-crafted adversarial paraphrases. Through this, we aim to interpret the robustness of said models to such adversarial paraphrases.

In this repository, we provide a mirror `slurm-s3it` branch for executing scripts on the `s3it` server with `slurm`. To use this branch, simply execute `git checkout slurm-s3it`. 

### Dependencies :neckbeard:

This repository's code was tested with Python versions `3.7+`. To install relevant dependencies, we recommend creating a virtual environment and installing packages via `pip`:

```shell
pip install -r requirements.txt
```

### Repository Initialization :fire:

1. Initialize the `xtreme-pawsx` git submodule by running the following command:

  ```shell
  bash scripts/setup_xtreme_pawsx.sh
  ```

2. Manually download [preprocessed WMT'16 En-De data](https://drive.google.com/uc?export=download&id=0B_bZck-ksdkpM25jRUN2X2UxMm8) provided by Google and place the tarball in the `data` directory.

3. To download/prepare `PAWS-X` and `WMT19` original + additional references + paraphrased test data, as well as prepare the previously downloaded `WMT16` data, run the command below:

    ```shell
    bash scripts/prepare_data.sh
    ```

4. Optionally, if you want to further develop this repository; you can keep python dependencies, the development log and the `slurm-s3it` branch synchronized by initializing pre-commit and pre-push `git` hooks:

    ```shell
    bash scripts/setup_git_hooks.sh
    ```

### Citations :sweat_drops:

Below are the key citations that were used in this repository.

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

Check our development [log](./docs/develop.md) for information on current developments.
