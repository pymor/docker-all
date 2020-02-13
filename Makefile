include common.mk
.PHONY: FORCE

PY=3.7

FORCE:

$(PYTHONS): FORCE
	$(MAKE) PY=$@ testing

cibase: FORCE ngsolve fenics dealii
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

deploy_checks: FORCE
	$(MAKE) -C deploy_checks

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

push_testing: FORCE push_ngsolve push_fenics push_dealii
	$(MAKE) -C testing push_$(PY)

push_%: FORCE
	$(MAKE) PY=$* push_testing

pull_latest_%: FORCE
	$(MAKE) -C testing pull_latest_$@
