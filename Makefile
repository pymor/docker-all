.PHONY: python qt5 testing petsc fenics ngsolve update

PYTHONS=$(addprefix python-,3.5 3.6 3.7)
PUSH_PYTHONS=$(addprefix push-,$(PYTHONS))

PY=3.6

all: $(PYTHONS)

testing: ngsolve pyqt5 fenics
	make -C testing $(PY)

python:
	make -C python $(PY)

pyqt5: python
	make -C pyqt5 $(PY)

petsc: python
	make -C petsc $(PY)

fenics: petsc
	make -C fenics $(PY)

ngsolve: petsc python
	make -C ngsolve $(PY)

push_python:
	make -C python push

push_pyqt5: push_python
	make -C pyqt5 push

push_petsc: push_python
	make -C petsc push

push_fenics: push_petsc
	make -C fenics push

push_ngsolve: push_python
	make -C ngsolve push

push_testing: push_ngsolve push_pyqt5 push_fenics
	make -C testing push

update:
	git submodule foreach git fetch
	git submodule foreach git checkout origin/master

$(PYTHONS): python-%:
	make -n PY=$* testing

$(PUSH_PYTHONS): push-python-%:
	make -n PY=$* push_testing

push: $(PUSH_PYTHONS)
