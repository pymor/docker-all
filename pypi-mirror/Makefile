include ../common.mk

PYMOR_BRANCH?=master
IMAGE_NAME:=PYPI_MIRROR_IMAGE

# this a manual target
download_source: IS_DIRTY
	test -d pymor_source || git clone https://github.com/pymor/pymor.git pymor_source
	cd pymor_source && git checkout origin/$(PYMOR_BRANCH)
	cp pymor_source/requirements* stable/
	cp pymor_source/requirements* constrainer/

$(PYTHONS): % : IS_DIRTY
	$(DOCKER_BUILD) --build-arg BASE=pymor/testing_py$@:latest \
		-t pymor/constraints_py$@:$(VER) constrainer
	$(DOCKER_BUILD) --build-arg PYVER=$@ --build-arg VER=$(VER) \
		-t $(call $(IMAGE_NAME),$@,$(VER),stable) stable
	$(DOCKER_BUILD) --build-arg PYVER=$@ --build-arg VER=$(VER) \
		-t $(call $(IMAGE_NAME),$@,$(VER),oldest) oldest
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$@,$(VER),oldest) $(call $(IMAGE_NAME),$@,latest,oldest)
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$@,$(VER),stable) $(call $(IMAGE_NAME),$@,latest,stable)

constraints: $(addprefix constraints_,$(PYTHONS))

constraints_%: IS_DIRTY

push_%:
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),$*,$(VER),oldest)
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),$*,$(VER),stable)
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),$*,latest,oldest)
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),$*,latest,stable)

test_%:
	VARIANT=stable PYPI_MIRROR_TAG=$(VER) CI_IMAGE_TAG=$(VER) DOCKER_BASE_PYTHON=$* docker-compose up --build test
	VARIANT=oldest PYPI_MIRROR_TAG=$(VER) CI_IMAGE_TAG=$(VER) DOCKER_BASE_PYTHON=$* docker-compose up --build test

test: $(addprefix test_,$(filter-out 3.9,$(PYTHONS)))
