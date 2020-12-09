# syntax = docker/dockerfile:experimental
FROM REGISTRY/pymor/python_PYVER:VERTAG as builder

MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV WHEEL_VERSION=0.36.1

# libopenblas-dev cmake: needed for slycot
# mpi-default-dev: mpi4py
RUN MOUNT_CACHE apt update && \
  apt install -y unp \
      libopenblas-dev cmake \
      mpi-default-dev

COPY build_*.sh /builder/
RUN MOUNT_CACHE /builder/build_wheels.sh

# FROM alpine:3.12
#
# COPY --from=builder /wheelhouse/* /wheelhouse/
