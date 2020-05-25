### To-do\'s

1.  Paraphrase generation

    1.  **TODO** embed and cluser using universal sentence
        encoder (eg. BERT or LASER) -\> use separate clusters for
        exemplar utility, make diverse collection and evaluate using
        metric or other NN

    2.  **TODO** find other sentence with maximum similarity
        and use that as exemplar, use paraphrase of best as exemplar,
        use pos-tags of sentence

    3.  **TODO** convert wmt datasets with derived exemplars
        into format pipe-able into SGCP -\> needed before paraphrasing

    4.  **TODO** perhaps do paraphrasing also for WMT
        training data in order to get new datasets that could be used
        for future augmentation

    5.  try constructing exemplar sentences by hand to check if it works
        -\> check if it works

    6.  QQPos is likely to be a better model

    7.  BERT score, BERT, RoBERTa for detecting paraphrases and quality

    8.  look into new libraries provided by Mathias -\> how could this
        possibly help our research -\> only seq2sick is provided

    9.  clustering is done by meaning and not syntax -\> or try
        difference via standard parse -\> or random

    10. provision of syntax directly instead of exemplar sentence

    11. Viable frameworks

        1.  SGCP \[torch, python3, well-documented\] -\> generate
            paraphrases given exemplar sentence form, limitation is that
            exemplar sentence is a hard dependency

            1.  viable-idea: remove exemplar sentence and replace with
                syntax form

            2.  future-idea: end-to-end paraphrase generation with
                adversarial goal, but unrealistic given time-frame and
                support

    12. Legacy frameworks

        1.  SOW-REAP \[torch, python3, average-documented\] -\> generate
            paraphrases without exemplar sentence form, worth trying out

        2.  SCPN \[torch, python2.7, poorly documented\] -\> buggy, but
            some examples work

        3.  Pair-it \[tensorflow, python3, poorly documented\] -\> has
            potential to work but requires major refactoring

2.  Code and documentation

    1.  **TODO** need to add build workflow for SGCP and also
        symlinking relevant data directly there -\> possibly consider
        git-submodules -\> need to add another workflow to ensure it is
        initialized properly

    2.  **TODO** clarify exact meaning of wmt dev set vs test
        set

    3.  **TODO** handle virtual environment in remote system
        better -\> maybe with poetry or with venvs -\> either way keep
        it clean and simple

    4.  **TODO** add wmt workflow to download training data
        as well

    5.  consider building readme and project using python -m framework

    6.  add documentation/acknowledgments to datasets and code, refactor
        major code used in SCPN to make it cleaner and better

    7.  add citations in readme as per general standard

    8.  add relevant gitignores

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

    6.  Semantic parsing to graph, wordnet concepts connecting,
        framenet, frame semantic parsing, brown clusters, AMR parsing,
        IWCS workshop for discussions

5.  Downstream data augmenttion

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

    4.  Zipf\'s law should apply to syntax chunks, bias might still be
        present

    5.  anchor might still be useful, look for similar syntax on the
        target side that can be substituted -\> maybe some kind of
        imitation to make augmented pairs

    6.  consider contributing paraphrases to data augmentation libraries
        from research

    7.  augmentation might still be useful in any case, even if the
        anchor is different

    8.  noise is not problematic since there is already noise present in
        normal training data

    9.  meaning preserving + adversarial outcome -\> then useful

    10. augmentation is important if adversarial attack is successful,
        maybe syntax real-life frequency has effect

### Completed

1.  **DONE** set up WMT 17 dev/test data and basic repo

2.  **DONE** convert all processes to makefile for ease

3.  **DONE** add pipeline to download WMT 17 training data

4.  **DONE** set up data downloading for all wmt sets with
    SacreBLEU
