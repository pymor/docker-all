# EXPERIMENTAL_SYNTAX
FROM REGISTRY/pymor/python_PYVER:VERTAG as builder_PYVER_VERTAG

RUN MOUNT_CACHE \
  pip install pypi-oldest-requirements>=2020.4.2 cython

# cache busting opportunity
COPY bumpfile /tmp
COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/*.whl /wheelhouse/ci_wheels.list /ci_wheels/
COPY requirements* /requirements/

COPY check_reqs.py constraints.bash /usr/local/bin
RUN constraints.bash

FROM alpine:3.12

COPY --from=builder_PYVER_VERTAG /requirements/* /requirements/
