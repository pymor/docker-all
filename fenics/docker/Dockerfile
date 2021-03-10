FROM REGISTRY/pymor/petsc_pyPYVER:VERTAG as petsclayer
MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV FENICS_BUILD_TYPE=Release \
    FENICS_PREFIX=/usr/local \
    FENICS_VERSION=2019.1.0 \
    FENICS_PYTHON=python \
    DOLFIN_VERSION="2019.1.0.post0" \
    MSHR_VERSION="2019.1.0" \
    PYPI_FENICS_VERSION=">=2019.1.0,<2019.2.0" \
    FENICS_PYTHON=python
WORKDIR /tmp

COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/mpi4py*.whl /tmp/
# Install Python environment
RUN pip install numpy && \
    pip install ply && \
    pip install pytest && \
    pip install scipy && \
    pip install six && \
    pip install urllib3 && \
    pip install sympy==1.5.1 && \
    pip install matplotlib && \
    pip install /tmp/mpi4py*.whl && \
    pip install petsc4py==${PETSC4PY_VERSION}

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
                  make -j ${MAKE_PROCS} && \
                  make install "
RUN find /usr/local -name demo ; ls -l /usr/local/share/* && \
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
                  make -j ${MAKE_PROCS} && \
                  make install && \
                  ls -l /tmp/ && \
                  cd /tmp/dolfin/python && \
                  PIP_NO_CACHE_DIR=off ${FENICS_PYTHON} -m pip install . && \
                  find /usr/local/lib -maxdepth 1 -type f | xargs strip -p -d 2> /dev/null ; \
                  ldconfig && \
                  rm -rf /tmp/*

# Install fenics as root user into /usr/local then remove the fenics-* scripts
# the fenics.env.conf file and the unnecessary /home/fenics/local directory as
# the user does not need them in the stable image!
RUN /bin/bash -c "cp -r /usr/local/share/dolfin/demo $FENICS_HOME/demo && \
                  rm -rf /home/fenics/local && \
                  rm -rf $FENICS_HOME/bin && \
                  echo '' >> $FENICS_HOME/.profile && \
                  printenv >> /usr/local/share/fenics.env"

# Make sure we get something that basically works on this stable build.  It
# would be better to run unit tests, but at the moment even the quick tests
# take too long to run.
RUN apt-get update && apt-get -y install xvfb
COPY demo_auto-adaptive_poisson.py /tmp/poisson_test/
RUN /bin/bash -l -c "cd /tmp/poisson_test && \
    time xvfb-run python demo_auto-adaptive_poisson.py && \
    rm -r /tmp/poisson_test"
