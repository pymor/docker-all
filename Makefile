PYTHONS = 3.6 3.7 3.8

.PHONY: pythons $(PYTHONS)

pythons: $(PYTHONS)

$(PYTHONS):
	docker build --build-arg PYVER=$@ \
		-t pymor/petsc:py$@ docker/

push:
	docker push pymor/petsc

all: pythons
