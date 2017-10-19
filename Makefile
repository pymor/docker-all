PYTHONS = 2.7 3.5 3.6 3.7-rc

.PHONY: pythons $(PYTHONS) petsc 

pythons: $(PYTHONS)

petsc:
	docker build -t pymor/petsc:3.7.4 .

$(PYTHONS): 
	echo docker build -t pymor/petsc:py$@_3.7.4 .

push:
	docker push pymor/petsc

all: petsc
