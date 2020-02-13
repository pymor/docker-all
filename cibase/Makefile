include ../common.mk

$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg PYVER=$@ \
		-t $(call CIBASE_IMAGE,$@,$(VER)) buster

push_%:
	$(DOCKER_PUSH) $(call CIBASE_IMAGE,$*,$(VER))
	$(DOCKER_PUSH) $(call CIBASE_IMAGE,$*,latest)

pull_latest_%:
	docker pull $(call CIBASE_IMAGE,$*,latest)
