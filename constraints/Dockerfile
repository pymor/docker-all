# syntax = docker/dockerfile:experimental
FROM pymor/python_PYVER:VERTAG as builder
# libopenblas-dev cmake: needed for slycot install (wheel building)
# mpi-default-dev: for mpi4py install/wheel
RUN --mount=type=cache,sharing=locked,id=pymor_aptcache,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,id=pymor_cache,target=/cache/ \
    --mount=type=cache,sharing=locked,id=pymor_aptlib,target=/var/lib/apt \
  pip install pypi-oldest-requirements>=2020.4.2 && \
  apt update && \
  apt install -y libopenblas-dev mpi-default-dev make g++ gfortran cmake

COPY requirements* /requirements/

COPY constraints.bash /usr/local/bin
RUN constraints.bash

FROM alpine:3.12

COPY --from=builder /requirements/ /requirements/
RUN apk add bash
VOLUME "/output"
ENTRYPOINT []
CMD ["cp", "-ra", "/requirements", "/output"]
