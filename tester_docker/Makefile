PYTHONS = 2.7 3.5 3.6

.PHONY: pythons $(PYTHONS) push

pythons: $(PYTHONS)

$(PYTHONS):
	docker build --build-arg PYVER=$@ -t pymor/wheeltester:py$@ .

push:
	docker push pymor/wheeltester

