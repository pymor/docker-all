include common.mk

SUBDIRS = $(patsubst %/,%,$(sort $(dir $(wildcard */))))
PY_INDEPENDENT = demo deploy_checks docker-in-docker docs
PY_SUBDIRS = $(filter-out $(PY_INDEPENDENT),$(SUBDIRS))
EXCLUDE_FROM_ALL = pypi-mirror_test wheelbuilder_manylinux1
PYPUSH = $(addprefix push_,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_SUBDIRS)))
PUSH = $(addprefix push_,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_INDEPENDENT)))
DEPLOY_CHECKS = $(addprefix deploy_checks_,$(DISTROS))

all: FORCE $(foreach subd,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_SUBDIRS)),$(addprefix $(subd)_,$(filter-out 3.9,$(PYTHONS)))) $(filter-out $(EXCLUDE_FROM_ALL),$(PY_INDEPENDENT))

$(PY_SUBDIRS): % : $(addprefix %_,$(filter-out 3.9,$(PYTHONS)))

push: $(PYPUSH) $(PUSH)

$(PYPUSH): % : $(addprefix %_,$(filter-out 3.9,$(PYTHONS)))

$(PYTHONS): % : $(addsuffix _%,$(PY_SUBDIRS))

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

# the actual IMAGE_NAME is set via target variable from tag_subdir% rules
tag_% : FORCE
	$(DOCKER_TAG) $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),$(VER)) $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),latest)

rp_% : FORCE
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),$(VER))
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),latest)

pymor_source:
	test -d pymor_source || git clone --branch=$(PYMOR_BRANCH) https://github.com/pymor/pymor pymor_source

docker-in-docker push_docker-in-docker: IMAGE_NAME:=DIND_IMAGE
docker-in-docker: FORCE
	$(DOCKER_BUILD) -t $(call $(IMAGE_NAME),dummy,$(VER)) docker-in-docker
	$(DOCKER_TAG) $(call $(IMAGE_NAME),dummy,$(VER)) $(call $(IMAGE_NAME),dummy,latest)
push_docker-in-docker: FORCE
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),dummy,$(VER))
	$(DOCKER_PUSH) $(call $(IMAGE_NAME),dummy,latest)

tag_wheelbuilder_manylinux1_% real_wheelbuilder_manylinux1_% rp_wheelbuilder_manylinux1_%: IMAGE_NAME:=WB1_IMAGE
real_wheelbuilder_manylinux1_%: FORCE pull_testing_% pypi-mirror_stable_% pypi-mirror_oldest_%
	$(DOCKER_BUILD) --build-arg PYTHON_VERSION=$* --build-arg VER=$(VER) \
			-t $(call $(IMAGE_NAME),$*,$(VER)) wheelbuilder_manylinux1

tag_wheelbuilder_manylinux2010_% real_wheelbuilder_manylinux2010_% rp_wheelbuilder_manylinux2010_%: IMAGE_NAME:=WB2010_IMAGE
real_wheelbuilder_manylinux2010_%: FORCE pull_testing_% pypi-mirror_stable_% pypi-mirror_oldest_%
	$(DOCKER_BUILD) --build-arg PYTHON_VERSION=$* --build-arg VER=$(VER) \
			-t $(call $(IMAGE_NAME),$*,$(VER)) wheelbuilder_manylinux2010

tag_wheelbuilder_manylinux2014_% real_wheelbuilder_manylinux2014_% rp_wheelbuilder_manylinux2014_%: IMAGE_NAME:=WB2014_IMAGE
real_wheelbuilder_manylinux2014_%: FORCE pull_testing_% pypi-mirror_stable_% pypi-mirror_oldest_%
	$(DOCKER_BUILD) --build-arg PYTHON_VERSION=$* --build-arg VER=$(VER) \
			-t $(call $(IMAGE_NAME),$*,$(VER)) wheelbuilder_manylinux2014

tag_constraints_% real_constraints_% rp_constraints_%: IMAGE_NAME:=CONSTRAINTS_IMAGE
real_constraints_%: FORCE pull_testing_%
	$(DOCKER_BUILD) --build-arg BASE=pymor/testing_py$*:latest \
		-t $(call $(IMAGE_NAME),$*,$(VER)) constraints

tag_pypi-mirror_stable_% real_pypi-mirror_stable_% rp_pypi-mirror_stable_%: IMAGE_NAME:=PYPI_MIRROR_STABLE_IMAGE
real_pypi-mirror_stable_%: FORCE constraints_%
	$(DOCKER_BUILD) --build-arg PYVER=$* --build-arg VER=$(VER) \
		-t $(call $(IMAGE_NAME),$*,$(VER)) pypi-mirror_stable

