include ../common.mk

$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg PYVER=$@ --build-arg VERTAG=$(VER) \
		-t $(call JUPYTER_IMAGE,$@,$(VER)) docker
	$(DOCKER_TAG) $(call JUPYTER_IMAGE,$@,$(VER)) $(call JUPYTER_IMAGE,$@,latest)

push_%:
	$(DOCKER_PUSH) $(call JUPYTER_IMAGE,$*,$(VER))
	$(DOCKER_PUSH) $(call JUPYTER_IMAGE,$*,latest)

pull_latest_%:
	docker pull $(call JUPYTER_IMAGE,$*,latest)
