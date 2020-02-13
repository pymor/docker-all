include ../common.mk

$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg BASE=$(call PYTHON_IMAGE,$@,$(PYTHON_TAG)) \
	-t $(call PETSC_IMAGE,$@,$(VER)) docker
	$(DOCKER_TAG) $(call PETSC_IMAGE,$@,$(VER)) $(call PETSC_IMAGE,$@,latest)

push_%:
	$(DOCKER_PUSH) $(call PETSC_IMAGE,$*,$(VER))
	$(DOCKER_PUSH) $(call PETSC_IMAGE,$*,latest)

pull_latest_%:
	docker pull $(call PETSC_IMAGE,$*,latest)
