include ../common.mk

IMAGE_NAME:=NGSOLVE_IMAGE

$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg PETSC_BASE=pymor/petsc_py$@:$(PETSC_TAG) \
	  --build-arg PYTHON_BASE=pymor/python_$@:$(PYTHON_TAG) \
		--build-arg NGSOLVE_VERSION=$(NGSOLVE_VERSION) \
		-t $(call $(IMAGE_NAME),$@,$(VER)) docker
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$@,$(VER)) $(call $(IMAGE_NAME),$@,latest)
