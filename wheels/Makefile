include ../common.mk
MYPYTHONS:=$(filter-out 3.9,$(PYTHONS))
IMAGES:=$(addprefix image, ${MYPYTHONS})
WHEELS:=$(addprefix wheel, ${MYPYTHONS})
TESTS:=$(addprefix test, ${MYPYTHONS})
PYMOR_BRANCH=master

all: images

# for implicit phony on wildcards
FORCE:

IMAGE_NAME:=$(WHEELBUILDER_IMAGE)

$(PYTHONS): IS_DIRTY image$*
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$@,$(VER)) $(call $(IMAGE_NAME),$@,latest)


source:
	[ -d pymor ] || git clone --branch=$(PYMOR_BRANCH) https://github.com/pymor/pymor

${WHEELS}: wheel%: FORCE manylinux1_builder% manylinux2010_builder% manylinux2014_builder% source
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

manylinux2014_builder%: FORCE
	cd manylinux2014_builder && docker build --build-arg PYTHON_VERSION="$*" \
		-t $(call $(IMAGE_NAME),$*,$(VER),2014) .

manylinux2010_builder%: FORCE
	cd manylinux2010_builder && docker build --build-arg PYTHON_VERSION="$*" \
		-t $(call $(IMAGE_NAME),$*,$(VER),2010) .

manylinux1_builder%: FORCE
	cd manylinux1_builder && docker build --build-arg PYTHON_VERSION="$*" \
		-t $(call $(IMAGE_NAME),$*,$(VER),1) .

${IMAGES}: image%: manylinux1_builder% manylinux2010_builder% manylinux2014_builder% tester%

images: ${IMAGES}

wheels: ${WHEELS}

tests: ${TESTS}

.PHONY: push
push:
	docker push pymor/wheelbuilder
	docker push pymor/wheeltester
