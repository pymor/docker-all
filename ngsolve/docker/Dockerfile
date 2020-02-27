ARG PETSC_BASE
ARG PYTHON_BASE

FROM $PETSC_BASE as petsclayer

ENV PETSC_DIR=/usr/local/petsc-32

FROM $PYTHON_BASE

MAINTAINER René Fritze <rene.fritze@wwu.de>

RUN apt-get update && \
    apt-get -y install libxmu-dev tk-dev tcl-dev cmake git g++ \
    libglu1-mesa-dev ccache openssh-client openmpi-bin libopenmpi-dev \
    python3 libpython3-dev python3-pytest python3-numpy python3-sphinx python3-pip \
    liboce-ocaf-dev libsuitesparse-dev python3-tk && \
    pip3 install sphinx_rtd_theme
ENV PATH="/opt/netgen/bin:${PATH}" \
    NGSOLVE_VERSION=v6.2.2001 \
    NGSOLVE_SRC_DIR=/root/src/ngsolve_src \
    NGSOLVE_BUILD_DIR=/root/src/ngsolve_build \
    PETSC_DIR=/usr/local/petsc-32
ENV MUMPS_DIR=${PETSC_DIR}

COPY --from=petsclayer ${PETSC_DIR} ${PETSC_DIR}

COPY catch.hpp /usr/local/include/
# fake lsb-release to get ngsolve cmake to configure for deb package building
RUN echo "DISTRIB_CODENAME=buster" > /etc/lsb-release && \
    git clone https://github.com/NGSolve/ngsolve.git ${NGSOLVE_SRC_DIR} && \
    cd ${NGSOLVE_SRC_DIR} && \
    git checkout ${NGSOLVE_VERSION} && \
    cd ${NGSOLVE_SRC_DIR}  && \
    git submodule update --init --recursive && \
    mkdir -p ${NGSOLVE_BUILD_DIR} && \
    cd ${NGSOLVE_BUILD_DIR} && \
    cmake ${NGSOLVE_SRC_DIR} \
    -DUSE_NATIVE_ARCH=OFF \
    -DUSE_OCC=ON \
    -DUSE_MPI=OFF \
    -DUSE_HYPRE=OFF \
    -DUSE_MUMPS=OFF \
    -DOpenGL_GL_PREFERENCE=GLVND \
    -DUSE_CCACHE=OFF \
    -DUSE_MKL=OFF \
    -DUSE_UMFPACK=ON \
    -DINSTALL_PROFILES=OFF \
    -DENABLE_UNIT_TESTS=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DNG_INSTALL_DIR_LIB=lib/netgen \
    -DNG_INSTALL_DIR_INCLUDE=include/netgen \
    -DCMAKE_INSTALL_PREFIX=/usr/local && \
    make -j "$(nproc)" && \
    cd ${NGSOLVE_BUILD_DIR} && \
    make install && \
    rm -rf ${NGSOLVE_BUILD_DIR} ${NGSOLVE_SRC_DIR}
