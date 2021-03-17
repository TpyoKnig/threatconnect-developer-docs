help:
	@echo "uptcex 		update tcex documentation"
	@echo "clean 		clean unneeded files"
	@echo "test 		run the tests"
	@echo "upstream 	set upstream to https://github.com/ThreatConnect-Inc/threatconnect-developer-docs.git (useful when working on a fork of the TC docs)"
	@echo "doctest 	run sphinx on the documentation to view errors"

today := $(shell date +"%B %d, %Y")
uptcex:
	# This script is to be run in the top directory of the TC Documentation (available here: https://github.com/ThreatConnect-Inc/threatconnect-developer-docs)
	# delete any top level copy of tcex docs
	rm -rf ./tcex/;
	# delete old copy of tcex docs
	rm -rf ./docs/tcex/;
	# make new TCEX directory for documentation
	mkdir ./docs/tcex;
	# clone the most recent commit to the master branch of the tcex repo into the ./tcex directory
	git clone --branch master https://github.com/ThreatConnect-Inc/tcex.git;
	# remove the .git & gitignore directories of the recently cloned tcex repo
	rm -rf ./tcex/.git/;
	rm -rf ./tcex/.gitignore;
	# move all of the .rst files from the tcex repo's documentation into this repo's documentation directory
	cp -pr ./tcex/docs/src/*rst ./docs/tcex;
	# move all of the .inc files from the tcex repo's documentation into this repo's documentation directory
	cp -pr ./tcex/docs/src/*.inc ./docs/tcex/;
	# build docs to ensure that they are the latest
	# make shell scripts executeable
	chmod 755 ./tcex/docs/src/*.sh;
	# install needed python libraries
	pip install tcex sphinx sphinx_rtd_theme CommonMark reno pre-commit;
	# needed for pre-commit to work correctly
	pre-commit install
	#copy pre-commit config for docs
	cp ./tcex/.pre-commit-config.yaml ./tcex/docs/src;
	# change to the tcex/docs/src directory and run the build
	cd ./tcex/docs/src/; ./00__build.sh;
	# change to the tcex/docs/src directory and perform a clean up
	cd ./tcex/docs/src/; ./01__cleanup.sh;
	# rename the landing page for the tcex docs
	mv ./tcex/docs/src/index.rst ./docs/tcex/tcex.rst;
	# move all of the .rst files from the compiled repo's documentation into this repo's documentation directory
	mv ./tcex/docs/src/*.rst ./docs/tcex/;
	# move all of the .inc files from the compiled repo's documentation into this repo's documentation directory
	mv ./tcex/docs/src/*.inc ./docs/tcex/;
	# move over tcex_docs as well
	mv ./tcex/docs/src/tcex_docs/ ./docs/tcex/;
	# remove old directory
	rm -rf ./tcex/;
	# change the variable name of the tcex version used in the tcex docs
	sed -i.bak 's/|version|/|tcex_version|/g' ./docs/tcex/tcex.rst && rm ./docs/tcex/tcex.rst.bak;
	# stage all changes (including deletions)
	git add .
	# commit
	git commit -m "Auto-update TCEX docs: $(today)";
	# push
	git push

clean:
	# This script is to be run in the top directory of the TC Documentation (available here: https://github.com/ThreatConnect-Inc/threatconnect-developer-docs)

	rm -rf ./.cache/
	rm -rf ./tests/__pycache__/
	rm -rf ./tests/test.py
	rm -rf ./docs/_build/

test:
	# run the tests and remove the junk created by the tests
	pytest;
	rm -rf ./tests/__pycache__/;
	rm -rf ./tests/test.py;

upstream:
	# set upstream for a clone of this repo
	git remote add upstream https://github.com/ThreatConnect-Inc/threatconnect-developer-docs.git;
	git remote -v;

doctest:
	cd docs && virtualenv ~/.venv/tc_developer_docs && source ~/.venv/tc_developer_docs/bin/activate && pip install sphinx && pip install recommonmark && pip install tcex && pip install sphinx_rtd_theme && sphinx-build -T -E -d _build/doctrees-readthedocs -D language=en . _build/html
