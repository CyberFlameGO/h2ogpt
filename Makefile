all: req_constraints.txt

.PHONY: req_constraints.txt
req_constraints.txt:
	grep -v '#\|git\+' requirements.txt > req_constraints.txt


#-- Build -------------------------------------------------------------
BUILD_TAG_FILES := \
      requirements.txt \
      Dockerfile

$(eval BUILD_TAG = $(shell md5sum $(BUILD_TAG_FILES) 2> /dev/null | sort | md5sum  | cut -d' ' -f1))
DOCKER_TEST_IMAGE := harbor.h2o.ai/h2ogpt/test-image:$(BUILD_TAG)
has_smoke_image   := $(shell docker pull $(DOCKER_TEST_IMAGE) > /dev/null && echo "OK")

docker_build:
ifeq ($(has_smoke_image),OK)
	@echo "Image pulled from Harbor."
else
	DOCKER_BUILDKIT=1 docker build --cache-from=$(DOCKER_TEST_IMAGE) -t $(DOCKER_TEST_IMAGE) -f Dockerfile .
	docker push $(DOCKER_TEST_IMAGE)
endif

#----------------------------------------------------------------------
wheel_in_docker: docker_build
	docker run \
		--rm \
		--ulimit core=-1 \
		-v /home/0xdiag:/home/0xdiag:ro \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/group:/etc/group:ro \
		-u `id -u`:`id -g` \
		-e HOME=/h2oai \
		-e HOST_HOSTNAME=`hostname` \
		-v `pwd`:/h2oai \
		--entrypoint bash \
		--workdir /h2oai \
		$(DOCKER_TEST_IMAGE) \
		-c "python3.10 setup.py bdist_wheel"

#-- Tests -------------------------------------------------------------
PYTHON_ENV  ?= $(shell dirname $(shell dirname `which python`))
PYTHON_PATH ?= $(PYTHON_ENV)/bin/python

.PHONY: req_constraints.txt test_smoke test publish

test_smoke: docker_build
	docker run \
		--rm \
		--ulimit core=-1 \
		-v /home/0xdiag:/home/0xdiag:ro \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/group:/etc/group:ro \
		-u `id -u`:`id -g` \
		-e HOME=/h2oai \
		-e HOST_HOSTNAME=`hostname` \
		-v `pwd`:/h2oai \
		--entrypoint bash \
		--workdir /h2oai \
		$(DOCKER_TEST_IMAGE) \
		-c "echo 'not implemented yet..' && touch smoke_test_report.xml"

venv: req_constraints.txt
	rm -rf venv
	$(PYTHON_PATH) -m virtualenv -p $(PYTHON_PATH) venv

test_setup: venv
	venv/bin/pip install -r requirements.txt -c req_constraints.txt

test_setup_cpu: test_setup
	venv/bin/pip install -r requirements_optional_langchain.txt -c req_constraints.txt
	venv/bin/pip install -r requirements_optional_gpt4all.txt -c req_constraints.txt

test:
	venv/bin/pytest tests --junit-xml=test_report.xml

#----------------------------------------------------------------------

publish:
	echo "Publishing not implemented yet."

print-%:
	@echo $($*)
