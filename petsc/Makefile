include ../common.mk

$(PYTHONS): IS_DIRTY
	docker build --build-arg BASE=$(call PYTHON_IMAGE,$@,$(PYTHON_TAG)) \
	-t $(call PETSC_IMAGE,$@,$(VER)) docker
	docker tag $(call PETSC_IMAGE,$@,$(VER)) $(call PETSC_IMAGE,$@,latest)

push_%:
	docker push $(call PETSC_IMAGE,$*,$(VER))

pull_latest_%:
	docker pull $(call PETSC_IMAGE,$@,latest)
