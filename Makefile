PYTHONS = 3.6 3.7

.PHONY: pythons $(PYTHONS)

pythons: $(PYTHONS)

$(PYTHONS):
	docker build --pull --build-arg PYVER=$@ \
		-t pymor/petsc:py$@ .

push:
	docker push pymor/petsc

all: pythons
