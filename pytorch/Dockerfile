# syntax = docker/dockerfile:experimental
FROM quay.io/pypa/manylinux2014_x86_64:2020-10-06-b2ca7a1

MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV MPICC=/usr/lib64/openmpi/bin/mpicc \
    PYTHON_VERSION=PYVER \
    WHEELHOUSE_DIR=wheelhouse \
    XDG_CACHE_HOME=/cache \
    PLATFORM=manylinux2014_x86_64 \
    PYTORCH_VERSION=1.6 \
    pytorch_rootdir="/src" \
    PYTORCH_FINAL_PACKAGE_DIR=/io/wheelhouse

RUN yum install -vy atlas-devel openmpi-devel \
        fltk freeglut libpng libjpeg \
        tk tcl xorg-x11-server-Xvfb xauth
RUN git clone --branch=${PYTORCH_VERSION} https://github.com/pytorch/pytorch/ ${pytorch_rootdir} && \
  cd ${pytorch_rootdir} && \
  git submodule update --init --recursive

COPY build_*.sh /builder/
RUN --mount=type=cache,sharing=locked,id=pymor_cache,target=/cache/  \
  DESIRED_PYTHON=PYVER /builder/build_cpu.sh
