all: TAGS
	
include ../common.mk
TAGS = 0.5 master 2019.2

.PHONY: TAGS $(TAGS)



TAGS: $(TAGS)

$(TAGS): IS_DIRTY
	$(DOCKER_BUILD) -t pymor/demo:$@ $@

push: $(addprefix push_,$(TAGS))

push_%:
	$(DOCKER_PUSH) pymor/demo:$*
