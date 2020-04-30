include common.mk

SUBDIRS = $(patsubst %/,%,$(sort $(dir $(wildcard */))))
PY_INDEPENDENT = demo deploy_checks docker-in-docker docs ci_sanity
PY_SUBDIRS = $(filter-out $(PY_INDEPENDENT),$(SUBDIRS))
EXCLUDE_FROM_ALL = pypi-mirror_test docs
PUSH_PYTHON_SUBDIRS = $(addprefix push_,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_SUBDIRS)))
CLEAN_PYTHON_SUBDIRS = $(addprefix clean_,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_SUBDIRS)))
PUSH_PYTHON_VERSIONS = $(addprefix push_,$(PYTHONS))
PUSH = $(addprefix push_,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_INDEPENDENT)))
CLEAN = $(addprefix clean_,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_INDEPENDENT)))
DEPLOY_CHECKS = $(addprefix deploy_checks_,$(DISTROS))
IMAGE_TARGETS=tag real rp run cl
DEMOS = $(addprefix demo_,$(DEMO_TAGS))

all: FORCE $(foreach subd,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_SUBDIRS)),$(addprefix $(subd)_,$(filter-out 3.9,$(PYTHONS)))) $(filter-out $(EXCLUDE_FROM_ALL),$(PY_INDEPENDENT))

$(PY_SUBDIRS): % : $(addprefix %_,$(filter-out 3.9,$(PYTHONS)))

push: $(PUSH_PYTHON_SUBDIRS) $(PUSH)
clean: $(CLEAN_PYTHON_SUBDIRS) $(CLEAN)

$(CLEAN_PYTHON_SUBDIRS): % : $(addprefix %_,$(filter-out 3.9,$(PYTHONS)))

$(PUSH_PYTHON_SUBDIRS): % : $(addprefix %_,$(filter-out 3.9,$(PYTHONS)))

$(PYTHONS): % : $(addsuffix _%,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_SUBDIRS)))

$(PUSH_PYTHON_VERSIONS): push_% : $(addsuffix _%,$(addprefix push_,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_SUBDIRS))))
IS_DIRTY:
	git diff-index --quiet HEAD || \
	(git update-index -q --really-refresh && git diff --no-ext-diff --quiet --exit-code) || \
	(git diff --no-ext-diff ; exit 1)

.PHONY: FORCE IS_DIRTY

# FORCE: IS_DIRTY
FORCE:

# build+tag meta pattern for all SUBDIR_PY
$(foreach subd,$(PY_SUBDIRS),$(addprefix $(subd)_,$(PYTHONS))): % : real_% tag_%
$(foreach subd,$(PY_SUBDIRS),$(addprefix tag_$(subd)_,$(PYTHONS))): tag_% : real_%
$(foreach subd,$(PY_SUBDIRS),$(addprefix push_$(subd)_,$(PYTHONS))): push_% : rp_%
$(foreach subd,$(PY_SUBDIRS),$(addprefix clean_$(subd)_,$(PYTHONS))): clean_% : cl_%

# the actual IMAGE_NAME is set via target variable from tag_subdir% rules
tag_% : FORCE
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),$(VER)) $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),latest)

cl_% : FORCE
	for img in $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),)) ; \
		do $(DOCKER_RMI) $${img} ; done

rp_% : FORCE
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),$(VER))
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),latest)

run_%: %
	$(DOCKER_RUN) --entrypoint=/bin/bash $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),$(VER))

pymor_source:
	test -d pymor_source || git clone --branch=$(PYMOR_BRANCH) https://github.com/pymor/pymor pymor_source

docker-in-docker push_docker-in-docker clean_docker-in-docker: IMAGE_NAME:=DIND_IMAGE
docker-in-docker: FORCE
	$(DOCKER_BUILD) -t $(call $(IMAGE_NAME),dummy,$(VER)) docker-in-docker
	$(DOCKER_TAG) $(call $(IMAGE_NAME),dummy,$(VER)) $(call $(IMAGE_NAME),dummy,latest)
push_docker-in-docker: FORCE
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),dummy,$(VER))
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),dummy,latest)
clean_docker-in-docker: FORCE
	for img in $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep $(call $(IMAGE_NAME),dummy,)) ; \
		do $(DOCKER_RMI) $${img} ; done


