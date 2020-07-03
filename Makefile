include common.mk

THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
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
IMAGE_TARGETS=tag real rp run cl ensure pull pl
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
	@git diff-index --quiet HEAD || \
	(git update-index -q --really-refresh && git diff --no-ext-diff --quiet --exit-code) || \
	(git diff --no-ext-diff ; exit 1)

.PHONY: FORCE IS_DIRTY

FORCE: IS_DIRTY

# build+tag meta pattern for all SUBDIR_PY
$(foreach subd,$(PY_SUBDIRS),$(addprefix $(subd)_,$(PYTHONS))): % : pull_% tag_%
$(foreach subd,$(PY_SUBDIRS),$(addprefix pull_$(subd)_,$(PYTHONS))): pull_% : pl_%
$(foreach subd,$(PY_SUBDIRS),$(addprefix tag_$(subd)_,$(PYTHONS))): tag_% : real_%
$(foreach subd,$(PY_SUBDIRS),$(addprefix push_$(subd)_,$(PYTHONS))): push_% : rp_%
$(foreach subd,$(PY_SUBDIRS),$(addprefix clean_$(subd)_,$(PYTHONS))): clean_% : cl_%

# the actual IMAGE_NAME is set via target variable from tag_subdir% rules
tag_% : FORCE
	$(CNTR_TAG) $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),$(VER)) \
		$(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),latest)

cl_% : FORCE
	for img in $$($(CNTR_CMD) images --format '{{.Repository}}:{{.Tag}}' | grep $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),)) ; \
		do $(CNTR_RMI) $${img} ; done

rp_% : FORCE
	$(CNTR_PUSH) $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),$(VER))
	$(CNTR_PUSH) $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),latest)

pl_% : FORCE
	@$(CNTR_PULL) $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),$(VER)) >/dev/null 2>&1 || \
		echo "Not yet build $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),$(VER))"

run_%: %
	$(CNTR_RUN) --entrypoint=/bin/bash $(call $(IMAGE_NAME),$(lastword $(subst _, ,$*)),$(VER))

pymor_source:
	test -d pymor_source || git clone --branch=$(PYMOR_BRANCH) https://github.com/pymor/pymor pymor_source

docker-in-docker push_docker-in-docker clean_docker-in-docker: IMAGE_NAME:=DIND_IMAGE
docker-in-docker: FORCE
	$(CNTR_BUILD) -t $(call $(IMAGE_NAME),dummy,$(VER)) docker-in-docker
	$(CNTR_TAG) $(call $(IMAGE_NAME),dummy,$(VER)) $(call $(IMAGE_NAME),dummy,latest)
push_docker-in-docker: FORCE
	$(CNTR_PUSH) $(call $(IMAGE_NAME),dummy,$(VER))
	$(CNTR_PUSH) $(call $(IMAGE_NAME),dummy,latest)
clean_docker-in-docker: FORCE
	for img in $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep $(call $(IMAGE_NAME),dummy,)) ; \
		do $(CNTR_RMI) $${img} ; done


$(addsuffix _wheelbuilder_manylinux1_%,$(IMAGE_TARGETS)): IMAGE_NAME:=WB1_IMAGE
real_wheelbuilder_manylinux1_%: FORCE pull_testing_% pypi-mirror_stable_% pypi-mirror_oldest_%
	$(COMMON_BUILD) wheelbuilder_manylinux1

$(addsuffix _wheelbuilder_manylinux2010_%,$(IMAGE_TARGETS)): IMAGE_NAME:=WB2010_IMAGE
real_wheelbuilder_manylinux2010_%: FORCE pull_testing_% pypi-mirror_stable_% pypi-mirror_oldest_%
	$(COMMON_BUILD) wheelbuilder_manylinux2010

$(addsuffix _wheelbuilder_manylinux2014_%,$(IMAGE_TARGETS)): IMAGE_NAME:=WB2014_IMAGE
real_wheelbuilder_manylinux2014_%: FORCE pull_testing_% pypi-mirror_stable_% pypi-mirror_oldest_%
	$(COMMON_BUILD) wheelbuilder_manylinux2014

$(addsuffix _constraints_%,$(IMAGE_TARGETS)): IMAGE_NAME:=CONSTRAINTS_IMAGE
real_constraints_%: FORCE python_%
	$(COMMON_BUILD) constraints

$(addsuffix _pypi-mirror_stable_%,$(IMAGE_TARGETS)): IMAGE_NAME:=PYPI_MIRROR_STABLE_IMAGE
real_pypi-mirror_stable_%: FORCE constraints_%
	$(CNTR_RUN) -v $(THIS_DIR)/pypi-mirror_stable/:/output $(call CONSTRAINTS_IMAGE,$*,$(VER))
	$(COMMON_BUILD) pypi-mirror_stable

$(addsuffix _pypi-mirror_oldest_%,$(IMAGE_TARGETS)): IMAGE_NAME:=PYPI_MIRROR_OLDEST_IMAGE
real_pypi-mirror_oldest_%: FORCE constraints_%
	$(CNTR_RUN) -v $(THIS_DIR)/pypi-mirror_oldest/:/output $(call CONSTRAINTS_IMAGE,$*,$(VER))
	$(COMMON_BUILD) pypi-mirror_oldest

