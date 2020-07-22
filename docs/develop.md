### Development

1.  Visualization

    1.  **TODO** think of plotting schemes that could be used
        on various results of analysis such as paraphrase detection
        results from all three models -\> get creative with these ideas
        -\> can already do this before newer translation model is
        present

    2.  **TODO** add various sub-routines with different
        visualization shell scripts corresponding to different arguments
        of python script -\> such as defining model paths to plot model
        evolutions, etc. -\> make this more dynamic and practical where
        possible

    3.  **TODO** re-run visualizations with improved NMT
        model, but prepare pipelines based on current one

    4.  use memory efficient pipelines and newer visualization
        techniques to assist in understanding

    5.  think of effective ways of converting tensorflow event logs to
        csv\'s for nicer plotting -\> look into event log combination
        workflow

    6.  update R dependencies in readme once all visualizations are
        finalized

    7.  ****extra:**** replace mean/sd annotations in plots with vector
        for mean and covariance matrix for sd

2.  Translation

    1.  **TODO** continue model training and save last 10
        checkpoints -\> consider averaging checkpoints later on to
        improve model performance

    2.  **TODO** re-export and upload new model if
        performance improves -\> update readme and relevant sections

    3.  strong model being WMT19 single and ensemble with back
        translation (which adds robustness), while weak model being
        transformer trained on WMT16 without back translation -\>
        compare general performances and metrics

    4.  consider also looking into extra references repo
        \"evaluation-of-nmt-bt\"

    5.  ****extra:**** train additional large model on wmt19
        non-backtranslated data and similar transformer arch as fair
        paper -\> to get slightly better performance for comparison -\>
        this can also be done later

3.  Clean-code and documentation

    1.  create modular scripts with instructions in readme:

        1.  **TODO** visualize shallow metrics

        2.  **TODO** visualize fine-tuned LM result

        3.  **TODO** visualize correlation of LM and shallow
            metrics

        4.  **TODO** visualize model training evolutions

        5.  **DONE** evaluate using fine-tuned language model

        6.  **DONE** train translation model

        7.  **DONE** fine tune paraphrase detector

        8.  **DONE** translate sentences

        9.  **DONE** evaluate bleu & chrf

    2.  segment readme into training, translation and others categories
        with relevant usages

    3.  add information on how long training took and what DL
        settings/hardware were used

    4.  replace relevant bash commands with sbatch in slurm-s3it branch
        after repository is completed

    5.  update initial page of readme with overview/abstract of work
        including shallow metrics

    6.  update TOC\'s in all readmes to reflect latest changes

    7.  add citations in readme as per general standard

    8.  add final paper/presentation into repo with link in readme

4.  Evaluation

    1.  **TODO** perhaps reliably use paraphrase detection
        only in cases where initial German paraphrase is positively
        detected, to ensure some consistency for evaluation

    2.  **TODO** check for possibly interesting correlations
        between XLM-R prediction and chrF/BLEU scores -\> this could be
        of interest in making additional statements to Michel et al.
        2019\'s statements regarding chrF scores

    3.  consider changing bleu to sacrebleu in json (read more about
        differences) and figure out why stating this might be important

    4.  compute statistical tests for ascertaining significance of
        relationships

    5.  in rare cases, can do manual analysis and include this inside
        report

    6.  report evaluation of fine-tuning paraphrase detector and weaker
        translation model

    7.  early conclusions/hypothese: hand-crafted adversarial paraphrase
        robustness is handled well in SOTA models due to backtranslation
        reguralization, main vulnerability will be targetted adversarial
        samples

5.  Paraphrase detection

    1.  consider roc and other evaluation metrics for pawsx model -\> in
        case these might be of more help

    2.  fine-tune models with English and ensure no or little machine
        translated data is present in training set

    3.  better to work with human-curated data than back-translated ones
        due to many errors -\> advantage in PAWS and PAWS-X English
        data + WMT19 AR paraphrases

    4.  ****extra:**** fix and refine paws-x pipeline later on with
        patience, typing, better documentation, clean-code and possibly
        continuation of training, add roc auc on pawsx test data

