# EXPERIMENTAL_SYNTAX

FROM pymor/petsc_pyPYVER:VERTAG as petsclayer
MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV DOLFINX_VERSION="master" PYBIND11_VERSION=2.4.3
WORKDIR /tmp

COPY --from=REGISTRY/pymor/ci_wheels_pyPYVER:VERTAG /wheelhouse/mpi4py*.whl /tmp/

#TODO: move backports setup to petsc
#TODO: move pybind11 install from this and fenics image to petsc

RUN MOUNT_CACHE \
  pip install numba /tmp/mpi4py* && \
  mkdir /src && cd /src && \
  (for i in basix fiat ufl ffcx dolfinx ; do git clone https://github.com/FEniCS/$i /src/$i ; done) && \
  (for i in basix fiat ufl ffcx dolfinx; do cd /src/$i && git checkout ${DOLFINX_VERSION} ; done) && \
  (for i in basix fiat ufl ffcx ; do cd /src/$i && pip install --no-cache-dir . ; done) && \
  apt update ; apt install -y ninja-build
RUN MOUNT_CACHE \
  echo 'APT::Default-Release "buster";' > /etc/apt/apt.conf.d/default-release && \
  echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" > /etc/apt/sources.list.d/buster-backports.list && \
  echo "deb http://deb.debian.org/debian/ buster contrib non-free" > /etc/apt/sources.list.d/buster-nonfree.list && \
  apt update && \
  apt-get install -q=100 -y --no-install-recommends -t buster-backports libboost1.71-all-dev

RUN MOUNT_CACHE \
      wget -nc --quiet https://github.com/pybind/pybind11/archive/v${PYBIND11_VERSION}.tar.gz && \
      tar -xf v${PYBIND11_VERSION}.tar.gz && \
      cd pybind11-${PYBIND11_VERSION} && \
      mkdir build && \
      cd build && \
      cmake -DPYBIND11_TEST=False ../ && \
      make -j ${MAKE_PROCS} && \
      make install && \
      rm -rf /tmp/* && \
  cd /src/dolfinx && \
    mkdir build && \
    cd build && \
    PETSC_ARCH=linux-gnu-real-32 cmake -G Ninja \
      -DCMAKE_INSTALL_PREFIX=/usr/local/ \
      -DCMAKE_BUILD_TYPE=Release \
      ../cpp && \
    ninja install && \
    cd ../python && \
    PETSC_ARCH=linux-gnu-real-32 pip3 install . && \
    (find /usr/local/lib -maxdepth 1 -type f | xargs strip -p -d 2> /dev/null ) && \
    ldconfig && \
    rm -rf /src && \
    printenv >> /usr/local/share/dolfinx.env

# Make sure we get something that basically works on this stable build.  It
# would be better to run unit tests, but at the moment even the quick tests
# take too long to run.
# RUN apt-get update && apt-get -y install xvfb
# COPY demo_auto-adaptive_poisson.py /tmp/poisson_test/
# RUN /bin/bash -l -c "cd /tmp/poisson_test && \
#     time xvfb-run python demo_auto-adaptive_poisson.py && \
#     rm -r /tmp/poisson_test"
