PYTHONS = 3.6 3.7 3.8 3.9
VER?=$(shell git log -1 --pretty=format:"%H")
NGSOLVE_IMAGE = pymor/ngsolve_py$1:$2
PETSC_IMAGE = pymor/petsc_py$1:$2
PYTHON_IMAGE = pymor/python_$1:$2
FENICS_IMAGE = pymor/fenics_py$1:$2
DEALII_IMAGE = pymor/dealii_py$1:$2
CIBASE_IMAGE = pymor/cibase_py$1:$2
DIND_IMAGE = pymor/docker-in-docker:$2
TESTING_IMAGE = pymor/testing_py$1:$2
PYPI_MIRROR_IMAGE = pymor/pypi-mirror_$3_py$1:$2
DOC_RELEASES_IMAGE = pymor/doc_releases:$2
JUPYTER_IMAGE = pymor/jupyter_py$1:$2
# DOCKER_BUILD=docker build --squash
DOCKER_BUILD=docker build
DOCKER_TAG=docker tag
DOCKER_PUSH=docker push
DOCKER_PULL=docker pull
DOCKER_RUN=docker run  -it
PYTHON_TAG=$(VER)
PETSC_TAG=$(VER)

all: $(filter-out 3.9,$(PYTHONS))

.PHONY: push IS_DIRTY

# diff-index sometimes produces false postives during docker build
# but if there's still a diff, we want to see it and _still_ fail the target
IS_DIRTY:
	git diff-index --quiet HEAD || \
	(git update-index -q --really-refresh && git diff --no-ext-diff --quiet --exit-code) || \
	(git diff --no-ext-diff ; exit 1)

push: $(addprefix push_,$(filter-out 3.9,$(PYTHONS)))
pull_latest: $(addprefix pull_latest_,$(filter-out 3.9,$(PYTHONS)))

push_%:
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),$*,$(VER))
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),$*,latest)

pull_latest_%:
	docker pull $(call $(IMAGE_NAME),$*,latest)

run_%:
	$(DOCKER_RUN) $(call $(IMAGE_NAME),$*,$(VER))
