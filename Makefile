.PHONY: python qt5 testing petsc fenics ngsolve dealii update

PYTHONS=$(addprefix python-,3.6 3.7 3.8)
PUSH_PYTHONS=$(addprefix push-,$(PYTHONS))

PY=3.7

all: $(PYTHONS)

testing: ngsolve fenics dealii
	$(MAKE) -C testing $(PY)

python:
	$(MAKE) -C python $(PY)

dealii: python
	$(MAKE) -C deal.II $(PY)

petsc: python
	$(MAKE) -C petsc $(PY)

fenics: petsc
	$(MAKE) -C fenics $(PY)

ngsolve: petsc python
	$(MAKE) -C ngsolve $(PY)

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

update:
	git submodule foreach git fetch
	git submodule foreach git checkout origin/master

$(PYTHONS): python-%:
	$(MAKE) PY=$* testing

$(PUSH_PYTHONS): push-python-%:
	$(MAKE) PY=$* push_testing

push: $(PUSH_PYTHONS)
