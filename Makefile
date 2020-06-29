SHELL = /bin/bash
GIT_HOOKS = ./.git/hooks
DATA = ./data

$(GIT_HOOKS)/pre-commit: ./hooks/pre-commit
	cp --force $< $@

.PHONY: pre_commit_hook
pre_commit_hook: $(GIT_HOOKS)/pre-commit

.PHONY: PAWS_X
PAWS_X:
	wget -N -P $(DATA) "https://storage.googleapis.com/paws/pawsx/x-final.tar.gz"
	tar -zxvf $(DATA)/x-final.tar.gz -C $(DATA)
