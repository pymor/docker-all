ARG PYVER=3.5
FROM pymor/petsc:py$PYVER as petsclayer
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
    OPENBLAS_VERBOSE=0 \
    FENICS_PREFIX=$FENICS_HOME/local

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
        libmpich-dev \
        libopenblas-dev \
        libpcre3-dev \
        libhdf5-mpich-dev \
        libgmp-dev \
        libcln-dev \
        libmpfr-dev \
        mpich \
        nano \
        pkg-config \
        man \
        wget \
        ccache \
        python-dev python3-dev \
        bash-completion && \
    git lfs install && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Python2 based environment
RUN pip install  \
        numpy \
        ply \
        pytest \
        scipy \
        six \
        urllib3
# Install Jupyter, sympy, mpi4py, petsc4py and slepc4py and Swig from source.
RUN pip install --no-cache-dir sympy && \
    pip install --no-cache-dir matplotlib && \
    pip install --no-cache-dir https://bitbucket.org/mpi4py/mpi4py/downloads/mpi4py-${MPI4PY_VERSION}.tar.gz && \
    pip install --no-cache-dir https://bitbucket.org/petsc/petsc4py/downloads/petsc4py-${PETSC4PY_VERSION}.tar.gz && \
    pip install --no-cache-dir https://bitbucket.org/slepc/slepc4py/downloads/slepc4py-${SLEPC4PY_VERSION}.tar.gz && \
    wget -nc --quiet http://downloads.sourceforge.net/swig/swig-${SWIG_VERSION}.tar.gz -O swig-${SWIG_VERSION}.tar.gz && \
    tar -xf swig-${SWIG_VERSION}.tar.gz && \
    cd swig-${SWIG_VERSION} && \
    ./configure && \
    make && \
    make install && \
    rm -rf /tmp/*

# Our helper scripts
WORKDIR $FENICS_HOME
COPY fenics.env.conf $FENICS_HOME/fenics.env.conf
COPY bin $FENICS_HOME/bin
RUN PYTHON_SITE_DIR=$(python -c "import site; print(site.getsitepackages()[0])") && \
    PYTHON_VERSION=$(python -c 'import sys; print(str(sys.version_info[0]) + "." + str(sys.version_info[1]))') && \
    echo "$FENICS_HOME/local/lib/python$PYTHON_VERSION/site-packages" >> $PYTHON_SITE_DIR/fenics-user.pth

# Python3 build.
ENV FENICS_PYTHON=python

RUN /bin/bash -c "FENICS_SRC_DIR=/tmp/src /root/fenics/bin/fenics-pull"
# Install fenics as root user into /usr/local then remove the fenics-* scripts
# the fenics.env.conf file and the unnecessary /root/fenics/local directory as
# the user does not need them in the stable image!
RUN pip install ply
RUN /bin/bash -c "FENICS_SRC_DIR=/tmp/src /root/fenics/bin/fenics-build && \
               ldconfig && \
               cp -r $FENICS_PREFIX/share/dolfin/demo $FENICS_HOME/demo && \
               rm -rf /root/fenics/local && \
               rm -rf /tmp/src && \
               rm -rf $FENICS_HOME/bin && \
               echo '' >> $FENICS_HOME/.profile"
# Make sure we get something that basically works on this stable build.  It
# would be better to run unit tests, but at the moment even the quick tests
# take too long to run.
# RUN /bin/bash -l -c "mkdir -p /tmp/poisson_test && \
#     cd /tmp/poisson_test && \
#     python $FENICS_HOME/demo/documented/poisson/python/demo_poisson.py && \
#     instant-clean && \
#     rm -r /tmp/poisson_test"
