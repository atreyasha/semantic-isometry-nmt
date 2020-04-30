### To-do\'s

1.  SCPN framework

    1.  **TODO** port SCPN code from python2 to python3 and
        ensure it works, if not re-train model for python 3 -\> priority
        is for generate~paraphrases~.py first to check if the saved
        models can work, might need to port other linking files as well

    2.  download stanford parser into repo and use this on WMT 17 data

    3.  generate parses for WMT17 dev/test, check quality and think of
        how to extend this utility to other SOTA parsers

    4.  generate paraphrases for WMT 17 data using previous steps

2.  SOTA NMT models

    1.  **TODO** download SOTA models from fairseq, start
        testing paraphrased samples on it and manually check out
        differences in results, see if this idea makes sense on a large
        scale

    2.  look for models that worked on WMT 17 en-de dataset and work
        from there

    3.  after manual checks, start thinking of semantic similarity
        measures on the target end, also possibly on the source side
        although we can assume that the SCPN makes quite good
        paraphrases

    4.  set up English and German SOTA parsers on local system

3.  Rules-based approaches

    1.  **TODO** consider other ways of generating
        paraphrases -\> perhaps rules based approaches employing logical
        rules

    2.  check if application of logic affects NMT models

4.  Documentation

    1.  add documentation/acknowledgments to datasets and code, refactor
        major code used in SCPN to make it cleaner and better

    2.  add citations in readme as per general standard

### Completed

1.  **TODO** set up WMT 17 dev/test data and basic repo
