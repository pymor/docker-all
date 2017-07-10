.PHONY: all wheel docker 2.7 3.4 3.5

BRANCH=origin/py3_debs

3.5: REV=3.5
3.5: PYVER=cp35-cp35m
3.5: wheel

3.4: REV=3.4
3.4: PYVER=cp34-cp34m
3.4: wheel

2.7: REV=2.7
2.7: PYVER=cp27-cp27mu
2.7: wheel

wheel: docker
	[ -d pymor ] || git clone https://github.com/pymor/pymor
	cd pymor && git fetch && git reset --hard $(BRANCH) && cd -
	docker run --rm -t -v ${PWD}:/io -e PYVER="$(PYVER)" pymor/manylinux:latest /usr/local/bin/build-wheels.sh
	ls ${PWD}/wheelhouse/
	# Install packages and test
	docker run --rm -t -v ${PWD}/wheelhouse:/io -e REV=$(REV) -e PYVER=$(PYVER) pymor/wheeltester:$(REV) wheeltester.bash

docker:
	docker build -t pymor/manylinux:latest builder_docker/
	make -C tester_docker $(REV)

push: docker
	make -C tester_docker push
