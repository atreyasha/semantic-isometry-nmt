### To-do\'s

1.  1\. Investigate semantics transfer during translation

    1.  **TODO** investigate PAWS-X data origins and ensure
        this is not present in the NMT training data -\> find new NMT
        model that fits this criterion

    2.  do a bleu score comparison of translations and gold sentence
        paraphrases for surface level analysis -\> output data as tsv
        instead of json -\> or perhaps provide option for both -\> add
        this as a pipeline to investigate -\> perhaps use some
        combinations of scores where possible

    3.  utilize fairseq model(s) for translation from English to German
        and then use test translations, provide options for various
        models and run these through fine-tuned paraphrase detection
        model later on -\> run on both gold and translated to check for
        systematic errors as well

    4.  use XLM-R model for predictions -\> predict it on the test set
        in german, and the test set translated and check the differences
        and where they coincide and where not -\> will tell you where
        the model is bad and where not to trust it -\> and where to
        trust it

    5.  check if human evaluation would be necessary at any point

    6.  expect very good results on translation and think of how to
        analyze and interpret/explain them

2.  2\. Paraphrase data selection and analysis workflow

    1.  Fine-tuning large X-models

        1.  **TODO** fine-tune models with English and ensure
            no or little machine translated data is present in training
            set

        2.  refactor and improve xtreme code with simpler repository -\>
            modify logging of models, combination of languages, correct
            naming of training parameters and files, make training
            process exhaustive and thorough, add better metrics for
            monitoring performance including ROC-AUC etc.

        3.  train more model combinations, change evaluation metrics on
            test set to only be at the end, continue training for
            existing models or re-evaluate them on the test dataset,
            make new model which learns from all data instead of just
            one language, remove constant re-writing of caches, add more
            information into each log file to make it unique

        4.  change pre-processing from two concatenated sentences to
            permutation invariant type -\> check if it improves

        5.  use both s3it and local cluster for simultaneous model
            training

        6.  data augmentation with easy examples -\> perhaps add this in
            to training scheme

        7.  look into Elektra, SentenceBERT, bert~score~, models
            developed for GLUE tasks such as paraphrase detection tasks

        8.  not good enough argument to show that siamese network is
            necessary compared to ordered concatenation

    2.  compare performance with or without other languages to see if
        this differs

    3.  compare performance with other pre-trained paraphrase detector
        -\> such as fine-tuned multilingual BERT from PAWS-X paper

    4.  add failsafe to output maximum score in case same inputs

    5.  better to work with human-curated data than back-translated ones
        due to many errors -\> advantage in PAWS and PAWS-X

    6.  possible to get students to do tests for us to check for
        semantic transfer

    7.  keep documentation of work -\> such as SGCP & SOW-REAP
        performance (with examples), LASER performance

3.  3\. Code and documentation

    1.  **TODO** redo repository with only necessary
        code-chunks and fill up readme, recreate environment with
        python3.7 in cluster -\> re-run simple tests first

    2.  add a deployed service on GitHub to build and check sanity

    3.  add a pylinter for formatting as pre-commit hook -\> think of
        standards to abide by -\> auto-PEP8

    4.  add documentation with typing to utils code later on

    5.  ultimately release best fine-tuned model for use in other
        scenarios -\> if possible add reproducability concept with
        setting seeds

    6.  provide readme to hdf5 files with different index meanings

    7.  consider building readme and project using python -m framework

    8.  think of how to handle LASER vs. larger model workflows in one
        repo

    9.  log out random seeds for full reproducability

    10. add citations in readme as per general standard

    11. add relevant gitignores

    12. add documentation/acknowledgments to datasets and code, and how
        to handle submodules

    13. re-review dependencies and remove unnecessary ones upon next
        check

### Completed

1.  **DONE** bug in XLM-R as it does not appear to learn -\>
    look through code

2.  **DONE** multilingual BERT with de only -\> bug in how
    test scripts are saved leads to wrong results

3.  **DONE** maybe consider using German BERT for doing this
    task explicitly for German, for our end task -\> German BERT and
    RoBERTa for English to focus on exact task -\> perhaps just use
    xtreme repo and keep only paws-x task -\> clean up code and workflow
    for it -\> error might be arising due to gradient clipping for very
    large model

4.  **DONE** look into ParaBank2 and universal
    decompositional semantics -\> not great paraphrases, no human
    curation

5.  **DONE** look into Duolingo dataset for paraphrases -\>
    no German target side

6.  **DONE** add symbols for defaults in metavar default
    formatter, maybe add some other formatting tricks such as indents
    for defaults

7.  **DONE** try installing java locally instead of root, if
    stanford parser is indeed necessary

8.  **DONE** paraphrasing with SGCP -\> very bad results on
    both original test and WMT data -\> very sensitive to exemplar

9.  **DONE** embed and cluser using universal sentence
    encoder (eg. BERT or LASER) -\> use separate clusters for exemplar
    utility, make diverse collection and evaluate using metric or other
    NN

10. **DONE** find other sentence with maximum similarity and
    use that as exemplar, useparaphrase of best as exemplar, use
    pos-tags of sentence

11. **DONE** convert wmt datasets with derived exemplars into
    format pipe-able into SGCP -\> needed before paraphrasing

12. **DONE** add workflow to download laser models with
    python -m laserembeddings download-models

13. **DONE** set up WMT 17 dev/test data and basic repo

14. **DONE** convert all processes to makefile for ease

15. **DONE** set up data downloading for all wmt sets with
    SacreBLEU

### Downstream work

1.  LASER embeddings + dense layers

    1.  **TODO** develop small but efficient pipeline to run
        LASER + dense layer to get basic performance and show
        ineffectiveness

    2.  **TODO** add function for normalization within class
        itself -\> or think of how to make normalization scheme portable
        and not have it separate outside of model

    3.  figure out nicer and more automated means of logging experiments
        -\> tensorboard + csv logging -\> consider using wandb, mlflow
        or comet-ml

    4.  extend to all combinations of languages, keep this as baseline
        comparison with larger models

2.  Semantic similarity metrics

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
