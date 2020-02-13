include ../common.mk

$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg PETSC=$(call PETSC_IMAGE,$@,$(PETSC_TAG)) \
		-t $(call FENICS_IMAGE,$@,$(VER)) docker
	$(DOCKER_TAG) $(call FENICS_IMAGE,$@,$(VER)) $(call FENICS_IMAGE,$@,latest)

push_%:
	$(DOCKER_PUSH) $(call FENICS_IMAGE,$*,$(VER))

pull_latest_%:
	docker pull $(call FENICS_IMAGE,$@,latest)
