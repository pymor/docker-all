include ../common.mk

VARIANT?=buster/slim

$(PYTHONS): IS_DIRTY
	cd "$@/$(VARIANT)" && \
		docker build -t $(call PYTHON_IMAGE,$@,$(VER)) .
	docker tag $(call PYTHON_IMAGE,$@,$(VER)) $(call PYTHON_IMAGE,$@,latest)

push_%:
docker push $(call PYTHON_IMAGE,$*,$(VER))

pull_latest_%:
docker pull $(call PYTHON_IMAGE,$@,latest)
