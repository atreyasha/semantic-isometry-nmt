### To-do\'s

1.  Paraphrase data selection and analysis workflow

    1.  **TODO** use paws-x for learning good paraphrase
        distinction -\> use simple model or other consider more complex
        multilingual models

    2.  **TODO** normalize all input properly and keep
        normalization scheme saved

    3.  **TODO** develop SVC with cosine similarity and
        vector difference to find some optimum thresholds for paraphrase
        vs. not -\> do quick run with scikit-learn and test on German
        paraphrases -\> look into using generators to make this more
        memory efficient

    4.  **TODO** if SVC with various kernels does not perform
        in the high 90s, can consider using a permutation invariant
        neural network for this purpose

    5.  **TODO** use dataset generator to keep everything
        memory efficient -\> save files in hd5 format with compression

    6.  **TODO** check whether all features are necessary or
        whether some abstraction is sufficient

2.  Code and documentation

    1.  **TODO** rebuild repository workflow with new
        structure -\> push to github and make things clean again

    2.  **TODO** add a pylinter for formatting as pre-commit
        hook -\> think of standards to abide by -\> auto-PEP8

    3.  **TODO** clean up reading articles/papers and make
        things neater overall

    4.  consider building readme and project using python -m framework

    5.  log out random seeds for full reproducability

    6.  add citations in readme as per general standard

    7.  add relevant gitignores

    8.  add documentation/acknowledgments to datasets and code, and how
        to handle submodules

    9.  add failsafe to ensure submodules are all loaded -\> with some
        phony checkouts

    10. clarify exact meaning of wmt dev set vs test set

    11. re-review dependencies and remove unnecessary ones upon next
        check

    12. better to work with human-curated data than back-translated ones
        due to many errors -\> consider PAWS and PAWS-X

    13. maybe use pre-trained paraphrase detector here if that helps

    14. important to keep things within LASER for multi-lingual features

    15. could not find other technique which used PAWS-X in combination
        with LASER

    16. look into nli adversarial datasets -\> Nevin and Aatlantise

3.  Fairseq NMT models

    1.  download SOTA models from fairseq, start testing paraphrased
        samples on it and manually check out differences in results, see
        if this idea makes sense on a large scale

    2.  look for models that worked on WMT en-de datasets and work from
        there

    3.  pre-process data as per pre-trained model

### Completed

1.  **DONE** look into ParaBank2 and universal
    decompositional semantics -\> not great paraphrases, no human
    curation

2.  **DONE** look into Duolingo dataset for paraphrases -\>
    no German target side

3.  **DONE** add symbols for defaults in metavar default
    formatter, maybe add some other formatting tricks such as indents
    for defaults

4.  **DONE** try installing java locally instead of root, if
    stanford parser is indeed necessary

5.  **DONE** paraphrasing with SGCP -\> very bad results on
    both original test and WMT data -\> very sensitive to exemplar

6.  **DONE** embed and cluser using universal sentence
    encoder (eg. BERT or LASER) -\> use separate clusters for exemplar
    utility, make diverse collection and evaluate using metric or other
    NN

7.  **DONE** find other sentence with maximum similarity and
    use that as exemplar, useparaphrase of best as exemplar, use
    pos-tags of sentence

8.  **DONE** convert wmt datasets with derived exemplars into
    format pipe-able into SGCP -\> needed before paraphrasing

9.  **DONE** add workflow to download laser models with
    python -m laserembeddings download-models

10. **DONE** set up WMT 17 dev/test data and basic repo

11. **DONE** convert all processes to makefile for ease

12. **DONE** set up data downloading for all wmt sets with
    SacreBLEU

### Downstream work

1.  Semantic similarity metrics

    1.  make table with all metrics and various datasets

    2.  possibly use several language pairs to test this

    3.  multireference BLEU score, use multiple paraphrases and check
        for best BLEU score

    4.  perhaps modified BLEU, METEOR, CCG semantics lambda calculus

    5.  perhaps some combination of edit distance with wordnet metrics

    6.  or NN technique using sentence BERT and other encoders -\> more
        quantitative and continuous, can apply Michel et al. 2019
        techniques for robustness comparisons

    7.  semantic parsing to graph, role labelling, wordnet concepts
        connecting, framenet, frame semantic parsing, brown clusters,
        AMR parsing, IWCS workshop for discussions

2.  Paraphrase generation

    1.  Ideas for self-paraphrasing

        1.  consider logical model for paraphrases, active to passive
            syntaxes and other logical frameworks -\> use dependency
            parse on manual examples and check for logical process to
            create meaningful permutations

        2.  permute-paraphrase using syntax-tree chunks and test
            paraphrses using a detect or LASER embeddings for
            agnosticism between source/target

    2.  Viable pre-developed dynamic paraphrase-generation frameworks

        1.  SOW-REAP \[torch, python3, average-documented\] -\> generate
            paraphrases without exemplar sentence form, worth trying out

            1.  refactor/extract out SOW model, shorten pipeline in sow
                to reduce computation and make input simpler

            2.  make quick samples from SOW and hand-select good ones,
                test them manually on fairseq NMT system for en-de to
                probe robustness

            3.  fork sow repo and clean code, remove bugs and make
                better documented with dep tracking and clearer
                instructions

            4.  require nltk word tokenize before main processing

        2.  SGCP \[torch, python3, well-documented\] -\> generate
            paraphrases given exemplar sentence form, limitation is that
            exemplar sentence is a hard dependency, poor performance and
            not very semantically sound paraphrases

            1.  ParaNMT is likely to be better than QQPos since latter
                was trained only on qns

            2.  BERT score, BERT, RoBERTa for detecting paraphrases and
                quality

            3.  hand-written exemplar for meaningful output

            4.  remove exemplar sentence and replace with syntax form

            5.  clustering is done by meaning and not syntax -\> or try
                difference via standard parse -\> or random

            6.  provision of syntax directly instead of exemplar
                sentence

            7.  fix bug in sgcp to write all outs on separate lines and
                to not compute any similarity

            8.  change k means to find best number of clusters

            9.  add various paraphrase generation styles for SGCP such
                as same cluster, other cluster and same as source

            10. require nltk word tokenize before main processing

            11. future-idea: end-to-end paraphrase generation with
                adversarial goal, but unrealistic given time-frame and
                support

    3.  Legacy frameworks

        1.  Pair-it \[tensorflow, python3, poorly documented\] -\> has
            potential to work but requires major refactoring

        2.  SCPN \[torch, python2.7, poorly documented\] -\> buggy, but
            some examples work

3.  Data augmenttion

    1.  either look for paraphrase source and target pair which are
        closest to gold ones and augment data with these -\> is safer to
        train with and can possibly improve overall translation quality

    2.  otherwise, find paraphrase which is close on source side but
        problematic on target side and augment these with gold target
        -\> acts as a regularizing anchor and possibly adds some
        stability

    3.  Zipf\'s law should apply to syntax chunks, bias might still be
        present

    4.  anchor might still be useful, look for similar syntax on the
        target side that can be substituted -\> maybe some kind of
        imitation to make augmented pairs

    5.  consider contributing paraphrases to data augmentation libraries
        from research

    6.  noise is not problematic since there is already noise present in
        normal training data

    7.  meaning preserving + adversarial outcome -\> then useful

    8.  augmentation is important if adversarial attack is successful,
        maybe syntax real-life frequency has effect
