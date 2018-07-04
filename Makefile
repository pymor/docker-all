.PHONY: python qt5 testing petsc fenics ngsolve

all: testing

python:
	make -C python

qt5: python
	make -C qt5

petsc: python
	make -C petsc

fenics: petsc
	make -C fenics

ngsolve: petsc python
	make -C ngsolve

testing: ngsolve qt5 fenics
	make -C testing

push_python:
	make -C python push

push_qt5: push_python
	make -C qt5 push

push_petsc: push_python
	make -C petsc push

push_fenics: push_petsc
	make -C fenics push

push_ngsolve: push_python
	make -C ngsolve push

push_testing: push_ngsolve push_qt5 push_fenics
	make -C testing push

push: push_testing

