include ../common.mk

IMAGE_NAME:=DEALII_IMAGE

$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg BASE=$(call PYTHON_IMAGE,$@,$(PYTHON_TAG)) \
		-t $(call $(IMAGE_NAME),$@,$(VER)) docker
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$@,$(VER)) $(call $(IMAGE_NAME),$@,latest)

push_%:
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),$*,$(VER))
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),$*,latest)

pull_latest_%:
	docker pull $(call $(IMAGE_NAME),$*,latest)