$(addsuffix _wheelbuilder_manylinux1_%,$(IMAGE_TARGETS)): IMAGE_NAME:=WB1_IMAGE
real_wheelbuilder_manylinux1_%: FORCE pull_testing_% pypi-mirror_stable_% pypi-mirror_oldest_%
	$(DOCKER_BUILD) --build-arg PYTHON_VERSION=$* --build-arg VER=$(VER) \
			-t $(call $(IMAGE_NAME),$*,$(VER)) wheelbuilder_manylinux1

$(addsuffix _wheelbuilder_manylinux2010_%,$(IMAGE_TARGETS)): IMAGE_NAME:=WB2010_IMAGE
real_wheelbuilder_manylinux2010_%: FORCE pull_testing_% pypi-mirror_stable_% pypi-mirror_oldest_%
	$(DOCKER_BUILD) --build-arg PYTHON_VERSION=$* --build-arg VER=$(VER) \
			-t $(call $(IMAGE_NAME),$*,$(VER)) wheelbuilder_manylinux2010

$(addsuffix _wheelbuilder_manylinux2014_%,$(IMAGE_TARGETS)): IMAGE_NAME:=WB2014_IMAGE
real_wheelbuilder_manylinux2014_%: FORCE pull_testing_% pypi-mirror_stable_% pypi-mirror_oldest_%
	$(DOCKER_BUILD) --build-arg PYTHON_VERSION=$* --build-arg VER=$(VER) \
			-t $(call $(IMAGE_NAME),$*,$(VER)) wheelbuilder_manylinux2014

$(addsuffix _constraints_%,$(IMAGE_TARGETS)): IMAGE_NAME:=CONSTRAINTS_IMAGE
real_constraints_%: FORCE ensure_testing_%
	$(DOCKER_BUILD) --build-arg BASE=pymor/testing_py$*:latest \
		-t $(call $(IMAGE_NAME),$*,$(VER)) constraints

$(addsuffix _pypi-mirror_stable_%,$(IMAGE_TARGETS)): IMAGE_NAME:=PYPI_MIRROR_STABLE_IMAGE
real_pypi-mirror_stable_%: FORCE constraints_%
	$(DOCKER_BUILD) --build-arg PYVER=$* --build-arg VER=$(VER) \
		-t $(call $(IMAGE_NAME),$*,$(VER)) pypi-mirror_stable

$(addsuffix _pypi-mirror_oldest_%,$(IMAGE_TARGETS)): IMAGE_NAME:=PYPI_MIRROR_OLDEST_IMAGE
real_pypi-mirror_oldest_%: FORCE constraints_%
	$(DOCKER_BUILD) --build-arg PYVER=$* --build-arg VER=$(VER) \
		-t $(call $(IMAGE_NAME),$*,$(VER)) pypi-mirror_oldest

$(addsuffix _pypi-mirror_test_%,$(IMAGE_TARGETS)): IMAGE_NAME:=MIRROR_TEST_IMAGE
real_pypi-mirror_test_%: pypi-mirror_stable_% pypi-mirror_oldest_% pymor_source
	VARIANT=stable PYPI_MIRROR_TAG=$(VER) CI_IMAGE_TAG=$(VER) DOCKER_BASE_PYTHON=$* docker-compose -f mirror-test.docker-compose.yml up --build test
	VARIANT=oldest PYPI_MIRROR_TAG=$(VER) CI_IMAGE_TAG=$(VER) DOCKER_BASE_PYTHON=$* docker-compose -f mirror-test.docker-compose.yml up --build test

$(addsuffix _cibase_%,$(IMAGE_TARGETS)): IMAGE_NAME:=CIBASE_IMAGE
real_cibase_%: FORCE ngsolve_% fenics_% dealii_%
	$(DOCKER_BUILD) --build-arg PYVER=$* \
		-t $(call $(IMAGE_NAME),$*,$(VER)) cibase/buster

$(addsuffix _testing_%,$(IMAGE_TARGETS)) ensure_testing_%: IMAGE_NAME=TESTING_IMAGE
real_testing_%: FORCE cibase_%
	$(DOCKER_BUILD) --build-arg BASETAG=$(VER) \
			-t $(call $(IMAGE_NAME),$*,$(VER)) testing/$*
ensure_testing_%:
	$(DOCKER_INSPECT) $(call $(IMAGE_NAME),$*,latest) >/dev/null 2>&1 || $(DOCKER_PULL) $(call $(IMAGE_NAME),$*,latest)

