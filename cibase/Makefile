include ../../common.mk

$(PYTHONS):
	$(DOCKER_BUILD) --build-arg PYVER=$@ \
		-t $(call CIBASE_IMAGE,$@,$(VER)) buster

push_%:
	$(DOCKER_PUSH) $(call CIBASE_IMAGE,$*,$(VER))

pull_latest_%:
	docker pull $(call CIBASE_IMAGE,$@,latest)
