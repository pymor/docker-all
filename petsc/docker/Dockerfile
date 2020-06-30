ARG PYVER
ARG VERTAG
FROM pymor/python_${PYVER}:${VERTAG}
MAINTAINER René Fritze <rene.fritze@wwu.de>

# Get Ubuntu updates
USER root
RUN apt-get update && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
    apt-get -y install locales sudo && \
    echo "C.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set locale environment
ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8


ENV FENICS_HOME /root/fenics
RUN mkdir ${FENICS_HOME} && touch $FENICS_HOME/.sudo_as_admin_successful

WORKDIR /tmp

# Non-Python utilities and libraries
RUN apt-get -qq update && \
    apt-get -y --with-new-pkgs \
        -o Dpkg::Options::="--force-confold" upgrade && \
    apt-get -y install curl && \
    apt-get -y install \
        bison \
        cmake \
        doxygen \
        flex \
        g++ \
        gfortran \
        git \
        git-lfs \
        libboost-filesystem-dev \
        libboost-iostreams-dev \
        libboost-math-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-thread-dev \
        libboost-timer-dev \
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
ENV PETSC_VERSION=3.12.3 \
    SLEPC_VERSION=3.12.1 \
    MPI4PY_VERSION=3.0.3 \
    PETSC4PY_VERSION=3.12.0 \
    SLEPC4PY_VERSION=3.12.0 \
    TRILINOS_VERSION=12.10.1 \
    OPENBLAS_NUM_THREADS=1 \
    OPENBLAS_VERBOSE=0

# Install PETSc from source
RUN wget --quiet -nc http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-${PETSC_VERSION}.tar.gz && \
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
     make && \
     make install && \
     rm -rf /tmp/*

# Install SLEPc from source
RUN wget -nc --quiet https://slepc.upv.es/download/distrib/slepc-${SLEPC_VERSION}.tar.gz -O slepc-${SLEPC_VERSION}.tar.gz && \
    mkdir -p slepc-src && tar -xf slepc-${SLEPC_VERSION}.tar.gz -C slepc-src --strip-components 1 && \
    export PETSC_DIR=/usr/local/petsc-32 && \
    cd slepc-src && \
    python ./configure --prefix=/usr/local/slepc-32 && \
    make && \
    make install && \
    rm -rf /tmp/*

# By default use the 32-bit build of SLEPc and PETSc.
# these can not be moved, configure behaves differently when these are already in the env
ENV SLEPC_DIR=/usr/local/slepc-32 \
    PETSC_DIR=/usr/local/petsc-32

RUN printenv > /usr/local/share/petsc.env
