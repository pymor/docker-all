include ../common.mk
MYPYTHONS:=$(filter-out 3.9,$(PYTHONS))
IMAGES:=$(addprefix image, ${MYPYTHONS})
WHEELS:=$(addprefix wheel, ${MYPYTHONS})
TESTS:=$(addprefix test, ${MYPYTHONS})
PYMOR_BRANCH=master

all: images

# for implicit phony on wildcards
FORCE:

IMAGE_NAME:=WHEELBUILDER_IMAGE

$(PYTHONS): IS_DIRTY
	for ml in 1 2010 2014 ; do \
		docker build --build-arg PYTHON_VERSION=$@ \
			-t $(call $(IMAGE_NAME),$@,$(VER),$${ml}) manylinux$${ml}_builder && \
			$(DOCKER_TAG) $(call $(IMAGE_NAME),$@,$(VER),$${ml}) $(call $(IMAGE_NAME),$@,latest,$${ml}) ; \
		done

source:
	[ -d pymor ] || git clone --branch=$(PYMOR_BRANCH) https://github.com/pymor/pymor

${WHEELS}: wheel%: FORCE $(PYTHONS) source
	for ml in 1 2010 2014 ; do \
		docker run --rm  -t -e LOCAL_USER_ID=$(shell id -u)  \
			-v ${PWD}:/io $(call $(IMAGE_NAME),$*,$(VER),${ml}) /usr/local/bin/build-wheels.sh ; \
	done

${TESTS}: test%: FORCE tester% wheel%
	# Install packages and test
	docker run --rm -t -e LOCAL_USER_ID=$(shell id -u)  \
		-v ${PWD}/wheelhouse:/io \
		pymor/wheeltester:py$* wheeltester.bash

tester%: FORCE
	cd tester_docker && docker build --build-arg PYVER=$* \
		-t pymor/wheeltester:py$* .

${IMAGES}: image%: manylinux1_builder% manylinux2010_builder% manylinux2014_builder% tester%

images: ${IMAGES}

wheels: ${WHEELS}

tests: ${TESTS}

push_%:
	for ml in 1 2010 2014 ; do \
		$(DOCKER_PUSH) $(call $(IMAGE_NAME),$*,$(VER),$${ml}) && \
		$(DOCKER_PUSH) $(call $(IMAGE_NAME),$*,latest,$${ml}) ; \
	done
