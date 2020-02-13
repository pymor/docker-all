include ../common.mk

VARIANT?=buster/slim

$(PYTHONS): IS_DIRTY
	cd "$@/$(VARIANT)" && \
		$(DOCKER_BUILD) -t $(call PYTHON_IMAGE,$@,$(VER)) .
	$(DOCKER_TAG) $(call PYTHON_IMAGE,$@,$(VER)) $(call PYTHON_IMAGE,$@,latest)

push_%:
	$(DOCKER_PUSH) $(call PYTHON_IMAGE,$*,$(VER))

pull_latest_%:
	docker pull $(call PYTHON_IMAGE,$@,latest)
