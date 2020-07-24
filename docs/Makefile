releases: IMAGE_NAME:=DOC_RELEASES_IMAGE
releases: FORCE
	$(CNTR_PULL) $(call $(IMAGE_NAME),dummy,latest) 
	$(CNTR_BUILD) -t $(call $(IMAGE_NAME),dummy,$(VER)) \
	  --cache-from=$(call $(IMAGE_NAME),dummy,latest) releases
	$(CNTR_TAG) $(call $(IMAGE_NAME),dummy,$(VER)) $(call $(IMAGE_NAME),dummy,latest)

push: push_releases

include ../common.mk


.PHONY: FORCE

FORCE:
