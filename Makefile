include common.mk

THIS_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SUBDIRS = $(patsubst %/,%,$(sort $(dir $(wildcard */))))
PY_INDEPENDENT = demo deploy_checks docker-in-docker docs ci_sanity pymor_source
PY_SUBDIRS = $(filter-out $(PY_INDEPENDENT),$(SUBDIRS))
EXCLUDE_FROM_ALL = pypi-mirror_test docs pymor_source dolfinx
PUSH_PYTHON_SUBDIRS = $(addprefix push_,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_SUBDIRS)))
CLEAN_PYTHON_SUBDIRS = $(addprefix clean_,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_SUBDIRS)))
PUSH_PYTHON_VERSIONS = $(addprefix push_,$(PYTHONS))
PUSH = $(addprefix push_,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_INDEPENDENT)))
CLEAN = $(addprefix clean_,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_INDEPENDENT)))
DEPLOY_CHECKS = $(subst /,_,$(patsubst %/,%,$(sort $(dir $(wildcard deploy_checks/*/)))))

IMAGE_TARGETS=real rp run cl ensure pull pl
DEMOS = $(addprefix demo_,$(DEMO_TAGS))
# no builtin rules or variables
MAKEFLAGS += -rR

all: FORCE $(foreach subd,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_SUBDIRS)),$(addprefix $(subd)_,$(PYTHONS))) $(filter-out $(EXCLUDE_FROM_ALL),$(PY_INDEPENDENT))

$(PY_SUBDIRS): % : $(addprefix %_,$(PYTHONS))

py_independent: $(PY_INDEPENDENT)
push_py_independent: $(addprefix push_,$(PY_INDEPENDENT))

push: $(PUSH_PYTHON_SUBDIRS) $(PUSH)
clean: $(CLEAN_PYTHON_SUBDIRS) $(CLEAN)

$(CLEAN_PYTHON_SUBDIRS): % : $(addprefix %_,$(PYTHONS))

$(PUSH_PYTHON_SUBDIRS): % : $(addprefix %_,$(PYTHONS))

$(PYTHONS): % : $(addsuffix _%,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_SUBDIRS)))

$(PUSH_PYTHON_VERSIONS): push_% : $(addsuffix _%,$(addprefix push_,$(filter-out $(EXCLUDE_FROM_ALL),$(PY_SUBDIRS))))

IS_DIRTY:
	@git diff-index --quiet HEAD || \
	(git update-index -q --really-refresh && git diff --no-ext-diff --quiet --exit-code) || \
	(git diff --no-ext-diff ; exit 1)

.PHONY: FORCE IS_DIRTY

FORCE: IS_DIRTY

# build+tag meta pattern for all SUBDIR_PY
$(foreach subd,$(PY_SUBDIRS),$(addprefix $(subd)_,$(PYTHONS))): % : real_%
$(foreach subd,$(PY_SUBDIRS),$(addprefix pull_$(subd)_,$(PYTHONS))): pull_% : pl_%
$(foreach subd,$(PY_SUBDIRS),$(addprefix push_$(subd)_,$(PYTHONS))): push_% : rp_%
$(foreach subd,$(PY_SUBDIRS),$(addprefix clean_$(subd)_,$(PYTHONS))): clean_% : cl_%

cl_% : FORCE
	for img in $$($(CNTR_CMD) images --format '{{.Repository}}:{{.Tag}}' | grep $(call FULL_IMAGE_NAME,$(lastword $(subst _, ,$*)),)) ; \
		do $(CNTR_RMI) $${img} ; done

rp_% : FORCE
	$(call COMMON_PUSH,$(lastword $(subst _, ,$*)))

# FULL_IMAGE_NAME includes MAIN_REGISTRY
pl_% : FORCE
	@$(CNTR_PULL) $(call FULL_IMAGE_NAME,$(lastword $(subst _, ,$*)),$(VER)) >/dev/null 2>&1 || \
		(echo "Not yet build $(call FULL_IMAGE_NAME,$(lastword $(subst _, ,$*)),$(VER))" ; \
		$(CNTR_PULL) $(call FULL_IMAGE_NAME,$(lastword $(subst _, ,$*)),latest) >/dev/null 2>&1 || \
			echo "No latest version found for $(call FULL_IMAGE_NAME,$(lastword $(subst _, ,$*)),latest)")

run_%: %
	$(CNTR_RUN) -it --entrypoint=/bin/bash $(call FULL_IMAGE_NAME,$(lastword $(subst _, ,$*)),$(VER))

push_pymor_source:
pymor_source:
	test -d pymor_source || git clone --branch=$(PYMOR_BRANCH) https://github.com/pymor/pymor pymor_source

docker-in-docker push_docker-in-docker clean_docker-in-docker run_docker-in-docker: IMAGE_NAME:=DIND_IMAGE
docker-in-docker: FORCE
	$(CNTR_BUILD) -t $(call FULL_IMAGE_NAME,dummy,$(VER)) $(call $(IMAGE_NAME)_DIR,dummy)
	$(CNTR_TAG) $(call FULL_IMAGE_NAME,dummy,$(VER)) $(call FULL_IMAGE_NAME,dummy,latest)
push_docker-in-docker: FORCE
	$(CNTR_PUSH) $(call FULL_IMAGE_NAME,dummy,$(VER))
	$(CNTR_PUSH) $(call FULL_IMAGE_NAME,dummy,latest)
clean_docker-in-docker: FORCE
	for img in $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep $(call FULL_IMAGE_NAME,dummy,)) ; \
		do $(CNTR_RMI) $${img} ; done

$(addsuffix _ci_wheels_%,$(IMAGE_TARGETS)): IMAGE_NAME:=CI_WHEELS_IMAGE
real_ci_wheels_%: FORCE python_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _wheelbuilder_manylinux2010_%,$(IMAGE_TARGETS)): IMAGE_NAME:=WB2010_IMAGE
real_wheelbuilder_manylinux2010_%: FORCE pypi-mirror_oldest_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _wheelbuilder_manylinux2014_%,$(IMAGE_TARGETS)): IMAGE_NAME:=WB2014_IMAGE
real_wheelbuilder_manylinux2014_%: FORCE pypi-mirror_oldest_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _constraints_%,$(IMAGE_TARGETS)): IMAGE_NAME:=CONSTRAINTS_IMAGE
real_constraints_%: FORCE real_ci_wheels_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _pypi-mirror_stable_%,$(IMAGE_TARGETS)): IMAGE_NAME:=PYPI_MIRROR_STABLE_IMAGE
real_pypi-mirror_stable_%: FORCE constraints_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _pypi-mirror_oldest_%,$(IMAGE_TARGETS)): IMAGE_NAME:=PYPI_MIRROR_OLDEST_IMAGE
real_pypi-mirror_oldest_%: FORCE constraints_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _pypi-mirror_test_%,$(IMAGE_TARGETS)): IMAGE_NAME:=MIRROR_TEST_IMAGE
real_pypi-mirror_test_%: testing_% pypi-mirror_stable_% pypi-mirror_oldest_% pymor_source
	VARIANT=stable PYPI_MIRROR_TAG=$(VER) CI_IMAGE_TAG=$(VER) CNTR_BASE_PYTHON=$* docker-compose -f mirror-test.docker-compose.yml up --build test
	VARIANT=oldest PYPI_MIRROR_TAG=$(VER) CI_IMAGE_TAG=$(VER) CNTR_BASE_PYTHON=$* docker-compose -f mirror-test.docker-compose.yml up --build test

$(addsuffix _cibase_%,$(IMAGE_TARGETS)): IMAGE_NAME:=CIBASE_IMAGE
real_cibase_%: FORCE ngsolve_% fenics_% dealii_% pypi-mirror_stable_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _minimal_cibase_%,$(IMAGE_TARGETS)): IMAGE_NAME:=MINIMAL_CIBASE_IMAGE
real_minimal_cibase_%: FORCE pypi-mirror_stable_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _minimal_testing_%,$(IMAGE_TARGETS)) ensure_testing_%: IMAGE_NAME=MINIMAL_TESTING_IMAGE
real_minimal_testing_%: FORCE minimal_cibase_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _testing_%,$(IMAGE_TARGETS)) ensure_testing_%: IMAGE_NAME=TESTING_IMAGE
real_testing_%: FORCE cibase_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

ensure_testing_%:
	$(CNTR_INSPECT) $(call FULL_IMAGE_NAME,$*,latest) >/dev/null 2>&1 || $(CNTR_PULL) $(call FULL_IMAGE_NAME,$*,latest)

$(addsuffix _python_builder_%,$(IMAGE_TARGETS)): IMAGE_NAME=PYTHON_BUILDER_IMAGE
real_python_builder_%: FORCE
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _python_%,$(IMAGE_TARGETS)): IMAGE_NAME=PYTHON_IMAGE
real_python_%: FORCE python_builder_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _dealii_%,$(IMAGE_TARGETS)): IMAGE_NAME:=DEALII_IMAGE
real_dealii_%: FORCE python_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _petsc_%,$(IMAGE_TARGETS)): IMAGE_NAME:=PETSC_IMAGE
real_petsc_%: FORCE python_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _fenics_%,$(IMAGE_TARGETS)): IMAGE_NAME:=FENICS_IMAGE
real_fenics_%: FORCE petsc_% ci_wheels_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _dolfinx_%,$(IMAGE_TARGETS)): IMAGE_NAME:=DOLFINX_IMAGE
real_dolfinx_%: FORCE petsc_% ci_wheels_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _ngsolve_%,$(IMAGE_TARGETS)): IMAGE_NAME:=NGSOLVE_IMAGE
real_ngsolve_%: FORCE petsc_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(addsuffix _jupyter_%,$(IMAGE_TARGETS)): IMAGE_NAME:=JUPYTER_IMAGE
real_jupyter_%: FORCE testing_%
	@echo "Building $(IMAGE_NAME)"
	@$(DO_IT)

$(DEMOS): demo_% : IS_DIRTY
	$(CNTR_BUILD) -t $(MAIN_CNTR_REGISTRY)/pymor/demo:$* \
	  -t $(ALT_CNTR_REGISTRY)/pymor/demo:$* demo/$*
demo: FORCE $(DEMOS)

clean_demo: $(addprefix clean_,$(DEMOS))
push_demo: $(addprefix push_,$(DEMOS))
push_demo_%:
	$(CNTR_PUSH) $(MAIN_CNTR_REGISTRY)/pymor/demo:$*
	$(CNTR_PUSH) $(ALT_CNTR_REGISTRY)/pymor/demo:$*
clean_demo_%:
	$(CNTR_RMI) $(MAIN_CNTR_REGISTRY)/pymor/demo:$*
	$(CNTR_RMI) $(ALT_CNTR_REGISTRY)/pymor/demo:$*

# TODO forward to submake correctly
push_docs:
docs:

ci_sanity: FORCE
	$(CNTR_BUILD) -t $(MAIN_CNTR_REGISTRY)/pymor/ci_sanity:$(VER) \
		-t $(MAIN_CNTR_REGISTRY)/pymor/ci_sanity:latest \
	  -t $(ALT_CNTR_REGISTRY)/pymor/ci_sanity:$(VER) \
		-t $(ALT_CNTR_REGISTRY)/pymor/ci_sanity:latest ci_sanity

push_ci_sanity:
	$(CNTR_PUSH) $(MAIN_CNTR_REGISTRY)/pymor/ci_sanity:$(VER)
	$(CNTR_PUSH) $(MAIN_CNTR_REGISTRY)/pymor/ci_sanity:latest
	$(CNTR_PUSH) $(ALT_CNTR_REGISTRY)/pymor/ci_sanity:$(VER)
	$(CNTR_PUSH) $(ALT_CNTR_REGISTRY)/pymor/ci_sanity:latest

clean_deploy_checks: $(addprefix clean_,$(DEPLOY_CHECKS))
push_deploy_checks: $(addprefix push_,$(DEPLOY_CHECKS))
deploy_checks: $(DEPLOY_CHECKS)
$(DEPLOY_CHECKS): deploy_checks_% : FORCE
	$(CNTR_BUILD) --build-arg DEBIAN_DATE=20201117 --build-arg CENTOS_VERSION=centos8.3.2011 \
		-t $(MAIN_CNTR_REGISTRY)/pymor/deploy_checks_$*:$(VER) -t $(MAIN_CNTR_REGISTRY)/pymor/deploy_checks_$*:latest \
		-t $(ALT_CNTR_REGISTRY)/pymor/deploy_checks_$*:$(VER) -t $(ALT_CNTR_REGISTRY)/pymor/deploy_checks_$*:latest \
		deploy_checks/$*
$(addprefix clean_,$(DEPLOY_CHECKS)): clean_deploy_checks_% : FORCE
	$(CNTR_RMI) $(ALT_CNTR_REGISTRY)/pymor/deploy_checks_$* $(MAIN_CNTR_REGISTRY)/pymor/deploy_checks_$*
$(addprefix push_,$(DEPLOY_CHECKS)): push_deploy_checks_% : FORCE
	$(CNTR_PUSH) $(MAIN_CNTR_REGISTRY)/pymor/deploy_checks_$*:$(VER)
	$(CNTR_PUSH) $(MAIN_CNTR_REGISTRY)/pymor/deploy_checks_$*:latest
	$(CNTR_PUSH) $(ALT_CNTR_REGISTRY)/pymor/deploy_checks_$*:$(VER)
	$(CNTR_PUSH) $(ALT_CNTR_REGISTRY)/pymor/deploy_checks_$*:latest


pull_latest_%: FORCE
	$(MAKE) -C testing pull_latest_$*

pull_all_latest_%: FORCE
	@$(foreach v, $(filter %IMAGE,$(.VARIABLES)), \
		$(CNTR_PULL) $(MAIN_CNTR_REGISTRY)/$(call $(v),$*,latest) ; )

pull_all_current_%: FORCE
	@$(foreach v, $(filter %IMAGE,$(.VARIABLES)), \
		$(CNTR_PULL) $(MAIN_CNTR_REGISTRY)/$(call $(v),$*,$(VER)) ; )

update_python_templates:
	cd python_builder && ./update.sh 3.6 3.7 3.8 3.9 3.10-rc

ci_update:
	./.ci/template.azure.py
	./.ci/template.gitlab.py

debug:
	echo $(DSUB)
