include ../common.mk

PYMOR_BRANCH?=master
IMAGE_NAME:=PYPI_MIRROR_STABLE_IMAGE

# this a manual target
download_source: IS_DIRTY
	test -d pymor_source || git clone https://github.com/pymor/pymor.git pymor_source
	cd pymor_source && git checkout origin/$(PYMOR_BRANCH)
	cp pymor_source/requirements* stable/
	cp pymor_source/requirements* constrainer/

$(PYTHONS): % :
	$(DOCKER_BUILD) --no-cache --build-arg PYVER=$@  \
		-t $(call $(IMAGE_NAME),$@,$(VER)) stable
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$@,$(VER)) $(call $(IMAGE_NAME),$@,latest)

constraints: $(addprefix constraints_,$(PYTHONS))

constraints_%: IS_DIRTY
	$(DOCKER_BUILD) --no-cache --build-arg BASE=pymor/testing_py$*:latest \
		-t pymor/local_requirements_py$*:$(VER) constrainer
	docker run pymor/local_requirements_py$*:$(VER) > stable/constraints_py$*.txt
