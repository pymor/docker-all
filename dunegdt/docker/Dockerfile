FROM pymor/python_PYVER:VERTAG

MAINTAINER René Fritze <rene.fritze@wwu.de>

RUN apt-get update && \
    apt-get -y install cmake git g++ \
    openmpi-bin libopenmpi-dev \
    bison build-essential cmake flex gfortran libboost-system-dev \
                libboost-thread-dev libboost-filesystem-dev libboost-date-time-dev \
                libboost-timer-dev libboost-chrono-dev libsuperlu-dev libtool \
                pkg-config libopenblas-dev libtbb-dev libeigen3-dev && \
    pip install mpi4py
ENV DUNE_GDT_VERSION=master \
  DUNE_SRC_DIR=/src \
  DUNE_BUILD_DIR=/src/build

RUN git clone https://zivgitlab.uni-muenster.de/ag-ohlberger/dune-community/dune-gdt-super ${DUNE_SRC_DIR} && \
    cd ${DUNE_SRC_DIR} && \
    git checkout ${DUNE_GDT_VERSION} && \
    git rm -rf dune-uggrid dune-testtools && \
    cd ${DUNE_SRC_DIR}  && \
    git submodule update --init --recursive

COPY config.opts ${DUNE_SRC_DIR}/pymor.opts
RUN cd ${DUNE_SRC_DIR}  && \
    ./dune-common/bin/dunecontrol --opts=${DUNE_SRC_DIR}/pymor.opts all
RUN cd ${DUNE_SRC_DIR}  && (for md in xt gdt xt-data ; do \
  ./dune-common/bin/dunecontrol --only=dune-${md} --opts=${DUNE_SRC_DIR}/pymor.opts make bindings ; done)
RUN cd ${DUNE_SRC_DIR}  && (for md in xt gdt xt-data ; do \
    ./dune-common/bin/dunecontrol --only=dune-${md} --opts=${DUNE_SRC_DIR}/pymor.opts make install; done)
#RUN cd ${DUNE_SRC_DIR}  && ./dune-common/bin/dunecontrol --opts=${DUNE_SRC_DIR}/pymor.opts make install

# RUN
#     cd ${DUNE_BUILD_DIR} && \
#     make -j ${MAKE_PROCS} && \
#     make install && \
#     find /usr/local/lib -maxdepth 1 -type f | xargs strip -p -d 2> /dev/null ; \
#     rm -rf ${DUNE_BUILD_DIR} ${DUNE_SRC_DIR} && \
#     printenv >> /usr/local/share/dunegdt.env
