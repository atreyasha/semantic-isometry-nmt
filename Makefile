SHELL = /bin/bash
WMT = ./data/wmt_all
GIT_HOOKS = ./.git/hooks
DATA = ./data

$(GIT_HOOKS)/pre-commit: ./hooks/pre-commit.sample
	cp --force $< $@

.PHONY: hook
hook: $(GIT_HOOKS)/pre-commit

.PHONY: download_laser
download_laser:
	python3 -m laserembeddings download-models

.PHONY: download_PAWS_X
download_PAWS_X:
	wget -N -P $(DATA) "https://storage.googleapis.com/paws/pawsx/x-final.tar.gz"
	tar -zxvf $(DATA)/x-final.tar.gz -C $(DATA)
