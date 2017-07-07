FROM quay.io/pypa/manylinux1_x86_64

ADD gmsh-r8692-1.el5.x86_64.rpm /tmp

RUN yum install -y atlas-devel openmpi-devel \
        fltk freeglut libpng libjpeg \
        tk tcl xorg-x11-server-Xvfb xauth && \
    rpm -ivh /tmp/gmsh-r8692-1.el5.x86_64.rpm && \
    rm /tmp/gmsh-r8692-1.el5.x86_64.rpm

ENV MPICC /usr/lib64/openmpi/1.4-gcc/bin/mpicc
