PYTHONS = 3.6 3.7 3.8
NGSOLVE_VERSION=v6.2.1905
VER=$(shell git log -1 --pretty=format:"%H")
PYTHON_TAG=latest
PETSC_TAG=latest

all: $(PYTHONS)

.PHONY: push IS_DIRTY

IS_DIRTY:
	git diff-index --quiet HEAD

$(PYTHONS): IS_DIRTY
	docker build --build-arg PETSC_BASE=pymor/petsc_py$@:$(PETSC_TAG) \
	  --build-arg PYTHON_BASE=pymor/python_$@:$(PYTHON_TAG) \
		--build-arg NGSOLVE_VERSION=$(NGSOLVE_VERSION) \
		-t pymor/ngsolve_$(NGSOLVE_VERSION)_py$@:$(VER) docker
	docker tag pymor/ngsolve_$(NGSOLVE_VERSION)_py$@:$(VER) pymor/ngsolve_$(NGSOLVE_VERSION)_py$@:latest

push_%:
	docker push pymor/ngsolve_$(NGSOLVE_VERSION)_py$*:$(VER)

push: $(addprefix push_,$(PYTHONS))
