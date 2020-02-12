PYTHONS = 3.6 3.7 3.8
VER=$(shell git log -1 --pretty=format:"%H")
PETSC_TAG=latest
PYTHON_TAG=latest
DEALII_VERSIONS = 9.0.1 8.5.1

all: $(PYTHONS)

.PHONY: push IS_DIRTY

IS_DIRTY:
	git diff-index --quiet HEAD

$(PYTHONS): IS_DIRTY
	for DEAL in $(DEALII_VERSIONS) ; do \
		docker build --build-arg BASE=pymor/python_$@:$(PYTHON_TAG) \
				--build-arg DEALIIVERSION=$${DEAL} -t pymor/dealii_v$${DEAL}_py$@:$(VER) docker  ; \
		docker tag pymor/dealii_v$${DEAL}_py$@:$(VER) pymor/dealii_v$${DEAL}_py$@:latest ; \
	done

push_%:
	for DEAL in $(DEALII_VERSIONS) ; do \
		docker push pymor/dealii_v$${DEAL}_py$* ; \
	done

push: $(addprefix push_,$(PYTHONS))
