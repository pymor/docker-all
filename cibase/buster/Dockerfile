# EXPERIMENTAL_SYNTAX
FROM REGISTRY/pymor/python_PYVER:VERTAG

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
# matplotlib/Qt backend: libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
#     libxcb-render-util0 libxcb-shape0 libxcb-xfixes0 libxcb-xinerama0 libxcb-xkb1 libxkbcommon-x11-0
# fenics/petsc:
#         boost*
#         libsz2
#         libhdf5-mpi-dev
#         libeigen3-dev
# ngsolve: liboce-modeling11 liboce-ocaf11 libopengl0 \
#          libumfpack5 libmuparser2v5 libatlas3-base libnetcdf-c++4 libgsl23
# gmsh: libxcursor1 libxinerama1
RUN MOUNT_CACHE \
    apt-get update && \
    ${APTINSTALL} wget curl less \
        texlive-base xvfb gnupg ca-certificates \
        gcc g++ gfortran make dirmngr pandoc \
        swig cmake libopenblas-dev \
        aptitude bison flex ninja-build \
        xauth gsl-bin git-lfs \
        vim openmpi-bin mpi-default-dev gosu sudo \
        liboce-modeling11 liboce-ocaf11 libopengl0 \
        libumfpack5 libmuparser2v5 libatlas3-base libnetcdf-c++4 libgsl23 \
        libhdf5-mpi-dev \
        libboost-filesystem-dev \
        libboost-iostreams-dev \
        libboost-math-dev \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-thread-dev \
        libboost-timer-dev \
        libeigen3-dev \
        libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-randr0 \
          libxcb-render-util0 libxcb-shape0 libxcb-xfixes0 libxcb-xinerama0 libxcb-xkb1 libxkbcommon-x11-0 \
        libxcursor1 libxinerama1 \
        libsz2  && \
    echo "alias ls='ls -h --color=auto'" >> /etc/bash.bashrc && \
    echo "alias ll='ls -lh'" >> /etc/bash.bashrc && \
    echo "source /usr/local/share/dolfin/dolfin.conf" >> /etc/bash.bashrc && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


COPY --from=REGISTRY/pymor/fenics_pyPYVER:VERTAG /usr/local/ /usr/local/
COPY --from=REGISTRY/pymor/dealii_pyPYVER:VERTAG /usr/local/ /usr/local/
COPY --from=REGISTRY/pymor/ngsolve_pyPYVER:VERTAG /usr/local/ /usr/local/

RUN MOUNT_CACHE \
    python -c "import ngsolve" && \
    pip install termtables python-dotenv # for pymor-info script

COPY pymor-info /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/
COPY *.pip.conf /usr/local/share/

COPY --from=pymor/pypi-mirror_stable_pyPYVER:VERTAG /pymor/downloads/* /tmp/dependencies/
RUN --mount=type=cache,sharing=locked,id=pymor_aptcache,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,id=pymor_cache,target=/cache/ \
    --mount=type=cache,sharing=locked,id=pymor_aptlib,target=/var/lib/apt \
    set -exu && for pkg in /tmp/dependencies/* ; do pip install --no-deps --no-cache-dir ${pkg} && rm ${pkg} ; done

# from here on images are user facing, unset away from mounted cache
ENV CCACHE_DIR=/tmp/ccache \
    XDG_CACHE_HOME=
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["./.ci/gitlab/script.bash"]
