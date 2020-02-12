PYTHONS = 3.6 3.7 3.8

VER=$(shell git log -1 --pretty=format:"%H")
PETSC_TAG=latest

all: $(PYTHONS)

.PHONY: push IS_DIRTY

IS_DIRTY:
	git diff-index --quiet HEAD

$(PYTHONS): IS_DIRTY
	docker build --build-arg PETSC=pymor/petsc_py$@:$(PETSC_TAG) \
		-t pymor/fenics_py$@:$(VER) docker
	docker tag pymor/fenics_py$@:$(VER) pymor/fenics_py$@:latest

push_%:
	docker push pymor/fenics_py$*

push: $(addprefix push_,$(PYTHONS))
