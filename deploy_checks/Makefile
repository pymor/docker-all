DISTROS = centos_8 debian_stretch debian_buster debian_bullseye
NAMESPACE ?= pymor

.PHONY: distros $(DISTROS) push

distros: $(DISTROS)

$(DISTROS):
	cd $@ && $(DOCKER_BUILD) -t $(NAMESPACE)/deploy_checks:$@ .

push:
	$(DOCKER_PUSH) $(NAMESPACE)/deploy_checks

all: distros
