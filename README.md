## NMT model robustness to adversarial paraphrases

### Overview :book:

This repository investigates the performance of state-of-the-art Neural Machine Translation (NMT) models in effectively and consistently transfering the semantics of hand-crafted adversarial paraphrases. 

### Dependencies :neckbeard:

Below are two recommended methods of syncing dependencies:

1. If `poetry` is installed on your system, you can create a virtual environment and install dependencies with just one command:

    ```shell
    $ poetry install
    ```

2. Alternatively, create a virtual environment separately (recommended) and install dependencies via `pip`:

    ```shell
    $ pip install -r requirements.txt
    ```

### Repository Initialization :fire:

To download `PAWS-X` and `WMT19` gold+paraphrased test data for this repository, simply run the command below:

```shell
$ make data
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
