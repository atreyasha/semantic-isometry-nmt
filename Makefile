GIT_HOOKS = ./.git/hooks
WMT = ./data/wmt
SGCP_DATA = ./data/sgcp
SGCP_MODELS = ./models/sgcp

$(GIT_HOOKS)/pre-commit: ./hooks/pre-commit.sample
	cp --force $< $@

.PHONY: hook
hook: $(GIT_HOOKS)/pre-commit

.PHONY: download_wmt_08_19_test
download_wmt_all:
  # make directories
	mkdir -p $(WMT)
  # download necessary WMT files
	for i in $$(seq 8 19); do \
		[[ "$$i" -lt "10" ]] && i="0$$i"; \
		sacrebleu --test-set "wmt$$i" --language-pair de-en --echo src > $(WMT)/"wmt$$i.test.truecased.de"; \
		sacrebleu --test-set "wmt$$i" --language-pair de-en --echo ref > $(WMT)/"wmt$$i.test.truecased.en"; \
	done

.PHONY: download_sgcp
download_sgcp:
  # set up directories and download files
	mkdir -p $(SGCP_DATA)
	mkdir -p $(SGCP_MODELS)
	wget --save-cookies cookies.txt --keep-session-cookies --delete-after "https://indianinstituteofscience-my.sharepoint.com/:u:/g/personal/ashutosh_iisc_ac_in/ER-roD8qRXFCsyJwbOHOVPgBs-VTKNmkNLzQvM0cLtvBhw?e=a0dOid"
	wget --load-cookies ./cookies.txt -N -P $(SGCP_DATA) "https://indianinstituteofscience-my.sharepoint.com/personal/ashutosh_iisc_ac_in/_layouts/15/download.aspx?SourceUrl=%2Fpersonal%2Fashutosh_iisc_ac_in%2FDocuments%2FSGCP%2Fdata.zip"
	wget --save-cookies cookies.txt --keep-session-cookies --delete-after "https://indianinstituteofscience-my.sharepoint.com/:u:/g/personal/ashutosh_iisc_ac_in/Ed5IT05LTaFNhVFweWuUE8MBnRCkSAJwSotrAhzT_2lL5w?e=3hOrSI"
	wget --load-cookies ./cookies.txt -N -P $(SGCP_MODELS) "https://indianinstituteofscience-my.sharepoint.com/personal/ashutosh_iisc_ac_in/_layouts/15/download.aspx?SourceUrl=%2Fpersonal%2Fashutosh_iisc_ac_in%2FDocuments%2FSGCP%2FModels.zip"
	wget --save-cookies cookies.txt --keep-session-cookies --delete-after "https://indianinstituteofscience-my.sharepoint.com/:u:/g/personal/ashutosh_iisc_ac_in/EQVo8LOkzlFKhAlfjMnZc20BEFfAzvemc9TdBONtBSpmGQ?e=q3J4NS"
	wget --load-cookies ./cookies.txt -N -P $(SGCP_DATA) "https://indianinstituteofscience-my.sharepoint.com/personal/ashutosh_iisc_ac_in/_layouts/15/download.aspx?SourceUrl=%2Fpersonal%2Fashutosh_iisc_ac_in%2FDocuments%2FSGCP%2Fevaluation.zip"
	rm cookies.txt

.PHONY: deploy_sgcp
deploy_sgcp:
  # unzip and re-order
	unzip -o $(SGCP_DATA)/*data.zip -d $(SGCP_DATA)
	rm -rf $(SGCP_DATA)/Para* $(SGCP_DATA)/QQP* $(SGCP_DATA)/evaluation
	mv -f $(SGCP_DATA)/data/* $(SGCP_DATA)
	rm -r $(SGCP_DATA)/data
	unzip -o $(SGCP_MODELS)/*Models.zip -d $(SGCP_MODELS)
	rm -rf $(SGCP_MODELS)/QQP* $(SGCP_MODELS)/Para*
	mv -f $(SGCP_MODELS)/Models/* $(SGCP_MODELS)
	rm -r $(SGCP_MODELS)/Models
	unzip -o $(SGCP_DATA)/*evaluation.zip -d $(SGCP_DATA)
