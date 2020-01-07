FROM quay.io/pypa/manylinux2010_x86_64

MAINTAINER René Fritze <rene.fritze@wwu.de>

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

ADD pybin.sh /etc/profile.d/
ADD entrypoint.sh /usr/local/bin/
ADD build-wheels.sh /usr/local/bin/

RUN bash -l -c '${PYBIN}/pip install ipython numpy cython scipy'
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/build-wheels.sh"]