6.  Paper

    1.  use two-column format for final paper, to prepare for paper
        writing

    2.  think more about whether to include or exclude adversarial term
        since this might be a grey area -\> qualify various means of
        being adversarial ie. targetted through model or perhaps just an
        intention

    3.  include semantic transferance equation in paper to introduce
        some formalisms -\> show mathematical properties of isometric
        functions/spaces and how this should hold for semantic vector
        spaces

    4.  describe processes that worked and did not work -\> talk about
        all the hurdles and show some bad examples when they occurred
        -\> summarized below in logs

    5.  list hypotheses and how some were refuted by results

### Completed

1.  **DONE** reduce computational overhead by caching source
    computations for paraphrase detection evaluation

2.  **DONE** make shell script which automatically filters
    and compresses to tar gz

3.  **DONE** Increase sequence lengths during training to
    accomodate for longer paraphrases, compute average seq lengths of
    wmt inputs to estimate model seq lengths for training paraphrase
    detector, work on keeping code simple

4.  **DONE** consider making separate branch with sbatch
    parameters all present in files as necessary for reproducibility

5.  **DONE** bug in XLM-R as it does not appear to learn -\>
    look through code

6.  **DONE** multilingual BERT with de only -\> bug in how
    test scripts are saved leads to wrong results

7.  **DONE** maybe consider using German BERT for doing this
    task explicitly for German, for our end task -\> German BERT and
    RoBERTa for English to focus on exact task -\> perhaps just use
    xtreme repo and keep only paws-x task -\> clean up code and workflow
    for it -\> error might be arising due to gradient clipping for very
    large model

8.  **DONE** look into ParaBank2 and universal
    decompositional semantics -\> not great paraphrases, no human
    curation

9.  **DONE** look into Duolingo dataset for paraphrases -\>
    no German target side

10. **DONE** add symbols for defaults in metavar default
    formatter, maybe add some other formatting tricks such as indents
    for defaults

11. **DONE** try installing java locally instead of root, if
    stanford parser is indeed necessary

12. **DONE** paraphrasing with SGCP -\> very bad results on
    both original test and WMT data -\> very sensitive to exemplar

13. **DONE** embed and cluser using universal sentence
    encoder (eg. BERT or LASER) -\> use separate clusters for exemplar
    utility, make diverse collection and evaluate using metric or other
    NN

14. **DONE** find other sentence with maximum similarity and
    use that as exemplar, useparaphrase of best as exemplar, use
    pos-tags of sentence

15. **DONE** convert wmt datasets with derived exemplars into
    format pipe-able into SGCP -\> needed before paraphrasing

16. **DONE** add workflow to download laser models with
    python -m laserembeddings download-models

17. **DONE** set up WMT 17 dev/test data and basic repo

18. **DONE** convert all processes to makefile for ease

19. **DONE** set up data downloading for all wmt sets with
    SacreBLEU

### Brainstorming and logs

1.  LASER embeddings + dense layers

    1.  not very useful by itself, needs a larger token-touching model

    2.  models do not show generalization, ie. training loss decreases
        but development loss rises

    3.  need to access larger token-based models to leverage full power
        of NLP model

2.  Semantic similarity metrics

    1.  multireference BLEU score, use multiple paraphrases and check
        for best BLEU score

    2.  perhaps modified BLEU, METEOR, CCG semantics lambda calculus

    3.  perhaps some combination of edit distance with wordnet metrics

    4.  or NN technique using sentence BERT and other encoders -\> more
        quantitative and continuous, can apply Michel et al. 2019
        techniques for robustness comparisons

    5.  semantic parsing to graph, role labelling, wordnet concepts
        connecting, framenet, frame semantic parsing, brown clusters,
        AMR parsing, IWCS workshop for discussions

3.  Paraphrase generation

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

4.  Data augmenttion

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
