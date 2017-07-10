PYTHONS = 2.7 3.4 3.5 3.6

.PHONY: pythons $(PYTHONS) push

pythons: $(PYTHONS)

$(PYTHONS):
	sed -e "s/PYTHONREV/$@/g" Dockerfile.in > Dockerfile
	docker build -t pymor/wheeltester:$@ .

push: pythons
	docker push pymor/wheeltester

