ARG PYVER
ARG VERTAG=latest

FROM pymor/pypi-mirror_stable_py${PYVER}:${VERTAG} as dependencies

FROM pymor/testing_py${PYVER}:${VERTAG}

MAINTAINER René Fritze <rene.fritze@wwu.de>

# needs repeating to be usable outside FROM
ARG VERTAG

# the pythreejs needs npm/nodejs installed for the jupter lab extension
RUN /bin/bash -c "curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    &&  apt update && apt install nodejs &&\
    pip install jupyterlab && \
    jupyter nbextension install --py --symlink --sys-prefix pythreejs && \
    jupyter nbextension enable --py --sys-prefix pythreejs && \
    jupyter labextension install jupyter-threejs && \
    pip install nbresuse jupyter_contrib_nbextensions && \
    jupyter contrib nbextension install --sys-prefix && \
    jupyter nbextension enable collapsible_headings/main && \
    jupyter nbextension enable codefolding/main && \
    jupyter nbextension enable notify/notify && \
    jupyter nbextension enable scroll_down/main"
COPY dev-entrypoint.bash /usr/local/bin/
COPY ipython_kernel_config.py /etc/ipython/

# automatic cache busting since docker will otherwise NOT rebuild if VERTAG (and thereby the mirror image) changes 
RUN echo ${VERTAG} > /tmp/vertag
COPY --from=dependencies /pymor/downloads/* /tmp/dependencies/
RUN /bin/bash -c "pip install /tmp/dependencies/*"

ENTRYPOINT ["/usr/local/bin/dev-entrypoint.bash"]
