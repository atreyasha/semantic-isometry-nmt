## NMT model robustness to adversarial paraphrases

### Overview :book:

This repository investigates the performance of state-of-the-art Neural Machine Translation (NMT) models in effectively and consistently transfering the semantics of adversarial paraphrases. Through this, we aim to investigate the robustness of said models to such paraphrases. 

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

1. To download and deploy `PAWS-X` data from [Google Research](https://github.com/google-research-datasets/paws/tree/master/pawsx), run the following command:

    ```shell
    $ make PAWS-X
    ```

2. If you aim to develop this repository further and want to keep pythonic dependencies and `develop.org` synced, initialize the pre-commit hook:

    ```shell
    $ make pre_commit_hook
    ```

### Development :snail:

As we are still under development, several parts of this repository might change significantly.

Check our development [log](./docs/develop.md) for information on current developments.