tag_pypi-mirror_oldest_% real_pypi-mirror_oldest_% rp_pypi-mirror_oldest_%: IMAGE_NAME:=PYPI_MIRROR_OLDEST_IMAGE
real_pypi-mirror_oldest_%: FORCE constraints_%
	$(DOCKER_BUILD) --build-arg PYVER=$* --build-arg VER=$(VER) \
		-t $(call $(IMAGE_NAME),$*,$(VER)) pypi-mirror_oldest

tag_pypi-mirror_test_% real_pypi-mirror_test_% rp_pypi-mirror_test_%: IMAGE_NAME:=MIRROR_TEST_IMAGE
real_pypi-mirror_test_%: pypi-mirror_stable_% pypi-mirror_oldest_% pymor_source
	VARIANT=stable PYPI_MIRROR_TAG=$(VER) CI_IMAGE_TAG=$(VER) DOCKER_BASE_PYTHON=$* docker-compose -f mirror-test.docker-compose.yml up --build test
	VARIANT=oldest PYPI_MIRROR_TAG=$(VER) CI_IMAGE_TAG=$(VER) DOCKER_BASE_PYTHON=$* docker-compose -f mirror-test.docker-compose.yml up --build test

tag_cibase_% real_cibase_% rp_cibase_%: IMAGE_NAME:=CIBASE_IMAGE
real_cibase_%: FORCE ngsolve_% fenics_% dealii_%
	$(DOCKER_BUILD) --build-arg PYVER=$* \
		-t $(call $(IMAGE_NAME),$*,$(VER)) cibase/buster

tag_testing_% real_testing_% rp_testing_%: IMAGE_NAME=TESTING_IMAGE
real_testing_%: FORCE cibase_%
	$(DOCKER_BUILD) --build-arg BASETAG=$(VER) \
			-t $(call $(IMAGE_NAME),$*,$(VER)) testing/$*

tag_python_% real_python_% rp_python_%: IMAGE_NAME=PYTHON_IMAGE
real_python_%: FORCE
	$(DOCKER_BUILD) -t $(call $(IMAGE_NAME),$*,$(VER)) python/$*/buster/slim

tag_dealii_% real_dealii_% rp_dealii_%: IMAGE_NAME:=DEALII_IMAGE
real_dealii_%: FORCE python_%
	$(DOCKER_BUILD) --build-arg BASE=$(call PYTHON_IMAGE,$*,$(VER)) \
			-t $(call $(IMAGE_NAME),$*,$(VER)) dealii/docker

tag_petsc_% real_petsc_% rp_petsc_%: IMAGE_NAME:=PETSC_IMAGE
real_petsc_%: FORCE python_%
	$(DOCKER_BUILD) --build-arg BASE=$(call PYTHON_IMAGE,$*,$(VER)) \
		-t $(call $(IMAGE_NAME),$*,$(VER)) petsc/docker

tag_fenics_% real_fenics_% rp_fenics_%: IMAGE_NAME:=FENICS_IMAGE
real_fenics_%: FORCE petsc_%
	$(DOCKER_BUILD) --build-arg PETSC=$(call PETSC_IMAGE,$*,$(PETSC_TAG)) \
		-t $(call $(IMAGE_NAME),$*,$(VER)) fenics/docker

tag_ngsolve_% real_ngsolve_% rp_ngsolve_%: IMAGE_NAME:=NGSOLVE_IMAGE
real_ngsolve_%: FORCE petsc_%
	$(DOCKER_BUILD) --build-arg PETSC_BASE=pymor/petsc_py$*:$(VER) \
		--build-arg PYTHON_BASE=pymor/python_$*:$(VER) \
		--build-arg NGSOLVE_VERSION=$(NGSOLVE_VERSION) \
		-t $(call $(IMAGE_NAME),$*,$(VER)) ngsolve/docker

$(DEMO_TAGS): IS_DIRTY
	$(DOCKER_BUILD) -t pymor/demo:$@ demo/$@
demo: FORCE testing_3.7 $(DEMO_TAGS)

push_demo: $(addprefix push_demo_,$(DEMO_TAGS))
push_demo_%:
	$(DOCKER_PUSH) pymor/demo:$*

tag_jupyter_% real_jupyter_% rp_jupyter_%: IMAGE_NAME:=JUPYTER_IMAGE
real_jupyter_%: FORCE testing_% pypi-mirror_stable_%
	$(DOCKER_BUILD) --build-arg PYVER=$* --build-arg VERTAG=$(VER) \
		-t $(call $(IMAGE_NAME),$*,$(VER)) jupyter


deploy_checks: $(DEPLOY_CHECKS)
$(DEPLOY_CHECKS): deploy_checks_% : FORCE
	$(DOCKER_BUILD) -t pymor/deploy_checks:$@ deploy_checks/$*

push_deploy_checks:
	$(DOCKER_PUSH) pymor/deploy_checks


pull_testing_%:
	echo '****************** IMPLEMENT ME **************************'

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
