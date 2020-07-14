FROM pymor/constraints_pyPYVER:VERTAG as constraints

FROM python:PYVER

ENV MIRROR_VERSION=4.0.2 \
  PIP_VERSION=20.1.1 \
  SERVER_ROOT=/pymor \
  PYTORCH_VERSION=1.5.1
RUN pip install "python-pypi-mirror==${MIRROR_VERSION}"  pip==${PIP_VERSION} \
      requests-toolbelt virtualenv\
  && useradd --shell /bin/bash -u 1000 -o -m -d /data -c "" -m pymor \
  && mkdir ${SERVER_ROOT} \
  && chown pymor ${SERVER_ROOT}

COPY --from=constraints /requirements/*.txt ${SERVER_ROOT}/requirements/
# non-installable packages need to be filtered from download
# pytorch needs special casing due to --follow url
RUN virtualenv /tmp/venv \
  && cd ${SERVER_ROOT}/requirements \
  && /tmp/venv/bin/pip download -d ../downloads pip \
  && (for fn in PYVER_oldest_req*.txt ; do \
    set +e ; \
    grep -v fenics ${fn} | grep -v pymor-dealii | grep -v torch > filtered_req ; \
    set -e ; \
    /tmp/venv/bin/pip download -d ../downloads -r filtered_req \
      -c ${SERVER_ROOT}/requirements/PYVER_oldest_constraints.txt && \
    echo 'done part 1 ************************************* ' ${fn} ; \
  done) \
  && /tmp/venv/bin/pip download -d ../downloads torch==${PYTORCH_VERSION}+cpu \
      -f https://download.pytorch.org/whl/torch_stable.html \
      -c ${SERVER_ROOT}/requirements/PYVER_oldest_constraints.txt
RUN cd ${SERVER_ROOT}/ \
  && pypi-mirror create -d downloads -m simple \
  && rm -rf /tmp/*
USER pymor
WORKDIR ${SERVER_ROOT}
ENTRYPOINT ["python", "-m", "http.server", "--bind", "0.0.0.0", "8080" ]
