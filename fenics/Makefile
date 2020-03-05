include ../common.mk

IMAGE_NAME:=FENICS_IMAGE

$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg PETSC=$(call PETSC_IMAGE,$@,$(PETSC_TAG)) \
		-t $(call $(IMAGE_NAME),$@,$(VER)) docker
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$@,$(VER)) $(call $(IMAGE_NAME),$@,latest)
