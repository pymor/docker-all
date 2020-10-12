# syntax = docker/dockerfile:experimental
FROM quay.io/pypa/manylinux2014_x86_64:2020-04-06-2fd435d

MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV MPICC=/usr/lib64/openmpi/bin/mpicc \
    PYTHON_VERSION=PYVER \
    WHEEL_DIR=/io/wheelhouse \
    XDG_CACHE_HOME=/cache \
    PLATFORM=manylinux2014_x86_64

RUN --mount=type=cache,sharing=locked,id=pymor_cache,target=/cache/ \
  yum install -y atlas-devel openmpi-devel  \
        fltk freeglut libpng libjpeg \
        tk tcl xorg-x11-server-Xvfb xauth

COPY --from=pymor/pypi-mirror_oldest_pyPYVER:VERTAG /pymor/downloads/* ${WHEEL_DIR}/
COPY pybin.sh /etc/profile.d/
# some packages get installed manually because others have broken dependency settings
RUN --mount=type=cache,sharing=locked,id=pymor_cache,target=/cache/ \
  source /etc/profile.d/pybin.sh && \
  rm -f ${WHEEL_DIR}/slycot* && \
  ${PYBIN}/pip install --no-cache ${WHEEL_DIR}/numpy* ${WHEEL_DIR}/scipy* && \
  ${PYBIN}/pip install --no-cache ${WHEEL_DIR}/*manylinux2014_x86_64.whl && \
  rm -f ${WHEEL_DIR}/*manylinux2014_x86_64.whl && \
  ${PYBIN}/pip install --no-cache ${WHEEL_DIR}/*

COPY entrypoint.sh /usr/local/bin/
COPY build-wheels.sh /usr/local/bin/
COPY gosu-amd64 /usr/local/bin/gosu

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/build-wheels.sh"]
