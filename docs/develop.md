### To-do\'s

1.  Code, documentation and outlook

    1.  **TODO** set up data downloading for all wmt sets
        with SacreBLEU, set up all data for given git submodules such as
        SGCP and SOW-REAP

    2.  **TODO** make table with all metrics, or use several
        language pairs to test this, pre-process data as per pre-trained
        model

    3.  **TODO** handle virtual environment in remote system
        better

    4.  **TODO** build reproducible pipeline to construct
        quick paraphrases for custom data, and then to evalute results
        to find most vulnerable syntax forms

    5.  consider building readme and project using python -m framework

    6.  add relevant gitignores

    7.  add documentation/acknowledgments to datasets and code, refactor
        major code used in SCPN to make it cleaner and better

    8.  add citations in readme as per general standard

2.  Paraphrase generation

    1.  **TODO** use viable frameworks to construct
        paraphrase construction pipeline for various syntax forms on WMT

    2.  **TODO** test on WMT 17 dev/test first, then run
        paraphrases on all WMT datasets

    3.  Viable frameworks

        1.  SOW-REAP \[torch, python3, average-documented\] -\> generate
            paraphrases without exemplar sentence form, worth trying out

        2.  SGCP \[torch, python3, well-documented\] -\> generate
            paraphrases given exemplar sentence form, limitation is that
            exemplar sentence is a hard dependency

            1.  viable-idea: remove exemplar sentence and replace with
                syntax form

            2.  future-idea: end-to-end paraphrase generation with
                adversarial goal, but unrealistic given time-frame and
                support

    4.  Legacy frameworks

        1.  SCPN \[torch, python2.7, poorly documented\] -\> buggy, but
            some examples work

        2.  Pair-it \[tensorflow, python3, poorly documented\] -\> has
            potential to work but requires major refactoring

3.  SOTA NMT models

    1.  download SOTA models from fairseq, start testing paraphrased
        samples on it and manually check out differences in results, see
        if this idea makes sense on a large scale

    2.  look for models that worked on WMT en-de datasets and work from
        there

4.  Semantic similarity metrics

    1.  think of useful semantic similarity metrics to make comparisons

    2.  perhaps modified BLEU, METEOR, CCG semantics lambda calculus

    3.  or NN technique using sentence BERT and other encoders -\> more
        quantitative and continuous, can apply Michel et al. 2019
        techniques for robustness comparisons

5.  Downstream data augmentation

    1.  Data augmentation with source paraphrase and same target without
        paraphrase -\> would this be beneficial, would it regularize or
        would it make convergence more difficult

### Completed

1.  **DONE** set up WMT 17 dev/test data and basic repo

2.  **DONE** convert all processes to makefile for ease

3.  **DONE** add pipeline to download WMT 17 training data
