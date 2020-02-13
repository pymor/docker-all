include ../common.mk

$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg PETSC_BASE=pymor/petsc_py$@:$(PETSC_TAG) \
	  --build-arg PYTHON_BASE=pymor/python_$@:$(PYTHON_TAG) \
		--build-arg NGSOLVE_VERSION=$(NGSOLVE_VERSION) \
		-t $(call NGSOLVE_IMAGE,$@,$(VER)) docker
	$(DOCKER_TAG) $(call NGSOLVE_IMAGE,$@,$(VER)) $(call NGSOLVE_IMAGE,$@,latest)

push_%:
	$(DOCKER_PUSH) $(call NGSOLVE_IMAGE,$*,$(VER))

pull_latest_%:
	docker pull $(call NGSOLVE_IMAGE,$*,latest)
