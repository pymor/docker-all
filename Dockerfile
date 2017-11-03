ARG PYVER=3.5
FROM pymor/python:$PYVER
MAINTAINER René Milk <rene.milk@wwu.de>

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


# Bug fix for Debian python3 site path issue
# https://bitbucket.org/fenics-project/dolfin/issues/787/debian-ubuntu-python-bug-leads-to-python3
# https://bugs.launchpad.net/ubuntu/+source/python3.5/+bug/1408092?comments=all
RUN echo "/usr/local/lib/python3/dist-packages" >> /usr/local/lib/python3.5/dist-packages/debian-ubuntu-sitepath-fix.pth


ENV FENICS_HOME /root/fenics
RUN mkdir ${FENICS_HOME} && touch $FENICS_HOME/.sudo_as_admin_successful

WORKDIR /tmp

# Environment variables
ENV PETSC_VERSION=3.7.6 \
    SLEPC_VERSION=3.7.4 \
    SWIG_VERSION=3.0.12 \
    MPI4PY_VERSION=2.0.0 \
    PETSC4PY_VERSION=3.7.0 \
    SLEPC4PY_VERSION=3.7.0 \
    TRILINOS_VERSION=12.10.1 \
    OPENBLAS_NUM_THREADS=1 \
    OPENBLAS_VERBOSE=0

# Non-Python utilities and libraries
RUN apt-get -qq update && \
    apt-get -y --with-new-pkgs \
        -o Dpkg::Options::="--force-confold" upgrade && \
    apt-get -y install curl && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
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
        bash-completion && \
    git lfs install && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Python2 based environment
RUN apt-get -qq update && \
    apt-get -y --with-new-pkgs \
        -o Dpkg::Options::="--force-confold" upgrade && \
    apt-get -y install \
        python-dev python3-dev \
        python-flufl.lock python3-flufl.lock \
        python-numpy python3-numpy \
        python-ply python3-ply \
        python-pytest python3-pytest \
        python-scipy python3-scipy \
        python-six python3-six \
        python-subprocess32 \
        python-urllib3  python3-urllib3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Install PETSc from source
RUN wget --quiet -nc http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-${PETSC_VERSION}.tar.gz && \
    tar -xf petsc-lite-${PETSC_VERSION}.tar.gz && \
    cd petsc-${PETSC_VERSION} && \
    python2 ./configure --COPTFLAGS="-O2" \
                --CXXOPTFLAGS="-O2" \
                --FOPTFLAGS="-O2" \
                --with-c-support \
                --with-debugging=0 \
                --with-shared-libraries \
                --download-blacs \
                --download-hypre \
                --download-metis \
                --download-mumps \
                --download-parmetis \
                --download-ptscotch \
                --download-scalapack \
                --download-spai \
                --download-suitesparse \
                --download-superlu \
                --download-superlu_dist \
                --prefix=/usr/local/petsc-32 && \
     make && \
     make install && \
     rm -rf /tmp/*

# Install SLEPc from source
RUN wget -nc --quiet https://bitbucket.org/slepc/slepc/get/v${SLEPC_VERSION}.tar.gz -O slepc-${SLEPC_VERSION}.tar.gz && \
    mkdir -p slepc-src && tar -xf slepc-${SLEPC_VERSION}.tar.gz -C slepc-src --strip-components 1 && \
    export PETSC_DIR=/usr/local/petsc-32 && \
    cd slepc-src && \
    python2 ./configure --prefix=/usr/local/slepc-32 && \
    make && \
    make install && \
    rm -rf /tmp/*

# By default use the 32-bit build of SLEPc and PETSc.
ENV SLEPC_DIR=/usr/local/slepc-32 \
    PETSC_DIR=/usr/local/petsc-32
