### Development

-   figure out preprocessing steps with submodules etc -\> test basic
    training to see if it works -\> then modify other stuff where
    required
-   remove xlm model implementations where possible -\> use only bert
    and xlm-r
-   use fp16 where possible, fix up command line arguments to make more
    sense

1.  Clean-code and documentation

    1.  **TODO** improve training regime with more sensible
        logging styles -\> do this later after main clean-up

    2.  **TODO** filter out dependencies to ones that are
        relevant in code -\> add those to poetry

    3.  **TODO** clean up readme and all afterwards -\> make
        scripts/side repos pretty where possible -\> change xtreme-pawsx
        readmes/descriptions to make it all simpler

    4.  **TODO** figure out effecient handling of submodule
        and related processes -\> add extra script to sync submodule and
        symlink executables to relevant locations, add extra script for
        preprocessing paws-x data in appropriate manner -\> figure out
        how to tie this whole thing together

    5.  create discrete scripts -\> train translation model, fine tune
        paraphrase detector, translate sentences, evaluate (bleu, chrf,
        fine-tuned model), visualize data

    6.  add instructions for syncing xtreme forked submodule and how the
        whole process should work

    7.  make separate readmes depending on if user wants to use or
        train, add separate instructions for different branches

    8.  consider building readme and project using python -m framework

    9.  provide all trained models for later reference -\> and/or
        provide full random seeds for generation

    10. add citations in readme as per general standard

2.  Translation

    1.  **TODO** think about checkpoint averaging and how
        this would also ultimately work

    2.  **TODO** think of post-processing scripts needed for
        final checkpoints, conversion to csv etc.

    3.  **TODO** during use in translate script, load model
        manually with specified checkpoint, moses tokenizer, fastbpe and
        bpe.32000 file

    4.  **TODO** split output sentences by single space and
        then do moses detokenization to get back most ordered output for
        reading/comparison

    5.  **TODO** fix up model typing for translation
        functions, try to use fairseq transformer class instead of Any

    6.  train additional large model on wmt19 non-backtranslated data
        without backtranslation and similar transformer arch as fair
        paper, see how that works, do this after building all the other
        pipelines since this should be quick task given that translation
        code is mostly working

    7.  use strong and weak model for translation -\> strong model being
        WMT19 single and ensemble with back translation (which adds
        robustness), while weak model being transformer trained on WMT16
        without back translation -\> compare general bleu scores

    8.  add easy and meaningful workflow for this directly into
        repository

    9.  consider also looking into extra references repo
        \"evaluation-of-nmt-bt\"

3.  Paraphrase detection

    1.  Fine-tuning using modified xtreme workflow

        1.  fine-tune models with English and ensure no or little
            machine translated data is present in training set

        2.  refactor and improve xtreme code with simpler repository:

            1.  modify logging of models, combination of languages,
                correct naming of training parameters and files, add
                better metrics for monitoring performance like F1

            2.  train more model combinations, change evaluation metrics
                on test set to only be at the end, continue training for
                existing models or re-evaluate them on the test dataset,
                make new model which learns from all data instead of
                just one language, remove constant re-writing of caches,
                add more information into each log file to make it
                unique

            3.  add clean prediction workflow for translated data

        3.  optional: data augmentation with easy examples -\> perhaps
            add this in to training scheme

        4.  run and document multiple models -\> such as fine-tuned
            multilingual BERT and others

        5.  add failsafe to output maximum score in case same inputs

        6.  better to work with human-curated data than back-translated
            ones due to many errors -\> advantage in PAWS and PAWS-X
            English data + WMT19 AR paraphrases

4.  Evaluation and visualization

    1.  run bleu and chrF comparisons on sources and targets for nice
        plots

    2.  need to think of effective ways of converting tensorflow event
        logs to csv\'s for nicer plotting -\> look into event log
        combination workflow

    3.  run paraphrase detection only in cases where initial German
        paraphrase is positively detected, to ensure some consistency
        for evaluation -\> maybe there might be an interesting
        correlation between XLM-R prediction and chrF scores

    4.  in rare cases, can do manual analysis and include this inside
        report

    5.  report evaluation of fine-tuning paraphrase detector and weaker
        translation model -\> get enough well-structured data for
        ultimate plotting

    6.  early conclusions/hypothese: hand-crafted adversarial paraphrase
        robustness is handled well in SOTA models due to backtranslation
        reguralization, main vulnerability will be targetted adversarial
        samples

5.  Paper

    1.  use two-column format for final paper, to prepare for paper
        writing

    2.  describe processes that worked and did not work -\> talk about
        all the hurdles and show some bad examples when they occurred
        -\> summarized below in logs

    3.  list hypotheses and how some were refuted by results

    4.  include semantic transferance equation in paper to introduce
        some formalisms

### Completed

1.  **DONE** consider making separate branch with sbatch
    parameters all present in files as necessary for reproducibility

2.  **DONE** bug in XLM-R as it does not appear to learn -\>
    look through code

3.  **DONE** multilingual BERT with de only -\> bug in how
    test scripts are saved leads to wrong results

4.  **DONE** maybe consider using German BERT for doing this
    task explicitly for German, for our end task -\> German BERT and
    RoBERTa for English to focus on exact task -\> perhaps just use
    xtreme repo and keep only paws-x task -\> clean up code and workflow
    for it -\> error might be arising due to gradient clipping for very
    large model

5.  **DONE** look into ParaBank2 and universal
    decompositional semantics -\> not great paraphrases, no human
    curation

6.  **DONE** look into Duolingo dataset for paraphrases -\>
    no German target side

7.  **DONE** add symbols for defaults in metavar default
    formatter, maybe add some other formatting tricks such as indents
    for defaults

8.  **DONE** try installing java locally instead of root, if
    stanford parser is indeed necessary

9.  **DONE** paraphrasing with SGCP -\> very bad results on
    both original test and WMT data -\> very sensitive to exemplar

10. **DONE** embed and cluser using universal sentence
    encoder (eg. BERT or LASER) -\> use separate clusters for exemplar
    utility, make diverse collection and evaluate using metric or other
    NN

11. **DONE** find other sentence with maximum similarity and
    use that as exemplar, useparaphrase of best as exemplar, use
    pos-tags of sentence

12. **DONE** convert wmt datasets with derived exemplars into
    format pipe-able into SGCP -\> needed before paraphrasing

13. **DONE** add workflow to download laser models with
    python -m laserembeddings download-models

14. **DONE** set up WMT 17 dev/test data and basic repo

15. **DONE** convert all processes to makefile for ease

16. **DONE** set up data downloading for all wmt sets with
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
