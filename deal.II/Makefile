include ../common.mk

$(PYTHONS): IS_DIRTY
	docker build --build-arg BASE=$(call PYTHON_IMAGE,$@,$(PYTHON_TAG)) \
		-t $(call DEALII_IMAGE,$@,$(VER)) docker
	docker tag $(call DEALII_IMAGE,$@,$(VER)) $(call DEALII_IMAGE,$@,latest)

push_%:
	docker push $(call DEALII_IMAGE,$*,$(VER))

pull_latest_%:
	docker pull $(call DEALII_IMAGE,$@,latest)
