all: releases

push: push_releases

include ../common.mk

IMAGE_NAME:=DOC_RELEASES_IMAGE

.PHONY: FORCE

FORCE:

releases: FORCE
	$(DOCKER_BUILD) \
		-t $(call $(IMAGE_NAME),$(VER)) releases
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$(VER)) $(call $(IMAGE_NAME),latest)
