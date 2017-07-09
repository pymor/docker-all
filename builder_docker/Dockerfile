FROM quay.io/pypa/manylinux1_x86_64

MAINTAINER René Milk <rene.milk@wwu.de>

ADD gmsh-r8692-1.el5.x86_64.rpm /tmp
ADD build-wheels.sh /usr/local/bin/
ADD entrypoint.sh /usr/local/bin/

RUN yum install -y atlas-devel openmpi-devel sudo \
        fltk freeglut libpng libjpeg \
        tk tcl xorg-x11-server-Xvfb xauth && \
    rpm -ivh /tmp/gmsh-r8692-1.el5.x86_64.rpm && \
    rm /tmp/gmsh-r8692-1.el5.x86_64.rpm

ENV MPICC /usr/lib64/openmpi/1.4-gcc/bin/mpicc

RUN yum install -y gpg && gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && rm -r /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/build-wheels.sh"]
