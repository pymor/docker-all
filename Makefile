PYTHONS = 3.6 3.7

.PHONY: pythons $(PYTHONS)

pythons: $(PYTHONS)

$(PYTHONS):
	docker build --build-arg PYVER=$@ \
		-t pymor/fenics:py$@ .

push:
	docker push pymor/fenics

all: pythons
