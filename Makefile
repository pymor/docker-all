# these target needs to be used instead of the one in common.mk

all: $(filter-out 3.9,$(PYTHONS)) docker-in-docker

push_%: FORCE
	$(MAKE) PY=$* push_jupyter push_docker-in-docker

include common.mk
.PHONY: FORCE

PY=3.7

FORCE:

$(PYTHONS): FORCE
	$(MAKE) PY=$@ jupyter

docker-in-docker: FORCE
	$(MAKE) -C docker-in-docker

pypi-mirror: FORCE testing
	$(MAKE) -C pypi-mirror $(PY)

cibase: FORCE ngsolve fenics dealii pypi-mirror
	$(MAKE) -C cibase $(PY)

testing: FORCE cibase
	$(MAKE) -C testing $(PY)

python: FORCE
	$(MAKE) -C python $(PY)

dealii: FORCE python
	$(MAKE) -C deal.II $(PY)

petsc: FORCE python
	$(MAKE) -C petsc $(PY)

fenics: FORCE petsc
	$(MAKE) -C fenics $(PY)

ngsolve: FORCE petsc
	$(MAKE) -C ngsolve $(PY)

demo: FORCE testing
	$(MAKE) -C demo

jupyter: FORCE testing
	$(MAKE) -C jupyter $(PY)

deploy_checks: FORCE
	$(MAKE) -C deploy_checks

push_pypi-mirror: FORCE
	$(MAKE) -C pypi-mirror push_$(PY)

push_python: FORCE
	$(MAKE) -C python push_$(PY)

push_dealii: FORCE push_python
	$(MAKE) -C deal.II push_$(PY)

push_petsc: FORCE push_python
	$(MAKE) -C petsc push_$(PY)

push_fenics: FORCE push_petsc
	$(MAKE) -C fenics push_$(PY)

push_ngsolve: FORCE push_python
	$(MAKE) -C ngsolve push_$(PY)

push_cibase: FORCE push_ngsolve push_fenics push_dealii push_pypi-mirror
	$(MAKE) -C cibase push_$(PY)

push_docker-in-docker: FORCE
	$(MAKE) -C docker-in-docker push

push_testing: FORCE push_cibase
	$(MAKE) -C testing push_$(PY)

push_jupyter: FORCE push_testing
	$(MAKE) -C jupyter push_$(PY)


pull_latest_%: FORCE
	$(MAKE) -C testing pull_latest_$*

pull_all_latest_%: FORCE
	$(DOCKER_PULL) $(call TESTING_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call CIBASE_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call DEALII_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call FENICS_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call PYTHON_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call PETSC_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call NGSOLVE_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call PYPI_MIRROR_IMAGE,$*,latest,stable)
	$(DOCKER_PULL) $(call PYPI_MIRROR_IMAGE,$*,latest,oldest)
	$(DOCKER_PULL) $(call JUPYTER_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call DIND_IMAGE,latest)
