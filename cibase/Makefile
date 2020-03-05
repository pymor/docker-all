include ../common.mk

IMAGE_NAME:=CIBASE_IMAGE

$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg PYVER=$@ \
		-t $(call $(IMAGE_NAME),$@,$(VER)) buster
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$@,$(VER)) $(call $(IMAGE_NAME),$@,latest)
