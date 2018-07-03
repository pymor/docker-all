PYTHONS = 3.5 3.6 3.7

.PHONY: pythons $(PYTHONS)

pythons: $(PYTHONS)

$(PYTHONS):
	docker build --build-arg PYVER=$@ \
		-t pymor/petsc:py$@ .

push:
	docker push pymor/petsc

all: pythons
