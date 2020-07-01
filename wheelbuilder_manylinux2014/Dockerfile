ARG PYTHON_VERSION
ARG VERTAG
FROM pymor/pypi-mirror_oldest_py${PYTHON_VERSION}:${VERTAG} as dependencies

FROM quay.io/pypa/manylinux2014_x86_64:2020-04-06-2fd435d

MAINTAINER René Fritze <rene.fritze@wwu.de>

# needs repeat after being consumed in FROM
ARG PYTHON_VERSION

ENV MPICC=/usr/lib64/openmpi/bin/mpicc \
    PYTHON_VERSION=${PYTHON_VERSION} \
    WHEEL_DIR=/io/wheelhouse

RUN yum install -y atlas-devel openmpi-devel  \
        fltk freeglut libpng libjpeg \
        tk tcl xorg-x11-server-Xvfb xauth

COPY --from=dependencies /pymor/downloads/* ${WHEEL_DIR}/
COPY pybin.sh /etc/profile.d/
# some packages get installed manually because others have broken dependency settings
RUN source /etc/profile.d/pybin.sh && \
  rm ${WHEEL_DIR}/slycot* && \
  ${PYBIN}/pip install --no-cache ${WHEEL_DIR}/numpy* ${WHEEL_DIR}/scipy* && \
  ${PYBIN}/pip install --no-cache ${WHEEL_DIR}/*

COPY entrypoint.sh /usr/local/bin/
COPY build-wheels.sh /usr/local/bin/
COPY gosu-amd64 /usr/local/bin/gosu

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/build-wheels.sh"]