$(addsuffix _python_%,$(IMAGE_TARGETS)): IMAGE_NAME=PYTHON_IMAGE
real_python_%: FORCE
	$(DOCKER_BUILD) -t $(call $(IMAGE_NAME),$*,$(VER)) python/$*/buster/slim

$(addsuffix _dealii_%,$(IMAGE_TARGETS)): IMAGE_NAME:=DEALII_IMAGE
real_dealii_%: FORCE python_%
	$(DOCKER_BUILD) --build-arg BASE=$(call PYTHON_IMAGE,$*,$(VER)) \
			-t $(call $(IMAGE_NAME),$*,$(VER)) dealii/docker

$(addsuffix _petsc_%,$(IMAGE_TARGETS)): IMAGE_NAME:=PETSC_IMAGE
real_petsc_%: FORCE python_%
	$(DOCKER_BUILD) --build-arg BASE=$(call PYTHON_IMAGE,$*,$(VER)) \
		-t $(call $(IMAGE_NAME),$*,$(VER)) petsc/docker

$(addsuffix _fenics_%,$(IMAGE_TARGETS)): IMAGE_NAME:=FENICS_IMAGE
real_fenics_%: FORCE petsc_%
	$(DOCKER_BUILD) --build-arg PETSC=$(call PETSC_IMAGE,$*,$(PETSC_TAG)) \
		-t $(call $(IMAGE_NAME),$*,$(VER)) fenics/docker

$(addsuffix _ngsolve_%,$(IMAGE_TARGETS)): IMAGE_NAME:=NGSOLVE_IMAGE
real_ngsolve_%: FORCE petsc_%
	$(DOCKER_BUILD) --build-arg PETSC_BASE=pymor/petsc_py$*:$(VER) \
		--build-arg PYTHON_BASE=pymor/python_$*:$(VER) \
		--build-arg NGSOLVE_VERSION=$(NGSOLVE_VERSION) \
		-t $(call $(IMAGE_NAME),$*,$(VER)) ngsolve/docker

$(addsuffix _jupyter_%,$(IMAGE_TARGETS)): IMAGE_NAME:=JUPYTER_IMAGE
real_jupyter_%: FORCE testing_% pypi-mirror_stable_%
	$(DOCKER_BUILD) --build-arg PYVER=$* --build-arg VERTAG=$(VER) \
		-t $(call $(IMAGE_NAME),$*,$(VER)) jupyter

$(DEMOS): demo_% : IS_DIRTY
	$(DOCKER_BUILD) -t pymor/demo:$* demo/$*
demo: FORCE testing_3.7 $(DEMOS)

clean_demo: $(addprefix clean_,$(DEMOS))
push_demo: $(addprefix push_,$(DEMOS))
push_demo_%:
	$(DOCKER_PUSH) pymor/demo:$*
clean_demo_%:
	$(DOCKER_RMI) pymor/demo:$*

ci_sanity: FORCE
	$(DOCKER_BUILD) -t pymor/ci_sanity:$(VER) ci_sanity

push_ci_sanity:
	$(DOCKER_PUSH) pymor/ci_sanity:$(VER)

clean_deploy_checks: $(addprefix clean_,$(DEPLOY_CHECKS))
deploy_checks: $(DEPLOY_CHECKS)
$(DEPLOY_CHECKS): deploy_checks_% : FORCE
	$(DOCKER_BUILD) -t pymor/deploy_checks:$@ deploy_checks/$*
$(addprefix clean_,$(DEPLOY_CHECKS)): clean_deploy_checks_% : FORCE
	$(DOCKER_RMI) pymor/deploy_checks:$@

push_deploy_checks:
	$(DOCKER_PUSH) pymor/deploy_checks

pull_testing_%: FORCE
	$(DOCKER_PULL) $(call TESTING_IMAGE,$*,latest)

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
	$(DOCKER_PULL) $(call PYPI_MIRROR_OLDEST_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call PYPI_MIRROR_STABLE_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call JUPYTER_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call CONSTRAINTS_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call JUPYTER_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call JUPYTER_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call DIND_IMAGE,dummy,latest)
	$(DOCKER_PULL) $(call WB2010_IMAGE,$*,latest)
	$(DOCKER_PULL) $(call WB2014_IMAGE,$*,latest)
