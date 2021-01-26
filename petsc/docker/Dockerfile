# EXPERIMENTAL_SYNTAX

FROM REGISTRY/pymor/python_PYVER:VERTAG
MAINTAINER René Fritze <rene.fritze@wwu.de>

# Get Ubuntu updates
USER root
ENV FENICS_HOME /root/fenics
RUN mkdir ${FENICS_HOME} && touch $FENICS_HOME/.sudo_as_admin_successful

WORKDIR /tmp

# Non-Python utilities and libraries
RUN MOUNT_CACHE \
    echo 'APT::Default-Release "buster";' > /etc/apt/apt.conf.d/default-release && \
    echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" > /etc/apt/sources.list.d/buster-backports.list && \
    echo "deb http://deb.debian.org/debian/ buster contrib non-free" > /etc/apt/sources.list.d/buster-nonfree.list && \
    apt update && \
    apt-get install -q=100 -y --no-install-recommends -t buster-backports libboost1.71-all-dev && \
    apt-get -y install curl \
        bison \
        cmake \
        doxygen \
        flex \
        g++ \
        gfortran \
        git \
        git-lfs \
        libeigen3-dev \
        liblapack-dev \
        libopenmpi-dev \
        libopenblas-dev \
        libpcre3-dev \
        libhdf5-mpi-dev \
        libgmp-dev \
        libcln-dev \
        libmpfr-dev \
        openmpi-bin \
        nano \
        pkg-config \
        man \
        wget \
        ccache \
        git-lfs \
        bash-completion && \
    git lfs install && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    pip install \
        flufl.lock \
        numpy \
        ply \
        pytest \
        scipy \
        six \
        subprocess32 \
        urllib3


# Environment variables
ENV PETSC_VERSION=3.14.0 \
    SLEPC_VERSION=3.14.0 \
    MPI4PY_VERSION=3.0.3 \
    PETSC4PY_VERSION=3.13.0 \
    SLEPC4PY_VERSION=3.13.0 \
    TRILINOS_VERSION=12.10.1 \
    OPENBLAS_NUM_THREADS=1 \
    OPENBLAS_VERBOSE=0 \
    PYBIND11_VERSION=2.4.3

# Install PETSc from source
RUN MOUNT_CACHE \
    wget --quiet -nc http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-${PETSC_VERSION}.tar.gz && \
    tar -xf petsc-lite-${PETSC_VERSION}.tar.gz && \
    cd petsc-${PETSC_VERSION} && \
    python ./configure --COPTFLAGS="-O2" \
                --CXXOPTFLAGS="-O2" \
                --FOPTFLAGS="-O2" \
                --with-debugging=0 \
                --download-blacs \
                --download-hypre \
                --download-metis \
                --download-mumps \
                --download-ptscotch \
                --download-scalapack \
                --download-spai \
                --download-suitesparse \
                --download-superlu \
                --prefix=/usr/local/petsc-32 && \
     make -j ${MAKE_PROCS} && \
     make install && \
     rm -rf /tmp/*

# Install SLEPc from source
RUN MOUNT_CACHE \
    wget -nc --quiet https://slepc.upv.es/download/distrib/slepc-${SLEPC_VERSION}.tar.gz -O slepc-${SLEPC_VERSION}.tar.gz && \
    mkdir -p slepc-src && tar -xf slepc-${SLEPC_VERSION}.tar.gz -C slepc-src --strip-components 1 && \
    export PETSC_DIR=/usr/local/petsc-32 && \
    cd slepc-src && \
    python ./configure --prefix=/usr/local/slepc-32 && \
  PETSC_ARCH=linux-gnu-real-32 pip3 install petsc4py==${PETSC4PY_VERSION} slepc4py==${SLEPC4PY_VERSION} && \
  wget -nc --quiet https://github.com/pybind/pybind11/archive/v${PYBIND11_VERSION}.tar.gz && \
  tar -xf v${PYBIND11_VERSION}.tar.gz && \
  cd pybind11-${PYBIND11_VERSION} && \
  mkdir build && \
  cd build && \
  cmake -DPYBIND11_TEST=False ../ && \
  make -j ${MAKE_PROCS} && \
  make install && \
  find /usr/local/lib -maxdepth 1 -type f | xargs strip -p -d 2> /dev/null ; \
  rm -rf /tmp/*

# By default use the 32-bit build of SLEPc and PETSc.
# these can not be moved, configure behaves differently when these are already in the env
ENV SLEPC_DIR=/usr/local/slepc-32 \
    PETSC_DIR=/usr/local/petsc-32

RUN printenv > /usr/local/share/petsc.env
