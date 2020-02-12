ARG PETSC=pymor/petsc_py3.7:latest
FROM $PETSC as petsclayer
MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV FENICS_BUILD_TYPE=Release \
    FENICS_PREFIX=/usr/local \
    FENICS_VERSION=2019.1.0 \
    FENICS_PYTHON=python \
    DOLFIN_VERSION="2019.1.0.post0" \
    MSHR_VERSION="2019.1.0" \
    PYBIND11_VERSION=2.4.2 \
    PYPI_FENICS_VERSION=">=2019.1.0,<2019.2.0" \
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
# sympy 1.2 has a regression that fails dolfin
    pip install --no-cache-dir sympy==1.1.1 && \
    pip install --no-cache-dir matplotlib && \
    pip install --no-cache-dir https://bitbucket.org/mpi4py/mpi4py/downloads/mpi4py-${MPI4PY_VERSION}.tar.gz && \
    pip install --no-cache-dir https://bitbucket.org/petsc/petsc4py/downloads/petsc4py-${PETSC4PY_VERSION}.tar.gz && \
    pip install --no-cache-dir https://bitbucket.org/slepc/slepc4py/downloads/slepc4py-${SLEPC4PY_VERSION}.tar.gz && \
    wget -nc --quiet https://github.com/pybind/pybind11/archive/v${PYBIND11_VERSION}.tar.gz && \
    tar -xf v${PYBIND11_VERSION}.tar.gz && \
    cd pybind11-${PYBIND11_VERSION} && \
    mkdir build && \
    cd build && \
    cmake -DPYBIND11_TEST=False ../ && \
    make -j "$(nproc)" && \
    make install && \
    rm -rf /tmp/*

# Our helper scripts
WORKDIR $FENICS_HOME
COPY fenics.env.conf $FENICS_HOME/fenics.env.conf

RUN PYTHON_SITE_DIR=$(python -c "import site; print(site.getsitepackages()[0])") && \
    PYTHON_VERSION=$(python -c 'import sys; print(str(sys.version_info[0]) + "." + str(sys.version_info[1]))') && \
    echo "$FENICS_HOME/local/lib/python$PYTHON_VERSION/site-packages" >> $PYTHON_SITE_DIR/fenics-user.pth

WORKDIR /tmp
RUN /bin/bash -c "PIP_NO_CACHE_DIR=off ${FENICS_PYTHON} -m pip install 'fenics${PYPI_FENICS_VERSION}' && \
                  git clone https://bitbucket.org/fenics-project/dolfin.git && \
                  cd dolfin && \
                  git checkout ${DOLFIN_VERSION} && \
                  mkdir build && \
                  cd build && \
                  cmake ../ \
                    -DDOLFIN_ENABLE_MPI=on \
                    -DDOLFIN_ENABLE_PETSC=on \
                    -DDOLFIN_ENABLE_SCOTCH=on \
                    -DDOLFIN_ENABLE_HDF5=on && \
                  make -j "$(nproc)" && \
                  make install && \
                  mv /usr/local/share/dolfin/demo /tmp/demo && \
                  mkdir -p /usr/local/share/dolfin/demo && \
                  mv /tmp/demo /usr/local/share/dolfin/demo/cpp && \
                  cd ../python && \
                  PIP_NO_CACHE_DIR=off ${FENICS_PYTHON} -m pip install . && \
                  cd demo && \
                  python3 generate-demo-files.py && \
                  mkdir -p /usr/local/share/dolfin/demo/python && \
                  cp -r documented /usr/local/share/dolfin/demo/python && \
                  cp -r undocumented /usr/local/share/dolfin/demo/python && \
                  cd /tmp/ && \
                  git clone https://bitbucket.org/fenics-project/mshr.git && \
                  cd mshr && \
                  git checkout ${MSHR_VERSION} && \
                  mkdir build && \
                  cd build && \
                  cmake ../ && \
                  make -j "$(nproc)"  && \
                  make install && \
                  ls -l /tmp/ && \
                  cd /tmp/dolfin/python && \
                  PIP_NO_CACHE_DIR=off ${FENICS_PYTHON} -m pip install . && \
                  find /usr/local -type f | xargs strip -p -d 2> /dev/null ; \
                  ldconfig && \
                  rm -rf /tmp/*"

# Install fenics as root user into /usr/local then remove the fenics-* scripts
# the fenics.env.conf file and the unnecessary /home/fenics/local directory as
# the user does not need them in the stable image!
RUN /bin/bash -c "cp -r /usr/local/share/dolfin/demo $FENICS_HOME/demo && \
                  rm -rf /home/fenics/local && \
                  rm -rf $FENICS_HOME/bin && \
                  echo '' >> $FENICS_HOME/.profile"

# Make sure we get something that basically works on this stable build.  It
# would be better to run unit tests, but at the moment even the quick tests
# take too long to run.
# RUN apt-get update && apt-get -y install xvfb
# RUN /bin/bash -l -c "mkdir -p /tmp/poisson_test && \
#     cd /tmp/poisson_test && \
#     ls -l $FENICS_HOME/demo/python/documented/poisson && \
#     time xvfb-run python $FENICS_HOME/demo/python/documented/poisson/demo_poisson.py && \
#     instant-clean && \
#     rm -r /tmp/poisson_test"
ONBUILD RUN echo "export MPLBACKEND=Agg \
    SLEPC_DIR=/usr/local/slepc-32 \
    PETSC_DIR=/usr/local/petsc-32" >> /etc/profile && \
    echo "source /usr/local/share/dolfin/dolfin.conf" >> /etc/profile
