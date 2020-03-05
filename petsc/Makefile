include ../common.mk

IMAGE_NAME:=PETSC_IMAGE

$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg BASE=$(call PYTHON_IMAGE,$@,$(PYTHON_TAG)) \
	-t $(call $(IMAGE_NAME),$@,$(VER)) docker
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$@,$(VER)) $(call $(IMAGE_NAME),$@,latest)
