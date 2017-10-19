.PHONY: petsc

petsc:
	docker build -t pymor/petsc:3.7.4 .

push:
	docker push pymor/petsc

all: petsc
