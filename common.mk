PYTHONS = 3.6 3.7 3.8
VER?=$(shell git log -1 --pretty=format:"%H")
NGSOLVE_IMAGE = pymor/ngsolve_py$1:$2
PETSC_IMAGE = pymor/petsc_py$1:$2
PYTHON_IMAGE = pymor/python_$1:$2
FENICS_IMAGE = pymor/fenics_py$1:$2
DEALII_IMAGE = pymor/dealii_py$1:$2
CIBASE_IMAGE = pymor/cibase_py$1:$2
TESTING_IMAGE = pymor/testing_py$1:$2
# DOCKER_BUILD=docker build --squash
DOCKER_BUILD=docker build --cache-from=$(call TESTING_IMAGE,$@,latest) --cache-from=$(call CIBASE_IMAGE,$@,latest) \
	--cache-from=$(call DEALII_IMAGE,$@,latest) --cache-from=$(call FENICS_IMAGE,$@,latest) \
	--cache-from=$(call PYTHON_IMAGE,$@,latest) --cache-from=$(call PETSC_IMAGE,$@,latest) \
	--cache-from=$(call NGSOLVE_IMAGE,$@,latest)
DOCKER_TAG=docker tag
DOCKER_PUSH=docker push
DOCKER_PULL=docker pull
PYTHON_TAG=$(VER)
PETSC_TAG=$(VER)

all: $(PYTHONS)

.PHONY: push IS_DIRTY

IS_DIRTY:
	git diff-index --quiet HEAD

push: $(addprefix push_,$(PYTHONS))
pull_latest: $(addprefix pull_latest_,$(PYTHONS))
