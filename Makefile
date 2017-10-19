PYTHONS = 2.7 3.5 3.6 3.7-rc
PETSC_VERSION=3.7.6

.PHONY: pythons $(PYTHONS)

pythons: $(PYTHONS)

$(PYTHONS):
	docker build --build-arg PYVER=$@ \
		-t pymor/petsc:py$@_$(PETSC_VERSION) .

push:
	docker push pymor/petsc

all: pythons