$(addsuffix _pypi-mirror_test_%,$(IMAGE_TARGETS)): IMAGE_NAME:=MIRROR_TEST_IMAGE
real_pypi-mirror_test_%: pypi-mirror_stable_% pypi-mirror_oldest_% pymor_source
	VARIANT=stable PYPI_MIRROR_TAG=$(VER) CI_IMAGE_TAG=$(VER) CNTR_BASE_PYTHON=$* docker-compose -f mirror-test.docker-compose.yml up --build test
	VARIANT=oldest PYPI_MIRROR_TAG=$(VER) CI_IMAGE_TAG=$(VER) CNTR_BASE_PYTHON=$* docker-compose -f mirror-test.docker-compose.yml up --build test

$(addsuffix _cibase_%,$(IMAGE_TARGETS)): IMAGE_NAME:=CIBASE_IMAGE
real_cibase_%: FORCE ngsolve_% fenics_% dealii_%
	$(COMMON_BUILD) cibase/buster

$(addsuffix _testing_%,$(IMAGE_TARGETS)) ensure_testing_%: IMAGE_NAME=TESTING_IMAGE
real_testing_%: FORCE cibase_%
	$(COMMON_BUILD) testing/$*
ensure_testing_%:
	$(CNTR_INSPECT) $(call $(IMAGE_NAME),$*,latest) >/dev/null 2>&1 || $(CNTR_PULL) $(call $(IMAGE_NAME),$*,latest)

$(addsuffix _python_%,$(IMAGE_TARGETS)): IMAGE_NAME=PYTHON_IMAGE
real_python_%: FORCE
	$(COMMON_BUILD) python/$*/buster/slim

$(addsuffix _dealii_%,$(IMAGE_TARGETS)): IMAGE_NAME:=DEALII_IMAGE
real_dealii_%: FORCE python_%
	$(COMMON_BUILD) dealii/docker

$(addsuffix _petsc_%,$(IMAGE_TARGETS)): IMAGE_NAME:=PETSC_IMAGE
real_petsc_%: FORCE python_%
	$(COMMON_BUILD) petsc/docker

$(addsuffix _fenics_%,$(IMAGE_TARGETS)): IMAGE_NAME:=FENICS_IMAGE
real_fenics_%: FORCE petsc_%
	$(COMMON_BUILD) fenics/docker

$(addsuffix _ngsolve_%,$(IMAGE_TARGETS)): IMAGE_NAME:=NGSOLVE_IMAGE
real_ngsolve_%: FORCE petsc_%
	$(COMMON_BUILD) --build-arg NGSOLVE_VERSION=$(NGSOLVE_VERSION) ngsolve/docker

$(addsuffix _jupyter_%,$(IMAGE_TARGETS)): IMAGE_NAME:=JUPYTER_IMAGE
real_jupyter_%: FORCE testing_% pypi-mirror_stable_%
	$(COMMON_BUILD) jupyter

$(DEMOS): demo_% : IS_DIRTY
	$(CNTR_BUILD) -t pymor/demo:$* demo/$*
demo: FORCE testing_3.7 $(DEMOS)

clean_demo: $(addprefix clean_,$(DEMOS))
push_demo: $(addprefix push_,$(DEMOS))
push_demo_%:
	$(CNTR_PUSH) pymor/demo:$*
clean_demo_%:
	$(CNTR_RMI) pymor/demo:$*

ci_sanity: FORCE
	$(CNTR_BUILD) -t pymor/ci_sanity:$(VER) ci_sanity

push_ci_sanity:
	$(CNTR_PUSH) pymor/ci_sanity:$(VER)

clean_deploy_checks: $(addprefix clean_,$(DEPLOY_CHECKS))
deploy_checks: $(DEPLOY_CHECKS)
$(DEPLOY_CHECKS): deploy_checks_% : FORCE
	$(CNTR_BUILD) -t pymor/deploy_checks:$@ deploy_checks/$*
$(addprefix clean_,$(DEPLOY_CHECKS)): clean_deploy_checks_% : FORCE
	$(CNTR_RMI) pymor/deploy_checks:$@

push_deploy_checks:
	$(CNTR_PUSH) pymor/deploy_checks

pull_latest_%: FORCE
	$(MAKE) -C testing pull_latest_$*

pull_all_latest_%: FORCE
	$(CNTR_PULL) $(call TESTING_IMAGE,$*,latest)
	$(CNTR_PULL) $(call CIBASE_IMAGE,$*,latest)
	$(CNTR_PULL) $(call DEALII_IMAGE,$*,latest)
	$(CNTR_PULL) $(call FENICS_IMAGE,$*,latest)
	$(CNTR_PULL) $(call PYTHON_IMAGE,$*,latest)
	$(CNTR_PULL) $(call PETSC_IMAGE,$*,latest)
	$(CNTR_PULL) $(call NGSOLVE_IMAGE,$*,latest)
	$(CNTR_PULL) $(call PYPI_MIRROR_OLDEST_IMAGE,$*,latest)
	$(CNTR_PULL) $(call PYPI_MIRROR_STABLE_IMAGE,$*,latest)
	$(CNTR_PULL) $(call JUPYTER_IMAGE,$*,latest)
	$(CNTR_PULL) $(call CONSTRAINTS_IMAGE,$*,latest)
	$(CNTR_PULL) $(call JUPYTER_IMAGE,$*,latest)
	$(CNTR_PULL) $(call JUPYTER_IMAGE,$*,latest)
	$(CNTR_PULL) $(call DIND_IMAGE,dummy,latest)
	$(CNTR_PULL) $(call WB2010_IMAGE,$*,latest)
	$(CNTR_PULL) $(call WB2014_IMAGE,$*,latest)

update_python_templates:
	cd python && ./update.sh 3.6 3.7 3.8 3.9-rc
