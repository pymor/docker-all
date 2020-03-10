releases: FORCE
	$(DOCKER_BUILD) -t $(call $(IMAGE_NAME),dummy,$(VER)) releases
	$(DOCKER_TAG) $(call $(IMAGE_NAME),dummy,$(VER)) $(call $(IMAGE_NAME),dummy,latest)

push: push_releases

include ../common.mk

IMAGE_NAME:=DOC_RELEASES_IMAGE

.PHONY: FORCE

FORCE:
