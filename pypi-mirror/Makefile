include ../common.mk

PYMOR_BRANCH?=master

# this a manual
download_source: IS_DIRTY
	test -d pymor_source || git clone https://github.com/pymor/pymor.git pymor_source
	cd pymor_source && git checkout origin/$(PYMOR_BRANCH)
	cp pymor_source/requirements* stable/
	cp pymor_source/requirements* constrainer/

$(PYTHONS): % : constraints-%
	$(DOCKER_BUILD) --no-cache --build-arg PYVER=$@  \
		-t $(call PYPI_MIRROR_STABLE_IMAGE,$@,$(VER)) stable
	$(DOCKER_TAG) $(call PYPI_MIRROR_STABLE_IMAGE,$@,$(VER)) $(call PYPI_MIRROR_STABLE_IMAGE,$@,latest)

constraints: $(addprefix constraints-,$(PYTHONS))

constraints-%: IS_DIRTY
	$(DOCKER_BUILD) --no-cache --build-arg BASE=pymor/testing_py$*:latest \
		-t pymor/local_requirements_py$*:$(VER) constrainer
	docker run pymor/local_requirements_py$*:$(VER) > stable/constraints_py$*.txt

push_%:
	$(DOCKER_PUSH) $(call PYPI_MIRROR_STABLE_IMAGE,$*,$(VER))
	$(DOCKER_PUSH) $(call PYPI_MIRROR_STABLE_IMAGE,$*,latest)

pull_latest_%:
	docker pull $(call PYPI_MIRROR_STABLE_IMAGE,$*,latest)
