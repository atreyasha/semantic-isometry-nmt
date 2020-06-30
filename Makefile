SHELL = /bin/bash
GIT_HOOKS = ./.git/hooks
DATA = ./data
WMT19 = ./data/wmt19
WMT19_PARAPHRASED = ./data/wmt19_paraphrased

$(GIT_HOOKS)/pre-commit: ./hooks/pre-commit
	cp --force $< $@

.PHONY: pre_commit_hook
pre_commit_hook: $(GIT_HOOKS)/pre-commit

.PHONY: paws_x
paws_x:
	wget -N -P $(DATA) "https://storage.googleapis.com/paws/pawsx/x-final.tar.gz"
	tar -zxvf $(DATA)/x-final.tar.gz -C $(DATA)
	mv $(DATA)/x-final $(DATA)/paws-x

.PHONY: wmt19
wmt19:
	mkdir -p $(WMT19)
	sacrebleu --test-set "wmt19" --language-pair en-de --echo src > $(WMT19)/"wmt19.test.truecased.en.src"
	sacrebleu --test-set "wmt19" --language-pair en-de --echo ref > $(WMT19)/"wmt19.test.truecased.de.ref"

.PHONY: wmt19_paraphrased
wmt19_paraphrased:
	mkdir -p $(WMT19_PARAPHRASED)
	wget -N -P $(WMT19_PARAPHRASED) "https://raw.githubusercontent.com/google/wmt19-paraphrased-references/master/wmt19/ende/wmt19-ende-ar.ref"
	wget -N -P $(WMT19_PARAPHRASED) "https://raw.githubusercontent.com/google/wmt19-paraphrased-references/master/wmt19/ende/wmt19-ende-arp.ref"
	wget -N -P $(WMT19_PARAPHRASED) "https://raw.githubusercontent.com/google/wmt19-paraphrased-references/master/wmt19/ende/wmt19-ende-hqall.ref"
	wget -N -P $(WMT19_PARAPHRASED) "https://raw.githubusercontent.com/google/wmt19-paraphrased-references/master/wmt19/ende/wmt19-ende-hqp.ref"
	wget -N -P $(WMT19_PARAPHRASED) "https://raw.githubusercontent.com/google/wmt19-paraphrased-references/master/wmt19/ende/wmt19-ende-hqr.ref"
	wget -N -P $(WMT19_PARAPHRASED) "https://raw.githubusercontent.com/google/wmt19-paraphrased-references/master/wmt19/ende/wmt19-ende-wmtp.ref"

.PHONY: data
data: paws_x wmt19 wmt19_paraphrased
