PYTHONS = 2.7 3.5 3.6 3.7-rc

.PHONY: pythons $(PYTHONS) push

pythons: $(PYTHONS)

$(PYTHONS):
	docker build --build-arg PYVER=$@ -t pymor/wheeltester:py$@ .

push: pythons
	docker push pymor/wheeltester

