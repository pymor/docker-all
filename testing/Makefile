include ../common.mk

$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg BASETAG=$(VER) \
		-t $(call TESTING_IMAGE,$@,$(VER)) $@
	$(DOCKER_TAG) $(call TESTING_IMAGE,$@,$(VER)) $(call TESTING_IMAGE,$@,latest)

squash:
	echo docker-squash -h &> /dev/null && docker-squash pymor/testing:$@

push_%:
	$(DOCKER_PUSH) $(call TESTING_IMAGE,$*,$(VER))
	$(DOCKER_PUSH) $(call TESTING_IMAGE,$*,latest)

pull_latest_%:
	docker pull $(call TESTING_IMAGE,$*,latest)
