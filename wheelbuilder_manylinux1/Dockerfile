FROM pymor/pypi-mirror_oldest_pyPYVER:VERTAG as dependencies

FROM quay.io/pypa/manylinux1_x86_64:2020-07-04-283458f

MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV MPICC=/usr/lib64/openmpi/1.4-gcc/bin/mpicc \
    PYTHON_VERSION=PYVER \
    WHEEL_DIR=/io/wheelhouse \
    PLATFORM=manylinux1_x86_64

RUN yum install -vy atlas-devel openmpi-devel \
        fltk freeglut libpng libjpeg \
        tk tcl xorg-x11-server-Xvfb xauth

COPY --from=dependencies /pymor/downloads/* ${WHEEL_DIR}/
COPY pybin.sh /etc/profile.d/
# some packages get installed manually because others have broken dependency settings
RUN source /etc/profile.d/pybin.sh && \
  rm -f ${WHEEL_DIR}/slycot* ${WHEEL_DIR}/*manylinux201* && \
  ${PYBIN}/pip install -U pip && \
  ${PYBIN}/pip install --no-cache ${WHEEL_DIR}/numpy* ${WHEEL_DIR}/scipy* && \
  ${PYBIN}/pip install --no-cache ${WHEEL_DIR}/*

COPY entrypoint.sh /usr/local/bin/
COPY build-wheels.sh /usr/local/bin/
COPY gosu-amd64 /usr/local/bin/gosu

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/build-wheels.sh"]
