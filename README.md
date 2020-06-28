## NMT model robustness to syntax-level adversarial paraphrases

### Overview

This repository investigates the performance of state-of-the-art Neural Machine Translation (NMT) models in effectively and consistently transfering the semantics of syntax-level adversarial paraphrases. Through this, we aim to investigate the robustness of said models to such paraphrases. 

### Dependencies

1. If `poetry` is installed on your system, you can install dependencies and create a virtual environment automatically via the following command:

    ```shell
    $ poetry install
    ```

2. Alternatively, install dependencies via `pip`:

    ```shell
    $ pip install -r requirements.txt
    ```

### Repository Initialization

In order to download and deploy `PAWS-X` data from [Google Research](https://github.com/google-research-datasets/paws/tree/master/pawsx), run the following command:

```shell
$ make PAWS-X
```

### Development

As we are still under development, parts of this repository are likely to change significantly :snail:

Check our development [log](./docs/develop.md) for information on current developments.
