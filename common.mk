PYTHONS = 3.6 3.7 3.8
VER?=$(shell git log -1 --pretty=format:"%H")
NGSOLVE_IMAGE = pymor/ngsolve_py$1:$2
PETSC_IMAGE = pymor/petsc_py$1:$2
PYTHON_IMAGE = pymor/python_$1:$2
FENICS_IMAGE = pymor/fenics_py$1:$2
DEALII_IMAGE = pymor/dealii_py$1:$2
CIBASE_IMAGE = pymor/cibase_py$1:$2
TESTING_IMAGE = pymor/testing_py$1:$2
PYPI_MIRROR_STABLE_IMAGE = pymor/pypi-mirror_stable_py$1:$2
DOC_RELEASES_IMAGE = pymor/doc_releases:$1
# DOCKER_BUILD=docker build --squash
DOCKER_BUILD=docker build
DOCKER_TAG=docker tag
DOCKER_PUSH=docker push
DOCKER_PULL=docker pull
PYTHON_TAG=$(VER)
PETSC_TAG=$(VER)

all: $(PYTHONS)

.PHONY: push IS_DIRTY

IS_DIRTY:
	# diff-index sometimes produces false postives during docker build
	git diff-index --quiet HEAD || git update-index -q --really-refresh
	git diff-index --quiet HEAD

push: $(addprefix push_,$(PYTHONS))
pull_latest: $(addprefix pull_latest_,$(PYTHONS))
