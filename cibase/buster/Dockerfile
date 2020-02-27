ARG PYVER
ARG VERTAG=latest

FROM pymor/fenics_py${PYVER}:${VERTAG} as fenicslayer
FROM pymor/ngsolve_py${PYVER}:${VERTAG} as ngsolve
FROM pymor/dealii_py${PYVER}:${VERTAG} as dealii
FROM pymor/python_${PYVER}:${VERTAG}

MAINTAINER René Fritze <rene.fritze@wwu.de>

# needs repeating to be usable outside FROM
ARG PYVER

ENV DEBIAN_FRONTEND=noninteractive \
    APTINSTALL="apt-get install -q -y --no-install-recommends" \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    PETSC_DIR=/usr/local/petsc-32 \
    DOCKER_NGSOLVE=1 \
    DOCKER_PYMOR=1 \
    OPENBLAS_NUM_THREADS=1 \
    GOTO_NUM_THREADS=1 \
    OMP_NUM_THREADS=1

RUN apt-get update && \
    echo "C.UTF-8 UTF-8" > /etc/locale.gen && \
    ${APTINSTALL} wget curl less software-properties-common \
        libboost-all-dev texlive-base xvfb gnupg libatlas-base-dev \
        gcc g++ gfortran make libc6-dev dirmngr eatmydata pandoc \
        gmsh sudo paraview-python swig cmake libeigen3-dev python-subprocess32 \
        aptitude bison flex libopenblas-dev liblapack-dev libpcre3-dev ninja-build \
        xauth python3 python3-opengl mpi-default-dev python3-virtualenv gsl-bin \
        libgmp-dev libmpfr-dev libcln-dev vim libhdf5-mpi-dev openmpi-bin libopenmpi-dev gosu && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    ${APTINSTALL} --allow-unauthenticated git-lfs && \
    git lfs install && \
    echo "alias ls='ls -h --color=auto'" >> /etc/bash.bashrc && \
    echo "alias ll='ls -lh'" >> /etc/bash.bashrc && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV DEBIAN_FRONTEND=teletype \
    SLEPC_DIR=/usr/local/slepc-32 \
    PETSC_DIR=/usr/local/petsc-32

COPY --from=fenicslayer /usr/local/ /usr/local/
COPY --from=dealii /usr/local/ /usr/local/
COPY --from=ngsolve /usr/local/ /usr/local/

RUN apt update && \
    apt-get install -q -y --no-install-recommends liboce-modeling11 liboce-ocaf11 libopengl0 \
      libumfpack5 libmuparser2v5 libatlas3-base libnetcdf-c++4 libgsl23 &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    python -c "import ngsolve"

COPY entrypoint.sh /usr/local/bin/
COPY *.pip.conf /usr/local/share/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["./.ci/gitlab/script.bash"]
