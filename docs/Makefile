all: releases

push: push_releases

include ../common.mk

.PHONY: FORCE

FORCE:

releases: FORCE
	$(DOCKER_BUILD) \
		-t $(call DOC_RELEASES_IMAGE,$(VER)) releases
	$(DOCKER_TAG) $(call DOC_RELEASES_IMAGE,$(VER)) $(call DOC_RELEASES_IMAGE,latest)

push_releases:
	$(DOCKER_PUSH) $(call DOC_RELEASES_IMAGE,$(VER))
	$(DOCKER_PUSH) $(call DOC_RELEASES_IMAGE,latest)

pull_latest_%:
	docker pull $(call DOC_RELEASES_IMAGE,latest)
