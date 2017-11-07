.PHONY: all wheel images 2.7 3.6 3.5 3.7-rc

BRANCH=origin/master

3.5: REV=3.5
3.5: PYVER=cp35-cp35m
3.5: wheel

3.6: REV=3.6
3.6: PYVER=cp36-cp36m
3.6: wheel

2.7: REV=2.7
2.7: PYVER=cp27-cp27mu
2.7: wheel

wheel: images
	[ -d pymor ] || git clone https://github.com/pymor/pymor
	docker run --rm -t -e LOCAL_USER_ID=$(shell id -u) -e PYVER="$(PYVER)" \
		-v ${PWD}:/io pymor/manylinux:latest /usr/local/bin/build-wheels.sh
	ls ${PWD}/wheelhouse/
	# Install packages and test
	docker run --rm -t -e LOCAL_USER_ID=$(shell id -u) -e PYVER="$(PYVER)" \
		-v ${PWD}/wheelhouse:/io -e REV=$(REV) \
		pymor/wheeltester:py$(REV) wheeltester.bash

images:
	docker build -t pymor/manylinux:latest builder_docker/
	make -C tester_docker $(REV)

push: images
	make -C tester_docker push
