### To-do\'s

1.  Paraphrasing

    1.  Automated frameworks

        1.  1\. SCPN \[torch\] -\> written in python2.7 and buggy, but
            some examples work

        2.  2\. Pair-it \[tensorflow\] -\> written in python3, has
            potential to work but requires refactoring

        3.  **TODO** 3. SGCP \[torch\] -\> written in
            python3, generate paraphrases given exemplar sentence form

        4.  test how SGCP works, memory consumption on single GPU, check
            if it can be tweaked for own purposes

        5.  generate paraphrases for WMT 17 data using previous steps

        6.  check if it is possible to make complete combined framework
            for adversarial generation

    2.  Rules-based approaches

        1.  consider other ways of generating paraphrases -\> perhaps
            rules based approaches employing logical rules

        2.  look into semantic web senses and how these could be used
            given world knowledge

        3.  generate paraphrases for WMT 17 data using previous steps

2.  Code and documentation

    1.  **TODO** add easy script for downloading google drive
        files

    2.  add documentation/acknowledgments to datasets and code, refactor
        major code used in SCPN to make it cleaner and better

    3.  add citations in readme as per general standard

3.  Syntax-parsers

    1.  download stanford parser into repo and use this on WMT 17 data

    2.  generate parses for WMT17 dev/test, check quality and think of
        how to extend this utility to other SOTA parsers

4.  SOTA NMT models

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

### Completed

1.  **DONE** set up WMT 17 dev/test data and basic repo

2.  **DONE** convert all processes to makefile for ease

3.  **DONE** add pipeline to download WMT 17 training data
