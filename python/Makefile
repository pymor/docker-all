PYTHONS = 3.6 3.7 3.8
VARIANT?=buster/slim
VER=$(shell git log -1 --pretty=format:"%H")

all: $(PYTHONS)

.PHONY: push IS_DIRTY

IS_DIRTY:
	git diff-index --quiet HEAD

$(PYTHONS): IS_DIRTY
	cd "$@/$(VARIANT)" && \
		docker build -t pymor/python_$@:$(VER) .
	docker tag pymor/python_$@:$(VER) pymor/python_$@:latest

push_%:
	docker push pymor/python_$*

push: $(addprefix push_,$(PYTHONS))
