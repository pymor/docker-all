DISTROS = centos_8 debian_stretch debian_buster debian_bullseye

all: distros
	
include ../common.mk

distros: $(DISTROS)

$(DISTROS): FORCE
	$(DOCKER_BUILD) -t pymor/deploy_checks:$@ $@

push:
	$(DOCKER_PUSH) pymor/deploy_checks
