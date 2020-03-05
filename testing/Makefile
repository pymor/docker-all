include ../common.mk

IMAGE_NAME:=TESTING_IMAGE

$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg BASETAG=$(VER) \
		-t $(call $(IMAGE_NAME),$@,$(VER)) $@
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$@,$(VER)) $(call $(IMAGE_NAME),$@,latest)

squash:
	echo docker-squash -h &> /dev/null && docker-squash pymor/testing:$@
