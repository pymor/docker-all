ARG PYVER=3.5
FROM pymor/petsc:py$PYVER as petsclayer
MAINTAINER René Milk <rene.milk@wwu.de>

ENV FENICS_BUILD_TYPE=Release \
    FENICS_PREFIX=/usr/local \
    FENICS_VERSION=2017.1.0 \
    FENICS_PYTHON=python
WORKDIR /tmp

# Install Python environment
RUN pip install --no-cache-dir numpy && \
    pip install --no-cache-dir ply && \
    pip install --no-cache-dir pytest && \
    pip install --no-cache-dir scipy && \
    pip install --no-cache-dir six && \
    pip install --no-cache-dir urllib3 && \
# Install Jupyter, sympy, mpi4py, petsc4py and slepc4py and Swig from source.
    pip install --no-cache-dir sympy && \
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
RUN /bin/bash -c "FENICS_SRC_DIR=/tmp/src /root/fenics/bin/fenics-build && \
               ldconfig && \
               cp -r $FENICS_PREFIX/share/dolfin/demo $FENICS_HOME/demo && \
               rm -rf /root/fenics/local && \
               rm -rf /tmp/src && \
               rm -rf $FENICS_HOME/bin"
# Make sure we get something that basically works on this stable build.  It
# would be better to run unit tests, but at the moment even the quick tests
# take too long to run.
# RUN apt-get update && apt-get -y install xvfb
# RUN /bin/bash -l -c "mkdir -p /tmp/poisson_test && \
#     cd /tmp/poisson_test && \
#     xvfb-run python $FENICS_HOME/demo/documented/poisson/python/demo_poisson.py && \
#     instant-clean && \
#     rm -r /tmp/poisson_test"
ONBUILD RUN echo "export SLEPC_DIR=/usr/local/slepc-32 \
    PETSC_DIR=/usr/local/petsc-32" >> /etc/profile && \
    echo "source /usr/local/share/dolfin/dolfin.conf" >> /etc/profile
