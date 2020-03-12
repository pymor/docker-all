include ../common.mk
WHEELS:=$(addprefix wheel, $(filter-out 3.9,$(PYTHONS)))
PYMOR_BRANCH=master

IMAGE_NAME:=WHEELBUILDER_IMAGE
MANYLINUXS=2010 2014

$(PYTHONS): IS_DIRTY
	for ml in $(MANYLINUXS); do \
		docker build --build-arg PYTHON_VERSION=$@ --build-arg VER=$(VER) \
			-t $(call $(IMAGE_NAME),$@,$(VER),$${ml}) manylinux$${ml}_builder && \
			$(DOCKER_TAG) $(call $(IMAGE_NAME),$@,$(VER),$${ml}) $(call $(IMAGE_NAME),$@,latest,$${ml}) ; \
		done

source:
	[ -d pymor ] || git clone --branch=$(PYMOR_BRANCH) https://github.com/pymor/pymor

${WHEELS}: wheel%: FORCE $(PYTHONS) source
	for ml in $(MANYLINUXS); do \
		docker run --rm  -t -e LOCAL_USER_ID=$(shell id -u)  \
			-v ${PWD}:/io $(call $(IMAGE_NAME),$*,$(VER),${ml}) /usr/local/bin/build-wheels.sh ; \
	done

wheels: ${WHEELS}

push_%:
	for ml in 1 2010 2014 ; do \
		$(DOCKER_PUSH) $(call $(IMAGE_NAME),$*,$(VER),$${ml}) && \
		$(DOCKER_PUSH) $(call $(IMAGE_NAME),$*,latest,$${ml}) ; \
	done
