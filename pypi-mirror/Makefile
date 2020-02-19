include ../common.mk

get_requirements_%:
	test -d pymor_source || git clone https://github.com/pymor/pymor.git pymor_source
	cd pymor_source && git checkout origin/master
	cp pymor_source/requirements* stable/


$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg PYVER=$@ \
		-t $(call PYPI_MIRROR_STABLE_IMAGE,$@,$(VER)) stable
	$(DOCKER_TAG) $(call PYPI_MIRROR_STABLE_IMAGE,$@,$(VER)) $(call PYPI_MIRROR_STABLE_IMAGE,$@,latest)

push_%:
	$(DOCKER_PUSH) $(call PYPI_MIRROR_STABLE_IMAGE,$*,$(VER))
	$(DOCKER_PUSH) $(call PYPI_MIRROR_STABLE_IMAGE,$*,latest)

pull_latest_%:
	docker pull $(call PYPI_MIRROR_STABLE_IMAGE,$*,latest)
