## Table of Contents
-   [Development](#development)
-   [Completed](#completed)
-   [Brainstorming logs](#brainstorming-logs)

### Development

1.  Clean-code and documentation

    1.  **extra:** add version numbers to R package dependencies for
        posterity -\> perhaps with session info

2.  Paraphrase detection

    1.  **extra:** consider roc and other evaluation metrics for pawsx
        model -\> in case these might be of more help

    2.  **extra:** fix and refine paws-x pipeline later on with
        patience, typing, better documentation, clean-code and possibly
        continuation of training, add roc auc on pawsx test data

3.  Translation

    1.  **extra:** train additional large model on wmt19
        non-backtranslated data and similar transformer arch as fair
        paper -\> to get slightly better performance for comparison -\>
        this can also be done later

4.  Evaluation

    1.  **extra:** make formal analysis on lengths of WMT19 inputs vs.
        lengths of paws-x training data

    2.  **extra:** show that training with backtranslation helps for
        robustness to paraphrases -\> through visualizations and perhaps
        some statistical tests

5.  Visualization

    1.  **extra:** consider plotting out agreement statistics sampled
        from uniform distribution within bar chart and if this would be
        of use

    2.  **extra:** check if chord or tree mapping plot could be possible
        to see dependencies and functional mappings

### Completed

1.  create modular scripts with instructions in readme:

    1.  **DONE** visualize model training evolutions

    2.  **DONE** visualize fine-tuned LM result -\> joint
        view

    3.  **DONE** visualize correlation of LM and shallow
        metrics -\> joint view

    4.  **DONE** visualize shallow metrics

    5.  **DONE** train translation model (after better NMT
        performance)

    6.  **DONE** translate sentences (after better NMT
        performance)

    7.  **DONE** evaluate using fine-tuned language model

    8.  **DONE** fine tune paraphrase detector

    9.  **DONE** evaluate bleu & chrf

2.  **DONE** clean up exporting script where user can specify
    which checkpoint should be packaged

3.  **DONE** replace mean/sd annotations in plots with vector
    for mean and covariance matrix for sd

4.  **DONE** reduce computational overhead by caching source
    computations for paraphrase detection evaluation

5.  **DONE** make shell script which automatically filters
    and compresses to tar gz

6.  **DONE** Increase sequence lengths during training to
    accomodate for longer paraphrases, compute average seq lengths of
    wmt inputs to estimate model seq lengths for training paraphrase
    detector, work on keeping code simple

7.  **DONE** consider making separate branch with sbatch
    parameters all present in files as necessary for reproducibility

8.  **DONE** bug in XLM-R as it does not appear to learn -\>
    look through code

9.  **DONE** multilingual BERT with de only -\> bug in how
    test scripts are saved leads to wrong results

10. **DONE** maybe consider using German BERT for doing this
    task explicitly for German, for our end task -\> German BERT and
    RoBERTa for English to focus on exact task -\> perhaps just use
    xtreme repo and keep only paws-x task -\> clean up code and workflow
    for it -\> error might be arising due to gradient clipping for very
    large model

11. **DONE** look into ParaBank2 and universal
    decompositional semantics -\> not great paraphrases, no human
    curation

12. **DONE** look into Duolingo dataset for paraphrases -\>
    no German target side

13. **DONE** add symbols for defaults in metavar default
    formatter, maybe add some other formatting tricks such as indents
    for defaults

14. **DONE** try installing java locally instead of root, if
    stanford parser is indeed necessary

15. **DONE** paraphrasing with SGCP -\> very bad results on
    both original test and WMT data -\> very sensitive to exemplar

16. **DONE** embed and cluser using universal sentence
    encoder (eg. BERT or LASER) -\> use separate clusters for exemplar
    utility, make diverse collection and evaluate using metric or other
    NN

17. **DONE** find other sentence with maximum similarity and
    use that as exemplar, useparaphrase of best as exemplar, use
    pos-tags of sentence

18. **DONE** convert wmt datasets with derived exemplars into
    format pipe-able into SGCP -\> needed before paraphrasing

19. **DONE** add workflow to download laser models with
    python -m laserembeddings download-models

20. **DONE** set up WMT 17 dev/test data and basic repo

21. **DONE** convert all processes to makefile for ease

22. **DONE** set up data downloading for all wmt sets with
    SacreBLEU

### Brainstorming logs

1.  NMT training on S3IT GPUs

    1.  V100-16GB safest option for fp16 fast training, tested with
        3584:16 and now testing out 7168:8

    2.  V100-32GB works great but many times slurms allocates it when it
        has \~100s MB left

    3.  K80 does not permit fp16 for faster training, goes into OOM when
        using with max-tokens 7168 and update-freq 8 -\> although can be
        used for PAWS-X

2.  LASER embeddings + dense layers

    1.  not very useful by itself, needs a larger token-touching model

    2.  models do not show generalization, ie. training loss decreases
        but development loss rises

    3.  need to access larger token-based models to leverage full power
        of NLP model

3.  Semantic similarity metrics

    1.  multireference BLEU score, use multiple paraphrases and check
        for best BLEU score

    2.  perhaps modified BLEU, METEOR, CCG semantics lambda calculus

    3.  perhaps some combination of edit distance with wordnet metrics

    4.  or NN technique using sentence BERT and other encoders -\> more
        quantitative and continuous, can apply Michel et al. 2019
        techniques for robustness comparisons

    5.  semantic parsing to graph, role labelling, wordnet concepts
        connecting, framenet, frame semantic parsing, brown clusters,
        AMR parsing, IWCS workshop for discussions

4.  Paraphrase generation

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
            -\> still poor results and only SOW model appears to be
            robust

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

5.  Data augmentation

    1.  look into nli adversarial datasets -\> Nevin and Aatlantise

    2.  either look for paraphrase source and target pair which are
        closest to gold ones and augment data with these -\> is safer to
        train with and can possibly improve overall translation quality

    3.  otherwise, find paraphrase which is close on source side but
        problematic on target side and augment these with gold target
        -\> acts as a regularizing anchor and possibly adds some
        stability

    4.  Zipf\'s law should apply to syntax chunks, bias might still be
        present

    5.  anchor might still be useful, look for similar syntax on the
        target side that can be substituted -\> maybe some kind of
        imitation to make augmented pairs

    6.  consider contributing paraphrases to data augmentation libraries
        from research

    7.  noise is not problematic since there is already noise present in
        normal training data

    8.  meaning preserving + adversarial outcome -\> then useful

    9.  augmentation is important if adversarial attack is successful,
        maybe syntax real-life frequency has effect
