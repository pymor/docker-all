FROM pymor/testing_py3.7:0792f9d2c00575d8cf10bfe43c0a645733bc5c07
MAINTAINER René Fritze <rene.fritze@wwu.de>

USER root
RUN apt-get update && apt-get install \
        --no-install-recommends -y xauth x11-apps xvfb libgl1-mesa-dri libglu1-mesa \
        libgsl-dev \
        liblapack-dev \
        libnetcdf-c++4-dev \
        libnetcdf-cxx-legacy-dev \
        libnetcdf-dev \
        libarpack2-dev libboost-all-dev libgmsh-dev \
        liblapack-dev libmuparser-dev libmetis-dev libtbb-dev \
    && pip uninstall -y pymor numpy \
    && ${PIP_INSTALL} -U pip==21.0 \
    && ${PIP_INSTALL} git+https://github.com/pymor/pymor.git@main#egg=pymor[full] \
    && ${PIP_INSTALL} -U git+https://github.com/pymor/pymor-deal.II#egg=pymor_dealii \
    && rm -rf ~/.matplotlib \
    && apt-get autoremove -y  \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --shell /bin/bash -u 1000 -o -c "" -m pymor

USER pymor

RUN pymor-demo --help && python -c "from pymor.basic import *"

ENV LIBGL_DEBUG=verbose
# ENTRYPOINT ["/usr/local/bin/pymor-demo"]
# CMD ["--help"]
