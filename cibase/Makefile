include ../../common.mk

$(PYTHONS):
	docker build --build-arg PYVER=$@ \
		-t $(call CIBASE_IMAGE,$@,$(VER)) buster

push_%:
	docker push $(call CIBASE_IMAGE,$*,$(VER))

pull_latest_%:
	docker pull $(call CIBASE_IMAGE,$@,latest)
