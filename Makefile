VERSIONS:=3.6 3.7
IMAGES:=$(addprefix image, ${VERSIONS})
WHEELS:=$(addprefix wheel, ${VERSIONS})
TESTS:=$(addprefix test, ${VERSIONS})
PYMOR_BRANCH=wheel_building

all: images

# for implicit phony on wildcards
FORCE:

source:
	[ -d pymor ] || git clone --branch=$(PYMOR_BRANCH) https://github.com/pymor/pymor

${WHEELS}: wheel%: FORCE builder% source
	docker run --rm  -t -e LOCAL_USER_ID=$(shell id -u)  \
		-v ${PWD}:/io pymor/wheelbuilder:py$* /usr/local/bin/build-wheels.sh

${TESTS}: test%: FORCE tester% wheel%
	# Install packages and test
	docker run --rm -t -e LOCAL_USER_ID=$(shell id -u)  \
		-v ${PWD}/wheelhouse:/io \
		pymor/wheeltester:py$* wheeltester.bash

tester%: FORCE
	cd tester_docker && docker build --build-arg PYVER=$* \
		-t pymor/wheeltester:py$* .

builder%: FORCE
	cd builder_docker && docker build --build-arg PYTHON_VERSION="$*" \
		-t pymor/wheelbuilder:py$* .

${IMAGES}: image%: builder% tester%

images: ${IMAGES}

wheels: ${WHEELS}

tests: ${TESTS}

.PHONY: push
push:
	docker push pymor/wheelbuilder
	docker push pymor/wheeltester
