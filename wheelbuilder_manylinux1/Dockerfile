ARG PYTHON_VERSION
ARG VER
FROM pymor/pypi-mirror_oldest_py${PYTHON_VERSION}:${VER} as dependencies

FROM quay.io/pypa/manylinux1_x86_64

MAINTAINER René Fritze <rene.fritze@wwu.de>

# needs repeat after being consumed in FROM
ARG PYTHON_VERSION

ENV MPICC=/usr/lib64/openmpi/bin/mpicc \
    PYTHON_VERSION=${PYTHON_VERSION} \
    WHEEL_DIR=/io/wheelhouse

RUN yum install -y atlas-devel openmpi-devel sudo \
        fltk freeglut libpng libjpeg \
        tk tcl xorg-x11-server-Xvfb xauth && \
    yum install -y gpg && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && rm -r /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu

COPY --from=dependencies /pymor/downloads/* ${WHEEL_DIR}/
COPY pybin.sh /etc/profile.d/
# some packages get installed manually because others haev broken dependency settings
RUN source /etc/profile.d/pybin.sh && \
  rm ${WHEEL_DIR}/slycot* && \
  ${PYBIN}/pip install -U pip && \
  ${PYBIN}/pip install --no-cache ${WHEEL_DIR}/numpy* ${WHEEL_DIR}/scipy* && \
  ${PYBIN}/pip install --no-cache ${WHEEL_DIR}/*

COPY entrypoint.sh /usr/local/bin/
COPY build-wheels.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/build-wheels.sh"]
