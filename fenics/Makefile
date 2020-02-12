include ../common.mk

$(PYTHONS): IS_DIRTY
	docker build --build-arg PETSC=$(call PETSC_IMAGE,$@,$(PETSC_TAG)) \
		-t $(call FENICS_IMAGE,$@,$(VER)) docker
	docker tag $(call FENICS_IMAGE,$@,$(VER)) $(call FENICS_IMAGE,$@,latest)

push_%:
	docker push $(call FENICS_IMAGE,$*,$(VER))

pull_latest_%:
	docker pull $(call FENICS_IMAGE,$@,latest)
