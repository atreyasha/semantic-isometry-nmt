### To-do\'s

1.  Code and documentation

    1.  **TODO** handle virtual environment in remote system
        better -\> maybe with poetry or with venvs -\> either way keep
        it clean and simple

    2.  consider building readme and project using python -m framework

    3.  add documentation/acknowledgments to datasets and code, refactor
        major code used in SCPN to make it cleaner and better

    4.  add citations in readme as per general standard

    5.  add relevant gitignores

2.  Paraphrase generation

    1.  **TODO** convert wmt datasets into format pipe-able
        into SGCP

    2.  **TODO** embed and cluser using universal sentence
        encoder -\> use separate clusters for exemplar utility, make
        diverse collection and evaluate using metric or other NN

    3.  maximize similarity metric on both sides, use paraphrase of
        maximum as exemplar, use pos-tags of sentence

    4.  QQPos is likely to be a better model, check quality of
        paraphrases, BERT score for quality of paraphrases

    5.  BERT, RoBERTa for detecting paraphrases

    6.  Viable frameworks

        1.  SGCP \[torch, python3, well-documented\] -\> generate
            paraphrases given exemplar sentence form, limitation is that
            exemplar sentence is a hard dependency

            1.  viable-idea: remove exemplar sentence and replace with
                syntax form

            2.  future-idea: end-to-end paraphrase generation with
                adversarial goal, but unrealistic given time-frame and
                support

    7.  Legacy frameworks

        1.  SOW-REAP \[torch, python3, average-documented\] -\> generate
            paraphrases without exemplar sentence form, worth trying out

        2.  SCPN \[torch, python2.7, poorly documented\] -\> buggy, but
            some examples work

        3.  Pair-it \[tensorflow, python3, poorly documented\] -\> has
            potential to work but requires major refactoring

3.  SOTA NMT models

    1.  download SOTA models from fairseq, start testing paraphrased
        samples on it and manually check out differences in results, see
        if this idea makes sense on a large scale

    2.  look for models that worked on WMT en-de datasets and work from
        there

4.  Semantic similarity metrics

    1.  multireference BLEU score, use multiple paraphrases and check
        for best BLEU score

    2.  make table with all metrics, or use several language pairs to
        test this, pre-process data as per pre-trained model

    3.  think of useful semantic similarity metrics to make comparisons

    4.  perhaps modified BLEU, METEOR, CCG semantics lambda calculus

    5.  or NN technique using sentence BERT and other encoders -\> more
        quantitative and continuous, can apply Michel et al. 2019
        techniques for robustness comparisons

5.  Downstream data augmentation

    1.  dual approach -\> either look for paraphrase source and target
        pair which are closest to gold ones and augment data with these
        -\> is safer to train with and can possibly improve overall
        translation quality

    2.  otherwise, find paraphrase which is close on source side but
        problematic on target side and augment these with gold target
        -\> acts as a regularizing anchor and possibly adds some
        stability -\> need to check semantics

    3.  this would be future work, but presentation of work depends on
        how this is envisioned

### Completed

1.  **DONE** set up WMT 17 dev/test data and basic repo

2.  **DONE** convert all processes to makefile for ease

3.  **DONE** add pipeline to download WMT 17 training data

4.  **DONE** set up data downloading for all wmt sets with
    SacreBLEU
