TAGS = 0.5 master 2019.2

.PHONY: TAGS $(TAGS)

TAGS: $(TAGS)

$(TAGS):
	$(DOCKER_BUILD) -t pymor/demo:$@ $@

all: TAGS
