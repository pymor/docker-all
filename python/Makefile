include ../common.mk

VARIANT?=buster/slim
IMAGE_NAME:=PYTHON_IMAGE

$(PYTHONS): IS_DIRTY
	cd "$@/$(VARIANT)" && \
		$(DOCKER_BUILD) -t $(call $(IMAGE_NAME),$@,$(VER)) .
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$@,$(VER)) $(call $(IMAGE_NAME),$@,latest)
