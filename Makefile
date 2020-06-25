SHELL = /bin/bash
GIT_HOOKS = ./.git/hooks
DATA = ./data

$(GIT_HOOKS)/pre-commit: ./hooks/pre-commit.sample
	cp --force $< $@

.PHONY: hook
hook: $(GIT_HOOKS)/pre-commit

.PHONY: download_fairseq_pretrained_models
download_fairseq_pretrained_models:
	python3 -c "import torch; torch.hub.load('pytorch/fairseq', 'transformer.wmt19.en-de.single_model')"

.PHONY: download_PAWS_X
download_PAWS_X:
	wget -N -P $(DATA) "https://storage.googleapis.com/paws/pawsx/x-final.tar.gz"
	tar -zxvf $(DATA)/x-final.tar.gz -C $(DATA)
