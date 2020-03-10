IMAGE_NAME:=DIND_IMAGE

image: IS_DIRTY
	$(DOCKER_BUILD) -t $(call $(IMAGE_NAME),dummy,$(VER)) docker
	$(DOCKER_TAG) $(call $(IMAGE_NAME),dummy,$(VER)) $(call $(IMAGE_NAME),dummy,latest)

include ../common.mk
