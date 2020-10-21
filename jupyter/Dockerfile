# syntax = docker/dockerfile:experimental
FROM pymor/testing_pyPYVER:VERTAG

MAINTAINER René Fritze <rene.fritze@wwu.de>

# libopenblas-dev: needed for slycot install (wheel building)
# mpi-default-dev: for mpi4py install/wheel
# the pythreejs needs npm/nodejs installed for the jupter lab extension
RUN --mount=type=cache,sharing=locked,id=pymor_aptcache,target=/var/cache/apt \
    --mount=type=cache,sharing=locked,id=pymor_cache,target=/cache/ \
    --mount=type=cache,sharing=locked,id=pymor_aptlib,target=/var/lib/apt \
    /bin/bash -c "curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    &&  apt update && ${APTINSTALL} nodejs libopenblas-dev mpi-default-dev &&\
    pip install jupyterlab pythreejs && \
    jupyter nbextension install --py --symlink --sys-prefix pythreejs && \
    jupyter nbextension install --py --symlink --sys-prefix ngsolve && \
    jupyter nbextension enable --py --sys-prefix pythreejs && \
    jupyter nbextension enable --py --sys-prefix ngsolve && \
    jupyter labextension install jupyter-threejs && \
    jupyter labextension install /usr/local/lib/pythonPYVER/site-packages/ngsolve/labextension && \
    pip install nbresuse jupyter_contrib_nbextensions && \
    jupyter contrib nbextension install --sys-prefix && \
    jupyter nbextension enable collapsible_headings/main && \
    jupyter nbextension enable codefolding/main && \
    jupyter nbextension enable notify/notify && \
    jupyter nbextension enable scroll_down/main"
COPY dev-entrypoint.bash /usr/local/bin/
COPY ipython_kernel_config.py /etc/ipython/

RUN chmod +rx /usr/local/bin/*
ENTRYPOINT ["/usr/local/bin/dev-entrypoint.bash"]
