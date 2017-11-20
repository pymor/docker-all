.PHONY: all wheel test images 2.7 3.5 3.6

PYMOR_BRANCH=origin/wheel_building

3.5: PYTHON_VERSION=3.5
3.5: wheel
3.5: test

3.6: PYTHON_VERSION=3.6
3.6: wheel
3.6: test

2.7: PYTHON_VERSION=2.7
2.7: wheel
2.7: test

wheel: images
	[ -d pymor ] || git clone --branch=$(PYMOR_BRANCH) https://github.com/pymor/pymor
	docker run --rm  -t -e LOCAL_USER_ID=$(shell id -u)  \
		-v ${PWD}:/io pymor/manylinux:py$(PYTHON_VERSION) /usr/local/bin/build-wheels.sh

test:
	# Install packages and test
	docker run --rm -t -e LOCAL_USER_ID=$(shell id -u)  \
		-v ${PWD}/wheelhouse:/io \
		pymor/wheeltester:py$(PYTHON_VERSION) wheeltester.bash

images:
	docker build --build-arg PYTHON_VERSION="$(PYTHON_VERSION)" \
		-t pymor/manylinux:py$(PYTHON_VERSION) builder_docker/
	make -C tester_docker $(PYTHON_VERSION)

push:
	docker push pymor/manylinux
	make -C tester_docker push
