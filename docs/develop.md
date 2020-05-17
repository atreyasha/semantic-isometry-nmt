Qns to discuss
==============

BERT, RoBERTa for detecting paraphrases

Maximize similarity metric, use paraphrase of maximum as exemplar, use
pos-tags of sentence, embed and cluser universal sentence encoder

QQPos is likely to be a better model, check quality of paraphrases, BERT
score for quality of paraphrases

Multireference BLEU score, use multiple paraphrases and check for best
BLEU score -\> maybe talk to Rico about this

Data augmentation -\> find best paraphrases using bleu and generated
exemplars, find best translated paraphrases using bleu as well, use best
results for augmentation, consider multi-reference bleu

Use similarity metric on paraphrase and translation, check this metric

Perhaps ignore SOW-REAP for now and do it only in case SGCP does not
work

Make some basic progress till weekly meetings to show Mathias

### To-do\'s

1.  Current

    1.  **TODO** set up data downloading for all wmt sets
        with SacreBLEU

    2.  **TODO** build reproducible pipeline to construct
        quick paraphrases for custom data, and then to evalute results
        to find most vulnerable syntax forms

    3.  **TODO** use viable frameworks to construct
        paraphrase construction pipeline for various syntax forms on WMT

    4.  **TODO** test on WMT 17 dev/test first, then run
        paraphrases on all WMT datasets

2.  Code and documentation

    1.  **TODO** handle virtual environment in remote system
        better

    2.  consider building readme and project using python -m framework

    3.  add relevant gitignores

    4.  add documentation/acknowledgments to datasets and code, refactor
        major code used in SCPN to make it cleaner and better

    5.  add citations in readme as per general standard

3.  Paraphrase generation

    1.  Viable frameworks

        1.  SGCP \[torch, python3, well-documented\] -\> generate
            paraphrases given exemplar sentence form, limitation is that
            exemplar sentence is a hard dependency

            1.  viable-idea: remove exemplar sentence and replace with
                syntax form

            2.  future-idea: end-to-end paraphrase generation with
                adversarial goal, but unrealistic given time-frame and
                support

    2.  Legacy frameworks

        1.  SOW-REAP \[torch, python3, average-documented\] -\> generate
            paraphrases without exemplar sentence form, worth trying out

        2.  SCPN \[torch, python2.7, poorly documented\] -\> buggy, but
            some examples work

        3.  Pair-it \[tensorflow, python3, poorly documented\] -\> has
            potential to work but requires major refactoring

4.  SOTA NMT models

    1.  download SOTA models from fairseq, start testing paraphrased
        samples on it and manually check out differences in results, see
        if this idea makes sense on a large scale

    2.  look for models that worked on WMT en-de datasets and work from
        there

5.  Semantic similarity metrics

    1.  make table with all metrics, or use several language pairs to
        test this, pre-process data as per pre-trained model

    2.  think of useful semantic similarity metrics to make comparisons

    3.  perhaps modified BLEU, METEOR, CCG semantics lambda calculus

    4.  or NN technique using sentence BERT and other encoders -\> more
        quantitative and continuous, can apply Michel et al. 2019
        techniques for robustness comparisons

6.  Downstream data augmentation

    1.  Data augmentation with source paraphrase and same target without
        paraphrase -\> would this be beneficial, would it regularize or
        would it make convergence more difficult

### Completed

1.  **DONE** set up WMT 17 dev/test data and basic repo

2.  **DONE** convert all processes to makefile for ease

3.  **DONE** add pipeline to download WMT 17 training data
