all: req_constraints.txt

.PHONY: req_constraints.txt
req_constraints.txt:
	grep -v '#\|git\+' requirements.txt > req_constraints.txt


#-- Tests -------------------------------------------------------------
PYTHON_ENV  ?=
PYTHON_PATH ?= $(PYTHON_ENV)/bin/python

.PHONY: req_constraints.txt test_smoke test publish

test_setup: req_constraints.txt
	rm -rf venv
	$(PYTHON_PATH) -m virtualenv -p $(PYTHON_PATH) venv
	venv/bin/pip install -r requirements.txt -c req_constraints.txt

test_smoke:
	echo "Running smoke test"
	echo "smoke results" > smoke.log

test: test_setup
	venv/bin/pytest tests --junit-xml=test_report.xml
#----------------------------------------------------------------------

publish:
	echo "Publish"
