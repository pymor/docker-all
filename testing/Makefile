include ../common.mk

$(PYTHONS):
	$(DOCKER_BUILD) -t $(call TESTING_IMAGE,$@,$(VER)) $@
	$(DOCKER_TAG) $(call TESTING_IMAGE,$@,$(VER)) $(call TESTING_IMAGE,$@,latest)

squash:
	echo docker-squash -h &> /dev/null && docker-squash pymor/testing:$@

push_%:
	$(DOCKER_PUSH) $(call TESTING_IMAGE,$*,$(VER))

pull_latest_%:
	docker pull $(call TESTING_IMAGE,$@,latest)
