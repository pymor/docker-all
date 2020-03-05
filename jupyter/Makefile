include ../common.mk

IMAGE_NAME:=JUPYTER_IMAGE

$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg PYVER=$@ --build-arg VERTAG=$(VER) \
		-t $(call $(IMAGE_NAME),$@,$(VER)) docker
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$@,$(VER)) $(call $(IMAGE_NAME),$@,latest)
