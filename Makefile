.PHONY: python testing petsc fenics ngsolve dealii update

include common.mk
PYTHONS=$(addprefix python-,$(PYTHONS))
PUSH_PYTHONS=$(addprefix push-,$(PYTHONS))

PY=3.7

$(PYTHONS): python-%:
	$(MAKE) PY=$* testing

cibase: ngsolve fenics dealii
	$(MAKE) -C cibase $(PY)

testing: cibase
	$(MAKE) -C testing $(PY)

python:
	$(MAKE) -C python $(PY)

dealii: python
	$(MAKE) -C deal.II $(PY)

petsc: python
	$(MAKE) -C petsc $(PY)

fenics: petsc
	$(MAKE) -C fenics $(PY)

ngsolve: petsc
	$(MAKE) -C ngsolve $(PY)

demo: testing
	$(MAKE) -C demo

deploy_checks:
	$(MAKE) -C deploy_checks

push_python:
	$(MAKE) -C python push

push_dealii: push_python
	$(MAKE) -C deal.II push

push_petsc: push_python
	$(MAKE) -C petsc push

push_fenics: push_petsc
	$(MAKE) -C fenics push

push_ngsolve: push_python
	$(MAKE) -C ngsolve push

push_testing: push_ngsolve push_fenics push_dealii
	$(MAKE) -C testing push

$(PUSH_PYTHONS): push-python-%:
	$(MAKE) PY=$* push_testing

push: $(PUSH_PYTHONS)
