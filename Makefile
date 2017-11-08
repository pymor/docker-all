.PHONY: all wheel images 2.7 3.5 3.6

PYMOR_BRANCH=origin/wheel_building

3.5: REV=3.5
3.5: PYVER=cp35-cp35m
3.5: wheel
3.5: test

3.6: REV=3.6
3.6: PYVER=cp36-cp36m
3.6: wheel
3.6: test

2.7: REV=2.7
2.7: PYVER=cp27-cp27mu
2.7: wheel
2.7: test

wheel: images
	[ -d pymor ] || git clone --branch=$(PYMOR_BRANCH) https://github.com/pymor/pymor
	docker run --rm  -t -e LOCAL_USER_ID=$(shell id -u)  \
		-v ${PWD}:/io pymor/manylinux:py$(REV) /usr/local/bin/build-wheels.sh

test:
	# Install packages and test
	docker run --rm -t -e LOCAL_USER_ID=$(shell id -u)  \
		-v ${PWD}/wheelhouse:/io \
		pymor/wheeltester:py$(REV) wheeltester.bash

images:
	docker build --build-arg PYVER="$(PYVER)" \
		-t pymor/manylinux:py$(REV) builder_docker/
	make -C tester_docker $(REV)

push:
	docker push pymor/manylinux
	make -C tester_docker push
