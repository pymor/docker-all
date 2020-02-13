include ../common.mk

$(PYTHONS): IS_DIRTY
	$(DOCKER_BUILD) --build-arg BASE=$(call PYTHON_IMAGE,$@,$(PYTHON_TAG)) \
		-t $(call DEALII_IMAGE,$@,$(VER)) docker
	$(DOCKER_TAG) $(call DEALII_IMAGE,$@,$(VER)) $(call DEALII_IMAGE,$@,latest)

push_%:
	$(DOCKER_PUSH) $(call DEALII_IMAGE,$*,$(VER))

pull_latest_%:
	docker pull $(call DEALII_IMAGE,$@,latest)
