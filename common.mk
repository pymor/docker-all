PYTHONS = 3.6 3.7 3.8
VER?=$(shell git log -1 --pretty=format:"%H")
NGSOLVE_IMAGE = pymor/ngsolve_py$1:$2
PETSC_IMAGE = pymor/petsc_py$1:$2
PYTHON_IMAGE = pymor/python_$1:$2
FENICS_IMAGE = pymor/fenics_py$1:$2
DEALII_IMAGE = pymor/dealii_py$1:$2
CIBASE_IMAGE = pymor/cibase_py$1:$2
TESTING_IMAGE = pymor/testing_py$1:$2
DOCKER_BUILD=docker build --squash
PYTHON_TAG=$(VER)
PETSC_TAG=$(VER)

all: $(PYTHONS)

.PHONY: push IS_DIRTY

IS_DIRTY:
	git diff-index --quiet HEAD

push: $(addprefix push_,$(PYTHONS))
pull_latest: $(addprefix pull_latest_,$(PYTHONS))
