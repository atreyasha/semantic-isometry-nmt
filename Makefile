GIT_HOOKS = ./.git/hooks
WMT_PREFIX = ./data/wmt17
WMT_DEV_TEST = $(WMT_PREFIX)/dev_test
WMT_TRAIN = $(WMT_PREFIX)/train

$(GIT_HOOKS)/pre-commit: ./hooks/pre-commit.sample
	cp --force $< $@

.PHONY: hook
hook: $(GIT_HOOKS)/pre-commit

.PHONY: wmt17
wmt17:
  # make directories
	mkdir -p $(WMT_DEV_TEST) $(WMT_TRAIN)
  # download necessary WMT17 files
	wget "http://data.statmt.org/wmt17/translation-task/preprocessed/de-en/corpus.tc.de.gz" -N -P $(WMT_TRAIN)
	wget "http://data.statmt.org/wmt17/translation-task/preprocessed/de-en/corpus.tc.en.gz" -N -P $(WMT_TRAIN)
	wget "http://data.statmt.org/wmt17/translation-task/preprocessed/de-en/dev.tgz" -N -P $(WMT_DEV_TEST)
  # decompress all files
	gunzip -c $(WMT_TRAIN)/corpus.tc.de.gz > $(WMT_TRAIN)/train.truecased.de
	gunzip -c $(WMT_TRAIN)/corpus.tc.en.gz > $(WMT_TRAIN)/train.truecased.en
	tar -zxvf $(WMT_DEV_TEST)/dev.tgz -C $(WMT_DEV_TEST)
  # symlink important files for easy access
	ln -sfr $(WMT_TRAIN)/train.truecased.de $(WMT_PREFIX)/train.truecased.de
	ln -sfr $(WMT_TRAIN)/train.truecased.en $(WMT_PREFIX)/train.truecased.en
	ln -sfr $(WMT_DEV_TEST)/newstest2015.tc.de $(WMT_PREFIX)/dev.truecased.de
	ln -sfr $(WMT_DEV_TEST)/newstest2015.tc.en $(WMT_PREFIX)/dev.truecased.en
	ln -sfr $(WMT_DEV_TEST)/newstest2016.tc.de $(WMT_PREFIX)/test.truecased.de
	ln -sfr $(WMT_DEV_TEST)/newstest2016.tc.en $(WMT_PREFIX)/test.truecased.en

.PHONY: sgcp
sgcp:
  # set up directories and download files
	mkdir -p ./data/sgcp
	mkdir -p ./models/sgcp
	wget --save-cookies cookies.txt --keep-session-cookies --delete-after "https://indianinstituteofscience-my.sharepoint.com/:u:/g/personal/ashutosh_iisc_ac_in/ER-roD8qRXFCsyJwbOHOVPgBs-VTKNmkNLzQvM0cLtvBhw?e=a0dOid"
	wget --load-cookies ./cookies.txt -N -P ./data/sgcp/ "https://indianinstituteofscience-my.sharepoint.com/personal/ashutosh_iisc_ac_in/_layouts/15/download.aspx?SourceUrl=%2Fpersonal%2Fashutosh_iisc_ac_in%2FDocuments%2FSGCP%2Fdata.zip"
	wget --save-cookies cookies.txt --keep-session-cookies --delete-after "https://indianinstituteofscience-my.sharepoint.com/:u:/g/personal/ashutosh_iisc_ac_in/Ed5IT05LTaFNhVFweWuUE8MBnRCkSAJwSotrAhzT_2lL5w?e=3hOrSI"
	wget --load-cookies ./cookies.txt -N -P ./models/sgcp/ "https://indianinstituteofscience-my.sharepoint.com/personal/ashutosh_iisc_ac_in/_layouts/15/download.aspx?SourceUrl=%2Fpersonal%2Fashutosh_iisc_ac_in%2FDocuments%2FSGCP%2FModels.zip"
	wget --save-cookies cookies.txt --keep-session-cookies --delete-after "https://indianinstituteofscience-my.sharepoint.com/:u:/g/personal/ashutosh_iisc_ac_in/EQVo8LOkzlFKhAlfjMnZc20BEFfAzvemc9TdBONtBSpmGQ?e=q3J4NS"
	wget --load-cookies ./cookies.txt -N -P ./data/sgcp/ "https://indianinstituteofscience-my.sharepoint.com/personal/ashutosh_iisc_ac_in/_layouts/15/download.aspx?SourceUrl=%2Fpersonal%2Fashutosh_iisc_ac_in%2FDocuments%2FSGCP%2Fevaluation.zip"
  # unzip and re-order
	unzip -o ./data/sgcp/*data.zip -d ./data/sgcp/
	mv ./data/sgcp/data/* ./data/sgcp/
	rm -r ./data/sgcp/data
	unzip -o ./data/models/*Models.zip -d ./data/models/
	mv ./models/Models/* ./models/
	rm -r ./models/Models
	unzip -o ./data/sgcp/*evaluation.zip -d ./data/sgcp/
