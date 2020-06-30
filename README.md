## NMT model robustness to adversarial paraphrases

### Overview :book:

This repository investigates the performance of state-of-the-art Neural Machine Translation (NMT) models in effectively and consistently transfering the semantics of hand-crafted adversarial paraphrases. 

### Dependencies :neckbeard:

Below are two recommended methods of syncing dependencies:

1. If `poetry` is installed on your system, you can install dependencies and create a virtual environment automatically via the following command:

    ```shell
    $ poetry install
    ```

2. Alternatively, create a virtual environment (recommended) and install dependencies via `pip`:

    ```shell
    $ pip install -r requirements.txt
    ```

### Repository Initialization :fire:

1. To download and deploy `WMT19` test [data](http://www.statmt.org/wmt19/translation-task.html) for the `de-en` translation direction, run the following command:

  ```shell
  $ make wmt19
  ```

2. To download and deploy paraphrased [references](https://github.com/google/wmt19-paraphrased-references) for the `WMT19` test data `de-en` translation direction, run the following command:

  ```shell
  $ make wmt19_paraphrased
  ```

3. To download and deploy `PAWS-X` data from [Google Research](https://github.com/google-research-datasets/paws/tree/master/pawsx), run the following command:

  ```shell
  $ make paws_x
  ```

### Development :snail:

As we are still under development, several parts of this repository might change significantly.

Check our development [log](./docs/develop.md) for information on current developments.


### Citations

```
@InProceedings{pawsx2019emnlp,
  title = {{PAWS-X: A Cross-lingual Adversarial Dataset for Paraphrase Identification}},
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
