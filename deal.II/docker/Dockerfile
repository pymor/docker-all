ARG BASE
FROM $BASE

MAINTAINER rene.milk@wwu.de

ARG DEALIIVERSION

USER root
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
#for add-apt-repo
RUN apt-get install -y software-properties-common \
    gfortran cmake \
    git \
    gsl-bin \
    libblas-dev \
    libbz2-dev \
    libgsl-dev \
    liblapack-dev \
    libnetcdf-c++4-dev \
    libnetcdf-cxx-legacy-dev \
    libnetcdf-dev \
    libarpack2-dev libboost-all-dev libgmsh-dev \
    liblapack-dev libmuparser-dev libmetis-dev libtbb-dev \
    ninja-build \
    numdiff \
    unzip \
    wget \
    zlib1g-dev \
    libopenmpi-dev \
# next line is necessary for xfvb/qt/gl demo to work, needed till imaged rebased on pymor/testing
    xauth x11-apps xvfb libgl1-mesa-dri libglu1-mesa \
    openmpi-bin gosu && \
    pip install numpy

RUN cd /tmp && git clone https://github.com/dealii/dealii.git dealii-${DEALIIVERSION}-src && \
    cd dealii-${DEALIIVERSION}-src && \
    git checkout v${DEALIIVERSION} && \
    mkdir build && cd build && \
    cmake -DDEAL_II_WITH_MPI=ON \
          -DDEAL_II_COMPONENT_EXAMPLES=OFF \
          -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DCMAKE_BUILD_TYPE=Release \
          -DDEAL_II_ALLOW_BUNDLED=OFF \
          -GNinja \
          ../ && \
    ninja -j "$(nproc)"  && \
    ninja -j 1 install && \
    cd / && rm -rf /tmp/deal*
RUN cd /tmp && git clone --recurse-submodules --branch=non_release https://github.com/pymor/pymor-deal.II deal && \
    cd deal && python setup.py bdist_wheel && \
    mkdir /usr/local/tmp/ && \
    mv dist/*.whl /usr/local/tmp/
ONBUILD RUN pip install pyqt5==5.13.1 && \
        pip install /usr/local/tmp/pymor_dealii*.whl && \
        apt update && \
        pip uninstall -y pyqt5 && \
        apt-get install -q -y --no-install-recommends libumfpack5 libmuparser2v5 libatlas3-base libnetcdf-c++4 libgsl23 \
        && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# THE END
ENV DEBIAN_FRONTEND teletype
