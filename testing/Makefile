include ../common.mk

$(PYTHONS):
	docker build -t $(call TESTING_IMAGE,$@,$(VER)) $@
	docker tag $(call TESTING_IMAGE,$@,$(VER)) $(call TESTING_IMAGE,$@,latest)

squash:
	echo docker-squash -h &> /dev/null && docker-squash pymor/testing:$@

push_%:
	docker push $(call TESTING_IMAGE,$*,$(VER))

pull_latest_%:
	docker pull $(call TESTING_IMAGE,$@,latest)
