FROM pymor/fenics_pyPYVER:VERTAG as fenicslayer
FROM pymor/ngsolve_pyPYVER:VERTAG as ngsolve
FROM pymor/dealii_pyPYVER:VERTAG as dealii
FROM pymor/python_PYVER:VERTAG

MAINTAINER René Fritze <rene.fritze@wwu.de>

ENV DOCKER_NGSOLVE=1 \
    DOCKER_PYMOR=1 \
    OPENBLAS_NUM_THREADS=1 \
    GOTO_NUM_THREADS=1 \
    OMP_NUM_THREADS=1 \
    DEBIAN_FRONTEND=teletype \
    SLEPC_DIR=/usr/local/slepc-32 \
    PETSC_DIR=/usr/local/petsc-32 \
    BOOST_VERSION=1.67.0

# -dev packages should be kept as few as possible, and listed here with reasoning
# mpi-default-dev: mpi4py install depends on it
# libopenblas-dev: slycot install needs it
# boost-* for fenics/petsc
# ngsolve: liboce-modeling11 liboce-ocaf11 libopengl0 \
#          libumfpack5 libmuparser2v5 libatlas3-base libnetcdf-c++4 libgsl23
RUN apt-get update && \
    ${APTINSTALL} wget curl less \
        texlive-base xvfb gnupg ca-certificates \
        gcc g++ gfortran make dirmngr pandoc \
        gmsh swig cmake libopenblas-dev \
        aptitude bison flex ninja-build \
        xauth gsl-bin git-lfs \
        vim openmpi-bin mpi-default-dev gosu sudo \
        liboce-modeling11 liboce-ocaf11 libopengl0 \
        libumfpack5 libmuparser2v5 libatlas3-base libnetcdf-c++4 libgsl23 \
        libboost-filesystem${BOOST_VERSION} \
        libboost-iostreams${BOOST_VERSION} \
        libboost-math${BOOST_VERSION} \
        libboost-regex${BOOST_VERSION} \
        libboost-program-options${BOOST_VERSION} \
        libboost-system${BOOST_VERSION} \
        libboost-thread${BOOST_VERSION} \
        libboost-timer${BOOST_VERSION}  && \
    echo "alias ls='ls -h --color=auto'" >> /etc/bash.bashrc && \
    echo "alias ll='ls -lh'" >> /etc/bash.bashrc && \
    echo "source /usr/local/share/dolfin/dolfin.conf" >> /etc/bash.bashrc && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


COPY --from=fenicslayer /usr/local/ /usr/local/
COPY --from=dealii /usr/local/ /usr/local/
COPY --from=ngsolve /usr/local/ /usr/local/

RUN python -c "import ngsolve" && \
    python -c "import dolfin" && \
    pip install termtables python-dotenv # for pymor-info script

COPY pymor-info /usr/local/bin/

COPY entrypoint.sh /usr/local/bin/
COPY *.pip.conf /usr/local/share/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["./.ci/gitlab/script.bash"]
