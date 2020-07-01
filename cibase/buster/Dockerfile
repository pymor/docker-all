ARG PYVER
ARG VERTAG

FROM pymor/fenics_py${PYVER}:${VERTAG} as fenicslayer
FROM pymor/ngsolve_py${PYVER}:${VERTAG} as ngsolve
FROM pymor/dealii_py${PYVER}:${VERTAG} as dealii
FROM pymor/python_${PYVER}:${VERTAG}

MAINTAINER René Fritze <rene.fritze@wwu.de>

# needs repeating to be usable outside FROM
ARG PYVER

ENV PETSC_DIR=/usr/local/petsc-32 \
    DOCKER_NGSOLVE=1 \
    DOCKER_PYMOR=1 \
    OPENBLAS_NUM_THREADS=1 \
    GOTO_NUM_THREADS=1 \
    OMP_NUM_THREADS=1

# -dev packages should be kept as few as possible, and listed here with reasoning
# mpi-default-dev: mpi4py install depends on it
RUN apt-get update && \
    ${APTINSTALL} wget curl less \
        texlive-base xvfb gnupg ca-certificates \
        gcc g++ gfortran make dirmngr pandoc \
        gmsh swig cmake \
        aptitude bison flex ninja-build \
        xauth gsl-bin git-lfs \
        vim openmpi-bin mpi-default-dev gosu && \
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
    python -c "import ngsolve" && \
    pip uninstall -y pymor && \
    pip install termtables python-dotenv

COPY pymor-info /usr/local/bin/

COPY entrypoint.sh /usr/local/bin/
COPY *.pip.conf /usr/local/share/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["./.ci/gitlab/script.bash"]
