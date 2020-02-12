PYTHONS = 3.6 3.7 3.8
VER=$(shell git log -1 --pretty=format:"%H")
PYTHON_TAG=latest

all: $(PYTHONS)

.PHONY: push IS_DIRTY

IS_DIRTY:
	git diff-index --quiet HEAD

$(PYTHONS): IS_DIRTY
	docker build --build-arg BASE=pymor/python_$@:$(PYTHON_TAG) \
		-t pymor/petsc_py$@:$(VER) docker/
	docker tag pymor/petsc_py$@:$(VER) pymor/petsc_py$@:latest

push:
	for PY in $(PYTHONS) ; do \
		docker push pymor/petsc_py$${PY} ; \
	done
